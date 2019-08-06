// Classe que gerencia os robos

class Robo {
  PVector pos, vel, obj;
  float ang = 0;
  byte velD, velE;
  // Velocidade maxima do robo
  byte velMax = byte(200);
  int v = 0;
  int index;
  
  Robo(int n) {
    index = n;
    ang = getAng();
    pos = getPos();
    vel = new PVector();
    obj = new PVector();
  }
  
  Robo(Robo r) {
    pos = r.pos;
    vel = r.vel;
    ang = r.ang;
    index = r.index;
  }
  
  void setVel(PVector income) {
    vel = income;
  }
  void setVel(float v1, float v2) {
    vel.set(v1, v2);
  }
  
  // Calcula o centro real do robo
  PVector getPos() {
    PVector centro = new PVector();
    PVector posVerde = new PVector(blobs.get(index+1).center().x, blobs.get(index+1).center().y);
    PVector posVermelho = new PVector(blobs.get(index+4).center().x, blobs.get(index+4).center().y);
    switch(index) {
      case 0:  // o centro é media aritmetica dos centros dos blobs
        centro.x = (posVerde.x + posVermelho.x) / 2;
        centro.y = (posVerde.y + posVermelho.y) / 2;
      break;
      
      case 1: // o centro é deslocado
        centro.x = (posVerde.x + posVermelho.x) / 2;
        centro.y = (posVerde.y + posVermelho.y) / 2;
      break;
      
      case 2:
        centro.x = (posVerde.x + posVermelho.x) / 2;
        centro.y = (posVerde.y + posVermelho.y) / 2;
      break;
    }
    return centro;
  }
  
  // Define posicao do objetivo como vetor
  void setObj(PVector income) {
    obj = income;
    //println(velObj);
  }
  
  // Define posicao do objetivo como coordenadas
  void setObj(float x, float y) {
    if(x > width) x = width;
    if(x < 0) x = 0;
    if(y > height) y = height;
    if(y < 0) y = 0;
    
    obj.x = x;
    obj.y = y;
  }
  
  void setEstrategia(int n) {
    estrategia(this, n);
  }
  void setAng(float income) {
    ang = income;
  }
  
  float getAng() {
    
    switch(index) {
      case 0:    // verde embaixo
        ang = atan2(- blobs.get(1).center().y + blobs.get(4).center().y, - blobs.get(1).center().x + blobs.get(4).center().x);
        //line(blobs.get(1).center().x, blobs.get(1).center().y, blobs.get(4).center().x, blobs.get(4).center().y);
      break;
      
      case 1:    // verde na esquerda
        ang = atan2(- blobs.get(2).center().y + blobs.get(5).center().y, - blobs.get(2).center().x + blobs.get(5).center().x);
        ang += (PI/2 - atan(2));
        //line(blobs.get(2).center().x, blobs.get(2).center().y, blobs.get(5).center().x, blobs.get(5).center().y);
      break;
      
      case 2:    // verde na direita
        ang = atan2(- blobs.get(3).center().y + blobs.get(6).center().y, - blobs.get(3).center().x + blobs.get(6).center().x);
        ang -= (PI/2 - atan(2));
        //line(blobs.get(3).center().x, blobs.get(3).center().y, blobs.get(6).center().x, blobs.get(6).center().y);
      break;
    }
    while(ang > 2*PI) ang -= 2*PI;
    while(ang < -2*PI) ang += 2*PI;
    return ang;
  }
  
  // Funcoes de debug
  void debugAng() {
    //println(degrees(ang));
    arrow(pos.x, pos.y, pos.x + 50*cos(ang), pos.y + 50*sin(ang));
  }
  void debugObj() {
    arrow(pos.x, pos.y, obj.x, obj.y);
    fill(255, 0, 0);
    ellipse(obj.x, obj.y, 10, 10);
  }
  void show() {
    
  }
}
