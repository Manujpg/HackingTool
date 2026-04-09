#include <ELECHOUSE_CC1101_SRC_DRV.h>

// --- EINSTELLUNGEN ---
float startFreq = 868.0;   // Startfrequenz (oder 433.0)
float endFreq = 868.6;     // Endfrequenz (oder 434.5)
float scanStep = 0.02;     // Schrittweite in MHz (sehr fein)
int threshold = -60;       // Signalschwelle: Alles was "stärker" (näher an 0) als -60 ist
// ---------------------

void setup() {
  Serial.begin(115200);
  ELECHOUSE_cc1101.setSpiPin(18, 19, 23, 5);
  
  if (!ELECHOUSE_cc1101.getCC1101()) {
    Serial.println("Fehler: CC1101 nicht gefunden!");
    while(1);
  }

  ELECHOUSE_cc1101.Init();
  ELECHOUSE_cc1101.setRxBW(58); // Schmale Bandbreite für präzises Finden
  Serial.println("Scanner gestartet. Drücke jetzt die Fernbedienung...");
}

void loop() {
  for (float f = startFreq; f <= endFreq; f += scanStep) {
    ELECHOUSE_cc1101.setMHZ(f);
    ELECHOUSE_cc1101.SetRx();
    
    // Kurz warten, damit der Chip die Energie messen kann
    delay(5); 
    
    int rssi = ELECHOUSE_cc1101.getRssi();

    // Wenn ein starkes Signal erkannt wird:
    if (rssi > threshold) {
      Serial.print("!!! SIGNAL GEFUNDEN !!!");
      Serial.print(" Frequenz: ");
      Serial.print(f, 2);
      Serial.print(" MHz | Stärke: ");
      Serial.print(rssi);
      Serial.println(" dBm");

      // Bleibe kurz hier stehen, um sicherzugehen
      unsigned long detectTime = millis();
      while(millis() - detectTime < 1000) {
         // Wir bleiben 1 Sekunde auf dieser Frequenz stehen
      }
    }
  }
  
  // Kleiner Punkt als Lebenszeichen im Scan
  Serial.print("."); 
}