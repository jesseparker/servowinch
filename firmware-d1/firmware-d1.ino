#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>

#define serial_debug true
#define baud 115200

#define SENSOR_A D6
#define SENSOR_B D7

#define motorEnable D1
#define motorPlus D2
#define motorMinus D3


#define spd3 1024/2.5
#define spd2 1024/1.8
#define spd1 1024

#define spd1d 4 
#define spd2d 2


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
char position[20];


const char* host = "wemos";
const char* ssid = "souther";
const char* password = "";

ESP8266WebServer server(80);
const char* serverIndex = "<html>"
"<head>"
"<style>"
"input {font-size: 100pt}"
"</style>"
"<script>"
"function getPositionUpdate() {"
"    var xmlhttp = new XMLHttpRequest();"
""
"    xmlhttp.onreadystatechange = function() {"
"        if (xmlhttp.readyState == XMLHttpRequest.DONE) {"
"           if (xmlhttp.status == 200) {"
"               document.getElementById('pos').innerHTML = xmlhttp.responseText;"
"           }"
"        }"
"    };"
""
"    xmlhttp.open('GET', '/position', true);"
"    xmlhttp.send();"
"    setTimeout(function() {getPositionUpdate()}, 500);"
"}"
"function setPosition() {"
"    var xmlhttp = new XMLHttpRequest();"
""
"    xmlhttp.onreadystatechange = function() {"
"        if (xmlhttp.readyState == XMLHttpRequest.DONE) {"
"           if (xmlhttp.status == 200) {"
"               document.getElementById('com').innerHTML = xmlhttp.responseText;"
"           }"
"        }"
"    };"
""
"    xmlhttp.open('POST', '/setPosition', true);"
"    xmlhttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');"
"    xmlhttp.send('position='+document.getElementById('position').value);"
"    document.getElementById('position').select();"
"}"
"setTimeout(function() {getPositionUpdate()}, 500);"
"</script>"
"</head>"
"<body onload='document.getElementById(\"position\").focus();'>"
"<h1>Servo Position</h1>"
"<p>Position <span id='pos'>unknown</span> Command <span id='com'>unknown</span></p>"
"<form action='#' method='post' onsubmit='setPosition(); return false;'>"
"<input type='number' inputmode='numeric' pattern='[0-9]*' type='text' id='position' name='position' value='0' size='4' onfocus='this.select();'>"
"<input type='button' onclick='setPosition(); return false;' value='set'>"
"</form>"
"</body>"
"</html>";


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

void motorOff() {
  analogWrite(motorEnable, 0);
  digitalWrite(motorPlus, LOW);
  digitalWrite(motorMinus, LOW);
}

void setup() {
  
  Serial.begin(baud);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  pinMode(SENSOR_A, INPUT);
  pinMode(SENSOR_B, INPUT);
  pinMode(motorEnable, OUTPUT);
  pinMode(motorPlus, OUTPUT);
  pinMode(motorMinus, OUTPUT);

  motorOff();

  PulseCount = 0;
  complete = true;
  count = 0;
  count2 = 0;


  WiFi.mode(WIFI_AP_STA);
  WiFi.begin(ssid, password);
  if(WiFi.waitForConnectResult() == WL_CONNECTED){
    MDNS.begin(host);
    server.on("/", HTTP_GET, [](){
      server.sendHeader("Connection", "close");
      server.send(200, "text/html", serverIndex);
    });
    
    server.on("/set", HTTP_POST, [](){

  if (server.hasArg("position")) {
    server.arg("position").toCharArray(position, 20);
    
    commandPosition = atoi(position);
  }
      
      server.sendHeader("Connection", "close");
      server.send(200, "text/html", serverIndex);
    });
   server.on("/position", HTTP_GET, [](){

      
      server.sendHeader("Connection", "close");
      server.send(200, "text/html", String(PulseCount));
    });

   server.on("/setPosition", HTTP_POST, [](){

   if (server.hasArg("position")) {
    server.arg("position").toCharArray(position, 20);
    
    commandPosition = atoi(position);
  }     
      server.sendHeader("Connection", "close");
      server.send(200, "text/html", String(commandPosition));
    });

    server.begin();
    MDNS.addService("http", "tcp", 80);

    Serial.printf("Ready! Open http://%s.local in your browser\n", host);
  } else {
    Serial.println("WiFi Failed");
  }


}

void loop() {

  server.handleClient();

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


  if (sensor01 == 1 && sensor02 == 1) {
    step = 0;
    if (stepOld == 1) {
      PulseCount--;
    }
    if (stepOld == 3) {
      PulseCount++;
    }
    stepOld = 0;
  }

  else if (sensor01 == 0 && sensor02 == 1) {
    step = 1;
    if (stepOld == 2) {
      PulseCount--;
    }
    if (stepOld == 0) {
      PulseCount++;
    }
    stepOld = 1;
  }

  else if (sensor01 == 0 && sensor02 == 0) {
    step = 2;
    if (stepOld == 3) {
      PulseCount--;
    }
    if (stepOld == 1) {
      PulseCount++;
    }
    stepOld = 2;
  }

  else if (sensor01 == 1 && sensor02 == 0) {
    step = 3;
    if (stepOld == 0) {
      PulseCount--;
    }
    if (stepOld == 2) {
      PulseCount++;
    }
    stepOld = 3;
  }


  if (PulseCount < commandPosition) {
    // CCW
    moveForward(abs(PulseCount - commandPosition));
    //  move2Forward();
  }
  else if (PulseCount > commandPosition)  {
    // CW
    moveBackward(abs(PulseCount - commandPosition));
    //   move2Backward();
  }
  else {
    motorOff();
    //    motor2Off();
    if (complete == false) {
      Serial.println("OK");
      //delay(1000);
    }
    complete = true;
  }


  if (serial_debug) {


    if (PulseCount > -1) {
      Serial.print(" ");
    }

    if (PulseCount < 10 && PulseCount > -10) {
      Serial.print(" ");
    }

    if (PulseCount < 100 && PulseCount > -100) {
      Serial.print(" ");
    }



    Serial.print(PulseCount);



    if (sensor01 == 1) {
      Serial.print("+");
    }
    else {
      Serial.print("-");
    }




    if (sensor02 == 1) {
      Serial.print("+");
    }
    else {
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
