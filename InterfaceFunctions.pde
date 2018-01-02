// InterfaceFunctions.pde

// ====================================================================================================


// row 1

void zero(){
  motorArray[0].setTarget(0);
  motorArray[1].setTarget(0);
}

void stopall(){
  motorArray[0].setSpeed(0);
  motorArray[1].setSpeed(0);
}

void recalibrate(){
  motorArray[0].recalibrate();
  motorArray[1].recalibrate();
}

void remap(){
  if(caseByte == 0){
    caseByte = 1;
    //cp5.setVisible(false);
  }
  else{
    caseByte = 0;
  }
}

// row 2

void toggleSampling(boolean theFlag){
  if(theFlag){
    println("Starting to sample data.");
    isSampling = true;
    lastSample = millis();
  }
  else{
    println("Stopping to sample data.");
    isSampling = false;
  }
}

void startLearn(){
  println("starting transfer of samples");
  transferSamples();
  println("finished transferring samples");
  activateLearning();
}

void save(){
  saveSamplesToFile();
}

void load(){
  loadSamplesFromFile();
}

// row 3
void startSketch(){
  switchSketch();
}

void delSketch(){
  deleteSketch();
}

void startDraw(){
    if(shapePoints.isEmpty()){
      println("No drawing found!");
    }
    else{
      isDrawing = true;
      isSketching = false;
      currentDrawIndex = 0;
      livePoints.clear();
      println("Starting drawing process!");
    }
}

void stopDraw(){
  isDrawing = false;
}