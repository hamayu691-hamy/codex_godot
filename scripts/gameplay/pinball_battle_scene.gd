extends Node2D

const StageConfig = preload("res://scripts/gameplay/stage_config.gd")
const FieldBuilder = preload("res://scripts/gameplay/field_builder.gd")
const RewardManager = preload("res://scripts/gameplay/reward_manager.gd")
const AssistBall = preload("res://scripts/gameplay/assist_ball.gd")
const FIELD_WIDTH: float = StageConfig.FIELD_WIDTH
const FIELD_HEIGHT: float = StageConfig.FIELD_HEIGHT
const VIEW_WIDTH: float = StageConfig.VIEW_WIDTH
const VIEW_HEIGHT: float = StageConfig.VIEW_HEIGHT
const FIELD_CENTER_X: float = FIELD_WIDTH * 0.5
const BALL_START_POSITION: Vector2 = Vector2(FIELD_CENTER_X, 120.0)
const BALL_MAX_SPEED: float = 1150.0
const BALL_FLIPPER_POST_HIT_MAX_SPEED: float = BALL_MAX_SPEED
const BALL_MIN_SPEED: float = 170.0
const BALL_LAUNCH_IMPULSE: Vector2 = Vector2(120.0, -750.0)
const DAMAGE_POPUP_DURATION: float = 0.55
const DAMAGE_POPUP_RISE: float = 24.0
const DAMAGE_POPUP_OFFSET: Vector2 = Vector2(0.0, -34.0)
const DAMAGE_POPUP_COLOR: Color = Color(1.0, 0.85, 0.45, 1.0)
const DAMAGE_POPUP_FONT_SIZE: int = 20
const ENEMY_HIT_FLASH_DURATION: float = 0.11
const ENEMY_HIT_FLASH_COLOR: Color = Color(2.6, 2.6, 2.6, 1.0)
const HIT_EFFECT_DURATION: float = 0.2
const HIT_EFFECT_START_RADIUS: float = 6.0
const HIT_EFFECT_END_RADIUS: float = 20.0
const HIT_EFFECT_COLOR: Color = Color(1.0, 0.95, 0.7, 0.9)
# Minimum angular speed (rad/s) to treat the flipper as actively striking. Tune for feel.
const FLIPPER_ACTIVE_ANGULAR_SPEED_THRESHOLD: float = 3.0
const ENEMY_HP_INITIAL: int = 20
const DEBUG_ENABLE_ENEMY_ZERO_HP_COMMAND: bool = true
const DEBUG_ENEMY_ZERO_HP_KEY: Key = KEY_K
const DEBUG_REPLACE_PIN_WITH_POWER_BUMPER_KEY: Key = KEY_B
const BALL_HP_INITIAL: int = 20
const BUMPER_GROUP: StringName = &"bumpers"
const BUMPER_COLLISION_RADIUS: float = 36.0
const BUMPER_VISUAL_COLOR: Color = Color(0.2, 0.9, 0.95, 1.0)
const BUMPER_VISUAL_COLOR_BY_TYPE: Dictionary = {
	"normal": Color(0.2, 0.9, 0.95, 1.0),
	"power": Color(0.95, 0.45, 0.35, 1.0),
	"heal": Color(0.35, 0.9, 0.45, 1.0),
	"slow": Color(0.45, 0.55, 0.95, 1.0),
	"charge": Color(0.9, 0.85, 0.3, 1.0),
	"critical": Color(0.95, 0.3, 0.6, 1.0),
	"pierce": Color(0.7, 0.7, 0.78, 1.0),
	"combo_plus": Color(0.9, 0.5, 0.95, 1.0),
	"combo_lock": Color(0.55, 0.35, 0.95, 1.0),
	"jackpot": Color(0.95, 0.75, 0.25, 1.0),
	"spawn": Color(0.25, 0.95, 0.85, 1.0),
	"transform": Color(0.7, 0.45, 0.95, 1.0),
	"shield": Color(0.35, 0.85, 0.95, 1.0),
	"poison": Color(0.55, 0.9, 0.3, 1.0),
	"lightning": Color(0.98, 0.95, 0.45, 1.0),
	"bomb": Color(0.35, 0.35, 0.35, 1.0),
	"multiball": Color(0.95, 0.6, 0.9, 1.0),
	"summon_ball": Color(0.35, 1.0, 0.85, 1.0),
}
const BULLET_SPEED: float = 420.0
const BULLET_DAMAGE: int = 2
const BULLET_COLLISION_RADIUS: float = 7.0
const BUMPER_TOOLTIP_OFFSET: Vector2 = Vector2(16.0, 16.0)
const BACKGROUND_Z_INDEX: int = -100
const DEFAULT_BACKGROUND_COLOR: Color = Color(0.08, 0.1, 0.15, 1.0)
const BALL_HP_BAR_SIZE: Vector2 = Vector2(44.0, 7.0)
const BALL_HP_BAR_OFFSET: Vector2 = Vector2(-22.0, -26.0)
const ENEMY_COLLISION_RADIUS: float = 20.0
const ENEMY_HIT_KNOCKBACK_STRENGTH: float = 120.0
const ENEMY_VISUAL_COLOR: Color = Color(0.9, 0.3, 0.35, 1.0)
const DEFAULT_SPRITE_SCALE: Vector2 = Vector2.ONE
const LARGE_TEXTURE_BASE_SIZE: float = 1254.0
const BALL_SPRITE_TARGET_DIAMETER: float = 24.0
const ASSIST_BALL_MAX_COUNT: int = 5
const ASSIST_BALL_HP: int = 1
const ASSIST_BALL_ATTACK_DAMAGE: int = 1
const ASSIST_BALL_LIFE_TIME: float = 8.0
const ASSIST_BALL_MAX_SPEED: float = 850.0
const ASSIST_BALL_COLLISION_RADIUS: float = 9.0
const ASSIST_BALL_SPAWN_OFFSET: Vector2 = Vector2(0.0, -30.0)
const ASSIST_BALL_SPAWN_IMPULSE_BASE: Vector2 = Vector2(0.0, -520.0)
const ASSIST_BALL_SPAWN_IMPULSE_RANDOM_X: float = 260.0
const ASSIST_BALL_VISUAL_COLOR: Color = Color(0.45, 1.0, 0.85, 0.74)
const MAIN_BALL_RING_COLOR: Color = Color(1.0, 0.98, 0.62, 0.55)
const MAIN_BALL_MARKER_COLOR: Color = Color(1.0, 1.0, 0.9, 0.92)
const BUMPER_SPRITE_TARGET_DIAMETER: float = 72.0
const ENEMY_SPRITE_TARGET_DIAMETER: float = 40.0
const PIN_COLLISION_RADIUS: float = 12.0
const BALL_SPRITE_SCALE: Vector2 = Vector2.ONE * (BALL_SPRITE_TARGET_DIAMETER / LARGE_TEXTURE_BASE_SIZE)
const BUMPER_SPRITE_SCALE: Vector2 = Vector2.ONE * (BUMPER_SPRITE_TARGET_DIAMETER / LARGE_TEXTURE_BASE_SIZE)
const ENEMY_SPRITE_SCALE: Vector2 = Vector2.ONE * (ENEMY_SPRITE_TARGET_DIAMETER / LARGE_TEXTURE_BASE_SIZE)
const BUMPER_VISUAL_POINTS: Array[Vector2] = [
	Vector2(0.0, -36.0),
	Vector2(18.0, -31.177),
	Vector2(31.177, -18.0),
	Vector2(36.0, 0.0),
	Vector2(31.177, 18.0),
	Vector2(18.0, 31.177),
	Vector2(0.0, 36.0),
	Vector2(-18.0, 31.177),
	Vector2(-31.177, 18.0),
	Vector2(-36.0, 0.0),
	Vector2(-31.177, -18.0),
	Vector2(-18.0, -31.177),
]

