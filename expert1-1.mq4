//Expert 1 gibi sürekli işlem açmak yerine tek işlem üzerinden gidiyor

#property copyright "Alparslan"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double lot = 0.03;

      //her tik sonunda tekrardan bu değerlere eşitlenecek
      int buycount = 0;
      int sellcount= 0;
      int buystopcount = 0;
      int sellstopcount= 0;
      int type;
      
      int buyTicket,sellTicket,buystopTicket,sellstopTicket;
      
      double buyopenprice;
      double sellopenprice;
      
      //açık olan tüm işlemler kapandıktan sonra bu değerler sıfırlanacak
      double buystopPrice = 0.0;
      double sellstopPrice= 0.0;
      int boolean = 0;
   
      //Her tik sonunda kendi değerlerine sıfırlanacak
      double ek = 99999.99;
      double eb = 00000.00;
      int ekTicket,ebTicket;
      
      
      //mevcut işlem ticket
      int mticket;
      double cprice;
      double buyfark;
      double sellfark;
      double yakinlik;
      
      
      //bakiye
      double kar_zarar;
      
      double mevcutbakiye;
      double istenendeger;
      
      
      int total;
      double mevcutbakiye2;
      

int OnInit()
  {
      //Başlangıçta bir adet buy işlemi ve sellstop işlemi açılır
      mevcutbakiye = AccountInfoDouble(ACCOUNT_BALANCE);
      istenendeger = mevcutbakiye + 4.0;
      OrderSend(NULL,OP_BUY,lot,Ask,0,0,Ask+0.002,NULL,0,0,clrNONE);
      OrderSend(NULL,OP_SELLSTOP,lot,Ask-0.00100,0,0,0,NULL,0,0,clrNONE);
      
   return(INIT_SUCCEEDED);
  }


