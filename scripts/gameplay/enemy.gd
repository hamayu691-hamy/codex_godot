class_name Enemy
extends Area2D

signal hit(enemy: Enemy, damage: int)
signal defeated(enemy: Enemy)

@export var max_hp: int = 20
@export var current_hp: int = 20
@export var contact_damage: int = 1
@export var move_speed: float = 35.0
@export var enemy_type: String = "basic"
@export var score_value: int = 100
@export var move_axis: String = "horizontal"
@export var move_range: float = 80.0
@export var attack_type: String = "bullet"
@export var attack_interval: float = 1.1

const ENEMY_DEFEAT_FADE_DURATION: float = 0.6
const ENEMY_DEFEAT_SCALE_MULTIPLIER: float = 1.25
const ENEMY_DEFEAT_FLASH_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)

var _attack_elapsed: float = 0.0
var is_defeated: bool = false
var _is_playing_defeat_animation: bool = false

var _start_position: Vector2 = Vector2.ZERO
var _move_direction: float = 1.0
var _knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_DAMPING: float = 7.5

func _ready() -> void:
	_start_position = global_position
	if current_hp <= 0:
		current_hp = max_hp

func _physics_process(delta: float) -> void:
	if is_defeated:
		return
	var movement: Vector2 = Vector2.ZERO
	if move_axis == "vertical":
		movement = Vector2(0.0, _move_direction * move_speed * delta)
	else:
		movement = Vector2(_move_direction * move_speed * delta, 0.0)

	if _knockback_velocity.length_squared() > 0.0:
		movement += _knockback_velocity * delta
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DAMPING * 100.0 * delta)

	global_position += movement

	var traveled: float = 0.0
	if move_axis == "vertical":
		traveled = global_position.y - _start_position.y
	else:
		traveled = global_position.x - _start_position.x

	if abs(traveled) >= move_range:
		_move_direction *= -1.0

func take_damage(damage: int) -> void:
	if is_defeated:
		return
	if damage <= 0:
		return
	current_hp -= damage
	hit.emit(self, damage)
	if current_hp <= 0:
		current_hp = 0
		is_defeated = true
		_stop_defeated_enemy_activity()
		defeated.emit(self)

func can_attack() -> bool:
	return not is_defeated and current_hp > 0 and attack_interval > 0.0 and attack_type != ""

func should_fire_attack(delta: float) -> bool:
	if not can_attack():
		_attack_elapsed = 0.0
		return false
	_attack_elapsed += delta
	if _attack_elapsed >= attack_interval:
		_attack_elapsed = 0.0
		return true
	return false

func reset_attack_timer() -> void:
	_attack_elapsed = 0.0

func apply_knockback(direction: Vector2, strength: float) -> void:
	if is_defeated:
		return
	if strength <= 0.0:
		return
	if direction == Vector2.ZERO:
		return
	_knockback_velocity += direction.normalized() * strength


func reset_for_battle() -> void:
	current_hp = max_hp
	is_defeated = false
	_is_playing_defeat_animation = false
	modulate = Color.WHITE
	_attack_elapsed = 0.0
	_knockback_velocity = Vector2.ZERO
	monitoring = true
	monitorable = true
	set_physics_process(true)
	for child: Node in get_children():
		var collision_shape: CollisionShape2D = child as CollisionShape2D
		if collision_shape != null:
			collision_shape.set_deferred("disabled", false)

func play_defeat_animation() -> void:
	if _is_playing_defeat_animation or is_queued_for_deletion():
		return
	_is_playing_defeat_animation = true
	is_defeated = true
	_stop_defeated_enemy_activity()

	var base_scale: Vector2 = scale
	var base_modulate: Color = modulate
	modulate = ENEMY_DEFEAT_FLASH_COLOR

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", base_scale * ENEMY_DEFEAT_SCALE_MULTIPLIER, ENEMY_DEFEAT_FADE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(base_modulate.r, base_modulate.g, base_modulate.b, 0.0), ENEMY_DEFEAT_FADE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()


func _stop_defeated_enemy_activity() -> void:
	_attack_elapsed = 0.0
	_knockback_velocity = Vector2.ZERO
	monitoring = false
	monitorable = false
	set_physics_process(false)
	for child: Node in get_children():
		var collision_shape: CollisionShape2D = child as CollisionShape2D
		if collision_shape != null:
			collision_shape.set_deferred("disabled", true)
