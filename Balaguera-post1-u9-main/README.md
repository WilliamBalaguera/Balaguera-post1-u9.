# Kher-Post1-U9

**Estudiante:** Juan David Kher  
**Código:** 1152430  
**Asignatura:** Arquitectura de Computadores  
**Unidad:** 9 — Entrada y Salida Avanzados  
**Actividad:** Post-Contenido 1  
**Programa:** Ingeniería de Sistemas — Universidad Francisco de Paula Santander  
**Año:** 2026

---

## Objetivo

Implementar programas en lenguaje ensamblador x86 (NASM + DOSBox) que accedan directamente a puertos de E/S mediante las instrucciones `IN` y `OUT`, aplicar la técnica de polling para sincronización con dispositivos, y verificar el comportamiento de los registros de estado del controlador de teclado 8042 y del puerto paralelo LPT1.

---

## Prerrequisitos

| Requisito | Detalle |
|---|---|
| Sistema operativo | Windows (recomendado) |
| DOSBox | Versión 0.74 o superior |
| NASM | Versión 2.x (nasm.exe accesible desde el prompt de DOSBox) |
| Directorio de trabajo | `C:\U9P1\` dentro de DOSBox |
| Conocimientos previos | Instrucciones INT 21h, registros de segmento, modos de direccionamiento x86 |

### Configuración inicial del entorno

1. Instalar DOSBox desde https://www.dosbox.com
2. Copiar `nasm.exe` al directorio `C:\U9P1\`
3. Montar la carpeta en DOSBox:

```
mount c c:\U9P1
c:
```

4. Verificar que NASM esté disponible:

```
nasm -v
```

La salida esperada es algo como: `NASM version 2.14.02`

---

## Programas

### 1. TECL.ASM — Lectura del puerto de estado del teclado (puerto 64h)

**Descripción:**  
Lee el registro de estado del controlador de teclado 8042 usando la técnica de polling. Espera hasta que el bit OBF (Output Buffer Full) del puerto `64h` esté en 1, luego lee el scancode del puerto `60h` y lo muestra en pantalla en formato hexadecimal.

**Puertos utilizados:**
- `60h` — Data Port: contiene el último scancode recibido
- `64h` — Status Register: el bit 0 (OBF) indica que hay datos listos

**Compilación:**

```
nasm -f bin TECL.ASM -o TECL.COM
```

**Ejecución:**

```
TECL
```

**Resultado esperado:**  
Al presionar una tecla, el programa muestra el scancode en hexadecimal. Por ejemplo, al presionar `A` (scancode make: 1Eh), la salida es:

```
1E
```

**Checkpoint 1 ✔:** El programa compila sin errores y muestra correctamente el scancode de la tecla presionada.

---

### 2. POLL_T.ASM — Polling con timeout del puerto de estado

**Descripción:**  
Versión mejorada del polling que incluye un contador de reintentos (`MAX_RETRY`) para evitar que el programa se bloquee indefinidamente si el dispositivo no responde. Si el contador llega a cero sin recibir dato, muestra un mensaje de timeout y termina.

**Parámetro clave:**
- `MAX_RETRY EQU 0FFFFh` — número máximo de reintentos (reducir a `0005h` para forzar timeout en pruebas)

**Compilación:**

```
nasm -f bin POLL_T.ASM -o POLL_T.COM
```

**Ejecución:**

```
POLL_T
```

**Resultado esperado (con MAX_RETRY = 0005h, sin presionar tecla):**

```
Timeout: sin respuesta del dispositivo
```

**Checkpoint 2 ✔:** El programa muestra el mensaje de timeout cuando `MAX_RETRY` es pequeño y no se presiona ninguna tecla en el tiempo definido.

---

### 3. LPT1.ASM — Escritura al puerto paralelo LPT1 (0x378)

**Descripción:**  
Envía el carácter `A` (0x41) al puerto paralelo centronics siguiendo el protocolo de escritura estándar: espera a que la impresora esté lista (BUSY# en alto), coloca el dato en el registro de datos, genera un pulso STROBE y termina.

**Puertos utilizados:**
- `0x378` — Data Register: 8 bits de datos enviados a las líneas D0–D7
- `0x379` — Status Register: señales de retroalimentación (BUSY, ACK, PE, SELECT, ERROR)
- `0x37A` — Control Register: señales de control (STROBE, AUTOFEED, INIT, SELECT_IN)

**Protocolo de escritura Centronics:**
1. Esperar BUSY# = 1 (impresora lista)
2. Colocar el dato en `0x378`
3. Activar STROBE (bit 0 de `0x37A`) por al menos 1 µs
4. Desactivar STROBE

**Compilación:**

```
nasm -f bin LPT1.ASM -o LPT1.COM
```

**Ejecución:**

```
LPT1
```

**Comportamiento observado en DOSBox:**  
El puerto paralelo no está conectado a un dispositivo físico, pero el acceso al puerto no genera error. El bit BUSY# del registro de estado aparece como alto, por lo que el bucle de espera termina inmediatamente y el programa finaliza sin bloqueo.

**Checkpoint 3 ✔:** El programa compila y se ejecuta sin errores de acceso a puerto en DOSBox.

---

## Estructura del repositorio

```
Kher-Post1-U9/
│
├── README.md               ← Este archivo
├── TECL.ASM                ← Lectura del teclado con polling
├── POLL_T.ASM              ← Polling con timeout
├── LPT1.ASM                ← Escritura al puerto paralelo
│
└── capturas/
    ├── checkpoint1_TECL.png
    ├── checkpoint2_POLL_T.png
    └── checkpoint3_LPT1.png
```

---

## Resumen de resultados

| Checkpoint | Programa | Resultado |
|---|---|---|
| 1 | TECL.COM | Muestra scancode hexadecimal al presionar tecla |
| 2 | POLL_T.COM | Muestra mensaje de timeout con MAX_RETRY pequeño |
| 3 | LPT1.COM | Compila y ejecuta sin errores en DOSBox |
