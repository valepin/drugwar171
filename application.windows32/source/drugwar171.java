import processing.core.*; 
import processing.xml.*; 

import controlP5.*; 
import processing.opengl.*; 
import geomerative.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class drugwar171 extends PApplet {

/* Author: Joseph Kelly, Valeria Espinosa
   Date: April 20, 2012
   CS 171 
   Homicide Rate in Mexico (1990-2010)
*/


int width = 1280;
int height = 750;
int selectedMuni;
int oldMuni = 0;
boolean cart2010=true, allCartTS=true, dispInt=false;
boolean hoverMuni;
int barHeight=75;
int joeyWidth=768;
int joeyHeight=675;
int valeriaHeight=405;
int valeriaWidth=512;
int anuvHeight=270;
int anuvWidth=512;


public void setup() {
  size(1280, 750);
  background(bg_color);
  setupJ();
  setupV();
}


public void draw() {

  hoverMuni=true;
  drawJ();
  if(dispInt){
    resultsplot(selectedMuni);
    //   loveplot("Images/MEloveplot.png");
    loveplot(lovefn);
  }else{
    drawV();
  }
}

class Table {
  String[][] data;
  int rowCount;
  
  
  Table() {
    data = new String[10][10];
  }

  
  Table(String filename) {
    String[] rows = loadStrings(filename);
    data = new String[rows.length][];
    
    for (int i = 0; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }
      
      // split the row on the tabs
      String[] pieces = split(rows[i], TAB);
      // copy to the table array
      data[rowCount] = pieces;
      rowCount++;
      
      // this could be done in one fell swoop via:
      //data[rowCount++] = split(rows[i], TAB);
    }
    // resize the 'data' array as necessary
    data = (String[][]) subset(data, 0, rowCount);
  }


  public int getRowCount() {
    return rowCount;
  }
  
  
  // find a row by its name, returns -1 if no row found
  public int getRowIndex(String name) {
    for (int i = 0; i < rowCount; i++) {
      if (data[i][0].equals(name)) {
        return i;
      }
    }
    println("No row named '" + name + "' was found");
    return -1;
  }
  
  
  public String getRowName(int row) {
    return getString(row, 0);
  }


  public String getString(int rowIndex, int column) {
    return data[rowIndex][column];
  }

  
  public String getString(String rowName, int column) {
    return getString(getRowIndex(rowName), column);
  }

  
  public int getInt(String rowName, int column) {
    return parseInt(getString(rowName, column));
  }

  
  public int getInt(int rowIndex, int column) {
    return parseInt(getString(rowIndex, column));
  }

  
  public float getFloat(String rowName, int column) {
    return parseFloat(getString(rowName, column));
  }

  
  public float getFloat(int rowIndex, int column) {
    return parseFloat(getString(rowIndex, column));
  }
  
  
  public void setRowName(int row, String what) {
    data[row][0] = what;
  }


  public void setString(int rowIndex, int column, String what) {
    data[rowIndex][column] = what;
  }

  
  public void setString(String rowName, int column, String what) {
    int rowIndex = getRowIndex(rowName);
    data[rowIndex][column] = what;
  }

  
  public void setInt(int rowIndex, int column, int what) {
    data[rowIndex][column] = str(what);
  }

  
  public void setInt(String rowName, int column, int what) {
    int rowIndex = getRowIndex(rowName);
    data[rowIndex][column] = str(what);
  }

  
  public void setFloat(int rowIndex, int column, float what) {
    data[rowIndex][column] = str(what);
  }


  public void setFloat(String rowName, int column, float what) {
    int rowIndex = getRowIndex(rowName);
    data[rowIndex][column] = str(what);
  }
  
  
  // Write this table as a TSV file
  public void write(PrintWriter writer) {
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < data[i].length; j++) {
        if (j != 0) {
          writer.print(TAB);
        }
        if (data[i][j] != null) {
          writer.print(data[i][j]);
        }
      }
      writer.println();
    }
    writer.flush();
  }
}

class Button
{
  int x, y;
  int size;
  int basecolor, highlightcolor;
  int currentcolor;
  boolean over = false;
  boolean pressed = false;   

  public void update() 
  {
    if(over()) {
      //currentcolor = highlightcolor;
    } 
    else {
      currentcolor = basecolor;
    }
  }

  public boolean pressed() 
  {
    if(over) {
      locked = true;
      return true;
    } 
    else {
      locked = false;
      return false;
    }    
  }

  public boolean over() 
  { 
    return true; 
  }

  public boolean overRect(int x, int y, int width, int height) 
  {
    if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
      return true;
    } 
    else {
      return false;
    }
  }

  public boolean overCircle(int x, int y, int diameter) 
  {
    float disX = x - mouseX;
    float disY = y - mouseY;
    if(sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
      return true;
    } 
    else {
      return false;
    }
  }

}

class CircleButton extends Button
{ 
  CircleButton(int ix, int iy, int isize, int icolor, int ihighlight) 
  {
    x = ix;
    y = iy;
    size = isize;
    basecolor = icolor;
    highlightcolor = ihighlight;
    currentcolor = basecolor;
  }

  public boolean over() 
  {
    if( overCircle(x, y, size) ) {
      over = true;
      return true;
    } 
    else {
      over = false;
      return false;
    }
  }

  public void display() 
  {
    noStroke();
    fill(currentcolor);
    ellipse(x, y, size, size);
  }
}

class RectButton extends Button
{
  RectButton(int ix, int iy, int isize, int icolor, int ihighlight) 
  {
    x = ix;
    y = iy;
    size = isize;
    basecolor = icolor;
    highlightcolor = ihighlight;
    currentcolor = basecolor;
  }

  public boolean over() 
  {
    if( overRect(x, y, size, size) ) {
      over = true;
      return true;
    } 
    else {
      over = false;
      return false;
    }
  }

  public void display() 
  {
    noStroke();
    fill(currentcolor);
    rect(x, y, size, size);
  }
}

