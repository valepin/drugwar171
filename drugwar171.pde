/* Author: Joseph Kelly, Valeria Espinosa
   Date: April 20, 2012
   CS 171 
   Homicide Rate in Mexico (1990-2010)
*/

int tsize = 10;
int width = 1024;
int height = 600;
int selectedMuni;
int oldMuni = 0;
boolean cart2010=true, allCartTS=true, dispInt=false;
boolean hoverMuni;
int barHeight= (int) height/10;
int joeyWidth= (int) 6*width/10;
int joeyHeight= (int) 9*height/10;
int valeriaHeight=(int) 54*height/100;
int valeriaWidth=(int) 4*width/10;
int anuvHeight=(int) 36*height/100;
int anuvWidth=(int) 4*width/10;


void setup() {
  size(width, height);
  if (frame != null) {
    frame.setResizable(true);
  }
  background(bg_color);
  setupJ();
  setupV();
}


void draw() {

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

