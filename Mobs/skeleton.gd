extends CharacterBody2D

var chase = false 
var speed = 100
var alive = true
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	var player = $"../../Player/Player"
	var direction = (player.global_position - self.global_position).normalized()
	if alive == true:
		if chase == true:
			velocity.x = direction.x * speed
			animated_sprite_2d.play("Run")
		else:
			velocity.x = 0
			animated_sprite_2d.play("Idle")
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	
	move_and_slide()


func _on_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true

func _on_detector_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false

func _on_death_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.velocity.y -=200
		death()
		
func _on_death_2_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if alive == true:
			body.health -= 40
		death()


func death() -> void:
	alive = false
	animated_sprite_2d.play("Death")
	await animated_sprite_2d.animation_finished
	queue_free()
