class_name Pin
extends Area2D

signal hit(pin: Pin)

const DEFAULT_VISUAL_COLOR: Color = Color(0.85, 0.85, 0.9, 1.0)
const DEFAULT_VISUAL_POINTS: Array[Vector2] = [
	Vector2(0.0, -12.0),
	Vector2(8.5, -8.5),
	Vector2(12.0, 0.0),
	Vector2(8.5, 8.5),
	Vector2(0.0, 12.0),
	Vector2(-8.5, 8.5),
	Vector2(-12.0, 0.0),
	Vector2(-8.5, -8.5),
]

@export var pin_id: String = ""
@export var impulse_strength: float = 80.0
@export var sprite_path: String = ""
@export var sprite_scale: Vector2 = Vector2.ONE
@export var replaceable: bool = true
@export var occupied: bool = false
@export var slot_id: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body is RigidBody2D:
		return
	_apply_impulse_to_ball(body)
	hit.emit(self)


func _apply_impulse_to_ball(ball: RigidBody2D) -> void:
	var hit_direction: Vector2 = ball.global_position - global_position
	if hit_direction.length_squared() <= 0.0001:
		hit_direction = Vector2.UP
	else:
		hit_direction = hit_direction.normalized()
	ball.apply_central_impulse(hit_direction * impulse_strength)
