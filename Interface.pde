// Interface.pde

// ====================================================================================================

// UI parameters
  
  ControlP5 cp5;
  ControlP5 remapControl;

  // Parameters
  
    int transformOffset = 20;
        
    int cornerSize = 10;
    
    
    
    // Slider Parameters
    int barHeight = 10;
    int barWidth = 580;
    
    // Canvas Paramters
    int canvasOffset = 122;
    int canvasSize = 500;
    
    boolean drawVideo = false;
    
    
    
    PFont p; // regular font
    PFont pb; // bold font
    
    // UI colors
    
    color darkblue = color(26, 26, 30);
    color white = color(255, 255, 255);
    
    color col1 = color(230);
    color col1_2 = color(230,150);
    color col2 = color(27, 198, 180);
    color col3 = color(255, 33, 81);
  
  // Variables
  
    boolean mouseLocked = false;
 
// ====================================================================================================

void drawMarker(float _x, float _y, int dia) {
  stroke(white);
  fill(darkblue);
  strokeWeight(1);

  pushMatrix();
  translate(_x, _y);

  line(0, -dia/2, 0, dia/2);
  line(-dia/2, 0, dia/2, 0);
  rect(-10, -10, 20, 20);
  drawCross(0, 0);

  popMatrix();
}

void drawMarker(float _x, float _y, int dia, int ellipseOff, int lineOff) {
  setLineStyle();
  pushMatrix();
  translate(_x, _y);
  line(0, lineOff, 0, dia/2);
  line(0, -lineOff, 0, -dia/2);
  line(lineOff, 0, dia/2, 0);
  line(-lineOff, 0, -dia/2, 0);

  ellipse(0, 0, dia+ellipseOff, dia+ellipseOff);
  popMatrix();
}

void drawMarker(float _x, float _y, int dia, int lineOff) {
  pushMatrix();
  translate(_x, _y);
  line(0, lineOff, 0, dia/2);
  line(0, -lineOff, 0, -dia/2);
  line(lineOff, 0, dia/2, 0);
  line(-lineOff, 0, -dia/2, 0);

  popMatrix();
}

void drawNode(float x, float y, int s) {
  stroke(white);
  strokeWeight(255);
  fill(col2);
  rect(x-s/2, y-s/2, s, s);
}

void drawFrame() {
  setFillStyle();
  beginShape();
  vertex(0, 0);
  vertex(cam.width, 0);
  vertex(cam.width, cam.height);
  vertex(0, cam.height);

  beginContour();
  for (DragPoint dP : dragPoints) {
    vertex(dP.pos.x, dP.pos.y);
  }
  endContour();
  endShape(CLOSE);
}

void drawCorners(float posX, float posY, float _width, float _height, int size) {
  setLineStyle();
  pushMatrix();
  translate(posX, posY);

  drawCorner(0, 0, -size, -size);
  drawCorner(0, _height, -size, size);
  drawCorner(_width, _height, size, size);
  drawCorner(_width, 0, size, -size);

  popMatrix();
}

void drawCorner(int size) {
  setLineStyle();
  beginShape();
  vertex(0, -size);
  vertex(0, 0);
  vertex(-size, 0);
  endShape();
}

void drawCorner(float x, float y, int sizeX, int sizeY) {
  line(x, y, x+sizeX, y);
  line(x, y, x, y+sizeY);
}

void setLineStyle() {
  stroke(255);
  strokeWeight(1);
  noFill();
}

void setLineStyle(int c) {
  stroke(c);
  strokeWeight(1);
  noFill();
}

void setFillStyle() {
  noStroke();
  fill(255, 50);
}

void drawCrossHair(PVector targetN, int frameWidth, int frameHeight, int offset) {
  setLineStyle();
  float targetX = targetN.x * frameWidth;
  float targetY = targetN.y * frameHeight;

  line(targetX, 0, targetX, targetY-offset);
  line(targetX, targetY + offset, targetX, frameHeight);

  line(0, targetY, targetX-offset, targetY);
  line(targetX + offset, targetY, frameWidth, targetY);
}




