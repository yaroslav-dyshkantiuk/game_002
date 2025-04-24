extends CharacterBody2D

enum {
	IDLE,
	ATTACK,
	CHASE,
	DAMAGE,
	DEATH,
	RECOVER,
}
var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			DAMAGE:
				damage_state()
			DEATH:
				death_state()
			RECOVER:
				recover_state()

var player
var direction
var damage = 20
var player_is_dead = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	Signals.connect("player_position_update", Callable (self, "_on_player_positon_update"))
	Signals.connect("player_died", Callable(self, "_on_player_died"))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if state == CHASE:
		chase_state()
	
	move_and_slide()

func _on_player_positon_update(player_position):
	player = player_position

func _on_attack_range_body_entered(_body: Node2D) -> void:
	state = ATTACK

func idle_state():
	animation_player.play("Idle")
	state = CHASE
	
func attack_state():
	if player_is_dead:
		state = IDLE
		return
	animation_player.play("Attack")
	await animation_player.animation_finished
	state = RECOVER
	
func chase_state():
	if player_is_dead:
		return
	direction = (player - self.position).normalized()
	if direction.x < 0:
		animated_sprite_2d.flip_h = true
		$AttackDirection.scale = Vector2(-1,1)
	else:
		animated_sprite_2d.flip_h = false
		$AttackDirection.scale = Vector2(1,1)

func damage_state():
	animation_player.play("Damage")
	await animation_player.animation_finished
	state = IDLE

func death_state():
	animation_player.play("Death")
	await  animation_player.animation_finished
	queue_free()

func recover_state():
	animation_player.play("Recover")
	await  animation_player.animation_finished
	state = IDLE

func _on_hit_box_area_entered(_area: Area2D) -> void:
	Signals.emit_enemy_attack(damage)

func _on_player_died():
	player_is_dead = true
	state = IDLE

func _on_mob_health_no_health() -> void:
	state = DEATH

func _on_mob_health_damage_received() -> void:
	state = IDLE
	state = DAMAGE
