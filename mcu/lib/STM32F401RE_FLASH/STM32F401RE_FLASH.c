// STM32F401RE_FLASH.c
// Source code for FLASH functions

#include "STM32F401RE_FLASH.h"

void configureFlash() {
    FLASH->ACR.LATENCY = 2; // Set to 0 waitstates
    FLASH->ACR.PRFTEN = 1; // Turn on the ART
}