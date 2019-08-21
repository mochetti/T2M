// Tolerancia de diferença entre os angulos em graus
float tolAng = 30;
// Velocidade inicial de giro
byte velGiro = 8;
// Velocidade inicial para andar reto
byte velViagem = 8;

// Alinha e anda
void alinha(Robo r) {
  // Angulo do objetivo
  float ang = atan2(r.obj.y, r.obj.x) - PI;
  float dAng = abs(r.getAng() - ang);
  //println("CONTROLE: ang obj = " + degrees(ang));
  //println("CONTROLE: ang robo = " + degrees(r.getAng()));
  //println("CONTROLE: dAng = " + degrees(dAng));
  if(dAng < radians(tolAng)) {
    // Anda reto
    println("CONTROLE: Anda reto");
    r.velE = velViagem;
    r.velD = velViagem;
  }
  else {
    // Alinha
    if(r.getAng() < ang) {
      println("CONTROLE: Gira horário");
      gira(r, true);
    }
    else {
      println("CONTROLE: Gira anti horário");
      gira(r, false);
    }
  }
}

// Gira o robo r no proprio eixo na velocidade velGiro
// sentido true : gira horário
// sentido false : gira anti horário
void gira(Robo r, boolean sentido) {
  if(sentido) {
    r.velD = byte(velGiro);
    r.velE = byte(velGiro + 64);
  }
  else {
    r.velE = byte(velGiro);
    r.velD = byte(velGiro + 64);
  }
}

// Alinha andando
void alinhandando(Robo r) {
  // O desafio maior tem sido vencer a inercia das rodas (que não é a mesma para as duas)
  // A ideia é começar numa velocidade alta independente da direção do robo em relação ao objetivo
  
  // Velocidades atuais do robo
  float velE = r.velE;
  float velD = r.velD;
  
  // Velocidades mínima e máxima
  int velMin = 20;
  int velMax = 50;
  
  // Angulo do objetivo
  PVector robObj = r.obj.sub(r.pos);
  //PVector robObj = r.getPos().sub(r.obj);
  float dAng = PVector.angleBetween(r.getDir(), robObj);
  
  println("CONTROLE: Angulo robObj = " + degrees(atan2(robObj.y, robObj.x)));
  println("CONTROLE: Angulo robo = " + degrees(r.getAng()));
  println("CONTROLE: dAng = " + degrees(dAng));
  
  /*// Verifica a inercia por distancia
  //if((velE == 0 && velD == 0) || (velE == 0 && velD == 0)) {
    if(abs(r.pos.x - r.posAnt.x) + abs(r.pos.y - r.posAnt.y) < 5) {
    // Vence a inercia
    println("CONTROLE: Vencendo a inércia");
    r.setVel(velMax, velMax);
    return;
  }
  */
  // Verifica a inercia por contagem de quadros
  if(contagemAlinhandando < 10) {
    // Vence a inercia
    println("CONTROLE: Vencendo a inércia");
    r.setVel(velMax, velMax);
    contagemAlinhandando++;
    return;
  }
  
  // Já estamos alinhando
  // PD
  float kp = 0.1, kd = 0;
  double dt = millis() - tempo;
  // A saída é a soma dos fatores P e D
  double out = kp * dAng + kd * (dAng - r.dAngAnt) / dt;
  
  println("CONTROLE: dt = " + dt);
  println("CONTROLE: out = " + out);
  
  velE -= out;
  velD += out;
  
  // Confere os limites de velocidade
  if(velE < -velMax) velE = -velMax;
  else if(velE < 0 && velE > -velMin) velE = -velMin;
  else if(velE > 0 && velE < velMin) velE = velMin;
  else if(velE > velMax) velE = velMax;
  if(velD < -velMax) velD = -velMax;
  else if(velD < 0 && velD > -velMin) velD = -velMin;
  else if(velD > 0 && velD < velMin) velD = velMin;
  else if(velD > velMax) velD = velMax;
  
  // Atribui as velocidades ao robo
  r.setVel(velE, velD);
  // Atualiza o erro antigo para o próximo frame
  r.dAngAnt = dAng;
}

// Método de controle baseado no Craig Reynolds
void arrive(Robo r) {
  // Vetor velocidade desejada
  PVector desVel = PVector.sub(r.pos, r.obj);
  // A velocidade é proporcional à distancia até o objetivo
  float distance = desVel.mag();
  if(distance < 100) {
    float m = map(distance, 0, 100, 0, r.velMax);
    desVel.setMag(m);
  }
  else desVel.setMag(r.velMax);
  
  // Vetor força de steering
  PVector steering = PVector.sub(desVel, r.vel);
  //steering.limit(100);
}

// Método de controle baseado no Craig Reynolds
void seek(Robo r) {
  // Vetor velocidade desejada
  PVector desVel = PVector.sub(r.pos, r.obj);
  desVel.normalize();
  desVel = desVel.mult(r.velMax);
  // Vetor força de steering
  PVector steering = PVector.sub(desVel, r.vel);
}

// Se a esquerda já foi configurada
boolean configEsq = false;
  
// Funcao que define alguns parametros do robo a partir de testes empiricos
void configRobo(Robo r) {
  // Descobre as velocidades minimas para cada roda
  // Configura o angulo antigo pela primeira vez
  if(r.angAnt == 0) r.angAnt = r.getAng();
  // Acompanhamos a quanto tempo tá rolando a configuracao
  double agora = millis();
  if(agora - tempo > 2000) r.angAnt = r.getAng();
  // Diferença entre o angulo atual e o inicial
  float dAng = abs(r.getAng() - r.angAnt);
  println("CONTROLE: angAnt = " + degrees(r.angAnt));
  println("CONTROLE: dAng = " + degrees(dAng));
  // Diferença mínima do angulo atual (em graus) para o inicial para configurar movimento
  int dAngMin = 5;
  // Taxa de incremento das velocidades por frame
  float taxaVel = 0.1;
  
  if(configEsq) {
    // Configura a direita depois
    if(dAng > radians(dAngMin)) {
      r.angAnt = r.getAng();
      println("CONTROLE: Velocidades definidas para o Robo " + r.index);
      println("CONTROLE: vEsq = " + r.velE + "  vDir = " + r.velD);
      configRobo = false;
    }
    else {
      // Incrementa velD
      if(r.velD <= 63) r.velD += taxaVel;
      println("CONTROLE: vDir = " + r.velD);
    }
  }
  else {
    // Configura a esquerda primeiro
    if(dAng > radians(dAngMin)) {
      r.angAnt = r.getAng();
      configEsq = true;
      return;
    }
    else {
      // Incrementa velE
      if(r.velE <= 63) r.velE += taxaVel;
      println("CONTROLE: vEsq = " + r.velE);    
    }
  }
 
 enviar();
}
