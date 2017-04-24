.ifndef GLOBAL_INC
.define GLOBAL_INC

.include "nes.inc"

CPU_OAM = $0200
BULLETS_MAX = 48
ENEMIES_MAX = 24
SMALL_STARS = 5
MEDIUM_STARS = 5
LARGE_STARS = 5

BGC = $1D
EBC = $24
EBC2 = $08

ES_HOME = 0
ES_SHOOT = 1
FLYES_RETREAT = 1

POW_1UP = $0C
POW_SHIELD = $0D
POW_BOMB = $0E
POW_RAPID = $0F

MENU_START = 1
MENU_GAMEOVER = 2

.globalzp ft_zp_storage
.global ft_storage
.global sounds

.globalzp subroutine_temp
.globalzp ptr_temp
.globalzp trig_dx
.globalzp trig_dy

.globalzp nt_hi
.globalzp nmi_counter
.globalzp ppuctrl
.globalzp rng_state

.globalzp buttons_held
.globalzp buttons_pressed

.globalzp player_x
.globalzp player_y
.globalzp player_dir

.globalzp frame_ptr
.globalzp palette_mask
.globalzp bgcol
.globalzp zp_nt_buffer

.global draw_x
.global draw_y

.global num_bullets
.global bullet_x
.global bullet_y
.global bullet_dir

.global pbullet_bitset
.global pbullet_x
.global pbullet_y
.global pbullet_dir

.global num_enemies
.global enemy_x_sub
.global enemy_x_lo
.global enemy_x_hi
.global enemy_y_sub
.global enemy_y_lo
.global enemy_y_hi
.global enemy_dir
.global enemy_timer
.global enemy_ammo
.global enemy_type

; Explosions
.global explosion_bitset
.global explosion_x
.global explosion_y
.global explosion_timer
.global explosion_palette

.global large_star_xsub
.global large_star_ysub
.global large_star_x
.global large_star_y
.global medium_star_xsub
.global medium_star_ysub
.global medium_star_x
.global medium_star_y
.global small_star_xsub
.global small_star_ysub
.global small_star_x
.global small_star_y

.global wave_number

.global frame_number
.global sprite_hit

.global score

.global powerup_xsub
.global powerup_x
.global powerup_ysub
.global powerup_y
.global powerup_type
.global player_powerup
.global player_rapid
.global player_shield
.global player_bomb
.global player_life
.global player_invuln

.global respawn

.global menu

.global bgcol_next

; Tables
.global sin_table
.global atan_table
.global bullet_sin_table
.global bullet_cos_table
.global enemy_sin_table_sub
.global enemy_sin_table_lo
.global enemy_sin_table_hi
.global enemy_cos_table_sub
.global enemy_cos_table_lo
.global enemy_cos_table_hi
.global small_star_sin_table_sub
.global small_star_cos_table_sub
.global small_star_sin_table_lo
.global small_star_cos_table_lo
.global medium_star_sin_table_sub
.global medium_star_cos_table_sub
.global medium_star_sin_table_lo
.global medium_star_cos_table_lo
.global large_star_sin_table_sub
.global large_star_cos_table_sub
.global large_star_sin_table_lo
.global large_star_cos_table_lo
.global asl4_table
.global powers_of_2_table
.global wave_lo
.global wave_hi
.endif
