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
  
  // Angulo do objetivo
  float ang = atan2(r.obj.y, r.obj.x) - PI;
  float dAng = abs(r.getAng() - ang);

  if(dAng < radians(tolAng)) {
    // Anda reto
    println("CONTROLE: Anda reto");
    r.velE = velViagem;
    r.velD = velViagem;
  }
  
  else {
    // gira horario
    if(r.getAng() < ang) {
      if(r.velD < 64) r.velD--;
      if(r.velD == 0) r.velD = 65;
      else if(r.velD < 127) r.velD++;
      
      if(r.velE >= 64) r.velE = 0;
      if(r.velE < 64) r.velE++;
      
    }
    // gira anti horario
    else {
      if(r.velE < 64) r.velE--;
      if(r.velE == 0) r.velE = 65;
      else if(r.velE < 127) r.velE++;
      
      if(r.velD >= 64) r.velD = 0;
      if(r.velD < 64) r.velD++;
    }
  }
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
