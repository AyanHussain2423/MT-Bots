//+------------------------------------------------------------------+
//|                                            GoldUTBot_Zaid_v1.mq5  |
//|                                     M15 Gold UT Bot EA for XM     |
//|                                                                  |
//|  Strategy: UT Bot ATR trailing stop (public Pine "UT Bot Alerts", |
//|  Yo_adriiiiaan / HPotter) - trend-following, always-in-market.    |
//|  Certified GO 2026-09-19 by Strategy Search Batch 1 (C1):        |
//|    698 OOS trades, E +4.96/trade, WR 37.82%, RR 2.27             |
//|    split-sample: half1 +1.76 (369) / half2 +5.53 (329) -> PASS   |
//|  Frozen config: wiki/synthesis/strategy-search-batch-1-precommit.md|
//|                                                                  |
//|  RULES (frozen, do NOT tune):                                    |
//|    1) M15 timeframe. Wilder ATR(10) (RMA smoothing - iATR is     |
//|       SMA-based and would silently change the strategy; we       |
//|       compute Wilder RMA manually).                              |
//|    2) KEY_VALUE = 4.5 (centre of the documented robust plateau   |
//|       3.0-6.0 x 5-28).                                           |
//|    3) Trailing stop per the public Pine logic (close vs stop,    |
//|       ratchet up/down).                                          |
//|    4) Always in the market; REVERSE on the opposite signal       |
//|       (close crosses the trailing stop).                         |
//|    5) NO fixed TP, NO broker stop at the trailing level          |
//|       (documented: broker stops destroy 45% of the edge).        |
//|    6) Entry/exit at signal-bar close (live: next bar open - the  |
//|       honest live approximation).                                |
//|    7) No weekend flattening (matches the backtest).              |
//|                                                                  |
//|  v1.00 - 2026-09-19 - first build from frozen C1 config.        |
//+------------------------------------------------------------------+
#property copyright "Zaid"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>

// ---- inputs (frozen C1 config; defaults = certified values) -------
input double   InpLotSize          = 0.01;        // Lot size (0.01 = 1 oz)
input int      InpMagicNumber      = 20260920;    // Magic number (ut bot)
input int      InpATRPeriod        = 10;          // ATR period (Wilder RMA, M15)
input double   InpKeyValue         = 4.5;         // Key value (trailing distance = KV x ATR)
input double   InpDisasterSL_ATR   = 0.0;         // Optional disaster SL in ATRs (0 = off; NOT in backtest)
input double   InpDailyLossLimit   = 0.0;         // Kill switch: daily loss limit (0 = off, NOT in backtest)

// ---- globals -------------------------------------------------------
CTrade  trade;
datetime g_lastBarTime = 0;
double  g_stop = 0.0;        // current trailing stop level
int     g_side = 0;          // 1 = long, -1 = short, 0 = flat (state machine)
double  g_dayStart = 0;
double  g_dayPnL = 0.0;
bool    g_killSwitch = false;

//+------------------------------------------------------------------+
//| Wilder RMA (same smoothing as the frozen engine's atr_wilder)    |
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

   int target = need - 1 - shift;
   if(target <= period) return (target == period) ? seed : 0.0;

   double a = seed;
   for(int i = period + 1; i <= target; i++)
      a = (a * (period - 1) + tr[i]) / period;
   return a;
}

