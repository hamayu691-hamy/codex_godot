extends Node2D

const StageConfig = preload("res://scripts/gameplay/stage_config.gd")
const FieldBuilder = preload("res://scripts/gameplay/field_builder.gd")
const RewardManager = preload("res://scripts/gameplay/reward_manager.gd")
const AssistBall = preload("res://scripts/gameplay/assist_ball.gd")
const BumperLevelTable = preload("res://scripts/gameplay/bumper_level_table.gd")
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
const PLAYER_DAMAGE_POPUP_COLOR: Color = Color(1.0, 0.2, 0.16, 1.0)
const PLAYER_DAMAGE_POPUP_FONT_SIZE: int = 24
const ASSIST_BALL_DAMAGE_POPUP_COLOR: Color = Color(1.0, 0.38, 0.32, 0.92)
const ASSIST_BALL_DAMAGE_POPUP_FONT_SIZE: int = 16
const ASSIST_BALL_DAMAGE_POPUP_OFFSET: Vector2 = Vector2(0.0, -20.0)
const ASSIST_BALL_DAMAGE_POPUP_DURATION: float = 0.35
const ASSIST_BALL_DAMAGE_POPUP_RISE: float = 14.0
const ASSIST_BALL_DAMAGE_EFFECT_COLOR: Color = Color(1.0, 0.3, 0.25, 0.72)
const ASSIST_BALL_DAMAGE_EFFECT_DURATION: float = 0.12
const ASSIST_BALL_DAMAGE_EFFECT_START_RADIUS: float = 3.0
const ASSIST_BALL_DAMAGE_EFFECT_END_RADIUS: float = 11.0
const PLAYER_DAMAGE_FLASH_COLOR: Color = Color(2.4, 0.12, 0.12, 1.0)
const PLAYER_DAMAGE_FLASH_STEP_DURATION: float = 0.055
const PLAYER_DAMAGE_HP_BAR_COLOR: Color = Color(2.5, 0.18, 0.18, 1.0)
const PLAYER_DAMAGE_HP_BAR_PULSE_SCALE: Vector2 = Vector2(1.2, 1.45)
const PLAYER_DAMAGE_HP_BAR_PULSE_DURATION: float = 0.09
const PLAYER_DAMAGE_SHAKE_STRENGTH: float = 7.0
const PLAYER_DAMAGE_SHAKE_STEP_DURATION: float = 0.035
const ENEMY_HIT_FLASH_DURATION: float = 0.11
const ENEMY_HIT_FLASH_COLOR: Color = Color(2.6, 2.6, 2.6, 1.0)
const HIT_EFFECT_DURATION: float = 0.2
const HIT_EFFECT_START_RADIUS: float = 6.0
const HIT_EFFECT_END_RADIUS: float = 20.0
const HIT_EFFECT_COLOR: Color = Color(1.0, 0.95, 0.7, 0.9)
const CLEAR_SLOW_TIME_SCALE: float = 0.35
const CLEAR_SLOW_DURATION: float = 0.8
const CLEAR_CAMERA_ZOOM: Vector2 = Vector2(1.25, 1.25)
const CLEAR_CAMERA_FOCUS_DURATION: float = 0.8
const CLEAR_REWARD_DELAY: float = 0.3
const CLEAR_EFFECT_COLOR: Color = Color(1.0, 0.85, 0.25, 0.95)
const FEVER_TRIGGER_BUMPER_HITS: int = 15
const FEVER_DURATION: float = 5.0
const FEVER_COMBO_GAIN_MULTIPLIER: int = 2
const FEVER_SUMMON_BALL_BONUS_COUNT: int = 1
const FEVER_BUMPER_COOLDOWN_MULTIPLIER: float = 0.55
const FEVER_HIT_EFFECT_MULTIPLIER: float = 1.45
const FEVER_BACKGROUND_MODULATE: Color = Color(1.18, 1.12, 0.82, 1.0)
const FEVER_EFFECT_COLOR: Color = Color(1.0, 0.82, 0.18, 0.95)
const CLEAR_EFFECT_END_RADIUS: float = 70.0
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
	"aim": Color(0.65, 0.4, 0.95, 1.0),
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
const BULLET_TYPE_NORMAL: String = "normal"
const BULLET_TYPE_BOSS_FAN: String = "boss_fan"
const BOSS_FAN_BURST_BULLET_COUNT: int = 3
const BOSS_FAN_BURST_TOTAL_ANGLE_DEGREES: float = 36.0
const BOSS_FAN_BURST_BULLET_SPEED: float = 300.0
const BOSS_FAN_BURST_BULLET_DAMAGE: int = 2
const BOSS_FAN_BURST_TELEGRAPH_DURATION: float = 0.25
const BOSS_FAN_BURST_BULLET_RADIUS: float = 9.0
const BOSS_FAN_BURST_BULLET_COLOR: Color = Color(1.0, 0.2, 0.85, 1.0)
const BOSS_FAN_BURST_EFFECT_COLOR: Color = Color(1.0, 0.42, 0.95, 0.5)
const MAX_ENEMY_BULLETS: int = 80
const BOSS_HP_BAR_SIZE: Vector2 = Vector2(520.0, 18.0)
const BOSS_HP_BAR_POSITION: Vector2 = Vector2(140.0, 20.0)
const BOSS_MESSAGE_DURATION: float = 1.2
const BOSS_HIT_EFFECT_MULTIPLIER: float = 1.35
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
const ASSIST_BALL_MAX_SPEED: float = 850.0
const ASSIST_BALL_COLLISION_RADIUS: float = 9.0
const ASSIST_BALL_SPAWN_OFFSET: Vector2 = Vector2(0.0, -30.0)
const ASSIST_BALL_SPAWN_IMPULSE_BASE: Vector2 = Vector2(0.0, -520.0)
const ASSIST_BALL_SPAWN_IMPULSE_RANDOM_X: float = 260.0
const BOMB_EXPLOSION_RADIUS: float = 90.0
const BOMB_EXPLOSION_DAMAGE: int = 2
const BOMB_MAIN_BALL_KNOCKBACK: float = 180.0
const BOMB_ASSIST_BALL_KNOCKBACK: float = 360.0
const BOMB_EXPLOSION_EFFECT_DURATION: float = 0.28
const BOMB_EXPLOSION_EFFECT_START_RADIUS: float = 12.0
const BOMB_EXPLOSION_EFFECT_COLOR: Color = Color(1.0, 0.55, 0.12, 0.62)
const BOMB_EXPLOSION_EFFECT_SEGMENTS: int = 28
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
@onready var audio_manager: AudioManager = $AudioManager
@onready var game_camera: Camera2D = $GameCamera
@onready var ball_hp_bar: ProgressBar = $Ball/BallHpBar
@onready var enemy_hp_label: Label = $UI/EnemyHpLabel
@onready var boss_hp_bar: ProgressBar = _create_boss_hp_bar()
@onready var boss_message_label: Label = _create_boss_message_label()
@onready var combo_label: Label = $UI/ComboLabel
@onready var bonus_damage_label: Label = $UI/BonusDamageLabel
@onready var assist_balls_label: Label = $UI/AssistBallsLabel
@onready var status_label: Label = $UI/StatusLabel
@onready var fever_label: Label = $UI/FeverLabel
@onready var fever_time_label: Label = $UI/FeverTimeLabel
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

