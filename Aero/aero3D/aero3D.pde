// Aero 3D Simulator
// Developed by t2m
// 09/17/2019

import mqtt.*;

MQTTClient client;

// coordenadas do trajeto
FloatList cX = new FloatList();
FloatList cY = new FloatList();
FloatList cZ = new FloatList();

// vetores de movimento
PVector pos;
PVector vel;

// formato virtual do aviao de papel
PShape s;

// controle de tempo para a simulacao
double tempo = 0;
// controle de posicao dentro da list
int n = 0;
// angulos de orientacao requisitados pelo mqtt
float phi, theta;


void setup() {
  size(640, 640, P3D);
  // construtor da shape do aviao
  shapeAviao();
  // simula coordenadas
  //coordenadas();
  pos = new PVector(0, 0, 0);
  vel = new PVector(1, 1, 1);
  
  // conecta ao mqtt
  client = new MQTTClient(this);
  client.connect("mqtt://test.mosquitto.org", "arebaba");
  client.subscribe("/MPUphi", 2);
  client.subscribe("/MPUtheta", 2);
}

void draw() {
  vel.set(1, 1, 1);
  background(0);
  perspectiva();
  //simulador();
  simulator();
}

// Muda a visao de acordo com as coordenadas do mouse
void perspectiva() {
  camera(map(mouseX, 0, width, 0, 2000), map(mouseY, 0, height, 0, 2000), (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
  translate(width/2, height/2, -100);
  stroke(255);
  noFill();
  box(300);
}

// simula valores para cada coordenada
void coordenadas() {
  int raio = 100;
  for(float i=-1000; i<1000; i++) {
    // trajetoria espiral
    cX.append(raio*cos(radians(i)));
    cY.append(raio*cos(radians(i)));
    cZ.append(raio*sin(radians(i)));
  }
}

// movimento de fato
void simulador() {
  // incrementa a posicao da list a cada intervalo de tempo
  if(millis() - tempo < 2) return;
    
  n++;
  tempo = millis();
  if(n == cX.size()-5) n = 0;
  
  // trajetoria completa
  for(int i=0; i<n; i++) {
    point(cX.get(i), cY.get(i), cZ.get(i));
  }
  
  // posicao instantanea
  pushMatrix();
  translate(cX.get(n), cY.get(n), cZ.get(n));
  
  PVector cauda = new PVector(cX.get(n), cY.get(n), cZ.get(n));
  PVector nariz = new PVector(cX.get(n+1), cY.get(n+1), cZ.get(n+1));
  PVector dir = nariz.sub(cauda);
  
  float angY = atan2(cX.get(n+1)-cX.get(n), cZ.get(n+1)-cZ.get(n));
  //println(degrees(angY));
  rotateY(angY);
  float dY = cY.get(n+1) - cY.get(n);
  rotateX(-2*dY);
  
  //shapeMode(CENTER);
  shape(s);
  popMatrix();
}

// movimento baseado nos angulos do mqtt
void simulator() {
  int limite = 300;
  // calcula a velocidade em cada eixo
  vel.x *= sin(radians(phi));
  vel.y *= -sin(radians(theta));
  vel.z *= cos(radians(theta));
  // resolve
  pos.add(vel);
  
  if(pos.x > limite) pos.x = -limite;
  if(pos.x < -limite) pos.x = limite;
  if(pos.y > limite) pos.y = -limite;
  if(pos.y < -limite) pos.y = limite;
  if(pos.z > limite) pos.z = -limite;
  if(pos.z < -limite) pos.z = limite;
  
  pushMatrix();
  translate(pos.x, pos.y, pos.z);
  rotateX(radians(theta));
  rotateZ(radians(phi));
  shape(s);
  popMatrix();
}

void shapeAviao() {
  // parametros do aviao
  int l1 = 4;
  int l2 = 20;
  int l3 = 50;
  int l4 = 10;

  s = createShape();
  s.beginShape();
  s.fill(0);
  s.stroke(255);
  s.strokeWeight(2);
  
  s.vertex(-(l2+l1/2), 0, -sqrt(l3*l3 - l2*l2)/2);
  s.vertex(-l1, 0, -sqrt(l3*l3 - l2*l2)/2);
  s.vertex(0, l4, -sqrt(l3*l3 - l2*l2)/2);
  s.vertex(l1, 0, -sqrt(l3*l3 - l2*l2)/2);
  s.vertex(l2+l1/2, 0, -sqrt(l3*l3 - l2*l2)/2);
  
  s.vertex(0, 0, sqrt(l3*l3 - l2*l2)/2);
  
  s.endShape(CLOSE);
}

void messageReceived(String topic, byte[] payload) {
  switch(topic) {
    case "/MPUphi":
      phi = float(new String(payload));
      println("phi = " + new String(payload));
    break;
    
    case "/MPUtheta":
      theta = float(new String(payload));
      println("theta = " + new String(payload));
    break;
  }
}
