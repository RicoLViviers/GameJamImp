extends TileMap

var lbl: Label

func _ready() -> void:
	# Get the Label node from the scene tree
	lbl = get_node("../MoodSelector/Label")

func _process(_delta: float) -> void:
	# Check the text of the label and show or hide accordingly
	if lbl.text == "Joy":
		set_layer_enabled(0, true)
	else:
		set_layer_enabled(0, false)
