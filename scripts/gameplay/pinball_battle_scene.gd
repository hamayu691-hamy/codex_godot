extends Node2D

const BALL_START_POSITION: Vector2 = Vector2(200.0, 120.0)
const LEFT_FLIPPER_REST_ROTATION: float = -0.35
const LEFT_FLIPPER_ACTIVE_ROTATION: float = -1.0
const RIGHT_FLIPPER_REST_ROTATION: float = 0.35
const RIGHT_FLIPPER_ACTIVE_ROTATION: float = 1.0
const FLIPPER_ROTATE_SPEED: float = 14.0
const BALL_MAX_SPEED: float = 1350.0
const BALL_LAUNCH_IMPULSE: Vector2 = Vector2(120.0, -750.0)
const FLIPPER_HIT_IMPULSE: float = 1600.0
const DAMAGE_POPUP_DURATION: float = 0.55
const DAMAGE_POPUP_RISE: float = 24.0
# Minimum angular speed (rad/s) to treat the flipper as actively striking. Tune for feel.
const FLIPPER_ACTIVE_ANGULAR_SPEED_THRESHOLD: float = 3.0
const ENEMY_HP_INITIAL: int = 20
const BUMPER_GROUP: StringName = &"bumpers"
const BUMPER_COLLISION_RADIUS: float = 18.0
const BUMPER_VISUAL_COLOR: Color = Color(0.2, 0.9, 0.95, 1.0)
const BUMPER_VISUAL_POINTS: Array[Vector2] = [
	Vector2(0.0, -18.0),
	Vector2(9.0, -15.5885),
	Vector2(15.5885, -9.0),
	Vector2(18.0, 0.0),
	Vector2(15.5885, 9.0),
	Vector2(9.0, 15.5885),
	Vector2(0.0, 18.0),
	Vector2(-9.0, 15.5885),
	Vector2(-15.5885, 9.0),
	Vector2(-18.0, 0.0),
	Vector2(-15.5885, -9.0),
	Vector2(-9.0, -15.5885),
]

@onready var ball: RigidBody2D = $Ball
@onready var left_flipper: StaticBody2D = $LeftFlipper
@onready var right_flipper: StaticBody2D = $RightFlipper
@onready var drain: Area2D = $Drain
@onready var bumpers_root: Node = $Bumpers
@onready var bumpers: Array[Bumper] = []
@onready var enemy_hp_label: Label = $EnemyHpLabel
@onready var victory_label: Label = $VictoryLabel

var bumper_configs: Array[Dictionary] = [
	{
		"position": Vector2(130.0, 210.0),
		"damage": 1,
		"impulse_strength": 130.0,
		"bumper_type": "normal",
	},
	{
		"position": Vector2(200.0, 165.0),
		"damage": 1,
		"impulse_strength": 130.0,
		"bumper_type": "normal",
	},
	{
		"position": Vector2(270.0, 210.0),
		"damage": 1,
		"impulse_strength": 130.0,
		"bumper_type": "normal",
	},
]

var _left_pressed: bool = false
var _right_pressed: bool = false
var _previous_left_rotation: float = LEFT_FLIPPER_REST_ROTATION
var _previous_right_rotation: float = RIGHT_FLIPPER_REST_ROTATION
var _left_angular_speed: float = 0.0
var _right_angular_speed: float = 0.0
var _enemy_hp: int = ENEMY_HP_INITIAL
var _is_victory: bool = false
var _damage_popups: Array[Dictionary] = []


func _ready() -> void:
	left_flipper.rotation = LEFT_FLIPPER_REST_ROTATION
	right_flipper.rotation = RIGHT_FLIPPER_REST_ROTATION
	_previous_left_rotation = left_flipper.rotation
	_previous_right_rotation = right_flipper.rotation
	drain.body_entered.connect(_on_drain_body_entered)
	ball.body_entered.connect(_on_ball_body_entered)
	_spawn_bumpers()
	for bumper_node: Node in bumpers_root.get_children():
		if bumper_node is Bumper:
			var bumper: Bumper = bumper_node
			bumpers.append(bumper)
			bumper.add_to_group(BUMPER_GROUP)
			bumper.body_entered.connect(_on_bumper_body_entered.bind(bumper))
			bumper.hit.connect(_on_bumper_hit)
	_update_enemy_hp_label()
	victory_label.visible = false
	reset_ball()

func _spawn_bumpers() -> void:
	for child: Node in bumpers_root.get_children():
		child.queue_free()
	bumpers.clear()
	for index: int in range(bumper_configs.size()):
		var config: Dictionary = bumper_configs[index]
		var bumper: Bumper = Bumper.new()
		bumper.name = "Bumper%d" % (index + 1)
		bumper.position = config.get("position", Vector2.ZERO)
		bumper.damage = int(config.get("damage", 1))
		bumper.impulse_strength = float(config.get("impulse_strength", 130.0))
		bumper.bumper_type = str(config.get("bumper_type", "normal"))

		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		var circle_shape: CircleShape2D = CircleShape2D.new()
		circle_shape.radius = BUMPER_COLLISION_RADIUS
		collision_shape.shape = circle_shape
		bumper.add_child(collision_shape)

		var bumper_visual: Polygon2D = Polygon2D.new()
		bumper_visual.name = "BumperVisual"
		bumper_visual.color = BUMPER_VISUAL_COLOR
		bumper_visual.polygon = PackedVector2Array(BUMPER_VISUAL_POINTS)
		bumper.add_child(bumper_visual)

		bumpers_root.add_child(bumper)

