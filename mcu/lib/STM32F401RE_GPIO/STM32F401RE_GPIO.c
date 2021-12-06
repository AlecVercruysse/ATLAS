// STM32F401RE_GPIO.c
// Source code for GPIO functions

#include "STM32F401RE_GPIO.h"

void pinMode(GPIO_TypeDef* GPIO_PORT_PTR, int pin, int function) {
    switch(function) {
        case GPIO_INPUT:
            GPIO_PORT_PTR->MODER &= ~(0b11 << 2*pin);
            break;
        case GPIO_OUTPUT:
            GPIO_PORT_PTR->MODER |= (0b1 << 2*pin);
            GPIO_PORT_PTR->MODER &= ~(0b1 << (2*pin+1));
            break;
        case GPIO_ALT:
            GPIO_PORT_PTR->MODER &= ~(0b1 << 2*pin);
            GPIO_PORT_PTR->MODER |= (0b1 << (2*pin+1));
            break;
        case GPIO_ANALOG:
            GPIO_PORT_PTR->MODER |= (0b11 << 2*pin);
            break;
    }
}

int digitalRead(GPIO_TypeDef* GPIO_PORT_PTR, int pin) {
    return ((GPIO_PORT_PTR->IDR) >> pin) & 1;
}

void digitalWrite(GPIO_TypeDef* GPIO_PORT_PTR, int pin, int val) {
    if(val == 1) {
        GPIO_PORT_PTR->ODR |= (1 << pin);
    }
    else if(val == 0) {
        GPIO_PORT_PTR->ODR &= ~(1 << pin);
    }
    
}

void togglePin(GPIO_TypeDef* GPIO_PORT_PTR,int pin) {
    // Use XOR to toggle
    GPIO_PORT_PTR->ODR ^= (1 << pin);
}