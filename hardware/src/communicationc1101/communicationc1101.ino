#include <ELECHOUSE_CC1101_SRC_DRV.h>

// Wir bleiben bei deinen erfolgreichen Pins
#define SCK_PIN 18
#define MISO_PIN 19
#define MOSI_PIN 23
#define CSN_PIN 5

void setup() {
    Serial.begin(115200);
    delay(2000);
    Serial.println("Starte CC1101 mit SmartRC Library...");

    // Wir erzwingen die funktionierenden Pins
    ELECHOUSE_cc1101.setSpiPin(SCK_PIN, MISO_PIN, MOSI_PIN, CSN_PIN);

    if (ELECHOUSE_cc1101.getCC1101()){ 
        Serial.println(">>> CC1101 ERFOLGREICH GEFUNDEN!");
        
        ELECHOUSE_cc1101.Init();
        ELECHOUSE_CC1101.setModulation(2);           
        ELECHOUSE_cc1101.setMHZ(433.92);   // Oder 868.3, je nach Modul
        ELECHOUSE_cc1101.SetRx();
        Serial.println("Konfiguration abgeschlossen.");
    } else {
        Serial.println("FEHLER: Library erkennt Modul noch nicht.");
    }
}

void loop() {
    Serial.println("Empfang aktiv...");
    ELECHOUSE_cc1101.SetRx(); // SetRx() ist der gängigste Befehl für Empfang
    delay(1000);

    Serial.println("Standby...");
    ELECHOUSE_cc1101.setSidle(); // Versetzt den Chip in den Leerlauf
    delay(1000);
}