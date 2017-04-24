.include "globals.inc"

.import sin, cos
.export prepare_blank_sprites
.export prepare_game_sprites

SPR_NT = 1

.segment "RODATA"
.include "metasprites.inc"

.segment "CODE"

; This writes sprite data to CPU_OAM. Does not write to PPU.
; Clobbers A, X, Y.
.proc prepare_game_sprites
    ; Use X as an index into CPU_OAM. The 'prepare_sprite' functions will
    ; use and increment X as they write to 'CPU_OAM'.
    ldx #0              ; Start off at 4, skipping sprite0.

    ; Write to CPU_OAM.
    jsr prepare_player_sprites
    jsr prepare_menu_sprites
    jsr prepare_ui_sprites
    jsr prepare_respawn_sprites
    jsr prepare_powerup_sprites
    jsr prepare_enemy_sprites
    jsr prepare_bullet_sprites
    jsr prepare_explosion_sprites
    jsr prepare_star_sprites

    ; Clear the remaining portion of CPU_OAM so that unused/glitchy
    ; sprites aren't drawn.
    cpx #0
    beq return
    jsr clear_remaining_cpu_oam ; X is 0 after clear_remaining_cpu_oam.
return:
    rts

    ; Set sprite0 at the very end of prepare_game_sprites.
    ; This guarantees that sprite0 will be written even if the 
    ; OAM buffer overflows.
    ;jmp prepare_sprite0 ; Use prepare_sprite0's rts to return.
.endproc

prepare_blank_sprites:
    ldx #0
    ; Fall-through to clear_remaining_cpu_oam
; Clears CPU_OAM (hides sprites) from X to $FF.
; Clobbers A, X. Preserves Y.
.proc clear_remaining_cpu_oam
    lda #$FF
clearOAMLoop:
    sta CPU_OAM, x
    axs #.lobyte(-4)
    bne clearOAMLoop    ; OAM is 256 bytes. Overflow signifies completion.
    rts
.endproc

.proc prepare_respawn_sprites
    lda respawn
    beq return

    lda player_y 
    clc
    adc respawn
    sta CPU_OAM+0, x ; Set sprite's y-position.
    sta CPU_OAM+4, x ; Set sprite's y-position.

    lda player_y 
    sec
    sbc respawn
    sta CPU_OAM+8, x ; Set sprite's y-position.
    sta CPU_OAM+12, x ; Set sprite's y-position.

    lda player_x 
    clc
    adc respawn
    sta CPU_OAM+3, x ; Set sprite's y-position.
    sta CPU_OAM+11, x ; Set sprite's y-position.

    lda player_x 
    sec
    sbc respawn
    sta CPU_OAM+7, x ; Set sprite's y-position.
    sta CPU_OAM+15, x ; Set sprite's y-position.

    lda #$2
.repeat 4, i
    sta CPU_OAM+1+4*i, x ; Set sprite's pattern.
.endrepeat
    lda #0
.repeat 4, i
    sta CPU_OAM+2+4*i, x ; Set sprite's pattern.
.endrepeat

    ; Increment X by 16.
    txa
    axs #.lobyte(-4*4)
return:
    rts
.endproc

.proc prepare_menu_sprites
    lda menu
    bne :+
    rts
:
    cmp #MENU_START
    beq :+
    jmp gameOverMenu
:

    lda #120-9
.repeat 4, i
    sta CPU_OAM+0+i*4, x ; Set sprite's y-position.
.endrepeat

    lda #1
.repeat 4, i
    sta CPU_OAM+2+i*4, x ; Set sprite's attributes.
.endrepeat

.repeat 4, i
    lda #$68 + i
    sta CPU_OAM+1+i*4, x ; Set sprite's pattern.
    lda #112 + 8*i
    sta CPU_OAM+3+i*4, x ; Set sprite's x-position.
.endrepeat

    ; Increment X by 4*4.
    txa
    axs #.lobyte(-4*4)

    lda #120
.repeat 4, i
    sta CPU_OAM+0+i*4, x ; Set sprite's y-position.
.endrepeat

    lda #0
.repeat 4, i
    sta CPU_OAM+2+i*4, x ; Set sprite's attributes.
.endrepeat

.repeat 4, i
    lda #$78 + i
    sta CPU_OAM+1+i*4, x ; Set sprite's pattern.
    lda #112 + 8*i
    sta CPU_OAM+3+i*4, x ; Set sprite's x-position.
.endrepeat

    ; Increment X by 4*4.
    txa
    axs #.lobyte(-4*4)
    rts
gameOverMenu:
    lda menu
    cmp #38
    bcs :+
    adc #1
    sta menu
    rts
:

    lda #120-9
.repeat 4, i
    sta CPU_OAM+0+i*4, x ; Set sprite's y-position.
.endrepeat

    lda #1
.repeat 4, i
    sta CPU_OAM+2+i*4, x ; Set sprite's attributes.
.endrepeat