void displayWarped() {
  // Display warped image
  pushMatrix();
  translate(imageTransformDelta.x, imageTransformDelta.y);
  if (drawVideo) {
    image(warpedCanvas, 0, 0);
    marker.display(0);
  } else {
    drawCrossHair(marker.posN, warpedCanvas.width, warpedCanvas.height, 20);
    marker.display(255);
  }


  drawCorners(0, 0, warpedCanvas.width, warpedCanvas.height, cornerSize);

  popMatrix();
}

void checkFrames() {
  if (newFrame)
  {
    newFrame=false;

    opencv.loadImage(cam);
    warpImg(warpedCanvas, canvasSize, transformPoints);

    img.copy(warpedCanvas, 0, 0, canvasSize, canvasSize, 0, 0, img.width, img.height);
    img.filter(INVERT);

    fastblur(img, 2);
    theBlobDetection.computeBlobs(img.pixels);
    int blobCount = theBlobDetection.getBlobNb();
    if (mouseLocked) {
      if (blobCount > 2) {
        detectionThreshold -= blobThreshDelta;
        theBlobDetection.setThreshold(detectionThreshold);
      } else if (blobCount == 0) {
        detectionThreshold += (3*blobThreshDelta);
        theBlobDetection.setThreshold(detectionThreshold);
      }
    }
    marker.updatePos(getMarkerPosition());
  }
}

void mousePressed() {
  if (!mouseLocked) {
    mouseLocked = true;
    for (DragPoint DP : dragPoints) {
      DP.checkDrag();
    }
  }
}

void mouseClicked(){
  if(isSketching){
    checkVertex(mouseX, mouseY);
  }
}

void mouseReleased() {
  for (DragPoint DP : dragPoints) {
    DP.isDragged = false;
  }
  mouseLocked = false;
}

void drawCross(float x, float y) {
  stroke(white);
  strokeWeight(1);
  line(x-2, y-2, x+2, y+2);
  line(x-2, y+2, x+2, y-2);
}

void drawCorners(float x, float y, float w, float h, float s) {
  beginShape();
  vertex(x, y-s);
  vertex(x, y);
  vertex(x-s, y);
  endShape();

  beginShape();
  vertex(x+w, y-s);
  vertex(x+w, y);
  vertex(x+w+s, y);
  endShape();

  beginShape();
  vertex(x+w+s, y+h);
  vertex(x+w, y+h);
  vertex(x+w, y+h+s);
  endShape();

  beginShape();
  vertex(x, y+h+s);
  vertex(x, y+h);
  vertex(x-s, y+h);
  endShape();
}

void drawGrid(float x, float y, float w, float h, float count) {
  float delta = w / count;
  for (float i = 1; i< count; i++) {
    for ( float j = 1; j<count; j++) {
      drawCross(x + (delta * i), y + (delta * j));
    }
  }
}

void drawPoint(float _x, float _y){
  stroke(white);
  strokeWeight(2);
  point(_x,_y);
}

void toggleVideo() {
  drawVideo = !drawVideo;
}

class DragPoint {
  int dragThresh = 10;
  int dia = 20;
  PVector pos;
  boolean isDragged = false;
  DragPoint(PVector _pos) {
    pos = _pos;
  }

  public void display() {
    setLineStyle();
    drawMarker(this.pos.x, this.pos.y, 50);
  }

  public void update() {
    if (isDragged) {
      pos.x += (mouseX-pmouseX);
      pos.y += (mouseY-pmouseY);
      println(pos.x + ", " + pos.y);
    }
  }

  public void checkDrag() {
    if (mouseOver()) {
      isDragged = true;
      println("drag");
    } else {
      isDragged = false;
    }
  }

  private boolean mouseOver() {
    PVector posTemp = this.getTransformedCoords();
    return (abs(mouseX-posTemp.x)<dragThresh) && (abs(mouseY-posTemp.y)<dragThresh);
  }

  public void setDiameter(int _dia) {
    dia = _dia;
  }

  PVector getTransformedCoords() {
    return new PVector(pos.x+imageTransformDelta.x, pos.y+imageTransformDelta.y);
  }
}