// classe que cuida da bola real e virtual
class Bola {
  PVector pos = new PVector();
  PVector vel = new PVector();
  PVector acc = new PVector();

  Bola() {
  }

  Bola(PVector posicao) {
    pos = posicao;
  }

  Bola(float x, float y) {
    pos.x = x;
    pos.y = y;
  }

  Bola(PVector posicao, PVector velocidade, PVector aceleracao) {
    pos = posicao;
    vel = velocidade;
    acc = aceleracao;
  }

  void atualiza() {
    // precisa de um valor minimo, caso contrario ela só "tende" a zero
    if (vel.mag() < 0.05) vel.set(0, 0);
    vel.add(acc);
    pos.add(vel);

    // rebote
    if (pos.x < 0 || pos.x > width) vel = new PVector(-vel.x, vel.y);
    if (pos.y < 0 || pos.y > height) vel = new PVector(vel.x, -vel.y);

    // colisoes
    for (int i=0; i<robosSimulados.size(); i++) {
      if (isInside(b, robosSimulados.get(i).corpo.getChild(0), robosSimulados.get(i).pos)) {
        println("SIMULADOR: choque com o robo " + robosSimulados.get(i).index);
        float angBola = atan(velBola().y / velBola().x);
        float dAng = PVector.angleBetween(velBola(), robosSimulados.get(i).pos);
        dAng *= 2;
        float magAnt = vel.mag();
        vel.set(cos(angBola) + cos(dAng), sin(angBola) + sin(dAng));
        vel.setMag(magAnt);
      };      // rebate e aumenta a velocidade
    }
    // rebate e aumenta a velocidade
  }
}

// retorna o vetor direçao da bola
PVector getDir() {
  PVector dir = new PVector();
  return dir;
}

void display() {
  fill(245, 166, 73);
  ellipse(pos.x, pos.y, 10, 10);
}
}
