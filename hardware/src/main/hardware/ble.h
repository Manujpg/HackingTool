#ifndef BLE_H
#define BLE_H

#include <Arduino.h>

void bleSetup();
void bleLoop();

bool bleIsConnected();
bool bleHasNewMessage();
String bleGetLastReceived();
void bleClearLastReceived();

void bleSendString(const String& msg);

#endif