class Collect {
  
  int numRows;
  int numCols;
  String[] colNames;
  
  // data stored as strings by default, convert where necessary
  String[][] data; 
  
  // Assumes properly formed TSV with no row names
  Collect (String filename) {
    
    String[] rows = loadStrings(filename);
    String[] columns = split(rows[0], TAB);
    this.colNames = columns;
    this.numRows = rows.length - 1;
    this.numCols = columns.length;
    this.data = new String[this.numRows][this.numCols];
    
    for (int i = 1; i < rows.length; i++) {
      String[] rowColumns = split(rows[i], TAB);
      this.data[i-1] = rowColumns;
    }
  }
 
 public String[] getColumnNames () { return this.colNames; }
 
 public String[][] getData () { return this.data; }
 
 public String getDataAt (int row, int column) { return this.data[row][column]; }
 
 public char getCharAt (int row, int column) { return this.data[row][column].charAt(0); }
 
 public float getFloatAt(int row, int column) { return parseFloat(this.data[row][column]); }
 
 public int fieldIndex (String field) {
   for (int index = 0; index < this.colNames.length; index++) {
     String column = this.colNames[index];
     if (column.equals(field)) { return index; }
   }
   return -1; // field not found in row names
 }
 
 // Determines the maximum numerical value in a column
 public float columnMax (int column) {
   float cMax = parseFloat(this.data[0][column]);
   for (int i = 0; i < this.data.length; i++) {
     float value = parseFloat(this.data[i][column]);
     if (value > cMax) {
       cMax = value;
     }
   }
   return cMax;
 }
 
 public float columnMin (int column) {
   float cMin = parseFloat(this.data[0][column]);
   for (int i = 0; i < this.data.length; i++) {
     float value = parseFloat(this.data[i][column]);
     if (value < cMin) {
       cMin = value;
     }
   }
   return cMin;
 }
 
}
/* Author: Valeria Espinosa
   Date: April 3, 2012
   Update: Oct 14, 2012
   CS 171 
   Homicide Rate in Mexico (1990-2010)
*/


Collect mtable, popul,Stable, Spopul, milInt,cartel07,cartel10,ppartycMun,ppartycS,results;
int bg_color = 50;
int fill_color=250;
int plot_x1, plot_x2, plot_y1, plot_y2;
float plot_width, plot_height,xrange, yrange;
float x_step_size,y_step_size;
// defining variables for the results plot
float[] effects,stdev;
float regionHRsd, regionHR,Maxim, Minim;
int nReg;




ControlP5 controlP5;

CheckBox checkbox;

int anuvcolor;


float[] point_size;
float[] or_size;
float[][] datapoints,statepoints,cartelpoints,nationalpoints, allCHompoints,allCPoppoints,resPoints;
float[] munHR,stateHR,cartelHR,nationalHR;
char cartS;
boolean click = false;
int extra=30; // for the axis not to start with the lowest value
  int cartInt,rowCart =0,cartIndl =0, cartIndd=0;


// Some Fonts
PFont titlefont;
PFont font;
PFont legendfont;


// municipality index to plot: selected muni (default should be the national one)
boolean all=true;
int state;


// Years considered
int[] years;


// current ranges
float[] ylims={0.0f,20};
float[] xlims={1989,2011};
int steps = 22;

// Getting the Cartel Name
String[][] cartels = {
  {"Gulf Cartel", "G"},
  {"Los Zetas Cartel", "Z"},
  {"Pacifico Sur Cartel", "P"},
  {"La Familia Michoacana", "F"},
  {"Cartel de Ju\u00e1rez", "J"},
  {"Sinaloa Cartel","S"},
  {"Tijuana Cartel","T"},
  {"Not Specified", "N"},
  {"In Dispute", "D"},
  {"Pacifico Sur and Sinaloa ","s"},
  {"Acapulco and Pacifico Sur ","a"},
  {"Gulf and Los Zetas","z"},

};

/*define the colors to use (this should be linked to the Cartel and the )
purple, red,blue pink, orange,green,yellow,gray? brown,cyan = Acapulco Cartel */
int[][] seriesCols={
{0xff8B4513,0xffCd853F ,0xffA9A9A9}, //brown
{0xffFF4500, 0xffFFA500,0xffA9A9A9}, //orange
{0xff4169E1, 0xff87CEFA,0xffA9A9A9}, //blue
{0xffC71585, 0xffFF69B4,0xffA9A9A9}, //pink
{0xffB22222, 0xffFA8080,0xffA9A9A9}, //red
{0xff008000, 0xff32CD32,0xffA9A9A9}, //green
{0xff9400D3, 0xffDA70D6,0xffA9A9A9}, //purple
{0xffFFB700,0xffFFEA00 ,0xffA9A9A9}, //yellow
{0xff708090,0xffD3D3D3,0xffA9A9A9}, //gray
{0xff66CDAA, 0xffAFEEEE,0xffA9A9A9} //cyan

};
//#F0E68C(khaki), #FFFF00  (bright yellow)
String MSinf,theState;
Textfield userMS;

RadioButton r, cts;

public void setupV() {
  // size(1100, 600);
   mtable = new Collect("MunHomicides.tsv");
   popul = new Collect("MunPopulationEst.tsv");
   Stable = new Collect("StateHomicides.tsv");
   Spopul = new Collect("StatePop.tsv");
   milInt = new Collect("InterventionDataNexos2011.tsv");
   cartel07 = new Collect("cartel2007HR.tsv");
   cartel10 = new Collect("cartel2010HR.tsv");
   ppartycMun = new Collect("CartelIncomeExpensesByMunicipality.tsv");
   results = new Collect("Results.tsv");
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
  

  
  
  //set the checkbox for cartel year to use 

    controlP5 = new ControlP5(this);
  r = controlP5.addRadioButton("radioButton",joeyWidth-40, 30);
  r.setColorForeground(color(bg_color));
  r.setColorValue(color(200));
  r.setColorActive(color(255));
  r.setColorLabel(color(255));
   r.setSize(15,15);
   r.setId(1);
 r.setItemsPerRow(2);
  r.setSpacingColumn(40);

 
// userMS = controlP5.addTextfield("Municipality, State",joeyWidth+valeriaWidth/3,valeriaHeight+barHeight,200,20);
// //userMun.setFocus(true);
// MSinf = userMS.getText();
// userMS.setId(2);
 
 
 

  addToRadioButton(r,"2007",0);
  addToRadioButton(r,"2010",1);
  addToRadioButton(r,"Intervened",2);
  
}




