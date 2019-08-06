void enviar() {
  byte[] txBuffer = {};
  txBuffer = new byte[7];
  txBuffer[0] = byte(128);
  if(radio) {
    for(Robo r : robos) {
      if(r.velE < 0) txBuffer[r.index+1] = byte(abs(r.velE));
      if(r.velE >= 0) txBuffer[r.index+1] = byte(r.velE+128);
      if(r.velD < 0) txBuffer[r.index+2] = byte(abs(r.velD));
      if(r.velD >= 0) txBuffer[r.index+2] = byte(r.velD+128);
    }
  }
  else {
    for(Robo r : robos) {
      txBuffer[r.index+1] = 100;
      txBuffer[r.index+2] = -100;
    }
  }
  print("SERIAL: ");
  for(byte data : txBuffer) {
    myPort.write(data);
    print(int(data) + "  ");
  }
  println("");
}
