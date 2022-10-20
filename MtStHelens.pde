// CSci-5609 Mt. St. Helens 3D Processing Visualization Assignment
// Original authors:  Sarit Ghildayal and Jung Nam, Univ. of Minnesota 2014


// bounds for the x and y dimensions of the regular grid that the data are sampled on
int xDim = 240;
int yDim = 346;

// the gridded data are stored in these arrays in column-major order.  that means the entire
// x=0 column is listed first in the array, then the entire x=1 column, and so on.  this is
// a typical way to store data that conceptually fit within a 2D array in a regular 1D array.
// there are helper functions at the bottom of this file that let you access the data directly
// by (x, y) locations in the array, so you don't have to worry too much about this if you
// don't want.
PVector[] beforePoints;
PVector[] beforeNormals;
PVector[] afterPoints;
PVector[] afterNormals;

// can be switched with the arrow keys
int displayMode = 1;

// each unit is 10 meters
// model centered around x,y and lowest z (height) value is 0
float xMin = -469.44;   
float xMax = 465.52792;
float yMin = -678.8792; 
float yMax = 674.9551;
float minElevation = 0;
float maxElevation = 199.51196;


void setup() {
  size(1280, 900, P3D);  // Use the P3D renderer for 3D graphics
  
  // load in .csv files
  Table beforeTable = loadTable("beforeGrid240x346.csv", "header"); 
  Table afterTable = loadTable("afterGrid240x346.csv", "header"); 
  
  //initialize Point Cloud data arrays
  beforePoints = new PVector[xDim*yDim];
  afterPoints = new PVector[xDim*yDim];
  
  // fill before and after arrays with PVector point cloud data points
  for (int i = 0; i < beforeTable.getRowCount(); i++) {
    beforePoints[i] = new PVector(beforeTable.getRow(i).getFloat("x"), 
                                  beforeTable.getRow(i).getFloat("y"), 
                                  beforeTable.getRow(i).getFloat("z"));
  }
  for (int i = 0; i < afterTable.getRowCount(); i++) {
    afterPoints[i] = new PVector(afterTable.getRow(i).getFloat("x"), 
                                 afterTable.getRow(i).getFloat("y"), 
                                 afterTable.getRow(i).getFloat("z"));
  } 
  
  //Initialize and fill arrays of the before and after data normals
  beforeNormals = new PVector[xDim*yDim];
  afterNormals = new PVector[xDim*yDim];
  calculateNormals();  // function defined on the bottom
}


