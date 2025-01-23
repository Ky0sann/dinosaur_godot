extends CharacterBody2D 

const GRAVITY : int = 4200 # Gravity force applied to the character
const JUMP_SPEED : int = -1200 # Initial speed of the jump (negative value to go up)
const MAX_JUMP_HOLD_TIME : float = 0.5 # Maximum duration to hold the jump button
const ADDITIONAL_JUMP_FORCE : int = -2000 # Additional force applied when holding the jump button

var jump_timer : float = 0.0
var is_jumping : bool = false

func _physics_process(delta):
	# Apply gravity to the vertical velocity
	velocity.y += GRAVITY * delta 
	
	if is_on_floor(): # If the character is on the ground
		is_jumping = false
		if not get_parent().game_running: # If the game is not running
			$AnimatedSprite2D.play("idle") # Play the idle animation
		else: # If the game is running
			$RunCol.disabled = false # Enable running collision detection
			if Input.is_action_just_pressed("ui_accept"): # If the jump button is pressed
				velocity.y = JUMP_SPEED # Set the initial jump speed
				is_jumping = true
				jump_timer = 0.0
				$JumpSound.play() # Play the jump sound effect
			elif Input.is_action_pressed("ui_down"): # If the down button is pressed
				$AnimatedSprite2D.play("duck") # Play the ducking animation
				$RunCol.disabled = true # Disable running collision detection while ducking
			else:
				$AnimatedSprite2D.play("run") # Play the running animation
	else: # If the character is in the air
		$AnimatedSprite2D.play("jump")  # Play the jumping animation
		
		if is_jumping and Input.is_action_pressed("ui_accept") and jump_timer < MAX_JUMP_HOLD_TIME:
			velocity.y += ADDITIONAL_JUMP_FORCE * delta
			jump_timer += delta

	# Move the character based on its velocity, and handle sliding on surfaces
	move_and_slide()
