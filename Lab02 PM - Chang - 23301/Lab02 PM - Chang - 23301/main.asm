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

	LDI R16, 0X00
	OUT PORTD, R16			; Iniciar el display apagado

	LDI ZH, 0X01			; Cargar parte alta de la tabla
    LDI ZL, 0X00			; Cargar parte baja de la tabla

MAIN_LOOP:
	CALL	T100ms			; Se necesitan 10 desbordamientos (~100 ms)
	INC		R17
	OUT		PORTC, R17

	SBIC PINB, 0			 ; Si PB0 (incrementar) está en alto, salta
    RJMP CHECK_DEC			 ; Si no, verifica el botón de decremento
    RCALL DELAY				 ; Antirrebote 

	ANDI ZL, 0x0F			 ; Mantener valores entre 0-F automáticamente
	LD R16, Z+				 ; Revisamos el siguiente registro del puntero
	OUT PORTD, R16			 ; Muestra el valor del contador en el display 
	RCALL WAIT_FOR_RELEASE	 ; Revisar que no hayan pushbuttons presionados

CHECK_DEC:
	SBIC PINB, 1			 ; Si PB1 (decrementar) está en alto, salta
    RJMP MAIN_LOOP			 ; Si no, regresar al main
    RCALL DELAY				 ; Antirrebote 

    CPI ZL, 0x00			 ; Verificar si estamos en 0
    BRNE DEC_NORMAL			 ; Si no está en 0, hacer decremento normal
    LDI ZL, 0x10			 ; Si está en 0, ponerlo en 0x10 (para que al restar pase a 0x0F)

DEC_NORMAL:
    LD R16, -Z				 ; Revisamos el siguiente registro del puntero
    OUT PORTD, R16           ; Muestra el valor del contador en el display   
    RCALL WAIT_FOR_RELEASE	 ; Revisar que no hayan pushbuttons presionados
    RJMP MAIN_LOOP

T100ms:
	LDI		R18, 10
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
    SBIS PINB, 2
	RJMP WAIT_FOR_RELEASE
    SBIS PINB, 3
    RJMP WAIT_FOR_RELEASE
	SBIS PINB, 4
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