@onready var background_root: Node2D = $Background
@onready var ball: RigidBody2D = $Ball
@onready var flippers_root: Node2D = $Flippers
@onready var drain: Area2D = $Drain
@onready var bumpers_root: Node = $Bumpers
@onready var pins_root: Node2D = $Pins
@onready var enemies_root: Node2D = $Enemies
@onready var walls_root: Node2D = $Walls
@onready var bullets_root: Node2D = $Bullets
@onready var assist_balls_root: Node2D = $AssistBalls
@onready var game_camera: Camera2D = $GameCamera
@onready var ball_hp_bar: ProgressBar = $Ball/BallHpBar
@onready var enemy_hp_label: Label = $UI/EnemyHpLabel
@onready var combo_label: Label = $UI/ComboLabel
@onready var bonus_damage_label: Label = $UI/BonusDamageLabel
@onready var assist_balls_label: Label = $UI/AssistBallsLabel
@onready var status_label: Label = $UI/StatusLabel
@onready var victory_label: Label = $UI/VictoryLabel
@onready var game_over_label: Label = $UI/GameOverLabel
@onready var reward_panel: Panel = $UI/RewardPanel
@onready var reward_header_label: Label = $UI/RewardPanel/RewardHeaderLabel
@onready var reward_status_label: Label = $UI/RewardPanel/RewardStatusLabel
@onready var bumper_tooltip_panel: PanelContainer = $UI/BumperTooltipPanel
@onready var bumper_tooltip_label: Label = $UI/BumperTooltipPanel/BumperTooltipLabel
@onready var reward_option_buttons: Array[Button] = [
	$UI/RewardPanel/RewardButtons/BumperDamageButton,
	$UI/RewardPanel/RewardButtons/MaxHpButton,
	$UI/RewardPanel/RewardButtons/FlipperPowerButton,
]
@onready var bumpers: Array[Bumper] = []
@onready var enemies: Array[Enemy] = []

var wall_configs: Array[Dictionary] = []
var bumper_configs: Array[Dictionary] = []
var pin_configs: Array[Dictionary] = []
var flipper_configs: Array[Dictionary] = []
var enemy_configs: Array[Dictionary] = []
var ball_config: Dictionary = {}
var background_sprite_path: String = ""
var background_color: Color = DEFAULT_BACKGROUND_COLOR

var _flippers: Array[Dictionary] = []
var _ball_hp: int = BALL_HP_INITIAL
var _is_victory: bool = false
var _is_game_over: bool = false
var _debug_enemy_zero_hp_key_was_down: bool = false
var _debug_replace_pin_key_was_down: bool = false
var _is_ball_alive: bool = true
var _damage_popups: Array[Dictionary] = []
var _hit_effects: Array[Dictionary] = []
var _reward_selected_this_victory: bool = false
var _current_reward_options: Array[String] = []
var _reward_manager: RewardManager = RewardManager.new()
var _pending_reward_bumper_config: Dictionary = {}
var _is_waiting_for_pin_replacement_selection: bool = false
var _slow_effect_multiplier: float = 1.0
var combo_count: int = 0
var _next_enemy_hit_bonus_damage: int = 0
var _bullet_fire_elapsed: float = 0.0
var _hovered_bumper: Bumper = null
var _ball_collision_radius: float = BALL_SPRITE_TARGET_DIAMETER * 0.5
var _field_builder: FieldBuilder

func _ready() -> void:
	_load_stage_config("stage_01")
	_field_builder = FieldBuilder.new(PIN_COLLISION_RADIUS, BUMPER_COLLISION_RADIUS, ENEMY_COLLISION_RADIUS, BUMPER_VISUAL_COLOR, BUMPER_VISUAL_COLOR_BY_TYPE, BUMPER_VISUAL_POINTS, ENEMY_VISUAL_COLOR, ENEMY_HP_INITIAL)
	_setup_background()
	_setup_ball_visual()
	_spawn_flippers()
	_setup_camera()
	ball.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	drain.body_entered.connect(_on_drain_body_entered)
	ball.body_entered.connect(_on_ball_body_entered)
	_spawn_walls()
	_spawn_pins()
	_spawn_bumpers()
	_spawn_enemies()
	_setup_bumper_tooltip()
	_setup_ball_hp_bar()
	_setup_reward_panel()
	_update_enemy_hp_label()
	_update_combo_label()
	_update_bonus_damage_label()
	_update_assist_balls_label()
	_update_status_label()
	victory_label.visible = false
	game_over_label.visible = false
	_reset_battle()

func _load_stage_config(stage_id: String) -> void:
	var stage_data: Dictionary = StageConfig.get_stage_data(stage_id)
	wall_configs = _to_dictionary_array(stage_data.get("wall_configs", []))
	bumper_configs = _to_dictionary_array(stage_data.get("bumper_configs", []))
	pin_configs = _to_dictionary_array(stage_data.get("pin_configs", []))
	flipper_configs = _to_dictionary_array(stage_data.get("flipper_configs", []))
	enemy_configs = _to_dictionary_array(stage_data.get("enemy_configs", []))
	ball_config = stage_data.get("ball_config", {})
	background_sprite_path = str(stage_data.get("background_sprite_path", ""))
	var loaded_background_color: Variant = stage_data.get("background_color", DEFAULT_BACKGROUND_COLOR)
	if loaded_background_color is Color:
		background_color = loaded_background_color
	else:
		background_color = DEFAULT_BACKGROUND_COLOR

func _to_dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for entry: Variant in value:
			if entry is Dictionary:
				result.append(entry)
	return result


