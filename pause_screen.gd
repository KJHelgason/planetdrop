# pause_screen.gd
# Script to handle the pause screen and its buttons.

extends Control

@export var win_texture: Texture
@export var lose_texture: Texture
@onready var texture_rect = $EscapeMenuBackground
@onready var continue_button = $ContinueButton
@onready var restart_button = $RestartButton
@onready var back_button = $BackToTitleButton

# Connects buttons to functions
func _ready():
	# Buttons
	continue_button.connect("pressed", Callable(self, "_on_continue_game"))
	restart_button.connect("pressed", Callable(self, "_on_restart_game"))
	back_button.connect("pressed", Callable(self, "_on_back_to_title"))
	
	# Start invisible
	visible = false
	
# Function to handle escape button.
func _unhandled_input(event):
	if visible and event.is_action_pressed("escape_menu"):
		print("unpausing")
		ScoreManager.escape_clicked = true
		_on_continue_game()

# Function to handle pausing the game
func pause():
	visible = true
	$Boop.play()
	get_tree().paused = true

# Function to handle continuing the game
func _on_continue_game():
	visible = false
	$Boop.play()
	get_tree().paused = false
	#ScoreManager.escape_clicked = false
	ScoreManager.escape_released_since_last_pause = false
	
# Function to handle restarting the game depending on which mode is being played.
func _on_restart_game():
	ScoreManager.button_clicked = true
	ScoreManager.restart = true
	if ScoreManager.mode == 0:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main.tscn")
	if ScoreManager.mode == 1:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_1v1_1.tscn")
	if ScoreManager.mode == 2:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_1v1_2.tscn")
	if ScoreManager.mode == 3:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_1v1_3.tscn")

# Function to handle returing to title screen.
func _on_back_to_title():
	ScoreManager.button_clicked = true
	get_tree().paused = false
	get_tree().change_scene_to_file("res://TitleScreen.tscn")
