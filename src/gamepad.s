.include "globals.inc"

.export read_gamepad

.segment "CODE"
; Sets button flags of 'buttons_held' and 'buttons_pressed'.
; Clobbers A. Preserves X, Y.
.proc read_gamepad
new_buttons = 0
    ; Use a ring counter to set all 8 bits of 'new_buttons'.
    ; By starting 'new_buttons' at 1, the 1's bit will become the carry bit
    ; after 8 iterations of rotating-left, thus terminating the loop.
    ; See http://wiki.nesdev.com/w/index.php/Gamepad_code
    lda #1
    sta new_buttons
    ; Write a 1 GAMEPAD1 to set the strobe bit.
    ; While the strobe bit is set, buttons will be continuously reloaded.
    ; This means that reading from GAMEPAD1 will only return the state of the
    ; first button: A.
    sta GAMEPAD1
    ; By writing a 0, the strobe bit is cleared and the reloading stops.
    ; This allows all 8 buttons (newly reloaded) to be read from GAMEPAD1.
    lda #0
    sta GAMEPAD1
loadGamepadLoop:
    lda GAMEPAD1        ; Read a single button from the controller.
    and #%00000011      ; Ignore bits from Zappers, Power Pads, etc.
    cmp #1              ; Clear carry if A==0, set carry if A>=1.
    rol new_buttons     ; Store the carry bit in 'new_buttons', rotating left.
    bcc loadGamepadLoop ; Stop the loop after 8 iterations.

    ; 'new_buttons' is ready. Now update 'buttons_held' and 'buttons_pressed'.
    lda buttons_held
    eor #$FF
    and new_buttons
    sta buttons_pressed
    lda new_buttons
    sta buttons_held

    rts
.endproc

