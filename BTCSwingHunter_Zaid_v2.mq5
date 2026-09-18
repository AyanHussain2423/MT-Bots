//+------------------------------------------------------------------+
//|                                            BTCSwingHunter_Zaid_v2.mq5 |
//|                                     BTC/USD Swing EA for XM       |
//|                        Trend-following swing trader based on      |
//|                        analysis of Paul Wei's public BitMEX       |
//|                        BTC trade history (2020-2026, 70x return)  |
//|                        Last-year stats: 93.8% win rate, 16 round  |
//|                        trips, avg +3.68% per trade, holds days    |
//|                                                                  |
//|                        v2.01 - bar-gate robustness fix           |
//|                        Indicator reads moved BEFORE the H1 bar    |
//|                        gate: a failed CopyBuffer no longer        |
//|                        consumes the bar (was silently skipping    |
//|                        whole H1 bars after one bad tick).         |
//+------------------------------------------------------------------+
#property copyright "BTCSwingHunter"
#property version   "2.01"
#property strict

//--- Input parameters
input double   InpLotSize          = 0.01;        // Lot size
input int      InpMagicNumber      = 20260916;    // Magic number (btc swing)
input int      InpMaxPositions     = 1;           // Max concurrent positions
input ENUM_TIMEFRAMES InpTrendTF   = PERIOD_H4;   // Trend filter timeframe
input int      InpTrendEMA         = 50;          // Trend EMA period (H4)
input ENUM_TIMEFRAMES InpEntryTF   = PERIOD_H1;   // Entry timeframe
input int      InpEntryEMA         = 21;          // Entry EMA period (H1)
input int      InpRSIPeriod        = 14;          // RSI period (entry TF)
input double   InpRSIPullback      = 45.0;        // RSI pullback threshold (buy < this in uptrend)
input double   InpRSIOverbought    = 55.0;        // RSI overbought threshold (sell > this in downtrend)
input int      InpATRPeriod        = 14;          // ATR period (entry TF)
input double   InpATRMultiplier    = 2.0;         // SL = ATR * multiplier
input double   InpRR               = 2.5;         // Risk:Reward ratio (measured move)
input double   InpDailyProfitTarget= 50.0;        // Kill switch: daily profit target
input double   InpDailyLossLimit   = 25.0;        // Kill switch: daily loss limit
input int      InpMaxTradesPerDay  = 3;           // Max new trades per day
input bool     InpUseTrailing      = true;        // Use trailing stop
input double   InpTrailATR         = 2.0;         // Trailing stop ATR multiple

//--- Global variables
int      g_handleTrendEMA;
int      g_handleEntryEMA;
int      g_handleRSI;
int      g_handleATR;
bool     g_dayStopped = false;
datetime g_lastBarTime = 0;
datetime g_dayStart = 0;
int      g_tradesToday = 0;

//+------------------------------------------------------------------+
//| Get the correct filling mode for the symbol                      |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING GetFillingMode()
{
   long fillingFlags = SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);

   if((fillingFlags & SYMBOL_FILLING_FOK) != 0)
      return ORDER_FILLING_FOK;
   if((fillingFlags & SYMBOL_FILLING_IOC) != 0)
      return ORDER_FILLING_IOC;
   return ORDER_FILLING_RETURN;
}

