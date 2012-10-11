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


void setup() {
  size(1280, 750);
  background(bg_color);
  setupJ();
  setupV();
}


void draw() {

  hoverMuni=true;
  drawJ();
  drawV();
}

