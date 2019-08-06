// Tolerancia de diferença entre os angulos
float dAng = 15;
byte velGiro = 60;

// Alinha e anda
void alinha(Robo r) {
  // Angulo do objetivo
  float ang = atan2(r.obj.x, r.obj.y);
  if(abs(r.getAng() - ang) < radians(dAng)) {
    // Anda reto
    r.velE = r.velMax;
    r.velD = r.velMax;
  }
  else {
    // Alinha
    if((r.getAng() - ang) < 0)
      gira(r, true);
    else gira(r, false);
  }
}

// Gira o robo r no proprio eixo na velocidade v
// sentido true : gira horário
// sentido false : gira anti horário
void gira(Robo r, boolean sentido) {
  if(sentido) {
    r.velD = velGiro;
    r.velE = byte(-velGiro);
  }
  else {
    r.velE = velGiro;
    r.velD = byte(-velGiro);
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
