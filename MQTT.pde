// MQTT.pde

// ====================================================================================================

// MQTT message handling

void messageReceived(String topic, byte[] payload) {

  String msg = new String(payload);
  //println("new message: " + topic + " - " + msg);

  String[] topicList = split(topic, '/');
  if(topicList[0].equals("register")){
    println("new motor registered");
  }
  else{
    int index = int(topicList[1]);
    if (topicList[2].equals("pos")) {
      motorArray[index].updatePos(float(msg));
    } else if (topicList[2].equals("sts")) {
      motorArray[index].updateState(int(msg));
    }
  }
}