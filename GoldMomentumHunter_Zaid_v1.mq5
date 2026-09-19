//+------------------------------------------------------------------+
//|                                     GoldMomentumHunter_Zaid_v1.mq5 |
//|                                     M15 Gold Momentum EA for XM    |
//|                                                                  |
//|  Strategy: Xaulgnition long-only momentum (cTrader product 5239) |
//|  Certified GO 2026-09-19 by Strategy Search Batch 1 (C3):        |
//|    357 OOS trades, E +5.82/trade, WR 59.38%, RR 1.01             |
//|    split-sample: half1 +7.19 (176) / half2 +2.74 (185) -> PASS   |
//|  Frozen config: wiki/synthesis/strategy-search-batch-1-precommit.md|
//|                                                                  |
//|  RULES (frozen, do NOT tune):                                    |
//|    1) M15 timeframe, LONG-ONLY.                                  |
//|    2) Trend filter: close > EMA198 (M15).                        |
//|    3) US session only: bar END hour UTC in [13, 20].             |
//|    4) No Fridays (weekend exposure guard).                       |
//|    5) Entry (all on the same closed bar):                        |
//|         - close > EMA198                                         |
//|         - bullish candle with body >= ATR(14) Wilder             |
//|         - close in upper half of the bar's range                 |
//|         - close > previous bar's high                            |
//|    6) SL = 3.7 x ATR(14), TP = 3.9 x ATR(14).                   |
//|    7) Time exit after 24 h if neither hit.                       |
//|    8) One position at a time.                                    |
//|                                                                  |
//|  LIVE vs BACKTEST note: backtest entered at signal-bar close;    |
//|  live enters at market on the first tick of the NEXT bar (the    |
//|  honest live approximation - a few points of slippage at most).  |
//|  ATR is Wilder-smoothed (iATR is SMA-based and would silently    |
//|  change the strategy - we compute Wilder ATR manually).          |
//|                                                                  |
//|  v1.00 - 2026-09-19 - first build from frozen C3 config.        |
//+------------------------------------------------------------------+
#property copyright "Zaid"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>

// ---- inputs (frozen C3 config; defaults = certified values) -------
input double   InpLotSize          = 0.01;        // Lot size (0.01 = 1 oz)
input int      InpMagicNumber      = 20260919;    // Magic number (momentum)
input int      InpEMAPeriod        = 198;         // Trend EMA period (M15)
input int      InpATRPeriod        = 14;          // ATR period (Wilder, M15)
input double   InpSLMultiplier     = 3.7;         // SL = this x ATR
input double   InpTPMultiplier     = 3.9;         // TP = this x ATR
input int      InpSessionStartUTC  = 13;          // US session start (bar END hour UTC)
input int      InpSessionEndUTC    = 20;          // US session end (bar END hour UTC)
input bool     InpNoFridays        = true;        // Skip Friday entries (weekend guard)
input int      InpTimeExitHours    = 24;          // Time exit after this many hours
input double   InpDailyLossLimit   = 0.0;         // Kill switch: daily loss limit (0 = off, NOT in backtest)

// ---- globals -------------------------------------------------------
CTrade  trade;
int     g_emaHandle = INVALID_HANDLE;
datetime g_lastBarTime = 0;
datetime g_dayStart = 0;
double  g_dayPnL = 0.0;
bool    g_killSwitch = false;

//+------------------------------------------------------------------+
//| Wilder ATR at bar 'shift' (0 = forming bar)                      |
//| Wilder RMA smoothing - identical to the frozen engine's atr_wilder|
//+------------------------------------------------------------------+
double WilderATR(const string symbol, ENUM_TIMEFRAMES tf, int period, int shift)
{
   int need = period + 1 + shift + 2;
   double h[], l[], c[];
   if(CopyHigh(symbol, tf, 0, need, h) < need) return 0.0;
   if(CopyLow(symbol, tf, 0, need, l) < need)  return 0.0;
   if(CopyClose(symbol, tf, 0, need, c) < need) return 0.0;

   double tr[];
   ArrayResize(tr, need);
   for(int i = 1; i < need; i++)
      tr[i] = MathMax(h[i] - l[i],
              MathMax(MathAbs(h[i] - c[i - 1]), MathAbs(l[i] - c[i - 1])));

   double seed = 0.0;
   for(int i = 1; i <= period; i++) seed += tr[i];
   seed /= period;

   int target = need - 1 - shift;      // tr index for the requested bar
   if(target <= period) return (target == period) ? seed : 0.0;

   double a = seed;
   for(int i = period + 1; i <= target; i++)
      a = (a * (period - 1) + tr[i]) / period;
   return a;
}

//+------------------------------------------------------------------+
//| Count today's realized PnL for our magic (server day)            |
//+------------------------------------------------------------------+
double TodayPnL()
{
   datetime dayStart = iTime(_Symbol, PERIOD_D1, 0);
   if(dayStart != g_dayStart)
   {
      g_dayStart = dayStart;
      g_dayPnL = 0.0;
   }
   if(!HistorySelect(dayStart, TimeCurrent()))
      return g_dayPnL;

   double pnl = 0.0;
   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != InpMagicNumber) continue;
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
      long entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_INOUT) continue;
      pnl += HistoryDealGetDouble(ticket, DEAL_PROFIT)
           + HistoryDealGetDouble(ticket, DEAL_SWAP)
           + HistoryDealGetDouble(ticket, DEAL_COMMISSION);
   }
   g_dayPnL = pnl;
   return pnl;
}

