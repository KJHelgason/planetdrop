# end_game_screen.gd
# This script controls the end screen after a game is done.
# Handles end game screen logic like unlocking next level.

extends Control

@export var win_texture: Texture
@export var lose_texture: Texture
@onready var texture_rect = $WinLoseImage
@onready var back_button = $BackToTitleButton

func _ready():
	back_button.connect("pressed", Callable(self, "_on_back_to_title"))
	visible = false

# Function to show win if player won
func show_win():
	texture_rect.texture = win_texture
	visible = true
	$ConfettiParticles.restart()
	$winSound.play()
	get_tree().paused = true
	
	# Check if this level unlocks the next one
	if ScoreManager.mode == 1 and ScoreManager.highest_unlocked_level < 2:
		ScoreManager.highest_unlocked_level = 2
		ScoreManager.save_progress()
	elif ScoreManager.mode == 2 and ScoreManager.highest_unlocked_level < 3:
		ScoreManager.highest_unlocked_level = 3
		ScoreManager.save_progress()

# Function to show loss if player lost
func show_loss():
	texture_rect.texture = lose_texture
	visible = true
	$loseSound.play()
	$RainParticles.emitting = true
	get_tree().paused = true

# Function to return to title screen.
func _on_back_to_title():
	ScoreManager.just_won = true
	get_tree().paused = false
	get_tree().change_scene_to_file("res://TitleScreen.tscn")
