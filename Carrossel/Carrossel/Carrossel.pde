import processing.video.*;
import processing.serial.*;

// Flags de debug
boolean debug = false;

// Controla a entrada da imagem
// 0 - camera
// 1 - video 
// 2 - simulador
int inputVideo = 2;

boolean calibra = true;  //Flag de controle se deve ou não calibrar as cores
boolean visao = false;  //Flag de controle para parar o código logo após jogar a imagem no canvas (visão) a visão ou não
boolean controle = true;  // Flag para rodar o bloco de controle
boolean estrategia = true; // Flag para rodar o bloco de estratégia
boolean radio = true; //Flag de controle para emitir ou não sinais ao rádio (ultimo passo da checagem)
boolean gameplay = false;  //Flag de controle que diz se o jogo está no automático ou no manual (apenas do robô 0 por enquanto)
boolean simManual = true;  // Flag de controle que define se os comandos vem pelas setas ou do modulo de controle

boolean ladoCampo = false;  // Atacamos pra qual lado (true é pra direita)
boolean posicionarParado = false;  // Controla se a estratégia engloba o posicionamento ou somente o jogo

// estretagia usada quando estrategia = false;
int estFixa = 0;

//Variavel para contar frames
int qtdFrames = 0;

// variaveis pro controle do arrasto do mouse
PVector clique = new PVector();
int dragged = 0;

//ID do robô
int buscandoRobo = 0;

boolean procurarRobo = false;

boolean pausado = false;

Serial myPort;

// Cores
color cores[] = { 
  color(245, 166, 73), // Laranja
  color(16, 148, 238), // Azul
  color(238, 96, 119) // Vermelho
};

// id de cada objeto
// 0 - Bola
// 1 - Meio Robo 0 (vermelho maior)
// 2 - Meio Robo 1 (robo xadrez)
// 3 - Meio Robo 2 (vermelho na direita)
// 4 - Quina Robo 0
// 5 - Quina Robo 1
// 6 - Quina Robo 2

// 6 - Quina 1 Robo 1
// 7 - Quina 0 Robo 2
// 8 - Quina 1 Robo 2
// 9 - Quina 2 Robo 2
// 10 - Inimigo

// campo[i]
// 0        1
// 3        2

color mouseColor;  //Ultima cor selecionada no clique do mouse

// current color sendo calibrada
int calColor = -1;

// Conta o tempo de execucao
double tempo = millis();
double antes;

Movie mov;
Capture cam;
//PImage screenshot;

// quantidade de objetos de cada cor
// [] - Cor
// 0 - Laranja
// 1 - Azul
// 2 - Vermelho
int[] quantCor = {1, 3, 3};
int elementos = 0;

ArrayList<Robo> robos = new ArrayList<Robo>();

ArrayList<Robo> robosSimulados = new ArrayList<Robo>();
ArrayList<PVector> rastro = new ArrayList<PVector>();

// bola real
Bola bola = new Bola(true);

void setup() {

  shapeCampo = createShape();

  for (int i : quantCor) elementos += i;

  //mov.frameRate(30);
  ellipseMode(RADIUS);
  size(960, 540);

  frameRate(30);
  if (inputVideo == 0) {
    printArray(Serial.list());
    myPort = new Serial(this, Serial.list()[1], 115200);
    camConfig();
  } else if (inputVideo == 1) {
    mov = new Movie(this, "aliado_com_bola_borda_campo.mov");
    mov.play();
    mov.loop();
  }

  // nao destroi mais os elementos robos, inicializa os robos somente uma vez e depois somente atualiza
  for (int i=0; i<3; i++) robos.add(new Robo(i));
}

void movieEvent(Movie m) {
  m.read();
  //redraw();
}
void captureEvent(Capture c) {
  c.read();
}