func _setup_background() -> void:
	for child: Node in background_root.get_children():
		child.queue_free()
	background_root.z_index = BACKGROUND_Z_INDEX
	background_root.position = Vector2.ZERO
	var texture: Texture2D = null
	if not background_sprite_path.is_empty():
		texture = load(background_sprite_path) as Texture2D
	if texture == null:
		_add_fallback_background()
		return
	var background_sprite: Sprite2D = Sprite2D.new()
	background_sprite.name = "BackgroundSprite"
	background_sprite.texture = texture
	background_sprite.centered = true
	background_sprite.position = Vector2(FIELD_WIDTH * 0.5, FIELD_HEIGHT * 0.5)
	var texture_size: Vector2 = texture.get_size()
	if texture_size.x > 0.0 and texture_size.y > 0.0:
		background_sprite.scale = Vector2(FIELD_WIDTH / texture_size.x, FIELD_HEIGHT / texture_size.y)
	background_root.add_child(background_sprite)

func _add_fallback_background() -> void:
	var fallback_background: Polygon2D = Polygon2D.new()
	fallback_background.name = "FallbackBackground"
	fallback_background.color = background_color
	fallback_background.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(FIELD_WIDTH, 0.0),
		Vector2(FIELD_WIDTH, FIELD_HEIGHT),
		Vector2(0.0, FIELD_HEIGHT),
	])
	background_root.add_child(fallback_background)

func _setup_ball_visual() -> void:
	var ball_visual: Node = ball.get_node_or_null("BallVisual")
	if ball_visual == null:
		return
	_try_attach_sprite(ball, ball_config, ball_visual, "BallSprite")
	_add_main_ball_focus_marker()
	_sync_ball_size_with_visual()


func _add_main_ball_focus_marker() -> void:
	if ball.get_node_or_null("MainBallRing") == null:
		var ring: Line2D = Line2D.new()
		ring.name = "MainBallRing"
		ring.width = 2.0
		ring.default_color = MAIN_BALL_RING_COLOR
		ring.closed = true
		ring.z_index = 3
		var ring_points: PackedVector2Array = PackedVector2Array()
		var ring_radius: float = BALL_SPRITE_TARGET_DIAMETER * 0.62
		for index: int in range(24):
			var angle: float = TAU * float(index) / 24.0
			ring_points.append(Vector2(cos(angle), sin(angle)) * ring_radius)
		ring.points = ring_points
		ball.add_child(ring)
	if ball.get_node_or_null("MainBallMarker") == null:
		var marker: Polygon2D = Polygon2D.new()
		marker.name = "MainBallMarker"
		marker.color = MAIN_BALL_MARKER_COLOR
		marker.z_index = 4
		marker.polygon = PackedVector2Array([
			Vector2(0.0, -18.0),
			Vector2(4.0, -12.0),
			Vector2(-4.0, -12.0),
		])
		ball.add_child(marker)

func _sync_ball_size_with_visual() -> void:
	var ball_sprite: Sprite2D = ball.get_node_or_null("BallSprite") as Sprite2D
	if ball_sprite == null or ball_sprite.texture == null:
		_ball_collision_radius = BALL_SPRITE_TARGET_DIAMETER * 0.5
	else:
		var texture_size: Vector2 = ball_sprite.texture.get_size()
		var applied_scale: Vector2 = ball_sprite.scale
		var scaled_size: Vector2 = Vector2(texture_size.x * absf(applied_scale.x), texture_size.y * absf(applied_scale.y))
		var diameter: float = max(scaled_size.x, scaled_size.y)
		_ball_collision_radius = max(diameter * 0.5, 1.0)
	_update_ball_collision_shape()

func _update_ball_collision_shape() -> void:
	var collision_shape: CollisionShape2D = ball.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		return
	var circle_shape: CircleShape2D = collision_shape.shape as CircleShape2D
	if circle_shape == null:
		circle_shape = CircleShape2D.new()
		collision_shape.shape = circle_shape
	circle_shape.radius = _ball_collision_radius

func _setup_bumper_tooltip() -> void:
	bumper_tooltip_panel.visible = false
	bumper_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bumper_tooltip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _setup_camera() -> void:
	game_camera.enabled = true
	game_camera.position_smoothing_enabled = true
	game_camera.position_smoothing_speed = 4.0
	game_camera.limit_left = 0
	game_camera.limit_top = 0
	game_camera.limit_right = int(FIELD_WIDTH)
	game_camera.limit_bottom = int(FIELD_HEIGHT)
	game_camera.global_position = BALL_START_POSITION

func _on_bumper_mouse_entered(bumper: Bumper) -> void:
	_hovered_bumper = bumper
	bumper_tooltip_label.text = bumper.get_tooltip_text()
	bumper_tooltip_panel.visible = true
	_update_bumper_tooltip_position()

func _on_bumper_mouse_exited(_bumper: Bumper) -> void:
	_hovered_bumper = null
	bumper_tooltip_panel.visible = false

func _update_bumper_tooltip_position() -> void:
	var viewport_rect: Rect2 = get_viewport_rect()
	var tooltip_size: Vector2 = bumper_tooltip_panel.size
	var target_position: Vector2 = get_viewport().get_mouse_position() + BUMPER_TOOLTIP_OFFSET
	if target_position.x + tooltip_size.x > viewport_rect.size.x:
		target_position.x = viewport_rect.size.x - tooltip_size.x
	if target_position.y + tooltip_size.y > viewport_rect.size.y:
		target_position.y = viewport_rect.size.y - tooltip_size.y
	target_position.x = max(target_position.x, 0.0)
	target_position.y = max(target_position.y, 0.0)
	bumper_tooltip_panel.position = target_position

func _setup_ball_hp_bar() -> void:
	ball_hp_bar.min_value = 0
	ball_hp_bar.max_value = _get_ball_max_hp()
	ball_hp_bar.value = _get_ball_max_hp()
	ball_hp_bar.show_percentage = false
	ball_hp_bar.position = BALL_HP_BAR_OFFSET
	ball_hp_bar.size = BALL_HP_BAR_SIZE


func _spawn_pins() -> void:
	_field_builder.spawn_pins(pins_root, pin_configs)

func _sync_pin_size_with_visual(pin: Pin) -> void:
	var collision_radius: float = PIN_COLLISION_RADIUS
	var pin_sprite: Sprite2D = pin.get_node_or_null("PinSprite") as Sprite2D
	if pin_sprite != null and pin_sprite.texture != null:
		var texture_size: Vector2 = pin_sprite.texture.get_size()
		var applied_scale: Vector2 = pin_sprite.scale
		var scaled_size: Vector2 = Vector2(texture_size.x * absf(applied_scale.x), texture_size.y * absf(applied_scale.y))
		var diameter: float = max(scaled_size.x, scaled_size.y)
		collision_radius = max(diameter * 0.5, 1.0)
	_update_pin_collision_shape(pin, collision_radius)