//+------------------------------------------------------------------+
//| Get a valid volume (clamped to symbol min/max/step)              |
//+------------------------------------------------------------------+
double GetValidVolume(double requested)
{
   double minVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   double vol = MathMax(requested, minVol);
   vol = MathMin(vol, maxVol);

   if(stepVol > 0.0)
      vol = MathFloor(vol / stepVol) * stepVol;

   vol = NormalizeDouble(vol, 2);
   return vol;
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   g_handleTrendEMA = iMA(_Symbol, InpTrendTF, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
   g_handleEntryEMA = iMA(_Symbol, InpEntryTF, InpEntryEMA, 0, MODE_EMA, PRICE_CLOSE);
   g_handleRSI      = iRSI(_Symbol, InpEntryTF, InpRSIPeriod, PRICE_CLOSE);
   g_handleATR      = iATR(_Symbol, InpEntryTF, InpATRPeriod);

   if(g_handleTrendEMA == INVALID_HANDLE || g_handleEntryEMA == INVALID_HANDLE ||
      g_handleRSI == INVALID_HANDLE || g_handleATR == INVALID_HANDLE)
   {
      Print("Failed to create indicator handles");
      return(INIT_FAILED);
   }

   g_dayStart = iTime(_Symbol, PERIOD_D1, 0);

   Print("BTCSwingHunter v2.01 initialized. Magic: ", InpMagicNumber,
         ", Lot: ", InpLotSize, ", TrendTF: ", InpTrendTF,
         ", MaxPositions: ", InpMaxPositions);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(g_handleTrendEMA != INVALID_HANDLE) IndicatorRelease(g_handleTrendEMA);
   if(g_handleEntryEMA != INVALID_HANDLE) IndicatorRelease(g_handleEntryEMA);
   if(g_handleRSI != INVALID_HANDLE)      IndicatorRelease(g_handleRSI);
   if(g_handleATR != INVALID_HANDLE)      IndicatorRelease(g_handleATR);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   CheckDayRollover();
   CheckKillSwitch();

   if(g_dayStopped)
      return;

//--- Manage existing positions (trailing stop)
   ManagePositions();

   //--- Get indicator values FIRST (v2.01 FIX: if a read fails we return
   //    WITHOUT advancing g_lastBarTime, so we retry next tick instead of
   //    silently skipping the whole H1 bar)
   double trendEMA[1], entryEMA[1], rsi[1], atr[1];
   if(CopyBuffer(g_handleTrendEMA, 0, 0, 1, trendEMA) < 1) return;
   if(CopyBuffer(g_handleEntryEMA, 0, 0, 1, entryEMA) < 1) return;
   if(CopyBuffer(g_handleRSI, 0, 0, 1, rsi) < 1) return;
   if(CopyBuffer(g_handleATR, 0, 0, 1, atr) < 1) return;

   //--- Process entry once per entry-TF bar
   datetime currentBar = iTime(_Symbol, InpEntryTF, 0);
   if(currentBar == g_lastBarTime)
      return;
   g_lastBarTime = currentBar;

   //--- Position limit
   int openCount = CountOpenPositions();
   if(openCount >= InpMaxPositions)
      return;

   //--- Daily new-trade limit
   if(g_tradesToday >= InpMaxTradesPerDay)
   {
      Print("Daily new-trade limit reached (", InpMaxTradesPerDay, "). Stopping new entries for the day.");
      g_dayStopped = true;
      return;
   }

   //--- Get current price
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return;

   //--- Trend filter (H4): price vs H4 EMA50
   bool uptrend = (tick.bid > trendEMA[0]);
   bool downtrend = (tick.bid < trendEMA[0]);

   //--- SL distance (ATR-based, floored)
   double slDistance = MathMax(InpATRMultiplier * atr[0], 100 * _Point);
   double tpDistance = slDistance * InpRR;

   //--- Entry logic (swing, once per H1 bar)
   //--- BUY: uptrend + pullback (price near/below H1 EMA21 + RSI not overbought)
   bool buySignal = (uptrend && tick.ask <= entryEMA[0] * 1.005 && rsi[0] < InpRSIPullback);
   //--- SELL: downtrend + pullback (price near/above H1 EMA21 + RSI not oversold)
   bool sellSignal = (downtrend && tick.bid >= entryEMA[0] * 0.995 && rsi[0] > InpRSIOverbought);

   //--- Status print every H1 bar so we can see what the bot is waiting for
   Print("BSH status | H4trend: ", (uptrend ? "UP" : (downtrend ? "DOWN" : "FLAT")),
         " | RSI: ", DoubleToString(rsi[0], 1),
         " | price/EMA21: ", DoubleToString(tick.bid / entryEMA[0], 4),
         " | buySig: ", buySignal, " sellSig: ", sellSignal);

   if(buySignal)
   {
      OpenBuy(tick.ask, slDistance, tpDistance, rsi[0]);
   }
   else if(sellSignal)
   {
      OpenSell(tick.bid, slDistance, tpDistance, rsi[0]);
   }
}

//+------------------------------------------------------------------+
//| Manage existing positions - trailing stop                        |
//+------------------------------------------------------------------+
void ManagePositions()
{
   if(!InpUseTrailing)
      return;

   double atr[1];
   if(CopyBuffer(g_handleATR, 0, 0, 1, atr) < 1) return;
   double trailDist = InpTrailATR * atr[0];

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      long type = PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);

      MqlTick tick;
      if(!SymbolInfoTick(_Symbol, tick))
         continue;

      double newSL = 0.0;
      if(type == POSITION_TYPE_BUY)
      {
         //--- Trail below price
         newSL = tick.bid - trailDist;
         //--- Only move SL up, never down
         if(newSL > currentSL + _Point)
         {
            ModifySL(ticket, newSL);
         }
      }
      else if(type == POSITION_TYPE_SELL)
      {
         //--- Trail above price
         newSL = tick.ask + trailDist;
         //--- Only move SL down, never up
         if(currentSL == 0.0 || newSL < currentSL - _Point)
         {
            ModifySL(ticket, newSL);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Modify the stop loss of a position                              |
//+------------------------------------------------------------------+
void ModifySL(ulong ticket, double newSL)
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   request.action = TRADE_ACTION_SLTP;
   request.position = ticket;
   request.symbol = _Symbol;
   request.sl = NormalizeDouble(newSL, (int)_Digits);
   request.tp = PositionGetDouble(POSITION_TP);
   request.type_filling = GetFillingMode();
   request.magic = InpMagicNumber;

   if(OrderSend(request, result))
      Print("Trailing SL updated for #", ticket, " to ", DoubleToString(newSL, (int)_Digits));
}

//+------------------------------------------------------------------+
//| Check if the trading day has rolled over                         |
//+------------------------------------------------------------------+
void CheckDayRollover()
{
   datetime currentDay = iTime(_Symbol, PERIOD_D1, 0);
   if(currentDay != g_dayStart)
   {
      g_dayStart = currentDay;
      g_dayStopped = false;
      g_tradesToday = 0;
      Print("New trading day detected. Resetting day state.");
   }
}

//+------------------------------------------------------------------+
//| Check kill switch - daily P/L guard                              |
//+------------------------------------------------------------------+
void CheckKillSwitch()
{
   double dailyPL = CalculateDailyPL();

   if(dailyPL >= InpDailyProfitTarget)
   {
      Print("KILL SWITCH: Daily profit target reached (+", DoubleToString(dailyPL, 2),
            "). Closing all and stopping for the day.");
      CloseAllPositions();
      g_dayStopped = true;
      return;
   }

   if(dailyPL <= -InpDailyLossLimit)
   {
      Print("KILL SWITCH: Daily loss limit reached (", DoubleToString(dailyPL, 2),
            "). Closing all and stopping for the day.");
      CloseAllPositions();
      g_dayStopped = true;
   }
}

//+------------------------------------------------------------------+
//| Calculate daily P/L (closed + floating)                          |
//+------------------------------------------------------------------+
double CalculateDailyPL()
{
   double total = 0.0;

   HistorySelect(g_dayStart, TimeCurrent());
   int deals = HistoryDealsTotal();
   for(int i = 0; i < deals; i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;

      long magic = HistoryDealGetInteger(ticket, DEAL_MAGIC);
      if(magic != InpMagicNumber) continue;

      long entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_OUT) continue;

      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
      double swap = HistoryDealGetDouble(ticket, DEAL_SWAP);
      double commission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      total += profit + swap + commission;
   }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;

      double profit = PositionGetDouble(POSITION_PROFIT);
      double swap = PositionGetDouble(POSITION_SWAP);
      total += profit + swap;
   }

   return total;
}

