// Geras robos virtuais para testar estratégias especificas do codigo

// mostra qual robo está sendo controlado pelas setas (altera o robo usando o TAB)
int roboControlado = 0;

// bola virtual
Bola bolaV = new Bola();

void simulador() {
  background(0);
  if (robosSimulados.size() == 0) {
    robosSimulados.add(new Robo(300, 100, 0));
    robosSimulados.add(new Robo(100, 200, 1));
    robosSimulados.add(new Robo(100, 300, 2));
  }

  // simula a bola
  // chute inicial
  if (bolaV.pos.x == 0 && bolaV.pos.y == 0) {
    println("SIMULADOR: chute inicial");
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
  
  if(bolaV.vel.mag() == 0) bolaV.acc.set(0, 0);
  else bolaV.acc = new PVector(kX/20, kY/30);
  
  //println("acc = " + bolaV.acc);
  //println("vel = " + bolaV.vel);

  bolaV.atualiza();
  bolaV.display();

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
      //println("SIMULADOR: frente");
      vel = new PVector(cos(r.ang), sin(r.ang));
    } else if (keyCode == DOWN) {
      //println("SIMULADOR: trás");
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

// classe que cuida da bola virtual
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
    if(vel.mag() < 0.05) vel.set(0, 0);
    vel.add(acc);
    pos.add(vel);

    // rebote
    if (pos.x < 0 || pos.x > width) vel = new PVector(-vel.x, vel.y);
    if (pos.y < 0 || pos.y > height) vel = new PVector(vel.x, -vel.y);

    for (int i=0; i<robos.size(); i++) {
      //if (isInside(bola, robos.get(i).corpo)) ;
      // rebate e aumenta a velocidade
    }
  }

  void display() {
    fill(255, 150, 0);
    ellipse(pos.x, pos.y, 10, 10);
  }
}