var _stage_loop_ids: Array[String] = []
var _current_stage_index: int = 0
var _current_stage_id: String = "stage_01"

var _flippers: Array[Dictionary] = []
var _ball_hp: int = BALL_HP_INITIAL
var _is_victory: bool = false
var _is_stage_clearing: bool = false
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
var _is_waiting_for_reward_bumper_target_selection: bool = false
var _slow_effect_multiplier: float = 1.0
var combo_count: int = 0
var _next_enemy_hit_bonus_damage: int = 0
var _bullet_fire_elapsed: float = 0.0
var _hovered_bumper: Bumper = null
var _ball_collision_radius: float = BALL_SPRITE_TARGET_DIAMETER * 0.5
var _field_builder: FieldBuilder
var _player_damage_flash_tween: Tween
var _player_damage_hp_bar_tween: Tween
var _player_damage_shake_tween: Tween
var _ball_visual_base_modulates: Dictionary = {}
var _stage_clear_sequence_id: int = 0
var _camera_default_zoom: Vector2 = Vector2.ONE
var _bumper_hit_count: int = 0
var _is_fever_active: bool = false
var _fever_remaining: float = 0.0
var _background_base_modulate: Color = Color.WHITE
var _boss_message_tween: Tween

func _ready() -> void:
	_stage_loop_ids = StageConfig.get_stage_loop_ids()
	if _stage_loop_ids.is_empty():
		_stage_loop_ids = ["stage_01"]
	_current_stage_index = 0
	_current_stage_id = _stage_loop_ids[_current_stage_index]
	_load_stage_config(_current_stage_id)
	_field_builder = FieldBuilder.new(PIN_COLLISION_RADIUS, BUMPER_COLLISION_RADIUS, ENEMY_COLLISION_RADIUS, BUMPER_VISUAL_COLOR, BUMPER_VISUAL_COLOR_BY_TYPE, BUMPER_VISUAL_POINTS, ENEMY_VISUAL_COLOR, ENEMY_HP_INITIAL)
	_setup_background()
	_setup_fever_ui()
	_setup_boss_ui()
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

func _exit_tree() -> void:
	Engine.time_scale = 1.0

func _load_stage_config(stage_id: String) -> void:
	_current_stage_id = stage_id
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
	_background_base_modulate = background_root.modulate
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

func _setup_fever_ui() -> void:
	fever_label.visible = false
	fever_time_label.visible = false
	fever_label.add_theme_color_override("font_color", FEVER_EFFECT_COLOR)
	fever_time_label.add_theme_color_override("font_color", FEVER_EFFECT_COLOR)

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
	_camera_default_zoom = game_camera.zoom

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
	ball_hp_bar.pivot_offset = BALL_HP_BAR_SIZE * 0.5


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
	var spawned_bumpers: Array[Bumper] = _field_builder.spawn_bumpers(bumpers_root, bumper_configs)
	for index: int in range(spawned_bumpers.size()):
		var bumper: Bumper = spawned_bumpers[index]
		bumper.set_meta("config_index", index)
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
		enemy.phase_two_started.connect(_on_boss_phase_two_started)
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
		bumper.set_meta("config_index", bumper_configs.size() - 1)
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
	if not _is_waiting_for_reward_bumper_target_selection:
		return
	if not (event is InputEventMouseButton):
		return
	var mouse_button_event: InputEventMouseButton = event
	if not mouse_button_event.pressed or mouse_button_event.button_index != MOUSE_BUTTON_LEFT:
		return
	if _pending_reward_bumper_config.is_empty():
		return

	var clicked_pin: Pin = _find_replaceable_pin_at_position(mouse_button_event.position)
	if clicked_pin != null and replace_pin_with_bumper(clicked_pin.slot_id, _pending_reward_bumper_config):
		_complete_reward_bumper_target_selection("バンパーを配置しました")
		get_viewport().set_input_as_handled()
		return

	var clicked_bumper: Bumper = _find_bumper_at_position(mouse_button_event.position)
	if clicked_bumper == null:
		return
	var reward_bumper_type: String = str(_pending_reward_bumper_config.get("bumper_type", ""))
	if clicked_bumper.bumper_type != reward_bumper_type:
		reward_status_label.text = "異なる種類のバンパーには配置できません"
		return
	if not _level_up_bumper(clicked_bumper):
		reward_status_label.text = "最大LvのバンパーはLvアップできません"
		return
	_complete_reward_bumper_target_selection("同種バンパーを重ねてLvアップしました")
	get_viewport().set_input_as_handled()

func _complete_reward_bumper_target_selection(result_text: String) -> void:
	_is_waiting_for_reward_bumper_target_selection = false
	_pending_reward_bumper_config = {}
	reward_status_label.text = result_text
	for button: Button in reward_option_buttons:
		button.disabled = true
	reward_header_label.text = _get_next_stage_message()
	_start_next_battle_placeholder()

func _level_up_bumper(bumper: Bumper) -> bool:
	if not bumper.level_up():
		return false
	audio_manager.play_se("bumper_level_up")
	var config_index: int = int(bumper.get_meta("config_index", -1))
	if config_index >= 0 and config_index < bumper_configs.size():
		var config: Dictionary = bumper_configs[config_index]
		config["level"] = bumper.level
		bumper_configs[config_index] = config
	return true

func _find_bumper_at_position(screen_position: Vector2) -> Bumper:
	var world_position: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * screen_position
	for bumper: Bumper in bumpers:
		if is_instance_valid(bumper) and bumper.global_position.distance_to(world_position) <= BUMPER_COLLISION_RADIUS:
			return bumper
	return null

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
	_update_fever(delta)
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
	if not is_instance_valid(ball) or _is_stage_clearing:
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
		if enemy.attack_type in ["bullet", "fan_burst"] and enemy.should_fire_attack(delta):
			_spawn_enemy_bullet(enemy)
		if enemy.should_fire_fan_burst(delta):
			_start_boss_fan_burst(enemy)

func _spawn_enemy_bullet(enemy: Enemy) -> void:
	if not _is_ball_alive:
		return
	if not is_instance_valid(enemy):
		return
	var to_ball: Vector2 = (ball.global_position - enemy.global_position).normalized()
	if to_ball == Vector2.ZERO:
		to_ball = Vector2.DOWN
	_spawn_enemy_bullet_with_params(
		enemy.global_position,
		to_ball,
		BULLET_SPEED,
		enemy.bullet_damage,
		enemy.bullet_radius,
		enemy.bullet_color,
		BULLET_TYPE_NORMAL
	)

