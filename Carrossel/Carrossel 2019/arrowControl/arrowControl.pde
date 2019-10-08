import processing.serial.*;
Serial myPort;
float velE, velD, vel = 10;
boolean radio = false;
int indexRobo = 0;

void setup() {
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[3], 115200);
}

void draw() {
  if(radio) enviar();
}

void keyPressed() {
  if (key >= '0' && key <= '2') {
    indexRobo = key - 48;
    println("Robo " + indexRobo);
  }
  if (key == 'r') radio = !radio;
  if (key == CODED) {
    if (keyCode == UP) {
      velE = vel; 
      velD = vel;
    } else if (keyCode == DOWN) {
      velE = -vel; 
      velD = -vel;
    } else if (keyCode == LEFT) {
      velE = -vel; 
      velD = vel;
    } else if (keyCode == RIGHT) {
      velE = vel; 
      velD = -vel;
    }
  }
}

void keyReleased() {
  velE = 0;
  velD = 0;
}

void enviar() {
  byte[] txBuffer = {};
  txBuffer = new byte[7];
  txBuffer[0] = byte(128);
  if (radio) {
    println("SERIAL:" + "  velE = " + velE + "  velD = " + velD);
    if (velE < 0) txBuffer[2*indexRobo+1] = byte(abs(velE) + 64);
    else txBuffer[2*indexRobo+1] = byte(velE);
    if (velD < 0) txBuffer[2*indexRobo+2] = byte(abs(velD) + 64);
    else txBuffer[2*indexRobo+2] = byte(velD);
  }
  // Para o robo se o radio for desabilitado
  else {
    txBuffer[2*indexRobo+1] = 0;
    txBuffer[2*indexRobo+2] = 0;
  }
  print("SERIAL: ");
  for (byte data : txBuffer) {
    myPort.write(data);
    print(data + "  ");
  }
  println("");
}
