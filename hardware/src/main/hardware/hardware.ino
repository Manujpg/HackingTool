#include <ELECHOUSE_CC1101_SRC_DRV.h>
#include "ble.h"

// Define Ports
#define MOSI 23
#define MISO 19
#define CLK 18
#define SS 5
#define GDO0_PIN 2
#define GDO2_PIN 4

// Variables for ISR
volatile unsigned long lastChangeTime = 0;
volatile unsigned long highDuration = 0;
volatile unsigned long lowDuration = 0;
volatile bool newPair = false;

//loop variables
bool jammingActive = false;
bool lastBleConnected = false;
unsigned long lastBleTestSendMs = 0;
unsigned long bleTestCounter = 0;


// init functions
void init_cc1101() {
  ELECHOUSE_cc1101.setSpiPin(CLK, MISO, MOSI, SS);
  if (ELECHOUSE_cc1101.getCC1101()) {
    sendData("Info: Mit cc1101 verbunden");
    ELECHOUSE_cc1101.Init();
    ELECHOUSE_cc1101.setMHZ(868.30);
    ELECHOUSE_cc1101.setModulation(0);
    ELECHOUSE_cc1101.setRxBW(812.50);       // Bandbreite etwas verengen für weniger Rauschen
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

// void startJamming() {
//   disable_cc1101_isr();
//   ELECHOUSE_cc1101.setSidle(); // Erstmal in den Idle-Modus

//   // 1. Modulation auf ASK/OOK und Asynchron setzen
//   // MDMCFG2: 0x30 bedeutet ASK/OOK, kein Manchester, kein Sync-Wort
//   ELECHOUSE_cc1101.SpiWriteReg(CC1101_MDMCFG2, 0x30); 
  
//   // 2. GDO0 als EINGANG für den CC1101 konfigurieren (Modus 0x0D im TX-Fall)
//   // Im asynchronen TX-Modus fungiert GDO0 als Dateneingang
//   ELECHOUSE_cc1101.SpiWriteReg(CC1101_IOCFG0, 0x0D); 

//   // 3. ESP32 Pin auf Output und HIGH
//   pinMode(GDO0_PIN, OUTPUT);
//   digitalWrite(GDO0_PIN, HIGH);

//   // 4. Leistung und Senden aktivieren
//   ELECHOUSE_cc1101.SpiWriteReg(CC1101_PATABLE, 0xC0); 
//   ELECHOUSE_cc1101.SetTx();
  
//   sendData("Info: Jamming aktiv (Carrier on)");
// }

// void startJamming() {
//   disable_cc1101_isr();
//   ELECHOUSE_cc1101.setSidle();
  
//   // Wichtig: Den Pin für den ESP32 als Ausgang beanspruchen
//   pinMode(GDO0_PIN, OUTPUT); 
  
//   jammingActive = true;
//   sendData("Info: Jamming gestartet - Loop aktiv");
// }

void startJamming() {
  // 1. Interrupt sauber trennen
  disable_cc1101_isr();
  yield();

  // 2. CC1101 in den richtigen Sende-Modus versetzen
  ELECHOUSE_cc1101.setSidle();
  ELECHOUSE_cc1101.setMHZ(868.32); // Deine gefundene Spitzenfrequenz
  
  // Wichtig: Asynchroner Modus (0x30 = ASK, kein Sync-Wort)
  ELECHOUSE_cc1101.SpiWriteReg(CC1101_MDMCFG2, 0x30); 
  // GDO0 als Dateneingang für den Sender konfigurieren
  ELECHOUSE_cc1101.SpiWriteReg(CC1101_IOCFG0, 0x0D); 

  // 3. Pin-Kontrolle übernehmen
  pinMode(GDO0_PIN, OUTPUT);
  
  // 4. DEN LOOP FREISCHALTEN
  jammingActive = true; 

  // 5. Senden physisch starten
  ELECHOUSE_cc1101.SetTx();
  
  sendData("Info: Jamming gestartet - LED MUSS JETZT BLINKEN");
}
void stopJamming() {
  jammingActive = false;
  ELECHOUSE_cc1101.setSidle();
  
  delay(10);
  ELECHOUSE_cc1101.SetRx();
  enable_cc1101_isr();
  sendData("Info: Jamming gestoppt");
}

// void stopJamming(){
//   digitalWrite(GDO0_PIN, LOW);

//   //go back to receive mode
//   ELECHOUSE_cc1101.setSidle();
//   ELECHOUSE_cc1101.SetRx();

//   delay(10);
//   enable_cc1101_isr();
// }


void handleGetData(String message) {
    message.trim(); //Remove spaces/wrapping
    if(message.length() == 0) return;

    int equalsPos = message.indexOf("=");

    if(equalsPos > 1){
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
      }else if(command == "setModulation") {
          ELECHOUSE_cc1101.setModulation((byte) valueFloat);
          ELECHOUSE_cc1101.SetRx();
          sendData("Info:Modulation geändert auf " + String(valueFloat));
      }else if(command == "setRxBW") {
          ELECHOUSE_cc1101.setRxBW(valueFloat);
          ELECHOUSE_cc1101.SetRx();
          sendData("Info:RxBW geändert auf " + String(valueFloat));
      }else if(command == "displayText") {
          // Zeigt einfach den Text an, den man ab dem '=' mitgeschickt hat
          Serial.println("DisplayText:" + valueStr);
      }else{
          sendData("Error:Befehl nicht erkannt " + message);
          return;
      }
    }else{
      if (message == "startJamming"){
        startJamming();
        sendData("Info: Start Jamming");
      }else if(message == "stopJamming")  {
        stopJamming();
        sendData("Info: Stop Jamming");
      }else{
        sendData("Error:Befehl nicht erkannt ");
        return;
      }
    }
    
}


void setup() {
  Serial.begin(115200);
  init_cc1101();

  // Nutzt die ble.h/ble.cpp Dateien im gleichen Ordner
  bleSetup();
}

void loop() {
  bleLoop();

  bool currentBleConnected = bleIsConnected();
  if (currentBleConnected && !lastBleConnected) {
    sendData("Info: BLE verbunden");
  } else if (!currentBleConnected && lastBleConnected) {
    Serial.println("Info: BLE getrennt");
  }
  lastBleConnected = currentBleConnected;

  if (currentBleConnected && millis() - lastBleTestSendMs >= 15000) {
    lastBleTestSendMs = millis();
    sendData("BLE_TEST:" + String(bleTestCounter++));
  }

  if (bleHasNewMessage()) {
    String bleMessage = bleGetLastReceived();
    bleClearLastReceived();
    handleGetData(bleMessage);
  }

  if (jammingActive) {
    // Einfaches, aggressives Flackern für die LED und den Funk
    digitalWrite(GDO0_PIN, HIGH);
    delayMicroseconds(500); 
    digitalWrite(GDO0_PIN, LOW);
    delayMicroseconds(500);

    // Diese zwei Zeilen sind KRITISCH, damit stopJamming funktioniert:
    yield();
  }

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
  if (Serial.available()) {
    String message = Serial.readStringUntil('\n');
    handleGetData(message);
  }
}