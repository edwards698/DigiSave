#include <Arduino.h>
#include <WiFi.h>

const char* ssid = "Mr.Boring";
const char* password = "##ONETWOTHREE45678";

void setup() {
  Serial.begin(9600);  
  WiFi.begin(ssid, password);
   Serial.println("Connecting to " + String(ssid));

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to " + String(ssid));
  Serial.println(WiFi.localIP());
}

void loop() {
  // Send data to Arduino over serial
  Serial.println(ssid);
  delay(1000);
}
