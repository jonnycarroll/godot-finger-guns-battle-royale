extends Area2D
class_name HurtBox

func _ready():
	area_entered.connect(_on_hit_area_entered)

func _on_hit_area_entered(hitbox : HitBox):
	if owner.has_method("take_damage") && hitbox.owner.has_method("create_attack"):
		owner.take_damage(hitbox.owner.create_attack())

func _on_heal_area_entered(healbox : Node):
#	if owner.has_method("take_healing"):
#		owner.take_healing(healbox.health)
	pass
