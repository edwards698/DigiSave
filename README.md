# DigiSave
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
* platformio.ini: Main configuration file where you define environments, platforms, and dependencies.
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