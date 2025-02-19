extends CharacterBody2D
class_name player

const SPEED = 120.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animation_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer
@onready var state_machine = animation_tree.get("parameters/playback")

@export var starting_direction = 1

var near_door = false
@onready var near_return = false
@onready var near_next = false
var current_level : int = 1

func _ready():
	update_animation_parameters(starting_direction)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Change between idle and walk animation
	pick_new_state()
	
	#Check if attack
	var attack = Input.get_action_strength("attack")
	if attack and state_machine.get_current_node() != "Attack":
		state_machine.travel("Attack")
		
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		update_animation_parameters(direction)
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _process(delta):
	if near_door:
		if Input.is_action_just_pressed("interact"):
			get_tree().change_scene_to_file("res://Scenes/level_" + str(current_level) + ".tscn")
	if near_next:
		if Input.is_action_just_pressed("interact"):
			update_level()
			get_tree().change_scene_to_file("res://Scenes/level_" + str(current_level) + ".tscn")
	if near_return:
		if Input.is_action_just_pressed("interact"):
			get_tree().change_scene_to_file("res://Scenes/home.tscn")

func update_animation_parameters(move_input : float):
	if (move_input != 0):
		animation_tree.set("parameters/Idle/blend_position", move_input)
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Falling/blend_position", move_input)
		animation_tree.set("parameters/Rising/blend_position", move_input)
		animation_tree.set("parameters/Attack/blend_position", move_input)

func pick_new_state():
	if (velocity.y == 0):
		if (velocity.x == 0):
			state_machine.travel("Idle")
		else:
			state_machine.travel("Walk")
	else:
		if (velocity.y < 0):
			state_machine.travel("Rising")
		else:
			state_machine.travel("Falling")

func update_level():
	current_level += 1

func get_current_level():
	return current_level

func _on_area_2d_body_entered(body):
	if body is player:
		get_tree().reload_current_scene()

func _on_exit_home_body_entered(body):
	near_door = true

func _on_exit_home_body_exited(body):
	near_door = false

func _on_return_home_area_body_entered(body):
	near_return = true

func _on_return_home_area_body_exited(body):
	near_return = false

func _on_next_level_area_body_entered(body):
	near_next = true

func _on_next_level_area_body_exited(body):
	near_next = false
