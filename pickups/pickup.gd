extends Area2D
class_name Pickup

var random_seed = randi_range(0, 100)

func _process(delta):
	idle_bobbing(delta)
	
func idle_bobbing(delta):
	var idle_bobbing_amount = sin(random_seed + Time.get_ticks_msec() * delta * 0.20) * 0.1
	position.y += idle_bobbing_amount

func _on_body_entered(body):
	queue_free()
