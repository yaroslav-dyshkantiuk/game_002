extends Node2D

signal no_health()
signal damage_received()

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var damage_text: Label = $DamageText
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var max_health = 100

var health = 100:
	set (value):
		health = value
		health_bar.value = health
		if health <= 0:
			health_bar.visible = false
		else:
			health_bar.visible = true

func _ready() -> void:
	damage_text.modulate = 0
	health_bar.max_value = max_health
	health = max_health
	health_bar.visible = false

func _on_hurt_box_area_entered(_area: Area2D) -> void:
	health -= Global.player_damage
	damage_text.text = str(Global.player_damage)
	animation_player.stop()
	animation_player.play("damage_text")
	if health <= 0:
		emit_signal("no_health")
	else:
		emit_signal("damage_received")
