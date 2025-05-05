# rule_image.gd
# Script to show the rules before game start
# Handles showing rule image and its buttons and their functions.

extends Control

# Initialize Rules
func _ready():
	# Make button noise
	if ScoreManager.button_clicked:
		$Boop.play()
		ScoreManager.button_clicked = false
	if ScoreManager.restart == false:
		$StartButton.connect("pressed", Callable(self, "_on_start_button_pressed"))
		# Make sure the rules image is visible and the game is paused
		visible = true
		get_tree().paused = true
	else:
		_start_game()

# Function to process input
func _input(event):
	if visible and event.is_action_pressed("ui_accept"):
		_start_game()

# Function triggers _start_game() when button is pressed
func _on_start_button_pressed():
	_start_game()

# Function to start game
func _start_game():
	$Boop.play()
	visible = false
	get_tree().paused = false
