extends Node2D

const BALL_START_POSITION: Vector2 = Vector2(200.0, 120.0)
const LEFT_FLIPPER_REST_ROTATION: float = -0.35
const LEFT_FLIPPER_ACTIVE_ROTATION: float = -1.0
const RIGHT_FLIPPER_REST_ROTATION: float = 0.35
const RIGHT_FLIPPER_ACTIVE_ROTATION: float = 1.0
const FLIPPER_ROTATE_SPEED: float = 14.0

@onready var ball: RigidBody2D = $Ball
@onready var left_flipper: StaticBody2D = $LeftFlipper
@onready var right_flipper: StaticBody2D = $RightFlipper
@onready var drain: Area2D = $Drain

func _ready() -> void:
	left_flipper.rotation = LEFT_FLIPPER_REST_ROTATION
	right_flipper.rotation = RIGHT_FLIPPER_REST_ROTATION
	drain.body_entered.connect(_on_drain_body_entered)
	reset_ball()

func _physics_process(delta: float) -> void:
	var left_pressed: bool = Input.is_key_pressed(KEY_LEFT)
	var right_pressed: bool = Input.is_key_pressed(KEY_RIGHT)
	var left_target: float = LEFT_FLIPPER_REST_ROTATION
	var right_target: float = RIGHT_FLIPPER_REST_ROTATION
	if left_pressed:
		left_target = LEFT_FLIPPER_ACTIVE_ROTATION
	if right_pressed:
		right_target = RIGHT_FLIPPER_ACTIVE_ROTATION
	left_flipper.rotation = move_toward(left_flipper.rotation, left_target, FLIPPER_ROTATE_SPEED * delta)
	right_flipper.rotation = move_toward(right_flipper.rotation, right_target, FLIPPER_ROTATE_SPEED * delta)
	if Input.is_key_pressed(KEY_R):
		reset_ball()

func _on_drain_body_entered(body: Node2D) -> void:
	if body == ball:
		reset_ball()

func reset_ball() -> void:
	ball.sleeping = true
	ball.global_position = BALL_START_POSITION
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	ball.sleeping = false