func _update_pin_collision_shape(pin: Pin, collision_radius: float) -> void:
	var collision_shape: CollisionShape2D = pin.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		return
	var circle_shape: CircleShape2D = collision_shape.shape as CircleShape2D
	if circle_shape == null:
		circle_shape = CircleShape2D.new()
		collision_shape.shape = circle_shape
	circle_shape.radius = collision_radius

func _spawn_bumpers() -> void:
	bumpers.clear()
	for bumper: Bumper in _field_builder.spawn_bumpers(bumpers_root, bumper_configs):
		_register_bumper(bumper)

func _register_bumper(bumper: Bumper) -> void:
	bumpers.append(bumper)
	bumper.add_to_group(BUMPER_GROUP)
	bumper.body_entered.connect(_on_bumper_body_entered.bind(bumper))
	bumper.hit.connect(_on_bumper_hit)
	bumper.mouse_entered.connect(_on_bumper_mouse_entered.bind(bumper))
	bumper.mouse_exited.connect(_on_bumper_mouse_exited.bind(bumper))

func _create_bumper_from_config(config: Dictionary, bumper_name: String) -> Bumper:
	return _field_builder._create_bumper_from_config(config, bumper_name)


func _sync_bumper_size_with_visual(bumper: Bumper) -> void:
	var collision_radius: float = BUMPER_COLLISION_RADIUS
	var bumper_sprite: Sprite2D = bumper.get_node_or_null("BumperSprite") as Sprite2D
	if bumper_sprite != null and bumper_sprite.texture != null:
		var texture_size: Vector2 = bumper_sprite.texture.get_size()
		var applied_scale: Vector2 = bumper_sprite.scale
		var scaled_size: Vector2 = Vector2(texture_size.x * absf(applied_scale.x), texture_size.y * absf(applied_scale.y))
		var diameter: float = max(scaled_size.x, scaled_size.y)
		collision_radius = max(diameter * 0.5, 1.0)
	_update_bumper_collision_shape(bumper, collision_radius)

func _update_bumper_collision_shape(bumper: Bumper, collision_radius: float) -> void:
	var collision_shape: CollisionShape2D = bumper.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		return
	var circle_shape: CircleShape2D = collision_shape.shape as CircleShape2D
	if circle_shape == null:
		circle_shape = CircleShape2D.new()
		collision_shape.shape = circle_shape
	circle_shape.radius = collision_radius

func _get_bumper_visual_color(bumper_type: String) -> Color:
	return BUMPER_VISUAL_COLOR_BY_TYPE.get(bumper_type, BUMPER_VISUAL_COLOR)


func _spawn_walls() -> void:
	_field_builder.spawn_walls(walls_root, wall_configs)

func _spawn_enemies() -> void:
	enemies.clear()
	for enemy: Enemy in _field_builder.spawn_enemies(enemies_root, enemy_configs):
		enemy.body_entered.connect(_on_enemy_body_entered.bind(enemy))
		enemy.hit.connect(_on_enemy_hit)
		enemy.defeated.connect(_on_enemy_defeated)
		enemies.append(enemy)

func _sync_enemy_size_with_visual(enemy: Enemy) -> void:
	var collision_radius: float = ENEMY_COLLISION_RADIUS
	var enemy_sprite: Sprite2D = enemy.get_node_or_null("EnemySprite") as Sprite2D
	if enemy_sprite != null and enemy_sprite.texture != null:
		var texture_size: Vector2 = enemy_sprite.texture.get_size()
		var applied_scale: Vector2 = enemy_sprite.scale
		var scaled_size: Vector2 = Vector2(texture_size.x * absf(applied_scale.x), texture_size.y * absf(applied_scale.y))
		var diameter: float = max(scaled_size.x, scaled_size.y)
		collision_radius = max(diameter * 0.5, 1.0)
	_update_enemy_collision_shape(enemy, collision_radius)

func _update_enemy_collision_shape(enemy: Enemy, collision_radius: float) -> void:
	var collision_shape: CollisionShape2D = enemy.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		return
	var circle_shape: CircleShape2D = collision_shape.shape as CircleShape2D
	if circle_shape == null:
		circle_shape = CircleShape2D.new()
		collision_shape.shape = circle_shape
	circle_shape.radius = collision_radius

func _try_attach_sprite(parent_node: Node2D, config: Dictionary, fallback_visual: CanvasItem, sprite_name: String) -> void:
	var sprite_path: String = str(config.get("sprite_path", ""))
	if sprite_path.is_empty():
		fallback_visual.visible = true
		return
	var texture: Texture2D = load(sprite_path) as Texture2D
	if texture == null:
		fallback_visual.visible = true
		return
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = sprite_name
	sprite.texture = texture
	sprite.centered = true
	sprite.position = Vector2.ZERO
	sprite.scale = _get_sprite_scale(config)
	parent_node.add_child(sprite)
	fallback_visual.visible = false

func _get_sprite_scale(config: Dictionary) -> Vector2:
	var scale_value: Variant = config.get("sprite_scale", DEFAULT_SPRITE_SCALE)
	if scale_value is Vector2:
		return scale_value
	if scale_value is float:
		var uniform_scale: float = scale_value
		return Vector2(uniform_scale, uniform_scale)
	return DEFAULT_SPRITE_SCALE

func _spawn_flippers() -> void:
	_flippers = _field_builder.spawn_flippers(flippers_root, flipper_configs)


func get_replaceable_pin_slots() -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	for pin_node: Node in pins_root.get_children():
		if not pin_node is Pin:
			continue
		var pin: Pin = pin_node
		if not pin.replaceable or pin.occupied:
			continue
		slots.append({
			"slot_id": pin.slot_id,
			"pin_id": pin.pin_id,
			"position": pin.position,
		})
	return slots


func replace_pin_with_bumper(slot_id: String, bumper_config: Dictionary) -> bool:
	for pin_node: Node in pins_root.get_children():
		if not pin_node is Pin:
			continue
		var pin: Pin = pin_node
		if pin.slot_id != slot_id:
			continue
		if not pin.replaceable or pin.occupied:
			return false

		var config: Dictionary = bumper_config.duplicate(true)
		config["position"] = pin.position
		config["slot_id"] = slot_id
		bumper_configs.append(config.duplicate(true))
		var bumper: Bumper = _create_bumper_from_config(config, "BumperSlot_%s" % slot_id)
		bumpers_root.add_child(bumper)
		_register_bumper(bumper)

		pin.occupied = true
		for index: int in range(pin_configs.size()):
			if str(pin_configs[index].get("slot_id", "")) == slot_id:
				pin_configs[index]["occupied"] = true
				break

		pin.queue_free()
		return true
	return false


