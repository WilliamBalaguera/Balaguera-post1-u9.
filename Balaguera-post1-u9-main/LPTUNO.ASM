; LPT1.ASM — Envio de un caracter al puerto paralelo LPT1
; Compila: nasm -f bin LPT1.ASM -o LPT1.COM

[BITS 16]
[ORG 0x100]

DATA_PORT   EQU 0378h   ; Registro de datos
STATUS_PORT EQU 0379h   ; Registro de estado
CTRL_PORT   EQU 037Ah   ; Registro de control

start:
    ; Esperar BUSY=1 (impresora lista)
.wait_ready:
    IN AL, STATUS_PORT
    TEST AL, 80h          ; bit 7: BUSY# (activo en bajo = ocupada)
    JZ .wait_ready

    ; Enviar caracter "A" (0x41)
    MOV AL, 41h
    OUT DATA_PORT, AL     ; colocar dato en el bus de datos

    ; Pulso STROBE (bit 0 del control, activo en bajo)
    IN AL, CTRL_PORT
    AND AL, 0FEh          ; STROBE=0 -> activo
    OUT CTRL_PORT, AL

    ; Retardo minimo (~1us en DOSBox)
    MOV CX, 0Fh
.delay:
    LOOP .delay

    ; Desactivar STROBE
    IN AL, CTRL_PORT
    OR AL, 01h            ; STROBE=1 -> inactivo
    OUT CTRL_PORT, AL

    ; Mensaje de confirmacion
    MOV AH, 09h
    MOV DX, msg_ok
    INT 21h

    MOV AH, 4Ch
    INT 21h               ; terminar programa

msg_ok DB 'Caracter enviado al puerto paralelo LPT1$'
