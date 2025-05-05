# score_manager.gd
# Script to manage score and upgrade spending as well as global variables
# Handles all global variables between scripts as well as upgrade and score management.

extends Node

# Global Variables
var mode = 0
var highest_unlocked_level := 1
var settings_menu = false
var restart = false
var top_wall = false
var ai_ready = true
var just_won = false
var escape_clicked = false
var escape_released_since_last_pause = true
var button_clicked = false
var high_score_label: Label

# Global Score Variables and saving locally
var score: int = 0
var high_score: int = 0

const SAVE_PATH := "user://endless_highscore.save"

var cloud: Node

# Initialize
func _ready():
	cloud = get_node_or_null("../Cloud")  # Adjust path if needed

# Save level progress
func save_progress():
	var config = ConfigFile.new()
	config.set_value("progress", "unlocked_level", highest_unlocked_level)
	config.save("user://progress.cfg")

# Load level progress
func load_progress():
	var config = ConfigFile.new()
	var err = config.load("user://progress.cfg")
	if err == OK:
		highest_unlocked_level = config.get_value("progress", "unlocked_level", 1)

# Load high score from file
func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		high_score = file.get_32()
		file.close()
	else:
		high_score = 0
	update_high_score_display()

# Update score
func _update_score(points: int):
	score += points
	if score > high_score:
		high_score = score
		save_high_score()
	update_high_score_display()

# Save high score to file
func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_32(high_score)
	file.close()

# Update high score display
func update_high_score_display():
	if high_score_label:
		high_score_label.text = str(score)

# Function to add points
func add_points(points: int):
	score += points

# Function to spend points (returns true if successful)
func spend_points(points: int) -> bool:
	if score >= points:
		if cloud and cloud.has_method("_update_score"):
			cloud._update_score(-points)
		return true
	return false
