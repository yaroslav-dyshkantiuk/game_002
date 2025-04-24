extends Node2D

@onready var light_animation: AnimationPlayer = $Light/LightAnimation
@onready var day_text: Label = $CanvasLayer/DayText
@onready var player: CharacterBody2D = $Player/Player

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT,
}

var state: int = MORNING
var day_count: int

func _ready() -> void:
	day_count = 0
	morning_state()

func _on_day_night_timeout() -> void:
	if state < 3:
		state += 1
	else:
		state = MORNING
		
	match state:
		MORNING:
			morning_state()
		EVENING:
			evening_state()

func morning_state():
	day_count +=1
	day_text.text = "DAY " + str(day_count)
	light_animation.play("sunrise")

func evening_state():
	light_animation.play("sunset")
