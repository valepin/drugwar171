/* Author: Valeria Espinosa
   Date: April 3, 2012
   CS 171 
   Homicide Rate in Mexico (1990-2010)
*/


Collect table, popul,Stable, Spopul, milInt,cartel07,cartel10,ppartycMun,ppartycS;
int bg_color = 50;
int fill_color=250;
int plot_x1, plot_x2, plot_y1, plot_y2;
float plot_width, plot_height,xrange, yrange;
float x_step_size,y_step_size;


import controlP5.*;

ControlP5 controlP5;

CheckBox checkbox;


float[] point_size;
float[] or_size;
float[][] datapoints,statepoints,cartelpoints,nationalpoints;
float[] munHR,stateHR,cartelHR,nationalHR;
char cartS;
boolean click = false, cart2010 = false;
int extra=30; // for the axis not to start with the lowest value
  int cartInt,rowCart =0,cartIndl =0, cartIndd=0;


// Some Fonts
PFont titlefont;
PFont font;
PFont legendfont;


// municipality index to plot (default should be the national one)
boolean all=true;
int munIndex=31;
int state;


// Years considered
int[] years;


// current ranges
float[] ylims={0.0,20};
float[] xlims={1989,2011};
int steps = 22;

// Getting the Cartel Name
String[][] cartels = {
  {"Gulf Cartel", "G"},
  {"Los Zetas Cartel", "Z"},
  {"Pacifico Sur Cartel", "P"},
  {"La Familia Michoacana", "F"},
  {"Cartel de Juárez", "J"},
  {"Sinaloa Cartel","S"},
  {"Not Specified", "N"},
  {"In Dispute", "D"},
  {"Pacifico Sur and Sinaloa Cartels","s"},
  {"Acapulco and Pacifico Sur Cartels","a"},
  {"Gulf and Los Zetas Cartels","z"},
};

