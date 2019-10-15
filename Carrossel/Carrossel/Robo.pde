// Classe que gerencia os robos

class Robo {

  //Variaveis de controle de estado para cada estratégia:
  int estagio = 0;  //Variável que para cada estratégia vai ditar o que no estágio atual deveria acontecer
  //Estratégia 0:
  /*
    estagio:
   -0 vai até o y da bola (limitando limites superior e inferior)
   -1 se a bola estiver próxima, gira até a bola distanciar
   */
  //Estratégia 1: com seus estados iniciais já setados
  /*
   estagio:
   -0: vai até a sombra da bola
   -1 vai até a posição projetada da sombra
   -2´ir até a sombra da bola, tendo passado pelo estágio 1
   -3: Vai até a bola
   Aqui percebemos que existem 2 caminhos lógicos que o robô poderá seguir:
   0 -> 3; OU  Nesta o robô chega direto na sombra da bola e vai direto até ela
   0 -> 1 -> 2 -> 3;  Enquanto nesta o robô vai até a sombra original, encontra a bola no caminho e passa a percorrer atrás da sombra projetada. Chega na projetada e vai até
   a original. Chega na original e vai até a bola.
   */

  PVector pos = new PVector(), posAnt, vel, obj, objAnt;
  float ang = 0, angAnt = 0, angObj = -1;
  // Armazena o erro no valor do angulo do frame anterior
  // É propriedade da classe robo para evitar multiplas variaveis globais
  float dAngAnt = 0;
  float velD, velE, dAntiga, eAntiga;
  // Velocidades limite do robo (0 - 64)
  int velMax = 20;
  int velMin = -10;
  float velEmin = 2.5;
  float velDmin = 2.5;
  // coeficiente proporcional para o controle
  float kP;
  int v = 0;
  int index;
  PShape corpo;
  // 0 = verde -> vermelho
  // 1 = verde <- vermelho
  boolean frente = false;

  Robo(int n) {
    index = n;
    ang = getAng();
    pos = getPos();
    vel = new PVector();
    obj = new PVector();
    atualiza();
  }

  Robo(Robo r) {
    pos = r.pos;
    vel = r.vel;
    ang = r.ang;
    index = r.index;

    angAnt = r.angAnt;
    obj = r.obj;
    objAnt = r.objAnt;
  }

  // construtor usado pelo simulador
  Robo(float x, float y, int n) {
    pos.x = x;
    pos.y = y;
    index = n;
    vel = new PVector();
  }

  Robo clone() {
    Robo r = new Robo(this);
    return r;
  }

  // define o angulo do robo
  // criado para a simulacao - cuidado ao usar
  void setAng(float income) {
    ang = income;
  }

  // define como vetor velocidade
  void setVel(PVector income) {
    vel = income;
  }
  // define a velocidade das rodas
  void setVel(float vE, float vD) {
    // Verifica se as velocidades estão dentro dos limites estabelecidos
    // O ajuste para velocidade negativa é feito direto na serial
    if (vE > velMax) vE = velMax;
    else if (vE < -velMax) vE = -velMax;
    if (vD > velMax) vD = velMax;
    else if (vD < -velMax) vD = -velMax;
    velE = vE;
    velD = vD;
    if (frente) {
      float aux = velE;
      velE = -velD;
      velD = -aux;
    }
  }

  // Calcula o centro real do robo
  PVector getPos() {
    PVector centro = new PVector();
    PVector posVerde = new PVector(blobs.get(index+1).center().x, blobs.get(index+1).center().y);
    PVector posVermelho = new PVector(blobs.get(index+4).center().x, blobs.get(index+4).center().y);
    switch(index) {
    case 0:  // o centro é a media aritmética dos centros dos blobs
      centro.x = (posVerde.x + posVermelho.x) / 2;
      centro.y = (posVerde.y + posVermelho.y) / 2;
      break;

    case 1: 
      centro.x = (posVerde.x + posVermelho.x) / 2;
      centro.y = (posVerde.y + posVermelho.y) / 2;
      break;

    case 2:  // o centro é deslocado (esse cálculo é aproximado mas muito bom)
      float angulo = ang;
      if (frente) angulo -= PI;
      //println("ROBO: angulo = " + degrees(angulo));
      float distCentros = dist(posVerde.x, posVerde.y, posVermelho.x, posVermelho.y);
      distCentros /= 2;
      centro.x = (posVerde.x + cos(angulo)*distCentros);
      centro.y = (posVerde.y + sin(angulo)*distCentros);
      break;
    }

    posAnt = new PVector(pos.x, pos.y);
    pos = new PVector(centro.x, centro.y);
    return centro;
  }

  // Define posicao do objetivo como vetor
  void setObj(PVector income) {
    obj = income;
  }

  // Define posicao do objetivo como coordenadas
  void setObj(float x, float y) {
    if (x > width) x = width;
    if (x < 0) x = 0;
    if (y > height) y = height;
    if (y < 0) y = 0;

    obj.x = x;
    obj.y = y;
  }

  void setEstrategia(int n) {
    if (pos.x > 0) {
      estrategia(this, n);
    } else {
      //Valores arbitrários apenas para identificar que o robô não está em campo e não traçar nenhum objetivo no canvas que não seja verdadeiro.
      //Assim que o robô voltar a ter posição X > 0 significa que foi reencontrado, e a partir daí o novo setObj dentro da estrategia dará o local certo que ele deve ir
      setObj(new PVector());
    }
  }