func _start_boss_fan_burst(enemy: Enemy) -> void:
	if enemy.get_meta("is_fan_burst_telegraphing", false):
		return
	_telegraph_and_spawn_boss_fan_burst(enemy)

func _telegraph_and_spawn_boss_fan_burst(enemy: Enemy) -> void:
	if not _is_ball_alive or not is_instance_valid(enemy) or not enemy.is_phase_two():
		return
	enemy.set_meta("is_fan_burst_telegraphing", true)
	enemy.play_fan_burst_telegraph(BOSS_FAN_BURST_TELEGRAPH_DURATION)
	await get_tree().create_timer(BOSS_FAN_BURST_TELEGRAPH_DURATION).timeout
	if is_instance_valid(enemy):
		enemy.set_meta("is_fan_burst_telegraphing", false)
	if _is_victory or _is_game_over or not _is_ball_alive:
		return
	if not is_instance_valid(enemy) or enemy.is_defeated or not enemy.is_phase_two():
		return
	_spawn_boss_fan_burst(enemy)

func _spawn_boss_fan_burst(enemy: Enemy) -> void:
	var center_direction: Vector2 = (ball.global_position - enemy.global_position).normalized()
	if center_direction == Vector2.ZERO:
		center_direction = Vector2.DOWN
	_spawn_boss_fan_burst_effect(enemy.global_position, center_direction)
	audio_manager.play_se("boss_fan_burst")
	var bullet_count: int = max(BOSS_FAN_BURST_BULLET_COUNT, 1)
	var angle_step: float = 0.0
	if bullet_count > 1:
		angle_step = deg_to_rad(BOSS_FAN_BURST_TOTAL_ANGLE_DEGREES) / float(bullet_count - 1)
	var start_angle: float = -angle_step * float(bullet_count - 1) * 0.5
	for index: int in range(bullet_count):
		if _get_active_enemy_bullet_count() >= MAX_ENEMY_BULLETS:
			return
		var direction: Vector2 = center_direction.rotated(start_angle + angle_step * float(index)).normalized()
		_spawn_enemy_bullet_with_params(enemy.global_position, direction, BOSS_FAN_BURST_BULLET_SPEED, BOSS_FAN_BURST_BULLET_DAMAGE, BOSS_FAN_BURST_BULLET_RADIUS, BOSS_FAN_BURST_BULLET_COLOR, BULLET_TYPE_BOSS_FAN)

func _spawn_enemy_bullet_with_params(spawn_position: Vector2, direction: Vector2, speed: float, damage: int, radius: float, color: Color, bullet_type: String) -> void:
	if _get_active_enemy_bullet_count() >= MAX_ENEMY_BULLETS:
		return
	var bullet: Area2D = Area2D.new()
	bullet.name = "EnemyBullet"
	bullet.global_position = spawn_position
	bullet.set_meta("damage", damage)
	bullet.set_meta("radius", radius)
	bullet.set_meta("bullet_type", bullet_type)
	bullet.collision_layer = 0
	bullet.collision_mask = 0
	var collision: CollisionShape2D = CollisionShape2D.new()
	var circle_shape: CircleShape2D = CircleShape2D.new()
	circle_shape.radius = radius
	collision.shape = circle_shape
	bullet.add_child(collision)
	var visual: Polygon2D = Polygon2D.new()
	visual.color = color
	visual.polygon = PackedVector2Array([Vector2(0.0, -radius), Vector2(radius, 0.0), Vector2(0.0, radius), Vector2(-radius, 0.0)])
	bullet.add_child(visual)
	bullet.set_meta("velocity", direction.normalized() * speed)
	bullets_root.add_child(bullet)

func _get_active_enemy_bullet_count() -> int:
	var count: int = 0
	for child: Node in bullets_root.get_children():
		if child is Area2D and not child.is_queued_for_deletion():
			count += 1
	return count

func _spawn_boss_fan_burst_effect(origin: Vector2, direction: Vector2) -> void:
	var effect: Polygon2D = Polygon2D.new()
	effect.color = BOSS_FAN_BURST_EFFECT_COLOR
	effect.global_position = origin
	effect.rotation = direction.angle()
	effect.polygon = PackedVector2Array([Vector2(12.0, 0.0), Vector2(42.0, -10.0), Vector2(42.0, 10.0)])
	bullets_root.add_child(effect)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(effect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.18)
	tween.tween_property(effect, "scale", Vector2.ONE * 1.35, 0.18)
	tween.chain().tween_callback(func() -> void: effect.queue_free())

func _on_drain_body_entered(body: Node2D) -> void:
	if body == ball and _is_ball_alive:
		_reset_combo_count()
		reset_ball()
		return
	if body is AssistBall:
		var assist_ball: AssistBall = body
		assist_ball.disappear()

func _on_ball_body_entered(body: Node) -> void:
	_try_apply_flipper_impulse(ball, body)

func _on_assist_ball_body_entered(body: Node, assist_ball: AssistBall) -> void:
	if not is_instance_valid(assist_ball) or assist_ball.is_queued_for_deletion():
		return
	_try_apply_flipper_impulse(assist_ball, body)

func _try_apply_flipper_impulse(hit_ball: RigidBody2D, body: Node) -> void:
	for state: Dictionary in _flippers:
		var flipper: StaticBody2D = state["node"]
		if body == flipper and _is_flipper_striking(state):
			_apply_flipper_impulse(hit_ball, flipper, state["config"])
			break

func _is_flipper_striking(state: Dictionary) -> bool:
	var config: Dictionary = state["config"]
	var side: float = float(config.get("side", 1.0))
	var angular_speed: float = float(state.get("angular_speed", 0.0))
	if side < 0.0:
		return angular_speed <= -FLIPPER_ACTIVE_ANGULAR_SPEED_THRESHOLD
	return angular_speed >= FLIPPER_ACTIVE_ANGULAR_SPEED_THRESHOLD

func _apply_flipper_impulse(hit_ball: RigidBody2D, flipper: StaticBody2D, config: Dictionary) -> void:
	if _is_victory or _is_game_over:
		return
	var side: float = float(config.get("side", 1.0))
	var pivot_to_ball: Vector2 = (hit_ball.global_position - flipper.global_position).normalized()
	var impulse_direction: Vector2 = Vector2(0.4 * side, -1.0).normalized()
	if pivot_to_ball != Vector2.ZERO:
		impulse_direction = (impulse_direction + pivot_to_ball * 0.35).normalized()
	var hit_impulse: float = float(config.get("hit_impulse", 1600.0))
	var impulse: Vector2 = impulse_direction * hit_impulse
	hit_ball.apply_central_impulse(impulse)
	if hit_ball == ball:
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
	if body == ball:
		bumper.on_ball_entered(ball)
		return
	if body is AssistBall:
		var assist_ball: AssistBall = body
		if not assist_ball.is_queued_for_deletion():
			bumper.on_ball_entered(assist_ball)

