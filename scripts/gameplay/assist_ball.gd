class_name AssistBall
extends RigidBody2D

signal expired(assist_ball: AssistBall)

@export var hp: int = 1
@export var attack_damage: int = 1
@export var max_speed: float = 850.0
@export var life_time: float = 8.0

var _elapsed: float = 0.0
var _is_disappearing: bool = false


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE


func _physics_process(delta: float) -> void:
	_elapsed += delta
	if life_time > 0.0 and _elapsed >= life_time:
		disappear()
		return
	_cap_speed()


func take_damage(damage: int = 1) -> void:
	if _is_disappearing:
		return
	hp -= damage
	if hp <= 0:
		disappear()


func disappear() -> void:
	if _is_disappearing:
		return
	_is_disappearing = true
	expired.emit(self)
	queue_free()


func _cap_speed() -> void:
	var speed: float = linear_velocity.length()
	if speed > max_speed and speed > 0.0:
		linear_velocity = linear_velocity.normalized() * max_speed
