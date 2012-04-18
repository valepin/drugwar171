class Collect {
  
  int numRows;
  int numCols;
  String[] rowNames;
  
  // data stored as strings by default, convert where necessary
  String[][] data; 
  
  // Assumes properly formed TSV with no row names
  Collect (String filename) {
    
    String[] rows = loadStrings(filename);
    String[] columns = split(rows[0], TAB);
    this.rowNames = columns;
    this.numRows = rows.length - 1;
    this.numCols = columns.length;
    this.data = new String[this.numRows][this.numCols];
    
    for (int i = 1; i < rows.length; i++) {
      String[] rowColumns = split(rows[i], TAB);
      this.data[i-1] = rowColumns;
    }
  }
 
 String[] getColumnNames () { return this.rowNames; }
 
 String[][] getData () { return this.data; }
 
 String getDataAt (int row, int column) { return this.data[row][column]; }
 
 float getFloatAt(int row, int column) { return parseFloat(this.data[row][column]); }
 
 int fieldIndex (String field) {
   for (int index = 0; index < this.rowNames.length; index++) {
     String column = this.rowNames[index];
     if (column.equals(field)) { return index; }
   }
   return -1; // field not found in row names
 }
 
 // Determines the maximum numerical value in a column
 float columnMax (int column) {
   float cMax = parseFloat(this.data[0][column]);
   for (int i = 0; i < this.data.length; i++) {
     float value = parseFloat(this.data[i][column]);
     if (value > cMax) {
       cMax = value;
     }
   }
   return cMax;
 }
 
 float columnMin (int column) {
   float cMin = parseFloat(this.data[0][column]);
   for (int i = 0; i < this.data.length; i++) {
     float value = parseFloat(this.data[i][column]);
     if (value < cMin) {
       cMin = value;
     }
   }
   return cMin;
 }
 
}
