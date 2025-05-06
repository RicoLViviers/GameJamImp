extends CharacterBody2D

# Movement and jump
var base_speed = 700
var speed = base_speed
var jump_force = -1200
var gravity = 4000
var is_jumping = false
var current_jump_force = jump_force

# Shake config
@export var shake_strength: float = 5.0
@export var shake_duration: float = 0.3
var shake_start_time: float
var shake_active: bool = false

# Mood durations
@export var Joy_Duration: float = 6.0
@export var Angry_Duration: float = 5.0
@export var Calm_Duration: float = 8.0
@export var Fear_Duration: float = 4.0
@export var Confidence_Duration: float = 6.0
@export var Sadness_Duration: float = 999.0  # Doesn't auto-drain

# Mood state
var time_scale = 1.0
var joy_timer = 0.0
var angry_timer = 0.0
var calm_timer = 0.0
var fear_timer = 0.0
var confidence_timer = 0.0
var sadness_timer = 0.0

var joy_active = false
var angry_active = false
var calm_active = false
var fear_active = false
var confidence_active = false
var sadness_active = false

# Floor tracking
var was_on_floor = false

# Nodes
var cam: Camera2D
var mood_label
var progress_bar
var overlay

func _ready():
	cam = $Camera2D
	mood_label = get_node("../MoodSelector/Label")
	progress_bar = get_node("../MoodSelector/ProgressBar")
	overlay = get_node("../MoodSelector/ColorOverlay") # Should be full screen

func _process(delta: float) -> void:
	var adjusted_delta = delta * time_scale
	var mood = mood_label.text

	# ---- Mood activation ----
	match mood:
		"Joy":
			if not joy_active:
				reset_mood()
				joy_active = true
				joy_timer = Joy_Duration
				overlay.color = Color(1.0, 1.0, 0.3, 0.25)
			current_jump_force = jump_force * 1.25
			speed = base_speed
			time_scale = 1.0

		"Angry":
			if not angry_active:
				reset_mood()
				angry_active = true
				angry_timer = Angry_Duration
				overlay.color = Color(1.0, 0.2, 0.2, 0.25)
			current_jump_force = jump_force
			speed = base_speed * 1.5
			time_scale = 0.5

		"Calm":
			if not calm_active:
				reset_mood()
				calm_active = true
				calm_timer = Calm_Duration
				overlay.color = Color(0.3, 0.6, 1.0, 0.2)
			current_jump_force = jump_force * 0.8
			speed = base_speed * 0.9
			time_scale = 1.25

		"Fear":
			if not fear_active:
				reset_mood()
				fear_active = true
				fear_timer = Fear_Duration
				overlay.color = Color(0.5, 0.0, 0.6, 0.3)
			current_jump_force = jump_force * 1.1
			speed = base_speed * 1.2
			time_scale = 0.75

		"Confidence":
			if not confidence_active:
				reset_mood()
				confidence_active = true
				confidence_timer = Confidence_Duration
				overlay.color = Color(0.2, 1.0, 0.5, 0.2)
			current_jump_force = jump_force * 1.2
			speed = base_speed * 1.3
			time_scale = 1.0

		"Sadness":
			if not sadness_active:
				reset_mood()
				sadness_active = true
				overlay.color = Color(0.0, 0.5, 0.8, 0.15)
			current_jump_force = jump_force * 0.7
			speed = base_speed * 0.6
			time_scale = 0.9

		_:
			reset_mood()

	# ---- Mood timers ----
	if joy_active:
		joy_timer -= delta
		progress_bar.value = (joy_timer / Joy_Duration) * 100.0
		if joy_timer <= 0:
			reset_mood()

	elif angry_active:
		angry_timer -= delta
		progress_bar.value = (angry_timer / Angry_Duration) * 100.0
		if angry_timer <= 0:
			reset_mood()

	elif calm_active:
		calm_timer -= delta
		progress_bar.value = (calm_timer / Calm_Duration) * 100.0
		if calm_timer <= 0:
			reset_mood()

	elif fear_active:
		fear_timer -= delta * (1.0 + velocity.length() / 800.0)
		progress_bar.value = (fear_timer / Fear_Duration) * 100.0
		if fear_timer <= 0:
			reset_mood()

	elif confidence_active:
		confidence_timer -= delta
		progress_bar.value = (confidence_timer / Confidence_Duration) * 100.0
		if confidence_timer <= 0:
			reset_mood()

	elif sadness_active:
		progress_bar.value = 100.0  # Stays full until player cures it manually

	# ---- Movement ----
	velocity.x = 0
	if Input.is_action_pressed("move_left"):
		velocity.x = -speed
		$AnimatedSprite2D.play("run")
		$AnimatedSprite2D.flip_h = true
	elif Input.is_action_pressed("move_right"):
		velocity.x = speed
		$AnimatedSprite2D.play("run")
		$AnimatedSprite2D.flip_h = false

	# Gravity
	var on_floor_now = is_on_floor()
	if not on_floor_now:
		velocity.y += gravity * adjusted_delta
		if velocity.y > 0:
			$AnimatedSprite2D.play("fall")
	else:
		velocity.y = 0

	# Landing detection for Angry mood shake
	if not was_on_floor and on_floor_now:
		if angry_active:
			start_camera_shake()
	was_on_floor = on_floor_now

	# Jumping
	if Input.is_action_just_pressed("jump") and on_floor_now:
		velocity.y = current_jump_force
		is_jumping = true
		$AnimatedSprite2D.play("jump")

	# Idle animation
	if velocity.x == 0 and velocity.y == 0:
		$AnimatedSprite2D.play("stand")

	move_and_slide()

func _on_floor():
	if is_on_floor():
		is_jumping = false

func start_camera_shake():
	if shake_active:
		return
	shake_active = true
	shake_start_time = Time.get_ticks_msec() / 1000.0
	call_deferred("_do_shake")

func _do_shake():
	var original_offset = cam.offset
	while (Time.get_ticks_msec() / 1000.0 - shake_start_time) < shake_duration:
		var offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		cam.offset = offset
		await get_tree().process_frame
	cam.offset = original_offset
	shake_active = false

func reset_mood():
	joy_active = false
	angry_active = false
	calm_active = false
	fear_active = false
	confidence_active = false
	sadness_active = false

	joy_timer = 0.0
	angry_timer = 0.0
	calm_timer = 0.0
	fear_timer = 0.0
	confidence_timer = 0.0

	progress_bar.value = 0.0

	current_jump_force = jump_force
	speed = base_speed
	time_scale = 1.0
	overlay.color = Color(0, 0, 0, 0)
