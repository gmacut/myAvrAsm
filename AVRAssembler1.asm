/*
 * AVRAssembler1.asm
 *
 *  Created: 30.6.2012. 19:37:30
 *   Author: Goran
 */ 


; Name: int0.asm
; Title: Simple AVR Interrupt Verification Program
;------------------------------------------------------------------------------------

.include "m16def.inc"
; Interrupt service vectors

	.org $0000
	rjmp Reset ; Reset vector										; C004
	
	.org INT0addr  ; INT0addr	= 0x0002	; External Interrupt Request 0
	rjmp IntV0 ; INT0 vector (ext. interrupt from pin D2)			; C01C

	.org INT1addr ; INT1addr	= 0x0004	; External Interrupt Request 1
	rjmp IntV1 ; INT1 vector (ext. interrupt from pin D3)			; C01E



;------------------------------------------------------------------------------------
;
; Register defines for main loop
.def TEMP=r17
.def TIME=r16

;-----------------------------------------------------------------------------------
;
; Reset vector - just sets up interrupts and service routines and
; then loops forever.
Reset:
	ldi TEMP,low(RAMEND)	; Set stackptr to ram end				; 
	out SPL,TEMP
	ldi TEMP, high(RAMEND)
	out SPH, TEMP
	ser TEMP				; Set TEMP to $FF to...
	out DDRB,TEMP			; ...set data direction to "out"
	out PORTD,TEMP			; ...all high for pullup on inputs
	
	; set up int0 and int1
	ldi TEMP,(1<<INT0)+(1<<INT1)	; int masks 0 and 1 set
	out GIMSK,TEMP
	ldi TEMP,$0F;					; interrupt t0 and t1 on rising edge only
	out MCUCR,TEMP
	
	ldi TEMP,$00 
	out PORTB,TEMP					; ...all lights off!
	
	sei						; enable interrupts and off we go!
loop:
	ldi TEMP, $ff	; inner-most loop
	push TEMP
	ldi TEMP, $ff	; inner loop
	push TEMP
	ldi TEMP, $04	; outer loop
	push TEMP

	call delay
	
	in TEMP, PINB
	com TEMP
	out PORTB, TEMP
rjmp loop 


;----------------------------------------------------------------------------------
;
; Int0 vector - increase count
IntV0:
	in TEMP, PINB
	inc TEMP
	out PORTB, TEMP
	reti
;----------------------------------------------------------------------------------
;
; Int1 vector - increase count
IntV1:
	in TEMP, PINB
	dec TEMP
	out PORTB, TEMP
	reti


; Delay function, three nested waiting loops.
; Takes three parameters using stack, waiting
; loop maximum values. On the top comes outermost
; loop maximum value, inner and inner-most values
; follow. 
; NOTE: Function removes parameters from the stack.
delay:
	pop r4		; return address
	pop r5
	pop r1		; outer loop index
	pop r2		; inner loop index
	pop r3		; inner-most loop index
	
	mov r21, r1
waitOuter:
	mov r22, r2
waitInner:
	mov r23, r3
waitInnermost:
	subi r23, $1
	breq continueInnermost
	rjmp waitInnermost
continueInnermost:
	subi r22, $1
	breq continueInner
	rjmp waitInner
continueInner:
	subi r21, $1
	breq continueOuter
	rjmp waitOuter
continueOuter:
	push r5		; restore return address
	push r4
	ret
	