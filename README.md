# DigiSave
DigiSave is a modern savings solution that combines the convenience of a mobile app with an innovative hardware device, offering users a way to manage savings. With DigiSave, users can set financial goals, create multiple savings pockets, and deposit money daily with precision. The system ensures data integrity using ```ESP32``` for connectivity and ```Firebase``` for secure data storage. Additionally, the DigiSave app built with ```C++```, ```Dart```, ```Kotlin```, ```Java``` and ```Swift``` with ```Flutter framework``` provides real-time updates, making savings management intuitive and efficient and.

## Features
### 1. Multi-Pocket Savings
* Users can create different savings pockets for individual goals (e.g., “```Holiday Fund```,” “```Emergency Savings```, ```Holiday Savings```”).
* Each pocket has a target amount to track progress visually in the app and on the LCD display.

### 2. Daily Savings Management with Target Goals
* Users can set daily deposit goals using the hardware device and assign how much they plan to save each day.
* Real-time tracking of savings ensures progress toward achieving personal financial goals.

### 3. Mobile App Integration (Flutter App)
 ####  The DigiSave app provides a sleek and interactive user interface to:

*  View pocket balances and savings history.
* Track contributions in real time.
* Manage personal accounts using User ID or Card ID.
#### Users get notifications about transactions and savings milestones.

### 4. Secure Transactions with ESP32 & Firebase
* ESP32 microcontroller handles all Wi-Fi-enabled transactions, sending real-time data to Firebase for secure storage and user authentication.

* Every deposit is linked to a unique User ID or Card ID, ensuring accurate tracking of who made the contribution.

### 5. Hardware Components for User Input & Interaction
* ```LCD Display```: Provides visual feedback, showing the amount deposited and savings progress for each pocket.
Keypad Input: Users enter deposit amounts manually.
* ```Potentiometer```: Adjust values or navigate through pocket options and settings.
* ```LED Indicators```: Show the status of transactions (e.g., Green for success, Red for error).






## PlatformIO Extension in VS Code
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