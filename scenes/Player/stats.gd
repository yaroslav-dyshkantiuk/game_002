extends CanvasLayer

signal no_stamina()

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var stamina_bar: TextureProgressBar = $StaminaBar
@onready var health_text: Label = $"../HealthText"
@onready var health_animation: AnimationPlayer = $"../HealthAnimation"

var stamina_cost
var attack_cost = 10
var block_cost = 0.5
var slide_cost = 20
var run_cost = 0.3
var max_health = 120
var old_health = max_health

var stamina = 50:
	set(value):
		stamina = value
		if stamina < 1:
			emit_signal("no_stamina")
var health:
	set(value):
		health = clamp(value, 0, max_health)
		health_bar.value = health
		var difference = health - old_health
		health_text.text = str(difference)
		old_health = health
		if difference < 0:
			health_animation.play("damage_received")
		if difference > 0:
			health_animation.play("health_received")

func _ready() -> void:
		health_text.modulate.a = 0
		health = max_health
		health_bar.max_value = health
		health_bar.value = health

func _process(delta: float) -> void:
	stamina_bar.value = stamina
	if stamina < 100:
		stamina += 0.05 + delta

func stamina_consumption():
	stamina -= stamina_cost


func _on_health_regen_timeout() -> void:
	health += 1
