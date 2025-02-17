#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double LOT = 0.01;

int ticket;
int TP=0;
int SL=0;

int OnInit()
  {
      ticket = OrderSend(NULL,OP_BUY,LOT,Ask,0,Ask-0.01,Ask+0.001,NULL,0,0,clrNONE);
      
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
  
      if(OrdersTotal()==0){
         
         OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY);
         int type = OrderType();
         
         if(OrderProfit()>=0){
            
            if(type == 0)
            ticket = OrderSend(NULL,OP_BUY,LOT,Ask,0,Ask-0.01,Ask+0.001,NULL,0,0,clrNONE);
            
            if(type == 1)
            ticket = OrderSend(NULL,OP_SELL,LOT,Bid,0,Bid+0.01,Bid-0.001,NULL,0,0,clrNONE);
            
            TP++;
            printf("TP COUNT %d",TP);
         }
         else if(OrderProfit()<0){
            
            if(type==0)
            ticket = OrderSend(NULL,OP_SELL,LOT,Bid,0,Bid+0.01,Bid-0.001,NULL,0,0,clrNONE);
            
            if(type == 1)
            ticket = OrderSend(NULL,OP_BUY,LOT,Ask,0,Ask-0.01,Ask+0.001,NULL,0,0,clrNONE);
            
            SL++;
            printf("SL COUNT %d",SL);
         }
      }
      
  }