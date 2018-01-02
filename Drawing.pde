// Drawing.pde

// ====================================================================================================

void deleteSketch(){
  shapePoints.clear();
}

void checkVertex(float _x, float _y){
  if(onCanvas(_x,_y)){
    shapePoints.add(new PVector(map(_x,canvasOffset,canvasSize+canvasOffset,0.0,1.0),map(_y,canvasOffset,canvasSize+canvasOffset,0.0,1.0)));
  }
}

boolean onCanvas(float _x, float _y){
  return(((_x > canvasOffset) && (_x < (canvasOffset + canvasSize))) && ((_y > canvasOffset) && (_y < (canvasOffset + canvasSize))));
}

void showPoints(ArrayList<PVector> pointList, color sC, int sW){
  // inputs : points , strokecolor , strokeweight
  
  if(!pointList.isEmpty()){
    pushMatrix();
    translate(canvasOffset,canvasOffset);

    stroke(sC);
    strokeWeight(sW);

    beginShape();
    for(PVector P : pointList){
      vertex(P.x*canvasSize,P.y*canvasSize);
    }
    endShape();

    popMatrix();
  }
}

void switchSketch(){
  if(isSketching){
    println("stopping sketching");
    isSketching = false;
    }
    else{
      println("starting sketching");
      isSketching = true;
    }
}

void checkDraw(){
  if(isDrawing){
    if(motorsReady() && !waitingForPos){
      if(currentDrawIndex < shapePoints.size()){
        PVector pTemp = shapePoints.get(currentDrawIndex);
        requestData(pTemp.x,pTemp.y);
        currentDrawIndex++;
      }
      else{
        if(repeatCounter == repeat){
          println("drawing done!");
          isDrawing = false;
        }
        else{
          currentDrawIndex = 0;
        }

      }
    }
    livePoints.add(new PVector(marker.getNormalizedX(),marker.getNormalizedY()));
  }
}