extends CharacterBody2D

enum {
	IDLE,
	ATTACK,
	CHASE,
}
var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
var player
var direction

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	Signals.connect("player_position_update", Callable (self, "_on_player_positon_update"))

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
	await get_tree().create_timer(1).timeout
	$AttackDirection/AttackRange/CollisionShape2D.disabled = false
	state = CHASE
	
func attack_state():
	animation_player.play("Attack")
	await animation_player.animation_finished
	$AttackDirection/AttackRange/CollisionShape2D.disabled = true
	state = IDLE
	
func chase_state():
	direction = (player - self.position).normalized()
	if direction.x < 0:
		animated_sprite_2d.flip_h = true
		$AttackDirection.scale = Vector2(-1,1)
	else:
		animated_sprite_2d.flip_h = false
		$AttackDirection.scale = Vector2(1,1)
	
