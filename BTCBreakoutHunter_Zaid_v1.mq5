//+------------------------------------------------------------------+
//|                                          BTCBreakoutHunter_Zaid_v1.mq5 |
//|                                     BTC Breakout EA for XM        |
//|                        Breakout + Trend Filter + Fixed Money       |
//|                        Port of GoldBreakoutHunter v3.14 to BTCUSD. |
//|                        BTC moves enough that M5/M15 breakouts fire |
//|                        daily (unlike the swing bot, which waits    |
//|                        for H4 setups and can sit for days).        |
//|                                                                  |
//|                        v1.04 - STOP-OUT PENALTY GATE (replaces     |
//|                        the time cooldown). Same fix as gold v3.20:  |
//|                        after an SL, same-direction entries need a   |
//|                        NEW channel extreme (new low for sells / new |
//|                        high for buys) - the market must prove the   |
//|                        bounce failed. No time blindness. After a TP:|
//|                        no restriction.                              |
//|                                                                  |
//|                        v1.05 - DAILY COUNTER RESTORED ON INIT     |
//|                        Same fix as gold v3.21: g_tradesToday was   |
//|                        memory-only - every re-attach reset it to 0,|
//|                        so the 4/day cap never held across restarts.|
//|                        OnInit now counts today's DEAL_ENTRY_IN     |
//|                        deals with our magic and restores it.       |
//|                                                                  |
//|                        v1.03 - STATUS PRINT BEFORE GATES +         |
//|                        COOLDOWN 15->5min. Same fix as gold v3.19:  |
//|                        the status print sat AFTER the cooldown/    |
//|                        position/daily gates, so the bot went silent |
//|                        (looked dead) for 15 min after every trade.  |
//|                        Print now runs every channel bar regardless  |
//|                        of gates. Cooldown default cut to 5 min.     |
//|                                                                  |
//|                        v1.02 - RAW TREND FOR TREND ENTRIES        |
//|                        Same fix as gold v3.18: v1.01 removed the   |
//|                        slope from the trendSell condition, but     |
//|                        `bearish` itself was still slope-filtered.  |
//|                        Slope read RISE -> bearish=FALSE -> TrendCont|
//|                        false/false even with price 360 pts below   |
//|                        EMA50 (09-10 00:15 print). Trend entries now|
//|                        use RAW price-vs-EMA50. Channel breaks keep |
//|                        the slope filter (conservative).            |
//|                                                                  |
//|                        v1.01 - TREND CONTINUATION + DISTANCE      |
//|                        Port of gold v3.16/v3.17 fixes:            |
//|                        (1) trend-continuation entries catch slow  |
//|                        grinds the channel break misses (price near |
//|                        channel edge + strong trend), (2) trend     |
//|                        entries use PRICE DISTANCE from EMA50       |
//|                        (>= InpTrendDistance) instead of the slope  |
//|                        (slope flips to RISE on a single bar bounce |
//|                        and blocks sells while price falls 360+ pts |
//|                        below the EMA - 09-10 00:15 print),         |
//|                        (3) slope smoothed to 3-bar comparison.     |
//|                                                                  |
//|                        v1.00 - FIXED $5 SL / $10 TP (2:1)        |
//|                        Same proven filters as gold v3.14:          |
//|                        EMA50 slope, H1 confirm, reopen guard,      |
//|                        kill switch, Donchian breakout.             |
//+------------------------------------------------------------------+
#property copyright "BTCBreakoutHunter"
#property version   "1.06"
#property strict

