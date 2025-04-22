extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func _on_attack_range_body_entered(body: Node2D) -> void:
	animation_player.play("Attack")
