.include "globals.inc"

.export random_byte

.segment "CODE"

; Taken from http://wiki.nesdev.com/w/index.php/Random_number_generator
; Returns with a random in A.
; Clobbers A, X. Preserves Y.
.proc random_byte
    lda rng_state+0
.repeat 2      ; iteration count: controls entropy quality (max 8,7,4,2,1 min)
    asl        ; shift the register
    rol rng_state+1
    bcc :+
    eor #$2D   ; apply XOR feedback whenever a 1 bit is shifted out
:
.endrepeat
    sta rng_state+0
    rts
.endproc


