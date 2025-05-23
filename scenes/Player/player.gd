extends CharacterBody2D

enum {
	MOVE,
	ATTACK,
	COMBO1,
	COMBO2,
	BLOCK,
	SLIDE,
	DAMAGE,
	CAST,
}

const SPEED = 120.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stats: CanvasLayer = $stats
@onready var leafs: GPUParticles2D = $Leafs
@onready var dust: GPUParticles2D = $Dust
@onready var smack: AudioStreamPlayer = $Sounds/Smack

var state = MOVE
var run_speed = 1
var combo = false
var attack_coldown = false
var damage_basic = 10
var damage_multiplier = 1
var damage_current
var recovery = false

func _ready() -> void:
	Signals.connect("enemy_attack", Callable (self, "_on_damage_received"))

func _physics_process(delta: float) -> void:
	if not Global.player_alive:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if velocity.y > 0:
		animation_player.play("Fall")
	
	Global.player_damage = damage_basic * damage_multiplier
	Global.player_position = self.position
	
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
	move_and_slide()

func _process(_delta: float) -> void:
	#dust.position = Global.player_position
	pass

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
		$AttackDirection.rotation_degrees = 180
	elif direction == 1:
		animated_sprite_2d.flip_h = false
		$AttackDirection.rotation_degrees = 0
		
	if Input.is_action_pressed("run") and not recovery:
		run_speed = 1.5
		stats.stamina -= stats.run_cost
	else:
		run_speed = 1
	
	stats.stamina_cost = stats.attack_cost
	if not recovery:
		if Input.is_action_just_pressed("attack") and attack_coldown == false and stats.stamina > stats.stamina_cost:
			state = ATTACK
		if Input.is_action_just_pressed("block") and velocity.x != 0 and stats.stamina > stats.stamina_cost:
			state = SLIDE
		elif Input.is_action_pressed("block") and velocity.x == 0 and stats.stamina > 1:
			state = BLOCK

func block_state() -> void:
	stats.stamina -= stats.block_cost
	animation_player.play("Block")
	if Input.is_action_just_released("block") or recovery:
		state = MOVE

func slide_state() -> void:
	animation_player.play("Slide")
	await animation_player.animation_finished
	state = MOVE

func attack_state() -> void:
	damage_multiplier = 1
	stats.stamina_cost = stats.attack_cost
	if Input.is_action_just_pressed("attack") and combo == true and stats.stamina > stats.stamina_cost:
		state = COMBO1
	velocity.x = 0
	animation_player.play("Attack")
	await animation_player.animation_finished
	state = MOVE

func combo1_state() -> void:
	damage_multiplier = 1.2
	stats.stamina_cost = stats.attack_cost
	if Input.is_action_just_pressed("attack") and combo == true and stats.stamina > stats.stamina_cost:
		state = COMBO2
	animation_player.play("Attack2")
	await animation_player.animation_finished
	attack_freeze()
	state = MOVE

func combo2_state() -> void:
	stats.stamina_cost = stats.attack_cost
	damage_multiplier = 2
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
	animation_player.play("Damage")
	await animation_player.animation_finished
	state = MOVE

func death():
	stats.health = 0
	Global.player_alive = false
	velocity.x = 0
	animation_player.play("Death")
	await animation_player.animation_finished
	queue_free()
	get_tree().change_scene_to_file.call_deferred("res://scenes/menu.tscn")

func _on_damage_received (enemy_damage):
	smack.play()
	if stats.health <= 0:
		death()
		return
	if state == BLOCK:
		enemy_damage /=2
	elif state == SLIDE:
		enemy_damage = 0
	else:
		state = DAMAGE
		damage_animation()
	stats.health -= enemy_damage

func _on_stats_no_stamina() -> void:
	recovery = true
	await get_tree().create_timer(2).timeout
	recovery = false

func damage_animation():
	animated_sprite_2d.modulate = Color(1, 0, 0, 1)
	velocity.x = 0
	if animated_sprite_2d.flip_h == true:
		velocity.x += 200
	else:
		velocity.x -= 200
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, 'velocity', Vector2.ZERO, 0.1)
	tween.parallel().tween_property(animated_sprite_2d, 'modulate', Color(1, 1, 1, 1), 0.1)

func steps():
	leafs.emitting = true
	leafs.one_shot = true
	
