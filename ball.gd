# ball.gd
# This script controlls Planet behavior.
# It handles Planet merges and its associated sound and vfx

extends RigidBody2D

# Multiplayer Code
@export var ball_owner: Node 

# Movement speed
@export var speed: float = 300

# All ball types (Planets)
@export var ball_type: String = "one"    #  2
@export var two_ball_scene: PackedScene  # Assign 4
@export var three_ball_scene: PackedScene  # Assign 6
@export var four_ball_scene: PackedScene # Assign 10
@export var five_ball_scene: PackedScene # Assign 15
@export var six_ball_scene: PackedScene # Assign  28
@export var seven_ball_scene: PackedScene # Assign 55
@export var eight_ball_scene: PackedScene # Assign 101
@export var nine_ball_scene: PackedScene # Assign 200
@export var ten_ball_scene: PackedScene # Assign 398
@export var eleven_ball_scene: PackedScene # Assign 783

# Particle/Audio Script
@export var merge_fx_scene: PackedScene  # Assign MergeEffect.tscn

# Prevents double spawning
var has_merged = false

# Temporary data for delayed merge
var _delayed_spawn_scene: PackedScene
var _delayed_spawn_position: Vector2
var _delayed_ball_type: String
var _delayed_ball_owner: Node
var _delayed_other_ball: RigidBody2D

func _ready():
	# Connect Area2D's "area_entered" signal to detect merging
	$Area2D.connect("area_entered", Callable(self, "_on_area_entered"))
	# Connect to a timer for delayed merge
	var connected = $MergeBallTimer.timeout.connect(Callable(self, "_on_MergeBallTimer_timeout"))

	# Give initial movement
	var direction = Vector2(0, 0)
	linear_velocity = direction * speed

# Merge Logic
func _on_area_entered(area):
	# Lose Logic
	var other = area.get_parent()

	# Don't allow self-merging check
	if other == self:
		return

	# Check if it collided with a held ball
	if is_in_group("balls") and other.is_in_group("held_ball"):
		if other.ball_owner and other.ball_owner.name == "Cloud":
			get_parent().get_node_or_null("EndGameScreen").show_loss()
		elif other.ball_owner and other.ball_owner.name == "Cloud2":
			get_parent().get_node_or_null("EndGameScreen").show_win()
		return
	
	var other_ball = area.get_parent()
	
	# Ensure it's another RigidBody2D and not already merged
	if other_ball is RigidBody2D and not has_merged and not other_ball.has_merged:
		# Handle Red → Blue merge
		if ball_type == "one" and (other_ball.ball_type == "one" or other_ball.ball_type == "gold"):
			# Merge Balls
			merge_into_new_ball(two_ball_scene, "two", other_ball)
			# Add Points
			if ball_owner:
				ball_owner._update_score(4)
			else:
				var cloud = get_parent().get_node("Cloud")
				cloud._update_score(4)
		
		# Handle Blue → Yellow merge
		elif ball_type == "two" and (other_ball.ball_type == "two" or other_ball.ball_type == "gold"):
			# Merge Balls
			merge_into_new_ball(three_ball_scene, "three", other_ball)
			# Add Points
			if ball_owner:
				ball_owner._update_score(6)
			else:
				var cloud = get_parent().get_node("Cloud")
				cloud._update_score(6)
			
		# Handle Yellow → Indigo merge
		elif ball_type == "three" and (other_ball.ball_type == "three" or other_ball.ball_type == "gold"):
			# Merge Balls
			merge_into_new_ball(four_ball_scene, "four", other_ball)
			# Add Points
			if ball_owner:
				ball_owner._update_score(10)
			else:
				var cloud = get_parent().get_node("Cloud")
				cloud._update_score(10)
			
		# Handle 4 → 5 merge
		elif ball_type == "four" and (other_ball.ball_type == "four" or other_ball.ball_type == "gold"):
			# Merge Balls
			merge_into_new_ball(five_ball_scene, "five", other_ball)
			# Add Points
			if ball_owner:
				ball_owner._update_score(15)
			else:
				var cloud = get_parent().get_node("Cloud")
				cloud._update_score(15)
			
		# Handle 5 → 6 merge
		elif ball_type == "five" and (other_ball.ball_type == "five" or other_ball.ball_type == "gold"):
			# Merge Balls
			merge_into_new_ball(six_ball_scene, "six", other_ball)
			# Add Points
			if ball_owner:
				ball_owner._update_score(28)
			else:
				var cloud = get_parent().get_node("Cloud")
				cloud._update_score(28)
			
		# Handle 6 → 7 merge
		elif ball_type == "six" and (other_ball.ball_type == "six" or other_ball.ball_type == "gold"):
			# Merge Balls
			merge_into_new_ball(seven_ball_scene, "seven", other_ball)
			# Add Points
			if ball_owner:
				ball_owner._update_score(55)
			else:
				var cloud = get_parent().get_node("Cloud")
				cloud._update_score(55)
			
		# Handle 7 → 8 merge
		elif ball_type == "seven" and (other_ball.ball_type == "seven" or other_ball.ball_type == "gold"):
			# Merge Balls
			merge_into_new_ball(eight_ball_scene, "eight", other_ball)
			# Add Points
			if ball_owner:
				ball_owner._update_score(101)
			else:
				var cloud = get_parent().get_node("Cloud")
				cloud._update_score(101)
			
		# Handle 8 → 9 merge
		elif ball_type == "eight" and (other_ball.ball_type == "eight" or other_ball.ball_type == "gold"):
			# Merge Balls
			merge_into_new_ball(nine_ball_scene, "nine", other_ball)
			# Add Points
			if ball_owner:
				ball_owner._update_score(200)
			else:
				var cloud = get_parent().get_node("Cloud")
				cloud._update_score(200)
			
		# Handle 9 → 10 merge
		elif ball_type == "nine" and (other_ball.ball_type == "nine" or other_ball.ball_type == "gold"):
			# Merge Balls
			merge_into_new_ball(ten_ball_scene, "ten", other_ball)
			# Add Points
			if ball_owner:
				ball_owner._update_score(398)
			else:
				var cloud = get_parent().get_node("Cloud")
				cloud._update_score(398)
			
		# Handle 10 → 11 merge
		elif ball_type == "ten" and (other_ball.ball_type == "ten" or other_ball.ball_type == "gold"):
			# Merge Balls
			merge_into_new_ball(eleven_ball_scene, "eleven", other_ball)
			# Add Points
			if ball_owner:
				ball_owner._update_score(783)
			else:
				var cloud = get_parent().get_node("Cloud")
				cloud._update_score(783)
			
		# Handle 11 -> 1 merge
		elif (ball_type == "eleven" and (other_ball.ball_type == "eleven" or other_ball.ball_type == "gold")) or (ball_type == "gold" and other_ball.ball_type == "eleven"):
			has_merged = true
			other_ball.has_merged = true
	
			# Add big score reward
			if ball_owner:
				ball_owner._update_score(1452)
			else:
				var cloud = get_parent().get_node("Cloud")
				cloud._update_score(1452)

			if merge_fx_scene:
				var fx = merge_fx_scene.instantiate()
				fx.global_position = (global_position + other_ball.global_position) / 2
				get_parent().add_child(fx)

			# Remove both balls
			queue_free()
			other_ball.queue_free()


