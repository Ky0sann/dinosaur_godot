extends Node

#preload obstacles
var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var barrel_scene = preload("res://scenes/barrel.tscn")
var bird_scene = preload("res://scenes/bird.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene] # Array containing all types of obstacles
var obstacles : Array  # Array to hold the active obstacles in the game
var bird_heights := [250, 390] # Possible heights for bird obstacles 

#game variables
const DINO_START_POS := Vector2i(150, 485) # Starting position of the dinosaur
const CAM_START_POS := Vector2i(576, 324) # Starting position of the camera
var difficulty # Stores the current game difficulty
const MAX_DIFFICULTY : int = 2 # Maximum difficulty level
var score : int # The player's current score
const SCORE_MODIFIER : int = 10 # Modifier to adjust the displayed score
var high_score : int  # The player's highest score
var speed : float  # The current speed of the game
const START_SPEED : float = 10.0 # Starting speed at the beginning of the game
const MAX_SPEED : int = 25 # Maximum speed of the game
const SPEED_MODIFIER : int = 5000 # Speed modifier for difficulty progression
var screen_size : Vector2i  # The size of the game screen
var ground_height : int # The height of the ground
var game_running : bool # Boolean indicating if the game is currently running
var last_obs # The last generated obstacle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size # Get the size of the window
	ground_height = $Ground.get_node("Sprite2D").texture.get_height() # Get the ground height based on the texture
	$GameOver.get_node("Button").pressed.connect(new_game) # Connect the button's pressed signal to start a new game when game over
	new_game() # Start a new game when the scene is ready (call the function new_game defined below)

func new_game():
	#reset variables
	score = 0
	show_score() # Update the score display
	game_running=false # Stop the game from running
	get_tree().paused = false # Unpause the game if it was paused
	difficulty = 0 # Set the initial difficulty to 0
	
	#delete all obstacles
	for obs in obstacles: # For every obstacles in the list
		obs.queue_free() # Free the obstacle from memory
	obstacles.clear()  # Clear the obstacle list
	
	#reset the nodes
	$Dino.position = DINO_START_POS # Reset the dinosaur's position
	$Dino.velocity = Vector2i(0, 0) # Reset the dinosaur's velocity
	$Camera2D.position = CAM_START_POS # Reset the camera's position
	$Ground.position = Vector2i(0, 0) # Reset the ground position
	
	#reset hud and game over screen
	$HUD.get_node("StartLabel").show() # Show the "Start" label
	$GameOver.hide() # Hide the game over screen
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running: # If the game is running
		# speed up and adjust difficulty
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED: # Limits maximum speed
			speed= MAX_SPEED
		adjust_difficulty() # Adjust difficulty based on score (call the function adjust_difficulty defined below) 
		
		#generate obstacles
		generate_obs()
		
		#move dino and camera
		$Dino.position.x += speed
		$Camera2D.position.x += speed
	
		#update score
		score += speed
		show_score()
		
		#update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
		
		#remove obstacles that have gone off screen
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	
	else: # If the game is not running, wait for an action to start again (spacebar)
		if Input.is_action_pressed("ui_accept"): # If the user presses to start
			game_running=true # Game is running
			$HUD.get_node("StartLabel").hide() # Hide the start label

# Function to generate obstacles
func generate_obs():
	# generate ground obstacles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()] # Select a random obstacle type
		var obs
		var max_obs = difficulty + 1 # Number of obstacles is based on difficulty
		for i in range(randi() % max_obs + 1): # Create a random number of obstacles
			obs = obs_type.instantiate() # Instantiate the obstacle
			var obs_height = obs.get_node("Sprite2D").texture.get_height() # Get the obstacle's height
			var obs_scale = obs.get_node("Sprite2D").scale # Get the obstacle's scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100) # Calculate the x-position of the obstacle
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5 # Calculate the y-position of the obstacle
			last_obs = obs # Store the last generated obstacle
			add_obs(obs, obs_x, obs_y) # Add the obstacle to the scene (call the function add_obs defined below) 
		# Random chance to add a bird if the difficulty is at max
		if difficulty == MAX_DIFFICULTY :
			if(randi() % 2 ) == 0:
				#generate bird obstacles
				obs = bird_scene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = bird_heights[randi() % bird_heights.size()] # Choose a random height for the bird (250 or 390)
				add_obs(obs, obs_x, obs_y) # Add the obstacle to the scene (call the function add_obs defined below) 

# Function to add an obstacle to the scene
func add_obs(obs, x ,y):
	obs.position = Vector2i(x,y) # Set the obstacle's position
	obs.body_entered.connect(hit_obs) # Connects collision detection
	add_child(obs) # Add the obstacle to the scene
	obstacles.append(obs)# Add the obstacle to the list

# Function to remove an obstacle
func remove_obs(obs):
	obs.queue_free() # Removes the obstacle from the scene
	obstacles.erase(obs)  # Removes the obstacle from the list

# Function called when an obstacle hits the dino
func hit_obs(body):
	if body.name == "Dino": # If the object that hits is the dino
		game_over() # Game over

# Function to display the score
func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER) # Display the current score

# Function to check and update the high score
func check_high_score():
	if score > high_score: # If the current score is higher than the high score
		high_score = score # Update the high score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER) # Display the high score

# Function to adjust the difficulty based on score
func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER # Adjust difficulty based on score
	if difficulty > MAX_DIFFICULTY: # Limit the difficulty to the maximum value
		difficulty = MAX_DIFFICULTY 

# Function called when the game is over
func game_over():
	check_high_score() # Check and update the high score
	get_tree().paused = true # Pause the game
	game_running = false # Game is not running
	$GameOver.show() # Display the game over screen
	$GameOverSound.play() # Play a game over sound
	$Dino.get_node("AnimatedSprite2D").play("death") # Play the dino's death animation
	