//--- Input parameters
input double   InpLotSize          = 0.01;        // Lot size (0.01 = 0.01 BTC)
input int      InpMagicNumber      = 20260917;    // Magic number (BTC breakout)
input int      InpMaxTrades        = 1;           // Max concurrent positions (1 = no hedging)
input int      InpChannelPeriod    = 20;          // Donchian channel period (breakout range)
input ENUM_TIMEFRAMES InpChannelTF  = PERIOD_M5;   // Channel timeframe (M5 = less noise than M1 on BTC)
input int      InpEMA50Period      = 50;          // EMA 50 period (trend filter)
input ENUM_TIMEFRAMES InpTrendTF    = PERIOD_M15;  // Trend filter timeframe (M15 = real trend)
input double   InpSLMoney          = 5.0;         // Stop loss in account currency ($)
input double   InpTPMoney          = 10.0;        // Take profit in account currency ($) - 2:1 RR
input double   InpDailyProfitTarget= 32.0;        // Kill switch: daily profit target
input double   InpDailyLossLimit   = 50.0;        // Kill switch: daily loss limit
input int      InpCutoffHour       = 23;          // Daily cutoff hour (local)
input int      InpCutoffMinute     = 59;          // Daily cutoff minute (local)
input int      InpMaxTradesPerDay  = 4;           // Max trades per day
input bool     InpUseEMASlope      = true;        // EMA slope filter (BUY only if EMA50 rising)
input bool     InpUseH1Confirm     = true;        // H1 EMA50 trend confirmation
input int      InpReopenGuardMinutes = 20;        // Skip minutes after a market gap (broker maintenance)
input bool     InpUseTrendContinuation = true;    // v1.01: trend-continuation entries (slow grinds)
input double   InpChannelProximity = 500.0;       // v1.01: enter when price within this many pts of channel edge
input double   InpTrendDistance = 300.0;          // v1.01: min price distance from EMA50 for trend entries
input int      InpMaxTrendEntriesPerDay = 3;      // v1.01: max trend-continuation entries per day

//--- Global variables
int      g_handleEMA50;
int      g_handleH1EMA50;
bool     g_dayStopped = false;
datetime g_dayStart = 0;
double   g_dayStartBalance = 0.0;
int      g_tradesToday = 0;
datetime g_lastTradeTime = 0;
datetime g_lastBarTime = 0;      // Last channel bar we evaluated (one trade per bar)
datetime g_reopenUntil = 0;      // v3.13: no entries until this time (post-reopen guard)
int      g_trendEntriesToday = 0; // v1.01: trend-continuation entries today
datetime g_trendDayStart = 0;     // v1.01: day tracking for trend counter
bool     g_afterSL = false;       // v1.04: last exit was a stop-out (penalty active)
int      g_slDirection = 0;       // v1.04: 1 = BUY SL, -1 = SELL SL, 0 = none
double   g_slChannelExtreme = 0.0;// v1.04: channel high/low at SL detection (re-entry proof)
datetime g_lastExitTime = 0;      // v1.04: time of last SL/TP deal seen
datetime g_lastExitCheck = 0;     // v1.04: throttle for CheckLastExit (once per minute)
datetime g_lastCountCheck = 0;    // v1.06: throttle for CountTradesToday() refresh (once per minute)
bool     g_limitPrinted = false;  // v1.06: print the daily-limit message once per day

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
g_handleEMA50 = iMA(_Symbol, InpTrendTF, InpEMA50Period, 0, MODE_EMA, PRICE_CLOSE);
   g_handleH1EMA50 = iMA(_Symbol, PERIOD_H1, InpEMA50Period, 0, MODE_EMA, PRICE_CLOSE);

   if(g_handleEMA50 == INVALID_HANDLE || g_handleH1EMA50 == INVALID_HANDLE)
   {
      Print("Failed to create indicator handles");
      return(INIT_FAILED);
   }

g_dayStart = ServerDayStart();   // v3.11 FIX: server midnight, NOT the D1
                                    // bar boundary (D1 starts 00:00 UTC =
                                    // 21:30 server, which counted YESTERDAY's
                                    // P/L and tripped the kill switch on load)
   g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   g_lastBarTime = iTime(_Symbol, InpChannelTF, 0);
   g_trendEntriesToday = 0;      // v1.01
   g_trendDayStart = ServerDayStart(); // v1.01
   g_tradesToday = CountTradesToday(true); // v1.06: restore + diagnostic print of each counted deal

