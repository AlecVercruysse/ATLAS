// STM32F401RE_SPI.c
// SPI function declarations

#include "STM32F401RE_SPI.h"
#include "STM32F401RE_RCC.h"
#include "STM32F401RE_GPIO.h"

/* Enables the SPI peripheral and intializes its clock speed (baud rate), polarity, and phase. */
void spiInit(uint32_t clkdivide, uint32_t cpol, uint32_t ncpha) {
    // this should not be called during operation!!
    // the CR1.SPE bit needs to be zero for these changes to go into effect.
    // GPIOA, GPIOB, & SPI1 needs clocks

    // set alternate function of PB3, PB4, PB5.
    GPIOB->AFRL = ((0b0101 << 12) | (0b0101 << 16) | (0b0101 << 20));
    //GPIOA->AFRL = (0b0101 << 28) | (0b0101 << 24) | (0b0101 << 20);
    pinMode(GPIOB, 3, GPIO_ALT); // SCK
    GPIOB->PURPDR |= 1 << 7;    // PUPDR5 -> pulldown
    GPIOB->PURPDR &= ~(1 << 6); // PUPDR5 -> pulldown    

    pinMode(GPIOB, 4, GPIO_ALT); // MISO
    pinMode(GPIOB, 5, GPIO_ALT); // MOSI

    GPIOA->PURPDR |=   1<<5;  // PUPDR2 -> pulldown
    GPIOA->PURPDR &= ~(1<<4); // PUPDR2 -> pulldown
    pinMode(GPIOA, CS, GPIO_OUTPUT);
    digitalWrite(GPIOA, CS, CS_DISABLED);
    

    SPI1->CR1.MSTR = 1; // master-mode
    // SPI1->CR1.SSM = 1;  // cs managed by software. (not used, not even connected to pad)
    SPI1->CR2.SSOE = 1; //
    // MSB first, 8-bit dataframe. CRC disabled. 2-line unidirectional data mode.
    SPI1->CR1.CPHA = ncpha;
    SPI1->CR1.CPOL = cpol;
    SPI1->CR1.BR = clkdivide; // can only be 3 bits! see datasheet for mapping.

    SPI1->CR1.SPE = 1; // enable peripheral
}

/* Transmits a character (1 byte) over SPI and returns the received character.
 *    -- send: the character to send over SPI
 *    -- return: the character received over SPI */
uint8_t spiSendReceive(uint8_t send) {
    // assumes that CS is enabled! we can't take care of that
    // in this function because the DS chip doesn't want CE 
    // toggled between byte transfers.
    SPI1->DR.DR = send;
    while(!SPI1->SR.RXNE); // wait until RXNE is set
    return (uint8_t) SPI1->DR.DR;
}

/* Transmits a short (2 bytes) over SPI and returns the received short.
 *    -- send: the short to send over SPI
 *    -- return: the short received over SPI */
uint16_t spiSendReceive16(uint16_t send) {
    uint16_t result = spiSendReceive(send >> 8) << 8;
    result |= spiSendReceive((uint8_t)(send & 0xFF));
    return result;
}

uint32_t spiSendReceive32(uint32_t send) {
    uint32_t result = spiSendReceive16(send >> 16) << 16;
    result |= spiSendReceive16((uint16_t)(send & 0xFFFF));
    return result;
}