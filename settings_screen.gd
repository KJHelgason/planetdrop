# settings_screen.gd
# Script to handle the settings screen and its buttons.

extends Control

@export var win_texture: Texture
@export var lose_texture: Texture
@onready var back_button = $BackToTitleButton
@onready var volume_slider = $VolumeMenu/VolumeSlider

# Initialize Screen
func _ready():
	# Buttons
	back_button.connect("pressed", Callable(self, "_on_back_to_title"))
	volume_slider.value_changed.connect(_on_volume_slider_changed)
	
	# Volume
	var db = AudioServer.get_bus_volume_db(0)
	volume_slider.value = db_to_linear(db)
	
	# Start invisible
	visible = false

# Escape button handling
func _unhandled_input(event):
	if visible and event.is_action_pressed("escape_menu"):
		print("unpausing")
		_on_back_to_title()

# Enable Menu
func menu():
	visible = true
	$Boop.play()
	get_tree().paused = true
	ScoreManager.settings_menu = true

# Close Menu
func close():
	visible = false
	get_tree().paused = false
	ScoreManager.settings_menu = false

# Return to title screen
func _on_back_to_title():
	$Boop.play()
	ScoreManager.button_clicked = true
	visible = false
	get_tree().paused = false
	ScoreManager.settings_menu = false

# Change volume of game
func _on_volume_slider_changed(value):
	# Convert linear (0.0 - 1.0) to dB (-80 to 0)
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(0, db)
