; =====================================================================
; PROGRAMA 1: Calculadora de Aritmética Hexadecimal Directa (TASM)
; Ensamblar:  tasm prog1.asm   |   Enlazar:  tlink prog1.exe
; =====================================================================
.MODEL SMALL
.STACK 100h

.DATA
msgTitulo   db 'CALCULADORA HEXADECIMAL (1 byte)',13,10,'$'
msgA        db 13,10,'Primer valor  (00-FF): $'
msgOp       db 13,10,'Operador (+ o -)      : $'
msgB        db 13,10,'Segundo valor (00-FF): $'
msgRes      db 13,10,13,10,'Resultado: $'
msgH        db 'h$'
msgAcarreo  db 13,10,'CF=1 -> ACARREO (la suma excedio FFh).$'
msgPrestamo db 13,10,'CF=1 -> PRESTAMO (resta negativa, resultado en complemento a 2).$'
msgSinCF    db 13,10,'CF=0 -> sin acarreo ni prestamo.$'
msgCRLF     db 13,10,'$'

valA        db 0            ; primer operando
valB        db 0            ; segundo operando
operador    db 0            ; '+' o '-'
resultado   db 0            ; resultado de 8 bits
bandera     db 0            ; copia de CF tras la operacion

.CODE
MAIN PROC
    MOV AX, @DATA           ; inicializar segmento de datos
    MOV DS, AX

    LEA DX, msgTitulo
    CALL PRINT_STR

    ; ---- Entrada de datos ----
    LEA DX, msgA
    CALL PRINT_STR
    CALL READ_BYTE          ; AL = byte leido
    MOV valA, AL

    LEA DX, msgOp
    CALL PRINT_STR
    CALL READ_OP            ; AL = '+' o '-'
    MOV operador, AL

    LEA DX, msgB
    CALL PRINT_STR
    CALL READ_BYTE
    MOV valB, AL

    ; ---- Operacion nativa sobre registros ----
    MOV AL, valA
    MOV BL, valB
    CMP operador, '+'
    JNE HACER_RESTA
    ADD AL, BL              ; suma: CF=1 si hay acarreo
    JMP FIN_OP
HACER_RESTA:
    SUB AL, BL              ; resta: CF=1 si hay prestamo
FIN_OP:
    MOV resultado, AL       ; MOV no altera las banderas
    MOV CL, 0
    ADC CL, 0               ; CL = CF (captura el acarreo/prestamo)
    MOV bandera, CL

    ; ---- Mostrar resultado ----
    LEA DX, msgRes
    CALL PRINT_STR
    MOV AL, resultado
    CALL PRINT_BYTE_HEX
    LEA DX, msgH
    CALL PRINT_STR

    ; ---- Informar estado del Carry Flag ----
    CMP bandera, 0
    JE SIN_CF
    CMP operador, '+'
    JNE MSG_PREST
    LEA DX, msgAcarreo
    JMP MOSTRAR_CF
MSG_PREST:
    LEA DX, msgPrestamo
    JMP MOSTRAR_CF
SIN_CF:
    LEA DX, msgSinCF
MOSTRAR_CF:
    CALL PRINT_STR
    LEA DX, msgCRLF
    CALL PRINT_STR

    MOV AH, 4Ch             ; retornar al sistema operativo
    INT 21h
MAIN ENDP

; ---------------------------------------------------------------------
; PRINT_STR: imprime cadena terminada en '$' apuntada por DX
; ---------------------------------------------------------------------
PRINT_STR PROC
    PUSH AX
    MOV AH, 09h
    INT 21h
    POP AX
    RET
PRINT_STR ENDP

; ---------------------------------------------------------------------
; READ_NIBBLE: lee un digito hexadecimal (0-9, A-F, a-f) con eco.
; Repite hasta recibir un caracter valido. Salida: AL = 0..15
; ---------------------------------------------------------------------
READ_NIBBLE PROC
RN_REINTENTAR:
    MOV AH, 01h
    INT 21h
    CMP AL, '0'
    JB  RN_REINTENTAR
    CMP AL, '9'
    JBE RN_DECIMAL
    CMP AL, 'A'
    JB  RN_REINTENTAR
    CMP AL, 'F'
    JBE RN_MAYUS
    CMP AL, 'a'
    JB  RN_REINTENTAR
    CMP AL, 'f'
    JA  RN_REINTENTAR
    SUB AL, 'a' - 10
    RET
RN_DECIMAL:
    SUB AL, '0'
    RET
RN_MAYUS:
    SUB AL, 'A' - 10
    RET
READ_NIBBLE ENDP

; ---------------------------------------------------------------------
; READ_BYTE: lee dos digitos hex. Salida: AL = byte (00h..0FFh)
; ---------------------------------------------------------------------
READ_BYTE PROC
    PUSH CX
    CALL READ_NIBBLE
    MOV CL, 4
    SHL AL, CL              ; nibble alto
    MOV CH, AL
    CALL READ_NIBBLE
    OR  AL, CH              ; combinar con nibble bajo
    POP CX
    RET
READ_BYTE ENDP

; ---------------------------------------------------------------------
; READ_OP: lee '+' o '-' (ignora otras teclas). Salida: AL
; ---------------------------------------------------------------------
READ_OP PROC
RO_REINTENTAR:
    MOV AH, 01h
    INT 21h
    CMP AL, '+'
    JE  RO_OK
    CMP AL, '-'
    JNE RO_REINTENTAR
RO_OK:
    RET
READ_OP ENDP

; ---------------------------------------------------------------------
; PRINT_NIBBLE: imprime AL (0..15) como un caracter hexadecimal
; ---------------------------------------------------------------------
PRINT_NIBBLE PROC
    PUSH AX
    PUSH DX
    ADD AL, '0'
    CMP AL, '9'
    JBE PN_IMPRIMIR
    ADD AL, 7               ; saltar a 'A'..'F'
PN_IMPRIMIR:
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    POP DX
    POP AX
    RET
PRINT_NIBBLE ENDP

; ---------------------------------------------------------------------
; PRINT_BYTE_HEX: imprime AL como dos digitos hexadecimales
; ---------------------------------------------------------------------
PRINT_BYTE_HEX PROC
    PUSH AX
    PUSH BX
    PUSH CX
    MOV BL, AL
    MOV CL, 4
    SHR AL, CL              ; nibble alto
    CALL PRINT_NIBBLE
    MOV AL, BL
    AND AL, 0Fh             ; nibble bajo
    CALL PRINT_NIBBLE
    POP CX
    POP BX
    POP AX
    RET
PRINT_BYTE_HEX ENDP

END MAIN