Print("BTCBreakoutHunter v1.05 initialized. Magic: ", InpMagicNumber,
         ", Lot: ", InpLotSize, ", Channel: ", InpChannelPeriod, "x", EnumToString(InpChannelTF),
         ", TrendTF: ", EnumToString(InpTrendTF),
         ", MaxTrades/Day: ", InpMaxTradesPerDay,
         ", MaxPos: ", InpMaxTrades,
         ", EMASlope: ", InpUseEMASlope, ", H1Confirm: ", InpUseH1Confirm,
         ", ReopenGuard: ", InpReopenGuardMinutes, "min",
         ", TrendCont: ", InpUseTrendContinuation, " (dist>=", InpTrendDistance,
         ", prox<=", InpChannelProximity, ", max ", InpMaxTrendEntriesPerDay, "/day)",
         ", TradesToday: ", g_tradesToday);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(g_handleEMA50 != INVALID_HANDLE)    IndicatorRelease(g_handleEMA50);
   if(g_handleH1EMA50 != INVALID_HANDLE)  IndicatorRelease(g_handleH1EMA50);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   CheckDayRollover();
   if(g_dayStopped)          // v3.11 FIX: stop BEFORE the kill switch check,
      return;                // so it can only fire ONCE per day (was firing
                             // every tick, opening a new trade each time)
   CheckKillSwitch();
   CheckDailyCutoff();

//--- Get indicator values FIRST (v3.12 FIX: if a read fails we return
   //    WITHOUT advancing g_lastBarTime, so we retry next tick instead of
   //    silently skipping the whole M1 bar)
   double ema50[4], h1ema50[1];
   if(CopyBuffer(g_handleEMA50, 0, 0, 4, ema50) < 4) return;   // [0]=now, [3]=3 bars ago (smoothed slope)
   if(CopyBuffer(g_handleH1EMA50, 0, 0, 1, h1ema50) < 1) return;

   //--- HARD GATE 1: one trade per channel bar (prevents same-bar re-entry)
   datetime currentBar = iTime(_Symbol, InpChannelTF, 0);
   if(currentBar == g_lastBarTime)
      return;

   //--- v3.13 REOPEN DETECTION: a gap > 5 min in channel bars means the
   //    market was closed (broker maintenance / weekend). Pause entries
   //    after reopen - gap fakeouts caused trade #1 loss on 09-10.
   if(g_lastBarTime != 0 && currentBar - g_lastBarTime > 300)
   {
      g_reopenUntil = TimeCurrent() + InpReopenGuardMinutes * 60;
      Print("Market reopen detected (bar gap ", (currentBar - g_lastBarTime),
            "s). Entries paused until ", TimeToString(g_reopenUntil));
   }
g_lastBarTime = currentBar;

   //--- v1.04: detect if our last position closed at SL (stop-out penalty)
   CheckLastExit();

   //--- v1.03: gates 2-4 (position/daily/cooldown) moved AFTER the status
   //    print so the bot always reports what it's waiting for, even while
   //    a position is open or during cooldown (was silent = looked dead).

   //--- Get current price
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return;

