#define OUT_PIN 5

void setup() {
  pinMode(OUT_PIN, OUTPUT);
  digitalWrite(OUT_PIN, LOW);
  Serial.begin(115200);
}

void loop() {
  for(int i = 0; i < 10; i++){
    digitalWrite(OUT_PIN, HIGH);
    delayMicroseconds(170);
    digitalWrite(OUT_PIN, LOW);
    delayMicroseconds(830);
    delay(499);
    Serial.print("fast");
    Serial.println(i);
  }

  for(int i = 0; i < 5; i++){
    digitalWrite(OUT_PIN, HIGH);
    delayMicroseconds(170);
    digitalWrite(OUT_PIN, LOW);
    delayMicroseconds(830);
    delay(1100);
    Serial.print("mid");
    Serial.println(i);
  }

  for(int i = 0; i < 5; i++){
    digitalWrite(OUT_PIN, HIGH);
    delayMicroseconds(170);
    digitalWrite(OUT_PIN, LOW);
    delayMicroseconds(830);
    delay(2200);
    Serial.print("slow");
    Serial.println(i);
  }
}
