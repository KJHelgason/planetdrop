# title_screen.gd
# Script to handle the title screen and all associated buttons

extends Control

# Paths to your game scenes
const ENDLESS_SCENE = "res://main.tscn"
const LEVEL_1_SCENE = "res://main_1v1_1.tscn"
const LEVEL_2_SCENE = "res://main_1v1_2.tscn"
const LEVEL_3_SCENE = "res://main_1v1_3.tscn"

# Initialize Title Screen
func _ready():
	# Level Progress Load
	ScoreManager.load_progress()
	
	# Make button noise
	if ScoreManager.just_won:
		$Boop.play()
		ScoreManager.just_won = false
	if ScoreManager.button_clicked:
		$Boop.play()
		ScoreManager.button_clicked = false
	ScoreManager.restart = false

	# Connect buttons to their functions
	$EndlessButton.connect("pressed", Callable(self, "_on_endless_pressed"))
	$Level1Button.connect("pressed", Callable(self, "_on_level1_pressed"))
	$Level2Button.connect("pressed", Callable(self, "_on_level2_pressed"))
	$Level3Button.connect("pressed", Callable(self, "_on_level3_pressed"))
	$SettingsButton.connect("pressed", Callable(self, "_on_settings_pressed"))
	
	# Check if levels are unlocked
	if ScoreManager.highest_unlocked_level >= 2:
		$Level2Button.disabled = false
	else:
		$Level2Button.disabled = true
	if ScoreManager.highest_unlocked_level >= 3:
		$Level3Button.disabled = false
	else:
		$Level3Button.disabled = true

# Handle clicking on Endless mode
func _on_endless_pressed():
	ScoreManager.button_clicked = true
	get_tree().change_scene_to_file(ENDLESS_SCENE)

# Handle clicking on level 1
func _on_level1_pressed():
	ScoreManager.button_clicked = true
	get_tree().change_scene_to_file(LEVEL_1_SCENE)

# Handle clicking on level 2
func _on_level2_pressed():
	ScoreManager.button_clicked = true
	get_tree().change_scene_to_file(LEVEL_2_SCENE)

# Handle clicking on level 3
func _on_level3_pressed():
	ScoreManager.button_clicked = true
	get_tree().change_scene_to_file(LEVEL_3_SCENE)
	
# Handle clicking on settings
func _on_settings_pressed():
	if ScoreManager.settings_menu:
		$Boop.play()
		get_node_or_null("SettingsScreen").close()
	else:
		ScoreManager.button_clicked = true
		get_node_or_null("SettingsScreen").menu()
