// main.c

#include "STM32F401RE_FLASH.h"
#include "STM32F401RE_RCC.h"
#include "STM32F401RE_USART.h"
#include "STM32F401RE_SPI.h"
#include "STM32F401RE_GPIO.h"
#include <stdio.h>
#include <string.h>

#define USART_ID USART2_ID

uint32_t fpga_out[32];
char text[50];
char donetext[30] = "--done--\n\n";
char starttext[30] = "--start--\n";

    
void delay_ms(int ms) {
   while (ms-- > 0) {
      volatile int x=1000;
      while (x-- > 0)
         __asm("nop");
   }
}

void send_sample(USART_TypeDef* USART) {
    digitalWrite(GPIOA, CS, CS_ENABLED);
    for(volatile int i = 0; i < 1000; i ++); // delay loop
    for (size_t i =0; i < 32; i++) {
        fpga_out[i] = spiSendReceive32(0);
    }
    for(volatile int i = 0; i < 1000; i ++); // delay loop
    digitalWrite(GPIOA, CS, CS_DISABLED);

    
    for (size_t i = 0; starttext[i]; i++) {
        sendChar(USART, starttext[i]);
    }

    for (size_t i = 0; i < 32; i++) {
        sprintf(text, "%08lx \n", fpga_out[i]);
        for (size_t j = 0; text[j]; j++) {
            sendChar(USART, text[j]);
        }
    }

    for (size_t i = 0; donetext[i]; i++) {
        sendChar(USART, donetext[i]);
    }
}

int main(void) {
    // Configure flash and clock
    configureFlash();
    configureClock(); // Set system clock to 84 MHz

    // USART clock is given by initUSART();
    RCC->AHB1ENR.GPIOAEN = 1;
    RCC->AHB1ENR.GPIOBEN = 1;
    RCC->APB2ENR |= 1 << 12; // give SPI1 clock.

    // BR: 111 (42 MHz/256 = ~.164 MHz)
    // CPOL: 0 (idle low)
    // CPHA: 1 (samples on lagging edge)
    spiInit(110, 0, 1);
    delay_ms(100);

    USART_TypeDef* USART = initUSART(USART_ID);

    while(1) {
        send_sample(USART);
        delay_ms(200);
    }
}