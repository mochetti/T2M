import processing.video.*;
import processing.serial.*;

// Flags de debug
boolean debug = true;
boolean calibra = true;
boolean visao = false;
boolean dimensionaCampo = true;
boolean campoDimensionado = false;
boolean buscandoCor = true;
boolean algumPonto = false;
boolean gameplay = false;
boolean radio = true;
// Verifica se ainda estamos configurando o robo
boolean configRobo = false;
// Verifica se é a primeira vez que chamamos millis() no alinhandando
boolean primeiraVezAlinhandando = true;

boolean andaReto = false;

Serial myPort = new Serial(this, Serial.list()[3], 115200);

// Salvar as cores num txt pra poupar tempo na hora de calibrar (?)
// Cores
color cores[] = { color(250, 178, 2), // Laranja
                  color(0, 150, 112), // Verde
                  color(223, 2, 2) // Vermelho
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

color trackColor;
color mouseColor; 
// current color sendo calibrada
int calColor = -1;
// Numero de pixels do maior blob da cor vermelha
int numMaior = 0;
// Numero de pixels do menor blob da cor verde
int numMenor = 0;
// Conta o tempo de execucao
double tempo = millis();
double antes = millis();
// Quantidade de quadros para vencer a inercia no controle alinhandando
int contagemAlinhandando = 0;


// Propriedades do campo
int Y_AREA = 200;
PVector comecoCampo = new PVector();
PVector finalCampo = new PVector();

//Movie mov;
Capture cam;
//PImage screenshot;

// quantidade de objetos de cada cor
// [] - Cor
// 0 - Laranja
// 1 - Verde
// 2 - Vermelho
int[] quantCor = {0, 3, 3};

ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<Blob> oldBlobs = new ArrayList<Blob>();
ArrayList<Robo> robos = new ArrayList<Robo>();
ArrayList<PVector> rastro = new ArrayList<PVector>();

void setup() {
  printArray(Serial.list());
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
  noFill();
  rectMode(CORNERS);
  rect(comecoCampo.x, comecoCampo.y, finalCampo.x, finalCampo.y);
  fill(255);
  // Armazena as ultimas coordenadas de cada blob
  oldBlobs.clear();
  for(Blob b : blobs) oldBlobs.add(new Blob(b.clone()));
  blobs.clear();

  if(debug) {
    andaReto = false;
    antes = tempo;
    return;
  }
  // Confere o numero de ids validos
  print("MAIN: ids validos: ");
  for(Blob b : oldBlobs) if(b.id >= 0) print(b.id + "  ");
  println("");
  // Busca os objetos
  if(!track()) {
    andaReto = false;
    antes = tempo;
    return;
  }
  // debug da visao
  if(visao) return;
  if(configRobo) {
    configRobo(robos.get(0));
    return;
  }
  
  //showBola();
  //velBola();
  
  // Inicializa os robos
  if(robos.size() == 0) {
    //robos.clear();
    for(int i=0; i<3; i++) {
      robos.add(new Robo(i));
    }
  }
  else {
    // Atualiza os robos
    for(int i=0; i<robos.size(); i++) {
      robos.get(i).getAng();
      robos.get(i).getPos();
      robos.get(i).debugAng();
    }
  }
  // Define as estratégias dos robos
  robos.get(0).setEstrategia(4);
  //robos.get(0).debugObj();
  
  //robos.get(0).setEstrategia(3);
  //robos.get(1).setEstrategia(2);
  //robos.get(2).setEstrategia(1);
  //for(Robo r : robos) r.debugObj();
  
  // Seleciona controle manual ou automatico
  if(gameplay) gameplay(robos.get(0));
  else {
    alinha(robos.get(0));
    //alinha(robos.get(1));
    //alinha(robos.get(2));
  }
  // Envia os comandos
  enviar();
  
}
  
void keyPressed() {
  if(key == 'd') {
    println("KEY: debug on/off");
    debug = !debug;
  }
  if(key == 'c') {
    println("KEY: calibra on/off");
    calibra = !calibra;
  }
  if(key >= '0' && key <= '9') {
    println("KEY: Cor " + key);
    calColor = key;
  }
  if(key == 'r') {
    println("KEY: radio on/off");
    radio = !radio;
  }
  if(key == 'k') {
    println("KEY: vel viagem increase");
    velViagem++;
  }
  if(key == 'l') {
    println("KEY: vel viagem decrease");
    velViagem--;
  }
  if(key == 'u') {
    //println("KEY: velE increase");
    robos.get(0).velE = 10;
  }
  if(key == 'i') {
    //println("KEY: velD increase");
    robos.get(0).velE = 20;
    robos.get(0).velD = 20;
  }
  if(key == 'o') {
    println("KEY: velE increase");
    robos.get(0).velEmin++;
  }
  if(key == 'p') {
    println("KEY: velD increase");
    robos.get(0).velDmin++;
  }
  if(key == 'y') {
    println("KEY: Config Robo");
    configEsq = false;
    configRobo = !configRobo;
    configRobo(robos.get(0));
  }
  if(key == 'v') {
    println("KEY: debug visao on/off");
    visao = !visao;
  }
  if(key == 'g') {
    println("KEY: gameplay on/off");
    gameplay = !gameplay;
  }
}

void keyReleased() {
  if(robos.size() > 0) {
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
  //if(buscandoCor && campoDimensionado) println("Quantidade de pixels = " + qPixels(mouseX, mouseY, cores[2]));
  if(dimensionaCampo) dimensionaCampo();
  if(calibra) calibra();
}
