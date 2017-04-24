.include "globals.inc"

.export ppu_set_palette

.segment "RODATA"
palette:
    .byt BGC,EBC,EBC,EBC, BGC,$21,$24,$28, BGC,$21,$24,$28, BGC,$21,$24,$28
    .byt BGC,$14,$25,$3a, BGC,$03,$21,$20, BGC,$03,$19,$38, BGC,$32,$20,$19

.segment "CODE"
; Clobbers A. Preserves X, Y.
.proc ppu_set_palette
    sta palette_mask
    ppu_palette_address = $3F00
    lda #.hibyte(ppu_palette_address)
    sta PPUADDR
    lda #.lobyte(ppu_palette_address)
    sta PPUADDR
    .repeat 32, i
        lda palette+i
        clc
        adc palette_mask
        cmp #$40
        bcc :+
        lda #$30
    :
        sta PPUDATA
    .endrepeat
    rts
.endproc

