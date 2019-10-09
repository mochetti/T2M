// Utiliza robos virtuais para testar estratégias especificas do codigo

Robo goleiro = new Robo (100, 100, 0);

void simulador() {
  background(0);

  // simula a bola (estática por enquanto)
  fill(255, 150, 0);
  bola.x = width/2;
  bola.y = 20;
  ellipse(bola.x, bola.y, 20, 20);

  // atribui o vetor velocidade e angulo (usando o teclado por enquanto)
  goleiro.setAng(goleiro.ang + simulaAng());
  goleiro.setVel(simulaVel(goleiro));

  // atualiza a posicao
  goleiro.pos.add(goleiro.vel);
  println("SIMULADOR: goleiro.vel = " + goleiro.vel);
  println("SIMULADOR: goleiro.pos = " + goleiro.pos);

  // mostra na tela
  goleiro.simula();
} 

// devolve o vetor velocidade gerado pelas setas do teclado
PVector simulaVel (Robo r) {
  PVector vel = new PVector();
  if (!keyPressed) goleiro.setVel(new PVector(0, 0));
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
