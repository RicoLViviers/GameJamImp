extends CanvasLayer
var time_scale = 0.5
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("mood_select"):
		$SelectionWheel.show()
	elif Input.is_action_just_released("mood_select"):
		var tool = $SelectionWheel.Close()
		if tool != "None":
			
			$Label.text = tool
		else:
			$Label.text = "Neutral"
