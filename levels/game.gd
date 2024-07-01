extends Node2D
class_name Game

const PLAYER_RESPAWN_TIMER : float = 3.0
const MAX_PICKUPS : int = 5
const PICKUP_SPAWN_TIMER : float = 1.5

@onready var arena_centre : Marker2D = $Arena/ArenaCentre
@onready var field = $Arena/Field
@onready var player_spawn_zones : Node = $Arena/PlayerSpawnZones
@onready var players : Node = $Players
@onready var projectiles : Node = $Projectiles
@onready var pickups = $Pickups
@onready var pickup_spawn_timer = $Arena/Timers/PickupSpawnTimer
@onready var ui : UI = $UI

signal match_started
var match_has_started : bool = false

var player_scene : PackedScene = preload("res://characters/player.tscn")
var temp_spawn_zones : Array[Node]
# weapons
var stapler_scene : PackedScene = preload("res://weapons/stapler.tscn")
var orange_scene : PackedScene = preload("res://weapons/orange.tscn")
# pickups
var pickup_scenes : Array[PackedScene] = [
	preload("res://pickups/healing.tscn"),
	preload("res://pickups/grenade.tscn")
]
# UI
var game_stats : Dictionary = {}
var player_to_monitor : Player

func _ready():
	temp_spawn_zones = player_spawn_zones.get_children()
	player_to_monitor = spawn_human_player()
	for n in 5:
		spawn_ai_player()
	temp_spawn_zones = player_spawn_zones.get_children()
	SignalBus.player_fired.connect(_on_player_fired)
	SignalBus.player_damaged.connect(_on_player_damaged)
	SignalBus.player_killed.connect(_on_player_killed)

func spawn_human_player() -> Player:
	var player = spawn_player(HumanController.new())
	game_stats[player] = PlayerStats.new()
	return player

func spawn_ai_player():
	var player = spawn_player(AbstractController.new())
	game_stats[player] = PlayerStats.new()

func spawn_player(controller : AbstractController) -> Player:
	var player : Player = player_scene.instantiate() as Player
	# set up the player controller
	controller.player = player
	match_started.connect(controller._on_match_started)
	player.controller = controller
	# figure out where to spawn the player
	var player_spawn_count = temp_spawn_zones.size()
	var spawn_zone_index = randi() % player_spawn_count
	var marker : Marker2D = temp_spawn_zones[spawn_zone_index]
	temp_spawn_zones.remove_at(spawn_zone_index)
	# position the player
	player.position = marker.position
	players.add_child(player)
	player.look_at(arena_centre.global_position)
	return player

func spawn_projectile(player : Player, weapon : String, spawn_position : Vector2, direction : Vector2):
	var projectile : Projectile
	match weapon:
		"stapler":
			projectile = stapler_scene.instantiate() as Projectile
		"orange":
			projectile = orange_scene.instantiate() as Orange
		_:
			push_error("Unknown weapon type: " + weapon)
	# vector math for area2d
	projectile.rotation = direction.angle()
	# vector math for rigidbody2d
	projectile.position = spawn_position
	projectile.direction = direction
	projectile.fired_by = player
	projectiles.add_child(projectile)

func spawn_pickup():
	if pickups.get_child_count() < MAX_PICKUPS:
		# randomly select a pickup to spawn
		var pickup_scene : PackedScene = pickup_scenes.pick_random()
		var pickup : Pickup = pickup_scene.instantiate()
		# pick random location in the arean
		var spawn_dimensions : Vector2i = field.texture.get_size() * field.scale
		var spawn_location = Vector2(randi_range(field.global_position.x-spawn_dimensions.y+90, field.global_position.x-90), \
			randi_range(field.global_position.y+90, spawn_dimensions.x-field.global_position.y-90))
		# set the position and add the child to pickups node
		pickup.position = spawn_location
		pickups.add_child(pickup)

func _on_player_fired(player : Player, weapon : String, firing_position : Vector2, firing_direction : Vector2):
	spawn_projectile(player, weapon, firing_position, firing_direction)

func _on_player_damaged(player : Player, attack : Attack):
	game_stats[player].damage_taken += attack.damage
	game_stats[attack.attacker].damage_dealt += attack.damage

func _on_player_killed(player : Player, killed_by : Player):
	game_stats[player].deaths += 1
	if player != killed_by:
		game_stats[killed_by].kills += 1
	call_deferred("_reset_and_respawn_player", player)

func _on_match_start_timer_timeout():
	match_started.emit()
	pickup_spawn_timer.start(randf_range(PICKUP_SPAWN_TIMER-0.1, PICKUP_SPAWN_TIMER+0.1))

func _reset_and_respawn_player(player : Player):
	# disable the player
	player.process_mode = Node.PROCESS_MODE_DISABLED
	players.remove_child(player)
	await get_tree().create_timer(PLAYER_RESPAWN_TIMER).timeout
	# reset the player
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.reset()
	# position the player
	var marker : Marker2D = temp_spawn_zones[randi() % temp_spawn_zones.size()]
	player.position = marker.position
	players.add_child(player)
	player.look_at(arena_centre.global_position)

func _on_pickup_spawn_timer_timeout():
	spawn_pickup()
