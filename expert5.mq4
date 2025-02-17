#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//EXTERN VARIABLES
extern double LOT = 0.01;
extern double LOT2= 0.1;

//GLOBAL VARIABLES
int BC,SC,BSC,SSC;
int BT,ST,BST,SST;

int total;
double balance;

int passBuy = 0;
int passSell = 0;

double buyMedianPrice,sellMedianPrice;


int OnInit()
  {
      balance = AccountBalance();
      
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
      BC = 0;
      SC = 0;
      BSC= 0;
      SSC= 0;
      
      for(int i=0; i<OrdersTotal(); i++){
         
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         
         if(OrderType()==0){
            BC++;
            BT = OrderTicket();
         }
         else if(OrderType()==1){
            SC++;
            ST = OrderTicket();
         }
         else if(OrderType()==4){
            BSC++;
            BST = OrderTicket();
         }
         else if(OrderType()==5){
            SSC++;
            SST = OrderTicket();
         }
      }//FOR
      
      
      //KAR KONTROL
      if(AccountEquity() >= AccountBalance() + 250.0){
         
         total = OrdersTotal(); 
         
         for(int i=0; i<total; i++){
            
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            
            if(OrderType()==0){
                     
                     OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                     BC--;
                     i=-1;
                     total = OrdersTotal();
                     if(total==0)
                     break;
            }
            else if(OrderType()==1){
                     OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                     SC--;
                     i=-1;
                     total = OrdersTotal();
                     if(total==0)
                     break;
            }
            else if(OrderType()==4){
                     OrderDelete(OrderTicket(),clrNONE);
                     BSC--;
                     i=-1;
                     total = OrdersTotal();
                     if(total==0)
                     break;
            }
            else if(OrderType()==5){
                     OrderDelete(OrderTicket(),clrNONE);
                     SSC--;
                     i=-1;
                     total = OrdersTotal();
                     if(total==0)
                     break;
            }
         }
         balance = AccountBalance();
      }
      /*else if(AccountEquity() <= balance/2){
         
         total = OrdersTotal(); 
         
         for(int i=0; i<total; i++){
            
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            
            if(OrderType()==0){
                     
                     OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                     BC--;
                     i=-1;
                     total = OrdersTotal();
                     if(total==0)
                     break;
            }
            else if(OrderType()==1){
                     OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                     SC--;
                     i=-1;
                     total = OrdersTotal();
                     if(total==0)
                     break;
            }
            else if(OrderType()==4){
                     OrderDelete(OrderTicket(),clrNONE);
                     BSC--;
                     i=-1;
                     total = OrdersTotal();
                     if(total==0)
                     break;
            }
            else if(OrderType()==5){
                     OrderDelete(OrderTicket(),clrNONE);
                     SSC--;
                     i=-1;
                     total = OrdersTotal();
                     if(total==0)
                     break;
            }
         }
         balance = AccountBalance();
      }*/
      
      
      //İZİNLER GÜNCELLENİR
      if(BC>SC){
         passBuy = 1;
         passSell = 0;
      }
      else if(SC>BC){
         passSell = 1;
         passBuy = 0;
      }
      
      
      //KOŞULLAR 1.19900 
      
      /* 1 */   if(BC==0 && SC==0 && BSC==0 && SSC==0){
                  
                  //Mevcut fiyattan sell işlemi açılır ve 550 pip altına sstop emri konulur
                  OrderSend(NULL,OP_SELL,LOT,Bid,0,Bid+0.30450,0,NULL,0,0,clrNONE);
                  double ssPrice = Bid-0.0055;
                  OrderSend(NULL,OP_SELLSTOP,LOT2,ssPrice,0,0,0,NULL,0,0,clrNONE);
                  
                }
      /* 1.1 */ else if(BC==0 && SC==0 && BSC==0 && SSC==1){
                  
                  //SSTOP EMRİ SİLİNİR
                  OrderDelete(SST,clrNONE);
                  
                  //MEVCUT FİYATTAN BUY İŞLEMİ AÇILIR VE 550 PİP ÜSTÜNE BSTOP EMRİ KONULUR
                  OrderSend(NULL,OP_BUY,LOT,Ask,0,Ask-0.30450,0,NULL,0,0,clrNONE);
                  double bsPrice = Bid+0.0055;
                  OrderSend(NULL,OP_BUYSTOP,LOT2,bsPrice,0,0,0,NULL,0,0,clrNONE);
                  
                }
      /* 1.2 */ else if(BC==0 && SC >1 && BSC==0 && SSC==0){
                  
                  //MEVCUT İŞLEMLER TEK TEK DOLAŞILIR VE TP VE SL Sİ 0 DAN FARKLI OLAN İŞLEMLER MODİFE EDİLİR VE 0 YAPILIR
                  makeZero();
                  
                  //MEVCUT İŞLEMLERİN SL Sİ BİRBİRLERİNİ SIFIRLAYACAK ŞEKİLDE MODİFE EDİLİR
                  sellMedianPrice = median();
                  printf("sellMedianPrice %f",sellMedianPrice);
                  //EN KÜÇÜK AÇILIŞ FİYATINA SAHİP SELL İŞLEMİNİN 100 PİP ALTINA 0.1 LIK SSTOP EMRİ KONULUR
                  double ssPrice = EKfinder()-0.001;
                  OrderSend(NULL,OP_SELLSTOP,LOT2,ssPrice,0,0,0,NULL,0,0,clrNONE);
                  
                }
      /* 1.3 */ else if(BC==0 && SC==0 && BSC==1 && SSC==0){
                  
                  //BSTOP EMRİ SİLİNİR
                  OrderDelete(BST,clrNONE);
                  
                  //MEVCUT FİYATTAN SELL İŞLEMİ AÇILIR VE 550 PİP ALTINA SSTOP EMRİ KONULUR
                  OrderSend(NULL,OP_SELL,LOT,Bid,0,Bid+0.30450,0,NULL,0,0,clrNONE);
                  double ssPrice = Bid-0.0055;
                  OrderSend(NULL,OP_SELLSTOP,LOT2,ssPrice,0,0,0,NULL,0,0,clrNONE);
                  
                }
      /* 1.4 */ else if(BC >1 && SC==0 && BSC==0 && SSC==0){
                  
                  //MEVCUT İŞLEMLER TEK TEK DOLAŞILIR VE TP VE SL Sİ 0 DAN FARKLI OLAN İŞLEMLER MODİFE EDİLİR VE 0 YAPILIR
                  makeZero();
                  
                  //MEVCUT İŞLEMLERİN SL Sİ BİRBİRLERİNİ SIFIRLAYACAK ŞEKİLDE MODİFE EDİLİR
                  buyMedianPrice = median();
                  printf("buyMedianPrice %f",buyMedianPrice);  
                  //EN BÜYÜK AÇILIŞ FİYATINA SAHİP BUY İŞLEMİNİN 100 PİP ÜSTÜNE 0.1 LIK BSTOP EMRİ KONULUR
                  double bsPrice = EBfinder()+0.001;
                  OrderSend(NULL,OP_BUYSTOP,LOT2,bsPrice,0,0,0,NULL,0,0,clrNONE);
                }
       
       
       
       //İŞLEM KAPATMA KONTROL         
       if(passBuy==1 && Bid<=buyMedianPrice && BC>1){
         //tip i 0 olan tüm işlemler kapatılır
          
         total = OrdersTotal(); 
         
         for(int i=0; i<total; i++){
            
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            
            if(OrderType()==0){
                     
                     OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                     BC--;
                     i=-1;
                     total = OrdersTotal();
                     if(total==0)
                     break;
            }
         }
       }
       if(passSell==1 && Ask>=sellMedianPrice && SC>1){
         //tip i 1 olan tüm işlemler kapatılır
         
         total = OrdersTotal(); 
         
         for(int i=0; i<total; i++){
            
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            
            if(OrderType()==1){
                     
                     OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                     SC--;
                     i=-1;
                     total = OrdersTotal();
                     if(total==0)
                     break;
            }
         }
       }
       
  }//ONTICK
  
  
  
  
  
  
  
  //FONKSİYONLAR
  
  
  void makeZero(){
   
      for(int i=0; i<OrdersTotal(); i++){
         
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         
         if(OrderTakeProfit()!=0 || OrderStopLoss()!=0){
            OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0,clrNONE);
         }
      }
  }
  
  double median(){
      
      double sumOP = 0.0;
      int sumLOT= 0;
      double price = 0.0;
      double temp = 0.0;
      
      for(int i=0; i<OrdersTotal(); i++){
         
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         
         if(OrderType()==0 || OrderType()==1){
            temp = OrderOpenPrice()*(OrderLots()*100);
            sumOP += temp;
            sumLOT += OrderLots()*100;
         }
      }
      printf("sumOP %f",sumOP);
      printf("sumLOT %d",sumLOT);
      price = sumOP/sumLOT;
      
      return(price); 
  }
  
  double EKfinder(){
  
      double EK = 999999999999.99999;
      int EKT = 0;
      
      for(int i=0; i<OrdersTotal(); i++){
         
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         
         if(OrderOpenPrice() < EK){
            EK = OrderOpenPrice();
            EKT = OrderTicket();
         }
      }
      
      return(EK);
  }
  
  double EBfinder(){
  
      double EB = 0.0;
      int EBT = 0;
      
      for(int i=0; i<OrdersTotal(); i++){
         
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         
         if(OrderOpenPrice() > EB){
            EB = OrderOpenPrice();
            EBT = OrderTicket();
         }
      }
      
      return(EB);
  }