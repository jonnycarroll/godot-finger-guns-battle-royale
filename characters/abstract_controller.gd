class_name AbstractController

var player : Player
var match_started : bool = false

var random_seed = randi_range(0, 100)

func _process_physics(delta):
	steady_avatar()
	idle_bobbing(delta)

func _on_match_started():
	match_started = true

func idle_bobbing(delta):
	var idle_bobbing_amount = sin(random_seed + Time.get_ticks_msec() * delta * 0.20) * 0.5
	player.position.y += idle_bobbing_amount

func steady_avatar():
	player.avatar.rotation = -player.rotation
