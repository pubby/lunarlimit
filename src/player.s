.include "globals.inc"

.import sin, cos
.import alloc_bitset8
.import FamiToneSfxPlay
.importzp FT_SFX_CH0, FT_SFX_CH1, FT_SFX_CH2
.export update_player
.export update_stars
.export respawn_player
.export reset_play

.segment "CODE"

.proc reset_play
    lda #0
    sta num_bullets
    sta pbullet_bitset
    sta explosion_bitset
    sta num_enemies
    sta sprite_hit
    sta powerup_type
    sta player_dir
    sta wave_number
    .repeat 4, i
        sta score+i
    .endrepeat
    lda #3
    sta player_life
    rts
.endproc

.proc respawn_player
    lda #128-4
    sta player_x
    lda #120-4
    sta player_y

    lda #120
    sta respawn

    lda #120
    sta player_invuln

    lda #0
    sta player_powerup
    sta player_rapid
    sta player_shield
    sta player_bomb

    rts
.endproc

.proc move_player
    lda buttons_held
    and #BUTTON_LEFT
    beq notPressingLeft
    lda player_x 
    cmp #8+2
    bcs :+
    lda #8+3
:
    sbc #2
    sta player_x
notPressingLeft:

    lda buttons_held
    and #BUTTON_RIGHT
    beq notPressingRight
    lda player_x 
    cmp #256-16
    bcc :+
    lda #256-16-3
:
    adc #2
    sta player_x
notPressingRight:

    lda buttons_held
    and #BUTTON_UP
    beq notPressingUp
    lda player_y 
    cmp #32+2
    bcs :+
    lda #32+3
:
    sbc #2
    sta player_y
notPressingUp:

    lda buttons_held
    and #BUTTON_DOWN
    beq notPressingDown
    lda player_y 
    cmp #240-24
    bcc :+
    lda #240-24-3
:
    adc #2
    sta player_y
notPressingDown:
    rts
.endproc

.proc update_player
    lda respawn
    beq :+
    lsr
    lsr
    lsr
    eor #$FF
    clc
    adc respawn
    sta respawn
:

    lda player_bomb
    cmp #16
    bcs notMoving
    jsr move_player
notMoving:

    lda buttons_held
    and #BUTTON_A
    beq notPressingA
    lda player_dir
    clc
    adc #4
    sta player_dir
notPressingA:

    lda buttons_held
    and #BUTTON_B
    beq notPressingB
    lda player_dir
    sec
    sbc #4
    sta player_dir
notPressingB:


    ; Check collisions
    lda player_invuln
    bne invuln
    lda player_shield
    bne notHit
    lda sprite_hit
    beq notHit

    lda #$16
    sta bgcol
    lda #$06
    sta bgcol_next

    ; Create an explosion
    lda explosion_bitset
    jsr alloc_bitset8
    bcs doneExplosion
    sta explosion_bitset
    lda player_x
    sec
    sbc #8
    sta explosion_x, x
    lda player_y
    sec
    sbc #8
    sta explosion_y, x
    lda #16
    sta explosion_timer, x
    lda #1
    sta explosion_palette, x
    ; Decrease life and shit
    dec player_life
    bne :+
    lda #MENU_GAMEOVER
    sta menu
    lda #0
    sta pbullet_bitset
:
    lda #7
    ldx #FT_SFX_CH2
    jsr FamiToneSfxPlay
    jsr respawn_player
    jmp updateBullets
invuln:
    dec player_invuln
doneExplosion:
notHit:
    lda #0
    sta sprite_hit

    lda buttons_pressed
    and #BUTTON_SELECT
    beq notPressingSelect
    lda player_powerup
    beq notPressingSelect
    cmp #POW_RAPID
    bne :+
    lda #$FF
    sta player_rapid
    lda #5
    ldx #FT_SFX_CH2
    jsr FamiToneSfxPlay
    jmp usedPowerUp
:
    cmp #POW_BOMB
    bne :+
    lda #0
    sta num_enemies
    sta num_bullets
    lda #48
    sta player_bomb
    lda #4
    ldx #FT_SFX_CH2
    jsr FamiToneSfxPlay
    ; create a bomb explosion
    lda explosion_bitset
    jsr alloc_bitset8
    bcs usedPowerUp
    sta explosion_bitset
    lda player_x
    sec
    sbc #8
    sta explosion_x, x
    lda player_y
    sec
    sbc #8
    sta explosion_y, x
    lda #14
    sta explosion_timer, x
    lda #1
    sta explosion_palette, x
    jmp usedPowerUp
:
    cmp #POW_SHIELD
    bne :+
    lda #$FF
    sta player_shield
    lda #5
    ldx #FT_SFX_CH2
    jsr FamiToneSfxPlay
:
usedPowerUp:
    lda #0
    sta player_powerup
notPressingSelect:

    ; Decrease powerups
    lda frame_number
    and #%1
    bne skipDecrease
    ldx player_rapid
    beq :+
    dex
    stx player_rapid
:
skipDecrease:
    ldx player_shield
    beq :+
    dex
    stx player_shield
:
    ldx player_bomb
    beq :+
    dex
    stx player_bomb
