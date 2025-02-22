extends CPUParticles2D

func _on_timer_timeout():
	self.queue_free()

func _on_tree_entered():
	pass # Replace with function body.
