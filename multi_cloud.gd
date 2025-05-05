# multi_cloud.gd
# This script controlls the player cloud(Spaceship) behvaior in versus mode
# It handles all player movement and planet dropping mechanics

extends StaticBody2D

# Ball types that can be spawned 
@export var one_ball_scene: PackedScene
@export var two_ball_scene: PackedScene
@export var three_ball_scene: PackedScene
@export var four_ball_scene: PackedScene
@export var five_ball_scene: PackedScene
@export var gold_ball_scene: PackedScene

# Speed of cloud movement
@export var move_speed: float = 400

# Boundary variables for cloud movement
@export var x_min: float = 315
@export var x_max: float = 704

# Global Variables
@export var score_manager: Node

# Current and Next Ball
var current_ball: RigidBody2D = null
var next_ball: RigidBody2D = null

# Prevents dropping multiple balls
var is_dropping: bool = false

# Timer Initialized
var spawn_timer: Timer

# Score Counter
var score: int = 0
var score_label: Label
var count = 1


# Ball Level Upgrade
var ball_drop_level_offset: int = 0

# Gold Ball Upgrade
var gold_ball_unlocked: bool = false

# Replicatable RNG
var rng := RandomNumberGenerator.new()
var main_rng: RandomNumberGenerator

# Initialize Game
func _ready():
	# RNG seed
	var main = get_tree().get_root().get_node("Main")
	rng.seed = main.rng.seed

	# Score Manager for Upgrades
	score_manager = get_node("../ScoreManager")

	# Find UI elements and set score to 0
	score_label = get_parent().get_node("scoreLabel")
	_update_score(0)

	# Initialize first ball
	current_ball = _get_random_ball_scene().instantiate() as RigidBody2D
	current_ball.add_to_group("held_ball")
	current_ball.ball_owner = self
	current_ball.position = position + Vector2(3, 65)
	current_ball.freeze = true
	_spawn_new_ball()

	# Get the Timer node
	spawn_timer = $BallSpawnTimer
	spawn_timer.connect("timeout", Callable(self, "_spawn_new_ball"))
	
	# Initialize first ball
	if current_ball:
		current_ball.add_to_group("held_ball")
		is_dropping = true
		current_ball.freeze = false
		current_ball = null

	# Start timer to spawn the next ball after 1 second
	spawn_timer.start(0.1)

# Process inputs
func _process(delta):
	
	# Direction of ball drop (Down)
	var direction = 0

	# Move the cloud based on user input
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
		direction = 0
	elif Input.is_action_pressed("move_right"):  # D key
		direction = 1
	elif Input.is_action_pressed("move_left"):  # A key
		direction = -1

	# Update the cloud position, but clamp it within the specified bounds
	# Move left or right
	position.x += direction * move_speed * delta
	# Ensure the cloud stays within bounds
	position.x = clamp(position.x, x_min, x_max)

	# Keep the ball attached to the cloud before dropping
	if is_instance_valid(current_ball) and !is_dropping:
		current_ball.position = position + Vector2(3, 65)  
		
	

# Process Ball Dropping
func _input(event):
	# Drop the ball when spacebar is pressed
	if event.is_action_pressed("drop_ball") and current_ball and !is_dropping and ScoreManager.ai_ready:
		_drop_ball()
		ScoreManager.ai_ready = false
		await get_tree().create_timer(1.1).timeout


# Function to spawn a new planet
func _spawn_new_ball():
	# Don't spawn if a ball is already held
	if current_ball != null:
		return 

	var current_scene: PackedScene
	var next_scene: PackedScene = _get_random_ball_scene()

	# First spawn case
	if count == 1:
		current_scene = _get_random_ball_scene()

		# Reroll if they're the same
		var reroll_limit = 10
		var attempts = 0
		while current_scene.resource_path == next_scene.resource_path and attempts < reroll_limit:
			next_scene = _get_random_ball_scene()
			attempts += 1

		# Instantiate current_ball from current_scene
		current_ball = current_scene.instantiate() as RigidBody2D
		get_parent().add_child(current_ball)
		current_ball.ball_owner = self
		current_ball.position = position + Vector2(0, 65)
		current_ball.freeze = true
		current_ball.add_to_group("held_ball")
		 # Mark that first spawn is done
		count = 2 
	else:
		# Normal case: promote next_ball to current
		current_ball = next_ball
		if current_ball:
			current_ball.position = position + Vector2(0, 65)
			current_ball.add_to_group("held_ball")
			current_ball.ball_owner = self

	# Instantiate next_ball
	next_ball = next_scene.instantiate() as RigidBody2D
	get_parent().add_child(next_ball)
	next_ball.position = Vector2(127, 288)
	next_ball.freeze = true
	is_dropping = false


# Function to update score
func _update_score(points: int):
	score += points
	if score_label:
		score_label.text = str(score)
		
	# Win threshold
	var win_score := 5000
	
	match ScoreManager.mode:
		1:
			win_score = 5000
		2:
			win_score = 10000
		3:
			win_score = 15000
			
	# Check for WIN
	if score >= win_score:
		var end_screen = get_parent().get_node_or_null("EndGameScreen")
		if end_screen:
			end_screen.show_win()
		else:
			print("EndGameScreen not found!")

# Function to drop the current held planet
func _drop_ball():
	if is_instance_valid(current_ball) and is_instance_valid(next_ball):
		current_ball.remove_from_group("held_ball")
		is_dropping = true  
		current_ball.freeze = false  
		$drop.play()
		current_ball = null

	# Start timer to spawn the next ball after 1 second
	spawn_timer.start(1.0)

# Randomly choose a ball scene from the available options based off upgrade or not
func _get_random_ball_scene():
	# No Level Upgrade
	if ball_drop_level_offset == 0:
		# No Gold Upgrade
		if !gold_ball_unlocked:
			var ball_scenes = [one_ball_scene, two_ball_scene, three_ball_scene, four_ball_scene]
			return ball_scenes[rng.randi_range(0, ball_scenes.size() - 1)]
		# Gold Upgrade
		else:
			# Rare Chance to HIT (5%)
			if rng.randf() < 0.05:
				return gold_ball_scene
			# No Gold HIT (95%)
			var ball_scenes = [one_ball_scene, two_ball_scene, three_ball_scene, four_ball_scene]
			return ball_scenes[rng.randi_range(0, ball_scenes.size() - 1)]
	# Level Upgrade
	else:
		# No Gold Upgrade
		if !gold_ball_unlocked:
			var ball_scenes = [two_ball_scene, three_ball_scene, four_ball_scene, five_ball_scene]
			return ball_scenes[rng.randi_range(0, ball_scenes.size() - 1)]
		# Gold Upgrade
		else:
			# Rare Chance to HIT (5%)
			if rng.randf() < 0.05:
				return gold_ball_scene
			# No Gold HIT (95%)
			var ball_scenes = [two_ball_scene, three_ball_scene, four_ball_scene, five_ball_scene]
			return ball_scenes[rng.randi_range(0, ball_scenes.size() - 1)]
	
