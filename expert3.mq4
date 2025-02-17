#property copyright "Alparslan"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//EXTERN VARIABLES
extern double lot = 0.03;

//GLOBAL VARIABLES
int currentHour,currentMinute,currentDay,mevcutDay;
int buyCount = 0;
int sellCount = 0;
int bsCount = 0;
int ssCount = 0;
int blCount = 0;
int slCount = 0;
int buyTicket,sellTicket,bsTicket,ssTicket,blTicket,slTicket;
int type;

double mevcutbakiye,istenendeger,kar_zarar;
int total;


int OnInit()
  {
      currentDay = TimeDay(TimeCurrent());
      mevcutDay = currentDay;
      
      mevcutbakiye = AccountInfoDouble(ACCOUNT_BALANCE);
      istenendeger = mevcutbakiye + 3.0;
      
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
      currentHour = TimeHour(TimeCurrent());
      currentMinute = TimeMinute(TimeCurrent());
      currentDay = TimeDay(TimeCurrent());
     
      
      if(currentHour == 15 && currentMinute == 25 && currentDay == mevcutDay){
         
         OrderSend(NULL,OP_BUY,lot,Ask,0,0,Ask+0.001,NULL,0,0,clrNONE);
         OrderSend(NULL,OP_SELLSTOP,lot,Ask-0.001,0,0,Ask-0.002,NULL,0,0,clrNONE);
         mevcutDay = -5;
      }
      
      for(int i=0; i<OrdersTotal(); i++){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         type = OrderType();
         
         if(type == 0){
            buyCount++;
            buyTicket = OrderTicket();
         }
         else if(type == 1){
            sellCount++;
            sellTicket = OrderTicket();
         }
         else if(type == 2){
            blCount++;
            blTicket = OrderTicket();
         }
         else if(type == 3){
            slCount++;
            slTicket = OrderTicket();
         }
         else if(type == 4){
            bsCount++;
            bsTicket = OrderTicket();
         }
         else if(type == 5){
            ssCount++;
            ssTicket = OrderTicket();
         }
      }
      
      if(buyCount == 0 && sellCount == 0 && bsCount == 0 && ssCount == 1 && blCount == 0 && slCount == 0){
         
         //sellstop emri silinir
         OrderDelete(ssTicket,clrNONE);
         
         //mevcut fiyattan buy ve sellstop işlemleri açılır
         OrderSend(NULL,OP_BUY,lot,Ask,0,0,Ask+0.001,NULL,0,0,clrNONE);
         OrderSend(NULL,OP_SELLSTOP,lot,Ask-0.001,0,0,Ask-0.002,NULL,0,0,clrNONE);
      }
      else if(buyCount == 1 && sellCount == 0 && bsCount == 0 && ssCount == 0 && blCount == 0 && slCount == 0){
         
         //Mevcut fiyatın 100 pip üstüne sell limit emri gönderilir
         OrderSend(NULL,OP_SELLLIMIT,lot,Bid+0.001,0,0,Bid,NULL,0,0,clrNONE);
         //Mevcut fiyatın 100 pip altına sell stop emri gönderilir
         OrderSend(NULL,OP_SELLSTOP,lot,Bid-0.001,0,0,Bid-0.002,NULL,0,0,clrNONE);
      }
      else if(buyCount == 1 && sellCount == 1 && bsCount == 0 && ssCount == 0 && blCount == 0 && slCount == 1){
         
         //Sellimit emri silinir
         OrderDelete(slTicket,clrNONE);
      }
      else if(buyCount == 1 && sellCount == 1 && bsCount == 0 && ssCount == 1 && blCount == 0 && slCount == 0){
         
         //Sellstop emri silinir
         OrderDelete(ssTicket,clrNONE);
      }
      else if(buyCount == 0 && sellCount == 1 && bsCount == 0 && ssCount == 0 && blCount == 0 && slCount == 0){
         
         //Mevcut fiyatın 100 pip altına buy limit emri gönderilir
         OrderSend(NULL,OP_BUYLIMIT,lot,Ask-0.001,0,0,Ask,NULL,0,0,clrNONE);
         //Mevcut fiyatın 100 pip üstüne buy stop emri gönderilir
         OrderSend(NULL,OP_BUYSTOP,lot,Ask+0.001,0,0,Ask+0.002,NULL,0,0,clrNONE);
      }
      else if(buyCount == 1 && sellCount == 1 && bsCount == 0 && ssCount == 0 && blCount == 1 && slCount == 0){
         
         //Buylimit emri silinir
         OrderDelete(blTicket,clrNONE);
      }
      else if(buyCount == 1 && sellCount == 1 && bsCount == 1 && ssCount == 0 && blCount == 0 && slCount == 0){
         
         //Buystop emri silinir
         OrderDelete(bsTicket,clrNONE);
      }
      
      //KAR-ZARAR KONTROLÜ
      
      kar_zarar = AccountEquity();
      
      if(kar_zarar >= istenendeger){
         
         total = OrdersTotal();
         int i=0;
         
         while(i<total){
         
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            
            if(OrderType() == 0){
               OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
               total--;
               i=0;
            }else if(OrderType() == 1){
               OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
               total--;
               i=0;
            }
            else{
               OrderDelete(OrderTicket(),clrNONE);
               total--;
               i=0;
            }
            
         }
         
         mevcutbakiye = AccountInfoDouble(ACCOUNT_BALANCE);
         istenendeger = mevcutbakiye + 3.0;
         
         OrderSend(NULL,OP_BUY,lot,Ask,0,0,Ask+0.001,NULL,0,0,clrNONE);
         OrderSend(NULL,OP_SELLSTOP,lot,Ask-0.001,0,0,Ask-0.002,NULL,0,0,clrNONE);
      }
      
      buyCount = 0;
      sellCount = 0;
      bsCount = 0;
      ssCount = 0;
      blCount = 0;
      slCount = 0;
  }