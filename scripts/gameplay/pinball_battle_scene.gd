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
const BUMPER_HIT_IMPULSE: float = 130.0
const BUMPER_HIT_SCALE: Vector2 = Vector2(1.15, 1.15)
const BUMPER_HIT_FLASH_COLOR: Color = Color(0.75, 1.0, 1.0, 1.0)
const DAMAGE_POPUP_DURATION: float = 0.55
const DAMAGE_POPUP_RISE: float = 24.0
# Minimum angular speed (rad/s) to treat the flipper as actively striking. Tune for feel.
const FLIPPER_ACTIVE_ANGULAR_SPEED_THRESHOLD: float = 3.0
const ENEMY_HP_INITIAL: int = 20
const BUMPER_GROUP: StringName = &"bumpers"

@onready var ball: RigidBody2D = $Ball
@onready var left_flipper: StaticBody2D = $LeftFlipper
@onready var right_flipper: StaticBody2D = $RightFlipper
@onready var drain: Area2D = $Drain
@onready var bumpers: Array[Area2D] = [$Bumper1, $Bumper2, $Bumper3]
@onready var enemy_hp_label: Label = $EnemyHpLabel
@onready var victory_label: Label = $VictoryLabel

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
	for bumper: Area2D in bumpers:
		bumper.add_to_group(BUMPER_GROUP)
		bumper.body_entered.connect(_on_bumper_body_entered.bind(bumper))
	_update_enemy_hp_label()
	victory_label.visible = false
	reset_ball()

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

func _on_bumper_body_entered(body: Node2D, bumper: Area2D) -> void:
	if _is_victory:
		return
	if body != ball:
		return
	var damage: int = int(bumper.get_meta("damage", 1))
	_apply_bumper_hit_feedback(bumper, damage)
	_enemy_hp -= damage
	_update_enemy_hp_label()
	if _enemy_hp <= 0:
		_enter_victory_state()

func _apply_bumper_hit_feedback(bumper: Area2D, damage: int) -> void:
	var hit_direction: Vector2 = ball.global_position - bumper.global_position
	if hit_direction.length_squared() <= 0.0001:
		hit_direction = Vector2.UP
	else:
		hit_direction = hit_direction.normalized()
	ball.apply_central_impulse(hit_direction * BUMPER_HIT_IMPULSE)

	var bumper_visual: CanvasItem = bumper.get_node_or_null("BumperVisual")
	if bumper_visual != null:
		var flash_tween: Tween = create_tween()
		flash_tween.tween_property(bumper_visual, "modulate", BUMPER_HIT_FLASH_COLOR, 0.05)
		flash_tween.tween_property(bumper_visual, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	var scale_tween: Tween = create_tween()
	scale_tween.tween_property(bumper, "scale", BUMPER_HIT_SCALE, 0.06)
	scale_tween.tween_property(bumper, "scale", Vector2.ONE, 0.1)

	_spawn_damage_popup(damage)

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
