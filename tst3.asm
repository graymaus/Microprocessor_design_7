; STANDARD HEADER FILE
	PROCESSOR		16F876A
;---REGISTER FILES 선언 ---
;  BANK 0
INDF	 EQU	00H
TMR0	 EQU	01H
PCL	 EQU	02H
STATUS	 EQU	03H
FSR	 EQU	04H	
PORTA	 EQU	05H
PORTB	 EQU	06H
PORTC	 EQU	07H
EEDATA	 EQU	08H
EEADR	 EQU	09H
PCLATH	 EQU	0AH
INTCON	 EQU	0BH
; BANK 1
OPTIONR	 EQU	81H
TRISA	 EQU	85H
TRISB	 EQU	86H
TRISC	 EQU	87H
EECON1	 EQU	88H
EECON2	 EQU	89H
ADCON1	 EQU	9FH
;---STATUS BITS 선언---
IRP	 EQU	7
RP1	 EQU	6
RP0	 EQU	5
NOT_TO 	 EQU	4
NOT_PD 	 EQU	3
ZF 	 EQU	2 ;ZERO FLAG BIT
DC 	 EQU	1 ;DIGIT CARRY/BORROW BIT
CF 	 EQU	0 ;CARRY BORROW FLAG BIT
; -- INTCON BITS 선언 --
; -- OPTION BITS 선언 --
W 	 EQU	B'0' ; W 변수를 0으로 선언
F 	 EQU	.1   ; F 변수를 1로 선언
; --USER
INT_CNT	EQU	20H
D_10SEC	EQU	21H
D_1SEC	EQU	22H
KEY_IN	EQU	23H
W_TEMP   	EQU	24H
STATUS_TEMP EQU	25H
HOHO	EQU	26H
;MAIN PROGRAM
	ORG	0000
	GOTO	START_UP
	ORG	4
;ISR 시작 번지
	MOVWF	W_TEMP	
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP

	CALL	DISP	;DISPLAY 부 프로그램

	SWAPF	STATUS_TEMP,W ; 저장된 내용으로 복원
	MOVWF	STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W
	BCF	INTCON,2
	RETFIE
	
;DISPLAY ROUTINE
DISP
	BTFSC	HOHO,0
	GOTO	DISP2
	GOTO	DISP1

DISP1
	MOVLW	B'11111110' ;DOT 표시하긩
	MOVWF	PORTC
	MOVLW	B'00001000'
	MOVWF	PORTA
	INCF	INT_CNT,F
	RETURN
	
DISP2			
	MOVLW	0
	MOVWF	PORTA	;전부 OFF	
	INCF	INT_CNT,F
	RETURN

; main program 시작
START_UP
	BSF 	STATUS,RP0 ; BANK를 1로 변경함
	MOVLW	B'00000000'; 
	MOVWF	TRISA
	MOVLW	B'00000111';
	MOVWF	ADCON1
	MOVLW	B'00000000'; 
	MOVWF	TRISC
; INTERRUPT 시간 설정 ---2.048msec 주기
	MOVLW	B'00000010' ; 2.048msec
	MOVWF 	OPTIONR
	BCF	STATUS,RP0 ; BANK를 0으로 변경
	BSF	INTCON,5 ; TIMER INTERRUPT ENABLE
	BSF	INTCON,7 ; GOLBAL INT. ENABLE
	GOTO	MAIN_ST
; SUBROUTINE을 앞쪽에 선언해야함.

MAIN_ST
; 여기서부터 USER PROGRAM 작성
; 변수 초기화
	MOVLW	B'00000000'
	MOVWF	HOHO
	MOVWF	INT_CNT
	MOVWF	D_10SEC
	MOVWF	D_1SEC
	MOVWF	KEY_IN
M_LOOP
; interrupt가 들어온 횟수 확인 (시간 계수) 

	MOVLW	.244
	SUBWF	INT_CNT,W
	BTFSS	STATUS,ZF
	GOTO	XLOOP
; 1초마다 들어오는 부분
CK_LOOP

	CLRF	INT_CNT ; 다음 1초를 기다리기 위한 초기화
	INCF	HOHO,F ; 1초 단위 변수 증가
	GOTO	XLOOP

 
; 나머지 시간동안 사용자 기능을 수행하기 위한 프로그램 영역

XLOOP	
; key를 확인하여 key에 따른 기능 수행
; 기능에 따른 부저 울리기 등

	GOTO	M_LOOP

END