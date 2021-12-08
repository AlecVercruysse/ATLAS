#include <stdio.h>
#include "STM32F401RE.h"

////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////

#define SERVO_PIN    4
#define BEAT_PIN     0

#define USART_ID USART2_ID

#define MIN_MICROS 770
#define MAX_MICROS 2270
#define CYCLE_MICROS 20000
const float usPerDeg = (MAX_MICROS - MIN_MICROS)/180;

char text[50];
// takes in an angle from 0-180, spits out microseconds to write to servo
long angleToMicros(float angle){
  return (long)(angle * usPerDeg) + MIN_MICROS;
}

int redPatPoints[] = {770, 917,  1022, 1136, 1242, 1370, 1465, 
                    1599, 1724, 1852, 1960, 2084, 2204, 2269};

int greenPatPoints[] = {770,  870,  966,  1091, 1208, 1328, 1442, 
                       1532, 1664, 1792, 1862, 1978, 2134, 2269};

// {type, start, end, timeMs} | 0 = cont, 1 = instant
// int greenPats[3][3] = {
//                        {0, 770,  1208},
//                        {2, 1532, 1978},
//                        {1, 1328, 1442} //1328, 1442
//                        };

int greenPats[3][2] = {
                       {770,  1208},
                       {1532, 1978},
                       {1328, 1442} //1328, 1442
                       };

int getPos(int pats[][3], int patInd, int patLen){

  long curTimeMs = (TIM9->CNT)/2;

  int patType = pats[patInd][0];
  int patStart = pats[patInd][1];
  int patEnd = pats[patInd][2];

  int pos = -1;
  float fracPat = (float)curTimeMs / (float)patLen;

  if(patType == 0){
    if(fracPat < 0.5){
      pos = patStart + (int)(fracPat * 2.0 * (patEnd - patStart));
    } else if (fracPat >= 0.5){
      pos = patEnd - (int)(((fracPat-0.5) * 2.0) * (patEnd - patStart));
    }
  }

  if(patType == 1){
    if(fracPat < 0.5){
      pos = patStart;
    } else if (fracPat >= 0.5){
      pos = patEnd;
    }
  }

  if(patType == 2){
    if(fracPat < 0.5){
      pos = patStart + (int)(fracPat * 2 * (patEnd - patStart));
    } else if (fracPat >= 0.5){
      pos = patEnd;
    }
  }

  if(curTimeMs >= patLen){
    TIM9->CNT = 0;
  }
  return pos;
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
  RCC->APB2ENR |= (1 << 16); //Enable TIM10
  RCC->APB2ENR |= (1 << 17); //Enable TIM10
  RCC->APB2ENR |= (1 << 18); //Enable TIM11
  RCC->AHB1ENR.GPIOAEN = 1; // Enable GPIOA Clock

  // Servo Pin
  pinMode(GPIOA, SERVO_PIN, GPIO_OUTPUT);
  // Beat Pin from FPGA
  pinMode(GPIOA, BEAT_PIN, GPIO_INPUT);

  //pinMode(GPIOA, 5, GPIO_OUTPUT);

  USART_TypeDef* USART = initUSART(USART_ID);

  // Pattern Millis Timer:
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


  TIM9->CNT = 0;  // Pattern millis*2
  TIM10->CNT = 0; // Servo Micros
  TIM11->CNT = 0; // BPM

  uint8_t prevBeatRead = 0;

  int beatIntervalMs = 10000;

  int patInd = 0;

  int patState = 0;

  while(1){

    long microsDes = -1; 
    // microsDes = getPos(greenPats, 1, beatIntervalMs);
    // if(beatIntervalMs < 1000){ //< 1sec, bpm > 60
    //    microsDes = getPos(greenPats, 2, beatIntervalMs);
    // } else if (beatIntervalMs >= 1000 && beatIntervalMs < 2000) { // < 2sec, 60 > bpm > 30 
    //    microsDes = getPos(greenPats, 1, beatIntervalMs);
    // } else if (beatIntervalMs >= 2000){ // > 2sec, 30 > bpm
    //    microsDes = getPos(greenPats, 0, beatIntervalMs);
    // }

    // if(beatIntervalMs < 1000){ //< 1sec, bpm > 60
    //   patInd = 0;
    // } else if (beatIntervalMs >= 1000 && beatIntervalMs < 2000) { // < 2sec, 60 > bpm > 30 
    //   patInd = 1;
    // } else if (beatIntervalMs >= 2000){ // > 2sec, 30 > bpm
    //   patInd = 2;
    // }

    long curMicros = TIM10->CNT;

    microsDes = greenPatPoints[patInd];

    if(curMicros < microsDes){
      digitalWrite(GPIOA, SERVO_PIN, 1);
    } else if(curMicros < CYCLE_MICROS){
      digitalWrite(GPIOA, SERVO_PIN, 0);
    } else {
      TIM10->CNT = 0;
    }

    uint8_t curBeatRead = digitalRead(GPIOA, BEAT_PIN);

    if (curBeatRead == 1 && prevBeatRead == 0){ // only on the rising edge
      //togglePin(GPIOA,5);
      beatIntervalMs = (TIM11->CNT)/2;
      //patState = ~patState;
      if(patState == 0){
        patInd += 1;
      } else {
        patInd -= 1;
      }
      TIM11->CNT = 0;
      // sprintf(text, "\n%d\n", beatIntervalMs);
      // for (size_t j = 0; text[j]; j++) {
      //     sendChar(USART, text[j]);
      // }
    }
    prevBeatRead = curBeatRead;

    // long curTimeMs = (TIM11->CNT / 2);
    // if(curTimeMs >= 1000){
    //   patInd += 1;
    //   TIM11->CNT = 0;
    // }

    if(patInd >= 14){
      patState = 1;
    } else if (patInd <= 0){
      patState = 0;
    }

  }


}