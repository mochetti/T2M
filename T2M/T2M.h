//
//  T2M.h
//  
//
//  Created by Thiago Mochetti on 28/01/16.
//
//

#ifndef T2M_h
#define T2M_h

#include "Arduino.h"

class Led
{
public:
    Led(int pin);
    void blink(int interval, int times);
private:
    int _pin, _interval, _times;

};

class Motor
{
public:
    Motor(int pinAA, int pinAB, int pinBA, int pinBB);
    void linha(int velocidade, int sentido);
    void gira(int velocidade, int sentido);      // sentido = 0 - horário, 1 - anti-horário
    void curva(int velocidade, int razaoVelocidades, int sentido);
private:
    int _pinAA, _pinAB, _pinBA, _pinBB, _velocidade, _sentido, _razaoVelocidades;
    
};

#endif
