Collect table;

import controlP5.*;

ControlP5 cp5;
int myColor = color(0,0,0);

int sliderValue = 100;
int sliderTicks1 = 100;
int sliderTicks2 = 30;
Slider abc;

//screen resolution
int width3 = 1440;
int height3 = 900;
int width2 = 700;
int height2 = 400;

float screen_width = width3*.5;
float screen_height = height3 *.5;

int background_color = 230;

float shifted = screen_height*.9;

int dot_size = 10;

//intialize
int var_year = 0;

float sum_T = 0;
float sum_H = 0;
float sum_E = 0;

float variance_T, variance_H, variance_E;

float average_T, average_H, average_E;

float average_T_interval, average_H_interval, average_E_interval;

float x_screen_interval, y_screen_interval;


float sd_T, sd_H, sd_E;

float multiplier_T, multiplier_H, multiplier_E;

float average_multiplier_T, average_multiplier_H, average_multiplier_E;

String [] names;

boolean hover = false;

int quadrant;

//*********************************************************************************************************************************
    Collect table2, popul,Stable, Spopul;
    int bg_color = 225;
    int plot_x1, plot_x2, plot_y1, plot_y2;
    float plot_width2, plot_height2,xrange, yrange;
    float x_step_size,y_step_size;
    float[] point_size;
    float[] or_size;
    float[][] datapoints,statepoints;
    float[] munHR,stateHR;
    boolean click = false;
  // Some Fonts
  PFont titlefont;
  PFont font;
  PFont legendfont;


  // municipality index to plot (default should be the national one)
  boolean all=true;
  int munIndex=100;
  int state;

  // Years considered
  int[] years;


  // current ranges
  float[] ylims={0.0,20};
  float[] xlims={1989,2011};
  int steps = 22;

  //define the colors to use (this should be linked to the Cartel and the )
  color[] seriesCols={#4169E1, #87CEFA,#C0C0C0};int extra=30; // for the axis not to start with the lowest value
//***********************************************************************************************************************************

void setup() {
    size(int(screen_width)*2,int(screen_height)*2);
    background(background_color);

    

    
    
    table = new Collect("Anuv_Data.tsv");
    calculate();
    names = new String[table.numRows];

 
 
 
 
 
  noStroke();
  cp5 = new ControlP5(this);
  cp5.addSlider("slider")
     .setPosition(screen_width*.2,screen_height-20+shifted)
     //.setwidth(400)
     .setRange(1990,2010)
     .setValue(128)
     .setNumberOfTickMarks(21)
     .showTickMarks(false)
     .setSliderMode(Slider.FLEXIBLE);

//*****************************************************************************************************************
  table2 = new Collect("../Data/MunHomicides.tsv");
   popul = new Collect("../Data/MunPopulationEst.tsv");
   Stable = new Collect("../Data/StateHomicides.tsv");
   Spopul = new Collect("../Data/StatePop.tsv");
   years = new int[table2.numCols];
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
//******************************************************************************************************************************




}


void calculate() {

  for(int i=1; i<table.numRows; i++){
  sum_T = sum_T + table.getFloatAt(i,3+4*var_year);
  sum_H = sum_H + table.getFloatAt(i,4+4*var_year);
  sum_E = sum_E + table.getFloatAt(i,1+4*var_year);   
  }

  //average
  average_T = sum_T/(table.numRows-1);
  average_H = sum_H/(table.numRows-1);
  average_E = sum_E/(table.numRows-1);

  
  //calculate intervals from average for zooming
  average_T_interval = average_T/10;
  average_H_interval = average_H/10;
  average_E_interval = average_E/10;
  
  //standard dev
  for(int i=1; i<table.numRows; i++){
    variance_T = variance_T + sq(table.getFloatAt(i,3+4*var_year)-average_T);
    variance_H = variance_H + sq(table.getFloatAt(i,4+4*var_year)-average_H);
    variance_E = variance_E + sq(table.getFloatAt(i,1+4*var_year)-average_E);
  }

  sd_T = sqrt(variance_T/(table.numRows-1));
  sd_H = sqrt(variance_H/(table.numRows-1));
  sd_E = sqrt(variance_E/(table.numRows-1));
}


void draw() {
  background(background_color);

  draw_scatter();
  drawTitle(var_year+1990);
  hoverOverDot();
  /*
  | IMPORTANT:
  | the next two lines determine the dimensions of the plot area
  */
  int w = (int) (width2 * 0.9);
  int h = (int) (height2 * 0.7);
  
  state = floor(popul.getFloatAt(munIndex,0)/1000);
  
  /*
  | Start Drawing here.
  | Change these methods if necessary, clearly
  | commenting where any changes have been made
  */
  drawPlotArea(w, h);
 
//************************************************************************************************************************
  drawTitle(popul.getDataAt(munIndex, 1)+", "+ Spopul.getDataAt(state, 1) );
    drawAxesLabels("year", "homicide rate");
  drawGridlines();
  plotDataPoints(munIndex);
  drawLegend();
  //drawZoomLegend();
  inspectDataPoints(munHR, datapoints,false);
  inspectDataPoints(stateHR, statepoints,true);
  
  // the choice of x and y change ()
//  int deltas =15;
//  if(mouseX >= width2/2 -deltas && mouseX <= width2/2 +deltas&& mouseY > plot_y2 && mouseY< plot_y2+50 && click == true){
//    cycle_axis('X');
//    xlims[0] = 0;
//    xlims[1]= ceil(table2.columnMax(table2.fieldIndex(axes[axis_choice[0]][1])));
//    ylims[0] = 0;
//    ylims[1]= ceil(table2.columnMax(table2.fieldIndex(axes[axis_choice[1]][1])));
//    click= false;
//  }
//  if( mouseX <=  plot_x1 && mouseY>=plot_y1+150 && mouseY<=plot_y1+300 && click == true){
//     cycle_axis('Y');
//     ylims[1]= ceil(table2.columnMax(table2.fieldIndex(axes[axis_choice[1]][1])));
//     ylims[0] = 0;
//     xlims[0] = 0;
//     xlims[1]= ceil(table2.columnMax(table2.fieldIndex(axes[axis_choice[0]][1])));
//     click= false;
//  } 
//  if(mouseX>plot_x2 && mouseY>=plot_y2-170&&  mouseY<=plot_y2 && click==true){
//     cycle_axis('S');
//     click=false;
//  }  
//**********************************************************************************************************************************  

}

void draw_scatter(){
  
  //white background
  fill(250);
  noStroke();
  rect(screen_width*.1,screen_height*.05+shifted,screen_width*.9-10, screen_height*.9+shifted);
  resetFill();

  //data maximums
  //E=expenditure, T= total, H= homocides
  float max_E = 3.0E10;
  float max_T = 359.;
  float max_H = 3000;

  float interval_E = max_E/10;
  float interval_T = max_T/10;
  float interval_H = max_H/10;
  
  resetStroke();
  //x-axis
  line(screen_width*.1,screen_height*.9+shifted,screen_width*.9-10,screen_height*.9+shifted);

  resetFont();

  //label
  text("Cartel Expenditures", screen_width*.9, screen_height*.93+shifted);
  
  //x-axis tick marks and labels
 
  x_screen_interval = (screen_width*.85)/10;
  for(int i=3; i<11;i++) {
    line(screen_width*.1+x_screen_interval*(i-2), screen_height*.9-2+shifted, screen_width*.1+x_screen_interval*(i-2), screen_height*.9+2+shifted); 
    
    //vertical labels
    pushMatrix();
    translate(screen_width*.1+x_screen_interval*(i-2), screen_height*.9+12+shifted);
      text("10E"+(i-1),0,2);
    popMatrix();

}
  //y-axis
  line(screen_width*.1, screen_height*.05+shifted, screen_width*.1, screen_height*.9+shifted);

  //label
  pushMatrix();
  translate(screen_width*.03, screen_height*.5+shifted);
  rotate(3*PI/2);
  text("Homocides",0,0);
  popMatrix();
  
  
  //y-axis tick marks
  y_screen_interval = (screen_height*.85)/4;
  for(int i=1; i<5;i++) {  
    line(screen_width*.1-2, screen_height*.05+y_screen_interval*i+shifted, screen_width*.1+2, screen_height*.05+y_screen_interval*i+shifted); 
    text("10E"+(i-1), screen_width*.1-25, screen_height*.9-y_screen_interval*i+2+shifted);

  }
 
 
 
 
 
 
  multiplier_T = (screen_width*.85)/max_T;
  multiplier_H = (screen_height*.85)/max_H;
  multiplier_E = (screen_width*.85)/max_E;

  average_multiplier_T = (screen_width*.85)/average_T;
  average_multiplier_H = (screen_height*.85)/average_H;
  average_multiplier_E = (screen_width*.85)/average_E; 
  

  
  for(int i=1; i<table.numRows; i++){
    noStroke();

    //save municipality names in array
    names[i] = table.getDataAt(i,0);
  
 
    //color based on standard deviation of E from mean    
    //if(table.getFloatAt(i,3+4*var_year)> average_T + 4*sd_T)
    //  fill(250,0,0);
    //else if(table.getFloatAt(i,3+4*var_year)> average_T + 2*sd_T)
    //  fill(200,100,0);






    //draw dot
    fill(100,50); 
    ellipse(screen_width*.1+(log10(table.getFloatAt(i,1+4*var_year))-3)*x_screen_interval, screen_height*.9-log10(table.getFloatAt(i,4+4*var_year))*y_screen_interval+shifted,dot_size,dot_size);
   
   
    stroke(0);
  }
  
//TEST
fill(0,0,250);
ellipse(screen_width*.1+(log10(table.getFloatAt(457,1+4*var_year))-3)*x_screen_interval, screen_height*.9-log10(table.getFloatAt(457,4+4*var_year))*y_screen_interval+shifted,dot_size,dot_size);
   




}

void resetStroke() {
  strokeWeight(1);
  stroke(0);
}


void resetFill() {
 fill(0); 
}



void drawTitle (int t) {
  fill(0);
  textAlign(CENTER);
  textSize(15);
  fill(100,100,250);
  text(t, screen_width/2, screen_height*.03+shifted);
  resetFill();
}


void hoverOverDot() {
hover = false;
for(int i = 0; i<table.numRows-1; i++){
  if(distance(mouseX,mouseY,screen_width*.1+(log10(table.getFloatAt(i,1+4*var_year))-3)*x_screen_interval,screen_height*.9-log10(table.getFloatAt(i,4+4*var_year))*y_screen_interval+shifted)<5 && i != 0 && hover==false){
    hover = true;
    textSize(20);
    fill(100,100,250);
    text(names[i], 500, 60);
    resetFill();
    }
  

}
}







float distance(float x1,float y1,float x2,float y2){
  float d = sqrt(sq(x2-x1)+sq(y2-y1));
  return d;
}


float log10 (float x) {
  return (log(x) / log(10));
}

void keyPressed() {
  
    //reset
    sum_T = 0;
    sum_H = 0;
    sum_E = 0;
    variance_T = 0;
    variance_H = 0;
    variance_E = 0;
  
    if(key == CODED) {
      if (keyCode == RIGHT && var_year<20){ 
        var_year = var_year + 1;
           calculate();}
      else if (keyCode == LEFT && var_year>0){
         var_year = var_year -1;  
          calculate();}
    }

}


void slider(float theColor) {

  myColor = color(theColor);
  int new_year = int(theColor) - 1990;
  if(var_year != new_year){
  var_year = new_year;
    sum_T = 0;
    sum_H = 0;
    sum_E = 0;
    variance_T = 0;
    variance_H = 0;
    variance_E = 0;
    calculate();
}
}


void resetFont() {
 textSize(10);
 textAlign(CENTER); 
}


//**********************************************************************
void drawPlotArea(int w, int h) {
  plot_x1 = (width2 - w) ;
  plot_y1 = (height2 - h) / 2;
  plot_x2 = plot_x1 + 18*w/20;
  plot_y2 = plot_y1 + h;
  rectMode(CORNERS);
  stroke(250);
  fill(250);
  rect(plot_x1, plot_y1, plot_x2, plot_y2);

  // set dimensions for later use
  plot_width2 = plot_x2 - plot_x1;
  plot_height2 = plot_y2 - plot_y1;
  
}

void drawTitle (String t) {
  fill(0);
  textAlign(CENTER);
  textSize(32);
  text(t, width2/2, 3*plot_y1/5);

}

void drawAxesLabels (String x_axis, String y_axis) {
  textSize(16);
  
  // axis labels are centered between adjacent edge of plot area and window
  //text(x_axis, width2/2, plot_y2+50);
  verticalText(y_axis, -height2/2, plot_x1/2);
  textSize(10);
  verticalText("per 100000 inhabitants ", -height2/2, plot_x1/2+15);

  
  // record areas where axes lie
//    textSize(10);
//  x_axis_area = new float[] { (height2+plot_y2)/2-7, (height2+plot_y2)/2+7 };
//  y_axis_area = new float[] { plot_x1/2-7, plot_x1/2+7 };
}



// draw grid lines
void drawGridlines () { 
  //define the ranges accordingly
  // these should be in the original scale
  xrange =  xlims[1]-xlims[0];
  yrange = ylims[1]-ylims[0];

  // steps defined at top of document, default 10
  float x_step_size = plot_width2 / steps;
  float y_step_size = plot_height2 /steps;

  for (int n =1; n <= steps; n++) {

    float x = plot_x1 + n * x_step_size;
    float y = plot_y2 - n * y_step_size;

    stroke(225);
    // draw grid lines
    line(plot_x1, y, plot_x2, y);
    line(x, plot_y1, x, plot_y2);
    //text(,x, plot_y2);

    // label grid lines as well
    textSize(10);
    text(truncate(ylims[0]+(n * yrange)/steps,3), plot_x1-15, y );
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
  munHR = new float[ncols];
  stateHR = new float[ncols];
  int i,col;
  float x,y,pop;
  int state = floor(popul.getFloatAt(mun,0)/1000);

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
   datapoints[i][0] = table2.getFloatAt(mun, col);
   munHR[i] = datapoints[i][0]/datapoints[i][1]*100000;
  //state
   statepoints[i][1] =  Spopul.getFloatAt(state,i+2);
   statepoints[i][0] = Stable.getFloatAt(state, col);
   stateHR[i] = statepoints[i][0]/statepoints[i][1]*100000; 
  }
  
  float mm=max(munHR), ms=max(stateHR);
  ylims[1]=max(mm,ms);
  //ylims[0]=min(datapoints);

     /*
    | draw spline
    */
    
    drawSpline(munHR,seriesCols[0] );
    drawSpline(stateHR,seriesCols[1] );

    /*
    | map the coordinates to the plot canvas and plot
    */
    
    
    drawPoints(munHR,seriesCols[0] );
    drawPoints(stateHR,seriesCols[1] );
  // plot datapoints

}

void drawSpline(float[] vector,color colo){
   // using a spline to create a smooth curve over the points
   int i;
   float x,y;
  noFill();
  stroke(colo);
  beginShape();   
  for (i = 0; i < vector.length; i++) {
 
    x =  map(years[i], xlims[0], xlims[1], plot_x1, plot_x2);
    y =  map(vector[i], ylims[0], ylims[1], plot_y2, plot_y1);
    curveVertex(x,y);
    /* is also the start point of curve is also the first control point, and
     is also the start point of curve is also the first control point*/
    if(i==0 || i == (vector.length-1))
    {
      curveVertex(x,y);
    }    
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

void inspectDataPoints (float[] vector, float[][] matrix, boolean stateInd) {
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
//      //rect(mouseX + 50, mouseY ,textwidth2(table2.getDataAt(i, table2.fieldIndex("name")))+10,60);
//      rect(mouseX + 50, mouseY, 1.5*textwidth2(popul.getDataAt(munIndex, 1)),60);
      stroke(0); fill(0); textAlign(CENTER);textSize(15);
      
      if(stateInd)
          text(Spopul.getDataAt(state, 1), mouseX + 15, mouseY - 60);
      else
           text(popul.getDataAt(munIndex, 1), mouseX + 15, mouseY - 60);

      fill(0); textSize(13);
      text("estimated population " + years[i]+" : " + matrix[i][1], mouseX + 27, mouseY-35 );
      text("number of homicides " + years[i]+" : " + floor(matrix[i][0]), mouseX + 10, mouseY-15 );
      //text(axes[axis_choice[1]][1] + ": " +truncate(table2.getFloatAt(munIndex,i+2),0), mouseX + 30, mouseY+15 );
      //text(axes[size_choice][1] + ": " +or_size[i], mouseX + 30, mouseY+25 );
      // should we display the specific information related to this plot?  
    }
  }
resetFont();

}


//void mouseClicked() {
//  click = true;
//} 


//// Size legend of time series
void drawLegend(){
  
  textAlign(LEFT);
  stroke(0); fill(0);
  textSize(12);
  text(popul.getDataAt(munIndex, 1)+ " municipality", width2 -130, plot_y2+40);
  text(Spopul.getDataAt(state, 1)+" state", width2 -130, plot_y2+60);
  
 //Lenged for size
  for (int i = 0; i < 2; i++)
  {
    fill(seriesCols[i]);
    stroke(seriesCols[i]);
    ellipse(width2 -150,  plot_y2+35+20*i, 6, 6);
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
float truncate(float x, int dec){
  float aux=pow(10,dec);
  if ( x > 0 )
    return float(floor(x * aux))/aux;
  else
    return float(ceil(x * aux))/aux;
}









