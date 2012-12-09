/* Author: Joseph Kelly
   Date: April 20, 2012
   CS 171 
   Homicide Rate in Mexico (1990-2010)
*/


import processing.opengl.*;
import geomerative.*;

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
float zoom = 1.5;
int buttonX = joeyWidth - 80;
int buttonY = barHeight + 60;
int buttonS = 40;
int legendS = 70;
int zoomcount = 0;
RectButton left, right, up, down, in, out;
boolean locked = false;
color highlightJ = color(0,100,255);
color[][] seriesColsJ={
{#8B4513,#Cd853F ,#A9A9A9}, //brown
{#FF4500, #FFA500,#A9A9A9}, //orange
{#4169E1, #87CEFA,#A9A9A9}, //blue
{#C71585, #FF69B4,#A9A9A9}, //pink
{#B22222, #FA8080,#A9A9A9}, //red
{#008000, #32CD32,#A9A9A9}, //green
{#9400D3, #DA70D6,#A9A9A9}, //purple
{#FFB700,#FFEA00 ,#A9A9A9}, //yellow
{#708090,#D3D3D3,#A9A9A9}, //gray
{#66CDAA, #AFEEEE,#A9A9A9} //cyan
};

String[][] cartelsJ = {
  {"Gulf Cartel", "G"},
  {"Los Zetas Cartel", "Z"},
  {"Pacifico Sur Cartel", "P"},
  {"La Familia Michoacana", "F"},
  {"Cartel de Juárez", "J"},
  {"Sinaloa Cartel","S"},
  {"Acapulco and Pacifico Sur","a"},
    {"Tijuana Cartel","T"},
  {"In Dispute", "D"},
  {"Not Specified", "N"},
  {"Pacifico Sur and Sinaloa Cartels","s"},
  {"Gulf and Los Zetas Cartels","z"},
};


void setupJ() {

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

void drawfullJ() {
    background(bg_color);
    stroke(1);
    strokeWeight(0.5);
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
		        fill(#FF0000);
                      else
                        fill(#000000);
		  else
                      if(reg!=3 && reg!=7 && reg!=13 && reg!=14 & reg!=17)
		        fill(#FF0000,100);
                      else
                        fill(#000000,100);          
	      }else{
		  fill(#FFFFFF);
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




  textSize(tsize);
  textAlign(LEFT,TOP);
  rectMode(CORNER);
  fill(bg_color);
  noStroke();
  rect(0,height-barHeight*1.25,width,barHeight*1.25);
  stroke(1);
  for(int i = 0; i < cartelsJ.length-2; i++){
    int [] cartcol = cartelColor(cartelsJ[i][1].charAt(0));
    fill(255);
    rect(legendS*(i+1), height-barHeight*1.25,40,40);
   
    text(cartelsJ[i][0],legendS*(i+1), height-barHeight*1.25 + 45, 60,70);
    
    for(int j = 0; j < heatJ.length; j++){
      fill(seriesColsJ[cartcol[0]][0],heatJ[j]);
      rect(legendS*(i+1), height-barHeight*1.25 + 30 - 10*j ,40,10);
    }
  }

  textAlign(RIGHT,TOP);
  textSize(10);
  fill(255);
  text("> " + (int) bJ[2], legendS-20, height-barHeight*1.25);
  text((int) bJ[1] + " - " + (int) bJ[2], legendS-20, height-barHeight*1.25 + 10);
  text((int) bJ[0] + " - " + (int) bJ[1], legendS-20, height-barHeight*1.25 + 20);
  text("0 - " + (int) bJ[0], legendS-20, height-barHeight*1.25 + 30);
  textAlign(LEFT,TOP);
  text("Homicide Rate", 20, height-barHeight*1.25 + 45, 60,70);  
}

void drawJ() {

  //update graph
  update();

//draw map
  smooth();
  strokeWeight(0.5);
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
      		      fill(#FF0000);
      		  else
      		      fill(#000000);
	      else 
		  if(reg!=3 && reg!=7 && reg!=13 && reg!=14 & reg!=17)
		      fill(#FF0000,100);
      		  else
      		      fill(#000000,100);  
	  }else{
	      fill(#FFFFFF);
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
		fill(#008000);
		if(cartelTable.getInt(i+1,7)==1)
		    fill(#32CD32);
	    }else{   
		fill(#FFFFFF);
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

float mapitJ(float val){
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


void keyReleased(){
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

void loveplot(String fn){
    File f = new File(dataPath("")+"../"+fn);
    if(f.exists()){
	PImage locImage = loadImage(fn);
	image(locImage,joeyWidth,valeriaHeight);
    }
}
