// classe que cuida da bola real e virtual
class Bola {
  PVector pos = new PVector();
  PVector vel = new PVector();
  PVector acc = new PVector();
  // real true - bola real
  // real false - bola virtual
  boolean real = true;

  Bola(boolean r) {
    real = r;
  }

  //Bola(PVector posicao) {
  //  pos = posicao;
  //}

  //Bola(float x, float y) {
  //  pos.x = x;
  //  pos.y = y;
  //}

  //Bola(PVector posicao, PVector velocidade, PVector aceleracao) {
  //  pos = posicao;
  //  vel = velocidade;
  //  acc = aceleracao;
  //}

  void atualiza() {
    getPos();
    getVel();

    // define limites e colisao para a bola virtual
    if (!real) {
      // precisa de um valor minimo, caso contrario ela só "tende" a zero
      if (vel.mag() < 0.05) vel.set(0, 0);
      vel.add(acc);
      pos.add(vel);

      // rebote
      if (pos.x < 0 || pos.x > width) vel = new PVector(-vel.x, vel.y);
      if (pos.y < 0 || pos.y > height) vel = new PVector(vel.x, -vel.y);

      colisao();
    }
  }

  PVector getPos() {
    if (real) {
      pos = new PVector(blobs.get(0).center().x, blobs.get(0).center().y);
      return pos;
    } else return pos;
  }

  PVector getVel() {
    if (real) {
      // Remove os rastros mais antigos
      while (rastro.size() > 15) rastro.remove(0);
      // Espera colher dados o suficiente
      if (rastro.size() < 14) return null;

      // Mostra o rastro na tela
      //for(int i = 0; i < rastro.size()-1; i++) ellipse(rastro.get(i).x, rastro.get(i).y, 15, 15);

      // Descobre o angulo e o modulo da bola
      float ang = 0;
      float modulo = 50;
      // Numero de frames entre duas bolas para calcular a velocidade
      int frames = 3;

      for (int i = 0; i < 9; i++) {
        // Começa pelo mais antigo
        PVector bolaAnt = new PVector(rastro.get(i).x, rastro.get(i).y);
        //PVector bolaRec = new PVector(rastro.get(i+frames).x, rastro.get(i+frames).y);
        //modulo += PVector.dist(bolaAnt, bolaRec);
        ang += atan2(pos.y - bolaAnt.y, pos.x - bolaAnt.x);
      }

      ang /= 9;
      //modulo /= 9;

      vel.x = modulo*cos(ang);
      vel.y = modulo*sin(ang);
      //vel.mult(10);
      arrow(pos.x, pos.y, PVector.add(pos, vel).x, PVector.add(pos, vel).y);

      return vel;
    } else return vel;
  }

  // verifica colisoes para a bola virtual
  void colisao() {
    for (int i=0; i<robosSimulados.size(); i++) {
      if (isInside(pos, robosSimulados.get(i).corpo.getChild(0))) {
        println("SIMULADOR: choque com o robo " + robosSimulados.get(i).index);
        float angBola = atan(vel.y / vel.x);
        float dAng = PVector.angleBetween(vel, robosSimulados.get(i).pos);
        dAng *= 2;
        float magAnt = vel.mag();
        vel.set(cos(angBola) + cos(dAng), sin(angBola) + sin(dAng));
        vel.setMag(magAnt);
      }
    }
  }

  // Retorna true se a bola estiver se aproximando do ponto fornecido
  boolean isAprox(PVector aqui) {
    // Se a distancia entre a bola futura e o ponto for maior que a distancia entre a bola atual e o ponto, a bola esta se afastando
    if (distSq(PVector.add(pos, vel), aqui) > distSq(pos, aqui)) {
      println("BOLA: afastando");
      return false;
    } else {
      println("BOLA: aproximando");
      return true;
    }
  }

  void display() {
    fill(245, 166, 73);
    ellipse(pos.x, pos.y, 10, 10);
  }
}