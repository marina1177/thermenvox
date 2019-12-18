.include "m8515def.inc"

.def tmp	=	r16 
.def razr1	=	r17
.def razr2	=	r18
.def n		=	r19
.def freq	=	r20
.def amp	=	r21
.def wt		=	r22

.equ delay_time1 = 10;5
.equ delay_time2 = 255;255
.equ delay_time3 = 255;255
.equ delay_time4 = 5;5

rjmp reset 

.org 0x0004
rjmp TIM1_COMPA

reset: 

	init_stek:
		ldi		R16,LOW(RamEnd)
		out		SPL,R16
		ldi		R16,HIGH(RamEnd)
		out		SPH,R16

			  	  	; конфигурация B на ввод 
		clr		tmp
		out		DDRB,	tmp
			  		; конфигурация A на ввод
		clr		tmp
		out		DDRA, tmp

		cbi		PORTB, 5//Low_LDAC
		sbi		PORTB, 1//High_AB
		sbi		PORTB, 0//High_CS
		sbi		PORTB, 2//High_WR
		
		ldi n,0

	init_timer:
		cli	

		ser		tmp
		out		OCR1AH,tmp
		out		OCR1AL,tmp
	
		clr		tmp
		out		TCNT1H,tmp
		out		TCNT1L,tmp	
		
		;ldi tmp,0b0001001; биты предделения //+ сброс при совпадении;
		ldi		tmp,0b00001001
		out		TCCR1B,tmp

		ldi		tmp,0b01000000; маска прерываний по сравнению, ЗАПРЕТ ПЕРЕПОЛНЕНИЙ
		out		TIMSK,tmp

main: // Основная программа
		ldi		amp,255
		ldi		freq,40
		detect_freq://рассчитываю уставку(частоту синуса)
		cpi		freq, 128
		brsh	more_250Hz
		rjmp	less_250Hz


rjmp main

///////////////////////////////////////////////////
more_250Hz:
	cpi		freq, 255
	brsh	freq_1kHz
	
	clr		tmp;
	out		TCNT1H,tmp
	out		TCNT1L,tmp
	//500Hz
	ldi		tmp,0b00000000
	out		OCR1AH,	tmp
	ldi		tmp,0b01111101
	out		OCR1AL,	tmp
	sei		
	rjmp	loop

freq_1kHz:
	clr		tmp;
	out		TCNT1H,tmp
	out		TCNT1L,tmp

	ldi		tmp,0b00000000
	out		OCR1AH,	tmp
	ldi		tmp,0b00111111
	out		OCR1AL,	tmp
	sei		
	rjmp	loop

////////////////////////////////////////////////
less_250Hz:
	cpi		freq, 128
	brlo	freq_50Hz
	
	clr		tmp
	out		TCNT1H,tmp
	out		TCNT1L,tmp
	//250Hz
	ldi		tmp,0b00000000
	out		OCR1AH,	tmp
	ldi		tmp,0b11111010
	out		OCR1AL,	tmp
	sei		
	rjmp	loop

freq_50Hz:
	clr		tmp;
	out		TCNT1H,tmp
	out		TCNT1L,tmp

	ldi		tmp,0b00000100
	out		OCR1AH,	tmp
	ldi		tmp,0b11100010
	out		OCR1AL,	tmp
	sei		
	rjmp	loop
/////////////////////////////////////////////////

loop:
	cpi		n, 1
	breq	gen_sine
	rjmp	loop

gen_sine:
	cli
/////////////////////////////////////////////////////////	
	cbi		PORTB, 0//Low_CS
	rcall Delay
	rcall Delay
	cbi		PORTB, 2//Low_WR
	rcall Delay

	lpm tmp, Z+ 	// Загружаем значение из памяти программ
	out PORTB, tmp // Выводим на порт B
	
	sbi		PORTB, 2//High_WR
	rcall Delay
	rcall Delay
	sbi		PORTB, 0//High_CS
	rcall Delay
	rcall Delay
///////////////////////////////////////////////////////////

	dec		razr1 // Понижаем регистр razr1
	brne	detect_freq // Если razr1 не 0, переходим на выход
	cpi		razr2, 0 // Проверяем razr2 на 0
	breq	TIM1_OVF0 // Если равен 0 переходим по метке
	ldi		ZH, High(Sinus0*2) // Иначе загружаем начальный адрес ячейки нашей полуволны Sinus0 
	ldi		ZL, Low(Sinus0*2)
	ldi		razr2, 0 // razr2 будет = 0, то есть полуволна Sinus0 используется
	ldi		razr1, 180 // razr1 будет = 180, 180 значений в памяти


