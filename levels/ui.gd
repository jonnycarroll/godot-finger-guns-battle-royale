extends CanvasLayer
class_name UI

@onready var player_name = $ColorRect/MarginContainer/VBoxContainer/Player/PlayerName
@onready var progress_bar = $ColorRect/MarginContainer/VBoxContainer/Player/ProgressBar
@onready var kill_counter = $ColorRect/MarginContainer/VBoxContainer/PlayerStats/LifeStats/Kills/KillCounter
@onready var death_counter = $ColorRect/MarginContainer/VBoxContainer/PlayerStats/LifeStats/Deaths/DeathCounter
@onready var damage_dealt_counter = $ColorRect/MarginContainer/VBoxContainer/PlayerStats/DamageStats/Dealt/Counter
@onready var damage_taken_counter = $ColorRect/MarginContainer/VBoxContainer/PlayerStats/DamageStats/Taken/Counter

@onready var grenades_counter = $ColorRect/MarginContainer/VBoxContainer/PowerUps/HBoxContainer/Grenades/Counter

func _process(delta):
	if owner && owner.game_stats && owner.player_to_monitor:
		var player_stats : PlayerStats = owner.game_stats[owner.player_to_monitor]
		progress_bar.value = owner.player_to_monitor.health
		kill_counter.text = str(player_stats.kills)
		death_counter.text = str(player_stats.deaths)
		damage_dealt_counter.text = str(player_stats.damage_dealt)
		damage_taken_counter.text = str(player_stats.damage_taken)
		grenades_counter.text = str(owner.player_to_monitor.secondary_firing_amount)