//+------------------------------------------------------------------+
//| Close all positions with our magic on this symbol                |
//+------------------------------------------------------------------+
void CloseOurPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      trade.PositionClose(ticket);
   }
}

//+------------------------------------------------------------------+
//| Count open positions with our magic on this symbol               |
//+------------------------------------------------------------------+
int CountOurPositions()
{
   int n = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber) n++;
   }
   return n;
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(50);
   trade.SetTypeFillingBySymbol(_Symbol);

   g_emaHandle = iMA(_Symbol, PERIOD_M15, InpEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   if(g_emaHandle == INVALID_HANDLE)
   {
      Print("GoldMomentumHunter: failed to create EMA handle");
      return INIT_FAILED;
   }

   g_dayStart = iTime(_Symbol, PERIOD_D1, 0);
   g_lastBarTime = iTime(_Symbol, PERIOD_M15, 0);

   Print("GoldMomentumHunter v1.00 attached | symbol=", _Symbol,
         " magic=", InpMagicNumber, " lot=", InpLotSize,
         " EMA", InpEMAPeriod, " ATR", InpATRPeriod,
         " SL ", InpSLMultiplier, "x TP ", InpTPMultiplier, "x",
         " session ", InpSessionStartUTC, "-", InpSessionEndUTC, " UTC (bar END)",
         " noFridays=", InpNoFridays, " timeExit=", InpTimeExitHours, "h");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(g_emaHandle != INVALID_HANDLE)
      IndicatorRelease(g_emaHandle);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // ---- kill switch (optional, NOT part of the backtest) ----------
   if(InpDailyLossLimit > 0.0)
   {
      double today = TodayPnL();
      if(today <= -InpDailyLossLimit)
      {
         if(!g_killSwitch)
         {
            g_killSwitch = true;
            CloseOurPositions();
            Print("GoldMomentumHunter KILL SWITCH: daily loss ", today,
                  " <= -", InpDailyLossLimit, " - closing and stopping for the day");
         }
         return;
      }
   }

   // ---- act only on a NEW closed M15 bar --------------------------
   datetime barTime = iTime(_Symbol, PERIOD_M15, 0);
   if(barTime == g_lastBarTime) return;
   g_lastBarTime = barTime;

   // ---- time exit: close any position older than the limit --------
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
      if(TimeCurrent() - openTime >= InpTimeExitHours * 3600)
      {
         trade.PositionClose(ticket);
         Print("GoldMomentumHunter TIME EXIT: closed ticket ", ticket,
               " after ", InpTimeExitHours, "h");
      }
   }

   // ---- session filter: bar END hour UTC in [start, end] ----------
   // bar open (server) + (GMT - server) + 15 min = bar end (GMT)
   int gmtOffset = (int)(TimeGMT() - TimeCurrent());
   datetime barEndGMT = iTime(_Symbol, PERIOD_M15, 1) + gmtOffset + 15 * 60;
   MqlDateTime utc;
   TimeToStruct(barEndGMT, utc);
   if(utc.hour < InpSessionStartUTC || utc.hour > InpSessionEndUTC)
      return;
   if(InpNoFridays && utc.day_of_week == 5)   // MQL5: 0=Sun..5=Fri
      return;

   // ---- entry conditions on the last CLOSED bar (shift 1) ---------
   double c1 = iClose(_Symbol, PERIOD_M15, 1);
   double o1 = iOpen(_Symbol, PERIOD_M15, 1);
   double h1 = iHigh(_Symbol, PERIOD_M15, 1);
   double l1 = iLow(_Symbol, PERIOD_M15, 1);
   double ph = iHigh(_Symbol, PERIOD_M15, 2);   // previous bar high

   double emaBuf[];
   if(CopyBuffer(g_emaHandle, 0, 1, 1, emaBuf) < 1) return;
   double ema = emaBuf[0];
   double atr = WilderATR(_Symbol, PERIOD_M15, InpATRPeriod, 1);
   if(ema <= 0.0 || atr <= 0.0) return;

   // 1) close > EMA198
   if(c1 <= ema) return;
   // 2) bullish candle with body >= ATR
   if(MathAbs(c1 - o1) < atr) return;
   // 3) close in upper half of the bar's range
   if(c1 < (h1 + l1) / 2.0) return;
   // 4) close > previous bar's high
   if(c1 <= ph) return;

   // ---- one position at a time ------------------------------------
   if(CountOurPositions() > 0) return;

   // ---- enter BUY --------------------------------------------------
   double sl = c1 - InpSLMultiplier * atr;
   double tp = c1 + InpTPMultiplier * atr;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if(ask <= 0.0) return;

   if(trade.Buy(InpLotSize, _Symbol, ask, sl, tp, "XGN BUY"))
      Print("GoldMomentumHunter BUY @ ", ask, " SL ", sl, " TP ", tp,
            " | EMA198 ", ema, " ATR ", atr, " barEndUTC ", utc.hour, ":",
            utc.min, " wd ", utc.day_of_week);
   else
      Print("GoldMomentumHunter BUY FAILED: ", trade.ResultRetcode(),
            " ", trade.ResultRetcodeDescription());
}
//+------------------------------------------------------------------+