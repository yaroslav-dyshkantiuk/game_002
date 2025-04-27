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

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	player = Global.player_position
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if state == CHASE:
		chase_state()
	move_and_slide()

func _on_attack_range_body_entered(_body: Node2D) -> void:
	if Global.player_alive:
		state = ATTACK

func idle_state():
	animation_player.play("Idle")
	state = CHASE
	
func attack_state():
	animation_player.play("Attack")
	await animation_player.animation_finished
	state = RECOVER
	
func chase_state():
	direction = (player - self.position).normalized()
	if direction.x < 0:
		animated_sprite_2d.flip_h = true
		$AttackDirection.scale = Vector2(-1,1)
	else:
		animated_sprite_2d.flip_h = false
		$AttackDirection.scale = Vector2(1,1)

func damage_state():
	damage_animation()
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

func _on_mob_health_no_health() -> void:
	state = DEATH

func _on_mob_health_damage_received() -> void:
	state = IDLE
	state = DAMAGE

func damage_animation():
	velocity.x = 0
	direction = (player - self.position).normalized()
	if direction.x < 0:
		velocity.x += 200
	elif direction.x > 0:
		velocity.x -= 200
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'velocity', Vector2.ZERO, 0.1)