void draw() {

  background(0);
  tempo = millis();

  if (inputVideo == 0) image(cam, 0, 0);
  else if (inputVideo == 1) image(mov, 0, 0, width, height);


  stroke(255);
  if (isCampoDimensionado) {
    // Mostra o campo na tela

    shape(shapeCampo);
    shape(shapeCampo.getChild(0));
    shape(shapeCampo.getChild(1));
    // Mostra os gols
    if (ladoCampo) {
      golAmigo = new PVector((shapeCampo.getVertex(1).x + shapeCampo.getVertex(2).x) /2, (shapeCampo.getVertex(1).y+shapeCampo.getVertex(2).y) / 2);
      golInimigo = new PVector((shapeCampo.getVertex(0).x + shapeCampo.getVertex(3).x) /2, (shapeCampo.getVertex(0).y+shapeCampo.getVertex(3).y) / 2);
    }
    if (!ladoCampo) {
      golInimigo = new PVector((shapeCampo.getVertex(1).x + shapeCampo.getVertex(2).x) /2, (shapeCampo.getVertex(1).y+shapeCampo.getVertex(2).y) / 2);
      golAmigo = new PVector((shapeCampo.getVertex(0).x + shapeCampo.getVertex(3).x) /2, (shapeCampo.getVertex(0).y+shapeCampo.getVertex(3).y) / 2);
    }
    // nosso gol é verde
    fill(0, 255, 0);
    ellipse(golAmigo.x, golAmigo.y, 20, 20);
    // gol inimigo é vermelho
    fill(255, 0, 0);
    ellipse(golInimigo.x, golInimigo.y, 20, 20);

    if  (inputVideo == 2) simulador();

    fill(0, 255, 0);
    for (Robo r : robos) {
      ellipse(r.azul.center().x, r.azul.center().y, 5, 5);
      ellipse(r.vermelho.center().x, r.vermelho.center().y, 5, 5);
    }
    ellipse(bola.pos.x, bola.pos.y, 5, 5);

    if (!debug) return;

    for (Robo r : robos) r.atualiza();

    //Defino a bola
    bola.atualiza();

    //A partir daqui pode definir os objetivos.

    //Defino as estratégias
    if (estrategia) {
      // Define as estratégias dos robos

      if (robos.get(0).index >= 0) robos.get(0).setEstrategia(0);
      if (robos.get(1).index >= 0) robos.get(1).setEstrategia(5);
      if (robos.get(2).index >= 0) robos.get(2).setEstrategia(3);
    } // posicoes fixas
    else for (Robo r : robos) if (r.index >= 0) r.setEstrategia(estFixa);

    //r.frente() não pode vir antes da estratégia, precisa ter os objetivos definidos.
    for (Robo r : robos) if (r.index >= 0 && !r.girando) r.frente();

    //print(robos.get(0).ang);

    // Debugo as estrategias (mostra na tela)
    for (Robo r : robos) if (r.index >= 0) r.debugObj();

    //A partir daqui controle assume

    if (controle) {

      //println(robos.get(0).girando);

      if (robos.get(0).index >= 0 && !robos.get(0).girando) alinhaAnda(robos.get(0));
      if (robos.get(1).index >= 0 && !robos.get(1).girando) alinhaAnda(robos.get(1));
      if (robos.get(2).index >= 0 && !robos.get(2).girando) alinhaAnda(robos.get(2));

      if (gameplay) gameplay(robos.get(0));
    }

    //A partir daqui envia dados
    if (inputVideo == 0) enviar();
    //for (Robo r : robos) print("Index: " + r.index);
  } else {
    // no simulador, o campo é o próprio canvas
    if (inputVideo == 2) {
      dimensionaCampo(0, 0);
      dimensionaCampo(width, 0);
      dimensionaCampo(width, height);
      dimensionaCampo(0, height);
      return;
    }

    //desenha as linhas na tela se formando
    for (int i = 0; i < shapeCampo.getVertexCount() - 1; i++) {
      strokeWeight(2);
      line(shapeCampo.getVertex(i).x, shapeCampo.getVertex(i).y, shapeCampo.getVertex(i+1).x, shapeCampo.getVertex(i+1).y);
    }
  }
}

