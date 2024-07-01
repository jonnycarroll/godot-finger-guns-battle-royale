extends Area2D
class_name HitBox

@export var collison_shape : CollisionShape2D

func set_disabled(is_disabled : bool):
	collison_shape.set_deferred("disabled", is_disabled)
