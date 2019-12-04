; STANDARD HEADER FILE
	PROCESSOR		16F876A
;---REGISTER FILES ���� ---
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
;---STATUS BITS ����---
IRP	 EQU	7
RP1	 EQU	6
RP0	 EQU	5
NOT_TO 	 EQU	4
NOT_PD 	 EQU	3
ZF 	 EQU	2 ;ZERO FLAG BIT
DC 	 EQU	1 ;DIGIT CARRY/BORROW BIT
CF 	 EQU	0 ;CARRY BORROW FLAG BIT
; -- INTCON BITS ���� --
; -- OPTION BITS ���� --
W 	 EQU	B'0' ; W ������ 0���� ����
F 	 EQU	.1   ; F ������ 1�� ����
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
;ISR ���� ����
	MOVWF	W_TEMP	
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP

	CALL	DISP	;DISPLAY �� ���α׷�

	SWAPF	STATUS_TEMP,W ; ����� �������� ����
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
; 7-segment�� ǥ�� ���ڰ� 2�ڸ��̹Ƿ� �� �ڸ��� ����������
; ǥ���ؾ��Ѵ�. ���� �� ���α׷��� ������ Ƚ���� Ȯ���Ͽ� ó�� �巯����
; ���� ���� ������ ��츦 �����Ͽ� �����ؾ��Ѵ�.
; <ó�� ���� ��> �� <���� ���� ��>�� �����ϱ�

DISP1;<ó�� ���� ��>
; D_10SEC ���� ������ MSD 7-segment�� ���õǵ��� �� ��			
	MOVLW	0
	MOVWF	PORTA	;���� OFF	
	MOVF	D_10SEC,W
	CALL	CONV
	MOVWF	PORTC
	MOVLW	B'00001000'
	MOVWF	PORTA
	
	INCF	HOHO,F
; key ���¿� ���� key_IN ������ �� �ֱ�
;	(00: key�� ����, 01: 1�� key, 02: 2�� key)
	RETURN
	
DISP2;<���� ���� ��>
; D_1SEC ���� ������ MSD 7-segment�� ���õǵ��� �� ��
			
	MOVLW	0
	MOVWF	PORTA	;���� OFF	
	MOVF	D_1SEC,W
	CALL	CONV
	MOVWF	PORTC
	MOVLW	B'00000100'
	MOVWF	PORTA
	INCF	HOHO,F
	INCF	INT_CNT,F
	RETURN

; main program ����
START_UP
	BSF 	STATUS,RP0 ; BANK�� 1�� ������
	MOVLW	B'00000000'; 
	MOVWF	TRISA
	MOVLW	B'00000111';
	MOVWF	ADCON1
	MOVLW	B'00000000'; 
	MOVWF	TRISC
; INTERRUPT �ð� ���� ---2.048msec �ֱ�
	MOVLW	B'00000010' ; 2.048msec
	MOVWF 	OPTIONR
	BCF	STATUS,RP0 ; BANK�� 0���� ����
	BSF	INTCON,5 ; TIMER INTERRUPT ENABLE
	BSF	INTCON,7 ; GOLBAL INT. ENABLE
	GOTO	MAIN_ST
; SUBROUTINE�� ���ʿ� �����ؾ���.

CONV	ANDLW	0FH	 ; W�� low nibble ���� ��ȯ����
	ADDWF	PCL,F	 ; PCL+��ȯ ���ڰ� --> PCL, PC�� ����ǹǷ� �� ��ɾ� ���� ���� ��ġ�� ����
	RETLW	B'00000011'; '0'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'10011111'; '1'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'00100101'; '2'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'00001101'; '3'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'10011001'; '4'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'01001001'; '5'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'01000001'; '6'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'00011011'; '7'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'00000001'; '8'�� ǥ���ϴ� ���� W�� ��
	RETLW	B'00001001'; '9'�� ǥ���ϴ� ���� W�� ��
MAIN_ST
; ���⼭���� USER PROGRAM �ۼ�
; ���� �ʱ�ȭ
	MOVLW	B'00000000'
	MOVWF	HOHO
	MOVWF	INT_CNT
	MOVWF	D_10SEC
	MOVWF	D_1SEC
	MOVWF	KEY_IN
M_LOOP
; interrupt�� ���� Ƚ�� Ȯ�� (�ð� ���) 

	MOVLW	.250
	SUBWF	INT_CNT,W
	BTFSS	STATUS,ZF
	GOTO	XLOOP
; 1�ʸ��� ������ �κ�
CK_LOOP

	CLRF	INT_CNT ; ���� 1�ʸ� ��ٸ��� ���� �ʱ�ȭ
	INCF	D_1SEC ; 1�� ���� ���� ����
	MOVLW	.10
	SUBWF	D_1SEC,W
	BTFSS	STATUS,ZF
	GOTO	XLOOP

; 10�ʸ��� ������ �κ�
	CLRF	D_1SEC ; ���� 10�ʸ� ��ٸ��� ���� �ʱ�ȭ
	INCF	D_10SEC ; 10�ʴ��� ���� ����
	MOVLW	.6
	SUBWF	D_10SEC,W
	BTFSC	STATUS,ZF
	CLRF	D_10SEC	;10�ʴ����� �ʱ�ȭ
	GOTO	XLOOP
 
; ������ �ð����� ����� ����� �����ϱ� ���� ���α׷� ����

XLOOP	
; key�� Ȯ���Ͽ� key�� ���� ��� ����
; ��ɿ� ���� ���� �︮�� ��

	GOTO	M_LOOP

END