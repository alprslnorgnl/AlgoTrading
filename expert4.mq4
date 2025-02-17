#property copyright "alparslan"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//Global Variables
int lastBar = 0;
double indexOneHigh,indexTwoHigh,indexTreeHigh;
double indexOneLow,indexTwoLow,indexTreeLow;

double iOneHigh,iOneLow,iOneOpen,iOneClose;
int OPbinler,CLbinler,HGbinler,LWbinler;

int currentMinute;
int boolean = 0;

int OnInit()
  {
      
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
       currentMinute = TimeMinute(TimeCurrent());
       
       if(currentMinute == 5 && boolean == 1)
       boolean = 0;
  
       if (currentMinute == 0 && boolean == 0)
       {
           //Yeni bir mum aktif olmuş demektir istediğini yapabilirsin
           
           indexOneHigh = iHigh(Symbol(), Period(), 1);
           indexTwoHigh = iHigh(Symbol(), Period(), 2);
           indexTreeHigh= iHigh(Symbol(), Period(), 3);
           
           //Satış poziyonu için kapanan son iki mumdan yüksek olma şartı sağlanır
           if(indexOneHigh > indexTwoHigh && indexOneHigh > indexTreeHigh)
           {
               iOneOpen = iOpen(Symbol(), Period(), 1);
               iOneClose= iClose(Symbol() ,Period(), 1);
               
               //Satış poziyonu için ikinci şart sağlanır
               if(iOneOpen > iOneClose)
               {
                  iOneHigh = iHigh(Symbol(), Period(), 1);
     
                  OPbinler = GetThousandthPlace(iOneOpen);
                  CLbinler = GetThousandthPlace(iOneClose);
                  HGbinler = GetThousandthPlace(iOneHigh);
                  
                  if((OPbinler == CLbinler) && OPbinler < HGbinler )
                  {
                     Print("SELL FIRSATI!!!!");
                     Print(OPbinler);
                     Print(CLbinler);
                     Print(HGbinler);
                  }
                  else if((OPbinler && CLbinler) == 9 && HGbinler == 0)
                  {
                     Print("SELL FIRSATI!!!!");
                     Print(OPbinler);
                     Print(CLbinler);
                     Print(HGbinler);
                  }
               }
           }
           
           indexOneLow = iLow(Symbol(), Period(), 1);
           indexTwoLow = iLow(Symbol(), Period(), 2);
           indexTreeLow= iLow(Symbol(), Period(), 3);
           
           //Alış pozisyonu için kapanan son iki mumdan düşük olma şartı sağlanır
           if(indexOneLow < indexTwoLow && indexOneLow < indexTreeLow)
           {
               iOneOpen = iOpen(Symbol(), Period(), 1);
               iOneClose= iClose(Symbol() ,Period(), 1);
               
               //Alış poziyonu için ikinci şart sağlanır
               if(iOneOpen < iOneClose)
               {
                  iOneLow = iLow(Symbol(), Period(), 1);
                  
                  OPbinler = GetThousandthPlace(iOneOpen);
                  CLbinler = GetThousandthPlace(iOneClose);
                  LWbinler = GetThousandthPlace(iOneLow);
                  
                  if((OPbinler == CLbinler) && OPbinler > LWbinler )
                  {
                     Alert("BUY FIRSATI!!!!");
                     Print(OPbinler);
                     Print(CLbinler);
                     Print(LWbinler);
                  }
                  else if((OPbinler && CLbinler) == 0 && LWbinler == 9)
                  {
                     Alert("BUY FIRSATI!!!!");
                     Print(OPbinler);
                     Print(CLbinler);
                     Print(LWbinler);
                  }
                  
               }
           }
           
           boolean = 1;
           
           
       }//newbar control last
  }//onTick last


//NewBar Fonksiyonu Tanımı
bool NewBar()
  {
      int currentBar = iBarShift(Symbol(), PERIOD_CURRENT, TimeCurrent());
       
      if (currentBar != lastBar)
      {
          lastBar = currentBar;
          return true;
      }
       
      return false;
  }
  
  
int GetThousandthPlace(double num) {

  // Convert the number to a string
  string numStr = DoubleToString(num, 5); //5 digits after the decimal point

  // Find the position of the decimal point
  int pointPos = StringFind(numStr, ".");

  // Extract the digit in the thousandth place (if it exists)
  if (pointPos > -1 && StringLen(numStr) >= pointPos + 4) {
    string thousandthPlaceStr = StringSubstr(numStr, pointPos + 2, 1);
    return StrToInteger(thousandthPlaceStr);
  }

  // If the number doesn't have a thousandth place
  return -1;
}