class_name AssistBall
extends RigidBody2D

signal expired(assist_ball: AssistBall)

@export var max_hp: int = 1
@export var hp: int = 1
@export var attack_damage: int = 1
@export var max_speed: float = 850.0
@export var life_time: float = 8.0

const LOW_LIFE_FLASH_TIME: float = 2.0
const LOW_LIFE_FLASH_SPEED: float = 12.0
const LOW_LIFE_MIN_ALPHA: float = 0.35
const POWER_VISUAL_SCALE_STEP: float = 0.08
const POWER_VISUAL_MAX_SCALE: float = 1.55

var _elapsed: float = 0.0
var _is_disappearing: bool = false


func _ready() -> void:
	max_hp = maxi(max_hp, hp)
	contact_monitor = true
	max_contacts_reported = 8
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	_update_power_visual()


func _physics_process(delta: float) -> void:
	_elapsed += delta
	if life_time > 0.0 and _elapsed >= life_time:
		disappear()
		return
	_update_low_life_flash()
	_cap_speed()


func _update_low_life_flash() -> void:
	var visual: CanvasItem = get_node_or_null("AssistBallVisual") as CanvasItem
	if visual == null or life_time <= 0.0:
		return
	var remaining_time: float = life_time - _elapsed
	if remaining_time > LOW_LIFE_FLASH_TIME:
		visual.modulate.a = 1.0
		return
	var flash_amount: float = (sin(_elapsed * LOW_LIFE_FLASH_SPEED) + 1.0) * 0.5
	visual.modulate.a = lerpf(LOW_LIFE_MIN_ALPHA, 1.0, flash_amount)


func take_damage(damage: int = 1) -> void:
	if _is_disappearing:
		return
	hp -= damage
	if hp <= 0:
		disappear()
	else:
		_update_power_visual()


func heal(amount: int = 1) -> void:
	if _is_disappearing:
		return
	max_hp = maxi(max_hp, 1)
	hp = mini(hp + amount, max_hp)
	_update_power_visual()


func boost_attack(amount: int = 1) -> void:
	if _is_disappearing:
		return
	attack_damage += maxi(amount, 1)
	max_hp += 1
	hp += 1
	_update_power_visual()


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


func _update_power_visual() -> void:
	var visual: CanvasItem = get_node_or_null("AssistBallVisual") as CanvasItem
	if visual == null:
		return
	var power_level: int = maxi(attack_damage - 1, 0) + maxi(max_hp - 1, 0)
	var target_scale: float = minf(1.0 + (POWER_VISUAL_SCALE_STEP * power_level), POWER_VISUAL_MAX_SCALE)
	visual.scale = Vector2.ONE * target_scale
