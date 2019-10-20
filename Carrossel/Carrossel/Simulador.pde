// Geras robos virtuais para testar estratégias especificas do codigo

// mostra qual robo está sendo controlado pelas setas (altera o robo usando o TAB)
int roboControlado = 0;

// bola virtual
Bola bolaV = new Bola(false);

void simulador() {
  if (robosSimulados.size() == 0) {
    robosSimulados.add(new Robo(500, 100, 0));
    robosSimulados.add(new Robo(400, 200, 1));
    robosSimulados.add(new Robo(100, 300, 2));
  }

  // mostra na tela
  robosSimulados.get(0).simula();
  robosSimulados.get(1).simula();
  robosSimulados.get(2).simula();
  robosSimulados.get(0).display();
  robosSimulados.get(1).display();
  robosSimulados.get(2).display();


  // simula a bola
  // chute inicial
  if (bolaV.pos.x == 0 && bolaV.pos.y == 0) {
    println("SIM: chute inicial");
    bolaV.pos.x = width/2;
    bolaV.pos.y = height/2;
    bolaV.vel = new PVector(5, 5);
  }
  // atrito
  // direcao do atrito (precisa ser contra o movimento)
  float kX = 1;
  float kY = 1;
  if (bolaV.vel.x > 0) kX = -1;
  if (bolaV.vel.y > 0) kY = -1;

  if (bolaV.vel.mag() == 0) bolaV.acc.set(0, 0);
  else bolaV.acc = new PVector(kX/20, kY/30);

  //println("acc = " + bolaV.acc);
  //println("vel = " + bolaV.vel);

  //NAO MEXER
  bolaV.atualiza();
  bolaV.display();
  //////

  // atribui o vetor velocidade e angulo
  if (simManual) {
    robosSimulados.get(roboControlado).setAng(robosSimulados.get(roboControlado).ang + simulaAng(robosSimulados.get(roboControlado)));
    robosSimulados.get(roboControlado).setVel(simulaVel(robosSimulados.get(roboControlado)));
    // atualiza a posicao
    robosSimulados.get(roboControlado).pos.add(robosSimulados.get(roboControlado).vel);
  } else {
    for (int i=0; i<robosSimulados.size(); i++) {
      robosSimulados.get(i).setAng(robosSimulados.get(i).ang + simulaAng(robosSimulados.get(i)));
      robosSimulados.get(i).setVel(simulaVel(robosSimulados.get(i)));
      // atualiza a posicao
      robosSimulados.get(i).pos.add(robosSimulados.get(i).vel);
    }
  }

  //println("SIMULADOR: goleiro.vel = " + goleiro.vel);
  //println("SIMULADOR: goleiro.pos = " + goleiro.pos);

  //// mostra na tela
  //robosSimulados.get(0).display();
  //robosSimulados.get(1).display();
  //robosSimulados.get(2).display();
  //bolaV.atualiza();
  //bolaV.display();
}



// devolve o vetor velocidade
PVector simulaVel (Robo r) {
  PVector vel = new PVector();
  int v = 5;
  int k = 1;
  if (r.frente) k = -1;
  //println("SIM: Robo " + r.index + " frente = " + r.frente);
  // usando como entrada as setas do teclado
  if (simManual) {
    if (!keyPressed) r.setVel(new PVector(0, 0));
    else if (key == CODED) {
      if (keyCode == UP) {
        //println("SIMULADOR: frente");
        vel = new PVector(k*cos(r.ang)*v, k*sin(r.ang)*v);
      } else if (keyCode == DOWN) {
        //println("SIMULADOR: trás");
        vel = new PVector(k*-cos(r.ang)*v, k*-sin(r.ang)*v);
      }
    }
  }

  // usando como entrada o módulo de controle
  else if (robos.size() > 0) {
    if (robos.get(r.index).velE > 0 && robos.get(r.index).velD > 0) vel = new PVector(cos(r.ang)*v, sin(r.ang)*v);
    else if (robos.get(r.index).velE < 0 && robos.get(r.index).velD < 0) vel = new PVector(-cos(r.ang)*v, -sin(r.ang)*v);
  }
  //println(vel);
  return vel;
}

// devolve o dAng
float simulaAng(Robo r) {
  float dAng = 0;
  // velocidade angular média do robo
  float velAng = 0.05;

  // usando como entrada as setas do teclado
  if (simManual) {
    if (!keyPressed) dAng = 0;
    else if (key == CODED) {
      if (keyCode == LEFT) {
        //println("SIMULADOR: esquerda");
        dAng -= velAng;
      } else if (keyCode == RIGHT) {
        //println("SIMULADOR: direita");
        dAng += velAng;
      }
    }
  }

  // usando como entrada o módulo de controle
  else if (robos.size() > 0) {
    if (robos.get(r.index).velE > 0 && robos.get(r.index).velD < 0) dAng += velAng;
    else if (robos.get(r.index).velE < 0 && robos.get(r.index).velD > 0) dAng -= velAng;
    // pra frente e pra trás
    else dAng = 0;
  }
  return dAng;
}
