extends CharacterBody2D

const GRAVITY : int = 4200 # Gravity force applied to the character
const JUMP_SPEED : int = -1600 # Speed of the jump (negative value to go up)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Apply gravity to the vertical velocity
	velocity.y += GRAVITY * delta 
	
	if is_on_floor(): # If the character is on the ground
		if not get_parent().game_running: # If the game is not running
			$AnimatedSprite2D.play("idle") # Play the idle animation
		else: # If the game is running
			$RunCol.disabled = false # Enable running collision detection
			if Input.is_action_just_pressed("ui_accept"): # If the jump button is pressed
				velocity.y = JUMP_SPEED # Set the vertical velocity for jumping
				$JumpSound.play() # Play the jump sound effect
			elif Input.is_action_pressed("ui_down"): # If the down button is pressed
				$AnimatedSprite2D.play("duck") # Play the ducking animation
				$RunCol.disabled = true # Disable running collision detection while ducking
			else:
				$AnimatedSprite2D.play("run") # Play the running animation
	else: # If the character is in the air
		$AnimatedSprite2D.play("jump")  # Play the jumping animation
	
	 # Move the character based on its velocity, and handle sliding on surfaces
	move_and_slide()
