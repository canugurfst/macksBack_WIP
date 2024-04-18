extends KinematicBody2D

export(float) var move_speed = 300
export(float) var jump_impulse = 600

enum STATE { IDLE, RUN, JUMP }

onready var animation_tree = $AnimationTree
onready var animated_sprite = $AnimatedSprite

signal changed_state(new_state_string, new_state_id)

var velocity: Vector2
var current_state = STATE.IDLE setget set_current_state
var jumps = 0

func _physics_process(delta):
	var input = get_player_input()

	adjust_flip_direction(input)

	velocity = Vector2(
		input.x * move_speed,
		min(velocity.y + GameSettings.gravity, GameSettings.terminal_velocity)
	)
	velocity = move_and_slide(velocity, Vector2.UP)
	
	set_anim_parameters()
	
	pick_next_state()
	
func adjust_flip_direction(input: Vector2):
	if (sign(input.x) == -1):
		animated_sprite.flip_h = false
	elif (sign(input.x) == 1):
		animated_sprite.flip_h = true
	
func set_anim_parameters():
	animation_tree.set("parameters/x_sign/blend_position", sign(velocity.x))
	animation_tree.set("parameters/y_sign/blend_amount", sign(velocity.y))

func pick_next_state():
	if (is_on_floor()):
		jumps = 0
		
		if (Input.is_action_just_pressed("jump")):
			self.current_state = STATE.JUMP
		elif (abs(velocity.x) > 0):
			self.current_state = STATE.RUN
		else:
			self.current_state = STATE.IDLE
	else:
		
		# DOUBLE JUMP
		
		pass
	
func get_player_input():
	var input: Vector2
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	return input
	
func jump():
	velocity.y = -jump_impulse
	jumps += 1

func set_current_state(new_state):
	match(new_state):
		STATE.JUMP:
			jump()
	current_state = new_state
	
	emit_signal("changed_state", STATE.keys()[new_state], new_state)
