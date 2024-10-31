#include <Wire.h>
//include keypad library in the directory called lib
#include <SPI.h>
//include MFRC522 library in the directory called lib
#include <MFRC522.h>
//include Adafruit_GFX and Adafruit_SSD1306 library in the directory called lib
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
//include LiquidCrystal_I2C library in the directory called lib
#include <LiquidCrystal_I2C.h>
//include keypad library in the directory called lib
#include <Keypad.h>
//include wifi and HTTPClient library in the directory called lib
#include <WiFi.h>
#include <HTTPClient.h>

// RFID pins
#define SS_PIN 21
#define RST_PIN 22

// OLED configuration
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_ADDRESS 0x3C  // Default I2C address

// I2C pins for ESP32
#define I2C_SDA 2
#define I2C_SCL 15

// Keypad configuration
const byte ROWS = 4;
const byte COLS = 4;
char keys[ROWS][COLS] = {
  {'1', '2', '3', 'A'},
  {'4', '5', '6', 'B'},
  {'7', '8', '9', 'C'},
  {'*', '0', '#', 'D'}
};

byte rowPins[ROWS] = {13, 14, 27, 26};
byte colPins[COLS] = {25, 33, 32, 35};
Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);

// Create instances for RFID and OLED
MFRC522 rfid(SS_PIN, RST_PIN);
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

// Wi-Fi Credentials
const char* ssid = "Mr.Boring";
const char* password = "##ONETWOTHREE45678";

// Firebase Firestore project details
const String FIREBASE_HOST = "https://firestore.googleapis.com/v1/projects/update-a33ce/databases/(default)/documents";
const String API_KEY = "AIzaSyCnkDqjRK3RERg4RbOpGEY7JMDDTzqUHvw";
const String COLLECTION_PATH = "/test-collection";
const String DOCUMENT_ID = "test-document";

// Known card UIDs and associated names and codes
const byte knownUIDs[][4] = {
  {0x4, 0x9D, 0xBE, 0x2B},  // Edward
  {0xBD, 0x56, 0xC1, 0xBF}, // Obrey
  {0x1D, 0x59, 0xCB, 0xBF}  // Ceicilia
};
const char* userNames[] = {"Edward Phiri", "Obrey Muchena", "Ceicilia Phiri"};
const int secretCodes[] = {1234, 5678, 9101};
const int numKnownCards = 3;

void displayMessage(String message);
String getUIDString();
int getUserIndex();
bool validateCode(int userIndex);
void displayAccessStatus(bool granted);
void promptForAmount();
void sendDataToFirestore(String amount);
void reconnectWiFi();
int extractAmount(String jsonResponse);

void setup() {
  Serial.begin(9600);

  WiFi.begin(ssid, password);
  Serial.println("Connecting to " + String(ssid));
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to " + String(ssid));
  Serial.println("IP Address: " + WiFi.localIP().toString());

  SPI.begin();
  rfid.PCD_Init();
  Wire.begin(I2C_SDA, I2C_SCL);

  if (!display.begin(SSD1306_SWITCHCAPVCC, OLED_ADDRESS)) {
    Serial.println("OLED initialization failed!");
    while (true);
  }

  displayMessage("Scan a card...");
}

void loop() {
  if (!rfid.PICC_IsNewCardPresent() || !rfid.PICC_ReadCardSerial()) {
    delay(500);
    return;
  }

  String uidString = getUIDString();
  Serial.println("Card detected. UID: " + uidString);

  int userIndex = getUserIndex();
  if (userIndex != -1) {
    displayMessage("Hello " + String(userNames[userIndex]) + "\nEnter 4-digit code:");
    bool accessGranted = validateCode(userIndex);
    displayAccessStatus(accessGranted);

    if (accessGranted) {
      promptForAmount();
    }
  } else {
    displayMessage("Unknown card\nUID: " + uidString);
  }

  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();
  delay(1000);
}

void displayMessage(String message) {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 0);
  display.println(message);
  display.display();
}

String getUIDString() {
  String uidString = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    uidString += String(rfid.uid.uidByte[i], HEX);
    if (i < rfid.uid.size - 1) uidString += " ";
  }
  return uidString;
}

int getUserIndex() {
  for (int k = 0; k < numKnownCards; k++) {
    bool match = true;
    for (byte i = 0; i < rfid.uid.size; i++) {
      if (rfid.uid.uidByte[i] != knownUIDs[k][i]) {
        match = false;
        break;
      }
    }
    if (match) return k;
  }
  return -1;
}

bool validateCode(int userIndex) {
  String correctCode = String(secretCodes[userIndex]);
  String enteredCode = "";

  displayMessage("Enter 4-digit code:");
  while (enteredCode.length() < 4) {
    char key = keypad.getKey();
    if (key) {
      enteredCode += key;

      String maskedCode = "";
      for (int i = 0; i < enteredCode.length(); i++) {
        maskedCode += '*';
      }
      displayMessage("Code: " + maskedCode);
      delay(200);
    }
  }
  return enteredCode == correctCode;
}

void displayAccessStatus(bool granted) {
  if (granted) {
    displayMessage("Access Granted");
    delay(3000);
  } else {
    displayMessage("Access Denied");
    delay(2000);
  }
  displayMessage("Scan a card...");
}

void promptForAmount() {
  String amount = "";
  displayMessage("Enter amount ($):");

  while (true) {
    char key = keypad.getKey();
    if (key) {
      if (key == '#') {
        if (amount.isEmpty()) {
          displayMessage("Amount cannot be empty");
          delay(1000);
          displayMessage("Enter amount ($):");
          continue;
        }

        if (WiFi.status() == WL_CONNECTED) {
          sendDataToFirestore(amount);

          // Display success message after sending data
          displayMessage("Amount Banked\nSuccess!");
          delay(6000);
          displayMessage("Scan a card...");
        } else {
          reconnectWiFi();
        }
        return;
      } else if (isdigit(key)) {
        amount += key;
        displayMessage("Amount: $" + amount);
      }
    }
  }
}


void sendDataToFirestore(String amount) {
  HTTPClient http;
  String url = FIREBASE_HOST + COLLECTION_PATH + "/" + DOCUMENT_ID + "?key=" + API_KEY;

  http.begin(url);
  int getResponseCode = http.GET();
  if (getResponseCode > 0) {
    int currentAmount = extractAmount(http.getString());
    int newAmount = currentAmount + amount.toInt();

    String jsonPayload = "{ \"fields\": { \"message\": {\"stringValue\": \"ZMW: " + String(newAmount) + "\"} } }";

    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    int patchResponseCode = http.PATCH(jsonPayload);

    if (patchResponseCode > 0) {
      Serial.println("Update successful: " + http.getString());
    }
  }
  http.end();
}

int extractAmount(String jsonResponse) {
  int startIndex = jsonResponse.indexOf("\"ZMW: ") + 6;
  int endIndex = jsonResponse.indexOf("\"", startIndex);
  return jsonResponse.substring(startIndex, endIndex).toInt();
}

void reconnectWiFi() {
  WiFi.disconnect();
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) delay(500);
}