# Function that merges 2 balls into 1 of the next size.
func merge_into_new_ball(new_ball_scene: PackedScene, new_type: String, other_ball: RigidBody2D) -> void:
	if new_ball_scene == null:
		return
	
	has_merged = true
	other_ball.has_merged = true

	# Calculate spawn position for new ball
	# And add delay
	_delayed_spawn_position = (global_position + other_ball.global_position) / 2
	_delayed_spawn_scene = new_ball_scene
	_delayed_ball_type = new_type
	_delayed_ball_owner = ball_owner
	_delayed_other_ball = other_ball 

	# Deactivate both balls visually and physically 
	hide()
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	freeze = true
	position = Vector2(-1000, -1000)  # Move off-screen

	other_ball.hide()
	other_ball.set_deferred("collision_layer", 0)
	other_ball.set_deferred("collision_mask", 0)
	other_ball.freeze = true
	other_ball.position = Vector2(-1000, -1000)

	# Spawn visual FX
	if merge_fx_scene:
		var fx = merge_fx_scene.instantiate()
		fx.global_position = _delayed_spawn_position
		get_parent().add_child(fx)

	# Start delay
	_start_merge_timer()

# Function to start merge timer
func _start_merge_timer():
	if $MergeBallTimer:
		$MergeBallTimer.start()
	else:
		print("Timer not found!")

# Function that happens after merge timer to spawn the new ball and delete the other 2
func _on_MergeBallTimer_timeout():
	# Now clean up both merged balls
	queue_free()
	if _delayed_other_ball and is_instance_valid(_delayed_other_ball):
		_delayed_other_ball.queue_free()
		
	if _delayed_spawn_scene:
		var new_ball = _delayed_spawn_scene.instantiate()
		new_ball.global_position = _delayed_spawn_position
		new_ball.ball_type = _delayed_ball_type
		new_ball.ball_owner = _delayed_ball_owner
		get_parent().add_child(new_ball)

	# Reset temporary vars
	_delayed_spawn_scene = null
	_delayed_ball_type = ""
	_delayed_ball_owner = null
	_delayed_other_ball = null

# Helper function to compare levels	
func get_level() -> int:
	match ball_type:
		"one": return 1
		"two": return 2
		"three": return 3
		"four": return 4
		"five": return 5
		"six": return 6
		"seven": return 7
		"eight": return 8
		"nine": return 9
		"ten": return 10
		"eleven": return 11
	return 0
