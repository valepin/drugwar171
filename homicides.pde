/* Author: Valeria Espinosa
   Date: April 3, 2012
   CS 171 
   Homicide Rate in Mexico (1990-2010)
*/


Collect mtable, popul,Stable, Spopul, milInt,cartel07,cartel10,ppartycMun,ppartycS;
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
float[][] datapoints,statepoints,cartelpoints,nationalpoints, allCHompoints,allCPoppoints;
float[] munHR,stateHR,cartelHR,nationalHR;
char cartS;
boolean click = false,plotAllC=false;
int extra=30; // for the axis not to start with the lowest value
  int cartInt,rowCart =0,cartIndl =0, cartIndd=0;


// Some Fonts
PFont titlefont;
PFont font;
PFont legendfont;


// municipality index to plot (default should be the national one)
boolean all=true;
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
  {"Pacifico Sur and Sinaloa ","s"},
  {"Acapulco and Pacifico Sur ","a"},
  {"Gulf and Los Zetas","z"},
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
{#FFB700,#FFEA00 ,#A9A9A9},
{#708090,#D3D3D3,#A9A9A9},
{#66CDAA, #AFEEEE,#708090}

};
//#F0E68C(khaki), #FFFF00  (bright yellow)


RadioButton r;

void setupV() {
  // size(1100, 600);
   mtable = new Collect("MunHomicides.tsv");
   popul = new Collect("MunPopulationEst.tsv");
   Stable = new Collect("StateHomicides.tsv");
   Spopul = new Collect("StatePop.tsv");
   milInt = new Collect("InterventionDataNexos2011.tsv");
   cartel07 = new Collect("cartel2007HR.tsv");
   cartel10 = new Collect("cartel2010HR.tsv");
   ppartycMun = new Collect("CartelIncomeExpensesByMunicipality.tsv");
   ppartycS = new Collect("CartelIncomeExpensesState.tsv");
   years = new int[mtable.numCols];
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
  r = controlP5.addRadioButton("radioButton",joeyWidth-20, 58);
  r.setColorForeground(color(bg_color));
  r.setColorValue(color(200));
  r.setColorActive(color(255));
  r.setColorLabel(color(255));
   r.setSize(15,15);
 r.setItemsPerRow(2);
  r.setSpacingColumn(40);


  addToRadioButton(r,"2007",0);
  addToRadioButton(r,"2010",1);
  
}


void addToRadioButton(RadioButton theRadioButton, String theName, int theValue ) {
  Toggle t = theRadioButton.addItem(theName,theValue);
 // t.captionLabel().setColorBackground(color(80));
//  t.captionLabel().style().movePadding(2,0,-1,2);
//  t.captionLabel().style().moveMargin(-2,0,0,-3);
//  t.captionLabel().style().backgroundWidth = 46;
}


void controlEvent(ControlEvent theEvent) {
  print("got an event from "+theEvent.group().name()+"\t");
  for(int i=0;i<theEvent.group().arrayValue().length;i++) {
    print(int(theEvent.group().arrayValue()[i]));
  }
  if(int(theEvent.group().value())==1){cart2010 = true;}
   else{cart2010 = false;}   
}


void drawV() {
  
//       rectMode(CORNERS);
//  stroke(250);
//  fill(250);
//  rect(0,  barHeight, joeyWidth, barHeight+ joeyHeight);
  
//       rectMode(CORNERS);
//  stroke(250);
//  fill(250);
//  rect(joeyWidth, barHeight+valeriaHeight,joeyWidth+ anuvWidth,  barHeight+valeriaHeight+anuvHeight);
//  
    //label button
 stroke(250); fill(250);  textFont(legendfont);textAlign(CENTER);textSize(11);
  text("Year of Stratfor Cartel Sketch ",joeyWidth+30,50);
  
  /*
  | IMPORTANT:
  | the next two lines determine the dimensions of the plot area
  */
  int w = int (valeriaWidth);
  int h = int (valeriaHeight);
  
  strokeWeight(1);
  
  state = floor(popul.getFloatAt(selectedMuni,0)/1000)-1;
  
  /*
  | Start Drawing here.
  | Change these methods if necessary, clearly
  | commenting where any changes have been made
  */
  drawPlotArea(w, h);
 
  drawTitle(popul.getDataAt(selectedMuni, 1)+", "+ Spopul.getDataAt(state, 1) );
    drawAxesLabels("year", "homicide rate");
    drawGridlines();
   if(hoverMuni)
   {
      plotDataPoints(selectedMuni);
      drawLegend();
      drawIntervention(selectedMuni,state,#6B8E23); //#808000
      drawPartyChange(selectedMuni,state,#BC8F8F);
      //drawZoomLegend();
      inspectDataPoints(munHR, datapoints,'M');
      inspectDataPoints(stateHR, statepoints,'S');
      inspectDataPoints(nationalHR, nationalpoints,'N');
      inspectDataPoints(cartelHR, cartelpoints,'C');
   }else
        drawAllCartels();
   
  
}

/*
| IMPORTANT:
| alter this method to change positioning of plot area
*/
void drawPlotArea(int w, int h) {
  plot_x1 = joeyWidth+80 ;
  plot_y1 =3*barHeight/2;
  plot_x2 = width-10;
  plot_y2 = plot_y1 + 7*h/10;
  rectMode(CORNERS);
  stroke(250);
  fill(250);
  rect(plot_x1, plot_y1, plot_x2, plot_y2);

  // set dimensions for later use
  plot_width = plot_x2 - plot_x1;
  plot_height = plot_y2 - plot_y1;
  
}

void drawTitle (String t) {
   //textFont(titlefont);
  fill(fill_color);
  textAlign(CENTER);
  textSize(32);
  text(t, joeyWidth+*valeriaWidth/7, 30);

}

void drawAxesLabels (String x_axis, String y_axis) {
  textSize(14);
  
  // axis labels are centered between adjacent edge of plot area and window
  text(x_axis, joeyWidth+valeriaWidth-30, plot_y2+40);
  verticalText(y_axis, -height/4, joeyWidth+15);
  textSize(10);
  verticalText("per 100000 inhabitants ", -height/4,joeyWidth+30);

 
}



// draw grid lines
void drawGridlines () { 
  //define the ranges accordingly
  // these should be in the original scale
  xrange =  xlims[1]-xlims[0];
  yrange = ylims[1]-ylims[0];
  
 int stepsy =10;

  // steps defined at top of document, default 10
  float x_step_size = plot_width / steps;
  float y_step_size = plot_height / stepsy;

      stroke(255);
      textSize(10);
  // x gridlines
  for (int n =1; n <= steps; n++) {

    float x = plot_x1 + n * x_step_size;
  
    // draw grid lines
    line(x, plot_y1, x, plot_y2);
    //text(,x, plot_y2);

    // label grid lines as well
    
    if(n>0 & n<steps)
    verticalText(nf(years[n-1],0), -(plot_y2+15), x+5);
  }
  // y grid lines
   for (int n =1; n <= 10; n++) {

    float y = plot_y2 - n * y_step_size;
    

    // draw grid lines
    line(plot_x1, y, plot_x2, y);
    //text(,x, plot_y2);

    // label grid lines as well
    textSize(10);
    text(String.format("%.2f",ylims[0]+(n * yrange)/stepsy), plot_x1-20,y);
     
      
  }
  
     text(String.format("%.2f",ylims[0]), plot_x1-20, plot_y2 );
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
  defineColors(cartS);
  
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
    // if it is zero get the state average
    if(datapoints[i][1] ==0){ 
      datapoints[i][1] =  Spopul.getFloatAt(state,i+2);
    }
   datapoints[i][0] = mtable.getFloatAt(mun, col);
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



void drawAllCartels(){
  
  int nrows =cartel10.numRows/2-1, ncols =popul.numCols-2;
  allCHompoints = new float[nrows][ncols];
  allCPoppoints = new float[nrows][ncols];
  nationalpoints = new float[ncols][2];
  nationalHR = new float[ncols];
  cartelHR = new float[ncols];
  int i,j;
  float x,y,pop;
  
    

    // i is a counter over the columns (years)
  for (i = 0; i < nationalpoints.length; i++) {
      //national
   nationalpoints[i][1] =  cartel10.getFloatAt(23,i+1);
   nationalpoints[i][0] = cartel10.getFloatAt(22,i+1); 
   nationalHR[i] = nationalpoints[i][0]/nationalpoints[i][1]*100000;
  }
    float mm = max(nationalHR);  
    // load homicides and population for each Cartel
  for (j=0; j < 11;j++){  
    for(i=0; i< nationalpoints.length; i++){
       //get cartel info by year
     if(cart2010)
     {  ylims[1]=290;
       allCPoppoints[j][i] =  cartel10.getFloatAt(2*j+1,i+1);
        allCHompoints[j][i] = cartel10.getFloatAt(2*j,i+1); 
       cartelHR[i] = allCHompoints[j][i]/max(allCPoppoints[j][i],1)*100000;
        cartS = cartel10.getCharAt(2*j,0);
                  println(cartS);
                            println(cartelHR[i]);
     }else
    {
      ylims[1]=80;
       allCPoppoints[j][i] =  cartel07.getFloatAt(2*j+1,i+1);
       allCHompoints[j][i] = cartel07.getFloatAt(2*j,i+1); 
       cartelHR[i] = allCHompoints[j][i]/max(allCPoppoints[j][i],1)*100000;
    }
       drawSpline(nationalHR,0);
    drawPoints(nationalHR,0);
      //define the colors

      //plot
    } 
    cartS = cartel07.getCharAt(2*j,0);
    defineColors(cartS);  
      drawSpline(cartelHR,seriesCols[cartIndl][0] );  
     drawPoints(cartelHR,seriesCols[cartIndd][0] );   
  }



}



void defineColors(char cartS){
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
 // beginShape();   
  for (i = 1; i < vector.length; i++) {
 
    x =  map(years[i], xlims[0], xlims[1], plot_x1, plot_x2);
    y =  map(vector[i], ylims[0], ylims[1], plot_y2, plot_y1);
//   if(vector[i]==0 && prev0)
//   { 
     x_p =  map(years[i-1], xlims[0], xlims[1], plot_x1, plot_x2);
     y_p =  map(vector[i-1], ylims[0], ylims[1], plot_y2, plot_y1);
     line(x_p,y_p,x,y);
     // to make the previous point the last control point?
//     curveVertex(x_p,y_p);
//     if(i<vector.length-1 && vector[i+1]>0)
//     {
//       cont_point=true;
//     }
//   }else
//   {
//     curveVertex(x,y);
//       prev0= false;
//   }
   
    /* is also the start point of curve is also the first control point, and
     is also the start point of curve is also the first control point*/
//    if(cont_point || i == (vector.length-1) )
//    {
//      curveVertex(x,y);
//      cont_point=false;
//    }
//    if(vector[i]==0)
//      prev0=true;    
  }
 // endShape(); 
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
//      //rect(mouseX + 50, mouseY ,textWidth(mtable.getDataAt(i, mtable.fieldIndex("name")))+10,60);
//      rect(mouseX + 50, mouseY, 1.5*textWidth(popul.getDataAt(selectedMuni, 1)),60);
     stroke(bg_color);
     line(plot_x1,y,plot_x2+10,y);
      stroke(250); fill(250); textAlign(CENTER);textSize(12); 
//      switch(type){
//      case 'S':
//          text(Spopul.getDataAt(state, 1), width- 350, barHeight+valeriaHeight-35);  //
//          text(" ("+ years[i]+")", width- 350,  barHeight+valeriaHeight-35);
//          break;
//      case 'M':    
//           text(popul.getDataAt(selectedMuni, 1)+" ("+years[i]+")",width-350, barHeight+valeriaHeight-35);
//            text(" ("+ years[i]+")", width- 350,  barHeight+valeriaHeight-35);
//           break;
//      case 'N':    
//           text("National ("+ years[i]+")",width-350, plot_y2+10);
//           text(" ("+ years[i]+")", width- 350,  barHeight+valeriaHeight-35);
//           break;
//      case 'C':
//           text(cartels[rowCart][0]+" ("+years[i]+")",width-350, barHeight+valeriaHeight-35);
            text(" ("+ years[i]+")", width- 350,  barHeight+valeriaHeight-40);
//           break;
//      }
      textFont(legendfont);
      fill(250); textSize(12);
      textAlign(LEFT);
      text("population: " + floor(matrix[i][1]), width- 420, barHeight+valeriaHeight-25);
      text("homicides :       " + floor(matrix[i][0]),width- 420,barHeight+valeriaHeight-10  );

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
  textSize(12);

   text("National", joeyWidth +45*valeriaWidth/100, barHeight+valeriaHeight-30);
    text(Spopul.getDataAt(state, 1), joeyWidth +45*valeriaWidth/100, barHeight+valeriaHeight-10); 
      text(popul.getDataAt(selectedMuni, 1), joeyWidth +7*valeriaWidth/10, barHeight+valeriaHeight-30); 
   text(cartels[rowCart][0], joeyWidth +7*valeriaWidth/10, barHeight+valeriaHeight-10);



 //Lenged for size
  for (int i = 1; i >=0; i--)
  {
    fill(seriesCols[cartIndl][i]);
    stroke(seriesCols[cartIndd][i]);
    ellipse(joeyWidth +7*valeriaWidth/10-10,  barHeight+valeriaHeight-15-20*i, 6, 6);
  }
  
     fill(seriesCols[cartIndl][2]);
    stroke(seriesCols[cartIndd][2]);
   ellipse(joeyWidth +45*valeriaWidth/100-10,  barHeight+valeriaHeight-35, 6, 6); 
  stroke(0);
  fill(0);
  ellipse(joeyWidth +45*valeriaWidth/100-10,  barHeight+valeriaHeight-15, 6, 6);

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
   if(clave==popul.getFloatAt(mun,0))
   {
     intYear= milInt.getFloatAt(i,5);
     x= map(intYear, xlims[0], xlims[1], plot_x1, plot_x2); 
       
     println(x);
     stroke(cInt);
     strokeWeight(2);
     fill(cInt);
     line(x,plot_y1,x,plot_y2);
     if(countInt==0){text("Military Intervention:",width-200, plot_y1-25);}     
     text(milInt.getDataAt(i,3)+"/"+ milInt.getDataAt(i,4)+"/" +floor(intYear), width- 190,  plot_y1- 10);
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
     //text(,width-250, 35);
     text("Party change: "+ partyb + " to " + partya, width- 400, plot_y1-25);
      textSize(8); 
      text("(PAN, PAN-PRD, PRD, PRI, Other)",width-390, plot_y1-10);
     break;
   
   }
   
 }  
} 

void verticalText (String t, float x, float y) {
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
  println(aux);
  if ( x > 0 )
    return round(floor(x * aux))/aux;
  else
    return round(ceil(x * aux))/aux;
}

// void keyPressed () {
//   if (key == CODED) {
//     switch (keyCode) {
//     case LEFT:
//       // maybe I should make 2486 a golbal variable for nMun
//         if(selectedMuni>0){
//           selectedMuni=(selectedMuni-1)%2456;
//         }
//         else {selectedMuni=2455;}  
//         state = floor(popul.getFloatAt(selectedMuni,0)/1000)-1;
//         plotAllC=false;
//         break; 
//     case RIGHT: 
//       if(selectedMuni<2455){
//         selectedMuni=(selectedMuni+1)%2456;
//        }
//         else {selectedMuni=0;}
//       state = floor(popul.getFloatAt(selectedMuni,0)/1000)-1;
//       plotAllC=false;
//       break;
//       case 's': 
//       // Go to ciudad Juárez (which has received a special atention)
//         selectedMuni=234;
//        plotAllC=true;
//       break;        
//     }
//   } 
// }


