extends CharacterBody2D

enum {
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE,
}

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var health: int = 100
var gold: int = 0
var state = MOVE
var run_speed: int = 1
var combo = false
var attack_coldown = false
var player_position

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if velocity.y > 0:
		animation_player.play("Fall")
		
	if health <= 0:
		health = 0
		animation_player.play("Death")
		await animation_player.animation_finished
		queue_free()
		get_tree().change_scene_to_file("res://menu.tscn")
	
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		ATTACK3:
			attack3_state() 
		BLOCK:
			block_state()
		SLIDE:
			slide_state()

	move_and_slide()

	player_position = self.position
	Signals.emit_signal("player_position_update", player_position)


func move_state() -> void:
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * run_speed
		if velocity.y == 0:
			if run_speed == 1:
				animation_player.play("Walk")
			else:
				animation_player.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animation_player.play("Idle")
	if direction == -1:
		animated_sprite_2d.flip_h = true
	elif direction == 1:
		animated_sprite_2d.flip_h = false
	if Input.is_action_pressed("run"):
		run_speed = 2
	else:
		run_speed = 1
	if Input.is_action_pressed("block"):
		if velocity.x == 0:
			state = BLOCK
		else:
			state = SLIDE
	if Input.is_action_just_pressed("attack") and attack_coldown == false:
		state = ATTACK

func block_state () -> void:
	animation_player.play("Block")
	if Input.is_action_just_released("block"):
		state = MOVE

func slide_state() -> void:
	animation_player.play("Slide")
	await animation_player.animation_finished
	state = MOVE

func attack_state() -> void:
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK2
	velocity.x = 0
	animation_player.play("Attack")
	await animation_player.animation_finished
	state = MOVE

func attack2_state() -> void:
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK3
	animation_player.play("Attack2")
	await animation_player.animation_finished
	attack_freeze()
	state = MOVE

func attack3_state() -> void:
	animation_player.play("Attack3")
	await animation_player.animation_finished
	state = MOVE

func combo1() -> void:
	combo = true
	await animation_player.animation_finished
	combo = false

func attack_freeze() -> void:
	attack_coldown = true
	await get_tree().create_timer(0.5).timeout
	attack_coldown = false