func _debug_replace_first_pin_with_power_bumper() -> void:
	var slots: Array[Dictionary] = get_replaceable_pin_slots()
	if slots.is_empty():
		return
	var target_slot_id: String = str(slots[0].get("slot_id", ""))
	if target_slot_id.is_empty():
		return
	var power_bumper_config: Dictionary = {
		"level": 1,
		"damage": 2,
		"impulse_strength": 150.0,
		"bumper_type": "power",
		"sprite_path": "res://gazou/banper_1.png",
		"sprite_scale": BUMPER_SPRITE_SCALE,
	}
	replace_pin_with_bumper(target_slot_id, power_bumper_config)


func _unhandled_input(event: InputEvent) -> void:
	if not _is_waiting_for_pin_replacement_selection:
		return
	if not (event is InputEventMouseButton):
		return
	var mouse_button_event: InputEventMouseButton = event
	if not mouse_button_event.pressed or mouse_button_event.button_index != MOUSE_BUTTON_LEFT:
		return

	var clicked_pin: Pin = _find_replaceable_pin_at_position(mouse_button_event.position)
	if clicked_pin == null:
		return
	if _pending_reward_bumper_config.is_empty():
		return

	var succeeded: bool = replace_pin_with_bumper(clicked_pin.slot_id, _pending_reward_bumper_config)
	if not succeeded:
		return

	_is_waiting_for_pin_replacement_selection = false
	_pending_reward_bumper_config = {}
	reward_status_label.text = "バンパーを配置しました"
	for button: Button in reward_option_buttons:
		button.disabled = true
	reward_header_label.text = "次ステージ（仮）へ進みます"
	_start_next_battle_placeholder()
	get_viewport().set_input_as_handled()


func _find_replaceable_pin_at_position(screen_position: Vector2) -> Pin:
	var world_position: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * screen_position
	for pin_node: Node in pins_root.get_children():
		if not pin_node is Pin:
			continue
		var pin: Pin = pin_node
		if not pin.replaceable or pin.occupied:
			continue
		if pin.global_position.distance_to(world_position) <= PIN_COLLISION_RADIUS:
			return pin
	return null

func _physics_process(delta: float) -> void:
	_update_camera_follow(delta)
	if DEBUG_ENABLE_ENEMY_ZERO_HP_COMMAND:
		var is_debug_key_down: bool = Input.is_key_pressed(DEBUG_ENEMY_ZERO_HP_KEY)
		if is_debug_key_down and not _debug_enemy_zero_hp_key_was_down:
			_debug_zero_enemy_hp()
		_debug_enemy_zero_hp_key_was_down = is_debug_key_down

	if Input.is_key_pressed(KEY_R):
		_reset_battle()
		return

	var is_replace_debug_key_down: bool = Input.is_key_pressed(DEBUG_REPLACE_PIN_WITH_POWER_BUMPER_KEY)
	if is_replace_debug_key_down and not _debug_replace_pin_key_was_down:
		_debug_replace_first_pin_with_power_bumper()
	_debug_replace_pin_key_was_down = is_replace_debug_key_down

	for index: int in range(_flippers.size()):
		var state: Dictionary = _flippers[index]
		var config: Dictionary = state["config"]
		var flipper: StaticBody2D = state["node"]
		var rest_rotation: float = float(config.get("rest_rotation", 0.0))
		var active_rotation: float = float(config.get("active_rotation", rest_rotation))
		var target: float = rest_rotation
		if Input.is_key_pressed(int(config.get("input_key", KEY_LEFT))):
			target = active_rotation
		flipper.rotation = move_toward(flipper.rotation, target, float(config.get("rotate_speed", 14.0)) * delta)

		var rotation_delta: float = flipper.rotation - float(state["previous_rotation"])
		if delta > 0.0:
			state["angular_speed"] = rotation_delta / delta
		else:
			state["angular_speed"] = 0.0
		state["previous_rotation"] = flipper.rotation
		_flippers[index] = state

	if _is_ball_alive and not _is_victory:
		_cap_ball_speed(BALL_MAX_SPEED)

	_update_enemy_bullets(delta)
	_update_damage_popups(delta)
	_update_hit_effects(delta)

func _update_camera_follow(delta: float) -> void:
	if not is_instance_valid(ball):
		return
	var follow_strength: float = clamp(delta * 3.0, 0.0, 1.0)
	game_camera.global_position = game_camera.global_position.lerp(ball.global_position, follow_strength)


func _cap_ball_speed(max_speed: float) -> void:
	var speed: float = ball.linear_velocity.length()
	if speed > max_speed and speed > 0.0:
		ball.linear_velocity = ball.linear_velocity.normalized() * max_speed

func _debug_zero_enemy_hp() -> void:
	if _is_victory or _is_game_over:
		return
	for enemy: Enemy in enemies:
		if is_instance_valid(enemy) and enemy.current_hp > 0:
			enemy.take_damage(enemy.current_hp)

func _update_enemy_bullets(delta: float) -> void:
	if _is_victory or _is_game_over:
		return
	for enemy: Enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.attack_type == "bullet" and enemy.should_fire_attack(delta):
			_spawn_enemy_bullet(enemy)

func _spawn_enemy_bullet(enemy: Enemy) -> void:
	if not _is_ball_alive:
		return
	if not is_instance_valid(enemy):
		return
	var spawn_position: Vector2 = enemy.global_position
	var bullet: Area2D = Area2D.new()
	bullet.name = "EnemyBullet"
	bullet.global_position = spawn_position
	bullet.set_meta("damage", BULLET_DAMAGE)
	bullet.collision_layer = 0
	bullet.collision_mask = 0

	var collision: CollisionShape2D = CollisionShape2D.new()
	var circle_shape: CircleShape2D = CircleShape2D.new()
	circle_shape.radius = BULLET_COLLISION_RADIUS
	collision.shape = circle_shape
	bullet.add_child(collision)

	var visual: Polygon2D = Polygon2D.new()
	visual.color = Color(1.0, 0.4, 0.35, 1.0)
	visual.polygon = PackedVector2Array([
		Vector2(0.0, -6.0),
		Vector2(6.0, 0.0),
		Vector2(0.0, 6.0),
		Vector2(-6.0, 0.0),
	])
	bullet.add_child(visual)

	var to_ball: Vector2 = (ball.global_position - bullet.global_position).normalized()
	if to_ball == Vector2.ZERO:
		to_ball = Vector2.DOWN
	bullet.set_meta("velocity", to_ball * BULLET_SPEED)
	bullets_root.add_child(bullet)

func _on_drain_body_entered(body: Node2D) -> void:
	if body == ball and _is_ball_alive:
		_reset_combo_count()
		reset_ball()
		return
	if body is AssistBall:
		var assist_ball: AssistBall = body
		assist_ball.disappear()

func _on_ball_body_entered(body: Node) -> void:
	for state: Dictionary in _flippers:
		var flipper: StaticBody2D = state["node"]
		if body == flipper and _is_flipper_striking(state):
			_apply_flipper_impulse(flipper, state["config"])
			break