func _on_bumper_hit(bumper: Bumper, bumper_type: String, _damage: int, hit_ball: RigidBody2D) -> void:
	if _is_victory or _is_game_over:
		return
	audio_manager.play_se("bumper_hit")
	_register_bumper_hit_for_fever(bumper)
	_apply_bumper_effect(bumper, hit_ball)
	if hit_ball is AssistBall:
		var assist_ball: AssistBall = hit_ball
		if assist_ball.grants_combo_on_bumper_hit():
			combo_count += _get_fever_combo_gain(1)
	if bumper_type == "summon_ball":
		for _summon_index: int in _get_fever_summon_ball_count(BumperLevelTable.get_summon_ball_count(bumper.level)):
			_spawn_assist_ball(bumper, bumper.summon_assist_ball_type)
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

func _spawn_assist_ball(bumper: Bumper, assist_ball_type: String = AssistBall.DEFAULT_TYPE) -> void:
	if not is_instance_valid(bumper):
		return
	if _get_active_assist_ball_count() >= ASSIST_BALL_MAX_COUNT:
		return
	var assist_ball: AssistBall = AssistBall.new()
	assist_ball.configure_type(assist_ball_type)
	assist_ball.name = "AssistBall_%s" % assist_ball.assist_ball_type
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
	assist_ball.damaged.connect(_on_assist_ball_damaged)
	assist_ball.exploded.connect(_on_assist_ball_exploded)
	assist_ball.body_entered.connect(_on_assist_ball_body_entered.bind(assist_ball))
	assist_balls_root.add_child(assist_ball)
	audio_manager.play_se("assist_ball_spawn")
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
	visual.color = assist_ball.visual_color
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
	if assist_ball.is_bomb():
		assist_ball.explode()
		return
	if assist_ball.attack_damage > 0:
		enemy.take_damage(assist_ball.attack_damage)
	assist_ball.take_damage(1)


func _try_hit_assist_ball_with_bullet(bullet: Area2D) -> bool:
	for child: Node in assist_balls_root.get_children():
		if not (child is AssistBall):
			continue
		var assist_ball: AssistBall = child
		if assist_ball.is_queued_for_deletion():
			continue
		var bullet_radius: float = float(bullet.get_meta("radius", BULLET_COLLISION_RADIUS))
		if bullet.global_position.distance_to(assist_ball.global_position) <= (ASSIST_BALL_COLLISION_RADIUS + bullet_radius):
			if assist_ball.blocks_enemy_bullet():
				assist_ball.disappear()
			else:
				assist_ball.take_damage(1)
			return true
	return false


func _on_assist_ball_damaged(assist_ball: AssistBall, damage: int) -> void:
	if not is_instance_valid(assist_ball):
		return
	var damage_position: Vector2 = assist_ball.global_position
	_spawn_damage_popup_at(
		damage_position,
		damage,
		ASSIST_BALL_DAMAGE_POPUP_COLOR,
		ASSIST_BALL_DAMAGE_POPUP_FONT_SIZE,
		ASSIST_BALL_DAMAGE_POPUP_OFFSET,
		ASSIST_BALL_DAMAGE_POPUP_DURATION,
		ASSIST_BALL_DAMAGE_POPUP_RISE
	)
	_spawn_hit_effect(
		damage_position,
		ASSIST_BALL_DAMAGE_EFFECT_COLOR,
		ASSIST_BALL_DAMAGE_EFFECT_DURATION,
		ASSIST_BALL_DAMAGE_EFFECT_START_RADIUS,
		ASSIST_BALL_DAMAGE_EFFECT_END_RADIUS
	)


func _on_assist_ball_exploded(_assist_ball: AssistBall, explosion_position: Vector2) -> void:
	_apply_bomb_explosion(explosion_position, _assist_ball)


func _on_assist_ball_expired(_assist_ball: AssistBall) -> void:
	call_deferred("_update_assist_balls_label")



func _apply_bomb_explosion(explosion_position: Vector2, source_assist_ball: AssistBall) -> void:
	audio_manager.play_se("bomb_explosion")
	_spawn_bomb_explosion_effect(explosion_position)
	for enemy: Enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.current_hp <= 0:
			continue
		if enemy.global_position.distance_to(explosion_position) <= BOMB_EXPLOSION_RADIUS:
			enemy.take_damage(BOMB_EXPLOSION_DAMAGE)

	if _is_ball_alive and is_instance_valid(ball):
		_apply_bomb_knockback_to_ball(ball, explosion_position, BOMB_MAIN_BALL_KNOCKBACK)
		_cap_ball_speed(BALL_MAX_SPEED)

	for child: Node in assist_balls_root.get_children():
		if not (child is AssistBall):
			continue
		var assist_ball: AssistBall = child
		if assist_ball == source_assist_ball:
			continue
		if assist_ball.is_queued_for_deletion():
			continue
		_apply_bomb_knockback_to_ball(assist_ball, explosion_position, BOMB_ASSIST_BALL_KNOCKBACK)
		_cap_assist_ball_speed(assist_ball)


func _apply_bomb_knockback_to_ball(target_ball: RigidBody2D, explosion_position: Vector2, impulse_strength: float) -> void:
	if target_ball == null or not is_instance_valid(target_ball):
		return
	if target_ball.global_position.distance_to(explosion_position) > BOMB_EXPLOSION_RADIUS:
		return
	var knockback_direction: Vector2 = target_ball.global_position - explosion_position
	if knockback_direction == Vector2.ZERO:
		knockback_direction = target_ball.linear_velocity
	if knockback_direction == Vector2.ZERO:
		knockback_direction = Vector2.UP
	target_ball.apply_central_impulse(knockback_direction.normalized() * impulse_strength)


func _cap_assist_ball_speed(assist_ball: AssistBall) -> void:
	if assist_ball == null or not is_instance_valid(assist_ball):
		return
	var speed: float = assist_ball.linear_velocity.length()
	if speed > assist_ball.max_speed and speed > 0.0:
		assist_ball.linear_velocity = assist_ball.linear_velocity.normalized() * assist_ball.max_speed


func _spawn_bomb_explosion_effect(world_position: Vector2) -> void:
	var effect: Polygon2D = Polygon2D.new()
	var effect_points: PackedVector2Array = PackedVector2Array()
	for index: int in range(BOMB_EXPLOSION_EFFECT_SEGMENTS):
		var angle: float = TAU * float(index) / float(BOMB_EXPLOSION_EFFECT_SEGMENTS)
		effect_points.append(Vector2(cos(angle), sin(angle)))
	effect.polygon = effect_points
	effect.color = BOMB_EXPLOSION_EFFECT_COLOR
	effect.top_level = true
	effect.global_position = world_position
	effect.scale = Vector2.ONE * BOMB_EXPLOSION_EFFECT_START_RADIUS
	add_child(effect)
	_hit_effects.append({
		"node": effect,
		"elapsed": 0.0,
		"duration": BOMB_EXPLOSION_EFFECT_DURATION,
		"start_radius": BOMB_EXPLOSION_EFFECT_START_RADIUS,
		"end_radius": BOMB_EXPLOSION_RADIUS,
		"color": BOMB_EXPLOSION_EFFECT_COLOR,
	})

