// --- Inclui a biblioteca da motor shield ---
#include <AFMotor.h> 
// --- Inclui a biblioteca do Sensor Ultrasonico ---
#include <Ultrasonic.h> 
// --- Inclui a biblioteca do Servo Motor ---
#include <Servo.h> 
//========================================================================================
// --- Seleção dos Motores ---
AF_DCMotor motor1(1, MOTOR12_64KHZ); //Seleção do Motor 1
AF_DCMotor motor2(2, MOTOR12_64KHZ); //Seleção do Motor 2
//========================================================================================
// -- 

#define serv 10 //Controle do Servo 1

//*Standard PWM DC control*

//Declaração do Pinos dos Sensores
int Leftsensor = A5;
int Rightsensor = A4;

//Declaração do Pinos dos Sensores

int L_sensor_val = 0;
int R_sensor_val = 0;

int threshold = 700;

Servo servo_ultra_sonico;

float distancia;

int trigPin = A0;
int echoPin = A1;

Ultrasonic ultrasonic(trigPin, echoPin);

void setup(){

 Serial.begin(9600);
 //Serial.println("Começando...");

  //servo_ultra_sonico.attach(10);
   
   motor1.setSpeed(150);
   motor2.setSpeed(150);
  
} 

void loop() {
  
  float cmMsec;
  long microsec = ultrasonic.timing();

  distancia = ultrasonic.convert(microsec, Ultrasonic::CM);
    
  if(distancia < 10){
    Serial.println("para");
    motor1.run(RELEASE);
    motor2.run(RELEASE);
    
    return;
  }
  
  L_sensor_val = analogRead(Leftsensor); 
  R_sensor_val = analogRead(Rightsensor);
  Serial.print("L = ");
  Serial.print(L_sensor_val);
  Serial.print("  R = ");
  Serial.println(R_sensor_val);

  if(L_sensor_val > threshold && R_sensor_val > threshold){
    Serial.println("Girando pra esquerda - 1");
    motor1.run(BACKWARD);  //FORWARD
    motor2.run(BACKWARD);  //FORWARD
   }
   
if(L_sensor_val < threshold && R_sensor_val < threshold){
    Serial.println("ANDANDO PRA FRENTE");
    motor1.run(FORWARD);
    motor2.run(FORWARD);
    delay (80);
   }
   //Sensor A5
if(L_sensor_val < threshold && R_sensor_val > threshold){
    Serial.println("Girando pra Esquerda -Agora");
    motor1.run(BACKWARD);
    motor2.run(BACKWARD); 
    delay(150);
    //motor1.run(RELEASE);
    //delay (30);
    motor2.run(BACKWARD);
    delay (30);
    motor2.run(FORWARD);
    delay (100);
    //motor1.run(BACKWARD);
    //motor2.run(FORWARD);
   }
   //Sensor A4
if(L_sensor_val > threshold && R_sensor_val < threshold){
    Serial.println("Girando pra Direita");
    motor1.run(BACKWARD);
    motor2.run(BACKWARD); 
    delay(50);
    motor2.run(BACKWARD);
    delay (30);
    motor1.run(FORWARD);
    delay (30);
    //motor1.run(FORWARD);
    //motor2.run(BACKWARD);
}
if(L_sensor_val == threshold && R_sensor_val == threshold){
  Serial.println("Girando pra Esquerda -Dois LEDS");
    motor1.run(RELEASE);
    motor2.run(RELEASE); 
    delay(1000);
    motor1.run(BACKWARD);
    motor2.run(BACKWARD); 
    delay(350);
    motor2.run(BACKWARD);
    delay (30);
    motor1.run(FORWARD);
    delay (30);
    //motor2.run(FORWARD);
   //delay (30);
    //motor1.run(FORWARD);
    //motor2.run(FORWARD);
  }
  
  delay(10);
}

 
