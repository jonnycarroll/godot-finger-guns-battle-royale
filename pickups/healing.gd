extends Pickup
class_name Healing

@export var health : int = 10

func _on_body_entered(body):
	if body.has_method("take_healing"):
		body.take_healing(health)
		queue_free()
