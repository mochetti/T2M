//
//  T2M.cpp
//  
//
//  Created by Thiago Mochetti on 28/01/16.
//
//

#include "T2M.h"
#include "Arduino.h"

Led::Led(int pin)
{
    pinMode(pin, OUTPUT);
    _pin = pin;
}

Motor::Motor(int pinAA, int pinAB, int pinBA, int pinBB)
{
    pinMode(pinAA, OUTPUT);
    pinMode(pinAB, OUTPUT);
    pinMode(pinBA, OUTPUT);
    pinMode(pinBB, OUTPUT);
    
    _pinAA = pinAA;
}

void Led::blink(int interval, int times)
{
    int a;
    for (a = 0; a < times; a++)
    {
        digitalWrite(_pin, HIGH);
        delay(interval);
        digitalWrite(_pin, LOW);
        delay(interval);
        
    }
}

void Motor::linha(int velocidade, int sentido)
{
    if (velocidade > 0) {
        
        analogWrite(_pinAA, velocidade);
        analogWrite(_pinAB, velocidade);
        analogWrite(_pinBA, velocidade);
        analogWrite(_pinBB, velocidade);
        
        if (sentido == 1) {
            digitalWrite(_pinAA, LOW);
            digitalWrite(_pinAB, HIGH);
            digitalWrite(_pinBA, LOW);
            digitalWrite(_pinBB, HIGH);
        }
        else {
            digitalWrite(_pinAA, HIGH);
            digitalWrite(_pinAB, LOW);
            digitalWrite(_pinBA, HIGH);
            digitalWrite(_pinBB, LOW);
        }
    }
    else {
        if (sentido == 1) {
            digitalWrite(_pinAA, LOW);
            digitalWrite(_pinAB, HIGH);
            digitalWrite(_pinBA, LOW);
            digitalWrite(_pinBB, HIGH);
        }
        else {
            digitalWrite(_pinAA, HIGH);
            digitalWrite(_pinAB, LOW);
            digitalWrite(_pinBA, HIGH);
            digitalWrite(_pinBB, LOW);
        }
    }
        
}

void Motor::gira(int velocidade, int sentido)
{
    
}