  // Retorna um vetor correspondente à direçao do robo
  PVector getDir() {
    PVector dir = new PVector();
    dir.x = cos(ang);
    dir.y = sin(ang);
    return dir;
  }

  // Retorna o angulo do robo
  float getAng() {

    switch(index) {
    case 0:    // vermelho maior
      ang = atan2(- blobs.get(1).center().y + blobs.get(4).center().y, - blobs.get(1).center().x + blobs.get(4).center().x);
      //line(blobs.get(1).center().x, blobs.get(1).center().y, blobs.get(4).center().x, blobs.get(4).center().y);
      break;

    case 1:    // robo xadrez
      ang = atan2(- blobs.get(2).center().y + blobs.get(5).center().y, - blobs.get(2).center().x + blobs.get(5).center().x);
      ang += PI/4;
      //line(blobs.get(2).center().x, blobs.get(2).center().y, blobs.get(5).center().x, blobs.get(5).center().y);
      break;

    case 2:    // vermelho na direita
      ang = atan2(- blobs.get(3).center().y + blobs.get(6).center().y, - blobs.get(3).center().x + blobs.get(6).center().x);
      ang -= atan(0.5);
      //line(blobs.get(3).center().x, blobs.get(3).center().y, blobs.get(6).center().x, blobs.get(6).center().y);
      break;
    }
    if (frente) ang += PI;

    while (ang > 2*PI) ang -= 2*PI;
    while (ang < 0) ang += 2*PI;

    //println("ROBO: " + index + " ang = " + degrees(ang));

    return ang;
  }

  // atualiza alguns parametros do robo
  void atualiza() {

    objAnt = obj;

    // muda a frente do robo se necessário
    // Vetor robo -> obj
    if (obj.mag() != 0) {
      PVector robObj = new PVector();
      robObj = PVector.sub(obj, pos);
      float dAng = PVector.angleBetween(robObj, getDir());
      if (dAng > 6*PI/10) frente = !frente;
      //println("ROBO: robo " + index + " esta com a frente trocada");
    }

    getAng();
    getPos();
    debugAng();



    switch(index) {
    case 0:
      velEmin = 3;
      velDmin = 3;
      kP = 0.25;
      break;
    case 1:
      velEmin = 1.5;
      velDmin = 1.5;
      kP = 0.5;
      break;
    default:
      velEmin = 2.5;
      velDmin = 2.5;
      kP = 0;
      break;
    }
  }

  // Funcoes de debug
  void debugAng() {
    //println("ROBO: " + index + "  ang = " + degrees(ang));
    arrow(pos.x, pos.y, pos.x + 50*cos(ang), pos.y + 50*sin(ang));
  }
  void debugObj() {
    arrow(pos.x, pos.y, obj.x, obj.y);
    fill(255, 0, 0);
    ellipse(obj.x, obj.y, 5, 5);
  }

  // desenha o robo no simulador
  void simula() {
    // lado do robo em pixels
    int lado = 35;
    rectMode(CORNER);
    // PShape
    corpo = createShape(GROUP);
    PShape vermelho = createShape();
    PShape verde = createShape();
    PShape fundo = createShape();
    fundo.beginShape();
    fundo.vertex(-lado/2, -lado/2);
    fundo.vertex(lado/2, -lado/2);
    fundo.vertex(lado/2, lado/2);
    fundo.vertex(-lado/2, lado/2);
    fundo.endShape(CLOSE);


    switch(index) {
      // goleiro
    case 0:
      vermelho = createShape(RECT, -lado/2, -lado/2, lado, lado/2);
      verde = createShape(RECT, -lado/2, 0, lado, lado/2);
      break;

      // zagueiro (xadrez)
    case 1:
      vermelho = createShape(RECT, -lado/2, -lado/2, lado/2, lado/2);
      verde = createShape(RECT, 0, 0, lado/2, lado/2);
      break;

      // atacante (L)
    case 2:
      vermelho = createShape(RECT, 0, -lado/2, lado/2, lado/2);
      verde = createShape(RECT, -lado/2, 0, lado, lado/2);
      break;
    }

    vermelho.setFill(color(255, 0, 0));
    verde.setFill(color(0, 255, 0));
    fundo.setFill(color(0));
    corpo.addChild(fundo);
    corpo.addChild(verde);
    corpo.addChild(vermelho);
  }

  void display() {
    pushMatrix();
    corpo.translate(pos.x, pos.y);
    corpo.rotate(ang + PI/2);
    shape(corpo);
    popMatrix();
  }

  boolean isBolaEntre(PVector objetivo) {  

    float distRoboObj = distSq(pos, objetivo);
    float distRoboBola = distSq(pos, bola);
    //println(distRoboObj);
    //println(distRoboBola);

    if (isNear(bola, 80) && distRoboObj > distRoboBola) {


      return true;
    } 
    return false;
  }

  boolean isNear(PVector alvo, int tolerancia) {
    int raio = tolerancia;
    noFill();
    ellipse(pos.x, pos.y, raio, raio);

    if (distSq(pos, alvo) < tolerancia*tolerancia) {
      //println("ROBO: Robo " + index + " isNear = true");
      return true;
    }
    //println("ROBO: Robo " + index + " isNear = false");
    return false;
  }
}
