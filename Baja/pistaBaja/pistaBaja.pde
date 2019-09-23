// variaveis da pista
// raio em metros
int raio = 100;
int raioTolerancia = 10;
boolean desenhado = false;
// controle de posicao dentro da list
int pac = 0;

// coordenadas da pista
FloatList cX = new FloatList();
FloatList cY = new FloatList();

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
  if(cX.size() > 5*raioTolerancia) 
    if(distSq(mouseX, mouseY, cX.get(0), cY.get(0)) < raioTolerancia*raioTolerancia) {
      print("ACQUIRE: Voltamos ao início !!");
      desenhado = true;
      return;
    }
  // valores do mouse
  cX.append(mouseX);
  cY.append(mouseY);
  point(mouseX, mouseY);
}

void display() {
  for(int i=0; i<cX.size(); i++) {
    point(cX.get(i), cY.get(i));
  }
}

void simulate() {
  int imageSize = 20;
  background(0);
  display();
  pac++;
  if(pac > cX.size() - 2) pac = 0;
  // calcula o angulo de rotacao baseado no proximo ponto
  float ang = atan2(cY.get(pac+1)-cY.get(pac), cX.get(pac+1)-cX.get(pac));
  push();
  translate(cX.get(pac), cY.get(pac));
  rotate(ang);
  //ellipse(coord.get(pac), coord.get(pac+1), 5, 5);
  image(pacMan, - imageSize/2, - imageSize/2, imageSize, imageSize);
  pop();
  
  delay(10);
}

float distSq(float x1, float y1, float x2, float y2) {
  return (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2);
}
