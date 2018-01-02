// Websocket.pde

// ====================================================================================================

void wsSendSample(Sample sendSample){
  print("sending command -> new data : ");
  String msg = "ip,";
  for(int i = 0; i<4;i++){
    msg+=sendSample.data[i];
    if(i!=3){
      msg+=',';
    }
  }
  println(msg.substring(3));
  wsc.sendMessage(msg);
}

void activateLearning() {
  println("sending command -> start learning");
  wsc.sendMessage("l");
}

void requestData(float _x, float _y){
  println("sending command -> request data");
  waitingForPos = true;
  String msg = "o," + _x + "," + _y;
  wsc.sendMessage(msg);
}

void saveNetToFile(String filename){
  println("sending command -> save net");
  String msg = "s," + filename;
  wsc.sendMessage(msg);
}

void webSocketEvent(String msg){
  //println("Incoming WS Message: " + msg);
  if(msg.equals("trained")){
    println("Model trained successfully");
    modelTrained = true;
  }

  else if(msg.equals("ping")){
    wsAlive();
  }




  if(waitingForPos){
    waitingForPos = false;
    String[] inData = split(msg,',');
    if(inData[0].equals("nt")){
      isDrawing = false;
      isSketching = false;
      currentDrawIndex = 0;
      livePoints.clear();
      println("No trained model found");
    }
    else{
      println("Received new positionData: " + inData[1] + " | " + inData[2]);
      commandMotors(float(inData[1]),float(inData[2]));
    }
  }
}

void wsAlive(){
  println("Websocket live");
}

void keepAlive(){
  if(lastAliveTime + 5000 < millis()){
    lastAliveTime = millis();
    wsc.sendMessage("ping");
  }
}