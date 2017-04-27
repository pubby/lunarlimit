.include "globals.inc"

.import alloc_bitset8
.import random_byte
.import sin, cos, atan, aim_at
.import FamiToneSfxPlay
.importzp FT_SFX_CH0, FT_SFX_CH1
.export move_enemies, think_enemies
.export update_explosions
.export load_wave, update_waves

.proc move_enemies
x_iter = 0
xv = 1
yv = 2
    lda num_enemies
    bne :+
    rts
:
    ldx #0
loop:

    lda player_shield
    bne shield

    clc
    ldy enemy_dir, x
    lda enemy_x_sub, x
    adc enemy_cos_table_sub, y
    sta enemy_x_sub, x
    lda enemy_x_lo, x
    adc enemy_cos_table_lo, y
    sta enemy_x_lo, x
    lda enemy_x_hi, x
    adc enemy_cos_table_hi, y
    sta enemy_x_hi, x

    clc
    lda enemy_y_sub, x
    adc enemy_sin_table_sub, y
    sta enemy_y_sub, x
    lda enemy_y_lo, x
    adc enemy_sin_table_lo, y
    sta enemy_y_lo, x
    lda enemy_y_hi, x
    adc enemy_sin_table_hi, y
    sta enemy_y_hi, x
    cmp #128
    bne doneCollisions

    lda enemy_x_hi, x
    cmp #128
    bne doneCollisions

    ; Collision checks
    lda player_invuln
    beq noShield
    bne :+
shield:
    lda enemy_x_hi, x
    cmp #128
    bne doneCollisions

    lda enemy_y_hi, x
    cmp #128
    bne doneCollisions
:

    lda player_x
    sec
    sbc enemy_x_lo, x
    sbc #8-1
    adc #8+8-1
    bcc noShield

    lda player_y
    sbc enemy_y_lo, x
    sbc #8-1
    adc #8+8-1
    bcc noShield
    jmp delete2
noShield:

    lda pbullet_bitset
    beq doneCollisions
    ldy #$FF
collisionLoop:
:
    iny
    lsr
    bcc :-
    sta subroutine_temp

    lda pbullet_x, y
    sbc enemy_x_lo, x
    sbc #8-1
    adc #8+8-1
    bcc noCollision

    lda pbullet_y, y
    sbc enemy_y_lo, x
    sbc #8-1
    adc #8+8-1
    bcc noCollision
    jmp delete

noCollision:
    lda subroutine_temp
    bne collisionLoop
doneCollisions:
    inx
afterDeleted:
    cpx num_enemies
    beq return
    jmp loop
return:
    rts
delete:
    ; Delete the bullet
    lda powers_of_2_table, y
    eor pbullet_bitset
    sta pbullet_bitset

    ; Try spawn a powerup
    lda powerup_type
    bne donePowerup
    jsr random_byte
    and #%00000111
    bne donePowerup
    jsr random_byte
    and #%00000011
    clc
    adc #POW_1UP
    sta powerup_type
    lda enemy_x_lo, x
    sta powerup_x
    lda enemy_y_lo, x
    sta powerup_y
    lda #0
    sta powerup_xsub
    sta powerup_ysub
donePowerup:

delete2:
    ; Create an explosion

    lda enemy_x_lo, x
    sta xv
    lda enemy_y_lo, x
    sta yv

    stx x_iter
    lda explosion_bitset
    jsr alloc_bitset8
    bcs doneExplosion
    sta explosion_bitset
    lda xv
    sec
    sbc #8
    sta explosion_x, x
    lda yv
    sec
    sbc #8
    sta explosion_y, x
    lda #16
    sta explosion_timer, x
    lda #1
    sta explosion_palette, x
doneExplosion:
    ldx x_iter

    ; Increment score.
    lda menu
    bne doneSetScore
    sec
    .repeat 4, i
        lda score+i
        adc #0
        sta score+i
        cmp #10
        bcc doneSetScore
        lda #0
        sta score+i
    .endrepeat
doneSetScore:

    ; Delete the enemy
    ldy num_enemies
    dey
    lda enemy_x_sub, y
    sta enemy_x_sub, x
    lda enemy_x_lo, y
    sta enemy_x_lo, x
    lda enemy_x_hi, y
    sta enemy_x_hi, x
    lda enemy_y_sub, y
    sta enemy_y_sub, x
    lda enemy_y_lo, y
    sta enemy_y_lo, x
    lda enemy_y_hi, y
    sta enemy_y_hi, x
    lda enemy_dir, y
    sta enemy_dir, x
    lda enemy_timer, y
    sta enemy_timer, x
    lda enemy_ammo, y
    sta enemy_ammo, x
    lda enemy_type, y
    sta enemy_type, x
    sty num_enemies

    sty subroutine_temp
    txa
    and #1
    ora #2
    ldx #FT_SFX_CH0
    jsr FamiToneSfxPlay
    ldx x_iter
    ldy subroutine_temp

    jmp afterDeleted
.endproc

.proc think_enemies
x_iter = 0
x_sign_ext = 1
y_sign_ext = 2
dir_to_player = 3
enemy_x_temp = 1
enemy_y_temp = 2
    lda frame_number
    alr #%100
    lsr
    tax
    cpx num_enemies
    bcc loop
    rts
loop:
    stx x_iter

    lda player_shield
    beq :+
    jmp doneDirChange
