extends Projectile
class_name Orange

@onready var explosion_particles = $ExplosionParticles

var detonated : bool = false

func detonate():
	if !detonated:
		detonated = true
		hit_box.set_disabled(false)
		get_tree().create_timer(0.1).timeout.connect(_disable_hitbox)
		
		speed = 0.0
		explosion_particles.emitting = true
		sprite_2d.visible = false
		lifetime_timer.start(0.55) # set this time to allow for the explosion animation

func _on_impact(body : Player):
	detonate()

func _on_impact_walls(area : Area2D):
	if area.is_in_group("arena_walls"):
		detonate()

func _on_lifetime_expired():
	if !detonated:
		detonate()
	else:
		queue_free()

func _disable_hitbox():
	hit_box.set_disabled(true)
