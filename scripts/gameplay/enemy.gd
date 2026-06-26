class_name Enemy
extends Area2D

signal hit(enemy: Enemy, damage: int)
signal defeated(enemy: Enemy)
signal phase_two_started(enemy: Enemy)

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
@export var bullet_damage: int = 2
@export var display_color: Color = Color(0.9, 0.3, 0.35, 1.0)

const TYPE_BASIC: String = "basic"
const TYPE_SWIFT: String = "swift"
const TYPE_TANK: String = "tank"
const TYPE_BOSS: String = "boss"
const BOSS_MAX_HP: int = 180
const BOSS_PHASE_TWO_HP_RATE: float = 0.5
const BOSS_PHASE_ONE_MOVE_SPEED: float = 28.0
const BOSS_PHASE_TWO_MOVE_SPEED: float = 50.0
const BOSS_PHASE_ONE_ATTACK_INTERVAL: float = 1.4
const BOSS_PHASE_TWO_ATTACK_INTERVAL: float = 0.75
const BOSS_PHASE_ONE_BULLET_DAMAGE: int = 2
const BOSS_PHASE_TWO_BULLET_DAMAGE: int = 3
const BOSS_SCALE: float = 1.6
const BOSS_PHASE_ONE_COLOR: Color = Color(0.85, 0.18, 0.75, 1.0)
const BOSS_PHASE_TWO_COLOR: Color = Color(1.0, 0.22, 0.12, 1.0)
const BOSS_BULLET_COLOR: Color = Color(1.0, 0.2, 0.75, 1.0)
const BOSS_BULLET_RADIUS: float = 10.0
const BOSS_FAN_BURST_INTERVAL: float = 1.5
const ENEMY_DEFINITIONS: Dictionary = {
	TYPE_BASIC: {
		"max_hp": 20,
		"move_speed": 35.0,
		"bullet_damage": 2,
		"attack_interval": 1.1,
		"attack_type": "bullet",
		"color": Color(0.9, 0.3, 0.35, 1.0),
		"score_value": 100,
	},
	TYPE_SWIFT: {
		"max_hp": 10,
		"move_speed": 80.0,
		"bullet_damage": 1,
		"attack_interval": 1.8,
		"attack_type": "bullet",
		"color": Color(0.25, 0.75, 1.0, 1.0),
		"score_value": 120,
	},
	TYPE_TANK: {
		"max_hp": 45,
		"move_speed": 18.0,
		"bullet_damage": 3,
		"attack_interval": 1.5,
		"attack_type": "bullet",
		"color": Color(0.75, 0.55, 0.25, 1.0),
		"score_value": 180,
	},
	TYPE_BOSS: {
		"max_hp": BOSS_MAX_HP,
		"move_speed": BOSS_PHASE_ONE_MOVE_SPEED,
		"bullet_damage": BOSS_PHASE_ONE_BULLET_DAMAGE,
		"attack_interval": BOSS_PHASE_ONE_ATTACK_INTERVAL,
		"attack_type": "bullet",
		"color": BOSS_PHASE_ONE_COLOR,
		"score_value": 1000,
		"move_range": 360.0,
		"scale": Vector2.ONE * BOSS_SCALE,
		"bullet_color": BOSS_BULLET_COLOR,
		"bullet_radius": BOSS_BULLET_RADIUS,
	},
}

const ENEMY_DEFEAT_FADE_DURATION: float = 0.6
const ENEMY_DEFEAT_SCALE_MULTIPLIER: float = 1.25
const ENEMY_DEFEAT_FLASH_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)

var _attack_elapsed: float = 0.0
var _fan_burst_elapsed: float = 0.0
var is_defeated: bool = false
var _is_playing_defeat_animation: bool = false

var _start_position: Vector2 = Vector2.ZERO
var _move_direction: float = 1.0
var _knockback_velocity: Vector2 = Vector2.ZERO
var _base_scale: Vector2 = Vector2.ONE
var _is_phase_two: bool = false
var bullet_color: Color = Color(1.0, 0.4, 0.35, 1.0)
var bullet_radius: float = 7.0
const KNOCKBACK_DAMPING: float = 7.5

static func get_definition(type_name: String) -> Dictionary:
	var definition: Dictionary = ENEMY_DEFINITIONS.get(type_name, {})
	if definition.is_empty():
		definition = ENEMY_DEFINITIONS[TYPE_BASIC]
	return definition.duplicate(true)

