extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	 # Move the node to the left based on the parent's speed, divided by 2 to adjust the movement speed.
	position.x -= get_parent().speed / 2
