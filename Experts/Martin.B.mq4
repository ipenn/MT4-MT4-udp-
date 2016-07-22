#property copyright "WeWant"
#property link "http://www.moneywang.com"

#import "MT4ManageDll.dll"
   void KillMT4();
#import
#import "WecapitalMT4Socket.dll"
   int MT4initConnect(int port);
   int MT4Send(int socket, int port, string msg, int messagelen);
   string MT4Recv(int socket, int port);
   int Disconnect(int socket);
#import

int Socket = 0;
extern int LocalPort = 6001;
extern int DestPort = 6002;

extern string s1 ="***************************";
extern double Lot = 0.01;
extern double MinLot = 0.01;
extern double MaxLot = 20;
extern double K_Lot = 1.5;
extern double MaxProfit = 7;
extern int MaxOrders = 20;
extern int LimitMaxStep = 50;
extern int LimitStep = 20;
extern int StartOrder = 10;

extern int Magic = 201610;
extern int Slippage = 10;
extern int Tp = 35;
extern bool onTrade = true;

int   font_size = 10 , openTime = 0;
color text_color = Orange;
double MinProfit = 0;


int OnInit()
{  
   Socket = MT4initConnect(LocalPort);
   
   if( Socket < 0)
   {
      Print("Init connection error");
   }else
   {
      Print("Init connection Succeed!");
   }
      
   int li_0 = font_size + font_size / 2;
   ObjectCreate("PROFIT", OBJ_LABEL, 0, 0, 0);
   ObjectSet("PROFIT", OBJPROP_CORNER, 1);
   ObjectSet("PROFIT", OBJPROP_XDISTANCE, 5);
   ObjectSet("PROFIT", OBJPROP_YDISTANCE, li_0);
   li_0 += font_size * 2;
   ObjectCreate("Equity", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Equity", OBJPROP_CORNER, 1);
   ObjectSet("Equity", OBJPROP_XDISTANCE, 5);
   ObjectSet("Equity", OBJPROP_YDISTANCE, li_0);
   li_0 += font_size * 2;
   ObjectCreate("BuyOrder", OBJ_LABEL, 0, 0, 0);
   ObjectSet("BuyOrder", OBJPROP_CORNER, 1);
   ObjectSet("BuyOrder", OBJPROP_XDISTANCE, 5);
   ObjectSet("BuyOrder", OBJPROP_YDISTANCE, li_0);
   li_0 += font_size * 2;
   ObjectCreate("BuyLots", OBJ_LABEL, 0, 0, 0);
   ObjectSet("BuyLots", OBJPROP_CORNER, 1);
   ObjectSet("BuyLots", OBJPROP_XDISTANCE, 5);
   ObjectSet("BuyLots", OBJPROP_YDISTANCE, li_0);
   li_0 += font_size * 2;
   ObjectCreate("BuyProfit", OBJ_LABEL, 0, 0, 0);
   ObjectSet("BuyProfit", OBJPROP_CORNER, 1);
   ObjectSet("BuyProfit", OBJPROP_XDISTANCE, 5);
   ObjectSet("BuyProfit", OBJPROP_YDISTANCE, li_0);
   li_0 += font_size * 2;
   ObjectCreate("SellOrder", OBJ_LABEL, 0, 0, 0);
   ObjectSet("SellOrder", OBJPROP_CORNER, 1);
   ObjectSet("SellOrder", OBJPROP_XDISTANCE, 5);
   ObjectSet("SellOrder", OBJPROP_YDISTANCE, li_0);
   li_0 += font_size * 2;
   ObjectCreate("SellLots", OBJ_LABEL, 0, 0, 0);
   ObjectSet("SellLots", OBJPROP_CORNER, 1);
   ObjectSet("SellLots", OBJPROP_XDISTANCE, 5);
   ObjectSet("SellLots", OBJPROP_YDISTANCE, li_0);
   li_0 += font_size * 2;
   ObjectCreate("SellProfit", OBJ_LABEL, 0, 0, 0);
   ObjectSet("SellProfit", OBJPROP_CORNER, 1);
   ObjectSet("SellProfit", OBJPROP_XDISTANCE, 5);
   ObjectSet("SellProfit", OBJPROP_YDISTANCE, li_0);
   li_0 += font_size * 2;
   ObjectCreate("MinProfit", OBJ_LABEL, 0, 0, 0);
   ObjectSet("MinProfit", OBJPROP_CORNER, 1);
   ObjectSet("MinProfit", OBJPROP_XDISTANCE, 5);
   ObjectSet("MinProfit", OBJPROP_YDISTANCE, li_0);
   li_0 += font_size * 2;
        
   EventSetMillisecondTimer(20);
}

int SocketSend(string msg)
{
   if (Socket <= 0)
   {
      Print("Socket error!");
      return -1;
   }
   if (MT4Send(Socket, DestPort, msg, 100) <= 0)
   {
      return -1;
   }
   else
   {
      return 1;
   }
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   int err = Disconnect(Socket);
   if(err != 0)printf("Disconnect error: %d", err);
}

void OnTimer()
{
   string msg = MT4Recv(Socket , DestPort);
   string result[];
   if(msg)
   {
      string delimeter=",";
      ushort u_delimeter=StringGetCharacter(delimeter,0); 
      int k = StringSplit(msg,u_delimeter,result);
      int resOrder = StringToInteger(result[2]);
      //Print(msg);
   }else
   {
      return ;
   }
   
   int buyStep,sellStep,limitBuyStep,limitSellStep;
   
   int cpt,ordersBuyStop,orderSellStop,ordersBuy,ordersSell,optype;
   double lastLot,orderPrice,orderBuystopPrice,orderSellstopPrice,orderBuyPrice,orderSellPrice,buyProfit,sellProfit,BuyLots,SellLots,maxBuyPrice,maxSellPrice,minBuyPrice,minSellPrice;
   double buyTotalAmount,sellTotalAmount,buyTotalLot,sellTotalLot;
   for(cpt=0;cpt<OrdersTotal();cpt++)
   {
      OrderSelect(cpt,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()==Magic  && OrderSymbol()==Symbol())
      {
         optype = OrderType();
         lastLot = OrderLots();
         orderPrice = NormalizeDouble(OrderOpenPrice(), Digits);
            
         if (optype == OP_BUYSTOP) 
         {
            if(OrderOpenPrice() < Ask )
            {
               //KillMT4();
            }
            ordersBuyStop++;
            orderBuystopPrice = orderPrice;
         }
         
         if (optype == OP_SELLSTOP) 
         {
            if(OrderOpenPrice() > Bid )
            {
               //KillMT4();
            }
            orderSellStop++;
            orderSellstopPrice = orderPrice;
         }
         
         if(optype == OP_BUY)
         {
            ordersBuy++;
            
            buyProfit += OrderProfit() + OrderSwap() + OrderCommission();
            orderBuyPrice = orderPrice;
            if(maxBuyPrice < orderPrice || maxBuyPrice == 0.0)
            {
               maxBuyPrice = orderPrice;
            }
            if(minBuyPrice > orderPrice || minBuyPrice == 0.0)
            {
               minBuyPrice = orderPrice;
            }
            if(BuyLots < lastLot)
            {
               BuyLots = lastLot;
            }
            
            buyTotalAmount += OrderOpenPrice() * OrderLots();
            buyTotalLot += OrderLots(); 
            
         }
         
         if(optype == OP_SELL)
         {  
            ordersSell++;
            
            sellProfit += OrderProfit() + OrderSwap() + OrderCommission();
            orderSellPrice = orderPrice;
            if(maxSellPrice < orderPrice || maxSellPrice == 0.0)
            {
               maxSellPrice = orderPrice;
            }
            if(minSellPrice > orderPrice || minSellPrice == 0.0)
            {
               minSellPrice = orderPrice;
            }
            if(SellLots < lastLot)
            {
               SellLots = lastLot;
            }
            
            sellTotalAmount += OrderOpenPrice() * OrderLots();
            sellTotalLot += OrderLots(); 
            
         }
      }
   }
   
   
   
   buyStep =  int(0.5 * LimitMaxStep);
   limitBuyStep = LimitStep;
   
   sellStep =  int(0.5 * LimitMaxStep);
   limitSellStep = LimitStep;
   
   
   if(MinProfit > buyProfit + sellProfit)
   {
      MinProfit = buyProfit + sellProfit;
   }
   
   double argBuyPrice,argSellPrice;
   
   
   //Draw Line
   if(ordersBuy > 0)
   {
      argBuyPrice = buyTotalAmount/buyTotalLot;
      HorizontalLine(argBuyPrice,"line_buy",DodgerBlue,STYLE_DASH,1);
      ModifyTakeProfit(OP_BUY,NormalizeDouble(argBuyPrice + Tp*Point,Digits));
   }
   
   if(ordersSell > 0)
   {  
      argSellPrice = sellTotalAmount/sellTotalLot;
      HorizontalLine(argSellPrice,"line_sell",HotPink,STYLE_DASH,1);
      ModifyTakeProfit(OP_SELL,NormalizeDouble(argSellPrice - Tp*Point,Digits));
   }
   
   
   double upperPrice,lowerPrice,lots;
   upperPrice = NormalizeDouble(Ask + buyStep * Point, Digits);
   lowerPrice = NormalizeDouble(Bid - sellStep * Point, Digits);
   lots = Lot;
   
   if(ordersBuy + ordersBuyStop == 0 && onTrade && result[1] == "B" && resOrder == StartOrder && TimeCurrent() <  result[2]+8)
   {  
      for(cpt = 0;cpt < StartOrder;cpt++)
      {
         lots += MathRound(Lot*MathPow(K_Lot,cpt)*100)/100;
      }
      OrderO("Buy",lots,Ask );
      return 0;
   }
   
   if(ordersSell + orderSellStop == 0 && onTrade && result[1] == "S" && resOrder == StartOrder && TimeCurrent() <  result[2]+8)
   {  
      
      for(cpt = 0;cpt < StartOrder;cpt++)
      {
         lots += MathRound(Lot*MathPow(K_Lot,cpt)*100)/100;
      }
      OrderO("Sell",lots,Bid );
      return 0;
   }
   
   if ((Bid - argBuyPrice >= Tp * Point && argBuyPrice > 0 && ordersBuy >= 4) || (buyProfit > MaxProfit && ordersBuy < 4) ) {
      Print("BuyProfit ", buyProfit);
      DeleteStop(OP_BUYSTOP);
      OrderC(1);
      ObjectDelete("line_buy");
      return;
   }
   
   if ((argSellPrice - Ask >= Tp * Point  && argSellPrice > 0  && ordersSell >= 4) || (sellProfit > MaxProfit && ordersSell < 4)) {
      Print("SellProfit ", sellProfit);
      DeleteStop(OP_SELLSTOP);
      OrderC(-1);
      ObjectDelete("line_sell");
      return;
   }
   

   if(minBuyPrice - Ask >= 2* buyStep * Point && ordersBuyStop == 0  && ordersBuy > 0 && ordersBuy < MaxOrders)
   {
      lots = MathRound(Lot*MathPow(K_Lot,ordersBuy+StartOrder-1)*100)/100;
      upperPrice = NormalizeDouble(Ask + limitBuyStep * Point, Digits);
      OrderO("BuyStop",lots,upperPrice );
      return;
   }
   
   
   if(Bid - maxSellPrice >= 2 * sellStep * Point && orderSellStop == 0  && ordersSell > 0 && ordersSell < MaxOrders)
   {
      lots = MathRound(Lot*MathPow(K_Lot,ordersSell+StartOrder-1)*100)/100;
      lowerPrice = NormalizeDouble(Bid - limitSellStep * Point, Digits);
      OrderO("SellStop",lots,lowerPrice);
      return;
   }
   
   //ModifyStop
   if(ordersBuyStop > 0 && Ask + limitBuyStep*Point < orderBuystopPrice )
   {
      ModifyStop(OP_BUYSTOP, Ask + limitBuyStep * Point);
   }
   
   if(orderSellStop > 0 && Bid - limitSellStep*Point > orderSellstopPrice )
   {
      ModifyStop(OP_SELLSTOP, Bid - limitSellStep * Point);
   }
   
   
 
   ObjectSetText("PROFIT", StringConcatenate("PROFIT ", DoubleToStr(AccountProfit(), 2)), font_size, "Arial", text_color);
   ObjectSetText("Equity", StringConcatenate("Equity ", DoubleToStr(AccountEquity(), 2)), font_size, "Arial", text_color);
   
   ObjectSetText("BuyOrder", StringConcatenate("BuyOrder ", DoubleToStr(ordersBuy , 2)), font_size, "Arial", text_color);
   ObjectSetText("BuyLots", StringConcatenate("BuyLots ", DoubleToStr(buyTotalLot, 2)), font_size, "Arial", text_color);
   ObjectSetText("BuyProfit", StringConcatenate("BuyProfit ", DoubleToStr(buyProfit, 2)), font_size, "Arial", text_color);
   
   ObjectSetText("SellOrder", StringConcatenate("SellOrder ", DoubleToStr(ordersSell , 2)), font_size, "Arial", text_color);
   ObjectSetText("SellLots", StringConcatenate("SellLots ", DoubleToStr(sellTotalLot, 2)), font_size, "Arial", text_color);
   ObjectSetText("SellProfit", StringConcatenate("SellProfit ", DoubleToStr(sellProfit, 2)), font_size, "Arial", text_color);
   ObjectSetText("MinProfit", StringConcatenate("MinProfit ", DoubleToStr(MinProfit, 2)), font_size, "Arial", text_color);
}

void HorizontalLine(double value, string name, color c, int style, int thickness) 
{
  if(ObjectFind(name) == -1)
  {
    ObjectCreate(name, OBJ_HLINE, 0, Time[0], value);
    
    ObjectSet(name, OBJPROP_STYLE, style);             
    ObjectSet(name, OBJPROP_COLOR, c);
    ObjectSet(name,OBJPROP_WIDTH,thickness);
  }
  else
  {
    ObjectSet(name,OBJPROP_PRICE1,value);
    ObjectSet(name, OBJPROP_STYLE, style);             
    ObjectSet(name, OBJPROP_COLOR, c);
    ObjectSet(name,OBJPROP_WIDTH,thickness);
  }  
}

void ModifyTakeProfit(int optype,double price)
{
   for(int cpt=0;cpt<OrdersTotal();cpt++)
   {
      OrderSelect(cpt,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()==Magic  && OrderSymbol()==Symbol())
      {
         if(OrderType() == optype && OrderTakeProfit() != price )
         {
            OrderModify(OrderTicket(), OrderOpenPrice(), 0, price , 0, White);
         }
      }
   }
}

void ModifyStop(int optype,double price)
{
   int error;
   for(int cpt=0;cpt<OrdersTotal();cpt++)
   {
      OrderSelect(cpt,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()==Magic  && OrderSymbol()==Symbol())
      {
         if(OrderType() == optype && OrderOpenPrice() != price )
         {
            error = OrderModify(OrderTicket(), price, 0, 0, 0, White);
         }
         if (error==-1) 
         {  
           int err=GetLastError();
           Print("Error ModifyStop ",err);
         }
      }
  }
}

void DeleteStop(int optype)
{
   int error;
   for(int cpt=0;cpt<OrdersTotal();cpt++)
   {
      OrderSelect(cpt,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()==Magic  && OrderSymbol()==Symbol())
      {
         if(OrderType() == optype )
         {
            error = OrderDelete(OrderTicket());
         }
         if (error==-1) 
         {  
           int err=GetLastError();
           Print("Error DeleteStop ",err);
         }
      }
  }
}

void OrderO(string ord,double LOT,double openPrice)
{
   double SL,TP;
   int error;
   if(MinLot > LOT)
   {
      LOT = MinLot;
   }
   if(MaxLot < LOT)
   {
      LOT = MaxLot;
   }
   if (ord=="BuyStop"){
      error=OrderSend(Symbol(),OP_BUYSTOP,LOT,openPrice,Slippage,SL,TP,"",Magic,0,Blue);
   }
   
   if (ord=="SellStop")
   {
      error=OrderSend(Symbol(),OP_SELLSTOP,LOT,openPrice,Slippage,SL,TP,"",Magic,0,Red);
   }
   
   if (ord=="Buy"){
      error=OrderSend(Symbol(),OP_BUY,LOT,openPrice,Slippage,SL,TP,"",Magic,0,Blue);
   }
   
   if (ord=="Sell")
   {
      error=OrderSend(Symbol(),OP_SELL,LOT,openPrice,Slippage,SL,TP,"",Magic,0,Red);
   }
   
   if (error==-1) 
   {  
     int err=GetLastError();
     Print("Error OPENORDER ",err);
   }
   return;
}




double OrderC(int ord){
   int cpt , orders = OrdersTotal();
   for(cpt = orders - 1;cpt >= 0;cpt--)
   {
      OrderSelect(cpt,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()==Magic && OrderSymbol()==Symbol())
      {
         if(OrderType()==OP_BUY && (ord == 1 || ord == 0))
         {
            OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue);
         }
         if(OrderType()==OP_SELL&& (ord == -1 || ord == 0))
         {
            OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
         }
      }
   }
}


