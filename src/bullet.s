.include "globals.inc"

.export move_bullets
.export write_bullets

.segment "RODATA"
nt_y_range:
.repeat 4, i
    .byt (224 / 4) * i + 16
.endrepeat

.segment "CODE"

.proc write_bullets
ptr = 0
or_bits = 2
buffer_index = 3
y_range = 4
    ; Zero the buffer
    ldx #0
    lda #0
:
    sta zp_nt_buffer, x
    inx
    cpx #224
    bne :-

    ; Find y range
    lda frame_number
    and #%00000011
    tax
    lda nt_y_range, x
    sta y_range

    ldx #0
    cpx num_bullets
    beq return
loop:
    lda #%00010000 << 2
    sta or_bits

    lda bullet_y, x
    sec
    sbc y_range
    bcc next_iteration
    cmp #224 / 4
    bcs next_iteration
    sta buffer_index
    and #%00000100
    beq :+
    lda #%00000001 << 2
    sta or_bits
:
    lda buffer_index
    and #%00111000
    asl
    asl
    sta buffer_index

    lda bullet_x, x
    lsr
    lsr
    lsr
    ora buffer_index
    tay
    lda or_bits
    bcs :+
    asl
:
    ora zp_nt_buffer, y
    sta zp_nt_buffer, y
next_iteration:

    lda #%00010000 << 0
    sta or_bits

    ldy bullet_dir, x
    lda bullet_y, x
    sec
    sbc bullet_sin_table, y
    sec
    sbc y_range
    bcc next_iteration2
    cmp #224 / 4
    bcs next_iteration2
    sta buffer_index
    and #%00000100
    beq :+
    lda #%00000001 << 0
    sta or_bits
:
    lda buffer_index
    and #%00111000
    asl
    asl ; Clears carry
    sta buffer_index

    lda bullet_x, x
    sec
    sbc bullet_cos_table, y
    lsr
    lsr
    lsr
    ora buffer_index
    tay
    lda or_bits
    bcs :+
    asl
:
    ora zp_nt_buffer, y
    sta zp_nt_buffer, y
next_iteration2:

    inx
    cpx num_bullets
    bne loop
return:
    rts
.endproc

.proc move_bullets
ptr = 0
    lda num_bullets
    bne :+
    rts
:
    ldx #0
loop:

.repeat 2, i
.scope 
    clc
    ldy bullet_dir, x
    lda bullet_sin_table, y
    bmi @negativeDY
    adc bullet_y, x
    bcc @doneAddY
:
    jmp removeBullet
@negativeDY:
    adc bullet_y, x
    bcc :-
@doneAddY:
    cmp #240
    bcs :-
    sta bullet_y, x

    clc
    ldy bullet_dir, x
    lda bullet_cos_table, y
    bmi @negativeDX
    adc bullet_x, x
    bcc @doneAddX
    bcs removeBullet
@negativeDX:
    adc bullet_x, x
    bcc removeBullet
@doneAddX:
    sta bullet_x, x
.endscope
.endrepeat

    inx
nextBullet:
    cpx num_bullets
    bne loop
    rts
removeBullet:
    ldy num_bullets
    dey
    lda bullet_x, y
    sta bullet_x, x
    lda bullet_y, y
    sta bullet_y, x
    lda bullet_dir, y
    sta bullet_dir, x
    sty num_bullets
    jmp nextBullet
.endproc