TIM1_OVF0:
ldi ZH, High(Sinus1*2) // Загружаем начальный адрес ячейки нашей полуволны Sinus1
ldi ZL, Low(Sinus1*2)
ldi razr2, 1 // razr2 будет = 1, то есть полуволна Sinus1 используется
ldi razr1, 180 // razr1 будет = 180, 180 значений в памяти
rjmp detect_freq



TIM1_COMPA: // Прерывание по переполнению таймера 1 
	ldi		n,0b00000001
	reti
/*
lpm tmp, Z+ // Загружаем значение из памяти программ
out PORTB, tmp // Выводим на порт D


dec razr1 // Понижаем регистр razr1
brne TIM1_OVF_Vix // Если razr1 не 0, переходим на выход
cpi razr2, 0 // Проверяем razr2 на 0
breq TIM1_OVF0 // Если равен 0 переходим по метке
ldi ZH, High(Sinus0*2) // Иначе загружаем начальный адрес ячейки нашей полуволны Sinus0 
ldi ZL, Low(Sinus0*2)
ldi razr2, 0 // razr2 будет = 0, то есть полуволна Sinus0 используется
ldi razr1, 180 // razr1 будет = 180, 180 значений в памяти


TIM1_OVF_Vix: // Зарядим регистры таймера примерно на 50Гц 
ldi tmp, 0xFF//частота синуса
out TCNT1H, tmp
ldi tmp, 0xCA
out TCNT1L, tmp
reti // Выйдем из прерывания
TIM1_OVF0:
ldi ZH, High(Sinus1*2) // Загружаем начальный адрес ячейки нашей полуволны Sinus1
ldi ZL, Low(Sinus1*2)
ldi razr2, 1 // razr2 будет = 1, то есть полуволна Sinus1 используется
ldi razr1, 180 // razr1 будет = 180, 180 значений в памяти
rjmp TIM1_OVF_Vix
*/


Delay:
		ser		wt
	DLY255:
		dec		wt
		brne	DLY255
		ret


Sinus0:
.db 1,1,1,1,1,1,2,2,2,3,3,3,4,4,5,5,6,7,7,8,9,9,10,11,12,13,14,15,16,17,18,19//32
.db 20,21,23,24,25,27,28,29,31,32,34,35,37,38,40,41,43,45,46,48,50,52,53,55//24
.db 57,59,61,63,65,66,68,70,72,74,76,78,80,82,85,87,89,91,93,95,97,99,102,104//24
.db 106,108,110,113,115,117,119,121,124,126,128,130,132,135,137,139,141,143//18
.db 146,148,150,152,154,157,159,161,163,165,167,169,171,174,176,178,180,182
.db 184,186,188,190,192,193,195,197,199,201,203,204,206,208,210,211,213,215
.db 216,218,219,221,222,224,225,227,228,229,231,232,233,235,236,237,238,239
.db 240,241,242,243,244,245,246,247,247,248,249,249,250,251,251,252,252,253
.db 253,253,254,254,254,255,255,255,255,255//10

Sinus1:
.db 255,255,255,255,255,255,254,254,254,253,253,253,252,252,251,251,250,249
.db 249,248,247,247,246,245,244,243,242,241,240,239,238,237,236,235,233,232
.db 231,229,228,227,225,224,222,221,219,218,216,215,213,211,210,208,206,204
.db 203,201,199,197,195,193,192,190,188,186,184,182,180,178,176,174,171,169
.db 167,165,163,161,159,157,154,152,150,148,146,143,141,139,137,135,132,130
.db 128,126,124,121,119,117,115,113,110,108,106,104,102,99,97,95,93,91,89,87
.db 85,82,80,78,76,74,72,70,68,66,65,63,61,59,57,55,53,52,50,48,46,45,43,41
.db 40,38,37,35,34,32,31,29,28,27,25,24,23,21,20,19,18,17,16,15,14,13,12,11
.db 10,9,9,8,7,7,6,5,5,4,4,3,3,3,2,2,2,1,1,1,1,1

