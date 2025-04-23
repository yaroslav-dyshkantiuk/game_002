extends Node

signal player_position_update (player_position)

func emit_player_position_update(player_position):
	emit_signal("player_position_update", player_position)

signal enemy_attack (enemy_damage)

func emit_enemy_attack(enemy_damage):
	emit_signal("enemy_attack", enemy_damage)

signal player_died

func emit_player_died():
	emit_signal("player_died")
