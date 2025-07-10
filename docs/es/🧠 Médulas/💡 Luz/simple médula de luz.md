# Simple médula de luz (Arduino)

Este módulo permite controlar un relé conectado a una lámpara mediante comandos enviados por puerto serial. Soporta:

- Control manual (`led: true/false`)
- Programación horaria (`on_time`, `off_time`)
- Prioridad automática (el horario prevalece sobre el estado manual)

---

## 🔌 Requisitos de hardware

- Microcontrolador: Arduino Nano / Uno / ESP32 (modo serial)
- Relé de 1 canal (5V)
- Carga conectada (ej. lámpara 220V)
- Comunicación Serial desde Node-RED o backend

---

## 📡 Comunicación Serial

Se utiliza un protocolo JSON vía `Serial` (9600 baudios). Cada línea debe terminar en `\n`.

### Estructura esperada:

```json
{
  "current_time": "HH:MM",
  "on_time": "HH:MM",
  "off_time": "HH:MM",
  "led": true | false
}
````

> **Notas:**
>
> * `current_time` es obligatorio para la programación horaria.
> * `led` activa control manual, pero se ignora si el sistema está dentro del horario programado.

---

## 🧠 Prioridad de control

| Condición                    | Acción sobre el relé      |
| ---------------------------- | ------------------------- |
| Dentro del horario           | Relé encendido (`LOW`)    |
| Fuera del horario + override | Relé según `led` (manual) |
| Fuera del horario            | Relé apagado (`HIGH`)     |

---

## 🔄 Flujo típico (desde Node-RED)

```text
[ Inject Timestamp ] → [ Function: construir JSON ] → [ Serial out ]
```

### Ejemplo función Node-RED (JavaScript):

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

## 🧠 Código fuente

* [🔗 Ver `.ino` en GitHub](https://github.com/growhardware/fullstack/blob/develop/devices/arduinouno/simple-light-medulla.ino)
* [🔗 Ver flujo Node-RED para envío de plan vía MQTT](https://github.com/growhardware/fullstack/blob/develop/nodered/flows.json#L37)

---

## 📘 Código Arduino (resumen lógico)

```cpp
if (doc.containsKey("current_time")) { ... }
if (doc.containsKey("on_time") && doc.containsKey("off_time")) { ... }
if (doc.containsKey("led")) { ... }
```

### Evaluación lógica:

```cpp
if (inSchedule) {
  // Encender (modo automático)
} else if (manualOverride) {
  // Aplicar control manual
} else {
  // Apagar
}
```

---

## 🛠️ Debugging serial

En `Monitor Serial`, el dispositivo imprime:

* 📥 JSON recibido
* ⏰ Hora actual
* ⏱️ Rango programado
* 💡 Estado del relé

---

## 🧪 Casos de prueba

| Caso                                   | Resultado esperado                         |
| -------------------------------------- | ------------------------------------------ |
| Hora 21:00, on 20:00, off 22:00        | 💡 Encendido por horario ✅                 |
| Hora 23:00, led: true                  | 💤 Fuera de horario, sin override. Apagado |
| Hora 23:00, led: true + horario válido | 💡 Encendido (horario tiene prioridad) ✅   |

---

## 🔐 Licencia

Este módulo forma parte del ecosistema **GrowHardware** – libre, modular y extendible. Compatible con AI-Core y futuros módulos de automatización agrícola.
