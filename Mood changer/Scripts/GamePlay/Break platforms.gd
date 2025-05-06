extends TileMap

var lbl: Label
@export var player: CharacterBody2D
func _ready() -> void:
	# Get the Label node from the scene tree
	lbl = get_node("../MoodSelector/Label")
var isPlatformGood = true
func _process(_delta: float) -> void:
	# Check the text of the label and show or hide accordingly
	if lbl.text == "Angry":
		if player.is_on_floor:
			if player.is_on_floor():
				if $Area2D.is_in_group("Player"):
					
					isPlatformGood = false
	if isPlatformGood == true:
		set_layer_enabled(0, true)
	else:
		set_layer_enabled(0, false)
