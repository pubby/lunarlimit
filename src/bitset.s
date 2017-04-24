.include "globals.inc"

.export alloc_bitset8

.segment "CODE"

; In:
;   A = bitset
; Out:
;   A = new bitset
;   X = new bit index
; Returns with carry clear if allocation was a success.
; Clobbers A, X. Preserves Y.
.proc alloc_bitset8
    sta subroutine_temp
    cmp #$FF            ; All bits set means we can't allocate.
    beq return          ; Return with carry set.
    ldx #$FF
:
    inx
    lsr
    bcs :-
    lda powers_of_2_table, x
    ora subroutine_temp
    ; Carry guaranteed to be clear.
return:
    rts
.endproc