//+------------------------------------------------------------------+
//| Rebuild the trailing-stop state machine from history             |
//| (walk back N closed bars so a restart converges to the same      |
//|  state the backtest would have had at this point)                |
//+------------------------------------------------------------------+
void RebuildState()
{
   int bars = 1000;   // ~10.4 days of M15 - plenty for convergence
   double c[], h[], l[];
   if(CopyClose(_Symbol, PERIOD_M15, 1, bars, c) < bars) return;
   if(CopyHigh(_Symbol, PERIOD_M15, 1, bars, h) < bars)  return;
   if(CopyLow(_Symbol, PERIOD_M15, 1, bars, l) < bars)   return;

   g_stop = 0.0;
   g_side = 0;
   for(int i = 1; i < bars; i++)
   {
      double a = WilderATR(_Symbol, PERIOD_M15, InpATRPeriod, bars - i);
      if(a <= 0.0) continue;
      double ps = g_stop;
      double ci = c[i], cprev = c[i - 1];
      if(ci > ps && cprev > ps)
         g_stop = MathMax(ps, ci - InpKeyValue * a);
      else if(ci < ps && cprev < ps)
         g_stop = MathMin(ps, ci + InpKeyValue * a);
      else if(ci > ps)
         g_stop = ci - InpKeyValue * a;
      else
         g_stop = ci + InpKeyValue * a;

      if(ci < ps && cprev > ps)
         g_side = -1;
      else if(ci > ps && cprev < ps)
         g_side = 1;
      // else: keep previous side
   }
   Print("GoldUTBot state rebuilt: side=", g_side, " stop=", g_stop);
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
//| Current position side with our magic (1 long, -1 short, 0 flat)  |
//+------------------------------------------------------------------+
int OurPositionSide()
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      long type = PositionGetInteger(POSITION_TYPE);
      return (type == POSITION_TYPE_BUY) ? 1 : -1;
   }
   return 0;
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(50);
   trade.SetTypeFillingBySymbol(_Symbol);

   g_dayStart = iTime(_Symbol, PERIOD_D1, 0);
   g_lastBarTime = iTime(_Symbol, PERIOD_M15, 0);

   RebuildState();

   Print("GoldUTBot v1.00 attached | symbol=", _Symbol,
         " magic=", InpMagicNumber, " lot=", InpLotSize,
         " ATR", InpATRPeriod, " KV ", InpKeyValue,
         " disasterSL=", InpDisasterSL_ATR, "xATR (0=off)",
         " dailyLossLimit=", InpDailyLossLimit);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
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
            Print("GoldUTBot KILL SWITCH: daily loss ", today,
                  " <= -", InpDailyLossLimit, " - closing and stopping for the day");
         }
         return;
      }
   }

   // ---- act only on a NEW closed M15 bar --------------------------
   datetime barTime = iTime(_Symbol, PERIOD_M15, 0);
   if(barTime == g_lastBarTime) return;
   g_lastBarTime = barTime;

   // ---- update the state machine one step (last closed bar) -------
   double c1 = iClose(_Symbol, PERIOD_M15, 1);
   double c2 = iClose(_Symbol, PERIOD_M15, 2);
   double atr = WilderATR(_Symbol, PERIOD_M15, InpATRPeriod, 1);
   if(atr <= 0.0) return;

   double ps = g_stop;
   if(c1 > ps && c2 > ps)
      g_stop = MathMax(ps, c1 - InpKeyValue * atr);
   else if(c1 < ps && c2 < ps)
      g_stop = MathMin(ps, c1 + InpKeyValue * atr);
   else if(c1 > ps)
      g_stop = c1 - InpKeyValue * atr;
   else
      g_stop = c1 + InpKeyValue * atr;

   int newSide = g_side;
   if(c1 < ps && c2 > ps)
      newSide = -1;                       // close crossed below stop -> SHORT
   else if(c1 > ps && c2 < ps)
      newSide = 1;                        // close crossed above stop -> LONG

   int curSide = OurPositionSide();

   // ---- reverse / open to match the state machine -----------------
   if(newSide != 0 && newSide != curSide)
   {
      if(curSide != 0)
      {
         CloseOurPositions();
         Print("GoldUTBot REVERSE: closed ", (curSide == 1 ? "LONG" : "SHORT"),
               " -> new side ", (newSide == 1 ? "LONG" : "SHORT"),
               " | stop ", g_stop, " close ", c1);
      }
      double price = (newSide == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                                    : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(price <= 0.0) return;

      double sl = 0.0;
      if(InpDisasterSL_ATR > 0.0)
         sl = (newSide == 1) ? price - InpDisasterSL_ATR * atr
                             : price + InpDisasterSL_ATR * atr;

      bool ok = (newSide == 1)
              ? trade.Buy(InpLotSize, _Symbol, price, sl, 0.0, "UTB BUY")
              : trade.Sell(InpLotSize, _Symbol, price, sl, 0.0, "UTB SELL");
      if(ok)
         Print("GoldUTBot ", (newSide == 1 ? "BUY" : "SELL"), " @ ", price,
               " disasterSL ", sl, " | stop ", g_stop);
      else
         Print("GoldUTBot order FAILED: ", trade.ResultRetcode(),
               " ", trade.ResultRetcodeDescription());
   }
}
//+------------------------------------------------------------------+