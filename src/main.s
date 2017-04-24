.include "globals.inc"

.import random_byte
.import read_gamepad
.import move_bullets
.import write_bullets
.import ppu_set_palette
.import prepare_game_sprites
.import update_player
.import move_enemies, think_enemies
.import update_explosions
.import load_wave, update_waves
.import update_stars
.import respawn_player
.import reset_play

.import FamiToneInit
.import FamiToneSfxInit
.import FamiToneMusicPlay
.import FamiToneUpdate
.import FamiToneSfxPlay
.importzp FT_SFX_CH0, FT_SFX_CH1, FT_SFX_CH2
.import sounds
.import music_data

.export main, nmi_handler, irq_handler

.segment "RODATA"

ppu_update_nt_lo:
    .byt .lobyte(ppu_update_nt_0)
    .byt .lobyte(ppu_update_nt_1)
    .byt .lobyte(ppu_update_nt_2)
    .byt .lobyte(ppu_update_nt_3)
ppu_update_nt_hi:
    .byt .hibyte(ppu_update_nt_0)
    .byt .hibyte(ppu_update_nt_1)
    .byt .hibyte(ppu_update_nt_2)
    .byt .hibyte(ppu_update_nt_3)

.segment "CODE"

.proc nmi_handler
    pha
    txa
    pha
    bit PPUSTATUS
    bvc :+
    inc sprite_hit
:
    ; Do OAM DMA.
    lda #.hibyte(CPU_OAM)
    sta OAMDMA

    jmp (frame_ptr)
doneUpdateNT:

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

    lda ppuctrl
    sta PPUCTRL

    ; Restore registers and return.
    inc nmi_counter
    pla
    tax
    pla
    rti
.endproc

.proc irq_handler
    rti
.endproc

; TODO
.proc ppu_clear_nt
    bit PPUSTATUS
.repeat 2, i
    lda #$20 + $08*i
    sta PPUADDR
    lda #$00
    sta PPUADDR
    lda #0
    ldx #0
:
    .repeat 4
        sta PPUDATA
    .endrepeat
    dex
    bne :-
.endrepeat
    rts
.endproc

.repeat 4, i
.ident(.concat("ppu_update_nt_", .string(i))):
    ; Set palette
    lda #.hibyte($3F00)
    sta PPUADDR
    lda #.lobyte($3F00)
    sta PPUADDR
    lda bgcol
    sta PPUDATA
    .if (i / 2) = 0
        lda #EBC
        sta PPUDATA
        lda #EBC2
        sta PPUDATA
    .else
        lda #EBC2
        sta PPUDATA
        lda #EBC
        sta PPUDATA
    .endif

    lda nt_hi
    ora #.hibyte(i*224 + 64)
    sta PPUADDR
    lda #$00 + .lobyte(i*224 + 64)
    sta PPUADDR
    .repeat 224, j
        lda zp_nt_buffer+j
        sta PPUDATA
    .endrepeat
    lda #PPUMASK_BG_ON | PPUMASK_SPR_ON
    sta PPUMASK
    jmp nmi_handler::doneUpdateNT
.endrepeat

.proc bomb_frame
    lda #$10
    ldx player_bomb
    cpx #44
    bcs skip
    txa
    asl
    and #%01110000
skip:
    cmp #$20
    bcc :+
    lda #0
    sta PPUMASK
    lda #$30
    jsr ppu_set_palette
    jsr ppu_clear_nt
    jmp nmi_handler::doneUpdateNT
:
    jsr ppu_set_palette
    lda #PPUMASK_BG_ON | PPUMASK_SPR_ON
    sta PPUMASK
    jmp nmi_handler::doneUpdateNT
.endproc

.proc init_stars
.repeat 5, i
    jsr random_byte
    sta large_star_x+i
    jsr random_byte
    sta large_star_y+i
    jsr random_byte
    sta medium_star_x+i
    jsr random_byte
    sta medium_star_y+i
    jsr random_byte
    sta small_star_x+i
    jsr random_byte
    sta small_star_y+i
.endrepeat
    rts
.endproc

.proc main
    lda #0
    ldx #0
:
    sta ft_storage, x
    inx
    bne :-

    lda #1
    ldx #<music_data
    ldy #>music_data
    jsr FamiToneInit

    ldx #<sounds
    ldy #>sounds
    jsr FamiToneSfxInit

    lda #0
    sta PPUCTRL
    sta PPUMASK
    sta buttons_held
    sta buttons_pressed

    lda #PPUCTRL_NMI_ON
    sta ppuctrl

    lda #BGC
    sta bgcol
    sta bgcol_next

    lda #$82
    sta rng_state+0
    lda #$39
    sta rng_state+1

    jsr init_stars

    lda #MENU_START
    sta menu

    jsr reset_play
    jsr respawn_player

    bit PPUSTATUS
    lda #0
    jsr ppu_set_palette

    lda #$20
    sta nt_hi

    lda #.lobyte(ppu_update_nt_0)
    sta frame_ptr+0
    lda #.hibyte(ppu_update_nt_0)
    sta frame_ptr+1

    jsr ppu_clear_nt

    lda #PPUCTRL_NMI_ON
    sta PPUCTRL
loop:
    ; Wait for NMI
    lda nmi_counter
:
    cmp nmi_counter
    beq :-

    lda bgcol_next
    sta bgcol
    lda #BGC
    sta bgcol_next

    jsr FamiToneUpdate
    jsr read_gamepad

    lda frame_number
    and #%00000011
    bne :+
    jsr move_bullets
:
    jsr write_bullets

    jsr move_enemies

    lda frame_number
    and #%00000011
    cmp #2
    bne :+
    jsr think_enemies
:

    lda frame_number
    and #%00000001
    beq :+
    jsr update_stars
:

    lda frame_number
    and #%00000011
    cmp #3
    bne :+
    jsr update_waves
:

    lda menu
    bne :+
    jsr update_player
    jmp doneUpdatePlayer
:
    lda buttons_pressed
    and #BUTTON_START
    beq doneUpdatePlayer
    lda #0
    sta menu
    jsr reset_play
    lda #8
    ldx #FT_SFX_CH2
    jsr FamiToneSfxPlay
    lda #$11
    sta bgcol
    lda #$01
    sta bgcol_next
doneUpdatePlayer:

    jsr update_explosions
    jsr prepare_game_sprites

    ; set frame_ptr
    lda player_bomb
    beq :+
    lda #.lobyte(bomb_frame)
    sta frame_ptr+0
    lda #.hibyte(bomb_frame)
    sta frame_ptr+1
    jmp doneSetFramePtr
:
    lda frame_number
    and #%00000011
    tax
done_prepare_zp_nt:
    lda ppu_update_nt_lo, x
    sta frame_ptr+0
    lda ppu_update_nt_hi, x
    sta frame_ptr+1
doneSetFramePtr:

    lda frame_number
    and #%00000100
    asl
    ora #$20
    sta nt_hi

    lda frame_number
    and #%00000100
    eor #%00000100
    lsr
    ora #PPUCTRL_NMI_ON | PPUCTRL_SPR_PT_1000
    sta ppuctrl

    inc frame_number
    jmp loop

.endproc

.segment "CHR"
    .incbin "bullets.chr"
    .incbin "sprites.chr"
