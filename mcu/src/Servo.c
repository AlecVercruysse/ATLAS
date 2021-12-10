#include <stdio.h>
#include "STM32F401RE.h"

////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////

#define SERVO_PIN    4 // GPIOA
#define BEAT_PIN     0 // GPIOA
#define GREEN_PIN    10 // GPIOB
#define RED_PIN      1 // GPIOA

#define USART_ID USART2_ID

#define MIN_MICROS 770
#define MAX_MICROS 2270
#define CYCLE_MICROS 20000

// Used for testing
const float usPerDeg = (MAX_MICROS - MIN_MICROS)/180;
// takes in an angle from 0-180, spits out microseconds to write to servo
long angleToMicros(float angle){
  return (long)(angle * usPerDeg) + MIN_MICROS;
}

// Servo Pattern points

// Red laser pattern locations
#define RPP0 770
#define RPP1 917
#define RPP2 1022
#define RPP3 1136
#define RPP4 1242
#define RPP5 1370
#define RPP6 1465
#define RPP7 1599
#define RPP8 1724
#define RPP9 1852
#define RPPA 1960
#define RPPB 2084
#define RPPC 2204
#define RPPD 2269

// Green laser pattern locations
#define GPP0 770  
#define GPP1 870
#define GPP2 966
#define GPP3 1091
#define GPP4 1208
#define GPP5 1328
#define GPP6 1442
#define GPP7 1532
#define GPP8 1664
#define GPP9 1792
#define GPPA 1862
#define GPPB 1978
#define GPPC 2134
#define GPPD 2269   

//Pattern set 1

// start, end, red, green
//  int pats[6][4] = {
//                        {GPP0,  GPP1, 1, 1},
//                        {RPP0,  RPP1, 0, 1},
//                        {GPP2, GPP3,  1, 1},
//                        {RPP3, RPP4,  1, 0},
//                        {RPP5, RPP6,  1, 0},
//                        {RPP7, RPP8,  1, 0} //1328, 1442
//                        };

// Pattern set 2

int pats[6][4] = {
                  {GPPC,  GPPD, 1, 1},
                  {GPPA,  GPPB, 1, 1},
                  {GPP8, GPP9,  0, 1},
                  {RPP6, RPP7,  1, 0},
                  {RPP4, RPP5,  1, 0},
                  {RPP2, RPP3,  1, 0}
                  };

// used for printing
char text[50];

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
  RCC->APB2ENR |= (1 << 16); //Enable TIM10
  RCC->APB2ENR |= (1 << 17); //Enable TIM10
  RCC->APB2ENR |= (1 << 18); //Enable TIM11
  RCC->AHB1ENR.GPIOAEN = 1; // Enable GPIOA Clock
  RCC->AHB1ENR.GPIOBEN = 1; // Enable GPIOA Clock

  // Servo Pin
  pinMode(GPIOA, SERVO_PIN, GPIO_OUTPUT);
  // Beat Pin from FPGA
  pinMode(GPIOA, BEAT_PIN, GPIO_INPUT);
  // Red Laser Transistor -> Relay
  pinMode(GPIOA, RED_PIN, GPIO_OUTPUT);
  // Green Laser Transistor -> Relay
  pinMode(GPIOB, GREEN_PIN, GPIO_OUTPUT);


  USART_TypeDef* USART = initUSART(USART_ID);

  // Print millis timer
  // PSC + 1 = 42000
  // 84MHz with a 42000 prescaler gives 0.5 ms resolution
  // Can count t0 32 seconds maximum
  TIM9->PSC = 41999;
  TIM9->CR1 |= (1 << 0); // Enable the counter
  TIM9->EGR |= (1 << 0);  // Generate an update event

  // Servo Micros Timer:
  // Goal, Count to 20,000, microsecond resolution
  // PSC + 1 = 84
  // 84MHz with a 84 prescaler gives microsecond resolution
  // Can count to 2^16 > 20,000
  TIM10->PSC = 83;
  TIM10->CR1 |= (1 << 0); // Enable the counter
  TIM10->EGR |= (1 << 0);  // Generate an update event

  // Beat Pin Millis Length Timer:
  // PSC + 1 = 42000
  // 84MHz with a 42000 prescaler gives 0.5 ms resolution
  // Can count t0 32 seconds maximum
  TIM11->PSC = 41999;
  TIM11->CR1 |= (1 << 0); // Enable the counter
  TIM11->EGR |= (1 << 0);  // Generate an update event


  TIM9->CNT = 0;  // Print
  TIM10->CNT = 0; // Servo Micros
  TIM11->CNT = 0; // BPM

  uint8_t prevBeatRead = 0; // boolean variable that tracks previous read value

  int beatIntervalMs = 10000; 

  int patInd = 0;

  uint8_t patState = 0;

  digitalWrite(GPIOB, GREEN_PIN, 1);
  digitalWrite(GPIOA, RED_PIN, 1);

  while(1){

    // Pattern selection
    
    if(beatIntervalMs < 250){ //< 0.25sec, bpm > 240
      patInd = 0;
    } else if(beatIntervalMs < 500){ //< 0.5sec, bpm > 120
      patInd = 2;
    } else if(beatIntervalMs < 1000){ //< 1sec, bpm > 60
      patInd = 3;
    } else if (beatIntervalMs < 2000) { // < 2sec, 60 > bpm > 30 
      patInd = 4;
    } else if (beatIntervalMs >= 2000){ // > 2sec, 30 > bpm
      patInd = 5;
    }

    // Writes Servo PWM signal out
    long curMicros = TIM10->CNT;
    long microsDes = pats[patInd][patState];
    if(curMicros < microsDes){
      digitalWrite(GPIOA, SERVO_PIN, 1);
    } else if(curMicros < CYCLE_MICROS){
      digitalWrite(GPIOA, SERVO_PIN, 0);
    } else {
      TIM10->CNT = 0;
    }

    uint8_t curBeatRead = digitalRead(GPIOA, BEAT_PIN);

    if (curBeatRead == 1 && prevBeatRead == 0){ // only on the rising edge
      beatIntervalMs = (TIM11->CNT)/2;

      digitalWrite(GPIOA, RED_PIN, pats[patInd][2]);
      digitalWrite(GPIOB, GREEN_PIN, pats[patInd][3]);
      
      // sprintf(text, "\n interval: %d | ind: %d | red: %d | green: %d\n", beatIntervalMs, patInd, pats[patInd][2], pats[patInd][3]);
      // for (size_t j = 0; text[j]; j++) {
      //     sendChar(USART, text[j]);
      // }
      TIM11->CNT = 0;
    }
    prevBeatRead = curBeatRead;

    if(TIM9->CNT > 200){
        // sprintf(text, "\n%d  %d  %d\n", beatIntervalMs, patInd, patState);
        // for (size_t j = 0; text[j]; j++) {
        //     sendChar(USART, text[j]);
        // }
        TIM9->CNT = 0;
    }
  }
}