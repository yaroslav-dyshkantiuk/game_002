extends Node

signal enemy_attack(enemy_damage)

func emit_enemy_attack(enemy_damage):
	emit_signal("enemy_attack", enemy_damage)
