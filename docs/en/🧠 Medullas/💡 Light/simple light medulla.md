# Simple Light Module (Arduino)

This module controls a relay connected to a lamp via serial commands. It supports:

- Manual control (`led: true/false`)
- Scheduled on/off (`on_time`, `off_time`)
- Automatic priority (time-based control overrides manual)

---

## 🔌 Hardware requirements

- Microcontroller: Arduino Nano / Uno / ESP32 (serial mode)
- 1-channel relay (5V)
- Connected load (e.g., 220V lamp)
- Serial communication from Node-RED or backend

---

## 📡 Serial communication

The device receives JSON over `Serial` (9600 baud). Each message ends with `\n`.

### Expected payload:

```json
{
  "current_time": "HH:MM",
  "on_time": "HH:MM",
  "off_time": "HH:MM",
  "led": true | false
}
````

> **Note:**
>
> * `current_time` is required for scheduling.
> * `led` triggers manual control, but will be overridden by the schedule if active.

---

## 🧠 Control priority

| Condition               | Relay state        |
| ----------------------- | ------------------ |
| Within scheduled time   | Relay ON (`LOW`)   |
| Outside time + override | Use `led` value    |
| Outside time            | Relay OFF (`HIGH`) |

---

## 🔄 Typical flow (via Node-RED)

```text
[ Inject ] → [ Function Node ] → [ Serial Out ]
```

### Example function (JavaScript):

```javascript
let now = new Date();
now.setHours(now.getHours() - 3);  // GMT-3

let hh = now.getHours().toString().padStart(2, '0');
let mm = now.getMinutes().toString().padStart(2, '0');

msg.payload = JSON.stringify({
  current_time: `${hh}:${mm}`,
  on_time: "22:00",
  off_time: "23:00",
  led: false
}) + "\n";

return msg;
```

---

## 🧠 Source code

* [🔗 View `.ino` on GitHub](https://github.com/growhardware/fullstack/blob/develop/devices/arduinouno/simple-light-medulla.ino)
* [🔗 View Node-RED flow (plan → MQTT)](https://github.com/growhardware/fullstack/blob/develop/nodered/flows.json#L37)

---

## 🛠️ Serial debugging

In the Serial Monitor, the device prints:

* 📥 Incoming JSON
* ⏰ Current time
* ⏱️ Scheduled range
* 💡 Relay status

---

## 🧪 Test cases

| Scenario                               | Expected result                    |
| -------------------------------------- | ---------------------------------- |
| Time 21:00, on 20:00, off 22:00        | 💡 ON due to schedule ✅            |
| Time 23:00, led: true                  | 💤 OFF (schedule takes precedence) |
| Time 23:00, led: true + valid schedule | 💡 ON (time wins) ✅                |

---

## 🔐 License

Part of the **GrowHardware** ecosystem – open, modular, and extendable. Fully compatible with AI-Core and future automation modules.
