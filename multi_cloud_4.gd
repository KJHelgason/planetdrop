# multi_cloud_3.gd
# This script controlls the computer cloud(Spaceship) behvaior in versus mode level 3
# It handles all computer movement and planet dropping mechanics and computer strategy

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
@export var x_min: float = 893
@export var x_max: float = 1282

# Score Manager Node
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
var ball_drop_level_offset = 0
var gold_ball_unlocked = 0

# AI Variables
var ai_target_x: float
var ai_move_cooldown := 0.0
var ai_rest_timer := 0.0
var ai_idle := true

# Replicatable RNG
var rng := RandomNumberGenerator.new()
var main_rng: RandomNumberGenerator

# Initialize Game
func _ready():
	# Game mode Global Variable
	ScoreManager.mode = 3
	
	var main = get_tree().get_root().get_node("Main")
	rng.seed = main.rng.seed
	
	# Score Manager for Upgrades
	score_manager = get_node("../ScoreManager")

	# Find UI elements and set score to 0
	score_label = get_parent().get_node("scoreLabel2")
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

	# Start timer to spawn the next ball after 0.1 second
	spawn_timer.start(0.1)

# Process inputs
func _process(delta):
	
	# AI Random Movement
	if ai_idle:
		ai_rest_timer -= delta
		if ai_rest_timer <= 0:
			ai_target_x = randf_range(x_min, x_max)
			ai_idle = false
	else:
		var distance = ai_target_x - position.x
		var direction = sign(distance)
		position.x += direction * move_speed * delta
		position.x = clamp(position.x, x_min, x_max)
		# Stop moving when close to target
		if abs(distance) <= 5:
			ai_idle = true
			ai_rest_timer = randf_range(1.5, 3.0)

	# Keep the ball attached to the cloud before dropping
	if is_instance_valid(current_ball) and !is_dropping:
		current_ball.position = position + Vector2(3, 65)
		

# Process Ball Dropping with Computer Logic for 95% accurate drop rate with combo setup
func _input(event):
	if event.is_action_pressed("drop_ball") and current_ball and !is_dropping and ScoreManager.ai_ready:
		# 95% chance to target accurately and look for a combo opportunity
		if rng.randf() < 0.95:
			var best_target: RigidBody2D = null
			# Combo Score
			var best_score := -1
			var balls = get_tree().get_nodes_in_group("balls")

			# Searching for same level ball to aim at
			for target_ball in balls:
				# Skip ball being held
				if target_ball == current_ball or target_ball == next_ball:
					continue
				# Skip non_comparable balls
				if not target_ball.has_method("get_level") or not current_ball.has_method("get_level"):
					continue
				# Skip different level balls
				if target_ball.get_level() != current_ball.get_level():
					continue

				# Count how many other balls of the same level are close by
				var nearby_same_level := 0
				for other in balls:
					if other == target_ball or other == current_ball or other == next_ball:
						continue
					if other.get_level() == target_ball.get_level():
						if abs(other.global_position.x - target_ball.global_position.x) < 50:
							if abs(other.global_position.y - target_ball.global_position.y) < 100:
								nearby_same_level += 1
								
				# Prioritize locations with 2+ nearby balls
				if nearby_same_level > best_score:
					best_score = nearby_same_level
					best_target = target_ball
					
			if best_target:
				# Move to align with target
				ai_target_x = clamp(best_target.global_position.x, x_min, x_max)
			else:
				# No combo opportunity found, fallback to random
				ai_target_x = randf_range(x_min, x_max)

		else:
			# 10% chance: normal random drop
			ai_target_x = randf_range(x_min, x_max)

		# Instantly move to drop location (or animate if you want)
		position.x = clamp(ai_target_x, x_min, x_max)

		# Wait briefly to simulate reaction time
		await get_tree().create_timer(0.3).timeout
		_drop_ball()
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
	next_ball.position = Vector2(1476, 288)
	next_ball.freeze = true

	is_dropping = false

	ScoreManager.ai_ready = true

# Function to update score
func _update_score(points: int):
	score += points
	if score_label:
		score_label.text = str(score)
	# Check for LOSS
	if score >= 15000:
		var end_screen = get_parent().get_node_or_null("EndGameScreen")
		if end_screen:
			end_screen.show_loss()
		else:
			print("EndGameScreen not found!")

# Function to drop the currently held planet
func _drop_ball():
	
	if is_instance_valid(current_ball) and is_instance_valid(next_ball):
		current_ball.remove_from_group("held_ball")
		is_dropping = true  
		current_ball.freeze = false
		$drop.play()
		current_ball = null

	# Start timer to spawn the next ball after 1 second
	spawn_timer.start(0.7)

# Randomly choose a ball scene from the available options based off upgrade or not
func _get_random_ball_scene():
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
	
