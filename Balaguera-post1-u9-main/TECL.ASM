; TECL.ASM — Lectura del estado del teclado 8042
; Compila: nasm -f bin TECL.ASM -o TECL.COM

[BITS 16]
[ORG 0x100]           ; programa .COM, CS=DS=ES=SS

start:
    ; Esperar hasta que OBF=1 (dato disponible en buffer de salida)
.poll:
    IN AL, 64h        ; leer registro de estado del 8042
    TEST AL, 01h      ; comprobar bit OBF
    JZ .poll          ; si OBF=0, no hay dato listo — repetir

    IN AL, 60h        ; leer scancode del Data Port
    MOV BL, AL        ; guardar scancode en BL

    ; Mostrar scancode en pantalla (conversion hex manual)
    MOV AH, 02h       ; funcion DOS: imprimir caracter
    MOV DL, BL
    SHR DL, 4         ; nibble alto
    ADD DL, 30h
    CMP DL, 3Ah
    JL .printH
    ADD DL, 07h       ; ajuste A-F
.printH:
    INT 21h

    MOV DL, BL
    AND DL, 0Fh       ; nibble bajo
    ADD DL, 30h
    CMP DL, 3Ah
    JL .printL
    ADD DL, 07h
.printL:
    INT 21h

    MOV AH, 02h
    MOV DL, 0Dh       ; CR
    INT 21h
    MOV DL, 0Ah       ; LF
    INT 21h

    MOV AH, 4Ch
    INT 21h           ; terminar programa