public void addToRadioButton(RadioButton theRadioButton, String theName, int theValue ) {
  Toggle t = theRadioButton.addItem(theName,theValue);
 // t.captionLabel().setColorBackground(color(80));
//  t.captionLabel().style().movePadding(2,0,-1,2);
//  t.captionLabel().style().moveMargin(-2,0,0,-3);
//  t.captionLabel().style().backgroundWidth = 46;
}


public void controlEvent(ControlEvent theEvent) {
  switch(PApplet.parseInt(theEvent.group().value())){
  case 0:
    cart2010 = false;
    dispInt=false;
    break;
  case 1 :
    cart2010 = true;
    dispInt=false;
    break;
  case 2 :
    dispInt=true;
    break;
  }
////  }  
}



public void find() {
  // receiving text from controller texting
  
  int nMun =mtable.numRows;
  String munName,sName, theMun,theState="";
  Boolean noStateflag = false;
  int comaPos = MSinf.indexOf(',');
  if(comaPos > 0)
  {
    theMun = MSinf.substring(0,comaPos-1);
    theState = MSinf.substring(comaPos+2);  
  }else
 {
   theMun = MSinf;
   noStateflag = true;
 } 

  for(int i=0 ; i < nMun;i++)
  {
     munName = mtable.getDataAt(i, 1);
     sName = Stable.getDataAt(i, 1);
     //println("munName = " +munName);
     if (munName.indexOf(theMun) !=-1)
     {
       if(noStateflag==false & sName.indexOf(theState) !=-1)
         selectedMuni = i;
         //break;
     }else
     {
       println("No match found.");
     }
  }
}

public void clear(int theValue) {
  userMS.clear();
}


public void drawV() {
    
    //draw rects
    fill(bg_color);
    rect(0,0,width,barHeight);
    rect(joeyWidth,0,width,height);

    //label button
 stroke(250); fill(250);  textFont(legendfont);textAlign(CENTER);textSize(10);
  text("Year of Stratfor Cartel Sketch ",joeyWidth,20);
    text("Press r to restart ",joeyWidth/2,58);
  
  /*
  | IMPORTANT:
  | the next two lines determine the dimensions of the plot area
  */
  int w = PApplet.parseInt (valeriaWidth);
  int h = PApplet.parseInt (valeriaHeight);
  
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
   if(allCartTS)
   {
     drawAllCartels();
     //allCartTS=false;
     
   }else
  { 
      plotDataPoints(selectedMuni);
      drawLegend();
      drawIntervention(selectedMuni,state,0xff8F8F23); //#808000
      drawPartyChange(selectedMuni,state,0xffBC8F8F);
      //drawZoomLegend();
      inspectDataPoints(munHR, datapoints,'M');
      inspectDataPoints(stateHR, statepoints,'S');
      inspectDataPoints(nationalHR, nationalpoints,'N');
      inspectDataPoints(cartelHR, cartelpoints,'C');
  }      
  

  if((mouseX<joeyWidth && mouseY> barHeight))
  {
     allCartTS=false; 
  }

}

/*
| IMPORTANT:
| alter this method to change positioning of plot area
*/
public void drawPlotArea(int w, int h) {
  plot_x1 = joeyWidth+80 ;
  plot_y1 =barHeight/2+20;
  plot_x2 = width-10;
  plot_y2 = plot_y1 + 65*h/100;
  rectMode(CORNERS);
  stroke(250);
  fill(250);
  rect(plot_x1, plot_y1, plot_x2, plot_y2);

  // set dimensions for later use
  plot_width = plot_x2 - plot_x1;
  plot_height = plot_y2 - plot_y1;
  
}

public void drawTitle (String t) {
  textFont(font);
  fill(fill_color);
  textAlign(CENTER);
  textSize(40);
  text(t, joeyWidth/2, 40);

}

public void drawAxesLabels (String x_axis, String y_axis) {
  textSize(14);
  
  // axis labels are centered between adjacent edge of plot area and window
  text(x_axis, joeyWidth+valeriaWidth-30, plot_y2+40);
  verticalText(y_axis, -height/4, joeyWidth+15);
  textSize(10);
  verticalText("per 100000 inhabitants ", -height/4,joeyWidth+30);

 
}



// draw grid lines
public void drawGridlines () { 
  //define the ranges accordingly
  // these should be in the original scale
  if(dispInt)
  {
    xrange =15;
     steps = 14;
     yrange = 200;
  }else
  {
    steps=22;
    xrange =  xlims[1]-xlims[0];  
    yrange = ylims[1]-ylims[0];
  }
  
   float x_step_size = plot_width / steps;
  
  
 int stepsy =10;

  // steps defined at top of document, default 10
 
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
    {
      if(dispInt)
      {
         verticalText(results.getDataAt(n-1,0), -(plot_y2+45), x+5); 
      }else
     { 
        verticalText(nf(years[n-1],0), -(plot_y2+15), x+5);
      }  
    }
  }
  // y grid lines
   for (int n =1; n <= 10; n++) {

    float y = plot_y2 - n * y_step_size;
    

    // draw grid lines
    line(plot_x1, y, plot_x2, y);
    //text(,x, plot_y2);

    // label grid lines as well
    textSize(10);
          if(dispInt)
      {  //println(results.getDataAt(n-1,0));
         text(String.format("%.2f",-40+(n * yrange)/stepsy), plot_x1-20,y);
      }else
     { 
        text(String.format("%.2f",ylims[0]+(n * yrange)/stepsy), plot_x1-20,y);
      }        
  }
  if(dispInt)
  {  //println(results.getDataAt(n-1,0));
     //text(String.format("%.2f",-70), plot_x1-20,y);
  }else
 { 
    text(String.format("%.2f",ylims[0]), plot_x1-20, plot_y2 );
  }  
  

}  


