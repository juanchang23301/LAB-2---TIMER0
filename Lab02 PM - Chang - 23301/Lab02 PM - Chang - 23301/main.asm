;************************************************************************
; Universidad del Valle de Guatemala
; IE2023: Programación de Microcontroladores
; Test.asm
;
; Author: Juan Chang
; Proyecto: Ejemplo
; Hardware: ATMega328P
; Creado: 2/5/2025 1:54:05 PM
; Modificado: 30/11/2024
; Descipción: Este programa consiste ens
;************************************************************************
.include "M328PDEF.inc"
.org 0x0000


LDI		R16, 0xFF
OUT		DDRC, R16

LDI		R16, 0x05
OUT		TCCR0B, R16		; Configurar Timer0 con prescaler de 1024

MAIN_LOOP:
	CALL	T100ms		; Se necesitan 6 desbordamientos (~100 ms)
	INC		R17
	OUT		PORTC, R17
	RJMP	MAIN_LOOP

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






