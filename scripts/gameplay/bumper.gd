class_name Bumper
extends Area2D

signal hit(bumper: Bumper, damage: int)

const HIT_SCALE: Vector2 = Vector2(1.15, 1.15)
const HIT_FLASH_COLOR: Color = Color(0.75, 1.0, 1.0, 1.0)

@export var damage: int = 1
@export var impulse_strength: float = 130.0
@export var bumper_type: String = "normal"
@export var cooldown_time: float = 0.08

var _cooldown_remaining: float = 0.0

@onready var _bumper_visual: CanvasItem = get_node_or_null("BumperVisual")


func _physics_process(delta: float) -> void:
	if _cooldown_remaining > 0.0:
		_cooldown_remaining = max(_cooldown_remaining - delta, 0.0)

func on_ball_entered(ball: RigidBody2D) -> void:
	if _cooldown_remaining > 0.0:
		return
	_cooldown_remaining = cooldown_time
	_apply_impulse_to_ball(ball)
	_play_hit_feedback()
	hit.emit(self, damage)

func _apply_impulse_to_ball(ball: RigidBody2D) -> void:
	var hit_direction: Vector2 = ball.global_position - global_position
	if hit_direction.length_squared() <= 0.0001:
		hit_direction = Vector2.UP
	else:
		hit_direction = hit_direction.normalized()
	ball.apply_central_impulse(hit_direction * impulse_strength)

func _play_hit_feedback() -> void:
	if _bumper_visual != null:
		var flash_tween: Tween = create_tween()
		flash_tween.tween_property(_bumper_visual, "modulate", HIT_FLASH_COLOR, 0.05)
		flash_tween.tween_property(_bumper_visual, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)

	var scale_tween: Tween = create_tween()
	scale_tween.tween_property(self, "scale", HIT_SCALE, 0.06)
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.1)
