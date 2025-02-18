;************************************************************************
; Universidad del Valle de Guatemala
; IE2023: Programación de Microcontroladores
; Test.asm
;
; Author: Juan Chang
; Proyecto: Contador binario
; Hardware: ATMega328P
; Creado: 2/12/2025 
; Modificado: 30/11/2024
; Descipción: contador binario de 4 bits en el que cada incremento serealizará cada 100ms, utilizando el Timer0.
;************************************************************************
.include "M328PDEF.inc"
.org 0x0000

	RJMP START

START:
	LDI		R16, 0xFF
	OUT		DDRC, R16		; Configurar el PORTC como salida 

	LDI		R16, 0x05
	OUT		TCCR0B, R16		; Configurar Timer0 con prescaler de 1024

	LDI R16, 0xFF
    OUT DDRD, R16			; Configura PORTD como salida (para el display de 7 segmentos)

    LDI R16, 0x00
    OUT DDRB, R16			; Configura PORTB como entrada (botones)

    LDI R16, 0xFF
    OUT PORTB, R16			; Habilita pull-ups en PB0 y PB1

	LDI ZH, 0X01			; Cargar parte alta de la tabla
    LDI ZL, 0X00			; Cargar parte baja de la tabla

    LDI R16, 0b00111111		; 0 en el display
	ST Z+, R16

	LDI	R16, 0b00000110		;1 en el display
	ST Z+, R16

	LDI	R16, 0b01011011		;2 en el display
	ST Z+, R16

	LDI	R16, 0b01001111		;3 en el display
	ST Z+, R16

	LDI	R16, 0b01100110		;4 en el display
	ST Z+, R16

	LDI	R16, 0b01101101		;5 en el display
	ST Z+, R16

	LDI	R16, 0b01111101		;6 en el display
	ST Z+, R16

	LDI	R16, 0b00000111		;7 en el display
	ST Z+, R16

	LDI	R16, 0b01111111		;8 en el display
	ST Z+, R16

	LDI	R16, 0b01101111		;9 en el display
	ST Z+, R16

	LDI	R16, 0b01110111		;A en el display
	ST Z+, R16

	LDI	R16, 0b01111100		;B en el display
	ST Z+, R16

	LDI	R16, 0b00111001		;C en el display
	ST Z+, R16

	LDI	R16, 0b01011110		;D en el display
	ST Z+, R16

	LDI	R16, 0b01111001		;E en el display
	ST Z+, R16

	LDI	R16, 0b01110001		;F en el display
	ST Z+, R16

	LDI ZH, 0X01			; Cargar parte alta de la tabla
    LDI ZL, 0X00			; Cargar parte baja de la tabla

	LD R16, Z				; Revisamos el siguiente registro del puntero
	OUT PORTD, R16			; Iniciar el display en 0

	LDI R20, 0x00			; Revisamos el siguiente registro del puntero

MAIN_LOOP:
    RCALL   T100ms          ; Se necesitan 10 desbordamientos (~100 ms)
    INC     R17
    ANDI    R17, 0x0F       ; Mantiene el contador en 4 bits (0-15)
    
    IN      R16, PORTC      ; Lee el estado actual de PORTC
    ANDI    R16, 0x10       ; Encender solo PC4  bit 4 (LED)
    MOV     R22, R17        ; Copia R17 a R22
    ANDI    R22, 0x0F       ; Mantiene solo los 4 bits menos significativos
    OR      R16, R22        ; Combina el estado del LED con el contador
    OUT     PORTC, R16      ; Actualiza PORTC
    
    RCALL   CHECK_COUNT     ; Verifica si los contadores coinciden
    RCALL   CHECK_INC		; Verifica los botones
    RJMP    MAIN_LOOP

CHECK_INC:
	SBIC PINB, 0			; Si PB0 (incrementar) está en alto, salta
    RJMP CHECK_DEC			; Si no, verifica el botón de decremento
    RCALL DELAY				; Antirrebote 
 
	INC R20					; Incrementa el contador
    ANDI R20, 0x0F			; Mantiene el contador en 4 bits (0-15)

	LDI ZH, 0x01			; Cargar parte alta de la tabla
    LDI ZL, 0x00			; Cargar parte baja de la tabla
    MOV R16, R20			; Copiar el contador a R16
    ADD ZL, R16				; Sumar el offset al puntero
    LD R16, Z				; Cargar el valor correspondiente
    OUT PORTD, R16			; Mostrar en el display

	RCALL WAIT_FOR_RELEASE	; Revisar que no hayan pushbuttons presionados
	RJMP MAIN_LOOP

CHECK_DEC:
	SBIC PINB, 1			; Si PB1 (decrementar) está en bajo
	RET						; Si no, regresa
    RCALL DELAY             ; Antirrebote
    
    DEC R20                 ; Decrementar el contador
    ANDI R20, 0x0F			; Mantiene el contador en 4 bits (0-15)
    
    LDI ZH, 0x01			; Cargar parte alta de la tabla
    LDI ZL, 0x00			; Cargar parte baja de la tabla
    MOV R16, R20			; Copiar el contador a R16
    ADD ZL, R16				; Sumar el offset al puntero
    LD R16, Z				; Cargar el valor correspondiente
    OUT PORTD, R16			; Mostrar en el display
	
	RCALL WAIT_FOR_RELEASE	; Revisar que no hayan pushbuttons presionados
	RJMP MAIN_LOOP

CHECK_COUNT:
    CP      R17, R20        ; Compara R17 (contador segundos) con R20 (contador botones)
    BRNE    RETURN_CHECK    ; Si no son iguales, retorna
    
    CLR     R17             ; Reinicia el contador de segundos
    SBRS    R21, 0          ; Salta si R21 bit 0 es 1 (LED encendido)
    RJMP    LED_ON			; Si el LED está apagado, enciéndelo
    RJMP    LED_OFF			; Si el LED está encendido, apágalo

LED_ON:
    SBI     PORTC, 4        ; Enciende LED en PC4
    LDI     R16, 1
    MOV     R21, R16        ; Marca LED como encendido
    RET
	
LED_OFF:
    CBI     PORTC, 4        ; Apaga LED en PC4
    CLR     R21             ; Marca LED como apagado
    RET

RETURN_CHECK:
    RET

T100ms:
	LDI		R18, 15
TIMER: 
	SBIS	TIFR0, TOV0			; Esperar desbordamiento
	RJMP	TIMER
	LDI		R16, (1 << TOV0)	; Limpiar la bandera de desbordamiento
	OUT		TIFR0, R16
	DEC		R18
	BRNE	TIMER
	RET

; Revisar que no hayan pushbuttons presionados
WAIT_FOR_RELEASE:
    SBIS PINB, 0
    RJMP WAIT_FOR_RELEASE
	SBIS PINB, 1	
	RJMP WAIT_FOR_RELEASE
    RET

	;Antirrebote
DELAY:
    LDI     R18, 0xFF
SUB_DELAY1:
    DEC     R18
    CPI     R18, 0
    BRNE    SUB_DELAY1
    LDI     R18, 0xFF
SUB_DELAY2:
    DEC     R18
    CPI     R18, 0
    BRNE    SUB_DELAY2
    RET