.repeat 4, i
    lda #$6C + i
    sta CPU_OAM+1+i*4, x ; Set sprite's pattern.
    lda #112 + 8*i
    sta CPU_OAM+3+i*4, x ; Set sprite's x-position.
.endrepeat

    ; Increment X by 4*4.
    txa
    axs #.lobyte(-4*4)

    lda #120
.repeat 4, i
    sta CPU_OAM+0+i*4, x ; Set sprite's y-position.
.endrepeat

    lda #0
.repeat 4, i
    sta CPU_OAM+2+i*4, x ; Set sprite's attributes.
.endrepeat

.repeat 4, i
    lda #$7C + i
    sta CPU_OAM+1+i*4, x ; Set sprite's pattern.
    lda #112 + 8*i
    sta CPU_OAM+3+i*4, x ; Set sprite's x-position.
.endrepeat

    ; Increment X by 4*4.
    txa
    axs #.lobyte(-4*4)
return:
    rts
.endproc

.proc prepare_player_sprites
    lda respawn
    bne return
    lda player_y
    sta CPU_OAM+0, x ; Set sprite's y-position.
    lda frame_number
    lsr
    alr #63
    clc
    adc #$20
    sta CPU_OAM+1, x ; Set sprite's pattern.
    ldy #3
    lda frame_number
    and #%00000010
    beq :+
    lda player_shield
    ora player_invuln
    beq :+
    ldy #1
:
    tya
    sta CPU_OAM+2, x ; Set sprite's attributes.
    lda player_x
    sta CPU_OAM+3, x ; Set sprite's x-position.
    ; Increment X by 4.
    txa
    axs #.lobyte(-4)

    lda player_dir
    jsr sin
    .repeat 4
        cmp #$80
        ror
    .endrepeat
    cmp #$80
    adc player_y
    sta CPU_OAM+0, x ; Set sprite's y-position.
    lda #$3
    sta CPU_OAM+1, x ; Set sprite's pattern.
    lda #3
    sta CPU_OAM+2, x ; Set sprite's attributes.
    lda player_dir
    jsr cos
    .repeat 4
        cmp #$80
        ror
    .endrepeat
    cmp #$80
    adc player_x
    sta CPU_OAM+3, x ; Set sprite's x-position.
    ; Increment X by 4.
    txa
    axs #.lobyte(-4)
return:
    rts
.endproc

.proc prepare_ui_sprites
    lda #16
    sta CPU_OAM+0, x ; Set sprite's y-position.
    lda player_life
    ora #$80
    sta CPU_OAM+1, x ; Set sprite's pattern.
    lda #2
    sta CPU_OAM+2, x ; Set sprite's attributes.
    lda #40
    sta CPU_OAM+3, x ; Set sprite's x-position.

    lda #16
    sta CPU_OAM+4, x ; Set sprite's y-position.
    lda frame_number
    lsr
    lsr
    alr #63
    clc
    adc #$20
    sta CPU_OAM+5, x ; Set sprite's pattern.
    lda #2
    sta CPU_OAM+6, x ; Set sprite's attributes.
    lda #32-1
    sta CPU_OAM+7, x ; Set sprite's x-position.

.repeat 5, i
    lda #16
    sta CPU_OAM+8+i*4, x ; Set sprite's y-position.
    lda #$80
    .if i > 0
        ora score+i-1
    .endif
    sta CPU_OAM+9+i*4, x ; Set sprite's pattern.
    lda #1
    sta CPU_OAM+10+i*4, x ; Set sprite's attributes.
    lda #132 -  i*7 + 4
    sta CPU_OAM+11+i*4, x ; Set sprite's x-position.
.endrepeat
    ; Increment X by 4*7.
    txa
    axs #.lobyte(-4*7)

    lda player_powerup
    beq return
    ora #$80
    sta CPU_OAM+1, x ; Set sprite's pattern.
    lda player_powerup
    sec
    sbc #POW_1UP
    sta CPU_OAM+2, x ; Set sprite's attributes.
    lda #16
    sta CPU_OAM+0, x ; Set sprite's y-position.
    lda #208
    sta CPU_OAM+3, x ; Set sprite's x-position.
    ; Increment X by 4.
    txa
    axs #.lobyte(-4)

return:
    rts
.endproc

.proc prepare_powerup_sprites
    lda powerup_type
    beq return
    sta CPU_OAM+1, x ; Set sprite's pattern.
    sec
    sbc #POW_1UP
    sta CPU_OAM+2, x ; Set sprite's attributes.
    lda powerup_y
    sta CPU_OAM+0, x ; Set sprite's y-position.
    lda powerup_x
    sta CPU_OAM+3, x ; Set sprite's x-position.
    ; Increment X by 4.
    txa
    axs #.lobyte(-4)
return:
    rts
.endproc

.proc prepare_bullet_sprites
iteration_bitset = 4
    lda pbullet_bitset
    beq return
    ldy #$FF
