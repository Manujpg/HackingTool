#include <ELECHOUSE_CC1101_SRC_DRV.h>
#include "ble.h"

// Define Ports
#define MOSI 23
#define MISO 19
#define CLK 18
#define SS 5
#define GDO0_PIN 2
#define GDO2_PIN 4

//Modes for loop
enum Mode { JAMMING,
            SCAN_SIGNAL,
            SCAN_FREQUENZ };

// default Settings
#define MODE_DEFAULT SCAN_SIGNAL
#define SCAN_FREQ_THRESHOLD_DEFAULT -65
#define SCAN_FREQ_STEPS_DEFAULT 0.02

//initale Mode
Mode currentMode = MODE_DEFAULT;

// Variables for ISR
volatile unsigned long lastChangeTime = 0;
volatile unsigned long highDuration = 0;
volatile unsigned long lowDuration = 0;
volatile bool newPair = false;

//loop variables
bool lastBleConnected = false;
unsigned long lastBleTestSendMs = 0;
unsigned long bleTestCounter = 0;



//Variables for Mode SCAN_FREQUENZ
float scanFreqBegin;
float scanFreqEnd;
float scanFreqStep;
int scanFreqThreshold = SCAN_FREQ_THRESHOLD_DEFAULT;
float scanFreqCurrent = 0;
unsigned long scanFreqStepMsLast = 0;
unsigned long scanFreqMsWaitOn = 0;

// init functions
void init_cc1101() {
  ELECHOUSE_cc1101.setSpiPin(CLK, MISO, MOSI, SS);
  if (ELECHOUSE_cc1101.getCC1101()) {
    sendData("Info: Mit cc1101 verbunden");
    ELECHOUSE_cc1101.Init();
    ELECHOUSE_cc1101.setMHZ(868.30);
    ELECHOUSE_cc1101.setModulation(0);
    ELECHOUSE_cc1101.setRxBW(812.50);  // Bandbreite etwas verengen für weniger Rauschen
    enable_cc1101_isr();

    ELECHOUSE_cc1101.SpiWriteReg(CC1101_IOCFG0, 0x0D);
    ELECHOUSE_cc1101.SetRx();

    // pinMode(GDO0_PIN, INPUT);
  } else {
    sendData("Error: cc1101 nicht gefunden");
  }
}

// ISR

void ISR_GDO(void) {
  unsigned long now = micros();
  unsigned long duration = now - lastChangeTime;

  if (digitalRead(GDO0_PIN) == LOW) {
    //change from high of low
    highDuration = duration;
  } else {
    //change from low of high
    lowDuration = duration;
    newPair = true;  // new pair with (High, Low)
  }
  lastChangeTime = now;
}

// Help functions
void sendData(String d) {
  Serial.println(d);
  if (bleIsConnected()) {
    bleSendString(d);
  }
}

void enable_cc1101_isr() {
  ELECHOUSE_cc1101.SpiWriteReg(CC1101_IOCFG0, 0x0D);
  pinMode(GDO0_PIN, INPUT);
  attachInterrupt(digitalPinToInterrupt(GDO0_PIN), ISR_GDO, CHANGE);
  // ELECHOUSE_cc1101.SpiWriteReg(CC1101_IOCFG0, 0x0D);
}

void disable_cc1101_isr() {
  detachInterrupt(digitalPinToInterrupt(GDO0_PIN));
  // ELECHOUSE_cc1101.SpiWriteReg(CC1101_IOCFG0, 0x0D);
}


void startJamming() {
  // 1. Interrupts und Empfang stoppen
  disable_cc1101_isr();
  ELECHOUSE_cc1101.setSidle(); // Idle Modus
  yield();

  // 2. CC1101 für konstanten Träger konfigurieren
  // Wir schalten die Modulation aus (einfacher Träger)
  ELECHOUSE_cc1101.setModulation(4); // 4 = CLEAN CWI (Continuous Wave)
  
  // PA_TABLE Einstellungen: Maximale Sendeleistung einstellen
  // (0xC0 ist oft das Maximum für CC1101)
  ELECHOUSE_cc1101.SpiWriteReg(CC1101_FREND0, 0x10); 

  // 3. Den Chip in den Sende-Modus (TX) versetzen
  ELECHOUSE_cc1101.SetTx();

  currentMode = JAMMING;
  sendData("Info: Konstantes Jamming gestartet (Hardware-Mode)");
}

void stopJamming() {
  ELECHOUSE_cc1101.setSidle();
  
  // Zurück auf Standard-Werte für Empfang
  ELECHOUSE_cc1101.setModulation(0); // Wieder zurück auf ASK/OOK oder was du nutzt
  
  delay(10);
  ELECHOUSE_cc1101.SetRx();
  enable_cc1101_isr();
  
  currentMode = MODE_DEFAULT;
  sendData("Info: Jamming gestoppt");
}

void startFreuquenzScanning(float pStartFreq, float pEndFreq, float pScanStep = SCAN_FREQ_STEPS_DEFAULT, int pThreshold = SCAN_FREQ_THRESHOLD_DEFAULT) {
  currentMode = SCAN_FREQUENZ;
  scanFreqBegin = pStartFreq;
  scanFreqEnd = pEndFreq;
  scanFreqStep = pScanStep;
  scanFreqThreshold = pThreshold;
  scanFreqCurrent = pStartFreq;
  disable_cc1101_isr();
}

void stopFreuquenzScanning() {
  currentMode = MODE_DEFAULT;
  enable_cc1101_isr();
}