//--- Get Donchian channel (breakout range) from the last N bars
   double highMax = 0.0, lowMin = DBL_MAX;
   for(int i = 1; i <= InpChannelPeriod; i++)
   {
      double h = iHigh(_Symbol, InpChannelTF, i);
      double l = iLow(_Symbol, InpChannelTF, i);
      if(h > highMax) highMax = h;
      if(l < lowMin)  lowMin = l;
   }

   //--- Channel slope: is the channel expanding in the breakout direction?
   //    (prevents buying a flat/falling channel = buying tops)
   double highMaxPrev = 0.0, lowMinPrev = DBL_MAX;
   for(int i = InpChannelPeriod + 1; i <= 2 * InpChannelPeriod; i++)
   {
      double h = iHigh(_Symbol, InpChannelTF, i);
      double l = iLow(_Symbol, InpChannelTF, i);
      if(h > highMaxPrev) highMaxPrev = h;
      if(l < lowMinPrev)  lowMinPrev = l;
   }
   bool channelRising  = (highMax > highMaxPrev);
   bool channelFalling = (lowMin < lowMinPrev);

   //--- Trend filter: price vs EMA50 on the TREND timeframe (M15, not M1)
   //    M1 EMA50 = 50 min of noise -> caused counter-trend BUYs in
   //    falling markets (3 SL hits on 2026-09-09). M15 = real trend.
   bool bullish = (tick.bid > ema50[0]);
   bool bearish = (tick.bid < ema50[0]);

   //--- v1.01 SMOOTHED EMA SLOPE: compare EMA50 now vs 3 bars ago (45 min
   //    on M15) instead of bar-to-bar. Bar-to-bar wiggle flips to RISE on
   //    a single bounce and blocks sells while price falls (09-10).
   bool emaRising  = (ema50[0] > ema50[3]);
   bool emaFalling = (ema50[0] < ema50[3]);
   if(InpUseEMASlope)
   {
      bullish  = bullish && emaRising;
      bearish  = bearish && emaFalling;
   }

   //--- v3.13 H1 CONFIRMATION: the M15 signal must agree with the H1 trend
   //    (higher-timeframe filter - blocks M15 bounces inside an H1 downtrend)
   bool h1Bullish = (tick.bid > h1ema50[0]);
   bool h1Bearish = (tick.bid < h1ema50[0]);
   if(InpUseH1Confirm)
   {
      bullish = bullish && h1Bullish;
      bearish = bearish && h1Bearish;
   }

   //--- Fresh-breakout guard: previous bar must have closed INSIDE the
   //    channel (price just broke out now, not extended/chasing)
   double prevClose = iClose(_Symbol, InpChannelTF, 1);
   bool freshBuy  = (prevClose < highMax);
   bool freshSell = (prevClose > lowMin);

   //--- v3.14 SL/TP from fixed money amounts (user: $5 SL / $10 TP = 2:1).
   //    Converts $ to price distance via tick value/size so it stays correct
   //    for any symbol or lot size. Gold 0.01 lot: $1 = 1.00 price move.
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); // per 1.0 lot
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double valuePerPriceUnit = (tickSize > 0.0 ? tickValue / tickSize : 1.0)
                              * GetValidVolume(InpLotSize);               // $ per 1.00 move
   double slDistance = (valuePerPriceUnit > 0.0) ? InpSLMoney / valuePerPriceUnit
                                                 : 300 * _Point;
   double tpDistance = (valuePerPriceUnit > 0.0) ? InpTPMoney / valuePerPriceUnit
                                                 : slDistance * 2.0;

//--- Breakout logic (checked once per channel bar - flood-proof)
   //--- BUY: bullish trend + rising channel + fresh break above channel high
   bool channelBuy = (bullish && channelRising && freshBuy && tick.ask > highMax);
   bool channelSell = (bearish && channelFalling && freshSell && tick.bid < lowMin);

   //--- v1.02 FIX: trend entries use RAW trend (price vs EMA50), NOT the
   //    slope-filtered bearish/bullish. InpUseEMASlope ANDs bearish with
   //    emaFalling - when the slope reads RISE (single bar bounce), bearish
   //    = FALSE and trendSell never fires even with price 360 pts below the
   //    EMA50 (09-10 00:15 print: EMA50 RISE, bid 77140, dist 360).
   //    Channel breaks keep the slope filter.
   bool rawBullish = (tick.bid > ema50[0]);
   bool rawBearish = (tick.bid < ema50[0]);

   //--- v1.01 TREND CONTINUATION: catch slow grinds the channel break misses.
   //    In a grind, the channel low ratchets down with price, so price never
   //    "breaks" it. When price is far below the EMA50 (strong trend), enter
   //    near the channel low instead of waiting for a break. Uses PRICE
   //    DISTANCE from EMA50 (>= InpTrendDistance) - the slope flips to RISE
   //    on a single bar bounce and blocks sells (09-10 00:15: EMA50 RISE,
   //    price 360 pts below). Distance is unambiguous.
   bool trendSell = false;
   bool trendBuy  = false;

   if(InpUseTrendContinuation)
   {
      // Daily counter reset
      datetime todayStart = ServerDayStart();
      if(todayStart != g_trendDayStart)
      {
         g_trendEntriesToday = 0;
         g_trendDayStart = todayStart;
      }
      bool trendAllow = (g_trendEntriesToday < InpMaxTrendEntriesPerDay);

      // SELL: strong downtrend + price near channel low
      trendSell = rawBearish && (ema50[0] - tick.bid >= InpTrendDistance)
                 && h1Bearish && channelFalling
                 && (tick.bid <= lowMin + InpChannelProximity)
                 && trendAllow;

      // BUY: strong uptrend + price near channel high
      trendBuy = rawBullish && (tick.ask - ema50[0] >= InpTrendDistance)
                && h1Bullish && channelRising
                && (tick.ask >= highMax - InpChannelProximity)
                && trendAllow;
   }

   // Combine: fire on channel break OR trend continuation
   bool buyBreak = channelBuy || trendBuy;
   bool sellBreak = channelSell || trendSell;

