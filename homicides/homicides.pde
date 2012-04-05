/* Author: Valeria Espinosa
   Date: April 3, 2012
   CS 171 
   Homicide Rate in Mexico (1990-2010)
*/


Collect table, popul,Stable, Spopul;
int bg_color = 225;
int plot_x1, plot_x2, plot_y1, plot_y2;
float plot_width, plot_height,xrange, yrange;
float x_step_size,y_step_size;





float[] point_size;
float[] or_size;
float[][] datapoints,statepoints;
float[] munHR,stateHR;
boolean click = false;
int extra=30; // for the axis not to start with the lowest value


// Some Fonts
PFont titlefont;
PFont font;
PFont legendfont;


// municipality index to plot (default should be the national one)
boolean all=true;
int munIndex=0;
int state;

// Years considered
int[] years;


// current ranges
float[] ylims={0.0,20};
float[] xlims={1989,2011};
int steps = 22;

//define the colors to use (this should be linked to the Cartel and the )
color[] seriesCols={#4169E1, #87CEFA,#C0C0C0};

void setup() {
  size(1100, 600);
   table = new Collect("../Data/MunHomicides.tsv");
   popul = new Collect("../Data/MunPopulationEst.tsv");
   Stable = new Collect("../Data/StateHomicides.tsv");
   Spopul = new Collect("../Data/StatePop.tsv");
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
}

void draw() {
  background(bg_color);
  
  /*
  | IMPORTANT:
  | the next two lines determine the dimensions of the plot area
  */
  int w = (int) (width * 0.9);
  int h = (int) (height * 0.7);
  
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
  drawLegend();
  //drawZoomLegend();
  inspectDataPoints(munHR, datapoints,false);
  inspectDataPoints(stateHR, statepoints,true);
  
  // the choice of x and y change ()
//  int deltas =15;
//  if(mouseX >= width/2 -deltas && mouseX <= width/2 +deltas&& mouseY > plot_y2 && mouseY< plot_y2+50 && click == true){
//    cycle_axis('X');
//    xlims[0] = 0;
//    xlims[1]= ceil(table.columnMax(table.fieldIndex(axes[axis_choice[0]][1])));
//    ylims[0] = 0;
//    ylims[1]= ceil(table.columnMax(table.fieldIndex(axes[axis_choice[1]][1])));
//    click= false;
//  }
//  if( mouseX <=  plot_x1 && mouseY>=plot_y1+150 && mouseY<=plot_y1+300 && click == true){
//     cycle_axis('Y');
//     ylims[1]= ceil(table.columnMax(table.fieldIndex(axes[axis_choice[1]][1])));
//     ylims[0] = 0;
//     xlims[0] = 0;
//     xlims[1]= ceil(table.columnMax(table.fieldIndex(axes[axis_choice[0]][1])));
//     click= false;
//  } 
//  if(mouseX>plot_x2 && mouseY>=plot_y2-170&&  mouseY<=plot_y2 && click==true){
//     cycle_axis('S');
//     click=false;
//  }  
  
}

/*
| IMPORTANT:
| alter this method to change positioning of plot area
*/
void drawPlotArea(int w, int h) {
  plot_x1 = (width - w) ;
  plot_y1 = (height - h) / 2;
  plot_x2 = plot_x1 + 18*w/20;
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
  fill(0);
  textAlign(CENTER);
  textSize(32);
  text(t, width/2, 3*plot_y1/5);

}

void drawAxesLabels (String x_axis, String y_axis) {
  textSize(16);
  
  // axis labels are centered between adjacent edge of plot area and window
  text(x_axis, width/2, plot_y2+50);
  verticalText(y_axis, -height/2, plot_x1/2);
  textSize(10);
  verticalText("per 100000 inhabitants ", -height/2, plot_x1/2+15);

  
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
  int state = floor(popul.getFloatAt(mun,0)/1000)-1;

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
   datapoints[i][0] = table.getFloatAt(mun, col);
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
//      //rect(mouseX + 50, mouseY ,textWidth(table.getDataAt(i, table.fieldIndex("name")))+10,60);
//      rect(mouseX + 50, mouseY, 1.5*textWidth(popul.getDataAt(munIndex, 1)),60);
      stroke(0); fill(0); textAlign(CENTER);textSize(15);
      
      if(stateInd)
          text(Spopul.getDataAt(state, 1), mouseX + 15, mouseY - 60);
      else
           text(popul.getDataAt(munIndex, 1), mouseX + 15, mouseY - 60);

      fill(0); textSize(13);
      text("estimated population " + years[i]+" : " + matrix[i][1], mouseX + 27, mouseY-35 );
      text("number of homicides " + years[i]+" : " + floor(matrix[i][0]), mouseX + 10, mouseY-15 );
      //text(axes[axis_choice[1]][1] + ": " +truncate(table.getFloatAt(munIndex,i+2),0), mouseX + 30, mouseY+15 );
      //text(axes[size_choice][1] + ": " +or_size[i], mouseX + 30, mouseY+25 );
      // should we display the specific information related to this plot?  
    }
  }
}


//void mouseClicked() {
//  click = true;
//} 


//// Size legend of time series
void drawLegend(){
  
  textAlign(LEFT);
  stroke(0); fill(0);
  textSize(12);
  text(popul.getDataAt(munIndex, 1), width -130, plot_y2+40);
  text(Spopul.getDataAt(state, 1), width -130, plot_y2+60);
  
 //Lenged for size
  for (int i = 0; i < 2; i++)
  {
    fill(seriesCols[i]);
    stroke(seriesCols[i]);
    ellipse(width -150,  plot_y2+35+20*i, 6, 6);
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

void keyPressed () {
  if (key == CODED) {
    switch (keyCode) {
    case LEFT:
      // maybe I should make 2486 a golbal variable for nMun
        munIndex=(munIndex-1)%2486;
        state = floor(popul.getFloatAt(munIndex,0)/1000)-1;
        break;
    case RIGHT: 
      munIndex=(munIndex+1)%2486;
      state = floor(popul.getFloatAt(munIndex,0)/1000)-1;
      break;
    }
  } 
}

