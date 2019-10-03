import processing.video.*;
import processing.serial.*;

// Flags de debug
boolean debug = true;

boolean calibra = true;  //Flag de controle se deve ou não calibrar as cores
boolean visao = false;  //Flag de controle para parar o código logo após jogar a imagem no canvas (visão) a visão ou não
boolean radio = true; //Flag de controle para emitir ou não sinais ao rádio (ultimo passo da checagem)
boolean gameplay = false;  //Flag de controle que diz se o jogo está no automático ou no manual (apenas do robô 0 por enquanto)

// Verifica se ainda estamos configurando o robo
//boolean configRobo = false;


//boolean andaReto = false; //DENTRO DE INERCIA()

Serial myPort;

// Salvar as cores num txt pra poupar tempo na hora de calibrar (?)
// Cores
color cores[] = { color(239, 161, 0), // Laranja
  color(0, 140, 102), // Verde
  color(210, 0, 0) // Vermelho
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

color trackColor;  //Qual cor estou procurando
color mouseColor;  //Ultima cor selecionada no clique do mouse

// current color sendo calibrada
int calColor = -1;

// Numero de pixels do maior blob da cor vermelha, usado para distinguir o goleiro dos outros dois robôs (robo 0)
int pxMaiorBlobVermelho = 0;

// Numero de pixels do menor blob da cor verde, usado para distinguir do outro robô com verde (robo 1)
int pxMenorBlobVerde = 0;

// Conta o tempo de execucao
double tempo = millis();
double antes = millis();

// Quantidade de quadros para vencer a inercia no controle alinhandando
//int contagemAlinhandando = 0;


// Propriedades do campo
int Y_AREA = 200;

// define o campo como dois pontos
//PVector shapeCampo.getVertex(0) = new PVector();
//PVector shapeCampo.getVertex(2) = new PVector();

// define o campo como quatro pontos
//PVector campo[] = {new PVector(), new PVector(), new PVector(), new PVector()};


//Movie mov;
Capture cam;
//PImage screenshot;

// quantidade de objetos de cada cor
// [] - Cor
// 0 - Laranja
// 1 - Verde
// 2 - Vermelho
int[] quantCor = {1, 3, 3};

ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<Blob> oldBlobs = new ArrayList<Blob>();
ArrayList<Robo> robos = new ArrayList<Robo>();
ArrayList<PVector> rastro = new ArrayList<PVector>();
PVector bola;

void setup() {

  shapeCampo = createShape();

  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[3], 115200);
  size(960, 540);  
  frame.removeNotify();
  frameRate(30);
  camConfig();
}

//void movieEvent(Movie m) {
//  m.read();
//}
void captureEvent(Capture c) {
  c.read();
}

void draw() {
  tempo = millis();
  //screenshot();
  image(cam, 0, 0);
  // Mostra o campo na tela
  if (isCampoDimensionado) {

    shape(shapeCampo);

    // Armazena as ultimas coordenadas de cada blob
    oldBlobs.clear();
    for (Blob b : blobs) oldBlobs.add(new Blob(b.clone()));
    blobs.clear();

    if (debug) return;

    // Confere o numero de ids validos
    //print("MAIN: ids validos: ");
    //for(Blob b : oldBlobs) if(b.id >= 0) print(b.id + "  ");
    //println("");
    // Busca os objetos
    if (!track()) return;

    // debug da visao
    if (visao) return;

    //if(configRobo) {
    //  configRobo(robos.get(0));
    //  return;
    //}

    bola = new PVector(blobs.get(0).center().x, blobs.get(0).center().y);

    showBola();
    //velBola();

    // Inicializa os robos
    if (robos.size() == 0) {
      //robos.clear();
      for (int i=0; i<3; i++) {
        robos.add(new Robo(i));
      }
    } else {
      // Atualiza os robos
      for (int i=0; i<robos.size(); i++) {
        robos.get(i).atualiza();
      }
    }
    // Define as estratégias dos robos
    robos.get(0).setEstrategia(0);
    robos.get(0).debugObj();

    robos.get(1).setEstrategia(1);
    robos.get(1).debugObj();

    //robos.get(0).setEstrategia(3);
    //robos.get(1).setEstrategia(2);
    //robos.get(2).setEstrategia(1);
    //for(Robo r : robos) r.debugObj();

    // Seleciona controle manual ou automatico para o robo 0
    if (gameplay) gameplay(robos.get(0));
    else {
      alinhaGoleiro(robos.get(0));
      alinhaAnda(robos.get(1));
      //alinha(robos.get(2));
    }
    // Envia os comandos
    enviar();
  } else {
    //desenha as linhas na tela se formando
    for (int i = 0; i < shapeCampo.getVertexCount() - 1; i++) {
      line(shapeCampo.getVertex(i).x, shapeCampo.getVertex(i).y, shapeCampo.getVertex(i+1).x, shapeCampo.getVertex(i+1).y);
    }
  }
}

void keyPressed() {
  if (key == 'd') {
    println("KEY: debug on/off");
    debug = !debug;
  }
  if (key == 'c') {
    println("KEY: calibra on/off");
    calibra = !calibra;
  }
  if (key >= '0' && key <= '9') {
    println("KEY: Cor " + key);
    calColor = key;
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
  //if(key == 'y') {
  //  println("KEY: Config Robo");
  //  configEsq = false;
  //  //configRobo = !configRobo;
  //  configRobo(robos.get(0));
  //}
  if (key == 'v') {
    println("KEY: debug visao on/off");
    visao = !visao;
  }
  if (key == 'g') {
    println("KEY: gameplay on/off");
    gameplay = !gameplay;
  }
}

void keyReleased() {
  if (robos.size() > 0) {
    robos.get(0).velE = 0;
    robos.get(0).velD = 0;
  }
}

void mousePressed() {
  int loc = mouseX + mouseY*cam.width;
  mouseColor = cam.pixels[loc];
  //println("x = " + mouseX);
  //println("y = " + mouseY);
  print("R = " + red(mouseColor));
  print("  G = " + green(mouseColor));
  println("  B = " + blue(mouseColor));
  //println("X: " + mouseX + " Y: " + mouseY);

  if (!isCampoDimensionado) dimensionaCampo(mouseX, mouseY);
  if (calibra) calibra();
}
