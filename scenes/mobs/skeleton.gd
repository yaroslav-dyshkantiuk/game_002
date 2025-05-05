extends Enemy

func _on_mob_health_no_health() -> void:
	if state != DEATH:
		state = DEATH

func _on_mob_health_damage_received() -> void:
	state = IDLE
	state = DAMAGE