/*define the colors to use (this should be linked to the Cartel and the )
purple, red,blue pink, orange,green,yellow,gray? cyan = Acapulco Cartel */
color[][] seriesCols={
{#9400D3, #DA70D6,#A9A9A9},
{#FF4500, #FFA500,#A9A9A9},
{#4169E1, #87CEFA,#A9A9A9},
{#C71585, #FF69B4,#A9A9A9},
{#B22222, #FA8080,#A9A9A9},
{#008000, #32CD32,#A9A9A9},
{#FFD700, #F0E68C,#A9A9A9},
{#708090,#D3D3D3,#A9A9A9},
{#66CDAA, #AFEEEE,#708090}

};


RadioButton r;

void setup() {
  size(1100, 600);
   table = new Collect("../Data/MunHomicides.tsv");
   popul = new Collect("../Data/MunPopulationEst.tsv");
   Stable = new Collect("../Data/StateHomicides.tsv");
   Spopul = new Collect("../Data/StatePop.tsv");
   milInt = new Collect("../Data/InterventionDataNexos2011.tsv");
   cartel07 = new Collect("../Data/cartel2007HR.tsv");
   cartel10 = new Collect("../Data/cartel2010HR.tsv");
   ppartycMun = new Collect("../Data/CartelIncomeExpensesByMunicipality.tsv");
   ppartycS = new Collect("../Data/CartelIncomeExpensesState.tsv");
   years = new int[table.numCols];
   // Years considered
   for (int i=0; i < 21 ;i++)
   {
     years[i]=1990+i;
   } 
   
   
  // define the fonts to be used
   titlefont = loadFont("TrebuchetMS-Bold-24.vlw");
  legendfont = loadFont("TrebuchetMS-16.vlw");
  font = loadFont("ArialMT-10.vlw");
  textFont(font);
  

  
  //set the checkbox
  controlP5 = new ControlP5(this);
  r = controlP5.addRadioButton("radioButton",width-150,100);
  r.setColorForeground(color(200));
  r.setColorActive(color(255));
  r.setColorLabel(color(255));
 r.setItemsPerRow(1);
  r.setSpacingColumn(2);

  addToRadioButton(r,"2007",0);
  addToRadioButton(r,"2010",1);
}


void addToRadioButton(RadioButton theRadioButton, String theName, int theValue ) {
  Toggle t = theRadioButton.addItem(theName,theValue);
  t.captionLabel().setColorBackground(color(80));
  t.captionLabel().style().movePadding(2,0,-1,2);
  t.captionLabel().style().moveMargin(-2,0,0,-3);
  t.captionLabel().style().backgroundWidth = 46;
}


void controlEvent(ControlEvent theEvent) {
  print("got an event from "+theEvent.group().name()+"\t");
  for(int i=0;i<theEvent.group().arrayValue().length;i++) {
    print(int(theEvent.group().arrayValue()[i]));
  }
  println("\t "+theEvent.group().value());
  if(int(theEvent.group().value())==1){cart2010 = true;}
   else{cart2010 = false;}   
}


void draw() {
  background(bg_color);
  
  /*
  | IMPORTANT:
  | the next two lines determine the dimensions of the plot area
  */
  int w = (int) (width * 0.9);
  int h = (int) (height * 0.7);
  
  strokeWeight(1);
  
  state = floor(popul.getFloatAt(munIndex,0)/1000)-1;
  
  /*
  | Start Drawing here.
  | Change these methods if necessary, clearly
  | commenting where any changes have been made
  */
  drawPlotArea(w, h);
 
  drawTitle(popul.getDataAt(munIndex, 1)+", "+ Spopul.getDataAt(state, 1) );
    drawAxesLabels("year", "homicide rate");
    drawGridlines();
  plotDataPoints(munIndex);
  // cover the lines that go below the zero line
//    rectMode(CORNERS);
//  stroke(bg_color);
//  fill(bg_color);
//  rect(plot_x1, plot_y2, plot_x2, plot_y2+20);

  drawLegend();
  drawIntervention(munIndex,state,100);
  drawPartyChange(munIndex,state,#BC8F8F);
  //drawZoomLegend();
  inspectDataPoints(munHR, datapoints,'M');
  inspectDataPoints(stateHR, statepoints,'S');
 inspectDataPoints(nationalHR, nationalpoints,'N');
  inspectDataPoints(cartelHR, cartelpoints,'C');
  
  
}

/*
| IMPORTANT:
| alter this method to change positioning of plot area
*/
void drawPlotArea(int w, int h) {
  plot_x1 = 4*(width - w)/5 ;
  plot_y1 = (height - h) / 2;
  plot_x2 = plot_x1 + 16*w/20;
  plot_y2 = plot_y1 + h;
  rectMode(CORNERS);
  stroke(250);
  fill(250);
  rect(plot_x1, plot_y1, plot_x2, plot_y2);

  // set dimensions for later use
  plot_width = plot_x2 - plot_x1;
  plot_height = plot_y2 - plot_y1;
  
}

void drawTitle (String t) {
   textFont(titlefont);
  fill(fill_color);
  textAlign(CENTER);
  textSize(32);
  text(t, width/2, 3*plot_y1/5);

}

void drawAxesLabels (String x_axis, String y_axis) {
  textSize(16);
  
  // axis labels are centered between adjacent edge of plot area and window
  text(x_axis, width/2, plot_y2+50);
  verticalText(y_axis, -height/2, plot_x1/3);
  textSize(10);
  verticalText("per 100000 inhabitants ", -height/2, plot_x1/3+15);

  
  // record areas where axes lie
//    textSize(10);
//  x_axis_area = new float[] { (height+plot_y2)/2-7, (height+plot_y2)/2+7 };
//  y_axis_area = new float[] { plot_x1/2-7, plot_x1/2+7 };
}



// draw grid lines
void drawGridlines () { 
  //define the ranges accordingly
  // these should be in the original scale
  xrange =  xlims[1]-xlims[0];
  yrange = ylims[1]-ylims[0];

  // steps defined at top of document, default 10
  float x_step_size = plot_width / steps;
  float y_step_size = plot_height /steps;

  for (int n =1; n <= steps; n++) {

    float x = plot_x1 + n * x_step_size;
    float y = plot_y2 - n * y_step_size;
    
    stroke(255);
    // draw grid lines
    line(plot_x1, y, plot_x2, y);
    line(x, plot_y1, x, plot_y2);
    //text(,x, plot_y2);

    // label grid lines as well
    textSize(10);
    text(truncate(ylims[0]+(n * yrange)/steps,1), plot_x1-15, y );
    if(n>0 & n<steps)
    text(years[n-1], x, plot_y2+15 );
      
  }
  
     text(ylims[0], plot_x1-15, plot_y2 );
    //text(xlims[0], plot_x1, plot_y2+15 );

}  


// plots column x against column y
void plotDataPoints (int mun) {
  int ncols =popul.numCols-2;
  datapoints = new float[ncols][2];
  statepoints = new float[ncols][2];
  nationalpoints = new float[ncols][2];
  cartelpoints = new float[ncols][2];
  nationalHR = new float[ncols];
  cartelHR = new float[ncols];
  munHR = new float[ncols];
  stateHR = new float[ncols];
  int i,col;
  float x,y,pop;
  int state = floor(popul.getFloatAt(mun,0)/1000)-1;
  if(cart2010){   cartS = ppartycMun.getCharAt(mun,6);}
  else{   cartS = ppartycMun.getCharAt(mun,5);}
  
  
  //define the colors
    switch(cartS){
  case 'G':
    cartIndl = 0;
    cartIndd = 0;
    rowCart = 0;
    break;
  case 'Z':
    cartIndl = 1;
     cartIndd = 1;
     rowCart = 1;
    break;
  case 'P':
    cartIndl = 2;
    cartIndd = 2;
    rowCart = 2;
    break;
  case 'F':
    cartIndl = 3;
    cartIndd = 3;
    rowCart = 3;
    break;
  case 'J':
    cartIndl = 4;
    cartIndd = 4;
    rowCart = 4;
    break;
  case 'S':
    cartIndl = 5;
    cartIndd = 5;
    rowCart = 5;
    break;
  case 'N':
    cartIndl = 6;
    cartIndd = 6;
    rowCart =6;
    break;
  case 'D':
    cartIndl = 7;
    cartIndd = 7;
    rowCart =7;
    break;
   case 's':
    cartIndl = 2;
    cartIndd = 5;
    rowCart =8;
    break;
   case 'a':
    cartIndl = 2;
    cartIndd = 8;
    rowCart =9;
    break;
   case 'z':
    cartIndl = 1;
    cartIndd = 0;
    rowCart =10;
    break;  
   default:
    println("failed"); 
  }
  
    // i is a counter over the columns (years)
  for (i = 0; i < datapoints.length; i++) {
    // load homicides and population for municipality mun
   // the data set is not homogoenous, it has more columns per year starting in 2007
     if(i>17)
     {
       col=3*18+4*(i-17);
     }else
     {
      col=3*(i+1);     
     }
     //municipality population by year
    datapoints[i][1] =   popul.getFloatAt(mun,i+2);
    datapoints[i][1] =   popul.getFloatAt(mun,i+2);
    // if it is zero get the state average
    if(datapoints[i][1] ==0){ 
      datapoints[i][1] =  Spopul.getFloatAt(state,i+2);
    }
   datapoints[i][0] = table.getFloatAt(mun, col);
   munHR[i] = datapoints[i][0]/datapoints[i][1]*100000;
  //state
   statepoints[i][1] =  Spopul.getFloatAt(state,i+2);
   statepoints[i][0] = Stable.getFloatAt(state, col);
   stateHR[i] = statepoints[i][0]/statepoints[i][1]*100000;
  //national
   nationalpoints[i][1] =  cartel10.getFloatAt(23,i+1);
   nationalpoints[i][0] = cartel10.getFloatAt(22,i+1); 
   nationalHR[i] = nationalpoints[i][0]/nationalpoints[i][1]*100000;
   //cartel
   if(cart2010)
   {
     cartelpoints[i][1] =  cartel10.getFloatAt(2*rowCart+1,i+1);
     cartelpoints[i][0] = cartel10.getFloatAt(2*rowCart,i+1); 
     cartelHR[i] = cartelpoints[i][0]/cartelpoints[i][1]*100000;
   }else
  {
     cartelpoints[i][1] =  cartel07.getFloatAt(2*rowCart+1,i+1);
     cartelpoints[i][0] = cartel07.getFloatAt(2*rowCart,i+1); 
     cartelHR[i] = cartelpoints[i][0]/cartelpoints[i][1]*100000;
  } 
  }
  
  float mm=max(max(munHR),max(stateHR)), ms=max(max(nationalHR),max(cartelHR));
  ylims[1]=max(mm,ms);
  //ylims[0]=min(datapoints);

     /*
    | draw spline
    */
    
     drawSpline(cartelHR,seriesCols[cartIndl][0] );
    drawSpline(munHR,seriesCols[cartIndl][1] );
    drawSpline(stateHR,seriesCols[cartIndl][2] );
    drawSpline(nationalHR,0);

    /*
    | map the coordinates to the plot canvas and plot
    */
    
    drawPoints(cartelHR,seriesCols[cartIndd][0] );  
    drawPoints(munHR,seriesCols[cartIndd][1] );
    drawPoints(stateHR,seriesCols[cartIndd][2] );
    drawPoints(nationalHR,0 );

  // plot datapoints

}


// we need to truncate at zero!
void drawSpline(float[] vector,color colo){
   // using a spline to create a smooth curve over the points
   int i;
   float x,y,x_p,y_p;
   // a flag to indicate if the previous one is zero
   boolean prev0 = false, cont_point=true;
  noFill();
  stroke(colo);
  beginShape();   
  for (i = 0; i < vector.length; i++) {
 
    x =  map(years[i], xlims[0], xlims[1], plot_x1, plot_x2);
    y =  map(vector[i], ylims[0], ylims[1], plot_y2, plot_y1);
   if(vector[i]==0 && prev0)
   { 
     x_p =  map(years[i-1], xlims[0], xlims[1], plot_x1, plot_x2);
     y_p =  map(vector[i-1], ylims[0], ylims[1], plot_y2, plot_y1);
     line(x_p,y_p,x,y);
     // to make the previous point the last control point?
     curveVertex(x_p,y_p);
     if(i<vector.length-1 && vector[i+1]>0)
     {
       cont_point=true;
     }
   }else
   {  curveVertex(x,y);
       prev0= false;
   }
   
    /* is also the start point of curve is also the first control point, and
     is also the start point of curve is also the first control point*/
    if(cont_point || i == (vector.length-1) )
    {
      curveVertex(x,y);
      cont_point=false;
    }
    if(vector[i]==0)
      prev0=true;    
  }
  endShape(); 
}


void drawPoints(float[] vector,color colo){
   // using a spline to create a smooth curve over the points
   int i;
   float x,y;
  fill(colo);//,170);
  stroke(colo);  
  for (i = 0; i < vector.length; i++) {
    x =  map(years[i], xlims[0], xlims[1], plot_x1, plot_x2);
    y =  map(vector[i], ylims[0], ylims[1], plot_y2, plot_y1);
    
   //if(datapoints[i][0]>=xlims[0] && datapoints[i][0]<=xlims[1] && datapoints[i][1]>=ylims[0] && datapoints[i][1]<=ylims[1]){
      ellipse(x,y,5,5);
   // }
  }
  
}

void inspectDataPoints (float[] vector, float[][] matrix, char type) {
  float x,y;
  for (int i = 0; i < vector.length; i++) {
    x =  map(years[i], xlims[0], xlims[1], plot_x1, plot_x2);
    y =  map(vector[i], ylims[0], ylims[1], plot_y2, plot_y1);
    // if mouse is within hover radius of a point. note: 1 is VERY accurate
    if (near(x,y, mouseX, mouseY, 5)) {
      // show tooltip with player name
      // have a bos show up wiith the label so it can be read more clearly
//      println("yes");
//      rectMode(CENTER);
//      stroke(255); fill(255); textAlign(RIGHT,RIGHT);
//      //rect(mouseX + 50, mouseY ,textWidth(table.getDataAt(i, table.fieldIndex("name")))+10,60);
//      rect(mouseX + 50, mouseY, 1.5*textWidth(popul.getDataAt(munIndex, 1)),60);
     stroke(bg_color);
     line(plot_x1,y,plot_x2,y);
      stroke(250); fill(250); textAlign(CENTER);textSize(18);
      switch(type){
      case 'S':
          text(Spopul.getDataAt(state, 1), width- 120,  200);
          text(" ("+ years[i]+")", width- 120,  220);
          break;
      case 'M':    
           text(popul.getDataAt(munIndex, 1),width-120, 200);
           text(" ("+ years[i]+")", width- 120,  220);
           break;
      case 'N':    
           text("National",width-120, 200);
           text(" ("+ years[i]+")", width- 120,  220);
           break;
      case 'C':
           text(cartels[rowCart][0],width-120, 200);
           text(" ("+ years[i]+")", width- 120,  220);
           break;
      }
      textFont(legendfont);
      fill(250); textSize(12);
      textAlign(LEFT);
      text("estimated population: " + floor(matrix[i][1]), width- 200, 240 );
      text("number of homicides: " + floor(matrix[i][0]),width- 200, 260 );

    }
  }
}


// for the checkbox
//void mouseClicked() {
//  click = true;
//} 


//// Size legend of time series
void drawLegend(){
  
  textAlign(LEFT);
  stroke(250); fill(250);
  textSize(11);

   text(Spopul.getDataAt(state, 1), width -180, plot_y2-80);
   text(popul.getDataAt(munIndex, 1), width -180, plot_y2-60);
   text(cartels[rowCart][0], width -180, plot_y2-40);

  
 //Lenged for size
  for (int i = 0; i < 3; i++)
  {
    fill(seriesCols[cartIndl][i]);
    stroke(seriesCols[cartIndd][i]);
    ellipse(width -190,  plot_y2-45-20*i, 6, 6);
  }

}  

void drawIntervention(int mun, int sta, color cInt)
{
 int ncols = milInt.numRows;
 int i,countInt=0;
 float clave;
 float intYear,x;

 for(i = 0; i < ncols; i++)
 { 
   clave=milInt.getFloatAt(i,0);
   println(clave==popul.getFloatAt(mun,0));
   if(clave==popul.getFloatAt(mun,0))
   {
     intYear= milInt.getFloatAt(i,5);
     x= map(intYear, xlims[0], xlims[1], plot_x1, plot_x2); 
       
     println(intYear);
     println(x);
     stroke(cInt);
     strokeWeight(2);
     fill(cInt);
     line(x,plot_y1,x,plot_y2);
     if(countInt==0){text("Military Intervention:",width-200, 370);}     
     text(milInt.getDataAt(i,3)+"/"+ milInt.getDataAt(i,4)+"/" +floor(intYear), width- 200,  390);
     countInt++;
   }
 }  
} 



void drawPartyChange(int mun, int sta, color cInt)
{
 int i;
 String partya, partyb;
 float intYear,x;
   

 for(i = 2; i < 4; i++)
 { 
   partyb=ppartycMun.getDataAt(mun,i);
   partya=ppartycMun.getDataAt(mun,i+1); // only here we have 0's
   if(partya.equals(0) || partya.equals("NOT YET"))
   {
     println("No data");
   }else
   if(partya.equals(partyb)) //does this work
   {
       println("No party change");
   }else
   {
   
     intYear= ppartycS.getFloatAt(state,i+1);
     x= map(intYear, xlims[0], xlims[1], plot_x1, plot_x2); 
     stroke(cInt);
     fill(cInt);
     strokeWeight(2);
     line(x,plot_y1,x,plot_y2);
     textSize(10);
     text("Party change:",width-200, 330);
     text(partyb + " to " + partya, width- 200,  350);
     break;
   
   }
   
 }  
} 

void verticalText (String t, int x, int y) {
  pushMatrix(); // contain text transformation
  rotate(radians(270));
  // because we rotate 270, x becomes -y, y becomes x. think cartesian coordinates
  text(t, x, y);  
  popMatrix();
}



// determines whether x and y are within a radius `rad`
// of data[2] and data[3] respectively
boolean near (float year_num, float hom , float x, float y, int rad) {
  boolean isnear = false;
  if ((y > plot_y1) && (y < plot_y2) && (x > plot_x1) && (x < plot_x2))
  {
      float distpoint = sqrt(pow(year_num- x,2)+pow(hom-y,2));  
      if( distpoint < rad) {
          isnear = true;
      }
    }  
  return isnear;
}





// truncating a number to three decimal places
float truncate(float x, float dec){
  float aux=pow(10,dec);
  if ( x > 0 )
    return float(floor(x * aux))/aux;
  else
    return float(ceil(x * aux))/aux;
}

void keyPressed () {
  if (key == CODED) {
    switch (keyCode) {
    case LEFT:
      // maybe I should make 2486 a golbal variable for nMun
        if(munIndex>0){
          munIndex=(munIndex-1)%2456;
        }
        else {munIndex=2455;}  
        state = floor(popul.getFloatAt(munIndex,0)/1000)-1;
        break; 
    case RIGHT: 
      if(munIndex<2456){
        munIndex=(munIndex+1)%2456;
       }
        else {munIndex=0;}
      state = floor(popul.getFloatAt(munIndex,0)/1000)-1;
      break;
    }
  } 
}


