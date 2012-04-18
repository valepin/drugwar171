import processing.opengl.*;
import geomerative.*;

RShape mapImage;
ArrayList munis;
ArrayList claveIDs;
Table homicideTable;
int mapHeight = 500;
int mapWidth = 800;
int municCount;
int[] colorScheme = {50, 153, 0, 255};
//int[] colorScheme = { 255, 255, 0, 50};
String[] municClave;
float[] municHom;
float[] municGrey;
float xx = 0;
float yy = 0;
float pan = -40;
float zoom = 1.5;
int buttonX = mapWidth - 80;
int buttonY = 60;
int buttonS = 40;
RectButton left, right, up, down, in, out;
boolean locked = false;

void setup() {

  //draw background
  background(colorScheme[0]);
  size(mapWidth,mapHeight); 
  g.smooth = true;

  //initialize the geomerative library
  RG.init(this);
  RG.ignoreStyles(true);
  RG.setPolygonizer(RG.ADAPTATIVE);

  //setup map
  mapImage = RG.loadShape("../data/muni_ink.svg");
  mapImage.centerIn(g, 0, 1, 1);

  //build homicideTable
  homicideTable = new Table("../data/MunHomicides.tsv");
  municCount = homicideTable.getRowCount() - 1;
  municClave = new String[municCount];
  municHom = new float[municCount];
  municGrey = new float[municCount];

  for(int c = 0; c < municCount; c++){
    municClave[c] = "muni_" + homicideTable.getString(c+1,0);
    municHom[c] = homicideTable.getFloat(c+1,66)/homicideTable.getFloat(c+1,65);
  }

  //create greyscale vector for heatmap
  for(int c = 0; c < municCount; c++)
    municGrey[c] = map(municHom[c], min(municHom), max(municHom),colorScheme[0], colorScheme[3]);
  
  //store all munis and claveID in ArrayLists for easy reference
  munis = new ArrayList();
  claveIDs = new ArrayList();
  for (int row = 0; row < municCount; row++) {
    RShape munic = mapImage.getChild(municClave[row]);
    if(munic != null){
      munis.add(munic);
      claveIDs.add(municClave[row]);
    }
  }

  //setup buttons
  ellipseMode(CENTER);
  left = new RectButton(buttonX-buttonS,buttonY, 10, color(colorScheme[3]), color(colorScheme[3]));
  right = new RectButton(buttonX+buttonS,buttonY, 10, color(colorScheme[3]), color(colorScheme[3]));
  up = new RectButton(buttonX,buttonY-buttonS, 10, color(colorScheme[3]), color(colorScheme[3]));
  down = new RectButton(buttonX,buttonY+buttonS, 10, color(colorScheme[3]), color(colorScheme[3]));
  in = new RectButton(buttonX,buttonY-buttonS/4, 10, color(colorScheme[3]), color(colorScheme[3]));
  out = new RectButton(buttonX,buttonY+buttonS/4, 10, color(colorScheme[3]), color(colorScheme[3]));

}

void draw() {
  background(colorScheme[0]);

  //update graph
  update();

//draw map
  smooth();
  translate(mapWidth/2-xx, mapHeight/2-yy);
  RPoint p = new RPoint(mouseX-width/2 + xx, mouseY-height/2 + yy);
  for(int i = 0; i < munis.size(); i++){
    RShape munic = (RShape) munis.get(i);
    if(munic.contains(p)){
      fill(0,100,255,250);
    }else{
      fill(municGrey[i]);
      stroke(colorScheme[2]);
    }
    munic.draw();
  }

  //draw buttons
  translate(-mapWidth/2+xx, -mapHeight/2+yy);
  left.display();
  right.display();
  up.display();
  down.display();
  in.display();
  out.display();

}


void zoomit(float zoom) {
  for(int i = 0; i < munis.size(); i++){
    RShape munic = (RShape) munis.get(i);
    munic.scale(zoom);
    munis.set(i,munic);
  } 
}

void update(){
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
    if(in.pressed())
      zoomit(zoom);
    if(out.pressed())
      zoomit(1/zoom);
  }
}