//--- Status print every M1 bar so we can see what the bot is waiting for
   Print("BBH status | Bid: ", DoubleToString(tick.bid, (int)_Digits),
         " | Range: ", DoubleToString(highMax, (int)_Digits), "/", DoubleToString(lowMin, (int)_Digits),
         " | DistHi: ", DoubleToString(highMax - tick.bid, (int)_Digits),
         " | DistLo: ", DoubleToString(tick.bid - lowMin, (int)_Digits),
         " | Trend(", EnumToString(InpTrendTF), "): ", (bullish ? "UP" : "DOWN"),
         " | EMA50: ", DoubleToString(ema50[0], (int)_Digits), " ", (emaRising ? "RISE" : "FALL"),
         " | H1: ", (h1Bullish ? "UP" : "DOWN"),
         " | Chan: ", (channelRising ? "RISE" : "FLAT/FALL"), "/", (channelFalling ? "FALL" : "FLAT/RISE"),
         " | Fresh: ", freshBuy, "/", freshSell,
         " | buyBreak: ", buyBreak, " sellBreak: ", sellBreak,
         " | TrendCont: ", trendSell, "/", trendBuy, " (", g_trendEntriesToday, "/", InpMaxTrendEntriesPerDay, ")",
          " | SLpenalty: ", (g_afterSL ? "ON(" + (g_slDirection == -1 ? "SELL" : "BUY") + ")" : "off"));

   //--- v1.03: gates moved here (after the status print) so the bot is
   //    never silent - it reports every channel bar, then decides entries.
   //--- HARD GATE 2: concurrent position limit (1 = no hedging possible)
   int openCount = CountOpenPositions();
   if(openCount >= InpMaxTrades)
      return;

   //--- HARD GATE 3: daily trade limit (v1.06: counter refreshed from
   //    history once per minute so the cap holds across re-attaches;
   //    message printed once per day)
   if(TimeCurrent() - g_lastCountCheck >= 60)
   {
      g_tradesToday = CountTradesToday();
      g_lastCountCheck = TimeCurrent();
   }
   if(g_tradesToday >= InpMaxTradesPerDay)
   {
      if(!g_limitPrinted)
      {
         Print("Daily trade limit reached (", InpMaxTradesPerDay, " trades). Stopping for the day.");
         g_limitPrinted = true;
      }
      g_dayStopped = true;
      return;
   }

   //--- v1.04 STOP-OUT PENALTY (replaces the time cooldown): after an SL,
   //    same-direction entries need a NEW channel extreme (new low for
   //    sells / new high for buys) - the market must prove the bounce
   //    failed. No time blindness: waits as long as needed, but never
   //    blocks a fresh opposite signal. After a TP there is no penalty.
   if(g_afterSL)
   {
      if(g_slDirection == -1 && sellBreak && lowMin >= g_slChannelExtreme)
         return; // SELL SL: need a new channel low
      if(g_slDirection == 1 && buyBreak && highMax <= g_slChannelExtreme)
         return; // BUY SL: need a new channel high
   }

   //--- v3.13 REOPEN GUARD: no entries during the first minutes after the
   //    daily market break (gap fakeouts - trade #1 loss on 09-10)
   if(TimeCurrent() < g_reopenUntil)
   {
      Print("Reopen guard active until ", TimeToString(g_reopenUntil), " - no entries.");
      return;
   }

