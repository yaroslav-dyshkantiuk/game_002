extends CharacterBody2D

signal health_changed(new_health)

enum {
	MOVE,
	ATTACK,
	COMBO1,
	COMBO2,
	BLOCK,
	SLIDE,
	DAMAGE,
	CAST,
	DEATH,
}

const SPEED = 120.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var max_health = 120
var health: int
var gold: int = 0
var state = MOVE
var run_speed: int = 1
var combo = false
var attack_coldown = false
var player_position
var is_dead = false

func _ready() -> void:
	Signals.connect("enemy_attack", Callable (self, "_on_damage_received"))
	health = max_health

func _physics_process(delta: float) -> void:
	if is_dead and state != DEATH:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if velocity.y > 0:
		animation_player.play("Fall")
	
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		COMBO1:
			combo1_state()
		COMBO2:
			combo2_state() 
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
		DAMAGE:
			damage_state()
		DEATH:
			death_state()

	
	move_and_slide()
	
	player_position = self.position
	Signals.emit_player_position_update(player_position)

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
		state = COMBO1
	velocity.x = 0
	animation_player.play("Attack")
	await animation_player.animation_finished
	state = MOVE

func combo1_state() -> void:
	if Input.is_action_just_pressed("attack") and combo == true:
		state = COMBO2
	animation_player.play("Attack2")
	await animation_player.animation_finished
	attack_freeze()
	state = MOVE

func combo2_state() -> void:
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

func damage_state():
	velocity.x = 0
	animation_player.play("Damage")
	await animation_player.animation_finished
	state = MOVE

func death_state():
	print("Death")
	velocity.x = 0
	Signals.emit_player_died()
	animation_player.play("Death")
	await animation_player.animation_finished
	queue_free()
	get_tree().change_scene_to_file.call_deferred("res://scenes/menu.tscn")

func _on_damage_received (enemy_damage):
	if is_dead:
		return  # Вже мертвий — ігноруємо подальші атаки
	health -= enemy_damage
	if health <= 0:
		health = 0
		is_dead = true
		death_state()
	else:
		state = DAMAGE
		emit_signal("health_changed", health)
		print(health)
