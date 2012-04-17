PShape mapImage;
Table homicideTable;
int mapHeight;
int mapWidth;
int worldX;
int worldY;
int municCount;
int[] colorScheme;
String[] municClave;
Float[] municHom;


void setup() {

  //set color scheme
  int[] colorScheme = { 0, 153, 0};
  //int[] colorScheme = { 255, 255, 0};

  //draw background
  background(colorScheme[0]);
  mapHeight = 500;
  mapWidth = 800;
  size(mapWidth,mapHeight); 

  //draw map
  worldX = -100;
  worldY = 500;
  mapImage = loadShape("../data/muni_ink.svg");
  smooth();
  mapImage.disableStyle();
  fill(colorScheme[1]);
  stroke(colorScheme[2]);
  shape(mapImage,worldX,worldY);
  
  //build homicideTable
  homicideTable = new Table("../data/MunHomicides.tsv");
  municCount = homicideTable.getRowCount() - 1;
  municClave = new String[municCount];
  municHom = new Float[municCount];

  for(int c = 0; c < municCount; c++){
    municClave[c] = "muni_" + homicideTable.getString(c+1,0);
    municHom[c] = homicideTable.getFloat(c+1,1);
  }

  //demonstrating use of getChild
  for (int row = 0; row < 100; row++) {
    PShape munic = mapImage.getChild(municClave[row]);;
    munic.disableStyle();
    fill(169,216,255);
    noStroke();
    shape(munic,worldX,worldY);
  }


}

void draw() {
 
}
