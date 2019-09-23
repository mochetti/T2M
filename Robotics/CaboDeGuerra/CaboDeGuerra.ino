// --- Inclui a biblioteca da motor shield ---
#include <AFMotor.h> 

// Seleção dos Motores
AF_DCMotor motor1(1); //Seleção do Motor 1 - direito
AF_DCMotor motor2(2); //Seleção do Motor 2 - esquerdo
AF_DCMotor motor3(3); //Seleção do Motor 1 - direito
AF_DCMotor motor4(4); //Seleção do Motor 2 - esquerdo

// Controle de Velocidade dos motores
#define pinMotor1PWM 11 //CONTROLA A VELOCIDADE DO MOTOR 1
#define pinMotor2PWM 3  //CONTROLA A VELOCIDADE DO MOTOR 2
#define pinMotor3PWM 6 //CONTROLA A VELOCIDADE DO MOTOR 1
#define pinMotor4PWM 5  //CONTROLA A VELOCIDADE DO MOTOR 2

//*Standard PWM DC control*

// pino para o botao de start
int botao = 34;
 
int vel = 255;


void setup(){

  Serial.begin(9600);
  Serial.println("Começando...");

    //pinMode(3,  OUTPUT);
    //pinMode(5,  OUTPUT);
    //pinMode(6,  OUTPUT);
    //inMode(11,  OUTPUT);  

  pinMode(botao, INPUT);
    
  motor1.setSpeed(vel);
  motor2.setSpeed(vel);
  motor3.setSpeed(vel);
  motor4.setSpeed(vel);  

  while(digitalRead(botao)) {}                                                                                                                                          
} 

void loop(){
   motor1.run(BACKWARD);
   motor2.run(BACKWARD);
   motor3.run(BACKWARD);
   motor4.run(BACKWARD);
  
}
 
