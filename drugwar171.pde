int width = 1280;
int height = 750;
int selectedMuni;
boolean cart2010=true;
boolean hoverMuni;
int barHeight=75;
int joeyWidth=768;
int joeyHeight=675;
int valeriaHeight=338;
int valeriaWidth=512;
int anuvHeight=337;
int anuvWidth=512;


void setup(){
  size(width,height);
  setupJ();
  setupV();
  //setupA();
}


void draw(){
  background(bg_color);
  hoverMuni=false;
  drawJ();
  drawV();
  //drawA();
}
