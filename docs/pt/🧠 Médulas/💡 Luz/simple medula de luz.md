# Módulo de Luz Simples (Arduino)

Este módulo controla um relé conectado a uma lâmpada via comandos seriais. Ele suporta:

- Controle manual (`led: true/false`)
- Agendamento de horário (`on_time`, `off_time`)
- Prioridade automática (o horário tem prioridade sobre o manual)

---

## 🔌 Requisitos de hardware

- Microcontrolador: Arduino Nano / Uno / ESP32 (modo serial)
- Relé de 1 canal (5V)
- Carga conectada (ex: lâmpada 220V)
- Comunicação serial via Node-RED ou backend

---

## 📡 Comunicação serial

Recebe JSON via `Serial` (9600 baud). Cada mensagem deve terminar com `\n`.

### Formato esperado:

```json
{
  "current_time": "HH:MM",
  "on_time": "HH:MM",
  "off_time": "HH:MM",
  "led": true | false
}
````

> **Nota:**
>
> * `current_time` é obrigatório para controle de horário.
> * `led` ativa controle manual, mas será ignorado se o horário estiver ativo.

---

## 🧠 Prioridade de controle

| Condição                   | Estado do relé          |
| -------------------------- | ----------------------- |
| Dentro do horário          | Relé LIGADO (`LOW`)     |
| Fora do horário + override | Usa valor de `led`      |
| Fora do horário            | Relé DESLIGADO (`HIGH`) |

---

## 🔄 Fluxo típico (Node-RED)

```text
[ Inject ] → [ Função JavaScript ] → [ Saída Serial ]
```

### Exemplo de função:

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

## 🧠 Código-fonte

* [🔗 Ver `.ino` no GitHub](https://github.com/growhardware/fullstack/blob/develop/devices/arduinouno/simple-light-medulla.ino)
* [🔗 Ver fluxo Node-RED (plano → MQTT)](https://github.com/growhardware/fullstack/blob/develop/nodered/flows.json#L37)

---

## 🛠️ Depuração serial

No monitor serial o dispositivo imprime:

* 📥 JSON recebido
* ⏰ Hora atual
* ⏱️ Horário configurado
* 💡 Estado do relé

---

## 🧪 Casos de teste

| Situação                              | Resultado esperado                    |
| ------------------------------------- | ------------------------------------- |
| Hora 21:00, on 20:00, off 22:00       | 💡 LIGADO por horário ✅               |
| Hora 23:00, led: true                 | 💤 DESLIGADO (horário tem prioridade) |
| Hora 23:00, led: true + horário ativo | 💡 LIGADO (vence o horário) ✅         |

---

## 🔐 Licença

Faz parte do ecossistema **GrowHardware** – livre, modular e expansível. Compatível com AI-Core e módulos futuros de automação agrícola.