extends Node

@onready var menu_music = $MenuMusic
@onready var bg_music = $BgMusic
@onready var boss_music = $BossMusic
@onready var victory_music = $VictoryMusic
@onready var game_over_music = $GameOverMusic
@onready var select_sound = $SelectSound
@onready var item_sound = $ItemPickup
@onready var stamina = $Stamina
@onready var outostamina = $OutOStamina

func stop_all():
	menu_music.stop()
	bg_music.stop()
	boss_music.stop()
	victory_music.stop()
	game_over_music.stop()
	
func play_menu_music():
	if not menu_music.playing:
		stop_all()
		menu_music.play()
		
func play_bg_music():
	if not bg_music.playing:
		stop_all()
		bg_music.play()
		
func play_boss_music():
	if not boss_music.playing:
		stop_all()
		boss_music.play()
		
func play_victory_music():
	if not victory_music.playing:
		stop_all()
		victory_music.play()
		
func play_game_over_music():
	if not game_over_music.playing:
		stop_all()
		game_over_music.play()
		
func play_select():
	select_sound.play()
	
func play_item():
	item_sound.play()
	
func play_stamina():
	stamina.play()
	
func play_outostamina():
	outostamina.play()
