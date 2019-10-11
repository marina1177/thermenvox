.include "m8515def.inc"


.def hex = r16     ;  ���� 8-������� �����
.def n = r17
.def cnt = r18
.def t1 = r19

.equ  convst= 0	    ; 
.equ  busy =  1		; 
.equ  miso  = 6  	; 
.equ  sck =   7		;



rjmp main

.org 0x0008
rjmp SPI_


main:

	init_stek:
		ldi R16,LOW(RamEnd)
		out SPL,R16
		ldi R16,HIGH(RamEnd)
		out SPH,R16
	init_spi:
	    ldi   t1,0b00110011       
	    out   PORTB,t1      ;  
	    ldi   t1,0b10000001	   
	    out   DDRB,t1	    ; PB0-convst,PB1-busy,PB6-MISO,PB7-SCK


read_adc:	;
		
	ldi   cnt,8		;
	cbi   PortB,convst  ;
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
	
		
		



	
