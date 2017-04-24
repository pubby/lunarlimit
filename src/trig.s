.include "globals.inc"

.export sin
.export cos
.export atan
.export aim_at

.segment "CODE"

; Takes input angle in A and returns [-127, 127] result in A.
; Clobbers A, Y. Preserves X.
.proc sin
    sta subroutine_temp
    alr #%01111111
    tay
    lda sin_table, y
    bcc noMidpoint
    iny
    clc
    adc sin_table, y
    ror
noMidpoint:
    bit subroutine_temp
    bpl :+
    eor #$FF
    clc
    adc #1
:
    rts
.endproc

; Takes input angle in A and returns [-127, 127] result in A.
; Clobbers A, Y. Preserves X.
.proc cos
    clc
    adc #256 / 4
    jmp sin
.endproc

; Returns atan lookup table in A and table index in X,
; based on the values in (trig_dx, trig_dy).
; Clobbers A, X. Preserves Y. Clobbers trig_dx, trig_dy.
.proc atan
    ; dy
    lda trig_dy+1
    bne :+
    lda trig_dy+0
    jmp @startShiftDy0
:
    lsr
    ror trig_dy+0
    lsr trig_dx+1
    ror trig_dx+0
    tax                 ; Use this to set the zero flag (if A == 0)
    bne :-
    ; Done with dy+1, but we're not going to 'sta dy+1'.
    lda trig_dy+0
:
    lsr
    lsr trig_dx+1
    ror trig_dx+0
@startShiftDy0:
    cmp #%00010000
    bcs :-
    sta trig_dy+0

    ; We're done shifting dy+1 in A, but we're not going to 'sta dy+1',
    ; because there's no need for dy+1 after this.

    ; dx
    lda trig_dx+1
    bne :+
    lda trig_dx+0
    jmp @startShiftDx0
:
    lsr
    ror trig_dx+0
    lsr trig_dy+0
    tax
    bne :-
    ; Done with dx+1, but we're not going to 'sta dx+1'.
    lda trig_dx+0
:
    lsr
    lsr trig_dy+0
@startShiftDx0:
    cmp #%00010000
    bcs :-
    ldx trig_dy+0
    ora asl4_table, x
    tax
    lda atan_table, x
    rts
.endproc

; In:
;   A = lobyte of x/y-position (FROM)
;   X = hibyte of x/y-position (FROM)
;  ST = lobyte of x/y-position (TO)
;   Y = hibyte of x/y-position (TO)
; Out:
;   Y = sign
;   X = lobyte
;   A = hibyte
; Clobbers A, X, Y.
.proc aim_at
    sec
    sbc subroutine_temp
    pha
    sty subroutine_temp
    txa
    ldx #0
    sbc subroutine_temp
    tay
    bpl :+
    dex
:
    stx subroutine_temp
    cpx #$FF
    pla
    eor subroutine_temp
    adc #0
    tax
    tya
    eor subroutine_temp
    adc #0
    ldy subroutine_temp
    rts
.endproc
