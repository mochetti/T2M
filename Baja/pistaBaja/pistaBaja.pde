// variaveis da pista
// raio em metros
int raio = 100;
int raioTolerancia = 10;
boolean desenhado = false;
// controle de posicao dentro da list
int pac = 0;

// coordenadas da pista
// pares - x
// impares - y
FloatList coord = new FloatList();
PImage pacMan;

void setup() {
  pacMan = loadImage("pacMan.png");
  size(500, 500);
  background(0);
  fill(255);
  //ellipse(0,0,10,10);
  stroke(255);
  point(0,0);
}

void draw() {
  if(mousePressed && !desenhado) acquire();
  else if(desenhado) simulate();
  delay(10);
}

void acquire() {
  if(coord.size() > 5*raioTolerancia) 
    if(distSq(mouseX, mouseY, coord.get(0), coord.get(1)) < raioTolerancia*raioTolerancia) {
      print("ACQUIRE: Voltamos ao início !!");
      desenhado = true;
      return;
    }
  // valores do mouse
  coord.append(mouseX);
  coord.append(mouseY);
  point(mouseX, mouseY);
}

void display() {
  for(int i=0; i<coord.size(); i+=2) {
    point(coord.get(i), coord.get(i+1));
  }
}

void simulate() {
  int imageSize = 20;
  background(0);
  display();
  pac += 2;
  if(pac > coord.size() - 4) pac = 0;
  // calcula o angulo de rotacao baseado no proximo ponto
  float ang = atan2(coord.get(pac+3)-coord.get(pac+1), coord.get(pac+2)-coord.get(pac));
  push();
  translate(coord.get(pac), coord.get(pac+1));
  rotate(ang);
  //ellipse(coord.get(pac), coord.get(pac+1), 5, 5);
  image(pacMan, - imageSize/2, - imageSize/2, imageSize, imageSize);
  pop();
  
  delay(0);
}

float distSq(float x1, float y1, float x2, float y2) {
  return (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2);
}
