int width = 1280;
int height = 750;
int selectedMuni;
boolean cart2010;
boolean hoverMuni;
int barHeight=75;
int joeyWidth=768;
int joeyHeight=675;
int valeriaHeight=338;
int valeriaWidth=300;
int valeriaHeight=337;
int valeriaWidth=300;


void setup(){
  size(width,height);
  setupJ();
  setupV();
  setupA();
}


void draw(){
  drawJ();
  drawV();
  drawA();
}