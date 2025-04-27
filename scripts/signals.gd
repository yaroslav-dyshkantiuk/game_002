extends Node

signal enemy_attack(enemy_damage)
signal enemy_died(enemy_position)
signal day_time(state)

func emit_enemy_attack(enemy_damage):
	emit_signal("enemy_attack", enemy_damage)

func emit_enemy_died(enemy_position):
	emit_signal("enemy_died", enemy_position)

func emit_day_time(state):
	emit_signal("day_time", state)
