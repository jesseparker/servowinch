#define serial_debug true
#define baud 115200 

#define SENSOR_A 3
#define SENSOR_B 2

#define motorEnable 5
#define motorPlus 4
#define motorMinus 6

#define motor2Enable 7
#define motor2Plus 8
#define motor2Minus 9

#define spd3 255/2.5
#define spd2 255/2
#define spd1 255

#define spd1d 10
#define spd2d 5


int count = 0;
int count2 = 0;
int delayTime = 2000;
int val = 0;
long i;

int sensor01;
int sensor02;

unsigned long int loopCount = 0;

int stepOld;
int step;
int direction;

//int pwm; 
boolean complete;

 int PulseCount;
 int commandPosition;

String inString = "";



void moveForward(int delta) {
    digitalWrite(motorPlus, HIGH);
    digitalWrite(motorMinus, LOW);
    //digitalWrite(motorEnable, HIGH);
    if (delta > spd1d)
      analogWrite(motorEnable, spd1);
    else if (delta > spd2d)
      analogWrite(motorEnable, spd2);
    else
      analogWrite(motorEnable, spd3);     
}
void move2Forward() {
    digitalWrite(motor2Plus, HIGH);
    digitalWrite(motor2Minus, LOW);
    digitalWrite(motor2Enable, HIGH);
}

void moveBackward(int delta) {
    digitalWrite(motorPlus, LOW);
    digitalWrite(motorMinus, HIGH);
    //digitalWrite(motorEnable, HIGH);
    if (delta > spd1d)
      analogWrite(motorEnable, spd1);
    else if (delta > spd2d)
      analogWrite(motorEnable, spd2);
    else
      analogWrite(motorEnable, spd3);     
 
}
void move2Backward() {
    digitalWrite(motor2Plus, LOW);
    digitalWrite(motor2Minus, HIGH);
    digitalWrite(motor2Enable, HIGH);

}


void motorOff() {
    analogWrite(motorEnable, 0);
    digitalWrite(motorPlus, LOW);
    digitalWrite(motorMinus, LOW);
}
void motor2Off() {
    digitalWrite(motor2Enable, LOW);
    digitalWrite(motor2Plus, LOW);
    digitalWrite(motor2Minus, LOW);
}

void setup() {
  Serial.begin(baud);
while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }  
//  for (count = 0; count < 4; count++) {
//    pinMode(motorPins[count], OUTPUT);
//  }
   pinMode(SENSOR_A, INPUT);
   pinMode(SENSOR_B, INPUT);
   pinMode(motorEnable, OUTPUT);
   pinMode(motorPlus, OUTPUT);
   pinMode(motorMinus, OUTPUT);

   pinMode(motor2Enable, OUTPUT);
   pinMode(motor2Plus, OUTPUT);
   pinMode(motor2Minus, OUTPUT);

   motorOff();
   motor2Off();
   
  PulseCount = 0;
  complete = true;
  count = 0;
  count2 = 0;
  }

void loop() {

  while (Serial.available() > 0) {
    int inChar = Serial.read();
    if (isDigit(inChar) || inChar == '-') {
      // convert the incoming byte to a char and add it to the string:
      inString += (char)inChar;
    }
    // if you get a newline, print the string, then the string's value:
    if (inChar == '\n') {
      if (serial_debug) {
        Serial.print("Value:");
        Serial.println(inString.toInt());
        Serial.print("String: ");
        Serial.println(inString);
      }
      commandPosition = inString.toInt();

      complete = false;
      // clear the string for new input:
      inString = "";
    }
  }

  sensor01 = digitalRead(SENSOR_A);
  sensor02 = digitalRead(SENSOR_B);


  if(sensor01 == 1 && sensor02 == 1){
    step = 0;
    if(stepOld == 1){
      PulseCount--;
    }
    if(stepOld == 3){
      PulseCount++;
    }
    stepOld = 0;
  }

  else if(sensor01 == 0 && sensor02 == 1){
    step = 1;
    if(stepOld == 2){
      PulseCount--;
    }
    if(stepOld == 0){
      PulseCount++;
    }
    stepOld = 1;
   }

  else if(sensor01 == 0 && sensor02 == 0){
    step = 2;
    if(stepOld == 3){
      PulseCount--;
    }
    if(stepOld == 1){
      PulseCount++;
    }
    stepOld = 2;
  }

  else if(sensor01 == 1 && sensor02 == 0){
    step = 3;
    if(stepOld == 0){
      PulseCount--;
    }
    if(stepOld == 2){
      PulseCount++;
    }
    stepOld = 3;
   }


  if (PulseCount < commandPosition) {
   // CCW
   moveForward(abs(PulseCount - commandPosition));
   move2Forward();
  }
  else if (PulseCount > commandPosition)  {
   // CW
   moveBackward(abs(PulseCount - commandPosition));
   move2Backward();
  }
  else {
    motorOff();
    motor2Off();
   if (complete == false) {
      Serial.println("OK");
      //delay(1000);
    }
    complete=true;
   }


if (serial_debug) {
  

  if(PulseCount > -1){
    Serial.print(" ");
  }

  if(PulseCount < 10 && PulseCount > -10){
    Serial.print(" ");
  }

  if(PulseCount < 100 && PulseCount > -100){
    Serial.print(" ");
  }



  Serial.print(PulseCount);


  
  if(sensor01 == 1){
    Serial.print("+");
  }
  else{
    Serial.print("-");
  }




  if(sensor02 == 1){
    Serial.print("+");
  }
  else{
    Serial.print("-");
  }
 


      if (PulseCount < commandPosition) {
       Serial.print(">");
      }
      else if (PulseCount > commandPosition)  {
        Serial.print("<");
       
      }
      else {
      Serial.print("|");
   
      
      }
      Serial.print(loopCount);
      Serial.println("");

}

loopCount++;

}
