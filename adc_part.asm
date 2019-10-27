.include "m8515def.inc"

.def	tmp = r16;
.def	data = r17
.def	select_ch = r18
.def	tmp_ch = r19
.def	n = r20

.equ	ch0 = 1
.equ	ch1 = 2

.equ	chn = 0
.equ	ncs = 4	    
.equ	miso = 6  
.equ	clk = 7		


rjmp main

.org 0x0008
rjmp SPI_interrapt


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
		ldi		tmp,	0b10011111	   
	    out		DDRB,	tmp	    ; PB0-control channel,PB4-NCS,PB5-MOSI,PB6-MISO,PB7-SCK
		
	select_channel: //опрос кнопок = выбор канала
	
		in		tmp,	PINA
		cpi		tmp, 	1
		breq 	set_ch0
		cpi		tmp,	2
		breq	set_ch1 
		rjmp	select_channel			

	set_ch0:
		
		ldi		tmp,	0b00110010       
	    out		PORTB,	tmp      
		rjmp	handle_spi

	set_ch1:
		ldi		tmp,	0b00110011       
	    out		PORTB,	tmp     
		rjmp	handle_spi

	handle_spi:

		cbi		PORTB,	ncs	;cs = 0
		sbi		PORTB,	chn	;DI(start bit) = 1
		
		sbi		PORTB,	clk	;UP CLK-1
		cbi		PORTB,	clk	;DOWN CLK-1
	
		sbic 	PORTB,	chn	;select channel(SGL/DIF)
		nop					;CH0
		cbi		PORTB,	chn	;CH1

		sbi		PORTB,	clk	;UP CLK-2
		cbi		PORTB,	clk	;DOWN CLK-2

		sbic 	PORTB,	chn	;select channel(ODD/SIGN)
		cbi		PORTB,	chn	;CH0
		nop					;CH1

		sbi		PORTB,	clk	;UP CLK-3
		cbi		PORTB,	clk	;DOWN CLK-3
		
		clr		n

	init_spi:
		
	    ldi		tmp,	0b00110011       
	    out		PORTB,	tmp     ;  

		ldi		tmp,	0b11010100; CPHA,SPIE,SPE,MSTR
		out		SPCR,	tmp; interrapt enable
		//clr		SPDR
		clr		data
		out		SPDR,	data	
		sei

	spi_loop: //опрос n
		
		sbrc	n,	0//пропуск если n == 0
		rjmp	out_data
		rjmp	spi_loop
	
	out_data:
		clr		n
		com		data
		out		PORTC,	data
	
		rjmp	select_channel
		
		
	SPI_interrapt:
		in	data, SPDR	 
		inc		n
		reti
	