//+------------------------------------------------------------------+
//| Count open positions for this EA                                 |
//+------------------------------------------------------------------+
int CountOpenPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
         count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| Close all positions for this EA                                  |
//+------------------------------------------------------------------+
void CloseAllPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
         continue;

      string symbol = PositionGetString(POSITION_SYMBOL);
      long type = PositionGetInteger(POSITION_TYPE);
      double volume = PositionGetDouble(POSITION_VOLUME);

      MqlTick tick;
      if(!SymbolInfoTick(symbol, tick))
         continue;

      MqlTradeRequest request = {};
      MqlTradeResult result = {};

      request.action = TRADE_ACTION_DEAL;
      request.symbol = symbol;
      request.volume = volume;
      request.deviation = 10;
      request.type_filling = GetFillingMode();

      if(type == POSITION_TYPE_BUY)
      {
         request.type = ORDER_TYPE_SELL;
         request.price = tick.bid;
      }
      else
      {
         request.type = ORDER_TYPE_BUY;
         request.price = tick.ask;
      }

      request.magic = InpMagicNumber;
      request.comment = "KillSwitch close";

      if(OrderSend(request, result))
         Print("Closed position #", ticket, " result: ", result.retcode);
      else
         Print("Failed to close position #", ticket, " error: ", result.retcode);
   }
}

