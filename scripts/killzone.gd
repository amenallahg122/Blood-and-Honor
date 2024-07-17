extends Area2D

@onready var timer = $Timer

@warning_ignore("unused_parameter")
func _on_body_entered(body):
	if body is Player:
		print("you died!")
		timer.start()

func _on_timer_timeout():
	get_tree().reload_current_scene()
