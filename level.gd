extends Node2D

@onready var light: DirectionalLight2D = $DirectionalLight2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var point_light_2d_2: PointLight2D = $PointLight2D2
@onready var day_text: Label = $CanvasLayer/DayText
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT,
}

var state: int = MORNING
var day_count: int

func _ready() -> void:
	light.enabled = true
	day_count = 1
	set_day_text()
	day_text_fade()

func morning_state():
	var tween = get_tree().create_tween()
	tween.tween_property(light,"energy", 0.2, 20)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(point_light_2d,"energy", 0, 20)
	var tween3 = get_tree().create_tween()
	tween3.tween_property(point_light_2d_2,"energy", 0, 20)

func evening_state():
	var tween = get_tree().create_tween()
	tween.tween_property(light,"energy", 0.95, 20)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(point_light_2d,"energy", 1.5, 20)
	var tween3 = get_tree().create_tween()
	tween3.tween_property(point_light_2d_2,"energy", 1.5, 20)

func _on_day_night_timeout() -> void:
	match state:
		MORNING:
			morning_state()
		EVENING:
			evening_state()
	
	if state < 3:
		state += 1
	else:
		state = MORNING
		day_count += 1
		set_day_text()
		day_text_fade()
		
		
func day_text_fade():
	animation_player.play("day_text_fade_in")
	await get_tree().create_timer(3).timeout
	animation_player.play("day_text_fade_out")
		
func set_day_text():
	day_text.text = "DAY " + str(day_count)
