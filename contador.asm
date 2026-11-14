; =====================================================================
; PROGRAMA 3: Contador Progresivo Automatico en Base 16 (TASM)
; Cuenta de 0h a Fh imprimiendo los 16 digitos hexadecimales.
; Ensamblar:  tasm prog3.asm   |   Enlazar:  tlink prog3.exe
; =====================================================================
.MODEL SMALL
.STACK 100h

.DATA
msgTitulo   db 'CONTADOR HEXADECIMAL 0h -> Fh',13,10,13,10,'$'
msgSep      db ', $'
msgFin      db 13,10,13,10,'Conteo finalizado.',13,10,'$'

.CODE
MAIN PROC
    MOV AX, @DATA           ; inicializar segmento de datos
    MOV DS, AX

    LEA DX, msgTitulo
    MOV AH, 09h
    INT 21h

    MOV BL, 0               ; contador inicia en 0h
    MOV CX, 16              ; 16 iteraciones (0..F)

CICLO:
    MOV AL, BL
    CALL PRINT_NIBBLE       ; imprimir digito hexadecimal actual

    CMP BL, 0Fh             ; ¿es el ultimo digito?
    JZ  SIN_SEPARADOR       ; si es Fh, no imprimir coma
    LEA DX, msgSep
    MOV AH, 09h
    INT 21h
SIN_SEPARADOR:
    INC BL                  ; siguiente valor
    LOOP CICLO              ; CX = CX - 1; repetir mientras CX <> 0

    ; Verificacion final con CMP/JNZ: BL debe valer 10h tras Fh
    CMP BL, 10h
    JNZ SALIR               ; si no es 10h, saltar sin mensaje (no deberia ocurrir)
    LEA DX, msgFin
    MOV AH, 09h
    INT 21h

SALIR:
    MOV AH, 4Ch             ; retornar al sistema operativo
    INT 21h
MAIN ENDP

; ---------------------------------------------------------------------
; PRINT_NIBBLE: imprime AL (0..15) como caracter hexadecimal '0'..'F'
; ---------------------------------------------------------------------
PRINT_NIBBLE PROC
    PUSH AX
    PUSH DX
    ADD AL, '0'
    CMP AL, '9'
    JBE PN_IMPRIMIR
    ADD AL, 7               ; ajustar a 'A'..'F'
PN_IMPRIMIR:
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    POP DX
    POP AX
    RET
PRINT_NIBBLE ENDP

END MAIN