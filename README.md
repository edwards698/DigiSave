# DigiSave
# *NOTE!*

<span style="color:red">

*This project is part of the [Tech Master Event](https://techmasterevent.com/) and is released as an open-source resource for the community. It is designed to foster collaborative learning, where participants can share their projects and benefit from each other's contributions. Through open access, The is to support the growth and exchange of innovative ideas, providing a platform for everyone to learn and improve together.*

**This project is not for commercial use or sale.*

</span>

#

DigiSave is a modern savings solution that combines the convenience of a mobile app with an innovative hardware device, offering users a way to manage savings. With DigiSave, users can set financial goals, create multiple savings pockets, and deposit money daily with precision. The system ensures data integrity using ```ESP32``` for connectivity and ```Firebase``` for secure data storage. Additionally, the DigiSave app built with ```C++```, ```Dart```, ```Kotlin```, ```Java``` and ```Swift``` with ```Flutter framework``` provides real-time updates, making savings management intuitive and efficient and.

# Development and Technology Stack for Dev
### 1. Hardware
| **Componet type**           | **Details**                           | **Source**                                         |
|-----------------------|---------------------------------------------|----------------------------------------------------|
| **ESP32**      | The module supports a data rate of up to 150 Mbps, and 20 dBm output power at the antenna to ensure the widest physical range.                        |  [Transfer Multisort Electronics](https://www.tme.eu)                                                         |
| **RFID**             | Radio-frequency identification               | [Transfer Multisort Electronics](https://www.tme.eu)   |
| **LCD Display 16x2**      | A 16×2 LCD display                            | [Transfer Multisort Electronics](https://www.tme.eu)                         |
| **PCB**           | A mechanically support and electrically connect electronic components using conductive pathways.      |[Transfer Multisort Electronics](https://www.tme.eu)              |
 

### ESP32 with RFID Component Connections

| **RFID**               | **ESP32**              | **Description**                           |
|------------------------|------------------------|-------------------------------------------|
| 3.3V                   | 3.3V                   | 3.3 Voltage Power Connection              |
| GND                    | GND                    | GND Power connection                      |
| RST                    | GPIO (D13)             | Pin Connection                            |
| Buzzer                 | Digital (e.g., D12)    | Pin Connection                            |
| Servo Motor            | PWM (e.g., D9)         | Pin Connection                            |
| Humidity Sensor        | Analog or Digital Pin  | Pin Connection                            |
| IR Receiver            | Digital (e.g., D2)     | Pin Connection                            |
| Push Button            | Digital (e.g., D4)     | Pin Connection                            |

### ESP32 with LCD Component Connections

| **LCD Display 16x2**   | **ESP32**              | **Description**                           |
|------------------------|------------------------|-------------------------------------------|
| GND                    | GND                    | Negative power connection                 |
| VCC                    | VCC                    | Postive power coneection                  |
| SCL                    | SCL GPIO(D2)           | Pin connection                            |
| SDA                    | SDA GPIO(D4)           | Pin connection                            |

### ESP32 with Keypad 4x4 Component Connections

| **Keypad 4x4**         | **ESP32**              | **Description**                           |
|------------------------|------------------------|-------------------------------------------|
| R1                     | GPIO(13)               | Pin Connection                            |
| R2                     | GPIO(14)               | Pin connection                            |
| R3                     | GPIO(27)               | Pin Connection                            |
| R4                     | GPIO(27)               | Pin Connection                            |
| C1                     | GPIO(26)               | Pin Connection                            |
| C2                     | GPIO(25)               | Pin Connection                            |
| C3                     | GPIO(33)               | Pin Connection                            |
| C4                     | GPIO(32)               | Pin Connection                            |

### Instructions for Use
* Arduino Pins: Adjust pin numbers based on your setup.
* Descriptions: Customize based on the specific function of each component in your project.
* Additional Components: Add any extra components used in your setup as needed.

## Environment Setup
### 1. Install PlatformIO
1. Open VS Code.
2. Go to the Extensions view by clicking the Extensions icon (or press Ctrl + Shift + X).
3. Search for "PlatformIO IDE".
4. Click Install on the PlatformIO IDE extension.

### 2. Install PlatformIO Core (CLI)
* Windows: PlatformIO is installed automatically with the VS Code extension.
* Linux/macOS: If not installed, you can install it manually by running

```bash
python3 -m pip install platformio
```
After installation, verify it by running:

```bash
pio --version
```
### 3. Create or Open a PlatformIO Project
#### 1. New Project:
* Click on PlatformIO: Home from the bottom status bar in VS Code.
* In the Home tab, click New Project.
* Select your board (e.g., Arduino Uno, ESP32, STM32).
* Choose a framework (e.g., Arduino, ESP-IDF).
Set a project location and click Finish.
#### 2.Open Existing Project:
* Use ```File > Open Folder...``` to open an existing PlatformIO project.
### 4. Project Structure
* ```platformio```.ini: Main configuration file where you define environments, platforms, and dependencies.
* ```src/```: Folder where your source code (main.cpp or .ino files) goes.
* ```lib/```: Store external libraries here.
* ```.pio/```: Temporary build files (automatically managed).
### 5. Building and Uploading Code
1. Open the Command Palette (Ctrl + Shift + P).
2. Search for PlatformIO: Build to compile your code.
3. Search for PlatformIO: Upload to upload code to your device.

You can also use the PlatformIO toolbar at the bottom to build, upload, or monitor serial output.
### 6. Monitor Serial Output
1. Connect your device to your computer.
2. Open Command Palette (Ctrl + Shift + P).
3. Search for PlatformIO: Serial Monitor.

Alternatively, add the following to ```platformio.ini``` to configure the serial monitor:
```ini
[env:my_board]
platform = espressif32
board = esp32dev
framework = arduino
monitor_speed = 115200 //in my case am using 9600

```

# Software
| **Type**           | **Details**                                 | **Source**                                |
|-----------------------|---------------------------------------------|----------------------------------------------------|
| **Flutter**      |Development kit                        |  [Flutter](https://flutter.dev)                                                         |
| **C/C++**             | Radio-frequency identification               | [SourceForge](https://sourceforge.net/projects/orwelldevcpp/)   |
| **Firebase**      | Backend solution                          | [Google Cloud console](https://cloud.google.com/)                         |

* You can access and download the files **[Embbedded System](https://github.com/edwards698/DigiSave/tree/main/Firmware)**
* You can access and download the files **[Android Application](https://github.com/edwards698/DigiSave/tree/main/Appication/digi)**
* Download of the APK **[Download](https://sourceforge.net/projects/orwelldevcpp/)**

# Features
### 1. Multi-Pocket Savings
##
* Users can create different savings pockets for individual goals (e.g., “```Holiday Fund```,” “```Emergency Savings```, ```Holiday Savings```”).
* Each pocket has a target amount to track progress visually in the app and on the LCD display.

### 2. Daily Savings Management with Target Goals
##
* Users can set daily deposit goals using the hardware device and assign how much they plan to save each day.
* Real-time tracking of savings ensures progress toward achieving personal financial goals.

### 3. Flexible Pocket Management
* Create multiple savings pockets for different goals and adjust contributions as needed.
* The potentiometer allows easy scrolling between savings pockets on the LCD display.

### 3. Mobile App Integration (Flutter App)
##
 ####  The DigiSave app provides a sleek and interactive user interface to:

*  View pocket balances and savings history.
* Track contributions in real time.
* Manage personal accounts using User ID or Card ID.
#### Users get notifications about transactions and savings milestones.

### 4. Secure Transactions with ESP32 & Firebase
##
* ESP32 microcontroller handles all Wi-Fi-enabled transactions, sending real-time data to Firebase for secure storage and user authentication.

* Every deposit is linked to a unique User ID or Card ID, ensuring accurate tracking of who made the contribution.

### 5. Hardware Components for User Input & Interaction
##
* ```LCD Display```: Provides visual feedback, showing the amount deposited and savings progress for each pocket.
Keypad Input: Users enter deposit amounts manually.
* ```Potentiometer```: Adjust values or navigate through pocket options and settings.
* ```LED Indicators```: Show the status of transactions (e.g., Green for success, Red for error).

##
### 6. Embedded Software & Hardware Development
* Developed using C++ and PlatformIO on VS Code for seamless hardware integration.
* PCB boards, power regulators, and jump wires ensure robust and reliable operation.
* Housed within a 3D-printed body chassis for a compact and aesthetically pleasing design.
## 
# Advantages of DigiSave
### 1. Convenient & Accessible:
* Manage savings from anywhere through the mobile app, with  instant feedback from the hardware device.
* Cardless deposits: Simply use your User ID or Card ID to contribute to the desired savings pocket.

### 2. Real-Time Data Syncing
* All transactions are instantly synced with Firebase,   ensuring data security and accessibility across devices.
* The mobile app provides real-time notifications on deposits, helping users stay on top of their savings goals.

### 3. Collaborative Savings
* Users can share pocket access or track group savings goals collaboratively using User IDs.
### 4. User-Friendly Hardware Interface
* The keypad and LCD display make interaction easy and intuitive, even for users unfamiliar with apps.
* LED indicators provide instant visual feedback, ensuring smooth and secure transactions

### 5. Eco-Friendly, Portable Design
* 3D-printed chassis makes the device lightweight and customizable.
* Portable, battery-powered operation allows users to deposit funds anytime, anywhere.
### 6. Secure & Reliable Data Management
* All deposits are authenticated through ESP32 and stored in Firebase, ensuring secure access and data integrity.
* Transactions are tracked by User ID or Card ID, minimizing the risk of errors.
##