//+------------------------------------------------------------------+
//| Open a BUY position                                              |
//+------------------------------------------------------------------+
void OpenBuy(double price, double slDistance, double tpDistance, double rsiValue)
{
   double sl = price - slDistance;
   double tp = price + tpDistance;

   int digits = (int)_Digits;
   sl = NormalizeDouble(sl, digits);
   tp = NormalizeDouble(tp, digits);

   if(!CheckMargin(GetValidVolume(InpLotSize)))
   {
      Print("Insufficient margin for BUY");
      return;
   }

   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = GetValidVolume(InpLotSize);
   request.type = ORDER_TYPE_BUY;
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.deviation = 10;
   request.type_filling = GetFillingMode();
   request.magic = InpMagicNumber;
   request.comment = "BSH BUY";

   if(OrderSend(request, result))
   {
      Print("BUY opened at ", DoubleToString(price, digits),
            " SL: ", DoubleToString(sl, digits),
            " TP: ", DoubleToString(tp, digits),
            " RSI: ", DoubleToString(rsiValue, 1));
      g_tradesToday++;
   }
   else
   {
      Print("BUY failed. Error: ", result.retcode, " (", result.comment, ")");
   }
}

//+------------------------------------------------------------------+
//| Open a SELL position                                             |
//+------------------------------------------------------------------+
void OpenSell(double price, double slDistance, double tpDistance, double rsiValue)
{
   double sl = price + slDistance;
   double tp = price - tpDistance;

   int digits = (int)_Digits;
   sl = NormalizeDouble(sl, digits);
   tp = NormalizeDouble(tp, digits);

   if(!CheckMargin(GetValidVolume(InpLotSize)))
   {
      Print("Insufficient margin for SELL");
      return;
   }

   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = GetValidVolume(InpLotSize);
   request.type = ORDER_TYPE_SELL;
   request.price = price;
   request.sl = sl;
   request.tp = tp;
   request.deviation = 10;
   request.type_filling = GetFillingMode();
   request.magic = InpMagicNumber;
   request.comment = "BSH SELL";

   if(OrderSend(request, result))
   {
      Print("SELL opened at ", DoubleToString(price, digits),
            " SL: ", DoubleToString(sl, digits),
            " TP: ", DoubleToString(tp, digits),
            " RSI: ", DoubleToString(rsiValue, 1));
      g_tradesToday++;
   }
   else
   {
      Print("SELL failed. Error: ", result.retcode, " (", result.comment, ")");
   }
}

//+------------------------------------------------------------------+
//| Check if there's enough margin for a trade                       |
//+------------------------------------------------------------------+
bool CheckMargin(double volume)
{
   double margin = 0.0;
   if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, volume, SymbolInfoDouble(_Symbol, SYMBOL_ASK), margin))
      return false;

   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   return (freeMargin > margin * 1.5);
}
//+------------------------------------------------------------------+

