extends Node2D

signal no_health()
signal damage_received()

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var damage_text: Label = $DamageText
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player_dmg = 0

var health = 100:
	set (value):
		health = value
		health_bar.value = health
		if health <= 0:
			health_bar.visible = false
		else:
			health_bar.visible = true

func _ready() -> void:
	Signals.connect("player_attack", Callable(self, "_on_damage_received"))
	damage_text.modulate = 0
	health_bar.max_value = health
	health_bar.visible = false

func _on_damage_received(player_damage):
	player_dmg = player_damage

func _on_hurt_box_area_entered(area: Area2D) -> void:
	health -= player_dmg
	damage_text.text = str(player_dmg)
	animation_player.stop()
	animation_player.play("damage_text")
	if health <= 0:
		emit_signal("no_health")
	else:
		emit_signal("damage_received")
