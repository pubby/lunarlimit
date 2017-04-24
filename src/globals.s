.include "globals.inc"

.segment "ZEROPAGE"

ft_zp_storage: .res 3

subroutine_temp: .res 1
ptr_temp: .res 2
trig_dx: .res 2
trig_dy: .res 2

nt_hi: .res 1
nmi_counter: .res 1
ppuctrl: .res 1
rng_state: .res 2

buttons_held: .res 1
buttons_pressed: .res 1

player_x:   .res 1
player_y:   .res 1
player_dir: .res 1

frame_ptr: .res 2
palette_mask: .res 1
bgcol: .res 1
zp_nt_buffer: .res 224

.segment "BSS" ; RAM

ft_storage: .res 256

draw_x: .res 1
draw_y: .res 1

num_bullets: .res 1
bullet_x: .res BULLETS_MAX
bullet_y: .res BULLETS_MAX
bullet_dir: .res BULLETS_MAX

pbullet_bitset: .res 1
pbullet_x: .res 8
pbullet_y: .res 8
pbullet_dir: .res 8

num_enemies: .res 1
enemy_x_sub: .res ENEMIES_MAX
enemy_x_lo: .res ENEMIES_MAX
enemy_x_hi: .res ENEMIES_MAX
enemy_y_sub: .res ENEMIES_MAX
enemy_y_lo: .res ENEMIES_MAX
enemy_y_hi: .res ENEMIES_MAX
enemy_dir: .res ENEMIES_MAX
enemy_timer: .res ENEMIES_MAX
enemy_ammo: .res ENEMIES_MAX
enemy_type: .res ENEMIES_MAX

; Explosions
explosion_bitset: .res 1
explosion_x: .res 8
explosion_y: .res 8
explosion_timer: .res 8
explosion_palette: .res 8

large_star_xsub: .res LARGE_STARS
large_star_ysub: .res LARGE_STARS
large_star_x: .res LARGE_STARS
large_star_y: .res LARGE_STARS
medium_star_xsub: .res MEDIUM_STARS
medium_star_ysub: .res MEDIUM_STARS
medium_star_x: .res MEDIUM_STARS
medium_star_y: .res MEDIUM_STARS
small_star_xsub: .res SMALL_STARS
small_star_ysub: .res SMALL_STARS
small_star_x: .res SMALL_STARS
small_star_y: .res SMALL_STARS

wave_number: .res 1

frame_number: .res 1
sprite_hit: .res 1

score: .res 4

powerup_xsub: .res 1
powerup_x: .res 1
powerup_ysub: .res 1
powerup_y: .res 1
powerup_type: .res 1
player_powerup: .res 1
player_rapid: .res 1
player_shield: .res 1
player_bomb: .res 1
player_life: .res 1
player_invuln: .res 1

respawn: .res 1

menu: .res 1

bgcol_next: .res 1

.segment "RODATA"

asl4_table:
.repeat 16, i
    .byt i << 4
.endrepeat

powers_of_2_table:
.repeat 8, i
    .byt .lobyte(1 << i)
.endrepeat