:


    ; Powerup collision checks
    lda powerup_type
    beq noPowerUpCollision

    lda player_x
    sbc powerup_x
    sbc #8-1
    adc #8+8-1
    bcc noPowerUpCollision

    lda player_y
    sbc powerup_y
    sbc #8-1
    adc #8+8-1
    bcc noPowerUpCollision

    lda powerup_type
    cmp #POW_1UP
    bne not1Up
    lda player_life
    cmp #9
    bcs :+
    inc player_life
    jmp donePowerUp
:
    ; Increment score.
    sec
    .repeat 3, i
        lda score+i+1
        adc #0
        sta score+i+1
        cmp #10
        bcc donePowerUp
        lda #0
        sta score+i+1
    .endrepeat
    jmp donePowerUp
not1Up:
    sta player_powerup
donePowerUp:
    lda #0
    sta powerup_type
    lda #6
    ldx #FT_SFX_CH2
    jsr FamiToneSfxPlay
noPowerUpCollision:

    ; Fire bullets
    lda player_bomb
    bne doneFireBullet
    lda player_invuln
    cmp #32
    bcs doneFireBullet
    lda frame_number
    and #%00000111
    ldx player_rapid
    beq :+
    and #%00000011
:
    tax
    bne doneFireBullet
    lda pbullet_bitset
    jsr alloc_bitset8
    bcs doneFireBullet
    sta pbullet_bitset

    lda player_dir
    jsr cos
    .repeat 4
        cmp #$80
        ror
    .endrepeat
    cmp #$80
    adc player_x
    sta pbullet_x, x
    lda player_dir
    jsr sin
    .repeat 4
        cmp #$80
        ror
    .endrepeat
    cmp #$80
    adc player_y
    sta pbullet_y, x
    lda player_dir
    sta pbullet_dir, x

    lda frame_number
    and #1
    ldx #FT_SFX_CH1
    jsr FamiToneSfxPlay
doneFireBullet:

updateBullets:
    ldx #$FF
    lda pbullet_bitset
    beq return
loop:
:
    inx
    lsr
    bcc :-
    pha

    lda pbullet_dir, x
    jsr cos
    .repeat 4
        cmp #$80
        ror
    .endrepeat
    ldy player_rapid
    bne :+
    cmp #$80
    ror
:
    cmp #$80
    bcs :+
    adc pbullet_x, x
    bcs destroyBullet
    cmp #256-8
    bcs destroyBullet
    bcc :++
:
    adc pbullet_x, x
    bcc destroyBullet
:
    sta pbullet_x, x

    lda pbullet_dir, x
    jsr sin
    .repeat 4
        cmp #$80
        ror
    .endrepeat
    ldy player_rapid
    bne :+
    cmp #$80
    ror
:
    cmp #$80
    bcs :+
    adc pbullet_y, x
    bcs destroyBullet
    bcc :++
:
    adc pbullet_y, x
    bcc destroyBullet
:
    cmp #240
    bcs destroyBullet
    sta pbullet_y, x

continueLoop:
    pla
    bne loop
return:
    rts
destroyBullet:
    lda powers_of_2_table, x
    eor pbullet_bitset
    sta pbullet_bitset
    jmp continueLoop
.endproc

.proc update_stars
    lda #128
    clc
    adc player_dir
    tax
.repeat 5, i
    clc
    lda large_star_cos_table_sub, x
    adc large_star_xsub+i
    sta large_star_xsub+i
    lda large_star_cos_table_lo, x
    adc large_star_x+i
    sta large_star_x+i

    clc
    lda large_star_sin_table_sub, x
    adc large_star_ysub+i
    sta large_star_ysub+i
    lda large_star_sin_table_lo, x
    adc large_star_y+i
    sta large_star_y+i

    clc
    lda medium_star_cos_table_sub, x
    adc medium_star_xsub+i
    sta medium_star_xsub+i
    lda medium_star_cos_table_lo, x
    adc medium_star_x+i
    sta medium_star_x+i

    clc
    lda medium_star_sin_table_sub, x
    adc medium_star_ysub+i
    sta medium_star_ysub+i
    lda medium_star_sin_table_lo, x
    adc medium_star_y+i
    sta medium_star_y+i

    clc
    lda small_star_cos_table_sub, x
    adc small_star_xsub+i
    sta small_star_xsub+i
    lda small_star_cos_table_lo, x
    adc small_star_x+i
    sta small_star_x+i

    clc
    lda small_star_sin_table_sub, x
    adc small_star_ysub+i
    sta small_star_ysub+i
    lda small_star_sin_table_lo, x
    adc small_star_y+i
    sta small_star_y+i
.endrepeat

    clc
    lda medium_star_cos_table_sub, x
    adc powerup_xsub
    sta powerup_xsub
    lda medium_star_cos_table_lo, x
    adc powerup_x
    sta powerup_x
    cmp #8
    bcc killPowerUp
    cmp #256-8
    bcs killPowerUp

    lda medium_star_sin_table_sub, x
    adc powerup_ysub
    sta powerup_ysub
    lda medium_star_sin_table_lo, x
    adc powerup_y
    sta powerup_y
    cmp #16
    bcc killPowerUp
    cmp #240-8
    bcs killPowerUp
    rts
killPowerUp:
    lda #0
    sta powerup_type
    rts
.endproc
