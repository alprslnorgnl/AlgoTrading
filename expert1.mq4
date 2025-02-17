#property copyright "Alparslan"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//Extern variables
extern double lot = 0.02;

   //Global variables
   int i = 1;  //sıfırlamaya gerek yok yeni bir buy işlemi açıldıktan sonra arttırılır
   int magic;  //sıfırlamaya gerek yok
   int type;   //sıfırlamaya gerek yok
   int buyCount = 0; //Her bir buy işlemi için kontrol edildikten sonra sıfırlanır
   int sellCount = 0;   //Her bir buy işlemi için kontrol edildikten sonra sıfırlanır
   int buystopCount = 0;   //Her bir buy işlemi için kontrol edildikten sonra sıfırlanır
   int sellstopCount = 0;  //Her bir buy işlemi için kontrol edildikten sonra sıfırlanır
   int buyTicket,sellTicket,buystopTicket,sellstopTicket;   //sıfırlamaya gerek yok
   double buyOP,sellOP; //sıfırlamaya gerek yok
   int hmagic = 0;   //hmagic != 0 olduğu vakit sıfırlanır
   double kar_zarar = 0.0; //kar_zarar hedefine ulaşıldığında sıfırlanır
   int total;  //sıfırlamaya gerek yok
   
   double ek = 99999.99;
   double eb = 00000.00;
   int ekTicket,ebTicket;
   
   double currentPrice;
   double buyFark;
   double sellFark;
   double yakinlik;
   
   int currentHour,currentMinute,currentDay,mevcutDay;

