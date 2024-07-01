extends Node

signal player_fired(fired_by : Player, weapon : String, firing_position : Vector2, firing_direction : Vector2)
signal player_damaged(damaged_player : Player, attack : Attack)
signal player_killed(killed_player : Player, attack : Attack)
