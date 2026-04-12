# 📡 ELECTRONIC WARFARE v1.0 – Sub-GHz Research Platform

<img width="1411" height="711" alt="image" src="https://github.com/user-attachments/assets/0a5667c2-4913-4d36-8717-791584edd7ca" />



> **An IoT research project developed during the 4th semester at DHBW Stuttgart.** > This project explores the security, analysis, and manipulation of Sub-GHz radio protocols (e.g., 433.92 MHz) using commercial off-the-shelf IoT hardware.

---

## ⚠️ Legal & Ethical Disclaimer
**FOR EDUCATIONAL AND RESEARCH PURPOSES ONLY.** This tool was developed exclusively as part of an academic IoT module at DHBW Stuttgart. The use of this hardware and software for unauthorized interference, intercepting third-party signals, or any illegal activities is strictly prohibited. The Core Development Unit assumes no liability for the misuse of this system.

---

## 🎯 Executive Summary
The "RF Attack Framework" is a portable hardware-software suite designed to analyze and interact with Sub-GHz radio protocols. It consists of an **ESP32-based Hardware Node** (paired with a CC1101 transceiver) and a **Mobile Control Node** (Flutter app) that acts as a tactical interface.

### Key Capabilities
* 🟢 **Signal Sniffing:** Real-time interception and logging of raw RF payloads.
* 🔵 **Replay Attacks:** Storage and targeted re-transmission of intercepted signals (e.g., for unsecured garage doors or remote-controlled sockets).
* 🔴 **Targeted Jamming:** Deliberate flooding of specific frequencies to demonstrate Denial-of-Service (DoS) vulnerabilities in standard IoT devices.
* 📱 **Tactical UI:** A responsive, brutalist-inspired mobile interface for seamless hardware control.

---

## ⚙️ System Architecture & Communication

The system is divided into two main components that communicate wirelessly:

1. **Hardware Node (ESP32 + CC1101)**
   * The **ESP32** serves as the central microcontroller.
   * The **CC1101 Transceiver** is connected to the ESP32 via **SPI (MOSI/MISO)** and handles the actual RF modulation and demodulation (TX/RX).
2. **Control Node (Mobile App)**
   * Built with **Flutter / Dart**.
   * Communication between the smartphone and the ESP32 is established via **Bluetooth Low Energy (BLE)**. Commands (such as frequency tuning or jamming triggers) are transmitted in real-time.

---

## 🛠️ Hardware Requirements
To replicate this node, you will need the following components:
* 1x ESP32 Development Board (e.g., NodeMCU)
* 1x CC1101 Antenna (433MHz / 868MHz capable)
* Jumper wires & Breadboard (or custom PCB)



## 👨‍💻 Development Team
This project was developed for the IoT Module (4th Semester, DHBW Stuttgart) by:

* **Felix Bandl**
* **Leonardo Risatti**
* **Manuel Sposato**
* **Laszlo Engemann**

---
*End of transmission.*
