extends Node2D
class_name Projectile

const DEFAULT_SPEED = 1000.0

@export var lifetime = 0.7
@export var damage = 10

@onready var sprite_2d = $Sprite2D
@onready var lifetime_timer = $LifetimeTimer
@onready var impact_detector = $ImpactDetector
@onready var hit_box = $HitBox

var direction = Vector2.ZERO
var speed = DEFAULT_SPEED
var fired_by : Player

func _ready():
	var degrees = rad_to_deg(rotation)
	sprite_2d.flip_v = (degrees > 100 or degrees < -100)
	lifetime_timer.timeout.connect(_on_lifetime_expired)
	lifetime_timer.start(lifetime)
	impact_detector.body_entered.connect(_on_impact)
	impact_detector.area_entered.connect(_on_impact_walls)

func _physics_process(delta):
	position += direction * speed * delta

func _on_impact(body : Player):
	queue_free()

func _on_impact_walls(area : Area2D):
	if area.is_in_group("arena_walls"):
		queue_free()

func _on_lifetime_expired():
	queue_free()

func create_attack() -> Attack:
	var attack : Attack = Attack.new()
	attack.attacker = fired_by
	attack.damage = damage
	return attack
