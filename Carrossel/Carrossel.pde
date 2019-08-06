import processing.video.*;
import processing.serial.*;
//import java.awt.Robot;
//import java.awt.AWTException;
//import java.awt.Rectangle;

// Flags de debug
boolean debug = true;
boolean calibra = true;
boolean dimensionaCampo = true;
boolean campoDimensionado = false;
boolean buscandoCor = true;
boolean algumPonto = false;
boolean radio = true;

Serial myPort = new Serial(this, Serial.list()[3], 115200);

// Salvas as cores num txt pra poupar tempo na hora de calibrar (?)
// Cores
color cores[] = { color(242, 161, 7), // Laranja
                  color(18, 155, 110), // Verde
                  color(221, 2, 2) // Vermelho
                };               

// id de cada objeto
// 0 - Bola
// 1 - Meio Robo 0 (vermelho embaixo)
// 2 - Meio Robo 1 (vermelho na esquerda)
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
int[] quantCor = {1, 3, 3};

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
  
  //print("MAIN: Quantidade de blobs: ");
  //println(oldBlobs.size());

  if(debug) return;
  // Confere o numero de ids validos
  int idsValidos = 0;
  for(Blob b : oldBlobs) if(b.id >= 0) idsValidos++;
  println("MAIN: ids validos = " + idsValidos);
  // Busca os objetos
  if(!track()) return;
  
  //showBola();
  velBola();
  
  // Inicializa os robos
  robos.clear();
  for(int i=0; i<3; i++) {
    robos.add(new Robo(i));
    robos.get(i).debugAng();
  }

  // Define as estratégias dos robos
  robos.get(0).setEstrategia(0);
  robos.get(0).debugObj();
  
  //robos.get(0).setEstrategia(3);
  //robos.get(1).setEstrategia(2);
  //robos.get(2).setEstrategia(1);
  //for(Robo r : robos) r.debugObj();
  
  alinha(robos.get(0));
  
  // Envia os comandos
  enviar();
  
}
  
void keyPressed() {
  if(key == 'd') {
    println("debug on/off");
    debug = !debug;
  }
  if(key == 'c') {
    println("calibra on/off");
    calibra = !calibra;
  }
  if(key >= 0) {
    println("Cor " + key);
    calColor = key;
  }
  if(key == 'r') {
    println("radio on/off");
    radio = !radio;
  }
  if(key == 'o') {
    println("vel increase");
    velGiro++;
  }
  if(key == 'p') {
    println("vel decrease");
    velGiro--;
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
