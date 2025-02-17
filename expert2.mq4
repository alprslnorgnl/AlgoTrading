//BU ROBOT BİR HER GÜN SAAT 15.25 DE BİR BUY İŞLEMİ VE SELLSTOP EMRİ AÇAR (PAZARTESİ AÇILAN İŞLEMLER DİĞER GÜNLERDEN BAĞIMSIZDIR AYNI ŞEY DİĞER GÜNLER İÇİNDE GEÇERLİ)
//ROBOTUN ÇALIŞMA MANTIĞI FİYATIN GİTTİĞİ YÖNDE 100 PİP ARALIKLAR İLE O YÖNDE İŞLEMLER AÇAR VE BU İŞLEMLER 100 PİP SL KONULUR

#property copyright "Alparslan"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//EXTERN VARIABLES
extern double lot = 0.01;

//GLOBAL VARIABLES
int currentHour,currentMinute,currentDay,mevcutDay; //Her gün saat 15.25 de işlem açılması için gerekli değişkenler
bool pass = 1;
int i = 1; //Magic Number
int magic; //Magic Number
int j,x,y,z; //Döngü değişkenleri
int total; //Mevcut işlem sayısı
int type; //Seçilmiş işlemin türü
int buyCount = 0; //Buy işlemlerinin sayısı
int sellCount = 0; //Sell işlemlerinin sayısı
int bsCount = 0; //buystop işlemlerinin sayısı
int ssCount = 0; //sellstop işlemlerinin sayısı
int buyTicket,sellTicket,bsTicket,ssTicket; //İşlemlerin ticket numaraları
double buyOP,sellOP;
double ek = 99999.99;
double eb = 00000.00;
int ekTicket,ebTicket;

double kar_zarar = 0.0;

int htotal;


