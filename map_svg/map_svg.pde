import processing.opengl.*;
import geomerative.*;

RShape mapImage;
ArrayList munis;
ArrayList claveIDs;
Table homicideTable;
int mapHeight = 500;
int mapWidth = 800;
int municCount;
int[] colorScheme = {0, 153, 0};
//int[] colorScheme = { 255, 255, 0};
String[] municClave;
Float[] municHom;


void setup() {

  //draw background
  background(colorScheme[0]);
 
  size(mapWidth,mapHeight); 
  g.smooth = true;

  //initialize the geomerative library
  RG.init(this);
  RG.ignoreStyles(true);
  //RG.setPolygonizer(RG.ADAPTATIVE);

  //draw map
  mapImage = RG.loadShape("../data/muni_ink.svg");
  smooth();
  fill(colorScheme[1]);
  stroke(colorScheme[2]);
  mapImage.centerIn(g, 0, 1, 1);
  translate(mapWidth/2, mapHeight/2);
  mapImage.draw();
  
  
  //build homicideTable
  homicideTable = new Table("../data/MunHomicides.tsv");
  municCount = homicideTable.getRowCount() - 1;
  municClave = new String[municCount];
  municHom = new Float[municCount];

  for(int c = 0; c < municCount; c++){
    municClave[c] = "muni_" + homicideTable.getString(c+1,0);
    municHom[c] = homicideTable.getFloat(c+1,1);
  }

  //store all munis and claveID in ArrayLists for easy reference
  munis = new ArrayList();
  claveIDs = new ArrayList();
  for (int row = 0; row < municCount; row++) {
    RShape munic = mapImage.getChild(municClave[row]);
    if(munic == null){
      print(row); //it seems that some munis in our tsv are not in the svg
      print(" ");
    }else{
      munis.add(munic);
      claveIDs.add(municClave[row]);
    }
  }

}

void draw() {

  translate(mapWidth/2, mapHeight/2);
  RPoint p = new RPoint(mouseX-width/2, mouseY-height/2);
  for(int i = 0; i < munis.size(); i++){
    RShape munic = (RShape) munis.get(i);
    if(munic.contains(p)){
       fill(0,100,255,250);
       munic.draw();
    }else{
      fill(colorScheme[1]);
      munic.draw();
    }
    
  }

}