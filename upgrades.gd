# upgrades.gd
# Script to handle all upgrades and their associated costs and functions

extends Control

@export var score_manager: Node 

@onready var hover_label = $HoverDescription

# Upgrade Costs
const GRAVITY_COST = 50
const ERASER_COST = 25
const BOMB_COST = 10
const BALL_DROP_COST = 300
const GOLD_BALL_COST = 1000
const SPEED_COST = 150

var gravity_active = false
var extra_ball_level = 0
var gold_ball_unlocked = false
var speed_boost = false

# Initialize upgrade buttons
func _ready():
	score_manager = get_node("../ScoreManager")
	
	# Connect buttons to functions
	$GravityButton.connect("pressed", Callable(self, "_on_gravity_pressed"))
	$EraserButton.connect("pressed", Callable(self, "_on_eraser_pressed"))
	$BombButton.connect("pressed", Callable(self, "_on_bomb_pressed"))
	$BallDropButton.connect("pressed", Callable(self, "_on_ball_drop_pressed"))
	$GoldBallButton.connect("pressed", Callable(self, "_on_gold_ball_pressed"))
	$SpeedButton.connect("pressed", Callable(self, "_on_speed_pressed"))

# Button Activation for gravity upgrade
func _on_gravity_pressed():
	if score_manager.spend_points(GRAVITY_COST):
		$ding.play()
		var cloud = get_node("../Cloud")
		cloud.gravity_active = true
		cloud.gravity_timer.start()

# Button Activation for eraser upgrade
func _on_eraser_pressed():
	if score_manager.spend_points(ERASER_COST):
		$ding.play()
		erase_random_low_level_balls()

# Button Activation for bomb upgrade
func _on_bomb_pressed():
	if score_manager.spend_points(BOMB_COST):
		$ding.play()
		launch_all_balls_upward()

# Button Activation for ball drop upgrade
func _on_ball_drop_pressed():
	if score_manager.spend_points(BALL_DROP_COST):
		$ding.play()
		var cloud = get_node("../Cloud")
		cloud.ball_drop_level_offset = 1

# Button Activation for gold ball upgrade
func _on_gold_ball_pressed():
	if score_manager.spend_points(GOLD_BALL_COST):
		$ding.play()
		var cloud = get_node("../Cloud")
		cloud.gold_ball_unlocked = true

# Button Activation for speed upgrade
func _on_speed_pressed():
	if score_manager.spend_points(SPEED_COST):
		$ding.play()
		var cloud = get_node("../Cloud")
		cloud.apply_speed_upgrade()

# Disable gravity effect after 5 seconds
func _on_gravity_timer_timeout():
	gravity_active = false

# Eraser Upgrade
func erase_random_low_level_balls():
	var balls = get_tree().get_nodes_in_group("balls")
	var low_level_balls = []

	# Reference the cloud to exclude held balls
	var cloud = get_tree().get_root().get_node("Main/Cloud")  # Adjust path if needed
	var current = cloud.current_ball
	var next = cloud.next_ball

	for ball in balls:
		if ball == current or ball == next:
			continue  # Skip the ball being held or previewed
		if ball.has_method("get_level") and ball.get_level() <= 4:
			low_level_balls.append(ball)

	low_level_balls.shuffle()
	var count = min(5, low_level_balls.size())
	for i in range(count):
		low_level_balls[i].queue_free()

# Bomb Upgrade
func launch_all_balls_upward():
	var balls = get_tree().get_nodes_in_group("balls")
	var cloud = get_node("../Cloud")
	print(balls)

	for ball in balls:
		# Skip the ball held or previewed
		if ball == cloud.current_ball or ball == cloud.next_ball:
			continue 
		
		# Boom
		if ball is RigidBody2D:
			var sideways_force = randf_range(-150, 150)  # random left/right force
			var vertical_force = randf_range(-350, -200)
			ball.apply_impulse(Vector2(sideways_force, vertical_force))


# Hover Gravity
func _on_gravity_button_mouse_entered() -> void:
	hover_label.text = " Temporarily pulls same-level Planets together "
	hover_label.visible = true
func _on_gravity_button_mouse_exited() -> void:
	hover_label.visible = false

# Hover Eraser
func _on_eraser_button_mouse_entered() -> void:
	hover_label.text = " Immediately erase up to 5 Planets "
	hover_label.visible = true
func _on_eraser_button_mouse_exited() -> void:
	hover_label.visible = false

# Hover Bomb
func _on_bomb_button_mouse_entered() -> void:
	hover_label.text = " Launches all planets into the air "
	hover_label.visible = true
func _on_bomb_button_mouse_exited() -> void:
	hover_label.visible = false

# Hover Ball Drop
func _on_ball_drop_button_mouse_entered() -> void:
	hover_label.text = " Permanent Dropped Planet level increase "
	hover_label.visible = true
func _on_ball_drop_button_mouse_exited() -> void:
	hover_label.visible = false

# Hover Speed
func _on_speed_button_mouse_entered() -> void:
	hover_label.text = " Permanent movement speed increase "
	hover_label.visible = true
func _on_speed_button_mouse_exited() -> void:
	hover_label.visible = false

# Hover Gold Ball
func _on_gold_ball_button_mouse_entered() -> void:
	hover_label.text = " Permanent 5% Chance to spawn a Golden Planet "
	hover_label.visible = true
func _on_gold_ball_button_mouse_exited() -> void:
	hover_label.visible = false