func _is_flipper_striking(state: Dictionary) -> bool:
	var config: Dictionary = state["config"]
	var side: float = float(config.get("side", 1.0))
	var angular_speed: float = float(state.get("angular_speed", 0.0))
	if side < 0.0:
		return angular_speed <= -FLIPPER_ACTIVE_ANGULAR_SPEED_THRESHOLD
	return angular_speed >= FLIPPER_ACTIVE_ANGULAR_SPEED_THRESHOLD

func _apply_flipper_impulse(flipper: StaticBody2D, config: Dictionary) -> void:
	if _is_victory or _is_game_over:
		return
	var side: float = float(config.get("side", 1.0))
	var pivot_to_ball: Vector2 = (ball.global_position - flipper.global_position).normalized()
	var impulse_direction: Vector2 = Vector2(0.4 * side, -1.0).normalized()
	if pivot_to_ball != Vector2.ZERO:
		impulse_direction = (impulse_direction + pivot_to_ball * 0.35).normalized()
	var hit_impulse: float = float(config.get("hit_impulse", 1600.0))
	var impulse: Vector2 = impulse_direction * hit_impulse
	ball.apply_central_impulse(impulse)
	_cap_ball_speed(BALL_FLIPPER_POST_HIT_MAX_SPEED)

func reset_ball() -> void:
	if not _is_ball_alive:
		return
	ball.sleeping = true
	ball.global_position = BALL_START_POSITION
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	ball.sleeping = false
	ball.apply_central_impulse(BALL_LAUNCH_IMPULSE)
	_cap_ball_speed(BALL_MAX_SPEED)

func _on_bumper_body_entered(body: Node2D, bumper: Bumper) -> void:
	if _is_victory or _is_game_over:
		return
	if body != ball:
		return
	bumper.on_ball_entered(ball)

func _on_bumper_hit(bumper: Bumper, bumper_type: String, _damage: int) -> void:
	if _is_victory or _is_game_over:
		return
	_apply_bumper_effect(bumper_type)
	if bumper_type == "summon_ball":
		_spawn_assist_ball(bumper)
	_update_combo_label()
	_update_bonus_damage_label()

func _on_enemy_body_entered(body: Node2D, enemy: Enemy) -> void:
	if _is_victory or _is_game_over:
		return
	if body is AssistBall:
		_apply_assist_ball_enemy_hit(body, enemy)
		return
	if body != ball:
		return
	var combo_damage_bonus: int = int(floor(float(combo_count) / 3.0))
	var total_damage: int = 1 + combo_damage_bonus + _next_enemy_hit_bonus_damage
	var knockback_direction: Vector2 = (enemy.global_position - ball.global_position)
	if knockback_direction == Vector2.ZERO:
		knockback_direction = ball.linear_velocity
	if knockback_direction == Vector2.ZERO:
		knockback_direction = Vector2.UP
	enemy.apply_knockback(knockback_direction, ENEMY_HIT_KNOCKBACK_STRENGTH)
	enemy.take_damage(total_damage)
	_next_enemy_hit_bonus_damage = 0
	_update_bonus_damage_label()
	_reset_combo_count()

func _spawn_assist_ball(bumper: Bumper) -> void:
	if _get_active_assist_ball_count() >= ASSIST_BALL_MAX_COUNT:
		return
	var assist_ball: AssistBall = AssistBall.new()
	assist_ball.name = "AssistBall"
	assist_ball.hp = ASSIST_BALL_HP
	assist_ball.attack_damage = ASSIST_BALL_ATTACK_DAMAGE
	assist_ball.life_time = ASSIST_BALL_LIFE_TIME
	assist_ball.max_speed = ASSIST_BALL_MAX_SPEED
	assist_ball.mass = 0.22
	assist_ball.gravity_scale = ball.gravity_scale
	assist_ball.physics_material_override = ball.physics_material_override
	assist_ball.linear_damp = ball.linear_damp
	assist_ball.angular_damp = ball.angular_damp
	assist_ball.global_position = bumper.global_position + ASSIST_BALL_SPAWN_OFFSET
	_add_assist_ball_collision(assist_ball)
	_add_assist_ball_visual(assist_ball)
	assist_ball.expired.connect(_on_assist_ball_expired)
	assist_balls_root.add_child(assist_ball)
	_update_assist_balls_label()
	var random_x: float = randf_range(-ASSIST_BALL_SPAWN_IMPULSE_RANDOM_X, ASSIST_BALL_SPAWN_IMPULSE_RANDOM_X)
	assist_ball.apply_central_impulse(ASSIST_BALL_SPAWN_IMPULSE_BASE + Vector2(random_x, 0.0))
	_spawn_hit_effect(assist_ball.global_position)


func _add_assist_ball_collision(assist_ball: AssistBall) -> void:
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	var circle_shape: CircleShape2D = CircleShape2D.new()
	circle_shape.radius = ASSIST_BALL_COLLISION_RADIUS
	collision_shape.shape = circle_shape
	assist_ball.add_child(collision_shape)


func _add_assist_ball_visual(assist_ball: AssistBall) -> void:
	var visual: Polygon2D = Polygon2D.new()
	visual.name = "AssistBallVisual"
	visual.color = ASSIST_BALL_VISUAL_COLOR
	visual.polygon = PackedVector2Array([
		Vector2(0.0, -7.2),
		Vector2(5.1, -5.1),
		Vector2(7.2, 0.0),
		Vector2(5.1, 5.1),
		Vector2(0.0, 7.2),
		Vector2(-5.1, 5.1),
		Vector2(-7.2, 0.0),
		Vector2(-5.1, -5.1),
	])
	assist_ball.add_child(visual)


func _get_active_assist_ball_count() -> int:
	var count: int = 0
	for child: Node in assist_balls_root.get_children():
		if child is AssistBall and not child.is_queued_for_deletion():
			count += 1
	return count


func _apply_assist_ball_enemy_hit(assist_ball: AssistBall, enemy: Enemy) -> void:
	if not is_instance_valid(enemy):
		return
	if assist_ball.is_queued_for_deletion():
		return
	enemy.take_damage(assist_ball.attack_damage)
	assist_ball.take_damage(1)


func _try_hit_assist_ball_with_bullet(bullet: Area2D) -> bool:
	for child: Node in assist_balls_root.get_children():
		if not (child is AssistBall):
			continue
		var assist_ball: AssistBall = child
		if assist_ball.is_queued_for_deletion():
			continue
		if bullet.global_position.distance_to(assist_ball.global_position) <= (ASSIST_BALL_COLLISION_RADIUS + BULLET_COLLISION_RADIUS):
			assist_ball.take_damage(1)
			return true
	return false


