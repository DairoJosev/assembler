; =====================================================================
; PROGRAMA 2: Operador de Mascaras Logicas (AND / OR / XOR) (TASM)
; Ensamblar:  tasm prog2.asm   |   Enlazar:  tlink prog2.exe
; =====================================================================
.MODEL SMALL
.STACK 100h

MASCARA_AND EQU 11110000b   ; AND: apaga (limpia) los 4 bits bajos
MASCARA_OR  EQU 00001111b   ; OR : enciende los 4 bits bajos
MASCARA_XOR EQU 10101010b   ; XOR: invierte los bits pares (7,5,3,1)

.DATA
msgTitulo   db 'OPERADOR DE MASCARAS LOGICAS',13,10,'$'
msgDato     db 13,10,'Ingrese un byte en hexadecimal (00-FF): $'
msgMenu     db 13,10,13,10
            db '1) AND (apagar bits)',13,10
            db '2) OR  (encender bits)',13,10
            db '3) XOR (invertir bits)',13,10
            db 'Seleccione operacion (1-3): $'
msgOrig     db 13,10,13,10,'Dato original : $'
msgMasc     db 13,10,'Mascara       : $'
msgRes      db 13,10,'Resultado     : $'
msgB        db 'b$'
msgCRLF     db 13,10,'$'

dato        db 0
mascara     db 0
resultado   db 0
opcion      db 0

.CODE
MAIN PROC
    MOV AX, @DATA           ; inicializar segmento de datos
    MOV DS, AX

    LEA DX, msgTitulo
    CALL PRINT_STR

    LEA DX, msgDato
    CALL PRINT_STR
    CALL READ_BYTE
    MOV dato, AL

    LEA DX, msgMenu
    CALL PRINT_STR
    CALL READ_OPCION        ; AL = '1', '2' o '3'
    MOV opcion, AL

    ; ---- Seleccion de operacion booleana ----
    MOV AL, dato
    CMP opcion, '1'
    JE  OP_AND
    CMP opcion, '2'
    JE  OP_OR

OP_XOR:
    MOV mascara, MASCARA_XOR
    XOR AL, MASCARA_XOR     ; invertir bits seleccionados
    JMP GUARDAR
OP_AND:
    MOV mascara, MASCARA_AND
    AND AL, MASCARA_AND     ; limpiar bits donde la mascara es 0
    JMP GUARDAR
OP_OR:
    MOV mascara, MASCARA_OR
    OR  AL, MASCARA_OR      ; encender bits donde la mascara es 1
GUARDAR:
    MOV resultado, AL

    ; ---- Mostrar en binario de 8 bits ----
    LEA DX, msgOrig
    CALL PRINT_STR
    MOV AL, dato
    CALL PRINT_BIN8

    LEA DX, msgMasc
    CALL PRINT_STR
    MOV AL, mascara
    CALL PRINT_BIN8

    LEA DX, msgRes
    CALL PRINT_STR
    MOV AL, resultado
    CALL PRINT_BIN8

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
; READ_NIBBLE: lee un digito hex (0-9, A-F, a-f). Salida: AL = 0..15
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
; READ_BYTE: lee dos digitos hex. Salida: AL = byte
; ---------------------------------------------------------------------
READ_BYTE PROC
    PUSH CX
    CALL READ_NIBBLE
    MOV CL, 4
    SHL AL, CL
    MOV CH, AL
    CALL READ_NIBBLE
    OR  AL, CH
    POP CX
    RET
READ_BYTE ENDP

; ---------------------------------------------------------------------
; READ_OPCION: lee '1', '2' o '3'. Salida: AL
; ---------------------------------------------------------------------
READ_OPCION PROC
RP_REINTENTAR:
    MOV AH, 01h
    INT 21h
    CMP AL, '1'
    JB  RP_REINTENTAR
    CMP AL, '3'
    JA  RP_REINTENTAR
    RET
READ_OPCION ENDP

; ---------------------------------------------------------------------
; PRINT_BIN8: imprime AL como 8 digitos binarios seguidos de 'b'
; Desplaza a la izquierda; el bit expulsado (CF) se convierte en '0'/'1'
; ---------------------------------------------------------------------
PRINT_BIN8 PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV BL, AL
    MOV CX, 8
PB_BUCLE:
    SHL BL, 1               ; bit alto -> CF
    MOV DL, '0'
    ADC DL, 0               ; DL = '0' + CF
    MOV AH, 02h
    INT 21h
    LOOP PB_BUCLE
    LEA DX, msgB
    MOV AH, 09h
    INT 21h
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_BIN8 ENDP

END MAIN