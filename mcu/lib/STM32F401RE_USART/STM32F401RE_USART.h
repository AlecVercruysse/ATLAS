// STM32F401RE_USART.h
// Header for USART functions

#ifndef STM32F4_USART_H
#define STM32F4_USART_H

#include <stdint.h>

///////////////////////////////////////////////////////////////////////////////
// Definitions
///////////////////////////////////////////////////////////////////////////////

#define __IO volatile

// Base addresses
#define USART1_BASE (0x40011000UL) // base address of USART1
#define USART2_BASE (0x40004400UL) // base address of USART2

// Defines for USART case statements
#define USART1_ID 1
#define USART2_ID 2

///////////////////////////////////////////////////////////////////////////////
// Bitfield structs
///////////////////////////////////////////////////////////////////////////////
typedef struct {
    __IO uint32_t PE            : 1;
    __IO uint32_t FE            : 1;
    __IO uint32_t NF            : 1;
    __IO uint32_t ORE           : 1;
    __IO uint32_t IDLE          : 1;
    __IO uint32_t RXNE          : 1;
    __IO uint32_t TC            : 1;
    __IO uint32_t TXE           : 1;
    __IO uint32_t LBD           : 1;
    __IO uint32_t CTS           : 1;
    __IO uint32_t               : 22;
} SR_bits;

typedef struct {
    __IO uint32_t DR            : 9;
    __IO uint32_t               : 23;
} DR_bits;

typedef struct {
    __IO uint32_t DIV_Fraction  : 4;
    __IO uint32_t DIV_Mantissa  : 12;
    __IO uint32_t               : 16;
} BRR_bits;

typedef struct {
    __IO uint32_t SBK           : 1;
    __IO uint32_t RWU           : 1;
    __IO uint32_t RE            : 1;
    __IO uint32_t TE            : 1;
    __IO uint32_t IDLEIE        : 1;
    __IO uint32_t RXNEIE        : 1;
    __IO uint32_t TCIE          : 1;
    __IO uint32_t TXEIE         : 1;
    __IO uint32_t PEIE          : 1;
    __IO uint32_t PS            : 1;
    __IO uint32_t PCE           : 1;
    __IO uint32_t WAKE          : 1;
    __IO uint32_t M             : 1;
    __IO uint32_t UE            : 1;
    __IO uint32_t               : 1;
    __IO uint32_t OVER8         : 1;
    __IO uint32_t               : 16;
} CR1_bits;

typedef struct {
    __IO uint32_t ADD           : 4;
    __IO uint32_t               : 1;
    __IO uint32_t LBDL          : 1;
    __IO uint32_t LBDIE         : 1;
    __IO uint32_t               : 1;
    __IO uint32_t LBCL          : 1;
    __IO uint32_t CPHA          : 1;
    __IO uint32_t CPOL          : 1;
    __IO uint32_t CLKEN         : 1;
    __IO uint32_t STOP          : 2;
    __IO uint32_t LINEN         : 1;
    __IO uint32_t               : 17;
} CR2_bits;

typedef struct {
    __IO SR_bits    SR;     // 0x00 Offset
    __IO DR_bits    DR;     // 0x04 Offset
    __IO BRR_bits   BRR;    // 0x08 Offset
    __IO CR1_bits   CR1;    // 0x0C Offset
    __IO CR2_bits   CR2;    // 0x10 Offset
    __IO uint32_t   CR3;    // 0x14 Offset
    __IO uint32_t   CGTPR;  // 0x18 Offset
} USART_TypeDef;

#define USART1 ((USART_TypeDef *) USART1_BASE)
#define USART2 ((USART_TypeDef *) USART2_BASE)

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

USART_TypeDef * initUSART(uint8_t USART_ID);
void sendChar(USART_TypeDef * USART, uint8_t data);
uint8_t receiveChar(USART_TypeDef * USART);

#endif