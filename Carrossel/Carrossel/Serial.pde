void enviar() {
  byte[] txBuffer = {};
  txBuffer = new byte[7];
  txBuffer[0] = byte(80);  //80 em ascii é P (p maiusculo)  
  if (radio) {
    for (Robo r : robos) {
      if (r.index < 0) continue;
      if (r.velE != 0 || r.velD != 0) println("SERIAL: Robo " + r.index + "  Esq = " + r.velE + "  Dir = " + r.velD);
      if (r.velE < 0) txBuffer[2*(r.index)+1] = byte(abs(r.velE) + 64);
      else txBuffer[2*(r.index)+1] = byte(r.velE);
      if (r.velD < 0) txBuffer[2*(r.index)+2] = byte(abs(r.velD) + 64);
      else txBuffer[2*(r.index)+2] = byte(r.velD);
    }
  }
  // Para o robo se o radio for desabilitado
  else {
    for (Robo r : robos) {
      if (r.index < 0) continue;
      txBuffer[r.index+1] = 0;
      txBuffer[r.index+2] = 0;
    }
  }
  print("SERIAL: ");
  for (byte data : txBuffer) {
    myPort.write(data);
    print(data + "  ");
  }
  println("");
}

//Se soma 64 vai pra trás, se não somar nada vai pra frente
void enviar(int index, int velE, int velD) {
  byte[] txBuffer = {};
  txBuffer = new byte[7];
  txBuffer[0] = byte(80);  //80 em ascii é P (p maiusculo)
  for (byte data : txBuffer) {
    if (data != byte(80)) data = 0;
  }
  
  byte rodaEsq;
  byte rodaDir;
  
  if(velE < 0) rodaEsq = byte(abs(velE) + 64);
  else rodaEsq = byte(velE);
  if(velD < 0) rodaDir = byte(abs(velD) + 64);
  else rodaDir = byte(velD);
  
  txBuffer[index*2 + 1] = rodaEsq;
  txBuffer[index*2 + 2] = rodaDir;
  println("SERIAL: Robo " + roboControlado + "  Esq = " + velE + "  Dir = " + velD);
  print("SERIAL: ");
  for (byte data : txBuffer) {
    myPort.write(data);
    print(data + "  ");
  }
}
