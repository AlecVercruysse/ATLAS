#include <stdio.h>
#include "STM32F401RE.h"

////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////

#define SERVO_PIN    5

#define MIN_MICROS 770
#define MAX_MICROS 2270
#define CYCLE_MICROS 20000
const float usPerDeg = (MAX_MICROS - MIN_MICROS)/180;

// takes in an angle from 0-180, spits out microseconds to write to servo
long angleToMicros(float angle){
  return (long)(angle * usPerDeg) + MIN_MICROS;
}



int main(void) {
  // Configure flash latency and set clock to run at 84 MHz
  configureFlash();

  /* Configure APB prescalers
      1. Set APB2 (high-speed bus) prescaler to no division
      2. Set APB1 (low-speed bus) to divide by 2.
  */
  RCC->CFGR.PPRE2 = 0b000;
  RCC->CFGR.PPRE1 = 0b100;

  configureClock();

  // Enable GPIOA clock
  RCC->APB2ENR |= (1 << 17); //Enable TIM10
  RCC->APB2ENR |= (1 << 18); //Enable TIM11
  RCC->AHB1ENR.GPIOAEN = 1; // Enable GPIOA Clock

  // Servo Pin
  pinMode(GPIOA, SERVO_PIN, GPIO_OUTPUT);

  // Micros Timer:
  // Goal, Count to 20,000, microsecond resolution
  // PSC + 1 = 50
  // 50MHz with a 50 prescaler gives microsecond resolution
  // Can count to 2^16 > 20,000
  TIM10->PSC = 49;
  TIM10->CR1 |= (1 << 0); // Enable the counter
  TIM10->EGR |= (1 << 0);  // Generate an update event

  // Millis Length Timer:
  // PSC + 1 = 50000
  // 50MHz with a 50000 prescaler gives millisecond resolution
  // Can count t0 65 seconds maximum
  TIM11->PSC = 999;
  TIM11->CR1 |= (1 << 0); // Enable the counter
  TIM11->EGR |= (1 << 0);  // Generate an update event

  TIM10->CNT = 0;
  TIM11->CNT = 0;

  float angleDes = 0;

  while(1){

    long microsHigh = angleToMicros(angleDes);

    long curMicros = TIM10->CNT;
    if(curMicros < microsHigh){
      digitalWrite(GPIOA, SERVO_PIN, 1);
    } else if(curMicros < CYCLE_MICROS){
      digitalWrite(GPIOA, SERVO_PIN, 0);
    } else {
      TIM10->CNT = 0;
    }

    long curTimeMs = TIM11->CNT;
    if(curTimeMs >= 50){
      angleDes += 0.1;
      TIM11->CNT = 0;
    }

    if(angleDes >= 180){
      angleDes = 0;
    }
  }
}