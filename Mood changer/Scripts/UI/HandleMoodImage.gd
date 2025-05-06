extends TextureRect

func _process(delta: float) -> void:
	var label = get_parent().get_node("Label")
	if label and label.text == "Angry":
		texture = load("res://Sprites/Emotions/anger.png")
	if label and label.text == "Calm":
		texture = load("res://Sprites/Emotions/calm.png")
	if label and label.text == "Confidence":
		texture = load("res://Sprites/Emotions/Confidence.png")
	if label and label.text == "Fear":
		texture = load("res://Sprites/Emotions/Fear.png")
	if label and label.text == "Joy":
		texture = load("res://Sprites/Emotions/joy.png")
	if label and label.text == "Sadness":
		texture = load("res://Sprites/Emotions/Sadness.png")
	if label and label.text == "Neutral":
		texture = load("res://Sprites/Emotions/neutral.png")
		
