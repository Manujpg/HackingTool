#include "ble.h"
#include <NimBLEDevice.h>

// Eigene UUIDs
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_RX   "beb5483e-36e1-4688-b7f5-ea07361b26a8" // <--- Hier fehlte die '1' in '36e1'
#define CHARACTERISTIC_TX   "e3223119-9445-4e96-a4a1-85358c4046a2"

static NimBLEServer* pServer = nullptr;
static NimBLEAdvertising* pAdvertising = nullptr;
static NimBLECharacteristic* pTxCharacteristic = nullptr;
static NimBLECharacteristic* pRxCharacteristic = nullptr;

static bool deviceConnected = false;
static bool oldDeviceConnected = false;
static unsigned long lastAdvertisingCheckMs = 0;

static String lastReceivedMessage = "";
static bool newMessageAvailable = false;

class ServerCallbacks : public NimBLEServerCallbacks {
    void onConnect(NimBLEServer* pServer, NimBLEConnInfo& connInfo) override {
        (void)pServer;
        (void)connInfo;
        deviceConnected = true;
        Serial.println("BLE: Smartphone verbunden");
    }

    void onDisconnect(NimBLEServer* pServer, NimBLEConnInfo& connInfo, int reason) override {
        (void)pServer;
        (void)connInfo;
        (void)reason;
        deviceConnected = false;
        Serial.println("BLE: Smartphone getrennt");
    }
};

class RxCallbacks : public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic* pCharacteristic, NimBLEConnInfo& connInfo) override {
        (void)connInfo;
        std::string value = pCharacteristic->getValue();

        if (!value.empty()) {
            lastReceivedMessage = String(value.c_str());
            newMessageAvailable = true;

            Serial.print("BLE empfangen: ");
            Serial.println(lastReceivedMessage);
        }
    }
};

void bleSetup() {
    NimBLEDevice::init("ESP32_BLE_Device");

    pServer = NimBLEDevice::createServer();
    pServer->setCallbacks(new ServerCallbacks());

    NimBLEService* pService = pServer->createService(SERVICE_UUID);

    // TX: ESP32 -> Smartphone
    pTxCharacteristic = pService->createCharacteristic(
        CHARACTERISTIC_TX,
        NIMBLE_PROPERTY::READ |
        NIMBLE_PROPERTY::NOTIFY
    );

    // RX: Smartphone -> ESP32
    pRxCharacteristic = pService->createCharacteristic(
        CHARACTERISTIC_RX,
        NIMBLE_PROPERTY::WRITE |
        NIMBLE_PROPERTY::WRITE_NR
    );

    pRxCharacteristic->setCallbacks(new RxCallbacks());

    pService->start();

    pAdvertising = NimBLEDevice::getAdvertising();
    pAdvertising->setName("ESP32_BLE_Device");
    pAdvertising->enableScanResponse(true);
    pAdvertising->addServiceUUID(SERVICE_UUID);
    bool started = pAdvertising->start();

    if (started) {
        Serial.println("BLE gestartet, warte auf Verbindung...");
    } else {
        Serial.println("BLE Fehler: Advertising konnte nicht gestartet werden");
    }
}

void bleLoop() {
    if (!deviceConnected && pAdvertising != nullptr && millis() - lastAdvertisingCheckMs >= 3000) {
        lastAdvertisingCheckMs = millis();
        if (!pAdvertising->isAdvertising()) {
            bool restarted = pAdvertising->start();
            if (restarted) {
                Serial.println("BLE Werbung periodisch neu gestartet");
            } else {
                Serial.println("BLE Warnung: Werbung konnte nicht neu gestartet werden");
            }
        }
    }

    if (!deviceConnected && oldDeviceConnected) {
        delay(200);
        NimBLEDevice::startAdvertising();
        Serial.println("BLE Werbung neu gestartet");
        oldDeviceConnected = deviceConnected;
    }

    if (deviceConnected && !oldDeviceConnected) {
        oldDeviceConnected = deviceConnected;
    }
}

bool bleIsConnected() {
    return deviceConnected;
}

bool bleHasNewMessage() {
    return newMessageAvailable;
}

String bleGetLastReceived() {
    return lastReceivedMessage;
}

void bleClearLastReceived() {
    lastReceivedMessage = "";
    newMessageAvailable = false;
}

void bleSendString(const String& msg) {
    if (deviceConnected && pTxCharacteristic != nullptr) {
        pTxCharacteristic->setValue(msg.c_str());
        pTxCharacteristic->notify();

        Serial.print("BLE gesendet: ");
        Serial.println(msg);
    }
}