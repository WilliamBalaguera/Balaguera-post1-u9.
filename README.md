
# Balaguera-Post1-U9
**Estudiante:** William Balaguera
**Código:** 1152439
**Asignatura:** Arquitectura de Computadores
**Unidad:** 9 — Entrada y Salida Avanzados
**Actividad:** Post-Contenido 1
**Programa:** Ingeniería de Sistemas — Universidad Francisco de Paula Santander
**Año:** 2026

---

## Objetivo
Desarrollar programas en lenguaje ensamblador x86 (NASM + DOSBox) que interactúen directamente con puertos de E/S mediante las instrucciones `IN` y `OUT`, implementar la técnica de polling para sincronización con dispositivos, y analizar el comportamiento de los registros de estado del controlador de teclado 8042 y del puerto paralelo LPT1.

---

## Prerrequisitos

| Requisito | Detalle |
|---|---|
| Sistema operativo | Windows (recomendado) |
| DOSBox | Versión 0.74 o superior |
| NASM | Versión 2.x (nasm.exe accesible desde el prompt de DOSBox) |
| Directorio de trabajo | C:\U9P1\ dentro de DOSBox |
| Conocimientos previos | Instrucciones INT 21h, registros de segmento, modos de direccionamiento x86 |

---

## Configuración del entorno

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
Salida esperada: `NASM version 2.14.02`

---

## Programas desarrollados

### 1. TECL.ASM — Lectura del puerto de estado del teclado (puerto 64h)
**Descripción:**
Lee el registro de estado del controlador de teclado 8042 mediante polling. Espera a que el bit OBF (Output Buffer Full) del puerto 64h sea 1, luego obtiene el scancode del puerto 60h y lo presenta en pantalla en formato hexadecimal.

**Puertos utilizados:**
- `60h` — Data Port: contiene el último scancode recibido
- `64h` — Status Register: el bit 0 (OBF) indica que hay datos disponibles

**Compilación:**
```
nasm -f bin TECL.ASM -o TECL.COM
```
**Ejecución:**
```
TECL
```
**Resultado esperado:**
Al presionar una tecla se muestra su scancode en hexadecimal. Ejemplo con la tecla A (scancode 1Eh):
```
1E
```
✔ **Checkpoint 1:** El programa compila sin errores y despliega correctamente el scancode.

---

### 2. POLL_T.ASM — Polling con timeout
**Descripción:**
Versión extendida del polling que incorpora un contador de reintentos (`MAX_RETRY`) para evitar bloqueos cuando el dispositivo no responde. Si se agota el contador sin recibir dato, el programa muestra un mensaje de timeout y finaliza.

**Parámetro clave:**
- `MAX_RETRY EQU 0FFFFh` — reducir a `0005h` para forzar timeout en pruebas

**Compilación:**
```
nasm -f bin POLL_T.ASM -o POLL_T.COM
```
**Ejecución:**
```
POLL_T
```
**Resultado esperado** (con `MAX_RETRY = 0005h` sin presionar tecla):
```
Timeout: sin respuesta del dispositivo
```
✔ **Checkpoint 2:** El programa muestra el timeout correctamente bajo las condiciones indicadas.

---

### 3. LPT1.ASM — Escritura al puerto paralelo LPT1 (0x378)
**Descripción:**
Envía el carácter `A` (0x41) al puerto paralelo siguiendo el protocolo Centronics: verifica que la impresora esté lista, coloca el dato en el registro de datos, genera un pulso STROBE y termina.

**Puertos utilizados:**
- `0x378` — Data Register: datos hacia las líneas D0–D7
- `0x379` — Status Register: señales BUSY, ACK, PE, SELECT, ERROR
- `0x37A` — Control Register: señales STROBE, AUTOFEED, INIT, SELECT_IN

**Protocolo Centronics:**
1. Esperar BUSY# = 1
2. Colocar dato en 0x378
3. Activar STROBE por al menos 1 µs
4. Desactivar STROBE

**Compilación:**
```
nasm -f bin LPT1.ASM -o LPT1.COM
```
**Ejecución:**
```
LPT1
```
✔ **Checkpoint 3:** El programa compila y se ejecuta sin errores en DOSBox.

---

## Estructura del repositorio
```
Balaguera-Post1-U9/
│
├── README.md
├── TECL.ASM
├── POLL_T.ASM
├── LPT1.ASM
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
