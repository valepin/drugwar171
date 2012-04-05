PShape mapImage;
Table homicideTable;
int mapHeight;
int mapWidth;
int municCount;
String[] municNames;
Float[] municHom;

void setup() {

  //draw map
  mapHeight = 540;
  mapWidth = 770;
  size(mapWidth,mapHeight); 
  mapImage = loadShape("../data/mexico_770x540.svg");
  smooth();
  shape(mapImage);

  //build homicideTable
  homicideTable = new Table("../Data/Homicides.tsv");
  municCount = homicideTable.getRowCount();
  municNames = new String[municCount];
  municHom = new Float[municCount];

  for(int c = 0; c < municCount; c++){
    municNames[c] = homicideTable.getString(c,0);
    municHom[c] = homicideTable.getFloat(c,1);
  }

  //color in muncip
  // for (int row = 0; row < municCount; row++) {
  //   PShape munic = mapImage.getChild(municNames[row]);
  //   fill(169,216,255);
  //   //shape(munic);
  //   print(munic);
  // }
}

// void draw() {
  
  
// }