func _on_assist_ball_expired(_assist_ball: AssistBall) -> void:
	call_deferred("_update_assist_balls_label")


func _clear_assist_balls() -> void:
	for child: Node in assist_balls_root.get_children():
		child.queue_free()
	call_deferred("_update_assist_balls_label")

func _on_enemy_hit(enemy: Enemy, damage: int) -> void:
	_update_enemy_hp_label()
	_spawn_damage_popup(enemy, damage)
	_play_enemy_hit_flash(enemy)
	_spawn_hit_effect(enemy.global_position)

func _on_enemy_defeated(_enemy: Enemy) -> void:
	_update_enemy_hp_label()
	_enter_victory_state()

func _spawn_damage_popup(enemy: Enemy, damage: int) -> void:
	if not is_instance_valid(enemy):
		return
	var popup_label: Label = Label.new()
	popup_label.text = "-%d" % damage
	popup_label.modulate = DAMAGE_POPUP_COLOR
	popup_label.add_theme_font_size_override("font_size", DAMAGE_POPUP_FONT_SIZE)
	popup_label.top_level = true
	popup_label.global_position = enemy.global_position + DAMAGE_POPUP_OFFSET
	add_child(popup_label)
	_damage_popups.append({
		"label": popup_label,
		"elapsed": 0.0,
		"start_position": popup_label.global_position,
	})

func _play_enemy_hit_flash(enemy: Enemy) -> void:
	var enemy_visual: CanvasItem = enemy.get_node_or_null("EnemySprite") as CanvasItem
	if enemy_visual == null:
		enemy_visual = enemy.get_node_or_null("EnemyVisual") as CanvasItem
	if enemy_visual == null:
		return
	enemy_visual.modulate = ENEMY_HIT_FLASH_COLOR
	var tween: Tween = create_tween()
	tween.tween_property(enemy_visual, "modulate", Color(1.0, 1.0, 1.0, 1.0), ENEMY_HIT_FLASH_DURATION)

