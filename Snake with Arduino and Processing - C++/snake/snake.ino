const int UP_BUTTON = 2;
const int DOWN_BUTTON = 3;
const int LEFT_BUTTON = 4;
const int RIGHT_BUTTON = 5;

const int debounceDelay = 5; 

boolean buttonState[4] = {false, false, false, false}; 
boolean lastButtonState[4] = {true, true, true, true}; 
unsigned long lastDebounceTime[4] = {0, 0, 0, 0}; 

void setup() {
  pinMode(UP_BUTTON, INPUT_PULLUP);
  pinMode(DOWN_BUTTON, INPUT_PULLUP);
  pinMode(LEFT_BUTTON, INPUT_PULLUP);
  pinMode(RIGHT_BUTTON, INPUT_PULLUP);

  Serial.begin(9600);
}

boolean debounce(int pin, int index) {
  int reading = digitalRead(pin);

  if (reading != lastButtonState[index]) {
    lastDebounceTime[index] = millis();
  }

  if ((millis() - lastDebounceTime[index]) > debounceDelay) {
    if (reading != buttonState[index]) {
      buttonState[index] = reading;
      if (reading == LOW) {
        return true;
      }
    }
  }

  lastButtonState[index] = reading;
  return false;
}

void loop() {
  if (debounce(UP_BUTTON, 0)) {
    Serial.println("UP");
  }
  if (debounce(DOWN_BUTTON, 1)) {
    Serial.println("DOWN");
  }
  if (debounce(LEFT_BUTTON, 2)) {
    Serial.println("LEFT");
  }
  if (debounce(RIGHT_BUTTON, 3)) {
    Serial.println("RIGHT");
  }
}