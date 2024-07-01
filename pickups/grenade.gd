extends Pickup
class_name Grenade

func _on_body_entered(body):
	if body.has_method("add_secondary_ammo"):
		body.add_secondary_ammo("grenade")
		queue_free()