void OnTick()
  {
      //Hangi işlem türünden kaç tane olduğu belirlenir ve gerekli bilgiler alınır
      for(int i=0; i<OrdersTotal() ; i++){
         
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         
         type = OrderType();
         
         if(type == 0){
            buycount++;
            buyTicket = OrderTicket();
            buyopenprice = OrderOpenPrice();
         }
         else if(type == 1){
            sellcount++;
            sellTicket = OrderTicket();
            sellopenprice = OrderOpenPrice();
         }
         else if(type == 4) {
            buystopcount++;
            buystopTicket = OrderTicket();
         }
         else if(type == 5){
            sellstopcount++;
            sellstopTicket = OrderTicket();
         }
         
      }
      
      if(buycount == 0 && sellcount == 0 && buystopcount == 0 && sellstopcount == 1){
      
         //Sellstop emri silinir
         OrderDelete(sellstopTicket,clrNONE);
         
         //Buy işlemi açılır ve sellstop emri konur
         //OrderSend(NULL,OP_BUY,lot,Ask,0,0,Ask+0.002,NULL,0,0,clrNONE);
         //OrderSend(NULL,OP_SELLSTOP,lot,Ask-0.00100,0,0,0,NULL,0,0,clrNONE);
         
         //mevcutbakiye = AccountInfoDouble(ACCOUNT_BALANCE);
         //istenendeger = mevcutbakiye + 4.0;
      }
      else if(buycount == 1 && sellcount == 1 && buystopcount == 0 && sellstopcount == 0 && boolean == 0){
      
         //Var olan işlemlerin tp ve sl leri 0 yapılır ve Buystop - Sellstop emirleri konur
         OrderSelect(buyTicket,SELECT_BY_TICKET,MODE_TRADES);
         OrderModify(buyTicket,OrderOpenPrice(),0,0,0,clrNONE);
         buystopPrice = OrderOpenPrice()+0.00100;
         OrderSend(NULL,OP_BUYSTOP,lot,buystopPrice,0,0,0,NULL,0,0,clrNONE);
         
         OrderSelect(sellTicket,SELECT_BY_TICKET,MODE_TRADES);
         sellstopPrice = OrderOpenPrice()-0.00100;
         OrderSend(NULL,OP_SELLSTOP,lot,sellstopPrice,0,0,0,NULL,0,0,clrNONE);
         
         boolean = 1;

      }
      else if(buycount == 1 && sellcount == 2 && buystopcount == 1 && sellstopcount == 0){
         
         //Buystop emri silinir
         OrderDelete(buystopTicket,clrNONE);
         
         //sell işlemlerinin açılış fiyatı en küçük ve en büyük olanı belirlenir
         for(int i=0; i<OrdersTotal() ; i++){
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            
            if(OrderType() == 1 && OrderOpenPrice() < ek){
               ek = OrderOpenPrice();
               ekTicket = OrderTicket();
            }
            if(OrderType() == 1 && OrderOpenPrice() > eb){
               eb = OrderOpenPrice();
               ebTicket = OrderTicket();
            }
            
         }
         
         //sell işlemlerinde açılış fiyatı en büyük olanın tp si 0 pip olarak ayarlanır
         OrderSelect(ebTicket,SELECT_BY_TICKET,MODE_TRADES);
         OrderModify(ebTicket,OrderOpenPrice(),OrderStopLoss(),0,0,clrNONE);
         
         //sell işlemlerinde açılış fiyatı en küçük olanın sl si mevcut buy işleminin 100 pip üstüne konumlandırılır
         OrderSelect(ekTicket,SELECT_BY_TICKET,MODE_TRADES);
         OrderModify(ekTicket,OrderOpenPrice(),buyopenprice+0.001,0,0,clrNONE);
         
      }
      else if(buycount == 2 && sellcount == 1 && buystopcount == 0 && sellstopcount == 1){
         
         //Sellstop emri silinir
         OrderDelete(sellstopTicket,clrNONE);
         
         //buy işlemlerinin açılış fiyatı en küçük ve en büyük olanı belirlenir
         for(int i=0; i<OrdersTotal(); i++){
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

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
         OrderModify(ebTicket,OrderOpenPrice(),sellopenprice-0.001,0,0,clrNONE);
         
      }
      else if(buycount == 1 && sellcount == 1 && buystopcount == 0 && sellstopcount == 0 && boolean == 1){
         
         //Mevcut işlemlerin tp ve sl si sıfırlanır
         for(int i=0; i<OrdersTotal(); i++){
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            
            mticket = OrderTicket();
            
            OrderModify(mticket,OrderOpenPrice(),0,0,0,clrNONE);
         }
         
         cprice = Ask;
         
         buyfark = MathAbs(cprice-buyopenprice);
         sellfark= MathAbs(cprice-sellopenprice);
         yakinlik = MathMin(buyfark,sellfark);
         
         //fiyat buy işlemine yakınsa
         if(yakinlik == buyfark){
            OrderSend(NULL,OP_BUY,lot,Ask,0,0,0,NULL,0,0,clrNONE);
            
            //buy işlemlerinin açılış fiyatı en küçük ve en büyük olanı belirlenir
            for(int i=0; i<OrdersTotal(); i++){
               OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   
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
            OrderModify(ebTicket,OrderOpenPrice(),sellopenprice-0.001,0,0,clrNONE);
         }
         
         //fiyat sell işlemine yakınsa
         if(yakinlik == sellfark){
            OrderSend(NULL,OP_SELL,lot,Bid,0,0,0,NULL,0,0,clrNONE);
             
            //sell işlemlerinin açılış fiyatı en küçük ve en büyük olanı belirlenir
            for(int i=0; i<OrdersTotal() ; i++){
               OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
               
               if(OrderType() == 1 && OrderOpenPrice() < ek){
                  ek = OrderOpenPrice();
                  ekTicket = OrderTicket();
               }
               if(OrderType() == 1 && OrderOpenPrice() > eb){
                  eb = OrderOpenPrice();
                  ebTicket = OrderTicket();
               }
               
            }
            
            //sell işlemlerinde açılış fiyatı en büyük olanın tp si 0 pip olarak ayarlanır
            OrderSelect(ebTicket,SELECT_BY_TICKET,MODE_TRADES);
            OrderModify(ebTicket,OrderOpenPrice(),OrderStopLoss(),0,0,clrNONE);
            
            //sell işlemlerinde açılış fiyatı en küçük olanın sl si mevcut buy işleminin 100 pip üstüne konumlandırılır
            OrderSelect(ekTicket,SELECT_BY_TICKET,MODE_TRADES);
            OrderModify(ekTicket,OrderOpenPrice(),buyopenprice+0.001,0,0,clrNONE);
         }
      }
      
      kar_zarar = AccountEquity();
      mevcutbakiye2 = AccountInfoDouble(ACCOUNT_BALANCE);
      
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
         
         buystopPrice = 0.0;
         sellstopPrice = 0.0;
         boolean = 0;
         mevcutbakiye = AccountInfoDouble(ACCOUNT_BALANCE);
         istenendeger = mevcutbakiye + 4.0;
         
         //OrderSend(NULL,OP_BUY,lot,Ask,0,0,Ask+0.002,NULL,0,0,clrNONE);
         //OrderSend(NULL,OP_SELLSTOP,lot,Ask-0.00100,0,0,0,NULL,0,0,clrNONE);
      }
      
      if((mevcutbakiye - mevcutbakiye2) >= 27.0){
         
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
         
         buystopPrice = 0.0;
         sellstopPrice = 0.0;
         boolean = 0;
         mevcutbakiye = AccountInfoDouble(ACCOUNT_BALANCE);
         istenendeger = mevcutbakiye + 4.0;
         
         //OrderSend(NULL,OP_BUY,lot,Ask,0,0,Ask+0.002,NULL,0,0,clrNONE);
         //OrderSend(NULL,OP_SELLSTOP,lot,Ask-0.00100,0,0,0,NULL,0,0,clrNONE);
         
      }
      
      buycount = 0;
      sellcount= 0;
      buystopcount = 0;
      sellstopcount= 0;
      
      ek = 99999.99;
      eb = 00000.00;
  }