int OnInit()
  {
      currentDay = TimeDay(TimeCurrent());
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
         OrderSend(NULL,OP_SELLSTOP,lot,Ask-0.001,0,0,0,NULL,i,0,clrNONE);
         i++;
         mevcutDay = -5;
      }
      
  
      for(int x=0; x<OrdersTotal(); x++){
         
         OrderSelect(x,SELECT_BY_POS,MODE_TRADES);
         
         buyCount = 0;
         sellCount = 0;
         buystopCount = 0;
         sellstopCount = 0;
         
            magic = OrderMagicNumber();
            
            for(int y=0; y<OrdersTotal(); y++){
            
               OrderSelect(y,SELECT_BY_POS,MODE_TRADES);
               type = OrderType();
               
               if(OrderMagicNumber() == magic){
                  
                  if(type == 0){
                     buyCount++;
                     buyTicket = OrderTicket();
                     buyOP = OrderOpenPrice();
                     kar_zarar += OrderProfit();
                  }
                  else if(type == 1){
                     sellCount++;
                     sellTicket = OrderTicket();
                     sellOP = OrderOpenPrice();
                     kar_zarar += OrderProfit();
                  }
                  else if(type == 4){
                     buystopCount++;
                     buystopTicket = OrderTicket();
                  }
                  else if(type == 5){
                     sellstopCount++;
                     sellstopTicket = OrderTicket();
                  }
               }
            
            }//2.for sonu
            
            //KOŞULLAR
            if(buyCount == 0 && sellCount == 0 && buystopCount == 0 && sellstopCount == 1){
               
               //Sellstop emri silinir
               OrderDelete(sellstopTicket,clrNONE);
               
               //Buy işlemi açılır ve sellstop emri konur
               OrderSend(NULL,OP_BUY,lot,Ask,0,0,Ask+0.002,NULL,i,0,clrNONE);
               OrderSend(NULL,OP_SELLSTOP,lot,Ask-0.001,0,0,0,NULL,i,0,clrNONE);
               i++;
            }
            else if(buyCount == 1 && sellCount == 1 && buystopCount == 0 && sellstopCount == 0){
               
               for(int z=0; z<OrdersHistoryTotal(); z++){
                  OrderSelect(z,SELECT_BY_POS,MODE_HISTORY);
                  
                  if(OrderMagicNumber() == magic)
                  hmagic++;
               }
               
               if(hmagic == 0){
                  
                  //Var olan işlemlerin tp ve sl leri 0 yapılır ayrıca buystop ve sellstop emirleri konulur
                  OrderSelect(buyTicket,SELECT_BY_TICKET,MODE_TRADES);
                  OrderModify(buyTicket,OrderOpenPrice(),0,0,0,clrNONE);
                  OrderSend(NULL,OP_BUYSTOP,lot,buyOP+0.001,0,0,0,NULL,magic,0,clrNONE);
                  OrderSend(NULL,OP_SELLSTOP,lot,sellOP-0.001,0,0,0,NULL,magic,0,clrNONE);
                  
                  //Aktif olan sell işleminin mevcut sell işlemleri arasında en küçük olup olmadığı kontrol edilir
                  for(int m=0; m<OrdersTotal() ; m++){
                     OrderSelect(m,SELECT_BY_POS,MODE_TRADES);
                     
                     if(OrderType() == 1 && OrderOpenPrice() < ek){
                        ek = OrderOpenPrice();
                        ekTicket = OrderTicket();
                     }
                     if(OrderType() == 1 && OrderOpenPrice() > eb){
                        eb = OrderOpenPrice();
                        ebTicket = OrderTicket();
                     }
                     
                  }
                  
                  if(ek == sellOP){
                     OrderSend(NULL,OP_BUY,lot,Ask,0,0,Ask+0.002,NULL,i,0,clrNONE);
                     OrderSend(NULL,OP_SELLSTOP,lot,Ask-0.001,0,0,0,NULL,i,0,clrNONE);
                     i++;
                  }
                  
               }
               else if(hmagic != 0){
                  
                  //Mevcut işlemlerini tp ve sl leri 0 yapılır
                  OrderSelect(buyTicket,SELECT_BY_TICKET,MODE_TRADES);
                  OrderModify(buyTicket,OrderOpenPrice(),0,0,0,clrNONE);
                  OrderSelect(sellTicket,SELECT_BY_TICKET,MODE_TRADES);
                  OrderModify(sellTicket,OrderOpenPrice(),0,0,0,clrNONE);
                  
                  currentPrice = Ask;
                  
                  buyFark = MathAbs(currentPrice-buyOP);
                  sellFark= MathAbs(currentPrice-sellOP);
                  yakinlik = MathMin(buyFark,sellFark);
                  
                  if(yakinlik == buyFark){
                     
                     //Buy işlemi gönderilir
                     OrderSend(NULL,OP_BUY,lot,Ask,0,0,0,NULL,magic,0,clrNONE);
                     
                     //Buy işlemlerinin açılış fiyatı en küçük ve en büyük olanı belirlenir
                     for(int h=0; h<OrdersTotal(); h++){
                        OrderSelect(h,SELECT_BY_POS,MODE_TRADES);
            
                        if(OrderType() == 0 && OrderOpenPrice() < ek){
                           ek = OrderOpenPrice();
                           ekTicket = OrderTicket();
                        }
                        if(OrderType() == 0 && OrderOpenPrice() > eb){
                           eb = OrderOpenPrice();
                           ebTicket = OrderTicket();
                        }
                        
                     }
                     
                     //Buy işlemlerinde açılış fiyatı en küçük olanın tp si 0 pip olarak ayarlanır
                     OrderSelect(ekTicket,SELECT_BY_TICKET,MODE_TRADES);
                     OrderModify(ekTicket,OrderOpenPrice(),OrderStopLoss(),0,0,clrNONE);
                     
                     //Buy işlemlerinde açılış fiyatı en büyük olanın sl si mevcut sell işleminin 100 pip altına konumlandırılır
                     OrderSelect(ebTicket,SELECT_BY_TICKET,MODE_TRADES);
                     OrderModify(ebTicket,OrderOpenPrice(),sellOP-0.001,0,0,clrNONE);
                     
                  }
                  else if(yakinlik == sellFark){
                     
                     //Sell işlemi gönderilir
                     OrderSend(NULL,OP_SELL,lot,Bid,0,0,0,NULL,magic,0,clrNONE);
                     
                     //Sell işlemlerinin açılış fiyatı en küçük ve en büyük olanı belirlenir
                     for(int h=0; h<OrdersTotal() ; h++){
                        OrderSelect(h,SELECT_BY_POS,MODE_TRADES);
                        
                        if(OrderType() == 1 && OrderOpenPrice() < ek && OrderMagicNumber() == magic){
                           ek = OrderOpenPrice();
                           ekTicket = OrderTicket();
                        }
                        if(OrderType() == 1 && OrderOpenPrice() > eb && OrderMagicNumber() == magic){
                           eb = OrderOpenPrice();
                           ebTicket = OrderTicket();
                        }
                        
                     }
                     
                     //sell işlemlerinde açılış fiyatı en büyük olanın tp si 0 pip olarak ayarlanır
                     OrderSelect(ebTicket,SELECT_BY_TICKET,MODE_TRADES);
                     OrderModify(ebTicket,OrderOpenPrice(),OrderStopLoss(),0,0,clrNONE);
                     
                     //sell işlemlerinde açılış fiyatı en küçük olanın sl si mevcut buy işleminin 100 pip üstüne konumlandırılır
                     OrderSelect(ekTicket,SELECT_BY_TICKET,MODE_TRADES);
                     OrderModify(ekTicket,OrderOpenPrice(),buyOP+0.001,0,0,clrNONE);
                     
                  }
                  
                  hmagic = 0;
               }
            }
            else if(buyCount == 1 && sellCount == 2 && buystopCount == 1 && sellstopCount == 0){
               
               //Buystop emri silinir
               OrderDelete(buystopTicket,clrNONE);
               
               //Sell işlemlerinin açılış fiyatı en küçük ve en büyük olanı belirlenir
               for(int h=0; h<OrdersTotal() ; h++){
                  OrderSelect(h,SELECT_BY_POS,MODE_TRADES);
                  
                  if(OrderType() == 1 && OrderOpenPrice() < ek && OrderMagicNumber() == magic){
                     ek = OrderOpenPrice();
                     ekTicket = OrderTicket();
                  }
                  if(OrderType() == 1 && OrderOpenPrice() > eb && OrderMagicNumber() == magic){
                     eb = OrderOpenPrice();
                     ebTicket = OrderTicket();
                  }
                  
               }
               
               //sell işlemlerinde açılış fiyatı en büyük olanın tp si 0 pip olarak ayarlanır
               OrderSelect(ebTicket,SELECT_BY_TICKET,MODE_TRADES);
               OrderModify(ebTicket,OrderOpenPrice(),OrderStopLoss(),0,0,clrNONE);
               
               //sell işlemlerinde açılış fiyatı en küçük olanın sl si mevcut buy işleminin 100 pip üstüne konumlandırılır
               OrderSelect(ekTicket,SELECT_BY_TICKET,MODE_TRADES);
               OrderModify(ekTicket,OrderOpenPrice(),buyOP+0.001,0,0,clrNONE);
            }
            else if(buyCount == 2 && sellCount == 1 && buystopCount == 0 && sellstopCount == 1){
               
               //Sellstop emri silinir
               OrderDelete(sellstopTicket,clrNONE);
               
               //Buy işlemlerinin açılış fiyatı en küçük ve en büyük olanı belirlenir
               for(int h=0; h<OrdersTotal(); h++){
                  OrderSelect(h,SELECT_BY_POS,MODE_TRADES);
      
                  if(OrderType() == 0 && OrderOpenPrice() < ek && OrderMagicNumber() == magic){
                     ek = OrderOpenPrice();
                     ekTicket = OrderTicket();
                  }
                  if(OrderType() == 0 && OrderOpenPrice() > eb && OrderMagicNumber() == magic){
                     eb = OrderOpenPrice();
                     ebTicket = OrderTicket();
                  }
                  
               }
               
               //Buy işlemlerinde açılış fiyatı en küçük olanın tp si 0 pip olarak ayarlanır
               OrderSelect(ekTicket,SELECT_BY_TICKET,MODE_TRADES);
               OrderModify(ekTicket,OrderOpenPrice(),OrderStopLoss(),0,0,clrNONE);
               
               //Buy işlemlerinde açılış fiyatı en büyük olanın sl si mevcut sell işleminin 100 pip altına konumlandırılır
               OrderSelect(ebTicket,SELECT_BY_TICKET,MODE_TRADES);
               OrderModify(ebTicket,OrderOpenPrice(),sellOP-0.001,0,0,clrNONE);
            }
            
            
            //AYNI MAGIC NUMARASINA SAHİP İŞLEMLER TOPLAM 4$ KAR YAPTI İSE AÇIK OLAN İŞLEMLER KAPATILIR
            for(int k=0; k<OrdersHistoryTotal(); k++){
               OrderSelect(k,SELECT_BY_POS,MODE_HISTORY);
               
               if(OrderMagicNumber() == magic){
                  kar_zarar +=  OrderProfit();
               }
               
            }
            
            if(kar_zarar >= 4.0){
               
               total = OrdersTotal();
               int l = 0;
               while(l<total){
                  
                  OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
                  
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
            
            buyCount = 0;
            sellCount = 0;
            buystopCount = 0;
            sellstopCount = 0;
            
            ek = 99999.99;
            eb = 00000.00;
            kar_zarar = 0.0;
            
      }//1.for sonu
  }//ontick sonu