func apply_config(config: Dictionary) -> void:
	enemy_type = str(config.get("enemy_type", enemy_type))
	var definition: Dictionary = get_definition(enemy_type)
	max_hp = int(config.get("max_hp", definition.get("max_hp", max_hp)))
	current_hp = int(config.get("current_hp", max_hp))
	contact_damage = int(config.get("contact_damage", contact_damage))
	move_speed = float(config.get("move_speed", definition.get("move_speed", move_speed)))
	bullet_damage = int(config.get("bullet_damage", definition.get("bullet_damage", bullet_damage)))
	score_value = int(config.get("score_value", definition.get("score_value", score_value)))
	move_axis = str(config.get("move_axis", move_axis))
	move_range = float(config.get("move_range", move_range))
	attack_type = str(config.get("attack_type", definition.get("attack_type", attack_type)))
	attack_interval = float(config.get("attack_interval", definition.get("attack_interval", attack_interval)))
	display_color = config.get("color", definition.get("color", display_color))
	bullet_color = config.get("bullet_color", definition.get("bullet_color", bullet_color))
	bullet_radius = float(config.get("bullet_radius", definition.get("bullet_radius", bullet_radius)))
	var configured_scale: Variant = config.get("scale", definition.get("scale", scale))
	if configured_scale is Vector2:
		scale = configured_scale
	elif configured_scale is float:
		scale = Vector2.ONE * float(configured_scale)

func get_display_name() -> String:
	return enemy_type.capitalize()

func is_boss() -> bool:
	return enemy_type == TYPE_BOSS

func is_phase_two() -> bool:
	return _is_phase_two

func _ready() -> void:
	_start_position = global_position
	_base_scale = scale
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
	_try_start_phase_two()
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
	_fan_burst_elapsed = 0.0

func should_fire_fan_burst(delta: float) -> bool:
	if not can_attack() or not is_boss() or not _is_phase_two:
		_fan_burst_elapsed = 0.0
		return false
	_fan_burst_elapsed += delta
	if _fan_burst_elapsed >= BOSS_FAN_BURST_INTERVAL:
		_fan_burst_elapsed = 0.0
		return true
	return false

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
	scale = _base_scale
	_is_phase_two = false
	if is_boss():
		move_speed = BOSS_PHASE_ONE_MOVE_SPEED
		attack_interval = BOSS_PHASE_ONE_ATTACK_INTERVAL
		bullet_damage = BOSS_PHASE_ONE_BULLET_DAMAGE
		display_color = BOSS_PHASE_ONE_COLOR
		bullet_color = BOSS_BULLET_COLOR
		bullet_radius = BOSS_BULLET_RADIUS
		attack_type = "bullet"
		_apply_visual_color(display_color)
	_attack_elapsed = 0.0
	_fan_burst_elapsed = 0.0
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
	_fan_burst_elapsed = 0.0
	_knockback_velocity = Vector2.ZERO
	monitoring = false
	monitorable = false
	set_physics_process(false)
	for child: Node in get_children():
		var collision_shape: CollisionShape2D = child as CollisionShape2D
		if collision_shape != null:
			collision_shape.set_deferred("disabled", true)

func _try_start_phase_two() -> void:
	if not is_boss() or _is_phase_two or current_hp <= 0:
		return
	if float(current_hp) >= float(max_hp) * BOSS_PHASE_TWO_HP_RATE:
		return
	_is_phase_two = true
	move_speed = BOSS_PHASE_TWO_MOVE_SPEED
	attack_interval = BOSS_PHASE_TWO_ATTACK_INTERVAL
	bullet_damage = BOSS_PHASE_TWO_BULLET_DAMAGE
	attack_type = "fan_burst"
	display_color = BOSS_PHASE_TWO_COLOR
	bullet_color = Color(1.0, 0.35, 0.12, 1.0)
	_apply_visual_color(display_color)
	phase_two_started.emit(self)

func _apply_visual_color(color: Color) -> void:
	var visual: CanvasItem = get_node_or_null("EnemyVisual") as CanvasItem
	if visual != null:
		visual.modulate = Color.WHITE
		if visual is Polygon2D:
			var polygon_visual: Polygon2D = visual
			polygon_visual.color = color
	var sprite: CanvasItem = get_node_or_null("EnemySprite") as CanvasItem
	if sprite != null:
		sprite.modulate = color

func play_fan_burst_telegraph(duration: float) -> void:
	if is_queued_for_deletion() or is_defeated:
		return
	var telegraph_scale: Vector2 = _base_scale * 1.08
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate", Color(1.9, 1.25, 2.2, 1.0), duration * 0.5)
	tween.tween_property(self, "scale", telegraph_scale, duration * 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain()
	tween.tween_property(self, "modulate", Color.WHITE, duration * 0.5)
	tween.tween_property(self, "scale", _base_scale, duration * 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func play_phase_two_animation() -> void:
	if is_queued_for_deletion():
		return
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(2.2, 2.2, 2.2, 1.0), 0.08)
	tween.parallel().tween_property(self, "scale", _base_scale * 1.18, 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.08)
	tween.parallel().tween_property(self, "scale", _base_scale, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color(1.6, 0.6, 0.6, 1.0), 0.08)
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)
