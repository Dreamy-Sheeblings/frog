extends Node
# Frog
## Tongue
@onready var tongue_shoot_sfx: AudioStreamPlayer = $Sfx/TongueShoot
@onready var tongue_hit_sfx: AudioStreamPlayer = $Sfx/TongueHit
@onready var tongue_stuck_sfx: AudioStreamPlayer = $Sfx/TongueStuck
@onready var tongue_pull_sfx: AudioStreamPlayer = $Sfx/TonguePull
##
@onready var swallow_sfx: AudioStreamPlayer = $Sfx/Swallow
## Rage
@onready var rage_enter_sfx: AudioStreamPlayer = $Sfx/RageEnter
@onready var rage_exit_sfx: AudioStreamPlayer = $Sfx/RageExit
@onready var lvl_up_sfx: AudioStreamPlayer = $Sfx/LvlUp
# Card
@onready var card_hover_sfx: AudioStreamPlayer = $Sfx/CardHover
@onready var card_select_sfx: AudioStreamPlayer = $Sfx/CardSelected
# Environment
@onready var rain_sfx: AudioStreamPlayer = $Sfx/Rain
@onready var thunder_sfx: AudioStreamPlayer = $Sfx/Thunder
# UI
@onready var pause_sfx: AudioStreamPlayer = $Sfx/Pause
@onready var click_sfx: AudioStreamPlayer = $Sfx/Click
@onready var lose_sfx: AudioStreamPlayer = $Sfx/Lose