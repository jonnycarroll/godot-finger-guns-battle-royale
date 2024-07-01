extends AbstractController
class_name HumanController

func _process_physics(delta):
	var mouse_position = player.get_global_mouse_position()
	player.look_at(mouse_position)
	steady_avatar()
	
	if !match_started:
		idle_bobbing(delta)
		player.move_and_slide()
		return
	
	var input = Input.get_axis("down", "up")
	var strafe_input = Input.get_axis("left", "right")
	
	if input == 0 && strafe_input == 0:
		if player.velocity.length() > (player.FRICTION * delta):
			player.velocity -= player.velocity.normalized() * player.FRICTION * delta
		else:
			player.velocity = Vector2.ZERO
			idle_bobbing(delta)
	else:
		if input != 0:
			player.velocity += (player.transform.x * input * player.ACCELERATION * delta)
		if strafe_input != 0:
			player.velocity += (player.transform.y * strafe_input * player.ACCELERATION * delta)
		player.velocity = player.velocity.limit_length(player.MAX_SPEED)
		
	#	if Input.is_action_pressed("dash"):
	#			velocity *= 2
	#	if last_dash >= DASH_DELAY:
	#		if Input.is_action_pressed("dash"):
	#			velocity *= 1.2
	#			last_dash = 0.0
	#	else:
	#		if last_dash < DASH_DELAY:#
	#			velocity *= 1.2
	#		last_dash += delta
	player.move_and_slide()
	
	if Input.is_action_just_pressed("primary_fire") && player.can_primary_fire && match_started:
		player.primary_fire(mouse_position)
	
	if Input.is_action_just_pressed("secondary_fire") && player.can_secondary_fire && match_started:
		player.secondary_fire(mouse_position)
