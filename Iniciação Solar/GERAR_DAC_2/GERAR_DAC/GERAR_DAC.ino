// include the library code:
#include <SPI.h>
 
// Set Constants
const int dacChipSelectPin = 10;      // set pin 9 as the chip select for the DAC:
float valor = 0;
// Start setup function:
void setup() {  
  pinMode (dacChipSelectPin, OUTPUT); 
  // set the ChipSelectPins high initially: 
  digitalWrite(dacChipSelectPin, HIGH);  
  // initialise SPI:
  SPI.begin();
  SPI.setBitOrder(MSBFIRST);         
  SPI.setDataMode(SPI_MODE0);        
  Serial.begin(9600);
//digite aqui a tensao desejada na saida
valor = 3.3;
} // End setup function.

// Start loop function:
void loop() {  
  float a = valor*4096/5;
  setDac(a,0);
  
 int medida = analogRead(A0);
 delay(2);
 int b = map(medida, 0, 1023, 0, 5000);
 Serial.println(b);
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
