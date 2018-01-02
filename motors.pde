// motors.pde

// ====================================================================================================

// Functions handling both motors

boolean motorsReady(){
  return (motorArray[0].motorReady() && motorArray[1].motorReady());
}

void commandMotors(float _x, float _y){
  motorArray[0].setTarget(_x);
  motorArray[1].setTarget(_y);
}