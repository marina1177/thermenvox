.include "m8515def.inc"

.def	tmp = r16;
.def	wt = r17


rjmp main

main:
		cli
	init_stek:
		ldi		R16,LOW(RamEnd)
		out		SPL,R16
		ldi		R16,HIGH(RamEnd)
		out		SPH,R16

		  	  	; конфигурация A на ввод 
		clr		tmp
		out		DDRA, tmp

			  	; конфигурация C на вывод 
		ser		tmp
		out		DDRC, tmp
				; конфигурация B
		ser		tmp
	    out		DDRB,	tmp	    ; PB0-control channel,PB4-NCS,PB5-MOSI,PB6-MISO,PB7-SCK
		
	fall:
		out		PORTB,	tmp
		call	Delay
		dec		tmp
		brne	fall

	rise:
		out		PORTB,	tmp
		call	Delay
		inc		tmp
		cpi		tmp,	0xff
		brne	rise

		out		PORTB,	tmp
		rjmp	fall

	Delay:
		ser		wt
	DLY255:
		dec		wt
		brne	DLY255
		ret


	







		
