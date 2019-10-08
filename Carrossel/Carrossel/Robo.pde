// Classe que gerencia os robos

class Robo {
 
  //Variáveis para estratégia de goleiro
  boolean chegouNoPonto = false;
  
  //Variaveis para estratégia de jogador
  boolean wasNearBola = false;
  boolean atingiuSombra = false;
  boolean proximoDaBola = false;
  
  PVector pos = new PVector(), posAnt, vel, obj;
  float ang = 0, angAnt = 0, angObj = -1;
  // Armazena o erro no valor do angulo do frame anterior
  // É propriedade da classe robo para evitar multiplas variaveis globais
  float dAngAnt = 0;
  float velD, velE, dAntiga, eAntiga;
  // Velocidades limite do robo (0 - 64)
  int velMax = 20;
  int velMin = -10;
  float velEmin = 4;
  float velDmin = 4;
  // coeficiente proporcional para o controle
  float kP;
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
  void setVel(float vE, float vD) {
    // Verifica se as velocidades estão dentro dos limites estabelecidos
    // Os ajustes para velocidade negativa é feito direto na serial
    if (vE > velMax) vE = velMax;
    else if (vE < -velMax) vE = -velMax;
    if (vD > velMax) vD = velMax;
    else if (vD < -velMax) vD = -velMax;
    velE = vE;
    velD = vD;
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

    case 1: 
      centro.x = (posVerde.x + posVermelho.x) / 2;
      centro.y = (posVerde.y + posVermelho.y) / 2;
      break;

    case 2:  // o centro é deslocado
      centro.x = (posVerde.x + posVermelho.x) / 2;
      centro.y = (posVerde.y + posVermelho.y) / 2;
      break;
    }

    posAnt = new PVector(pos.x, pos.y);
    pos = new PVector(centro.x, centro.y);
    return centro;
  }

  // Define posicao do objetivo como vetor
  void setObj(PVector income) {
    obj = income;
  }

  // Define posicao do objetivo como coordenadas
  void setObj(float x, float y) {
    if (x > width) x = width;
    if (x < 0) x = 0;
    if (y > height) y = height;
    if (y < 0) y = 0;

    obj.x = x;
    obj.y = y;
  }

  void setEstrategia(int n) {
    estrategia(this, n);
  }

  // Retorna um vetor correspondente à direçao do robo
  PVector getDir() {
    PVector dir = new PVector();
    dir.x = cos(ang);
    dir.y = sin(ang);
    return dir;
  }
  
  void inverteFrente(){
    
  }

  // Retorna o angulo do robo
  float getAng() {

    switch(index) {
    case 0:    // vermelho maior
      ang = atan2(- blobs.get(1).center().y + blobs.get(4).center().y, - blobs.get(1).center().x + blobs.get(4).center().x);
      //line(blobs.get(1).center().x, blobs.get(1).center().y, blobs.get(4).center().x, blobs.get(4).center().y);
      break;

    case 1:    // robo xadrez
      ang = atan2(- blobs.get(2).center().y + blobs.get(5).center().y, - blobs.get(2).center().x + blobs.get(5).center().x);
      ang += PI/4;
      //line(blobs.get(2).center().x, blobs.get(2).center().y, blobs.get(5).center().x, blobs.get(5).center().y);
      break;

    case 2:    // vermelho na direita
      ang = atan2(- blobs.get(3).center().y + blobs.get(6).center().y, - blobs.get(3).center().x + blobs.get(6).center().x);
      ang += atan(2) - PI/2;
      //line(blobs.get(3).center().x, blobs.get(3).center().y, blobs.get(6).center().x, blobs.get(6).center().y);
      break;
    }
    while (ang > 2*PI) ang -= 2*PI;
    while (ang < -2*PI) ang += 2*PI;

    //println("ROBO: " + index + " ang = " + degrees(ang));

    return ang;
  }

  // atualiza alguns parametros do robo
  void atualiza() {
    Robo r = new Robo(this);
    r.getAng();
    r.getPos();
    r.debugAng();
    
    if(isNear(bola)){
      proximoDaBola = true;
      wasNearBola = true;
    } else{
      if(wasNearBola) atingiuSombra = false;
      proximoDaBola = false;
      wasNearBola = false;
    }
    
    switch(r.index) {
    case 0:
      velEmin = 4;
      velDmin = 4;
      kP = 0.4;
      break;
    case 1:
      velEmin = 3;
      velDmin = 3;
      kP = 0.22;
      break;
    default:
      velEmin = 4;
      velDmin = 4;
      kP = 0.4;
      break;
    }
  }

  // Funcoes de debug
  void debugAng() {
    //println("ROBO: " + index + "  ang = " + degrees(ang));
    arrow(pos.x, pos.y, pos.x + 50*cos(ang), pos.y + 50*sin(ang));
  }
  void debugObj() {
    arrow(pos.x, pos.y, obj.x, obj.y);
    fill(255, 0, 0);
    ellipse(obj.x, obj.y, 10, 10);
  }

  boolean isNear(PVector alvo) {
    noFill();
    //ellipse(pos.x, pos.y, 50, 50);
    if (distSq(pos, alvo) < 50*50){
      println("ROBO: ISNEAR TRUE");
      return true; 
    }
    return false;
  }
}