void keyPressed() {
  if (key == TAB) {
    roboControlado++;
    if (roboControlado == 3) roboControlado = 0;
    println("KEY: Controlando o robo " + roboControlado);
  }
  if (key == 'd') {
    print("KEY: ");
    if (debug) {
      println("debug off");
      debug = false;
    } else {
      println("debug: on");
      debug = true;
    }
  }
  if (key == 'c') {
    calibra = !calibra;
    if (calibra) {
      println("KEY: calibra on");
    } else {
      println("KEY: calibra off");
    }
  }
  if (key >= '0' && key <= '9') {
    if (calibra) {
      println("KEY: Cor " + key);
      calColor = key;
    } else if (procurarRobo) {
      buscandoRobo = key - 48;
      println("KEY: buscando robô - " + buscandoRobo);
    }
  }
  if (key == 'r') {
    println("KEY: radio on/off");
    radio = !radio;
  }
  if (key == 'C') {
    println("KEY: redefinir campo");
    isCampoDimensionado = false;
    shapeCampo = createShape();
  }
  if (key == 'i') {
    if (procurarRobo) {
      procurarRobo = false;
      println("KEY: buscando robô off");
    } else {
      calibra = false;
      procurarRobo = true;
      println("KEY: buscando robô on");
    }
  }

  //MOVIE
  if (key == ' ') {
    // chute aleatorio na bola
    if (inputVideo == 2) bolaV.vel.set(random(20)-10, random(20)-10);
    if (pausado) {
      if (inputVideo == 1) { 
        mov.play();
        pausado = false;
      }
    } else {
      if (inputVideo == 1) {
        mov.pause();
        pausado = true;
      }
    }
  }
  if (key == 'v') {
    println("KEY: debug visao on/off");
    visao = !visao;
  }
  if (key == 'S') {
    println("KEY: simulador manual/automatico");
    simManual = !simManual;
  }
  if (key == 'g') {
    println("KEY: gameplay on/off");
    gameplay = !gameplay;
  }
  // posicionamento ainda é necessário ?
  if (key == 'l') {
    if (posicionarParado) {
      println("KEY: posicionar antes off");
      posicionarParado = false;
    } else {
      println("KEY: posicionar antes on");
      posicionarParado = true;
    }
  }
  // posicao inicial
  if (key == 'P') {
    if (estrategia) {
      println("KEY: posicao inicial off");
      estrategia = false;
    } else {
      println("KEY: posicao inicial on");
      estFixa = 6;
      estrategia = true;
    }
  }
  // falta para nós
  if (key == 'f') {
    if (estrategia) {
      println("KEY: falta para nós off");
      estrategia = false;
    } else {
      println("KEY: falta para nós on");
      estFixa = 7;
      estrategia = true;
    }
  }
  // falta para eles
  if (key == 'F') {
    if (estrategia) {
      println("KEY: falta para eles off");
      estrategia = false;
    } else {
      println("KEY: falta para eles on");
      estFixa = 8;
      estrategia = true;
    }
  }
}

void mouseDragged() {
}

void mouseReleased() {
  PVector mouse = new PVector(mouseX, mouseY);
  PVector tiro = PVector.sub(mouse, clique);
  tiro.setMag(sqrt(distSq(mouse, clique))/40);
  bolaV.vel = tiro;
}

void keyReleased() {
  if (robos.size() > 0) {
    robos.get(0).velE = 0;
    robos.get(0).velD = 0;
  }
}

void mousePressed() {

  clique.x = mouseX;
  clique.y = mouseY;

  mouseColor = get(mouseX, mouseY);

  print("R = " + red(mouseColor));
  print("  G = " + green(mouseColor));
  println("  B = " + blue(mouseColor));
  //println("X: " + mouseX + " Y: " + mouseY);

  if (!isCampoDimensionado) dimensionaCampo(mouseX, mouseY);
  if (calibra) calibra();
  if (procurarRobo) search(buscandoRobo);
}