int OnInit()
  {
      currentDay = currentDay = TimeDay(TimeCurrent());
      mevcutDay = currentDay;
      
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
      currentHour = TimeHour(TimeCurrent());
      currentMinute = TimeMinute(TimeCurrent());
      currentDay = TimeDay(TimeCurrent());
     
      
      if(currentHour == 15 && currentMinute == 25 && currentDay == mevcutDay){
         OrderSend(NULL,OP_BUY,lot,Ask,0,0,Ask+0.002,NULL,i,0,clrNONE);
         OrderSend(NULL,OP_SELLSTOP,lot,Ask-0.002,0,0,0,NULL,i,0,clrNONE);
         i++;
         
         mevcutDay++;
      }
      
      /*if(currentHour == 15 && currentMinute == 40 && pass == 0){
         pass = 1;
      }*/
      
      for(x=0; x<OrdersTotal(); x++){
         
         OrderSelect(x,SELECT_BY_POS,MODE_TRADES);
         magic = OrderMagicNumber();
         
         buyCount = 0;
         sellCount = 0;
         bsCount = 0;
         ssCount = 0;
         
         for(j=0; j<OrdersTotal(); j++){
            OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
            type = OrderType();
            
            if(type == 0 && magic == OrderMagicNumber()){
               buyCount++;
               buyTicket = OrderTicket();
               buyOP = OrderOpenPrice();
               kar_zarar += OrderProfit();
            }
            else if(type == 1 && magic == OrderMagicNumber()){
               sellCount++;
               sellTicket = OrderTicket();
               sellOP = OrderOpenPrice();
               kar_zarar += OrderProfit();
            }
            else if(type == 4 && magic == OrderMagicNumber()){
               bsCount++;
               bsTicket = OrderTicket();
            }
            else if(type == 5 && magic == OrderMagicNumber()){
               ssCount++;
               ssTicket = OrderTicket();
            }
         }//For
         
         //KOŞULLAR
         if(buyCount == 0 && sellCount == 0 && bsCount == 0 && ssCount == 1){
            
            //sellstop emri silinir
            OrderDelete(ssTicket,clrNONE);
         }
         else if(buyCount == 1 && sellCount == 1 && bsCount == 0 && ssCount == 0){
            
            //Mevcut Buy işleminin tp ve sl si 0 yapılır
            OrderSelect(buyTicket,SELECT_BY_TICKET,MODE_TRADES);
            OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0,clrNONE);
            
            //Buy işleminin 100 pip üstüne buystop emri konulur
            OrderSend(NULL,OP_BUYSTOP,lot,buyOP+0.002,0,0,0,NULL,magic,0,clrNONE);
            
            //Sell işleminin 100 pip altına sellstop emri konulur
            OrderSend(NULL,OP_SELLSTOP,lot,sellOP-0.002,0,0,0,NULL,magic,0,clrNONE);
         }
         else if(buyCount == 2 && sellCount == 1 && bsCount == 0 && ssCount == 1){
            
            //sellstop emri silinir
            OrderDelete(ssTicket,clrNONE);
            
            //En büyük buy işlemi belirlenir ve ticket ı alınır
            for(y=0; y<OrdersTotal(); y++){
               OrderSelect(y,SELECT_BY_POS,MODE_TRADES);
   
               if(OrderType() == 0 && OrderOpenPrice() > eb){
                  eb = OrderOpenPrice();
                  ebTicket = OrderTicket();
               }
               
            }
            
            //En büyük buy işleminin sl si 100 pip yapılır
            OrderSelect(ebTicket,SELECT_BY_TICKET,MODE_TRADES);
            OrderModify(ebTicket,OrderOpenPrice(),eb-0.002,0,0,clrNONE);
            
            //En büyük buy işleminin 100 pip üstüne buystop emri konulur
            OrderSend(NULL,OP_BUYSTOP,lot,eb+0.002,0,eb,0,NULL,magic,0,clrNONE);
            
         }
         else if(buyCount == 1 && sellCount == 2 && bsCount == 1 && ssCount == 0){
            
            //buystop emri silinir
            OrderDelete(bsTicket,clrNONE);
            
            //En küçük sell işlemi belirlenir ve ticket ı alınır
            for(z=0; z<OrdersTotal(); z++){
               OrderSelect(z,SELECT_BY_POS,MODE_TRADES);
   
               if(OrderType() == 1 && OrderOpenPrice() < ek){
                  ek = OrderOpenPrice();
                  ekTicket = OrderTicket();
               }
               
            }
            
            //En küçük sell işleminin sl si 100 pip yapılır
            OrderSelect(ekTicket,SELECT_BY_TICKET,MODE_TRADES);
            OrderModify(ekTicket,OrderOpenPrice(),ek+0.002,0,0,clrNONE);
            
            //En küçük sell işleminin 100 pip altına sellstop emri konulur
            OrderSend(NULL,OP_SELLSTOP,lot,ek-0.002,0,ek,0,NULL,magic,0,clrNONE);
         }
         else if(buyCount >= 2 && bsCount == 0){
            
            //En büyük buy işlemi belirlenir ve ticket ı alınır
            for(y=0; y<OrdersTotal(); y++){
               OrderSelect(y,SELECT_BY_POS,MODE_TRADES);
   
               if(OrderType() == 0 && OrderOpenPrice() > eb){
                  eb = OrderOpenPrice();
                  ebTicket = OrderTicket();
               }
               
            }
            
            //En büyük buy işleminin 100 pip üstüne buystop emri konulur
            OrderSend(NULL,OP_BUYSTOP,lot,eb+0.002,0,eb,0,NULL,magic,0,clrNONE);
            
         }
         else if(sellCount >= 2 && ssCount == 0){
         
            //En küçük sell işlemi belirlenir ve ticket ı alınır
            for(z=0; z<OrdersTotal(); z++){
               OrderSelect(z,SELECT_BY_POS,MODE_TRADES);
   
               if(OrderType() == 1 && OrderOpenPrice() < ek){
                  ek = OrderOpenPrice();
                  ekTicket = OrderTicket();
               }
               
            }
            
            //En küçük sell işleminin 100 pip altına sellstop emri konulur
            OrderSend(NULL,OP_SELLSTOP,lot,ek-0.002,0,ek,0,NULL,magic,0,clrNONE);
         }
         
         
         //AYNI MAGIC NUMARASINA SAHİP İŞLEMLER TOPLAM 4$ KAR YAPTI İSE AÇIK OLAN İŞLEMLER KAPATILIR
         for(int k=0; k<OrdersHistoryTotal(); k++){
            OrderSelect(k,SELECT_BY_POS,MODE_HISTORY);
            
            if(OrderMagicNumber() == magic){
               kar_zarar +=  OrderProfit();
            }
            
         }
         
         if(kar_zarar >= 5.0){
            
            total = OrdersTotal();
            int l = 0;
            while(l<total){
               
               OrderSelect(l,SELECT_BY_POS,MODE_TRADES);
               
               if(OrderType() == 0 && OrderMagicNumber() == magic){
                  OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  total--;
                  l=0;
               }
               else if(OrderType() == 1 && OrderMagicNumber() == magic){
                  OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                  total--;
                  l=0;
               }
               else if((OrderType() == 4 || OrderType() == 5) && OrderMagicNumber() == magic){
                  OrderDelete(OrderTicket(),clrNONE);
                  total--;
                  l=0;
               }
               
            }
            
            kar_zarar = 0.0;
         }
         
         //SON KAPANAN İŞLEMİN MAGIC NUMARASI KONTROL EDİLİR
         htotal = OrdersHistoryTotal();
         OrderSelect(htotal-1,SELECT_BY_POS,MODE_HISTORY);
         
         if(OrderMagicNumber() == magic && OrderType() == 0){
            OrderDelete(bsTicket,clrNONE);
         }
         else if(OrderMagicNumber() == magic && OrderType() == 1){
            OrderDelete(ssTicket,clrNONE);
         }
         
         
         buyCount = 0;
         sellCount = 0;
         bsCount = 0;
         ssCount = 0;
         
         ek = 99999.99;
         eb = 00000.00;
         kar_zarar = 0.0;
      }//For
          
  }//OnTick