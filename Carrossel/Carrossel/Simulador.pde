// Utiliza robos virtuais para testar estratégias especificas do codigo


// mostra qual robo ta sendo controlado pelas setas (altera o robo usando o TAB)
int roboControlado = 0;

void simulador() {
  background(0);
  if (robosSimulados.size() == 0) {
    robosSimulados.add(new Robo(100, 100, 0));
    robosSimulados.add(new Robo(100, 200, 1));
    robosSimulados.add(new Robo(100, 300, 2));
  }

  // simula a bola (estática por enquanto)
  fill(255, 150, 0);
  bola.x = width/2;
  bola.y = 20;
  ellipse(bola.x, bola.y, 20, 20);

  // atribui o vetor velocidade e angulo (usando o teclado por enquanto)
  robosSimulados.get(roboControlado).setAng(robosSimulados.get(roboControlado).ang + simulaAng());
  robosSimulados.get(roboControlado).setVel(simulaVel(robosSimulados.get(roboControlado)));

  // atualiza a posicao
  robosSimulados.get(roboControlado).pos.add(robosSimulados.get(roboControlado).vel);
  //println("SIMULADOR: goleiro.vel = " + goleiro.vel);
  //println("SIMULADOR: goleiro.pos = " + goleiro.pos);

  // mostra na tela
  robosSimulados.get(0).simula();
  robosSimulados.get(1).simula();
  robosSimulados.get(2).simula();
} 

// devolve o vetor velocidade gerado pelas setas do teclado
PVector simulaVel (Robo r) {
  PVector vel = new PVector();
  if (!keyPressed) r.setVel(new PVector(0, 0));
  else if (key == CODED) {
    if (keyCode == UP) {
      println("SIMULADOR: frente");
      vel = new PVector(cos(r.ang), sin(r.ang));
    } else if (keyCode == DOWN) {
      println("SIMULADOR: trás");
      vel = new PVector(-cos(r.ang), -sin(r.ang));
    }
  }
  return vel;
}

// devolve o dAng gerado pelas setas do teclado
float simulaAng() {
  float dAng = 0;
  // velocidade angular média do robo
  float velAng = 0.05;
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
  return dAng;
}