if(buyBreak)
   {
      OpenBuy(tick.ask, slDistance, tpDistance, highMax, trendBuy && !channelBuy);
   }
   else if(sellBreak)
   {
      OpenSell(tick.bid, slDistance, tpDistance, lowMin, trendSell && !channelSell);
   }
}

//+------------------------------------------------------------------+
//| v1.04: detect the last SL/TP exit on our magic and set the        |
//| stop-out penalty. Runs once per minute. SL -> penalty ON with the |
//| channel extreme at detection; TP -> penalty OFF (trend confirmed).|
//+------------------------------------------------------------------+
void CheckLastExit()
{
   datetime now = TimeCurrent();
   if(now - g_lastExitCheck < 60)
      return;
   g_lastExitCheck = now;

   if(!HistorySelect(now - 7200, now))   // last 2 hours
      return;

   int total = HistoryDealsTotal();
   for(int i = total - 1; i >= 0; i--)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != InpMagicNumber) continue;

      long reason = HistoryDealGetInteger(ticket, DEAL_REASON);
      if(reason != DEAL_REASON_SL && reason != DEAL_REASON_TP) continue;

      datetime dealTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      if(dealTime <= g_lastExitTime) break;   // already seen this exit

      g_lastExitTime = dealTime;
      long type = HistoryDealGetInteger(ticket, DEAL_TYPE);

      if(reason == DEAL_REASON_SL)
      {
         // Closing deal type: BUY closes a SELL position, SELL closes a BUY
         g_afterSL = true;
         g_slDirection = (type == DEAL_TYPE_BUY) ? -1 : 1;
         // Channel extreme at detection, same window as the entry logic
         if(g_slDirection == -1)
         {
            g_slChannelExtreme = DBL_MAX;
            for(int b = 1; b <= InpChannelPeriod; b++)
            {
               double l = iLow(_Symbol, InpChannelTF, b);
               if(l < g_slChannelExtreme) g_slChannelExtreme = l;
            }
         }
         else
         {
            g_slChannelExtreme = 0.0;
            for(int b = 1; b <= InpChannelPeriod; b++)
            {
               double h = iHigh(_Symbol, InpChannelTF, b);
               if(h > g_slChannelExtreme) g_slChannelExtreme = h;
            }
         }
         Print("Stop-out detected (", (g_slDirection == -1 ? "SELL" : "BUY"),
               "). Re-entry needs a new channel extreme: ",
               DoubleToString(g_slChannelExtreme, (int)_Digits));
      }
      else // TP
      {
         g_afterSL = false;
         g_slDirection = 0;
         Print("Take-profit detected. No re-entry restriction.");
      }
      break;
   }
}

//+------------------------------------------------------------------+
//| Check if the trading day has rolled over                         |
//+------------------------------------------------------------------+
void CheckDayRollover()
{
   datetime currentDay = ServerDayStart();
   if(currentDay != g_dayStart)
   {
      g_dayStart = currentDay;
      g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      g_dayStopped = false;
      g_tradesToday = 0;
      g_limitPrinted = false;   // v1.06: fresh day = fresh message
      g_lastCountCheck = 0;     // v1.06: refresh immediately on the new day
      g_afterSL = false;      // v1.04: fresh day = fresh start
      g_slDirection = 0;
      Print("New trading day detected. Resetting day state.");
   }
}

//+------------------------------------------------------------------+
//| Server midnight (start of the trading day)                       |
//+------------------------------------------------------------------+
datetime ServerDayStart()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   dt.hour = 0;
   dt.min  = 0;
   dt.sec  = 0;
   return(StructToTime(dt));
}

