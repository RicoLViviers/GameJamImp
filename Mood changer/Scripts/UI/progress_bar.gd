extends ProgressBar

@export var player: CharacterBody2D

func _ready() -> void:
	player.joyChanged.connect(update)
	update()

func update():
	value = player.currentJoy * 100 / player.maxJoy
	print(value)
