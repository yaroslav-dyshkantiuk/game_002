extends Node2D

@onready var mobs: Node2D = $".."
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var spawn_count = 0

var mushroom_preload = preload("res://scenes/mobs/mushroom.tscn")
var skeleton_preload = preload("res://scenes/mobs/skeleton.tscn")
 
func _ready() -> void:
	Signals.connect("day_time", Callable(self, "_on_time_changed"))

func _on_time_changed(state, day_count):
	spawn_count = 0
	var rng = randi_range(0, 2)
	if state == 1:
		for i in (day_count + rng):
			animation_player.play("spawn")
			await animation_player.animation_finished
			spawn_count += 1
	if spawn_count == day_count + rng:
		animation_player.play("idle")

func enemy_spawn():
	var rng = randi_range(1, 2)
	if rng == 1:
		mushroom_spawn()
	elif rng == 2:
		skeleton_spawn()

func mushroom_spawn():
	var mushroom = mushroom_preload.instantiate()
	mushroom.position = Vector2(self.position.x, 480)
	mobs.add_child(mushroom)

func skeleton_spawn():
	var skeleton = skeleton_preload.instantiate()
	skeleton.position = Vector2(self.position.x, 480)
	mobs.add_child(skeleton)
