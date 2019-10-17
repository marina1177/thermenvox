.include "m8515def.inc"

.def flgs = r16;
.def chn = r17
.def data_ch0 = r18
.def data_ch1 = r19
.def n = r20

.equ  ncs =		4	    ; 
.equ  selch =	0		; 
.equ  miso =	6  	; 
.equ  clk =		7		;


rjmp main

.org 0x0008
rjmp SPI_interrapt


main:
	cli
	init_stek:
		ldi R16,LOW(RamEnd)
		out SPL,R16
		ldi R16,HIGH(RamEnd)
		out SPH,R16
	init_spi:
		ldi   R16,0b10011111	   
	    out   DDRB,R16	    ; PB0-control channel,PB4-NCS,PB6-MISO, PB5-MOSI,PB7-SCK
	    ldi   R16,0b00110011       
	    out   PORTB,R16     ;  

		ldi R16,0b11010100; CPHA,SPIE,SPE,MSTR
		out		SPCR,	R16; interrapt enable	
		sei
	
		cli flgs; f0 - ch0/1, f1 - channel count

	select_channel:
		cpi		flgs,	2
		breq	transfer_data ;both registers are full
		rjmp	rvrs_ch			
			

	start_spi:

		cbi		PORTB,	ncs	;cs = 0
		sbi		PORTB,	chn	;DI(start bit) = 1
		
		sbi		PORTB,	clk	;UP CLK-1
		cbi		PORTB,	clk	;DOWN CLK-1
	
		sbic 	PORTB, 0	;select channel(SGL/DIF)
		nop					;CH0
		cbi		PORTB, chn	;CH1

		sbi		PORTB, clk	;UP CLK-2
		cbi		PORTB, clk	;DOWN CLK-2

		sbic 	PORTB, 0	;select channel(ODD/SIGN)
		cbi		PORTB, 0	;CH0
		nop					;CH1

		sbi		PORTB, clk	;UP CLK-3
		cbi		PORTB, clk	;DOWN CLK-3

	spi_loop:

		sbi		PORTB,	clk	;UP CLK
		cbi		PORTB,	clk	;DOWN CLK

		sbrc	flgs,	0	;пропуск если flgs0 = 0
		rjmp	start_spi	;
		rjmp	spi_loop				

		ret




SPI_interrapt:
	
	sbi		PORTB,	ncs	;cs = 1

	sbic	PORTB0,	0	
	rjmp	solve_0

	sbis	PORTB0, 0
	rjmp	solve_1	

	solve_0:
		
		inc		flgs;если выбран ch0 -> flgs = 1;
		in		data_ch0, SPDR
		rjmp	next	

	solve_1:
		
		inc		flgs		;если выбран ch1 -> flgs = 2;
		in		data_ch1, SPDR
		rjmp	next	
	
	next:
		reti
	
		





	
		
		



	
