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

Carro::Carro(int pinAA, int pinAB, int pinBA, int pinBB, int largura)
{
    pinMode(pinAA, OUTPUT);
    pinMode(pinAB, OUTPUT);
    pinMode(pinBA, OUTPUT);
    pinMode(pinBB, OUTPUT);
    
    _pinAA = pinAA;
}

IRarray::IRarray(int clock, int portaAnalogica)
{
    pinMode(clock, OUTPUT);
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

void Carro::linha(int velocidade, int sentido)
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
        
        analogWrite(_pinAA, 255);
        analogWrite(_pinAB, 255);
        analogWrite(_pinBA, 255);
        analogWrite(_pinBB, 255);
        
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

void Carro::gira(int velocidade, int sentido)
{
    analogWrite(_pinAA, velocidade);
    analogWrite(_pinAB, velocidade);
    analogWrite(_pinBA, velocidade);
    analogWrite(_pinBB, velocidade);
    
    if (sentido == 1) {
        digitalWrite(_pinAA, LOW);
        digitalWrite(_pinAB, HIGH);
        digitalWrite(_pinBA, HIGH);
        digitalWrite(_pinBB, LOW);
    }
    else {
        digitalWrite(_pinAA, HIGH);
        digitalWrite(_pinAB, LOW);
        digitalWrite(_pinBA, LOW);
        digitalWrite(_pinBB, HIGH);
    }
}

void Carro::curva(int velocidade, int raio, int setor, int sentido)
{
    int velMaior = velocidade;
    int velMenor = velMaior * ((raio - largura/2)/(raio + largura/2));
    
    if(sentido == 0) {
        
        analogWrite(_pinAA, velMaior);
        analogWrite(_pinAB, velMaior);
        analogWrite(_pinBA, velMenor);
        analogWrite(_pinBB, velMenor);
        
    }
    else {
        
        analogWrite(_pinAA, velMaior);
        analogWrite(_pinAB, velMaior);
        analogWrite(_pinBA, velMenor);
        analogWrite(_pinBB, velMenor);
    }
    
    digitalWrite(_pinAA, HIGH);
    digitalWrite(_pinAB, LOW);
    digitalWrite(_pinBA, HIGH);
    digitalWrite(_pinBB, LOW);
    
}

void IRarray::varredura()
{
    int atual;
    int soma;
    for (int a = 0; a < 5; a = a++) {
        atual = analogRead(_portaAnalogica);
        if (atual >= 700)atual = 1*10ˆa;
        else atual = 0;
        soma = soma + atual;
        digitalWrite(_clock, HIGH);
        delay(2);
        digitalWrite(_clock, LOW);
        delay(2);
        digitalWrite(_clock, HIGH);
        delay(2);
        digitalWrite(_clock, LOW);
        delay(2);
    }
    return soma;
}