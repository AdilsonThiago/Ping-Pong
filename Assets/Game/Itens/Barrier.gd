extends Area

var player : Object

func _on_Area_body_entered(body):
	if body.is_in_group("ball"):
		body.linear_velocity.z = -body.linear_velocity.z
		player.ob_barrier = null
		queue_free()
	pass