void draw() {
  float minDist = 200;
  float maxDist = 1500;
  float cameraDistance = lerp(minDist, maxDist, float(mouseY)/height);
  camera(cameraDistance, cameraDistance, cameraDistance, 0,0,0,0,0,-1);
  rotateZ(radians(0.25*mouseX));
  background(0);  // reset background to black
  stroke(255);    // set stroke to white
  
  if (displayMode == 1) {  // point cloud before  // Step One
    for(PVector v : beforePoints){
      point(v.x,v.y,v.z);
    }
  } 
  else if (displayMode == 2) {  // point cloud after  // Step One
    for(PVector v : afterPoints){
      point(v.x,v.y,v.z);
    }
  } 
  else if (displayMode == 3) {  // mesh before  // Step Three
    directionalLight(255,255,255,1,-0.5,-0.5);
    noStroke();
    
    for(int x = 0; x < xDim-1; x++)
    {
      beginShape(TRIANGLE_STRIP);
      for(int y = 0; y < yDim; y++)
      {
        PVector n1 = getBeforeNormal(x,y);
        PVector v1 = getBeforePoint(x,y);
        PVector n2 = getBeforeNormal(x+1,y);
        PVector v2 = getBeforePoint(x+1,y);
        normal(n1.x,n1.y,n1.z);
        vertex(v1.x,v1.y,v1.z);
        normal(n2.x,n2.y,n2.z);
        vertex(v2.x,v2.y,v2.z);
      }
      endShape();
    }
    
  } 
  else if (displayMode == 4) {  // mesh after  // Step Three
    directionalLight(255,255,255,1,-0.5,-0.5);
    noStroke();
    
    for(int x = 0; x < xDim-1; x++)
    {
      beginShape(TRIANGLE_STRIP);
      for(int y = 0; y < yDim; y++)
      {
        PVector n1 = getAfterNormal(x,y);
        PVector v1 = getAfterPoint(x,y);
        PVector n2 = getAfterNormal(x+1,y);
        PVector v2 = getAfterPoint(x+1,y);
        normal(n1.x,n1.y,n1.z);
        vertex(v1.x,v1.y,v1.z);
        normal(n2.x,n2.y,n2.z);
        vertex(v2.x,v2.y,v2.z);
      }
      endShape();
    }
  } 
  else if (displayMode == 5) {  // lines from before to after  // Step Four
    for(int i = 0; i < xDim; i++){
      for(int j = 0; j < yDim; j++){
        PVector bv = getBeforePoint(i,j);
        PVector av = getAfterPoint(i,j);
        if(av.z <= bv.z)
          stroke(#fc8d59);
        else
          stroke(#91cf60);

        line(av.x,av.y,av.z, bv.x,bv.y,bv.z);
      }
    }
  }
  else if (displayMode == 6) {  // your choice  // Step Five
    camera();
    scale(1,-1);
    translate(.5*width, -height);
    int t = millis();
    int m = t % 5000;
    float p = (float)m / 5000;
    int line = (int)(p * xDim);
    for(int i = 0; i < yDim; i++)
    {
      PVector bv = getBeforePoint(line, i);
      PVector av = getAfterPoint(line, i);
      if(av.z <= bv.z)
        stroke(#fc8d59);
      else
        stroke(#91cf60);
        
      line(bv.y,bv.z,av.y,av.z);
    }
  }
}


// Helper functions for accessing the point data by (x, y) location
PVector getBeforePoint(int x, int y) { 
  PVector beforeVec = beforePoints[(x*yDim)+y];
  return new PVector(beforeVec.x, beforeVec.y, beforeVec.z);
}

PVector getAfterPoint(int x, int y) {
  PVector afterVec = afterPoints[(x*yDim)+y];
  return new PVector(afterVec.x, afterVec.y, afterVec.z);
}


// Helper functions for accessing the normal data by (x, y) location
PVector getBeforeNormal(int x, int y) { 
  PVector beforeVec = beforeNormals[(x*yDim)+y];
  return new PVector(beforeVec.x, beforeVec.y, beforeVec.z);
}

PVector getAfterNormal(int x, int y) {
  PVector afterVec = afterNormals[(x*yDim)+y];
  return new PVector(afterVec.x, afterVec.y, afterVec.z);
}



void keyPressed() {
  if (key == '1') {
    displayMode = 1;
  }
  if (key == '2') {
    displayMode = 2;
  }
  if (key == '3') {
    displayMode = 3;
  }
  if (key == '4') {
    displayMode = 4;
  }
  if (key == '5') {
    displayMode = 5;
  }
  if (key == '6') {
    displayMode = 6;
  }
}


// Utility routine for calculating the normals of the triangle mash from vertex locations
void calculateNormals() {
  int normalStep = 6;
  for (int x = 0; x < xDim; x+=1) {
    for(int y = 0; y < yDim; y+=1) {
      PVector current = beforePoints[(x*yDim)+y]; //before(x,y);
      PVector north = new PVector(current.x, current.y, current.z);
      PVector south = new PVector(current.x, current.y, current.z);
      PVector west = new PVector(current.x, current.y, current.z);
      PVector east = new PVector(current.x, current.y, current.z);
      
      if (x-normalStep >= 0) {
        PVector w = beforePoints[((x-normalStep)*yDim)+y]; //before(x-normalStep,y);
        west = new PVector(w.x,w.y,w.z);
      }
      if (x+normalStep < xDim) {
        PVector e = beforePoints[((x+normalStep)*yDim)+y]; //before(x+normalStep,y);
        east = new PVector(e.x,e.y,e.z);
      }
      if (y-normalStep >= 0) {
        PVector s = beforePoints[(x*yDim)+(y-normalStep)]; //before(x,y-normalStep);
        south = new PVector(s.x,s.y,s.z);
      }
      if (y+normalStep < yDim) {
        PVector n = beforePoints[(x*yDim)+(y+normalStep)]; //before(x,y+normalStep);
        north = new PVector(n.x,n.y,n.z);
      }
      
      PVector eastVec = PVector.sub(east,west);
      PVector northVec = PVector.sub(north,south);
      eastVec.normalize();
      northVec.normalize();
      
      PVector norm = eastVec.cross(northVec);
      norm.normalize();
      beforeNormals[(x*yDim)+y] = norm; //new PVector(0,0,1);
    }
  }
  for (int x = 0; x < xDim; x+=1) {
    for(int y = 0; y < yDim; y+=1) {
      PVector current = afterPoints[(x*yDim)+y]; //before(x,y);
      PVector north = new PVector(current.x, current.y, current.z);
      PVector south = new PVector(current.x, current.y, current.z);
      PVector west = new PVector(current.x, current.y, current.z);
      PVector east = new PVector(current.x, current.y, current.z);
      
      if (x-normalStep >= 0) {
        PVector w = afterPoints[((x-normalStep)*yDim)+y]; //before(x-normalStep,y);
        west = new PVector(w.x,w.y,w.z);
      }
      if (x+normalStep < xDim) {
        PVector e = afterPoints[((x+normalStep)*yDim)+y]; //before(x+normalStep,y);
        east = new PVector(e.x,e.y,e.z);
      }
      if (y-normalStep >= 0) {
        PVector s = afterPoints[(x*yDim)+(y-normalStep)]; //before(x,y-normalStep);
        south = new PVector(s.x,s.y,s.z);
      }
      if (y+normalStep < yDim) {
        PVector n = afterPoints[(x*yDim)+(y+normalStep)]; //before(x,y+normalStep);
        north = new PVector(n.x,n.y,n.z);
      }
      
      PVector eastVec = PVector.sub(east,west);
      PVector northVec = PVector.sub(north,south);
      eastVec.normalize();
      northVec.normalize();
      
      PVector norm = eastVec.cross(northVec);
      norm.normalize();
      afterNormals[(x*yDim)+y] = norm; //new PVector(0,0,1);
    }
  }
}
