# main.gd
# main function for singleplayer that positions the boundary walls appropriately and the escape menu.

extends Node2D

# Wall variables
@export var wall_thickness: int = 50
@export var wall_width: int = 644
@export var wall_height: int = 698

func _ready():
	# Global Gamemode Variable
	ScoreManager.mode = 0
	
	# Position Walls
	_reposition_walls()
	get_viewport().connect("size_changed", Callable(self, "_reposition_walls"))
	
	# Escape Variables
	ScoreManager.escape_clicked = false
	ScoreManager.escape_released_since_last_pause = true

# Function to handle escape button
func _unhandled_input(event):
	if event.is_action_released("escape_menu"):
		ScoreManager.escape_clicked = false
		ScoreManager.escape_released_since_last_pause = true

	if event.is_action_pressed("escape_menu") and not ScoreManager.escape_clicked and ScoreManager.escape_released_since_last_pause:
		ScoreManager.escape_clicked = true
		ScoreManager.escape_released_since_last_pause = false
		get_node_or_null("PauseScreen").pause()

func _process(delta):
	# Manage top boundary for gravity
	if ScoreManager.top_wall:
		_boundary_top_wall()
	else:
		_remove_top_wall()

# Function to calculate boundary top wall.
func _boundary_top_wall():
	# Calculate center position
	var screen_size = get_viewport_rect().size 
	var center = screen_size / 2 + Vector2(-2, 71)
	var offset_x = wall_width / 2
	var offset_y = wall_height / 2
	$Top.position = Vector2(center.x, 180)
	
# Function to remove top wall.
func _remove_top_wall():
	# Calculate center position
	var screen_size = get_viewport_rect().size 
	var center = screen_size / 2 + Vector2(-2, 71)
	var offset_x = wall_width / 2
	var offset_y = wall_height / 2
	$Top.position = Vector2(center.x, -1000)

# Function to reposition walls if screen changes
func _reposition_walls():
	var screen_size = get_viewport_rect().size 

	# Calculate center position
	var center = screen_size / 2 + Vector2(-2, 71)
	var offset_x = wall_width / 2
	var offset_y = wall_height / 2

	# Move and resize walls
	setup_wall($Left, Vector2(center.x - offset_x, center.y), Vector2(wall_thickness, wall_height))
	setup_wall($Right, Vector2(center.x + offset_x, center.y), Vector2(wall_thickness, wall_height))
	setup_wall($Bottom, Vector2(center.x, center.y + offset_y), Vector2(wall_width, wall_thickness))
	if has_node("Top"):
		setup_wall($Top, Vector2(center.x, -1000), Vector2(wall_width, wall_thickness))

# Funciton to initalize walls
func setup_wall(wall: Node2D, position: Vector2, size: Vector2):
	if wall == null:
		return

	wall.position = position

	# Set collision shape
	var collision = wall.get_node("CollisionShape2D")
	if collision:
		var shape = RectangleShape2D.new()
		shape.extents = size / 2
		collision.shape = shape

	# Set texture scaling
	var sprite = wall.get_node("Sprite2D")
	if sprite and sprite.texture:
		sprite.scale = size / sprite.texture.get_size()

var merge_scene: PackedScene
var merge_position: Vector2