loop:
:
    iny
    lsr
    bcc :-
    pha

    lda pbullet_y, y
    sta CPU_OAM+0, x ; Set sprite's y-position.
    ;lda #$3
    lda pbullet_dir, y
    alr #%01111111
    lsr
    lsr
    ora #$10
    sta CPU_OAM+1, x ; Set sprite's pattern.
    lda #1
    sta CPU_OAM+2, x ; Set sprite's attributes.
    lda pbullet_x, y
    sta CPU_OAM+3, x ; Set sprite's x-position.
    ; Increment X by 4.
    txa
    axs #.lobyte(-4)

    pla
    bne loop
return:
    rts
.endproc

.proc prepare_explosion_sprites
y_iter = 0
iteration_bitset = 4
    lda explosion_bitset
    beq return
    ldy #$FF
loop:
:
    iny
    lsr
    bcc :-
    pha


    lda explosion_x, y
    sta draw_x
    lda explosion_y, y
    sta draw_y

    lda explosion_timer, y
    alr #%11111100
    cmp #8
    bcs checkNext
    sty y_iter
    tay

    lda metasprite::explosion, y
    sta ptr_temp+0
    lda metasprite::explosion+1, y
    sta ptr_temp+1
    ldy y_iter
    lda explosion_palette, y
    tay
    jsr prepare_metasprite

    ldy y_iter

checkNext:
    pla
    bne loop
return:
    rts
.endproc

.proc prepare_enemy_sprites
    lda num_enemies
    beq return
    ldy #0
loop:

    lda enemy_y_hi, y
    cmp #128
    bne nextIter

    lda enemy_x_hi, y
    cmp #128
    bne nextIter

    lda enemy_y_lo, y
    cmp #240
    bcs nextIter
    sta CPU_OAM+0, x ; Set sprite's y-position.
    lda enemy_dir, y
    lsr
    lsr
    lsr
    ora #$40
    sta CPU_OAM+1, x ; Set sprite's pattern.
    lda enemy_type, y
    sta CPU_OAM+2, x ; Set sprite's attributes.
    lda enemy_x_lo, y
    sta CPU_OAM+3, x ; Set sprite's x-position.
    ; Increment X by 4.
    txa
    axs #.lobyte(-4)

nextIter:
    iny
    cpy num_enemies
    bne loop
return:
    rts
.endproc

.proc prepare_metasprite
    sty subroutine_temp
    ldy #0
    lda (ptr_temp), y
    tay              ; First byte holds length of data.
loop:
    cpx #256-16
    bcs return

    lda (ptr_temp), y
    dey
    clc
    adc draw_y
    bcs badPos
    cmp #240
    bcs badPos
    sta CPU_OAM+0, x ; Set sprite's y-position.

    clc
    lda (ptr_temp), y
    bpl :+
    adc draw_x
    sta CPU_OAM+3, x ; Set sprite's x-position.
    bcc badPos
:
    adc draw_x
    sta CPU_OAM+3, x ; Set sprite's x-position.
    bcs badPos
    dey

    lda (ptr_temp), y
    dey
    sta CPU_OAM+1, x ; Set sprite's pattern.
    lda (ptr_temp), y
    eor subroutine_temp
    sta CPU_OAM+2, x ; Set sprite's attributes.

    ; Increment X by 4.
    txa
    axs #.lobyte(-4)

deyCheck:
    dey
    bne loop
return:
    rts
badPos:
    dey
    dey
    jmp deyCheck
.endproc

.proc prepare_star_sprites
.repeat 5, i
    lda large_star_y+i
    sta CPU_OAM+0, x ; Set sprite's y-position.
    lda #$04 + i / 2
    sta CPU_OAM+1, x ; Set sprite's pattern.
    lda #2 | %00100000
    sta CPU_OAM+2, x ; Set sprite's attribute.
    lda large_star_x+i
    sta CPU_OAM+03, x ; Set sprite's x-position.
    txa
    axs #.lobyte(-4)
    bne :+
    rts
:
.endrepeat
.repeat 5, i
    lda medium_star_y+i
    sta CPU_OAM+0, x ; Set sprite's y-position.
    lda #$06 + i / 2
    sta CPU_OAM+1, x ; Set sprite's pattern.
    lda #3 | %00100000
    sta CPU_OAM+2, x ; Set sprite's attribute.
    lda medium_star_x+i
    sta CPU_OAM+03, x ; Set sprite's x-position.
    txa
    axs #.lobyte(-4)
    bne :+
    rts
:
.endrepeat
.repeat 5, i
    lda small_star_y+i
    sta CPU_OAM+0, x ; Set sprite's y-position.
    lda #$08 + i / 2
    sta CPU_OAM+1, x ; Set sprite's pattern.
    lda #2 | %00100000
    sta CPU_OAM+2, x ; Set sprite's attribute.
    lda small_star_x+i
    sta CPU_OAM+03, x ; Set sprite's x-position.
    txa
    axs #.lobyte(-4)
    bne :+
    rts
:
.endrepeat
return:
    rts
.endproc