void loopFrequenzScanning() {
  // Wenn wir gerade in einer "Wartepause" nach einem Fund sind
  if (millis() < scanFreqMsWaitOn) return;

  // Initialisiere currentScanFreq beim ersten Start
  if (scanFreqCurrent < scanFreqBegin) scanFreqCurrent = scanFreqBegin;

  ELECHOUSE_cc1101.setMHZ(scanFreqCurrent);
  ELECHOUSE_cc1101.SetRx();

  // Dem Chip Zeit zum Einschwingen geben (sehr kurz)
  delayMicroseconds(500);

  int rssi = ELECHOUSE_cc1101.getRssi();

  if (rssi > scanFreqThreshold) {
    sendData("findNewSignal: Frequenz: " + String(scanFreqCurrent) + " MHz | RSSI: " + String(rssi));
    scanFreqMsWaitOn = millis() + 1000;
  }

  // Nächster Schritt
  scanFreqCurrent += scanFreqStep;
  if (scanFreqCurrent > scanFreqEnd) {
    scanFreqCurrent = scanFreqBegin;
    sendData(".");  // Lebenszeichen nach einem vollen Durchlauf
  }
}

String getParam(String data, char separator, int index) {
  int found = 0;
  int strIndex[] = {0, -1};
  int maxIndex = data.length() - 1;
  for (int i = 0; i <= maxIndex && found <= index; i++) {
    if (data.charAt(i) == separator || i == maxIndex) {
      found++;
      strIndex[0] = strIndex[1] + 1;
      strIndex[1] = (i == maxIndex) ? i + 1 : i;
    }
  }
  return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
}


void handleGetData(String message) {
  message.trim();  //Remove spaces/wrapping
  if (message.length() == 0) return;

  int equalsPos = message.indexOf("=");

  if (equalsPos > 1) {
    String command = message.substring(0, equalsPos);
    String valueStr = message.substring(equalsPos + 1);

    // Werte vorparsen (hilft bei der Verwendung)
    float valueFloat = valueStr.toFloat();
    int valueInt = valueStr.toInt();
    bool valueBool = (valueStr == "1" || valueStr.equalsIgnoreCase("true"));

    if (command == "setFrequenz") {
      ELECHOUSE_cc1101.setMHZ(valueFloat);
      ELECHOUSE_cc1101.SetRx();
      sendData("Info:Frequenz geändert auf " + String(valueFloat));
    } else if (command == "setModulation") {
      ELECHOUSE_cc1101.setModulation((byte)valueFloat);
      ELECHOUSE_cc1101.SetRx();
      sendData("Info:Modulation geändert auf " + String(valueFloat));
    } else if (command == "setRxBW") {
      ELECHOUSE_cc1101.setRxBW(valueFloat);
      ELECHOUSE_cc1101.SetRx();
      sendData("Info:RxBW geändert auf " + String(valueFloat));
    } else if (command == "displayText") {
      // Zeigt einfach den Text an, den man ab dem '=' mitgeschickt hat
      Serial.println("DisplayText:" + valueStr);
    } else {
      sendData("Error:Befehl nicht erkannt " + message);
      return;
    }
  } else {
    if (message == "startJamming") {
      startJamming();
      sendData("Info: Start Jamming");
    } else if (message == "stopJamming") {
      stopJamming();
      sendData("Info: Stop Jamming");
    } else if (message.startsWith("startScanningFrequenz")) {
      // Extrahiere den Teil zwischen den Klammern
      int startBracket = message.indexOf('(');
      int endBracket = message.lastIndexOf(')');

      if (startBracket != -1 && endBracket != -1) {
        String params = message.substring(startBracket + 1, endBracket);

        // Nutze die getParam Hilfsfunktion (siehe unten)
        float pStart = getParam(params, ',', 0).toFloat();
        float pEnd = getParam(params, ',', 1).toFloat();
        float pStep = getParam(params, ',', 2).toFloat();

        if (pStart > 0 && pEnd > pStart) {
          startFreuquenzScanning(pStart, pEnd, pStep);
          sendData("Info: Scan gestartet (" + String(pStart) + "-" + String(pEnd) + " MHz)");
        }
      }
    } else if (message == "stopScanningFrequenz") {    
      stopFreuquenzScanning();
    } else if (message == "getMode") {    
      sendData("Mode: " + String(currentMode));
    } else {
      sendData("Error:Befehl nicht erkannt ");
      return;
    }
  }
}


void setup() {
  Serial.begin(115200);
  init_cc1101();
  bleSetup();
  //start with initial Mode
  currentMode = MODE_DEFAULT;
}

void loop() {

  switch (currentMode) {
    case SCAN_FREQUENZ:
      loopFrequenzScanning();
      break;
  }


  // bleLoop();

  // bool currentBleConnected = bleIsConnected();
  // if (currentBleConnected && !lastBleConnected) {
  //   sendData("Info: BLE verbunden");
  // } else if (!currentBleConnected && lastBleConnected) {
  //   Serial.println("Info: BLE getrennt");
  // }
  // lastBleConnected = currentBleConnected;

  // if (currentBleConnected && millis() - lastBleTestSendMs >= 15000) {
  //   lastBleTestSendMs = millis();
  //   sendData("BLE_TEST:" + String(bleTestCounter++));
  // }


  // helpfunction ISR
  if (newPair) {
    newPair = false;

    // Filtern von Rauschen (nur Pulse > 100µs anzeigen)
    if (highDuration > 350 && lowDuration > 350) {
      String message = "newSignal: ";
      message += highDuration;
      message += ",";
      message += lowDuration;
      message += " ";

      sendData(message);
    }
  }

  // if new Message is avialable
  if (bleHasNewMessage()) {
    String bleMessage = bleGetLastReceived();
    bleClearLastReceived();
    handleGetData(bleMessage);
  }

  if (Serial.available()) {
    String message = Serial.readStringUntil('\n');
    handleGetData(message);
  }
}