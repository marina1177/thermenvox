.include "m8515def.inc"


.def chn = r17
.def cnt = r18
.def t1 = r19

.equ  ncs =		4	    ; 
.equ  selch =	0		; 
.equ  miso =	6  	; 
.equ  clk =		7		;


rjmp main

.org 0x0008
rjmp SPI_


main:
	cli
	init_stek:
		ldi R16,LOW(RamEnd)
		out SPL,R16
		ldi R16,HIGH(RamEnd)
		out SPH,R16
	init_spi:
		ldi   t1,0b10011111	   
	    out   DDRB,t1	    ; PB0-control channel,PB4-NCS,PB6-MISO, PB5-MOSI,PB7-SCK
	    ldi   t1,0b00110011       
	    out   PORTB,t1      ;  
	    
	start:
		ldi t1,0b11010000; SPIE,SPE,
		out		SPCR,	t1; interrapt enable	

		cbi		PORTB, ncs	;cs = 0
		sbi		PORTB, chn	;DI(start bit) = 1
		sbi		PORTB, clk	;UP CLK
		sbic 	PORTB, 0	;select channel(SGL/DIF)
		nop					;CH0
		cbi		PORTB, chn	;CH1
		cbi		PORTB, clk	;DOWN CLK
		sbic 	PORTB, 0	;select channel(ODD/SIGN)
		cbi		PORTB, 0	;CH0
		nop					;CH1






read_adc:	;
		
	ldi   cnt,8		;
	sbi   PortB, ncs  ;cs
	nop
	sbi   PortB,convst
	Busy1:
		sbic  PINB,busy     ;
		rjmp  Busy1
	spi_loop:
		lsl   hexL
		rol   hexH
		sbi   PortB,sck
		cbi   PortB,sck
		sbic  PINB,miso
		inc hexL
		dec   Cnt
		brne  spi_loop
ret		
	
		
		



	
