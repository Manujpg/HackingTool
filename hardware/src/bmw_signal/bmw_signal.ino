#include <ELECHOUSE_CC1101_SRC_DRV.h>

#define GDO0_PIN 4  // Das Kabel von GDO0 zu GPIO 4

void setup() {
    Serial.begin(115200);
    ELECHOUSE_cc1101.setSpiPin(18, 19, 23, 5);

    if (ELECHOUSE_cc1101.getCC1101()){
        Serial.println("CC1101 Hardware OK. Starte RAW-Modus...");
        ELECHOUSE_cc1101.Init();
        ELECHOUSE_cc1101.setMHZ(433);
        ELECHOUSE_cc1101.setModulation(0); // FSK für BMW
        
        // WICHTIG: Setze GDO0 auf asynchronen Output
        // Dies leitet das rohe Funksignal direkt an den Pin weiter
        ELECHOUSE_cc1101.SpiWriteReg(0x02, 0x0D); 
        
        ELECHOUSE_cc1101.SetRx();
        pinMode(GDO0_PIN, INPUT);
        Serial.println("Höre auf GPIO 4... Drück den Schlüssel!");
    }
}

void loop() {
    // Wir messen die Länge eines HIGH-Signals am Pin
    unsigned long duration = pulseIn(GDO0_PIN, HIGH, 100000); // 100ms Timeout
    
    if (duration > 0) {
        // Wenn ein Puls kommt, zeichnen wir ihn kurz im Monitor
        Serial.print(duration);
        Serial.print(" ");
        
        // Wenn sehr viele Pulse kommen, machen wir eine neue Zeile
        static int count = 0;
        if (++count > 20) {
            Serial.println();
            count = 0;
        }
    }
}