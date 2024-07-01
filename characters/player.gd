extends CharacterBody2D
class_name Player

const MAX_SPEED = 800.0
const ACCELERATION = 3000.0
const FRICTION = 2000.0
#const DASH_DELAY = 0.6

enum FIRING_MODE {SINGLE, RAPID, MULTI}

@export var default_accuracy_reduction : float = 0.05
@export var default_health : int = 100

@onready var avatar = $Avatar
@onready var hands = $Hands
@onready var left_muzzle = $Hands/LeftMuzzle
@onready var right_muzzle = $Hands/RightMuzzle
@onready var secondary_muzzle = $Hands/SecondaryMuzzle
@onready var primary_fire_cooldown = $Timers/PrimaryFireCooldown
@onready var secondary_fire_cooldown = $Timers/SecondaryFireCooldown

var controller : AbstractController
#var last_dash : float = 0.0
var muzzle_markers : Array = []
var next_muzzle : bool = false
var can_primary_fire : bool = true
var can_secondary_fire : bool = true
var accuracy_reduction : float = 0.0

var primary_firing_mode : FIRING_MODE # single shot, rapid fire, multi-shot
var secondary_firing_weapon # grenade
var secondary_firing_amount : int = 2

var health : int = default_health:
	set(value):
		if value <= 0:
			value = 0
		health = value

func _ready():
	muzzle_markers.append(left_muzzle)
	muzzle_markers.append(right_muzzle)
	accuracy_reduction = default_accuracy_reduction

func _physics_process(delta):
	controller._process_physics(delta)

func primary_fire(mouse_position):
	can_primary_fire = false
	primary_fire_cooldown.start()
	var muzzle_position = muzzle_markers[int(next_muzzle)].global_position
	var firing_direction = muzzle_position.direction_to(fuzzy_mouse_position(mouse_position))
	SignalBus.player_fired.emit(self, "stapler", muzzle_position, firing_direction)
	next_muzzle = !next_muzzle

func secondary_fire(mouse_position):
	if secondary_firing_amount > 0:
		can_secondary_fire = false
		secondary_fire_cooldown.start()
		var muzzle_position = secondary_muzzle.global_position
		var firing_direction = muzzle_position.direction_to(fuzzy_mouse_position(mouse_position))
		SignalBus.player_fired.emit(self, "orange", muzzle_position, firing_direction)
		secondary_firing_amount -= 1

func _on_primary_fire_cooldown_timeout():
	can_primary_fire = true

func _on_secondary_fire_cooldown_timeout():
	can_secondary_fire = true

func take_damage(attack : Attack):
	SignalBus.player_damaged.emit(self, attack)
	var new_health = health - attack.damage
	if new_health <= 0:
		SignalBus.player_killed.emit(self, attack.attacker)
	health = new_health

func take_healing(amount : int):
	health += amount

func add_secondary_ammo(weapon):
	secondary_firing_amount += 1

func change_primary_firing_mode():
	pass

func fuzzy_mouse_position(mouse_position) -> Vector2:
	return mouse_position * randf_range(1 - accuracy_reduction, 1 + accuracy_reduction)

func reset():
	health = default_health
	primary_firing_mode = FIRING_MODE.SINGLE
	secondary_firing_amount = 2