func _clear_assist_balls() -> void:
	for child: Node in assist_balls_root.get_children():
		child.queue_free()
	call_deferred("_update_assist_balls_label")

func _on_enemy_hit(enemy: Enemy, damage: int) -> void:
	audio_manager.play_se("enemy_hit")
	_update_enemy_hp_label()
	_spawn_damage_popup(enemy, damage)
	_play_enemy_hit_flash(enemy)
	if enemy.is_boss():
		_spawn_hit_effect(enemy.global_position, HIT_EFFECT_COLOR, HIT_EFFECT_DURATION * BOSS_HIT_EFFECT_MULTIPLIER, HIT_EFFECT_START_RADIUS, HIT_EFFECT_END_RADIUS * BOSS_HIT_EFFECT_MULTIPLIER)
	else:
		_spawn_hit_effect(enemy.global_position)
	_update_boss_hp_bar()

func _on_enemy_defeated(enemy: Enemy) -> void:
	audio_manager.play_se("enemy_defeated")
	_update_enemy_hp_label()
	_update_boss_hp_bar()
	if _are_all_enemies_defeated():
		_start_stage_clear_sequence(enemy)
	elif is_instance_valid(enemy):
		enemy.play_defeat_animation()

func _are_all_enemies_defeated() -> bool:
	for enemy: Enemy in enemies:
		if is_instance_valid(enemy) and enemy.current_hp > 0:
			return false
	return true