// plots column x against column y
public void plotDataPoints (int mun) {
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



public void drawAllCartels(){
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



public void defineColors(char cartS){
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
  case 'T':
    cartIndl = 6;
    cartIndd = 6;
    rowCart =6;
    break;
  case 'N':
    cartIndl = 7;
    cartIndd = 7;
    rowCart =7;
    break;
  case 'D':
    cartIndl = 8;
    cartIndd = 8;
    rowCart =8;
    break;
   case 's':
    cartIndl = 2;
    cartIndd = 5;
    rowCart =9;
    break;
   case 'a':
    cartIndl = 2;
    cartIndd = 9;
    rowCart =10;
    break;
   case 'z':
    cartIndl = 0;
    cartIndd = 1;
    rowCart =11;
    break;  
  }
}

 

// we need to truncate at zero!
public void drawSpline(float[] vector,int colo){
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


public void drawPoints(float[] vector,int colo){
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

public void inspectDataPoints (float[] vector, float[][] matrix, char type) {
  float x,y;
  for (int i = 0; i < vector.length; i++) {
    x =  map(years[i], xlims[0], xlims[1], plot_x1, plot_x2);
    y =  map(vector[i], ylims[0], ylims[1], plot_y2, plot_y1);
    // if mouse is within hover radius of a point. note: 1 is VERY accurate
    if (near(x,y, mouseX, mouseY, 5)) {
     stroke(bg_color);
     line(plot_x1,y,plot_x2+10,y);
      stroke(250); fill(250); textAlign(CENTER);textSize(12); 
      text(" ("+ years[i]+")", width-400,  valeriaHeight-40);
      textFont(legendfont);
      fill(250); textSize(12);
      textAlign(LEFT);
      text("population: " + floor(matrix[i][1]), width- 420,valeriaHeight-25);
      text("homicides :" + floor(matrix[i][0]),width- 420,valeriaHeight-10  );

    }
  }
}

// inspect Cartel points allCHompoints,allCPoppoints
//void inspectCartelPoints (float[][] homInf, float[][] PopInf, char type) {
//  float x,y;
//  for (int i = 0; i < years.length; i++) {
//    x =  map(years[i], xlims[0], xlims[1], plot_x1, plot_x2);
//    y =  map(vector[i], ylims[0], ylims[1], plot_y2, plot_y1);
//    // if mouse is within hover radius of a point. note: 1 is VERY accurate
//    if (near(x,y, mouseX, mouseY, 5)) {
// 
//     stroke(bg_color);
//     line(plot_x1,y,plot_x2+10,y);
//      stroke(250); fill(250); textAlign(CENTER);textSize(12); 
//            text(" ("+ years[i]+")", width- 350,  barHeight+valeriaHeight-40);
//
//      textFont(legendfont);
//      fill(250); textSize(12);
//      textAlign(LEFT);
//      text("population: " + floor(matrix[i][1]), width- 420, barHeight+valeriaHeight-25);
//      text("homicides :       " + floor(matrix[i][0]),width- 420,barHeight+valeriaHeight-10  );
//
//    }
//  }
//}



// for the checkbox
//void mouseClicked() {
//  click = true;
//} 


//// Size legend of time series
public void drawLegend(){
  
  textAlign(LEFT);
  stroke(250); fill(250);
  textSize(12);

   text("National", joeyWidth +45*valeriaWidth/100, valeriaHeight-10);
    text(Spopul.getDataAt(state, 1), joeyWidth +45*valeriaWidth/100, valeriaHeight-30); 
      text(popul.getDataAt(selectedMuni, 1), joeyWidth +7*valeriaWidth/10, valeriaHeight-30); 
   text(cartels[rowCart][0], joeyWidth +7*valeriaWidth/10, valeriaHeight-10);



 //Lenged for size
  for (int i = 1; i >=0; i--)
  {
    fill(seriesCols[cartIndl][i]);
    anuvcolor = seriesCols[cartIndl][1];
    stroke(seriesCols[cartIndd][i]);
    ellipse(joeyWidth +7*valeriaWidth/10-10,  valeriaHeight-15-20*i, 6, 6);
  }
  
     fill(seriesCols[cartIndl][2]);
    stroke(seriesCols[cartIndd][2]);
   ellipse(joeyWidth +45*valeriaWidth/100-10,  valeriaHeight-35, 6, 6); 
  stroke(0);
  fill(0);
  ellipse(joeyWidth +45*valeriaWidth/100-10,  valeriaHeight-15, 6, 6);

}  

public void drawIntervention(int mun, int sta, int cInt)
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



public void drawPartyChange(int mun, int sta, int cInt)
{
 int i;
 String partya, partyb;
 float intYear,x;
   

 for(i = 2; i < 4; i++)
 { 
   partyb=ppartycMun.getDataAt(mun,i);
   partya=ppartycMun.getDataAt(mun,i+1); // only here we have 0's
//   if(partya.equals(0) || partya.equals("NOT YET"))
//   {
//     println("No data");
//   }else
//   if(partya.equals(partyb)) //does this work
//   {
//       println("No party change");
//   }else
//   {
//   
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
   
//   }
   
 }  
} 

public void verticalText (String t, float x, float y) {
  pushMatrix(); // contain text transformation
  rotate(radians(270));
  // because we rotate 270, x becomes -y, y becomes x. think cartesian coordinates
  text(t, x, y);  
  popMatrix();
}



// determines whether x and y are within a radius `rad`
// of data[2] and data[3] respectively
public boolean near (float year_num, float hom , float x, float y, int rad) {
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
public float truncate(float x, float dec){
  float aux=pow(10,dec);

  if ( x > 0 )
    return round(floor(x * aux))/aux;
  else
    return round(ceil(x * aux))/aux;
}

 public void keyPressed () {
   if (key == CODED) {
     switch (keyCode) {
     case LEFT:
       // maybe I should make 2486 a golbal variable for nMun
         if(selectedMuni>0){
           selectedMuni=(selectedMuni-1)%2456;
         }
         else {selectedMuni=2455;}  
         state = floor(popul.getFloatAt(selectedMuni,0)/1000)-1;
         //plotAllC=false;
         break; 
     case RIGHT: 
       if(selectedMuni<2455){
         selectedMuni=(selectedMuni+1)%2456;
        }
         else {selectedMuni=0;}
       state = floor(popul.getFloatAt(selectedMuni,0)/1000)-1;
       //plotAllC=false;
       break;
       case 's': 
       // Go to ciudad Ju\u00e1rez (which has received a special atention)
         selectedMuni=234;
        //plotAllC=true;
       break;        
     }
   } 
 }



//// suggested by http://Phi.Lho.free.fr/index.en.h
//// at http://forum.processing.org/topic/an-if-statement-that-searches-for-a-string
//boolean contains(String haystack, String needles)
//{
//  for (String needle : needles)
//  {
//    if (haystack.contains(needle))
//    {
//      return true;
//    }
//  }
//  return false;
//}

public void resultsplot(int mun){
  int nReg = results.numRows-1;
  effects = new float[nReg]; 
  stdev = new float[nReg]; 
  float regionHRD, regionHRsd;
  int i,col;
  float x,y,lb,ub,rMuni;
  
  // the set up
     
     //draw rects
    fill(bg_color);
    rect(0,0,width,barHeight);
    rect(joeyWidth,0,width,height);

    //label button
 stroke(250); fill(250);  textFont(legendfont);textAlign(CENTER);textSize(10);
  text("Year of Stratfor Cartel Sketch ",joeyWidth,20);
    text("Press r to restart ",joeyWidth/2,58);
  
  /*
  | IMPORTANT:
  | the next two lines determine the dimensions of the plot area
  */
  int w = PApplet.parseInt (valeriaWidth);
  int h = PApplet.parseInt (valeriaHeight);
  
  strokeWeight(1);
 
  state = floor(popul.getFloatAt(selectedMuni,0)/1000)-1;
  
  /*
  | Start Drawing here.
  | Change these methods if necessary, clearly
  | commenting where any changes have been made
  */
  drawPlotArea(w, h);
 
  drawTitle(popul.getDataAt(selectedMuni, 1)+", "+ Spopul.getDataAt(state, 1) );
    drawAxesLabels("", "gain in homicide rate difference");
    drawGridlines();

      
  

//  if((mouseX<joeyWidth && mouseY> barHeight))
//  {
//     allCartTS=false; 
//  }
  
  // draw the results plot
  

    // i is a counter over the rows (regions)
  for (i = 0; i < nReg; i++) {
  //estimated effect
  //println(results.getFloatAt(i,6));
  effects[i] =   results.getFloatAt(i,4);
    //estimated sd
    // println(results.getFloatAt(i,7));
    stdev[i] =   results.getFloatAt(i,5);
  }
  
  // this should use max and min functions, but they weren't working so I put them in manually
  Maxim=160;
  Minim=-40;

  rMuni = ppartycMun.getFloatAt(mun,8);
    //println(rMuni);
  // plot datapoints

  for (i = 0; i < effects.length; i++) {
    x =  map(i, -1, nReg, plot_x1, plot_x2);
    y =  map(effects[i], Minim, Maxim, plot_y2, plot_y1);
    lb = map(effects[i]-1.96f*stdev[i], Minim, Maxim, plot_y2, plot_y1);
    ub = map(effects[i]+1.96f*stdev[i], Minim, Maxim, plot_y2, plot_y1);
   //if(datapoints[i][0]>=xlims[0] && datapoints[i][0]<=xlims[1] && datapoints[i][1]>=ylims[0] && datapoints[i][1]<=ylims[1]){

      if(results.getFloatAt(i,1) == rMuni)
      {
        stroke(0xff008000);
         fill(0xff008000);
      }else
      {
        fill( 0xffB22222);
        stroke(0xffB22222);  
      } 
      ellipse(x,y,5,5);
      line(x,lb,x,ub);
   // }
  }
  
  //draw the average
//  println(results.getFloatAt(13,6));
  stroke(0xffFA8080);
  y =  map(results.getFloatAt(13,4), Minim, Maxim, plot_y2, plot_y1);
  line(plot_x1,y,plot_x2,y);
  //and the bound
//  lb = map(results.getFloatAt(13,4)-1.96*results.getFloatAt(13,5), Minim, Maxim, plot_y2, plot_y1);
//  ub = map(results.getFloatAt(13,4)+1.96*results.getFloatAt(13,5), Minim, Maxim, plot_y2, plot_y1);
//
//  strokeWeight(0.5);
//  line(plot_x1,lb,plot_x2,lb);
//  line(plot_x1,ub,plot_x2,ub);
  strokeWeight(1);
  line(plot_x1,y,plot_x2,y);
    y =  map(0, Minim, Maxim, plot_y2, plot_y1);
    stroke(bg_color);
  line(plot_x1,y,plot_x2,y);
  
  //display information
    for ( i = 0; i < effects.length; i++) {
    x =  map(i, -1, nReg, plot_x1, plot_x2);
    y =  map(effects[i], Minim, Maxim, plot_y2, plot_y1);
    // if mouse is within hover radius of a point. note: 1 is VERY accurate
    if (near(x,y, mouseX, mouseY, 5)) {
     stroke(bg_color);
     line(plot_x1,y,plot_x2+10,y);
      stroke(250); fill(250); textAlign(CENTER);textSize(12); 
       textFont(legendfont);
            text(results.getDataAt(i,0)+" Region", width-350,  barHeight/2);
             textSize(12);
             textAlign(LEFT);
             text("number of municipalities: " +results.getDataAt(i,2)+" ", width- 250,barHeight/2-20);
             text("estimated effect (se): " + truncate(effects[i],2)+" ("+ truncate(stdev[i],4)+")",width- 250,barHeight/2-5); 
             text("first intervention date: " +results.getDataAt(i,3)+ " ",width- 250,barHeight/2+10);  
    }
  }
  
}
/* Author: Joseph Kelly
   Date: April 20, 2012
   CS 171 
   Homicide Rate in Mexico (1990-2010)
*/





RShape mapImage;
RShape[] munis;
Table homicideTable;
Table cartelTable;
Table popTableJ;
int mapHeight = height;
int mapWidth = width;
int municCount;
int[] colorScheme = {50, 153, 0, 255};
//int[] colorScheme = { 255, 255, 0, 50};
String[] municClave;
String lovefn ="Images/MEloveplot.png";
char[] municCartel;
char[] municCartel2007J;
char[] municCartel2010J;
float[] municHom;
float[] municHom2007J;
float[] municHom2010J;
float[] municGrey;
float[] municGrey2007J;
float[] municGrey2010J;
float[] bJ = {5,10,50};
float[] heatJ = {30, 100, 200, 255};
float xx = 280;
float yy = 0;
float pan = -40;
float zoom = 1.5f;
int buttonX = joeyWidth - 80;
int buttonY = barHeight + 60;
int buttonS = 40;
int legendS = 70;
int zoomcount = 0;
RectButton left, right, up, down, in, out;
boolean locked = false;
int highlightJ = color(0,100,255);
int[][] seriesColsJ={
{0xff8B4513,0xffCd853F ,0xffA9A9A9}, //brown
{0xffFF4500, 0xffFFA500,0xffA9A9A9}, //orange
{0xff4169E1, 0xff87CEFA,0xffA9A9A9}, //blue
{0xffC71585, 0xffFF69B4,0xffA9A9A9}, //pink
{0xffB22222, 0xffFA8080,0xffA9A9A9}, //red
{0xff008000, 0xff32CD32,0xffA9A9A9}, //green
{0xff9400D3, 0xffDA70D6,0xffA9A9A9}, //purple
{0xffFFB700,0xffFFEA00 ,0xffA9A9A9}, //yellow
{0xff708090,0xffD3D3D3,0xffA9A9A9}, //gray
{0xff66CDAA, 0xffAFEEEE,0xffA9A9A9} //cyan
};

String[][] cartelsJ = {
  {"Gulf Cartel", "G"},
  {"Los Zetas Cartel", "Z"},
  {"Pacifico Sur Cartel", "P"},
  {"La Familia Michoacana", "F"},
  {"Cartel de Ju\u00e1rez", "J"},
  {"Sinaloa Cartel","S"},
  {"Acapulco and Pacifico Sur","a"},
    {"Tijuana Cartel","T"},
  {"In Dispute", "D"},
  {"Not Specified", "N"},
  {"Pacifico Sur and Sinaloa Cartels","s"},
  {"Gulf and Los Zetas Cartels","z"},
};


public void setupJ() {

  //setup
  g.smooth = true;

  //initialize the geomerative library
  RG.init(this);
  RG.ignoreStyles(true);
  RG.setPolygonizer(RG.ADAPTATIVE);

  //setup map
  /* @pjs preload="muni_ink.svg"; */
  mapImage = RG.loadShape("muni_ink.svg");
  mapImage.centerIn(g, 0, 1, 1);

  //build homicideTable and cartelTable
  cartelTable = new Table("CartelIncomeExpensesByMunicipality.tsv");
  homicideTable = new Table("MunHomicides.tsv");
  popTableJ = new Table("MunPopulationEst.tsv");
  municCount = homicideTable.getRowCount() - 1;
  municCartel = new char[municCount];
  municCartel2007J = new char[municCount];
  municCartel2010J = new char[municCount];
  municClave = new String[municCount];
  municHom = new float[municCount];
  municHom2007J = new float[municCount];
  municHom2010J = new float[municCount];
  municGrey = new float[municCount];
  municGrey2007J = new float[municCount];
  municGrey2010J = new float[municCount];
  munis = new RShape[municCount];

  for(int c = 0; c < municCount; c++){
    municClave[c] = "muni_" + homicideTable.getString(c+1,0);
    municHom2010J[c] = homicideTable.getFloat(c+1,66)/popTableJ.getFloat(c+1,22)*100000;
    municHom2007J[c] = homicideTable.getFloat(c+1,54)/popTableJ.getFloat(c+1,19)*100000;
    municCartel2010J[c] = cartelTable.getString(c+1,6).charAt(0);
    municCartel2007J[c] = cartelTable.getString(c+1,5).charAt(0);
    munis[c] = mapImage.getChild(municClave[c]);
    municGrey2010J[c] = mapitJ(municHom2010J[c]);
    municGrey2007J[c] = mapitJ(municHom2007J[c]);
  }

  //setup buttons
  ellipseMode(CENTER);

  left = new RectButton(buttonX-buttonS,buttonY, 14, color(colorScheme[3],0), color(colorScheme[3],0));
  right = new RectButton(buttonX+buttonS,buttonY, 14, color(colorScheme[3],0), color(colorScheme[3],0));
  up = new RectButton(buttonX,buttonY-buttonS, 14, color(colorScheme[3],0), color(colorScheme[3],0));
  down = new RectButton(buttonX,buttonY+buttonS, 14, color(colorScheme[3],0), color(colorScheme[3],0));
  in = new RectButton(buttonX,buttonY-buttonS/4, 14, color(colorScheme[3],0), color(colorScheme[3],0));
  out = new RectButton(buttonX,buttonY+buttonS/4+10, 14, color(colorScheme[3],0), color(colorScheme[3],0));

  //zoomout once
  zoomit(1/zoom);

  //draw full map
  drawfullJ();
}

public void drawfullJ() {
    background(bg_color);
    stroke(1);
    strokeWeight(0.5f);
    translate(mapWidth/2-xx, mapHeight/2-yy);
    //change from 2010 to 2007 according to boolean
  if(cart2010){
    arrayCopy(municGrey2010J,municGrey);
    arrayCopy(municCartel2010J,municCartel);
    arrayCopy(municHom2010J, municHom);
  }else{
    arrayCopy(municGrey2007J,municGrey);
    arrayCopy(municCartel2007J,municCartel);
    arrayCopy(municHom2007J, municHom);
  }
  
  for(int i = 0; i < municCount; i++){
      RShape munic = munis[i];
      if(munic != null){
	  fill(255);
	  munic.draw();
	  int[] cartcol  = cartelColor(municCartel[i]);
	  //println(cartelTable.getInt(7,7));
	  // modified to display the intervened municipalities
	  if(dispInt){
              // there must be a cleaner way to do this
              int reg = cartelTable.getInt(i+1,8);
	      if(reg!=0){
		  if(cartelTable.getInt(i+1,7)==1)
                      if(reg!=3 && reg!=7 && reg!=13 && reg!=14 & reg!=17)
		        fill(0xffFF0000);
                      else
                        fill(0xff000000);
		  else
                      if(reg!=3 && reg!=7 && reg!=13 && reg!=14 & reg!=17)
		        fill(0xffFF0000,100);
                      else
                        fill(0xff000000,100);          
	      }else{
		  fill(0xffFFFFFF);
	      }
	  }else{
	      fill(seriesColsJ[cartcol[0]][0],municGrey[i]);
	  }
	  stroke(colorScheme[2]);
	  munic.draw();
      }
  }
  translate(-mapWidth/2+xx, -mapHeight/2+yy);



  //draw legend




  textSize(10);
  textAlign(LEFT,TOP);
  rectMode(CORNER);
  fill(bg_color);
  noStroke();
  rect(0,height-barHeight*1.25f,width,barHeight*1.25f);
  stroke(1);
  for(int i = 0; i < cartelsJ.length-2; i++){
    int [] cartcol = cartelColor(cartelsJ[i][1].charAt(0));
    fill(255);
    rect(legendS*(i+1), height-barHeight*1.25f,40,40);
   
    text(cartelsJ[i][0],legendS*(i+1), height-barHeight*1.25f + 45, 60,70);
    
    for(int j = 0; j < heatJ.length; j++){
      fill(seriesColsJ[cartcol[0]][0],heatJ[j]);
      rect(legendS*(i+1), height-barHeight*1.25f + 30 - 10*j ,40,10);
    }
  }

  textAlign(RIGHT,TOP);
  textSize(10);
  fill(255);
  text("> " + (int) bJ[2], legendS-20, height-barHeight*1.25f);
  text((int) bJ[1] + " - " + (int) bJ[2], legendS-20, height-barHeight*1.25f + 10);
  text((int) bJ[0] + " - " + (int) bJ[1], legendS-20, height-barHeight*1.25f + 20);
  text("0 - " + (int) bJ[0], legendS-20, height-barHeight*1.25f + 30);
  textAlign(LEFT,TOP);
  text("Homicide Rate", 20, height-barHeight*1.25f + 45, 60,70);  
}

public void drawJ() {

  //update graph
  update();

//draw map
  smooth();
  strokeWeight(0.5f);
  stroke(1);

  RPoint p = new RPoint(mouseX-width/2 + xx, mouseY-height/2 + yy);
  translate(mapWidth/2-xx, mapHeight/2-yy);

  RShape oldmunic = munis[oldMuni];
  if(oldmunic != null){
      fill(255);
      oldmunic.draw();
      int[] cartcol  = cartelColor(municCartel[oldMuni]);
      //println(cartelTable.getInt(7,7));
      // modified to display the intervened municipalities
      if(dispInt){

	  // // there must be a cleaner way to do this
      // 	  int reg = cartelTable.getInt(i+1,8);
      // 	  if(reg!=0){
      // 	      if(cartelTable.getInt(i+1,7)==1)
      // 		  if(reg!=3 && reg!=7 && reg!=13 && reg!=14 & reg!=17)
      // 		      fill(#FF0000);
      // 		  else
      // 		      fill(#000000);
      // 	      else
      // 		  if(reg!=3 && reg!=7 && reg!=13 && reg!=14 & reg!=17)
      // 		      fill(#FF0000,100);
      // 		  else
      // 		      fill(#000000,100);          
      // 	  }else{
      // 	      fill(#FFFFFF);
      // 	  }
      // }else{
      // 	  fill(seriesColsJ[cartcol[0]][0],municGrey[i]);
      // }
      
	  int reg = cartelTable.getInt(oldMuni+1,8);
	  if(reg!=0){
	      if(cartelTable.getInt(oldMuni+1,7)==1)
		  if(reg!=3 && reg!=7 && reg!=13 && reg!=14 & reg!=17)
      		      fill(0xffFF0000);
      		  else
      		      fill(0xff000000);
	      else 
		  if(reg!=3 && reg!=7 && reg!=13 && reg!=14 & reg!=17)
		      fill(0xffFF0000,100);
      		  else
      		      fill(0xff000000,100);  
	  }else{
	      fill(0xffFFFFFF);
	  }
      }else{
	  fill(seriesColsJ[cartcol[0]][0],municGrey[oldMuni]);
      }
      // stroke(colorScheme[2]);
      oldmunic.draw();
  }

  int selectedregion = 99;
  for(int i = 0; i < municCount; i++){
    RShape munic = munis[i];
    int region = cartelTable.getInt(i+1,8);
    if(munic != null){
      if(munic.contains(p) & mouseX< joeyWidth & mouseY > barHeight){
	selectedregion = cartelTable.getInt(i+1,8);
        selectedMuni = i;
        hoverMuni = true;

	//loveplot
	if(dispInt){
	    if(cartelTable.getInt(i+1,8)!=0){
		String muniname = ""+ Integer.parseInt(split(municClave[i],'_')[1]);
		lovefn = "Images/loveplot" + muniname + ".png";
	    }else{
		lovefn = "Images/MEloveplot.png";
	    }
	}

	if(dispInt){
	    if(cartelTable.getInt(i+1,8)!=0){
		fill(0xff008000);
		if(cartelTable.getInt(i+1,7)==1)
		    fill(0xff32CD32);
	    }else{   
		fill(0xffFFFFFF);
	    }
	}else{
	    fill(highlightJ);
	}
	munic.draw();
	oldMuni = i;
      // }else{
      // 	  if(dispInt){
      // 	      if(region == selectedregion & cartelTable.getInt(i+1,8)!=0){
		 
      // 		  String muniname = ""+ Integer.parseInt(split(municClave[i],'_')[1]);
      // 		  lovefn = "Images/loveplot" + muniname + ".png";
      // 		  fill(#008000);
      // 		  munic.draw();
      // 		  oldMuni = i;
      // 		  fill(#FFFFFF);
      // 	      }
      // 	  }
	  //drawfullJ();
	  // oldMuni = i;
      }
   
      // if(hoverMuni & i==selectedMuni){
      //   fill(highlightJ);
      //  // fill(seriesColsJ[ cartelColor(municCartel[i])[0]][3]);
      //   munic.draw();
      // }

    }
  }

  //draw buttons
  //translate(xx, -joeyHeight/1.3+yy);
  translate(-mapWidth/2+xx, -mapHeight/2+yy);
  
  
  //draw background for widget
  fill(colorScheme[0]);
  noStroke();
  ellipse(buttonX+3, buttonY+7, 110, 110);

  // left.display();
  // right.display();
  // up.display();
  // down.display();
  // in.display();
  // out.display();

  //text in buttons
  textAlign(LEFT,TOP);
  //textSize(14);
  //stroke(1);
  fill(255);
  textSize(18);
  text("<",buttonX-buttonS,buttonY);
  text("+",buttonX,buttonY-buttonS/4);
  text(">",buttonX+buttonS,buttonY);
textSize(22);
  text("-",buttonX+1,buttonY+buttonS/4);
  text("^",buttonX+1,buttonY-buttonS);
textSize(16);
  text("v",buttonX+1,buttonY+buttonS);


  
//draw rectangles
  // fill(colorScheme[0]);
  // rectMode(CORNER);
  // rect(joeyWidth,barHeight,valeriaWidth,2*valeriaHeight);
  // rect(0,0,width,barHeight);
  // rect(0,height-barHeight*1.35,joeyWidth,barHeight*1.35);

  //draw legend
  //text label
}


public void zoomit(float zoom) {
  for(int i = 0; i < municCount; i++){
    RShape munic =  munis[i];
    if(munic != null){
      munic.scale(zoom);
      munis[i] = munic;
    }
  } 
  
}

public void update(){
  if(locked == false) {
    left.update();
    right.update();
    up.update();
    down.update();
    in.update();
    out.update();
  } 
  else {
    locked = false;
  }

  if(mousePressed) {
    if(left.pressed())
      xx = xx + pan;
    if(right.pressed())
      xx = xx - pan;
    if(up.pressed())
      yy = yy + pan;
    if(down.pressed())
      yy = yy - pan;
    if(in.pressed()){
      zoomit(zoom);
      zoomcount = zoomcount + 1;
    }
    if(out.pressed()){
      zoomit(1/zoom);
      zoomcount = zoomcount - 1;
    }
    drawfullJ();
  }
}

public float mapitJ(float val){
  float retval = 0;
  if(val > bJ[2])
    retval = heatJ[3];

  if(val < bJ[2] & val > bJ[1])
    retval = heatJ[2];
  
  if(val < bJ[1] & val > bJ[0])
    retval = heatJ[1];

  if(val < bJ[0])
    retval = heatJ[0];

  return retval;
}

public int[] cartelColor(char cartS){
  int cartIndl=0;
  int cartIndd=0;
  int rowCart=0;
  
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
  case 'T':
    cartIndl = 6;
    cartIndd = 6;
    rowCart =6;
    break;
  case 'N':
    cartIndl = 7;
    cartIndd = 7;
    rowCart =7;
    break;
  case 'D':
    cartIndl = 8;
    cartIndd = 8;
    rowCart =8;
    break;
   case 's':
    cartIndl = 2;
    cartIndd = 5;
    rowCart =9;
    break;
   case 'a':
    cartIndl = 9;
    cartIndd = 9;
    rowCart =10;
    break;
   case 'z':
    cartIndl = 0;
    cartIndd = 1;
    rowCart =11;
    break;   
   //default:
     //println("failed"); 
  }
  int[] vals = {cartIndl, cartIndd, rowCart};
  return vals;
}


public void keyReleased(){
  if(key == 'r'){
    allCartTS =true;
    cart2010 = true;
    selectedMuni = 0;
    xx = 280;
    yy = 0;
    
    if(zoomcount < 0){
      zoomcount = zoomcount*-1;
      for(int i = 0; i < zoomcount; i++){
        zoomit(zoom);
      }
    }
    if(zoomcount > 0){
      for(int i = 0; i < zoomcount; i++){
        zoomit(1/zoom);
      } 
    }
    zoomcount = 0;  
    drawfullJ();
  }
}

public void loveplot(String fn){
    File f = new File(dataPath("")+"../"+fn);
    if(f.exists()){
	PImage locImage = loadImage(fn);
	image(locImage,joeyWidth,valeriaHeight);
    }
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "drugwar171" });
  }
}