func _spawn_hit_effect(world_position: Vector2) -> void:
	var effect: Polygon2D = Polygon2D.new()
	effect.polygon = PackedVector2Array([
		Vector2(-1.0, -1.0),
		Vector2(1.0, -1.0),
		Vector2(1.0, 1.0),
		Vector2(-1.0, 1.0),
	])
	effect.color = HIT_EFFECT_COLOR
	effect.top_level = true
	effect.global_position = world_position
	effect.scale = Vector2.ONE * HIT_EFFECT_START_RADIUS
	add_child(effect)
	_hit_effects.append({
		"node": effect,
		"elapsed": 0.0,
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

func _update_hit_effects(delta: float) -> void:
	for index: int in range(_hit_effects.size() - 1, -1, -1):
		var effect_data: Dictionary = _hit_effects[index]
		var effect: Polygon2D = effect_data["node"]
		if not is_instance_valid(effect):
			_hit_effects.remove_at(index)
			continue
		var elapsed: float = float(effect_data["elapsed"]) + delta
		effect_data["elapsed"] = elapsed
		var progress: float = min(elapsed / HIT_EFFECT_DURATION, 1.0)
		var radius: float = lerpf(HIT_EFFECT_START_RADIUS, HIT_EFFECT_END_RADIUS, progress)
		effect.scale = Vector2.ONE * radius
		effect.color.a = HIT_EFFECT_COLOR.a * (1.0 - progress)
		_hit_effects[index] = effect_data
		if progress >= 1.0:
			effect.queue_free()
			_hit_effects.remove_at(index)

func _enter_victory_state() -> void:
	_is_victory = true
	_clear_assist_balls()
	ball.sleeping = true
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	victory_label.visible = true
	_show_reward_panel()

func _setup_reward_panel() -> void:
	reward_panel.visible = false
	for index: int in range(reward_option_buttons.size()):
		reward_option_buttons[index].pressed.connect(_on_reward_button_pressed.bind(index))
	reward_header_label.text = "報酬を1つ選んでください"
	reward_status_label.text = ""

func _show_reward_panel() -> void:
	_reward_selected_this_victory = false
	_is_waiting_for_pin_replacement_selection = false
	_pending_reward_bumper_config = {}
	reward_panel.visible = true
	reward_status_label.text = ""
	_current_reward_options = _reward_manager.get_random_reward_options(reward_option_buttons.size())
	for index: int in range(reward_option_buttons.size()):
		var button: Button = reward_option_buttons[index]
		button.disabled = false
		button.text = _reward_manager.get_reward_label(_current_reward_options[index], Bumper.MAX_LEVEL)

func _on_reward_button_pressed(button_index: int) -> void:
	if _reward_selected_this_victory:
		return
	if button_index < 0 or button_index >= _current_reward_options.size():
		return
	_reward_selected_this_victory = true
	var reward_id: String = _current_reward_options[button_index]
	var requires_pin_selection: bool = _apply_reward(reward_id)
	_reward_manager.increment_reward_level(reward_id)
	reward_status_label.text = _reward_manager.get_reward_result_text(reward_id, Bumper.MAX_LEVEL)
	for button: Button in reward_option_buttons:
		button.disabled = true
	if requires_pin_selection:
		reward_header_label.text = "配置先のピンをクリックしてください"
		return
	reward_header_label.text = "次ステージ（仮）へ進みます"
	_start_next_battle_placeholder()

func _apply_reward(reward_id: String) -> bool:
	match reward_id:
		"normal_to_power":
			return _apply_normal_to_power_reward()
		"random_bumper_damage":
			return _apply_random_bumper_damage_reward()
		"add_heal_bumper":
			return _apply_add_heal_bumper_reward()
		"add_summon_ball_bumper":
			return _apply_add_summon_ball_bumper_reward()
		"enhance_slow":
			return _apply_enhance_slow_reward()
	return false

func _apply_normal_to_power_reward() -> bool:
	for config: Dictionary in bumper_configs:
		if str(config.get("bumper_type", "normal")) == "normal":
			config["bumper_type"] = "power"
			break
	return false

func _apply_random_bumper_damage_reward() -> bool:
	if bumper_configs.is_empty():
		return false
	var random_index: int = randi() % bumper_configs.size()
	var selected_config: Dictionary = bumper_configs[random_index]
	var current_level: int = int(selected_config.get("level", 1))
	selected_config["level"] = mini(current_level + 1, Bumper.MAX_LEVEL)
	bumper_configs[random_index] = selected_config
	return false

func _apply_add_heal_bumper_reward() -> bool:
	_pending_reward_bumper_config = {
		"level": 1,
		"damage": 1,
		"impulse_strength": 130.0,
		"bumper_type": "heal",
		"sprite_path": "res://gazou/banper_2.png",
		"sprite_scale": BUMPER_SPRITE_SCALE,
	}
	_is_waiting_for_pin_replacement_selection = true
	return true

func _apply_add_summon_ball_bumper_reward() -> bool:
	_pending_reward_bumper_config = {
		"level": 1,
		"damage": 1,
		"impulse_strength": 130.0,
		"bumper_type": "summon_ball",
		"cooldown_time": 1.2,
		"sprite_path": "res://gazou/banper_3.png",
		"sprite_scale": BUMPER_SPRITE_SCALE,
	}
	_is_waiting_for_pin_replacement_selection = true
	return true

func _apply_enhance_slow_reward() -> bool:
	_slow_effect_multiplier += 0.25
	_update_status_label()
	return false

func _start_next_battle_placeholder() -> void:
	await get_tree().create_timer(0.8).timeout
	reward_panel.visible = false
	_reset_battle()

func _get_ball_max_hp() -> int:
	return BALL_HP_INITIAL

func _update_enemy_hp_label() -> void:
	var current_hp: int = 0
	if enemies.size() > 0 and is_instance_valid(enemies[0]):
		current_hp = enemies[0].current_hp
	if current_hp < 0:
		current_hp = 0
	enemy_hp_label.text = "Enemy HP: %d" % current_hp

func _update_combo_label() -> void:
	combo_label.text = "Combo: %d" % combo_count
	_update_status_label()

func _update_bonus_damage_label() -> void:
	bonus_damage_label.text = "Next Bonus DMG: +%d" % _next_enemy_hit_bonus_damage
	_update_status_label()

func _update_assist_balls_label() -> void:
	assist_balls_label.text = "Assist Balls: %d / %d" % [_get_active_assist_ball_count(), ASSIST_BALL_MAX_COUNT]
	_update_status_label()

func _update_status_label() -> void:
	if not is_node_ready():
		return
	var status_lines: Array[String] = [
		"Status: %s" % _get_battle_status_text(),
		"Combo: %d" % combo_count,
		"Next Bonus Damage: +%d" % _next_enemy_hit_bonus_damage,
		"Assist Balls: %d / %d" % [_get_active_assist_ball_count(), ASSIST_BALL_MAX_COUNT],
	]
	if _slow_effect_multiplier > 1.0:
		status_lines.append("Slow Boost: x%.2f" % _slow_effect_multiplier)
	status_label.text = "\n".join(status_lines)

func _get_battle_status_text() -> String:
	if _is_victory:
		return "Victory"
	if _is_game_over:
		return "Game Over"
	if not _is_ball_alive:
		return "Ball Down"
	return "In Battle"

func _reset_combo_count() -> void:
	combo_count = 0
	_update_combo_label()

func _apply_bumper_effect(bumper_type: String) -> void:
	match bumper_type:
		"normal":
			combo_count += 1
		"power":
			combo_count += 2
			_next_enemy_hit_bonus_damage += 1
		"heal":
			if _ball_hp < _get_ball_max_hp():
				_ball_hp += 1
				ball_hp_bar.value = _ball_hp
		"slow":
			var slow_rate: float = max(0.2, 0.8 - ((_slow_effect_multiplier - 1.0) * 0.15))
			var new_velocity: Vector2 = ball.linear_velocity * slow_rate
			var speed: float = new_velocity.length()
			if speed < BALL_MIN_SPEED:
				if speed <= 0.001:
					new_velocity = Vector2.UP * BALL_MIN_SPEED
				else:
					new_velocity = new_velocity.normalized() * BALL_MIN_SPEED
			ball.linear_velocity = new_velocity
		"summon_ball":
			combo_count += 1
		_:
			combo_count += 1

func _damage_ball(damage: int) -> void:
	if _is_victory or _is_game_over or not _is_ball_alive:
		return
	_ball_hp -= damage
	ball_hp_bar.value = max(_ball_hp, 0)
	if _ball_hp <= 0:
		_destroy_ball()

func _destroy_ball() -> void:
	if not _is_ball_alive:
		return
	_is_ball_alive = false
	ball.visible = false
	ball.freeze = true
	for child: Node in bullets_root.get_children():
		child.queue_free()
	_enter_game_over_state()

func _enter_game_over_state() -> void:
	_is_game_over = true
	_clear_assist_balls()
	game_over_label.visible = true

func _reset_battle() -> void:
	_is_victory = false
	_is_game_over = false
	_is_ball_alive = true
	_spawn_bumpers()
	_hovered_bumper = null
	bumper_tooltip_panel.visible = false
	for enemy: Enemy in enemies:
		if is_instance_valid(enemy):
			enemy.current_hp = enemy.max_hp
			enemy.reset_attack_timer()
	_ball_hp = _get_ball_max_hp()
	_bullet_fire_elapsed = 0.0
	_next_enemy_hit_bonus_damage = 0
	_reset_combo_count()
	_update_bonus_damage_label()
	_update_enemy_hp_label()
	_update_assist_balls_label()
	ball_hp_bar.max_value = _ball_hp
	ball_hp_bar.value = _ball_hp
	victory_label.visible = false
	game_over_label.visible = false
	reward_panel.visible = false
	_is_waiting_for_pin_replacement_selection = false
	_pending_reward_bumper_config = {}
	ball.visible = true
	ball.freeze = false
	for child: Node in bullets_root.get_children():
		child.queue_free()
	_clear_assist_balls()
	for popup: Dictionary in _damage_popups:
		var popup_label: Label = popup.get("label")
		if is_instance_valid(popup_label):
			popup_label.queue_free()
	_damage_popups.clear()
	for effect_data: Dictionary in _hit_effects:
		var effect_node: Polygon2D = effect_data.get("node")
		if is_instance_valid(effect_node):
			effect_node.queue_free()
	_hit_effects.clear()
	reset_ball()

func _process(delta: float) -> void:
	if _hovered_bumper != null:
		_update_bumper_tooltip_position()
		bumper_tooltip_label.text = _hovered_bumper.get_tooltip_text()
	for index: int in range(bullets_root.get_child_count() - 1, -1, -1):
		var bullet_node: Node = bullets_root.get_child(index)
		if not (bullet_node is Area2D):
			continue
		var bullet: Area2D = bullet_node
		var velocity: Vector2 = bullet.get_meta("velocity", Vector2.ZERO)
		bullet.global_position += velocity * delta
		if _is_ball_alive and bullet.global_position.distance_to(ball.global_position) <= (_ball_collision_radius + BULLET_COLLISION_RADIUS):
			_damage_ball(int(bullet.get_meta("damage", BULLET_DAMAGE)))
			bullet.queue_free()
			continue
		if _try_hit_assist_ball_with_bullet(bullet):
			bullet.queue_free()
			continue
		if bullet.global_position.y > FIELD_HEIGHT or bullet.global_position.x < -20.0 or bullet.global_position.x > FIELD_WIDTH + 20.0:
			bullet.queue_free()
