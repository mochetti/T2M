// biblioteca de comunicação I2C
#include <Wire.h>
#include <SPI.h>

 // seleciona o pin 10 para controlar o DAC:
const int dacChipSelectPin = 10;      
 // variavel para armazenar o valor desejado no DAC ja convertido
 float a = 0;
 // tensao desejada no DAC
 float valor = 0;
 // tensao medida de cada sensor
 int tensao = 0;

void setup()
{
     // inicia e seta a velocidade da comunicação serial
     Serial.begin(9600);

     // inicia a comunicação serial I2C
     Wire.begin();
     
     // inicia a comunicacao seria SPI
     SPI.begin();

     // configura o pino A0 como entrada analógica
     pinMode(A0, INPUT);
     // configura o pino A1 como entrada analógica
     pinMode(A1, INPUT);
     // configura o pino A2 como entrada analógica
     pinMode(A2, INPUT);

     // reseta a porta serial
     Serial.println("0");

     pinMode (dacChipSelectPin, OUTPUT); 
    // desativa a porta do DAC inicialmente
    digitalWrite(dacChipSelectPin, HIGH);  
    // configuracoes basicas do SPI:
    SPI.setBitOrder(MSBFIRST);         
    SPI.setDataMode(SPI_MODE0);        
}

void loop() 
{
  
     // realiza a leitura da porta serial
     char comando = Serial.read();
     
     // comando para leitura de DAVIS
     if(comando == '0')
     {
       valor = 3.3;
       // converte o valor desejado no DAC
     a = valor*4095/5;
     // chama a funcao do DAC, com valor a e canal 0
     setDac(a,0);
     // muda a referencia do arduino para a alimentacao externa
       analogReference(EXTERNAL);
       // as primeiras medidas sao imprecisas
      for(int i = 0; i <= 5; i++) {
       // grava uma em cima da outra
      tensao = analogRead(A0);
      delay(2);
        int davis = map(tensao, 0, 1023, 0, 3300);
        Serial.println(davis);
     }
     }

     // comando para leitura de TRANSISTOR
     if(comando == '1')
     {
        valor = 5.0;
       // converte o valor desejado no DAC
     a = valor*4096/5;
     // chama a funcao do DAC, com valor a e canal 0
     setDac(a,0);
       analogReference(EXTERNAL);
      for(int i = 0; i <= 5; i++) {    //as primeiras medidas sao imprecisas
      tensao = analogRead(A1);
      delay(2); 
        int transistor = map(tensao, 0, 1023, 0, 5000);
        Serial.println(transistor);
      }
     }

     // comando para leitura de MÓDULO
     if(comando == '2')
     {
        valor = 5.0;
       // converte o valor desejado no DAC
     a = valor*4096/5;
     // chama a funcao do DAC, com valor a e canal 0
     setDac(a,0);
       analogReference(EXTERNAL);
       int tensao = 0;
      for(int i = 0; i <= 5; i++) {    //as primeiras medidas sao imprecisas
      tensao = analogRead(A2);
      delay(2);
        int modulo = map(tensao, 0, 1023, 0, 5000);
        Serial.println(modulo);
     }
     }
     }
void setDac(int value, int channel) {
  byte dacRegister = 0b00110000;                        // Sets default DAC registers B00110000, 1st bit choses DAC, A=0 B=1, 2nd Bit bypasses input Buffer, 3rd bit sets output gain to 1x, 4th bit controls active low shutdown. LSB are insignifigant here.
  int dacSecondaryByteMask = 0b0000000011111111;        // Isolates the last 8 bits of the 12 bit value, B0000000011111111.
  byte dacPrimaryByte = (value >> 8) | dacRegister;     //Value is a maximum 12 Bit value, it is shifted to the right by 8 bytes to get the first 4 MSB out of the value for entry into th Primary Byte, then ORed with the dacRegister  
  byte dacSecondaryByte = value & dacSecondaryByteMask; // compares the 12 bit value to isolate the 8 LSB and reduce it to a single byte. 
  // Sets the MSB in the primaryByte to determine the DAC to be set, DAC A=0, DAC B=1
  switch (channel) {
   case 0:
     dacPrimaryByte &= ~(1 << 7);     
   break;
   case 1:
     dacPrimaryByte |= (1 << 7);  
  }
  noInterrupts(); // disable interupts to prepare to send data to the DAC
  digitalWrite(dacChipSelectPin,LOW); // take the Chip Select pin low to select the DAC:
  SPI.transfer(dacPrimaryByte); //  send in the Primary Byte:
  SPI.transfer(dacSecondaryByte);// send in the Secondary Byte
  digitalWrite(dacChipSelectPin,HIGH);// take the Chip Select pin high to de-select the DAC:
  interrupts(); // Enable interupts
}
