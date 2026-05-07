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
# Minimum angular speed (rad/s) to treat the flipper as actively striking. Tune for feel.
const FLIPPER_ACTIVE_ANGULAR_SPEED_THRESHOLD: float = 3.0

@onready var ball: RigidBody2D = $Ball
@onready var left_flipper: StaticBody2D = $LeftFlipper
@onready var right_flipper: StaticBody2D = $RightFlipper
@onready var drain: Area2D = $Drain

var _left_pressed: bool = false
var _right_pressed: bool = false
var _previous_left_rotation: float = LEFT_FLIPPER_REST_ROTATION
var _previous_right_rotation: float = RIGHT_FLIPPER_REST_ROTATION
var _left_angular_speed: float = 0.0
var _right_angular_speed: float = 0.0

func _ready() -> void:
	left_flipper.rotation = LEFT_FLIPPER_REST_ROTATION
	right_flipper.rotation = RIGHT_FLIPPER_REST_ROTATION
	_previous_left_rotation = left_flipper.rotation
	_previous_right_rotation = right_flipper.rotation
	drain.body_entered.connect(_on_drain_body_entered)
	ball.body_entered.connect(_on_ball_body_entered)
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
	if speed > BALL_MAX_SPEED:
		ball.linear_velocity = ball.linear_velocity.normalized() * BALL_MAX_SPEED
	if Input.is_key_pressed(KEY_R):
		reset_ball()

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
	var pivot_to_ball: Vector2 = (ball.global_position - flipper.global_position).normalized()
	var impulse_direction: Vector2 = Vector2(0.4 * side, -1.0).normalized()
	if pivot_to_ball != Vector2.ZERO:
		impulse_direction = (impulse_direction + pivot_to_ball * 0.35).normalized()
	var impulse: Vector2 = impulse_direction * FLIPPER_HIT_IMPULSE
	ball.apply_central_impulse(impulse)

func reset_ball() -> void:
	ball.sleeping = true
	ball.global_position = BALL_START_POSITION
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	ball.sleeping = false
	ball.apply_central_impulse(BALL_LAUNCH_IMPULSE)