func _physics_process(delta: float) -> void:
	_left_pressed = Input.is_key_pressed(KEY_LEFT)
	_right_pressed = Input.is_key_pressed(KEY_RIGHT)
	var left_target: float = LEFT_FLIPPER_REST_ROTATION
	var right_target: float = RIGHT_FLIPPER_REST_ROTATION
	if _left_pressed:
		left_target = LEFT_FLIPPER_ACTIVE_ROTATION
	if _right_pressed:
		right_target = RIGHT_FLIPPER_ACTIVE_ROTATION
	left_flipper.rotation = move_toward(left_flipper.rotation, left_target, FLIPPER_ROTATE_SPEED * delta)
	right_flipper.rotation = move_toward(right_flipper.rotation, right_target, FLIPPER_ROTATE_SPEED * delta)

	var left_rotation_delta: float = left_flipper.rotation - _previous_left_rotation
	var right_rotation_delta: float = right_flipper.rotation - _previous_right_rotation
	if delta > 0.0:
		_left_angular_speed = left_rotation_delta / delta
		_right_angular_speed = right_rotation_delta / delta
	else:
		_left_angular_speed = 0.0
		_right_angular_speed = 0.0
	_previous_left_rotation = left_flipper.rotation
	_previous_right_rotation = right_flipper.rotation

	var speed: float = ball.linear_velocity.length()
	if speed > BALL_MAX_SPEED and not _is_victory:
		ball.linear_velocity = ball.linear_velocity.normalized() * BALL_MAX_SPEED
	if Input.is_key_pressed(KEY_R):
		_reset_battle()
	_update_damage_popups(delta)

func _on_drain_body_entered(body: Node2D) -> void:
	if body == ball:
		reset_ball()

func _on_ball_body_entered(body: Node) -> void:
	if body == left_flipper and _is_left_flipper_striking():
		_apply_flipper_impulse(left_flipper, -1.0)
	elif body == right_flipper and _is_right_flipper_striking():
		_apply_flipper_impulse(right_flipper, 1.0)

func _is_left_flipper_striking() -> bool:
	# Left flipper striking direction: rotation gets smaller (negative angular speed).
	return _left_angular_speed <= -FLIPPER_ACTIVE_ANGULAR_SPEED_THRESHOLD

func _is_right_flipper_striking() -> bool:
	# Right flipper striking direction: rotation gets larger (positive angular speed).
	return _right_angular_speed >= FLIPPER_ACTIVE_ANGULAR_SPEED_THRESHOLD

func _apply_flipper_impulse(flipper: StaticBody2D, side: float) -> void:
	if _is_victory:
		return
	var pivot_to_ball: Vector2 = (ball.global_position - flipper.global_position).normalized()
	var impulse_direction: Vector2 = Vector2(0.4 * side, -1.0).normalized()
	if pivot_to_ball != Vector2.ZERO:
		impulse_direction = (impulse_direction + pivot_to_ball * 0.35).normalized()
	var impulse: Vector2 = impulse_direction * FLIPPER_HIT_IMPULSE
	ball.apply_central_impulse(impulse)

func reset_ball() -> void:
	if _is_victory:
		return
	ball.sleeping = true
	ball.global_position = BALL_START_POSITION
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	ball.sleeping = false
	ball.apply_central_impulse(BALL_LAUNCH_IMPULSE)

func _on_bumper_body_entered(body: Node2D, bumper: Bumper) -> void:
	if _is_victory:
		return
	if body != ball:
		return
	bumper.on_ball_entered(ball)

func _on_bumper_hit(_bumper: Bumper, damage: int) -> void:
	if _is_victory:
		return
	_enemy_hp -= damage
	_update_enemy_hp_label()
	_spawn_damage_popup(damage)
	if _enemy_hp <= 0:
		_enter_victory_state()

func _spawn_damage_popup(damage: int) -> void:
	var popup_label: Label = Label.new()
	popup_label.text = "-%d" % damage
	popup_label.modulate = Color(1.0, 0.85, 0.45, 1.0)
	popup_label.add_theme_font_size_override("font_size", 20)
	popup_label.top_level = true
	popup_label.global_position = enemy_hp_label.global_position + Vector2(145.0, 6.0)
	add_child(popup_label)
	_damage_popups.append({
		"label": popup_label,
		"elapsed": 0.0,
		"start_position": popup_label.global_position,
	})

func _update_damage_popups(delta: float) -> void:
	for index: int in range(_damage_popups.size() - 1, -1, -1):
		var popup: Dictionary = _damage_popups[index]
		var popup_label: Label = popup["label"]
		if not is_instance_valid(popup_label):
			_damage_popups.remove_at(index)
			continue
		var elapsed: float = float(popup["elapsed"]) + delta
		popup["elapsed"] = elapsed
		var progress: float = min(elapsed / DAMAGE_POPUP_DURATION, 1.0)
		var start_position: Vector2 = popup["start_position"]
		popup_label.global_position = start_position + Vector2(0.0, -DAMAGE_POPUP_RISE * progress)
		var alpha: float = 1.0 - progress
		popup_label.modulate.a = alpha
		_damage_popups[index] = popup
		if progress >= 1.0:
			popup_label.queue_free()
			_damage_popups.remove_at(index)

func _enter_victory_state() -> void:
	_is_victory = true
	ball.sleeping = true
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	victory_label.visible = true

func _update_enemy_hp_label() -> void:
	var current_hp: int = _enemy_hp
	if current_hp < 0:
		current_hp = 0
	enemy_hp_label.text = "Enemy HP: %d" % current_hp

func _reset_battle() -> void:
	_is_victory = false
	_enemy_hp = ENEMY_HP_INITIAL
	_update_enemy_hp_label()
	victory_label.visible = false
	reset_ball()
