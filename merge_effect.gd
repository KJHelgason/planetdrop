# merge_effect.gd
# Function that plays a vfx when merges happen.

extends Node2D

func _ready():
	$CPUParticles2D.restart()
	$AudioStreamPlayer2D.play()
	await get_tree().create_timer(1.5).timeout
	queue_free()

# Called every frame.
func _process(delta: float) -> void:
	pass