//+------------------------------------------------------------------+
//| Count trades opened today (restores g_tradesToday after re-attach)|
//| v1.05 FIX: g_tradesToday was memory-only - every re-attach reset  |
//| it to 0, so the 4/day cap never held across restarts. Count       |
//| today's DEAL_ENTRY_IN deals with our magic instead.               |
//+------------------------------------------------------------------+
int CountTradesToday(bool debug = false)
{
   int count = 0;
   if(!HistorySelect(ServerDayStart(), TimeCurrent()))
      return 0;

   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != InpMagicNumber) continue;
      if(HistoryDealGetInteger(ticket, DEAL_ENTRY) != DEAL_ENTRY_IN) continue;
      count++;
      if(debug)
         Print("  counted: ticket ", ticket, " time ", TimeToString((datetime)HistoryDealGetInteger(ticket, DEAL_TIME)),
               " ", HistoryDealGetString(ticket, DEAL_COMMENT));
   }
   if(debug)
      Print("CountTradesToday() = ", count, " (server day ", TimeToString(ServerDayStart()), ")");
   return count;
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
//| Check daily cutoff - stop trading at cutoff time                 |
//+------------------------------------------------------------------+
void CheckDailyCutoff()
{
   MqlDateTime dt;
   TimeToStruct(TimeLocal(), dt);

   if(dt.hour > InpCutoffHour || (dt.hour == InpCutoffHour && dt.min >= InpCutoffMinute))
   {
      if(!g_dayStopped)
      {
         Print("DAILY CUTOFF: Reached ", InpCutoffHour, ":", InpCutoffMinute,
               " local. Closing all positions and stopping for the day.");
         CloseAllPositions();
         DeleteAllPendingOrders();
         g_dayStopped = true;
      }
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
      request.position = ticket;   // v3.11 FIX: without this, MT5 opens a
                                   // NEW position instead of closing this one
                                   // (this caused the 2 naked trades on 09-10)

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
      request.comment = "KillSwitch/Cutoff close";

      if(OrderSend(request, result))
         Print("Closed position #", ticket, " result: ", result.retcode);
      else
         Print("Failed to close position #", ticket, " error: ", result.retcode);
   }
}

//+------------------------------------------------------------------+
//| Delete all pending orders for this EA                            |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0) continue;

      if(OrderGetInteger(ORDER_MAGIC) != InpMagicNumber)
         continue;

      MqlTradeRequest request = {};
      MqlTradeResult result = {};

      request.action = TRADE_ACTION_REMOVE;
      request.order = ticket;

      if(OrderSend(request, result))
         Print("Deleted pending order #", ticket);
      else
         Print("Failed to delete order #", ticket, " error: ", result.retcode);
   }
}

//+------------------------------------------------------------------+
//| Open a BUY position                                              |
//+------------------------------------------------------------------+
void OpenBuy(double price, double slDistance, double tpDistance, double breakoutLevel, bool isTrendEntry = false)
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
   request.comment = "BBH BUY";

   if(OrderSend(request, result))
   {
      Print("BUY opened at ", DoubleToString(price, digits),
            " SL: ", DoubleToString(sl, digits),
            " TP: ", DoubleToString(tp, digits),
            " Breakout: ", DoubleToString(breakoutLevel, digits));
g_tradesToday++;
      g_lastTradeTime = TimeCurrent();
      if(isTrendEntry) g_trendEntriesToday++;
      g_afterSL = false;      // v1.04: new trade resets the penalty
      g_slDirection = 0;
   }
   else
   {
      Print("BUY failed. Error: ", result.retcode, " (", result.comment, ")");
   }
}

//+------------------------------------------------------------------+
//| Open a SELL position                                             |
//+------------------------------------------------------------------+
void OpenSell(double price, double slDistance, double tpDistance, double breakoutLevel, bool isTrendEntry = false)
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
   request.comment = "BBH SELL";

   if(OrderSend(request, result))
   {
      Print("SELL opened at ", DoubleToString(price, digits),
            " SL: ", DoubleToString(sl, digits),
            " TP: ", DoubleToString(tp, digits),
            " Breakout: ", DoubleToString(breakoutLevel, digits));
g_tradesToday++;
      g_lastTradeTime = TimeCurrent();
      if(isTrendEntry) g_trendEntriesToday++;
      g_afterSL = false;      // v1.04: new trade resets the penalty
      g_slDirection = 0;
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

