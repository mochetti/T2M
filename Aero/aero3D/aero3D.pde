// coordenadas do trajeto
FloatList cX = new FloatList();
FloatList cY = new FloatList();
FloatList cZ = new FloatList();

PShape s;

// controle de tempo para a simulacao
double tempo = 0;
// controle de posicao dentro da list
int n = 0;

void setup() {
  size(640, 640, P3D);
  // construtor da shape do aviao
  aviao();
}

void draw() {
  // limpa as coordenadas, mas é provisório (eu espero rs)
  cX.clear();
  cY.clear();
  cZ.clear();
  background(0);
  perspectiva();
  coordenadas();
  simulador();
}

// Muda a visao de acordo com a coordenada X do mouse
void perspectiva() {
  camera(2*mouseX, 2*mouseY, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
  translate(width/2, height/2, -100);
  stroke(255);
  noFill();
  box(200);
}

// obtem os valores para cada coordenada
void coordenadas() {
  int raio = 20;
  for(int i=0; i<2000; i++) {
    cX.append(raio*cos(radians(i)));
    cY.append(i/5);
    cZ.append(raio*sin(radians(i)));
  }
}

// movimento de fato
void simulador() {
  // incrementa a posicao da list a cada intervalo de tempo
  if(millis() - tempo > 2) {
    n++;
    tempo = millis();
    if(n == cX.size()) n = 0;
  }
  // trajetoria completa
  for(int i=0; i<n; i++) {
    point(cX.get(i), cY.get(i), cZ.get(i));
  }
  // posicao intantanea
  push();
  translate(cX.get(n), cY.get(n), cZ.get(n));
  rotateX(atan2(cZ.get(n+1)-cZ.get(n), cY.get(n+1)-cY.get(n)));
  rotateY(atan2(cX.get(n+1)-cX.get(n), cZ.get(n+1)-cZ.get(n)));
  rotateZ(atan2(cX.get(n+1)-cX.get(n), cY.get(n+1)-cY.get(n)));
  shape(s);
  pop();
}

void aviao() {
  // parametros do aviao
  int l1 = 5;
  int l2 = 25;
  int l3 = 50;
  int l4 = 15;

  s = createShape();
  s.beginShape();
  s.fill(0);
  s.stroke(255);
  s.strokeWeight(2);
  
  s.vertex(-(l2+l1/2), 0, 0);
  s.vertex(-l1, 0, 0);
  s.vertex(0, 0, l4);
  s.vertex(l1, 0, 0);
  s.vertex(l2+l1/2, 0, 0);
  
  s.vertex(0, sqrt(l3*l3 - l2*l2), 0);
  
  s.endShape(CLOSE);
}