func _start_stage_clear_sequence(defeated_enemy: Enemy) -> void:
	if _is_victory or _is_stage_clearing or _is_game_over:
		return
	_is_stage_clearing = true
	_is_victory = true
	_stage_clear_sequence_id += 1
	var sequence_id: int = _stage_clear_sequence_id
	var defeated_position: Vector2 = game_camera.global_position
	if is_instance_valid(defeated_enemy):
		defeated_position = defeated_enemy.global_position
		defeated_enemy.play_defeat_animation()

	Engine.time_scale = CLEAR_SLOW_TIME_SCALE
	ball.sleeping = true
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	_clear_assist_balls()
	for child: Node in bullets_root.get_children():
		child.queue_free()
	_spawn_hit_effect(defeated_position, CLEAR_EFFECT_COLOR, CLEAR_SLOW_DURATION, HIT_EFFECT_START_RADIUS, CLEAR_EFFECT_END_RADIUS)

	var camera_tween: Tween = create_tween().set_parallel(true).set_ignore_time_scale(true)
	camera_tween.tween_property(game_camera, "global_position", defeated_position, CLEAR_CAMERA_FOCUS_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	camera_tween.tween_property(game_camera, "zoom", CLEAR_CAMERA_ZOOM, CLEAR_CAMERA_FOCUS_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(CLEAR_SLOW_DURATION, true, false, true).timeout
	if sequence_id != _stage_clear_sequence_id or not _is_stage_clearing:
		return
	victory_label.visible = true
	audio_manager.play_se("victory")
	await get_tree().create_timer(CLEAR_REWARD_DELAY, true, false, true).timeout
	if sequence_id != _stage_clear_sequence_id or not _is_stage_clearing:
		return
	_restore_stage_clear_state()
	_enter_victory_state()

func _spawn_damage_popup(enemy: Enemy, damage: int) -> void:
	if not is_instance_valid(enemy):
		return
	_spawn_damage_popup_at(enemy.global_position, damage, DAMAGE_POPUP_COLOR, DAMAGE_POPUP_FONT_SIZE)

func _spawn_player_damage_popup(damage: int) -> void:
	_spawn_damage_popup_at(ball.global_position, damage, PLAYER_DAMAGE_POPUP_COLOR, PLAYER_DAMAGE_POPUP_FONT_SIZE)

func _spawn_damage_popup_at(
	world_position: Vector2,
	damage: int,
	popup_color: Color,
	font_size: int,
	popup_offset: Vector2 = DAMAGE_POPUP_OFFSET,
	duration: float = DAMAGE_POPUP_DURATION,
	rise: float = DAMAGE_POPUP_RISE
) -> void:
	var popup_label: Label = Label.new()
	popup_label.text = "-%d" % damage
	popup_label.modulate = popup_color
	popup_label.add_theme_font_size_override("font_size", font_size)
	popup_label.top_level = true
	popup_label.z_index = 20
	popup_label.global_position = world_position + popup_offset
	add_child(popup_label)
	_damage_popups.append({
		"label": popup_label,
		"elapsed": 0.0,
		"start_position": popup_label.global_position,
		"duration": duration,
		"rise": rise,
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

func _spawn_hit_effect(
	world_position: Vector2,
	effect_color: Color = HIT_EFFECT_COLOR,
	duration: float = HIT_EFFECT_DURATION,
	start_radius: float = HIT_EFFECT_START_RADIUS,
	end_radius: float = HIT_EFFECT_END_RADIUS
) -> void:
	var effect: Polygon2D = Polygon2D.new()
	effect.polygon = PackedVector2Array([
		Vector2(-1.0, -1.0),
		Vector2(1.0, -1.0),
		Vector2(1.0, 1.0),
		Vector2(-1.0, 1.0),
	])
	effect.color = effect_color
	effect.top_level = true
	effect.global_position = world_position
	effect.scale = Vector2.ONE * start_radius
	add_child(effect)
	_hit_effects.append({
		"node": effect,
		"elapsed": 0.0,
		"duration": duration,
		"start_radius": start_radius,
		"end_radius": end_radius,
		"color": effect_color,
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
		var duration: float = float(popup.get("duration", DAMAGE_POPUP_DURATION))
		var rise: float = float(popup.get("rise", DAMAGE_POPUP_RISE))
		var progress: float = min(elapsed / duration, 1.0)
		var start_position: Vector2 = popup["start_position"]
		popup_label.global_position = start_position + Vector2(0.0, -rise * progress)
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
		var duration: float = float(effect_data.get("duration", HIT_EFFECT_DURATION))
		var start_radius: float = float(effect_data.get("start_radius", HIT_EFFECT_START_RADIUS))
		var end_radius: float = float(effect_data.get("end_radius", HIT_EFFECT_END_RADIUS))
		var effect_color: Color = effect_data.get("color", HIT_EFFECT_COLOR)
		var progress: float = min(elapsed / duration, 1.0)
		var radius: float = lerpf(start_radius, end_radius, progress)
		effect.scale = Vector2.ONE * radius
		effect.color.a = effect_color.a * (1.0 - progress)
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
	_is_waiting_for_reward_bumper_target_selection = false
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
	audio_manager.play_se("reward_select")
	var reward_id: String = _current_reward_options[button_index]
	var requires_pin_selection: bool = _apply_reward(reward_id)
	reward_status_label.text = _reward_manager.get_reward_result_text(reward_id, Bumper.MAX_LEVEL)
	for button: Button in reward_option_buttons:
		button.disabled = true
	if requires_pin_selection:
		reward_header_label.text = "空きPinまたは同種バンパーをクリックしてください"
		return
	reward_header_label.text = _get_next_stage_message()
	_start_next_battle_placeholder()

func _apply_reward(reward_id: String) -> bool:
	var bumper_type: String = _reward_manager.get_bumper_type(reward_id)
	if bumper_type.is_empty():
		return false
	_pending_reward_bumper_config = _create_reward_bumper_config(bumper_type)
	_is_waiting_for_reward_bumper_target_selection = true
	return true

func _create_reward_bumper_config(bumper_type: String) -> Dictionary:
	var config: Dictionary = {
		"level": 1,
		"damage": 1,
		"impulse_strength": 130.0,
		"bumper_type": bumper_type,
		"sprite_path": "res://gazou/banper_0.png",
		"sprite_scale": BUMPER_SPRITE_SCALE,
	}
	match bumper_type:
		"power":
			config["sprite_path"] = "res://gazou/banper_1.png"
		"heal":
			config["sprite_path"] = "res://gazou/banper_2.png"
		"summon_ball":
			config["assist_ball_type"] = AssistBall.DEFAULT_TYPE
			config["cooldown_time"] = 1.2
			config["sprite_path"] = "res://gazou/banper_3.png"
	return config

func _start_next_battle_placeholder() -> void:
	await get_tree().create_timer(0.8).timeout
	reward_panel.visible = false
	_advance_to_next_stage()
	_reset_battle()

func _advance_to_next_stage() -> void:
	if _stage_loop_ids.is_empty():
		return
	_current_stage_index = (_current_stage_index + 1) % _stage_loop_ids.size()
	_current_stage_id = _stage_loop_ids[_current_stage_index]
	_apply_stage_enemy_config(_current_stage_id)

func _apply_stage_enemy_config(stage_id: String) -> void:
	enemy_configs = _to_dictionary_array(StageConfig.get_stage_enemy_configs(stage_id))
	for child: Node in enemies_root.get_children():
		child.queue_free()
	enemies.clear()
	_update_status_label()

func _get_next_stage_message() -> String:
	if _stage_loop_ids.is_empty():
		return "次ステージへ進みます"
	var next_stage_index: int = (_current_stage_index + 1) % _stage_loop_ids.size()
	var next_stage_id: String = _stage_loop_ids[next_stage_index]
	return "%sへ進みます" % StageConfig.get_stage_display_name(next_stage_id)

func _get_ball_max_hp() -> int:
	return BALL_HP_INITIAL

func _create_boss_hp_bar() -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.name = "BossHpBar"
	bar.position = BOSS_HP_BAR_POSITION
	bar.size = BOSS_HP_BAR_SIZE
	bar.show_percentage = false
	bar.visible = false
	$UI.add_child(bar)
	return bar

func _create_boss_message_label() -> Label:
	var label: Label = Label.new()
	label.name = "BossMessageLabel"
	label.position = Vector2(0.0, 74.0)
	label.size = Vector2(VIEW_WIDTH, 44.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 34)
	label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.22, 1.0))
	label.visible = false
	$UI.add_child(label)
	return label

func _setup_boss_ui() -> void:
	boss_hp_bar.visible = false
	boss_message_label.visible = false

func _update_enemy_hp_label() -> void:
	var hp_parts: PackedStringArray = PackedStringArray()
	for enemy: Enemy in enemies:
		if is_instance_valid(enemy) and enemy.current_hp > 0 and not enemy.is_boss():
			hp_parts.append("%s HP: %d/%d" % [enemy.get_display_name(), enemy.current_hp, enemy.max_hp])
	if hp_parts.is_empty():
		enemy_hp_label.text = "Enemy HP: 0"
	else:
		enemy_hp_label.text = " | ".join(hp_parts)
	_update_boss_hp_bar()

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
		"Stage: %s" % StageConfig.get_stage_display_name(_current_stage_id),
		"Status: %s" % _get_battle_status_text(),
		"Combo: %d" % combo_count,
		"Next Bonus Damage: +%d" % _next_enemy_hit_bonus_damage,
		"Assist Balls: %d / %d" % [_get_active_assist_ball_count(), ASSIST_BALL_MAX_COUNT],
	]
	status_lines.append("Fever Hits: %d / %d" % [_bumper_hit_count, FEVER_TRIGGER_BUMPER_HITS])
	if _is_fever_active:
		status_lines.append("FEVER: %.1fs" % _fever_remaining)
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

func _register_bumper_hit_for_fever(bumper: Bumper) -> void:
	if _is_fever_active:
		_spawn_hit_effect(bumper.global_position, FEVER_EFFECT_COLOR, HIT_EFFECT_DURATION * FEVER_HIT_EFFECT_MULTIPLIER, HIT_EFFECT_START_RADIUS, HIT_EFFECT_END_RADIUS * FEVER_HIT_EFFECT_MULTIPLIER)
		return
	_bumper_hit_count += 1
	if _bumper_hit_count >= FEVER_TRIGGER_BUMPER_HITS:
		_start_fever()
	_update_fever_ui()

func _start_fever() -> void:
	if _is_fever_active:
		return
	_is_fever_active = true
	_fever_remaining = FEVER_DURATION
	background_root.modulate = FEVER_BACKGROUND_MODULATE
	audio_manager.play_se("fever_start")
	_apply_fever_to_bumpers()
	_update_fever_ui()

func _update_fever(delta: float) -> void:
	if not _is_fever_active:
		return
	_fever_remaining = max(_fever_remaining - delta, 0.0)
	if _fever_remaining <= 0.0:
		_end_fever()
	else:
		_update_fever_ui()

func _end_fever() -> void:
	if not _is_fever_active:
		return
	_is_fever_active = false
	_fever_remaining = 0.0
	_bumper_hit_count = 0
	background_root.modulate = _background_base_modulate
	audio_manager.play_se("fever_end")
	_apply_fever_to_bumpers()
	_update_fever_ui()

func _apply_fever_to_bumpers() -> void:
	var cooldown_multiplier: float = 1.0
	var hit_feedback_multiplier: float = 1.0
	if _is_fever_active:
		cooldown_multiplier = FEVER_BUMPER_COOLDOWN_MULTIPLIER
		hit_feedback_multiplier = FEVER_HIT_EFFECT_MULTIPLIER
	for bumper: Bumper in bumpers:
		if is_instance_valid(bumper):
			bumper.cooldown_multiplier = cooldown_multiplier
			bumper.hit_feedback_multiplier = hit_feedback_multiplier

func _update_fever_ui() -> void:
	if not is_node_ready():
		return
	fever_label.visible = _is_fever_active
	fever_time_label.visible = _is_fever_active
	if _is_fever_active:
		fever_label.text = "FEVER"
		fever_time_label.text = "%.1fs" % _fever_remaining
	_update_status_label()

func _get_fever_combo_gain(base_gain: int) -> int:
	if _is_fever_active:
		return base_gain * FEVER_COMBO_GAIN_MULTIPLIER
	return base_gain

func _get_fever_summon_ball_count(base_count: int) -> int:
	if _is_fever_active:
		return base_count + FEVER_SUMMON_BALL_BONUS_COUNT
	return base_count

func _reset_fever_state() -> void:
	_is_fever_active = false
	_fever_remaining = 0.0
	_bumper_hit_count = 0
	background_root.modulate = _background_base_modulate
	_apply_fever_to_bumpers()
	_update_fever_ui()

func _reset_combo_count() -> void:
	combo_count = 0
	_update_combo_label()

func _apply_bumper_effect(bumper: Bumper, hit_ball: RigidBody2D) -> void:
	match bumper.bumper_type:
		"normal":
			combo_count += _get_fever_combo_gain(BumperLevelTable.get_normal_combo_gain(bumper.level))
		"power":
			combo_count += _get_fever_combo_gain(BumperLevelTable.get_power_combo_gain(bumper.level))
			var power_amount: int = BumperLevelTable.get_power_bonus_damage(bumper.level)
			if hit_ball is AssistBall:
				var power_assist_ball: AssistBall = hit_ball
				power_assist_ball.boost_attack(power_amount)
				_spawn_hit_effect(power_assist_ball.global_position)
			else:
				_next_enemy_hit_bonus_damage += power_amount
		"heal":
			var heal_amount: int = BumperLevelTable.get_heal_amount(bumper.level)
			if hit_ball is AssistBall:
				var heal_assist_ball: AssistBall = hit_ball
				heal_assist_ball.heal(heal_amount)
			else:
				if _ball_hp < _get_ball_max_hp():
					_ball_hp += heal_amount
					_ball_hp = mini(_ball_hp, _get_ball_max_hp())
					ball_hp_bar.value = _ball_hp
		"slow":
			_apply_slow_bumper_velocity(hit_ball, BumperLevelTable.get_slow_rate(bumper.level))
		"aim":
			combo_count += _get_fever_combo_gain(1)
			_apply_aim_bumper_effect(bumper, hit_ball)
		"summon_ball":
			combo_count += _get_fever_combo_gain(1)
		_:
			combo_count += _get_fever_combo_gain(1)

func _apply_aim_bumper_effect(bumper: Bumper, target_ball: RigidBody2D) -> void:
	if _is_victory or _is_game_over:
		return
	if target_ball == null or not is_instance_valid(target_ball):
		return
	var nearest_enemy: Enemy = _find_nearest_alive_enemy(target_ball.global_position)
	if nearest_enemy == null:
		return
	var aim_direction: Vector2 = nearest_enemy.global_position - target_ball.global_position
	if aim_direction.length_squared() <= 0.0001:
		return
	var current_speed: float = target_ball.linear_velocity.length()
	var aimed_speed: float = current_speed + BumperLevelTable.get_aim_bumper_speed_bonus(bumper.level)
	target_ball.linear_velocity = aim_direction.normalized() * aimed_speed
	_cap_target_ball_speed(target_ball)

func _find_nearest_alive_enemy(from_position: Vector2) -> Enemy:
	var nearest_enemy: Enemy = null
	var nearest_distance_squared: float = INF
	for child: Node in enemies_root.get_children():
		var enemy: Enemy = child as Enemy
		if enemy == null or not is_instance_valid(enemy) or enemy.current_hp <= 0:
			continue
		var distance_squared: float = from_position.distance_squared_to(enemy.global_position)
		if distance_squared < nearest_distance_squared:
			nearest_distance_squared = distance_squared
			nearest_enemy = enemy
	return nearest_enemy

func _cap_target_ball_speed(target_ball: RigidBody2D) -> void:
	var max_speed: float = BALL_MAX_SPEED
	if target_ball is AssistBall:
		var assist_ball: AssistBall = target_ball
		max_speed = assist_ball.max_speed
	var speed: float = target_ball.linear_velocity.length()
	if speed > max_speed and speed > 0.0:
		target_ball.linear_velocity = target_ball.linear_velocity.normalized() * max_speed

func _apply_slow_bumper_velocity(target_ball: RigidBody2D, level_slow_rate: float) -> void:
	if target_ball == null or not is_instance_valid(target_ball):
		return
	var slow_rate: float = max(0.2, level_slow_rate - ((_slow_effect_multiplier - 1.0) * 0.15))
	var new_velocity: Vector2 = target_ball.linear_velocity * slow_rate
	var speed: float = new_velocity.length()
	if speed < BALL_MIN_SPEED:
		if speed <= 0.001:
			new_velocity = Vector2.UP * BALL_MIN_SPEED
		else:
			new_velocity = new_velocity.normalized() * BALL_MIN_SPEED
	target_ball.linear_velocity = new_velocity

func _damage_ball(damage: int) -> void:
	if _is_victory or _is_game_over or not _is_ball_alive:
		return
	_ball_hp -= damage
	ball_hp_bar.value = max(_ball_hp, 0)
	_play_player_damage_feedback(damage)
	if _ball_hp <= 0:
		_destroy_ball()

func _play_player_damage_feedback(damage: int) -> void:
	audio_manager.play_se("player_damage")
	_spawn_player_damage_popup(damage)
	_play_player_damage_flash()
	_play_ball_hp_bar_damage_pulse()
	_play_player_damage_camera_shake()

func _play_player_damage_flash() -> void:
	if _player_damage_flash_tween != null and _player_damage_flash_tween.is_valid():
		_player_damage_flash_tween.kill()
	var visuals: Array[CanvasItem] = _get_main_ball_visuals()
	if visuals.is_empty():
		return
	_player_damage_flash_tween = create_tween().set_parallel(true)
	for visual: CanvasItem in visuals:
		if not _ball_visual_base_modulates.has(visual):
			_ball_visual_base_modulates[visual] = visual.modulate
		visual.modulate = PLAYER_DAMAGE_FLASH_COLOR
		_player_damage_flash_tween.tween_property(visual, "modulate", _ball_visual_base_modulates[visual], PLAYER_DAMAGE_FLASH_STEP_DURATION)
	_player_damage_flash_tween.chain()
	for visual: CanvasItem in visuals:
		_player_damage_flash_tween.tween_property(visual, "modulate", PLAYER_DAMAGE_FLASH_COLOR, PLAYER_DAMAGE_FLASH_STEP_DURATION)
	_player_damage_flash_tween.chain()
	for visual: CanvasItem in visuals:
		_player_damage_flash_tween.tween_property(visual, "modulate", _ball_visual_base_modulates[visual], PLAYER_DAMAGE_FLASH_STEP_DURATION)

func _get_main_ball_visuals() -> Array[CanvasItem]:
	var visuals: Array[CanvasItem] = []
	for node_name: String in ["BallSprite", "BallVisual", "MainBallRing", "MainBallMarker"]:
		var visual: CanvasItem = ball.get_node_or_null(node_name) as CanvasItem
		if visual != null and visual.visible:
			visuals.append(visual)
	return visuals

func _play_ball_hp_bar_damage_pulse() -> void:
	if _player_damage_hp_bar_tween != null and _player_damage_hp_bar_tween.is_valid():
		_player_damage_hp_bar_tween.kill()
	ball_hp_bar.self_modulate = PLAYER_DAMAGE_HP_BAR_COLOR
	ball_hp_bar.scale = PLAYER_DAMAGE_HP_BAR_PULSE_SCALE
	_player_damage_hp_bar_tween = create_tween().set_parallel(true)
	_player_damage_hp_bar_tween.tween_property(ball_hp_bar, "self_modulate", Color.WHITE, PLAYER_DAMAGE_HP_BAR_PULSE_DURATION * 2.0)
	_player_damage_hp_bar_tween.tween_property(ball_hp_bar, "scale", Vector2.ONE, PLAYER_DAMAGE_HP_BAR_PULSE_DURATION * 2.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _play_player_damage_camera_shake() -> void:
	if _player_damage_shake_tween != null and _player_damage_shake_tween.is_valid():
		_player_damage_shake_tween.kill()
	game_camera.offset = Vector2(PLAYER_DAMAGE_SHAKE_STRENGTH, -PLAYER_DAMAGE_SHAKE_STRENGTH * 0.5)
	_player_damage_shake_tween = create_tween()
	_player_damage_shake_tween.tween_property(game_camera, "offset", Vector2(-PLAYER_DAMAGE_SHAKE_STRENGTH, PLAYER_DAMAGE_SHAKE_STRENGTH * 0.5), PLAYER_DAMAGE_SHAKE_STEP_DURATION)
	_player_damage_shake_tween.tween_property(game_camera, "offset", Vector2(PLAYER_DAMAGE_SHAKE_STRENGTH * 0.5, PLAYER_DAMAGE_SHAKE_STRENGTH * 0.25), PLAYER_DAMAGE_SHAKE_STEP_DURATION)
	_player_damage_shake_tween.tween_property(game_camera, "offset", Vector2.ZERO, PLAYER_DAMAGE_SHAKE_STEP_DURATION)

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
	_restore_stage_clear_state()
	_is_game_over = true
	audio_manager.play_se("game_over")
	_clear_assist_balls()
	game_over_label.visible = true

func _reset_battle() -> void:
	_restore_stage_clear_state()
	_is_victory = false
	_is_game_over = false
	_is_ball_alive = true
	_spawn_bumpers()
	_reset_fever_state()
	_reset_enemies_for_battle()
	_hovered_bumper = null
	bumper_tooltip_panel.visible = false
	_ball_hp = _get_ball_max_hp()
	_bullet_fire_elapsed = 0.0
	_next_enemy_hit_bonus_damage = 0
	_reset_combo_count()
	_update_bonus_damage_label()
	_update_enemy_hp_label()
	_update_boss_hp_bar()
	_show_boss_message_if_needed()
	_update_assist_balls_label()
	ball_hp_bar.max_value = _ball_hp
	ball_hp_bar.value = _ball_hp
	victory_label.visible = false
	game_over_label.visible = false
	reward_panel.visible = false
	_is_waiting_for_reward_bumper_target_selection = false
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
	_reset_player_damage_feedback()
	reset_ball()

func _reset_enemies_for_battle() -> void:
	var valid_enemy_count: int = 0
	for enemy: Enemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			valid_enemy_count += 1
	if valid_enemy_count != enemy_configs.size():
		for child: Node in enemies_root.get_children():
			child.queue_free()
		_spawn_enemies()
		return
	for enemy: Enemy in enemies:
		if is_instance_valid(enemy):
			enemy.reset_for_battle()

func _restore_stage_clear_state() -> void:
	_stage_clear_sequence_id += 1
	_is_stage_clearing = false
	Engine.time_scale = 1.0
	if is_instance_valid(game_camera):
		game_camera.zoom = _camera_default_zoom
		game_camera.offset = Vector2.ZERO
		if is_instance_valid(ball):
			game_camera.global_position = ball.global_position

func _reset_player_damage_feedback() -> void:
	for tween: Tween in [_player_damage_flash_tween, _player_damage_hp_bar_tween, _player_damage_shake_tween]:
		if tween != null and tween.is_valid():
			tween.kill()
	for visual: CanvasItem in _get_main_ball_visuals():
		if _ball_visual_base_modulates.has(visual):
			visual.modulate = _ball_visual_base_modulates[visual]
	ball_hp_bar.self_modulate = Color.WHITE
	ball_hp_bar.scale = Vector2.ONE
	game_camera.offset = Vector2.ZERO

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
		var bullet_radius: float = float(bullet.get_meta("radius", BULLET_COLLISION_RADIUS))
		if _is_ball_alive and bullet.global_position.distance_to(ball.global_position) <= (_ball_collision_radius + bullet_radius):
			_damage_ball(int(bullet.get_meta("damage", BULLET_DAMAGE)))
			bullet.queue_free()
			continue
		if _try_hit_assist_ball_with_bullet(bullet):
			bullet.queue_free()
			continue
		if bullet.global_position.y > FIELD_HEIGHT or bullet.global_position.x < -20.0 or bullet.global_position.x > FIELD_WIDTH + 20.0:
			bullet.queue_free()

func _find_alive_boss() -> Enemy:
	for enemy: Enemy in enemies:
		if is_instance_valid(enemy) and enemy.current_hp > 0 and enemy.is_boss():
			return enemy
	return null

func _update_boss_hp_bar() -> void:
	if not is_node_ready():
		return
	var boss: Enemy = _find_alive_boss()
	if boss == null:
		boss_hp_bar.visible = false
		return
	boss_hp_bar.visible = true
	boss_hp_bar.min_value = 0
	boss_hp_bar.max_value = boss.max_hp
	boss_hp_bar.value = boss.current_hp

func _show_boss_message_if_needed() -> void:
	if _find_alive_boss() != null:
		_show_boss_message("BOSS BATTLE")

func _show_boss_message(message: String) -> void:
	if _boss_message_tween != null and _boss_message_tween.is_valid():
		_boss_message_tween.kill()
	boss_message_label.text = message
	boss_message_label.visible = true
	boss_message_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_boss_message_tween = create_tween()
	_boss_message_tween.tween_interval(BOSS_MESSAGE_DURATION)
	_boss_message_tween.tween_property(boss_message_label, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.25)
	_boss_message_tween.tween_callback(func() -> void: boss_message_label.visible = false)

func _on_boss_phase_two_started(enemy: Enemy) -> void:
	if not is_instance_valid(enemy) or not enemy.is_boss():
		return
	audio_manager.play_se("boss_phase_two")
	enemy.play_phase_two_animation()
	_show_boss_message("PHASE 2")
	_update_boss_hp_bar()