:
    lda enemy_ammo, x
    bmi retreat

    ; First calculate direction to player
    lda enemy_x_lo, x
    sta subroutine_temp
    ldy enemy_x_hi, x
    lda player_x
    ldx #128
    jsr aim_at
    sty x_sign_ext
    stx trig_dx+0
    sta trig_dx+1

    ldx x_iter
    lda enemy_y_lo, x
    sta subroutine_temp
    ldy enemy_y_hi, x
    lda player_y
    ldx #128
    jsr aim_at
    sty y_sign_ext
    stx trig_dy+0
    sta trig_dy+1
    jmp doAtan
retreat:
    ; enemy_ammo is in A
    ldy enemy_timer, x
    bne :+
    sec
    sbc #16
    bmi :+
    jsr random_byte
    and #%00000011
    ora #1
:
    sta enemy_ammo, x

    lda player_x
    sta subroutine_temp
    ldy #128
    lda enemy_x_hi, x
    tax
    lda enemy_x_lo, x
    jsr aim_at
    sty x_sign_ext
    stx trig_dx+0
    sta trig_dx+1

    ldx x_iter
    lda player_y
    sta subroutine_temp
    ldy #128
    lda enemy_y_hi, x
    tax
    lda enemy_y_lo, x
    jsr aim_at
    sty y_sign_ext
    stx trig_dy+0
    sta trig_dy+1
doAtan:
    jsr atan
    sta subroutine_temp

    bit x_sign_ext
    bpl :+
    lda #128
    sec
    sbc subroutine_temp
:

    bit y_sign_ext
    bpl :+
    eor #$FF
    clc
    adc #1
:
    sta dir_to_player

    ; Compare enemy_dir to dir_to_player.
    ldx x_iter
    sec
    sbc enemy_dir, x
    cmp #128
    bcs otherTurn
    cmp #16
    bcc dirAligned
    lda enemy_dir, x
    adc #12-1 ; Carry set
    sta enemy_dir, x
    jmp doneDirChange
otherTurn:
    lda enemy_dir, x
    sec
    sbc dir_to_player
    cmp #16
    bcc dirAligned
    lda enemy_dir, x
    sbc #12 ; Carry set
    sta enemy_dir, x
doneDirChange:
    jmp doneShoot
dirAligned:

    ; Try to shoot a bullet
    lda enemy_timer, x
    bne doneShoot
    lda enemy_ammo, x
    bmi doneShoot
    lda enemy_x_hi, x
    cmp #128
    bne doneShoot
    lda enemy_y_hi, x
    cmp #128
    bne doneShoot
    ldy num_bullets
    cpy #BULLETS_MAX
    bcs doneShoot
    dec enemy_ammo, x
    lda enemy_x_lo, x
    adc #4 ; carry cleared (bcs)
    sta enemy_x_temp
    lda enemy_y_lo, x
    clc
    adc #4
    sta enemy_y_temp
    lda dir_to_player
    sta bullet_dir, y
    tax
    ; Calc y
    lda bullet_sin_table, x
    asl
    clc
    bpl :+
    adc enemy_y_temp
    bcc doneShoot
    bcs :++
:
    adc enemy_y_temp
    bcs doneShoot
:
    sta bullet_y, y
    ; Calc x
    lda bullet_cos_table, x
    asl
    clc
    bpl :+
    adc enemy_x_temp
    bcc doneShoot
    bcs :++
:
    adc enemy_x_temp
    bcs doneShoot
:
    sta bullet_x, y
    iny
    sty num_bullets
    ldx x_iter
    jsr random_byte
    ora #$0F
    sta enemy_timer, x
doneShoot:
    lsr enemy_timer, x

    inx
    inx
    cpx num_enemies
    bcs return
    jmp loop
return:
    rts
.endproc

.proc update_explosions
iteration_bitset = 0
    lda explosion_bitset
    beq return
    ldx #$FF
loop:
:
    inx
    lsr
    bcc :-
    sta iteration_bitset

    dec explosion_timer, x
    bne :+
    lda explosion_bitset
    eor powers_of_2_table, x
    sta explosion_bitset
:

    lda iteration_bitset
    bne loop
return:
    rts
.endproc

.proc load_wave
type = 0
    ldy #0
    lda (ptr_temp), y
    sta subroutine_temp

    ldx num_enemies
    iny
    lda (ptr_temp), y
    beq return
    clc
    adc num_enemies
    cmp #ENEMIES_MAX
    bcc :+
    lda #ENEMIES_MAX
:
    sta num_enemies
    cpx num_enemies
    beq return
    
    jsr random_byte
    and #%00000011
    cmp #3
    bcc :+
    lda #2
:
    sta type
loop:
    lda subroutine_temp
    sta enemy_dir, x
    lda #0
    sta enemy_x_sub, x
    sta enemy_y_sub, x
    jsr random_byte
    sta enemy_timer, x
    lda #2
    sta enemy_ammo, x
    lda type
    sta enemy_type, x
    iny
    lda (ptr_temp), y
    sta enemy_x_lo, x
    iny
    lda (ptr_temp), y
    sta enemy_x_hi, x
    iny
    lda (ptr_temp), y
    sta enemy_y_lo, x
    iny
    lda (ptr_temp), y
    sta enemy_y_hi, x
    inx
    cpx num_enemies
    bne loop
return:
    rts
.endproc

.proc update_waves
    lda player_invuln
    bne return
    lda num_enemies
    cmp #16
    bcs return
    asl
    cmp wave_number
    beq :+
    bcs return
:
    ldx wave_number
    lda wave_lo, x
    sta ptr_temp+0
    lda wave_hi, x
    sta ptr_temp+1
    inx
    txa
    cmp #64
    bcc :+
    lda #32
:
    sta wave_number
    jmp load_wave
return:
    rts
.endproc
