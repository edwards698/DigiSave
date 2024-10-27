#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h> // For HTTP requests

// Wi-Fi Credentials
const char* ssid = "Mr.Boring";
const char* password = "##ONETWOTHREE45678";

// Firebase Firestore project details
const String FIREBASE_HOST = "https://firestore.googleapis.com/v1/projects/update-a33ce/databases/(default)/documents";
const String API_KEY = "AIzaSyCnkDqjRK3RERg4RbOpGEY7JMDDTzqUHvw"; // Replace with your Firebase API key
const String COLLECTION_PATH = "/test-collection"; // Firestore collection path
const String DOCUMENT_ID = "test-document"; // Firestore document ID

// Function prototype declaration
void sendDataToFirestore();  

void setup() {
  // Start serial communication and connect to Wi-Fi
  Serial.begin(9600);
  WiFi.begin(ssid, password);
  Serial.println("Connecting to " + String(ssid));

  // Wait for Wi-Fi connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nConnected to " + String(ssid));
  Serial.println("IP Address: " + WiFi.localIP().toString()); // Print IP address
}

void loop() {
  // Check Wi-Fi status
  if (WiFi.status() == WL_CONNECTED) {
    sendDataToFirestore(); // Send data to Firestore
  } else {
    Serial.println("WiFi disconnected! Reconnecting...");
    WiFi.disconnect();
    delay(1000);
    WiFi.begin(ssid, password);
  }
  delay(5000); // Wait 5 seconds before sending the next request
}

// Definition of sendDataToFirestore function
void sendDataToFirestore() {
  HTTPClient http;  // Create an HTTP client object

  // Correct Firestore REST API URL for creating or updating a document
  String url = FIREBASE_HOST + COLLECTION_PATH + "/" + DOCUMENT_ID + "?key=" + API_KEY;
  Serial.println("Firestore URL: " + url);  // Log the URL for debugging

  http.begin(url);  // Initialize HTTP request

  // Set content type to JSON
  http.addHeader("Content-Type", "application/json");

  // JSON payload to send
  String jsonPayload = R"(
    {
      "fields": {
        "ssid": {"stringValue": "Mr.Boring"},
        "message": {"stringValue": "Hello from Arduino! and Edward"}
      }
    }
  )";
  Serial.println("Sending JSON Payload: " + jsonPayload);  // Log JSON for debugging

  // Send HTTP POST request
  int httpResponseCode = http.PATCH(jsonPayload); // Using PATCH to create or update document

  // Handle the response
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println("Response Code: " + String(httpResponseCode));
    Serial.println("Response: " + response);
  } else {
    Serial.println("Error sending PATCH request. Code: " + String(httpResponseCode));
  }

  // Close HTTP connection
  http.end();
}
