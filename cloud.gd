# cloud.gd
# This script controlls the player cloud(Spaceship) behvaior
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
@export var x_min: float = 545
@export var x_max: float = 1045

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
var high_score_label: Label
var count = 1

# Gravity Upgrade
var gravity_active = false
var gravity_timer: Timer

# Ball Level Upgrade
var ball_drop_level_offset: int = 0

# Gold Ball Upgrade
var gold_ball_unlocked: bool = false

# Movement Speed Upgrade
var speed_upgraded: bool = false 

# RNG
var rng := RandomNumberGenerator.new()
var seed_value := 0

# Initialize Game
func _ready():
	# RNG Seed Value
	seed_value = Time.get_ticks_usec()
	rng.seed = seed_value
	
	# Score Manager for Upgrades
	score_manager = get_node("../ScoreManager")
	
	# Gravity Effect
	gravity_timer = Timer.new()
	gravity_timer.wait_time = 5.0
	gravity_timer.one_shot = true
	gravity_timer.connect("timeout", Callable(self, "_disable_gravity"))
	add_child(gravity_timer)

	# Find UI elements and set score to 0
	score_label = get_parent().get_node("scoreLabel")
	high_score_label = get_parent().get_node("highScoreLabel")
	_update_score(0)
	
	# Initialize first ball
	current_ball = _get_random_ball_scene().instantiate() as RigidBody2D
	current_ball.add_to_group("held_ball")
	current_ball.ball_owner = self
	current_ball.position = position + Vector2(3, 65)  # Place it above the cloud
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
	
	# Load High Score
	ScoreManager.load_high_score()
	high_score_label.text = str(ScoreManager.high_score)

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
	# Don't allow dropping if gravity is active
	if gravity_active:
		return
	# Drop the ball when spacebar is pressed
	if event.is_action_pressed("drop_ball") and current_ball and !is_dropping:
		_drop_ball()
		await get_tree().create_timer(1.1).timeout

# Function to spawn a new ball in players hands
func _spawn_new_ball():
	if current_ball != null:
		return  # Don't spawn if a ball is already held

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
	next_ball.position = Vector2(244, 288)
	next_ball.freeze = true
	is_dropping = false

# Function to update score
func _update_score(points: int):
	if points >= 0:
		score += points
		score_manager.score = score
		ScoreManager._update_score(points)
	else:
		score += points
		score_manager.score = score
		ScoreManager._update_score(points)
	if score_label:
		score_label.text = str(score)
	if high_score_label:
		high_score_label.text = str(ScoreManager.high_score)

# Function to drop the planet
func _drop_ball():
	# Prevent dropping during gravity
	if gravity_active:
		return
	
	# Make sure planet is droppable
	if is_instance_valid(current_ball) and is_instance_valid(next_ball):
		current_ball.remove_from_group("held_ball")
		is_dropping = true
		current_ball.freeze = false  
		$drop.play()
		current_ball = null

	# Start timer to spawn the next ball after 1 second
	spawn_timer.start(1.0)

# Function to generate a random ball depending on upgrades.
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

# Gravity Upgrade Proccesses
func _physics_process(delta):
	if gravity_active:
		_apply_gravity_effect()
		
# Disabled Gravity Upgrade
func _disable_gravity():
	ScoreManager.top_wall = false
	gravity_active = false
	
	var balls = get_tree().get_nodes_in_group("balls")
	for ball in balls:
		# Restore normal gravity
		ball.gravity_scale = 1
		
# Gravity Upgrade Effect
func _apply_gravity_effect():
	# Temporary Top Wall Enabled to prevent bad losses
	ScoreManager.top_wall = true
	
	var balls = get_tree().get_nodes_in_group("balls")
	for ball in balls:
		if ball == current_ball or ball == next_ball:
			continue
		# Make the ball weightless
		ball.gravity_scale = 0
		for other in balls:
			if ball == other:
				continue
			if other == current_ball or other == next_ball:
				continue
			if ball.get_level() == other.get_level():
				var dir = other.global_position - ball.global_position
				var dist = dir.length()
				if dist > 10:
					var force = dir.normalized() * 5
					ball.apply_impulse(force)

# Speed Upgrade
func apply_speed_upgrade():
	if not speed_upgraded:
		move_speed *= 1.5  # Increase by 50% (adjust as needed)
		speed_upgraded = true
