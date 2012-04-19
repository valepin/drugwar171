import processing.opengl.*;
import geomerative.*;

//TODO: Cartel legend + highlighting 
//TODO: cart2010 functionality
//

RShape mapImage;
RShape[] munis;
//ArrayList munis;
//ArrayList claveIDs;
Table homicideTable;
Table cartelTable;
int mapHeight = 500;
int mapWidth = 800;
int municCount;
int[] colorScheme = {50, 153, 0, 255};
//int[] colorScheme = { 255, 255, 0, 50};
String[] municClave;
char[] municCartel;
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
color[][] seriesColsJ={
{#9400D3, #DA70D6,#A9A9A9},
{#FF4500, #FFA500,#A9A9A9},
{#4169E1, #87CEFA,#A9A9A9},
{#C71585, #FF69B4,#A9A9A9},
{#B22222, #FA8080,#A9A9A9},
{#008000, #32CD32,#A9A9A9},
{#FFD700, #F0E68C,#A9A9A9},
{#708090,#D3D3D3,#A9A9A9}

};


void setupJ() {

  //draw background
  background(colorScheme[0]);
  //size(mapWidth,mapHeight); 
  g.smooth = true;

  //initialize the geomerative library
  RG.init(this);
  RG.ignoreStyles(true);
  RG.setPolygonizer(RG.ADAPTATIVE);

  //setup map
  mapImage = RG.loadShape("muni_ink.svg");
  mapImage.centerIn(g, 0, 1, 1);

  //build homicideTable and cartelTable
  cartelTable = new Table("CartelIncomeExpensesByMunicipality.tsv");
  homicideTable = new Table("data/MunHomicides.tsv");
  municCount = homicideTable.getRowCount() - 1;
  municCartel = new char[municCount];
  municClave = new String[municCount];
  municHom = new float[municCount];
  municGrey = new float[municCount];
  munis = new RShape[municCount];

  for(int c = 0; c < municCount; c++){
    municClave[c] = "muni_" + homicideTable.getString(c+1,0);
    municHom[c] = homicideTable.getFloat(c+1,66)/homicideTable.getFloat(c+1,65);
    municCartel[c] = cartelTable.getString(c+1,6).charAt(0);
    munis[c] = mapImage.getChild(municClave[c]);
  }

  //create greyscale vector for heatmap
  for(int c = 0; c < municCount; c++)
    municGrey[c] = map(municHom[c], min(municHom), max(municHom),0,255);
  
  //setup buttons
  ellipseMode(CENTER);
  left = new RectButton(buttonX-buttonS,buttonY, 10, color(colorScheme[3],0), color(colorScheme[3],0));
  right = new RectButton(buttonX+buttonS,buttonY, 10, color(colorScheme[3]), color(colorScheme[3]));
  up = new RectButton(buttonX,buttonY-buttonS, 10, color(colorScheme[3]), color(colorScheme[3]));
  down = new RectButton(buttonX,buttonY+buttonS, 10, color(colorScheme[3]), color(colorScheme[3]));
  in = new RectButton(buttonX,buttonY-buttonS/4, 10, color(colorScheme[3]), color(colorScheme[3]));
  out = new RectButton(buttonX,buttonY+buttonS/4, 10, color(colorScheme[3]), color(colorScheme[3]));
}

void drawJ() {
  background(colorScheme[0]);

  //update graph
  update();

//draw map
  smooth();
  strokeWeight(0.1);
  translate(mapWidth/2-xx, mapHeight/2-yy);
  RPoint p = new RPoint(mouseX-width/2 + xx, mouseY-height/2 + yy);
  for(int i = 0; i < municCount; i++){
    RShape munic = munis[i];
    if(munic != null){
      if(munic.contains(p)){
	fill(0,100,255,250);
      }else{
	fill(255);
	munic.draw();
	int[] cartcol  = cartelColor(municCartel[i]);
	//TODO not sure about mix thing
	fill(seriesColsJ[cartcol[0]][0],municGrey[i]);
	stroke(colorScheme[2]);
      }
   
      munic.draw();
    }
  }

  //draw buttons
  translate(-mapWidth/2+xx, -mapHeight/2+yy);
  left.display();
  right.display();
  up.display();
  down.display();
  in.display();
  out.display();

  //text in buttons
  textAlign(LEFT,TOP);
  text("<",buttonX-buttonS,buttonY);
  text(">",buttonX+buttonS,buttonY);
  text("^",buttonX,buttonY-buttonS);
  text("v",buttonX,buttonY+buttonS);
  text("+",buttonX,buttonY-buttonS/4);
  text("-",buttonX,buttonY+buttonS/4);


}


void zoomit(float zoom) {
  for(int i = 0; i < municCount; i++){
    RShape munic =  munis[i];
    if(munic != null){
      munic.scale(zoom);
      munis[i] = munic;
    }
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

int[] cartelColor(char cartS){
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
    cartIndl = 5;
    cartIndd = 2;
    rowCart =8;
    break;
   case 'a':
    cartIndl = 8;
    cartIndd = 2;
    rowCart =9;
    break;
   case 'z':
    cartIndl = 1;
    cartIndd = 0;
    rowCart =10;
    break;  
   default:
     //println("failed"); 
  }
  int[] vals = {cartIndl, cartIndd, rowCart};
  return vals;
}