// Utiliza robos virtuais para testar estratégias especificas do codigo

Robo goleiro = new Robo (width/2, height/2, 0);

void simulador() {
  background(0);
  // atribui o vetor velocidade;
  if (!keyPressed) goleiro.setVel(0, 0);
  else if (key == CODED) {
    if (key == UP) goleiro.setVel(goleiro.velEmin, goleiro.velDmin);
    else if (key == DOWN) goleiro.setVel(-goleiro.velEmin, -goleiro.velDmin);
    else if (key == LEFT) goleiro.setVel(-goleiro.velEmin, goleiro.velDmin);
    else if (key == RIGHT) goleiro.setVel(goleiro.velEmin, -goleiro.velDmin);
  }
  
  // atualiza a posicao
  goleiro.pos.add(goleiro.vel);
  
  // mostra na tela
  goleiro.simula();

} 
