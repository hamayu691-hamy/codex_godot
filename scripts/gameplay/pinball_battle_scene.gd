extends Node2D

const FIELD_WIDTH: float = 1200.0
const FIELD_HEIGHT: float = 700.0
const VIEW_WIDTH: float = 800.0
const VIEW_HEIGHT: float = 700.0
const FIELD_CENTER_X: float = FIELD_WIDTH * 0.5
const BALL_START_POSITION: Vector2 = Vector2(FIELD_CENTER_X, 120.0)
const BALL_MAX_SPEED: float = 1150.0
const BALL_FLIPPER_POST_HIT_MAX_SPEED: float = BALL_MAX_SPEED
const SLOPE_WALL_MIN_THICKNESS: float = 25.0
const BALL_MIN_SPEED: float = 170.0
const BALL_LAUNCH_IMPULSE: Vector2 = Vector2(120.0, -750.0)
const DAMAGE_POPUP_DURATION: float = 0.55
const DAMAGE_POPUP_RISE: float = 24.0
const REWARD_OPTION_IDS: Array[String] = [
	"normal_to_power",
	"random_bumper_damage",
	"add_heal_bumper",
	"enhance_slow",
]
# Minimum angular speed (rad/s) to treat the flipper as actively striking. Tune for feel.
const FLIPPER_ACTIVE_ANGULAR_SPEED_THRESHOLD: float = 3.0
const ENEMY_HP_INITIAL: int = 20
const DEBUG_ENABLE_ENEMY_ZERO_HP_COMMAND: bool = true
const DEBUG_ENEMY_ZERO_HP_KEY: Key = KEY_K
const BALL_HP_INITIAL: int = 20
const BUMPER_GROUP: StringName = &"bumpers"
const BUMPER_COLLISION_RADIUS: float = 18.0
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
}
const BULLET_SPEED: float = 420.0
const BULLET_DAMAGE: int = 2
const BULLET_COLLISION_RADIUS: float = 7.0
const BUMPER_TOOLTIP_OFFSET: Vector2 = Vector2(16.0, 16.0)
const BALL_HP_BAR_SIZE: Vector2 = Vector2(44.0, 7.0)
const BALL_HP_BAR_OFFSET: Vector2 = Vector2(-22.0, -26.0)
const ENEMY_COLLISION_RADIUS: float = 20.0
const ENEMY_VISUAL_COLOR: Color = Color(0.9, 0.3, 0.35, 1.0)
const DEFAULT_SPRITE_SCALE: Vector2 = Vector2.ONE
const LARGE_TEXTURE_BASE_SIZE: float = 1254.0
const BALL_SPRITE_TARGET_DIAMETER: float = 24.0
const BUMPER_SPRITE_TARGET_DIAMETER: float = 36.0
const ENEMY_SPRITE_TARGET_DIAMETER: float = 40.0
const BALL_SPRITE_SCALE: Vector2 = Vector2.ONE * (BALL_SPRITE_TARGET_DIAMETER / LARGE_TEXTURE_BASE_SIZE)
const BUMPER_SPRITE_SCALE: Vector2 = Vector2.ONE * (BUMPER_SPRITE_TARGET_DIAMETER / LARGE_TEXTURE_BASE_SIZE)
const ENEMY_SPRITE_SCALE: Vector2 = Vector2.ONE * (ENEMY_SPRITE_TARGET_DIAMETER / LARGE_TEXTURE_BASE_SIZE)
const BUMPER_VISUAL_POINTS: Array[Vector2] = [
	Vector2(0.0, -18.0),
	Vector2(9.0, -15.5885),
	Vector2(15.5885, -9.0),
	Vector2(18.0, 0.0),
	Vector2(15.5885, 9.0),
	Vector2(9.0, 15.5885),
	Vector2(0.0, 18.0),
	Vector2(-9.0, 15.5885),
	Vector2(-15.5885, 9.0),
	Vector2(-18.0, 0.0),
	Vector2(-15.5885, -9.0),
	Vector2(-9.0, -15.5885),
]

@onready var ball: RigidBody2D = $Ball
@onready var flippers_root: Node2D = $Flippers
@onready var drain: Area2D = $Drain
@onready var bumpers_root: Node = $Bumpers
@onready var enemies_root: Node2D = $Enemies
@onready var walls_root: Node2D = $Walls
@onready var bullets_root: Node2D = $Bullets
@onready var game_camera: Camera2D = $GameCamera
@onready var ball_hp_bar: ProgressBar = $Ball/BallHpBar
@onready var enemy_hp_label: Label = $UI/EnemyHpLabel
@onready var combo_label: Label = $UI/ComboLabel
@onready var bonus_damage_label: Label = $UI/BonusDamageLabel
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

var bumper_configs: Array[Dictionary] = [
	{
		"position": Vector2(280.0, 280.0),
		"level": 1,
		"damage": 1,
		"impulse_strength": 130.0,
		"bumper_type": "normal",
		"sprite_path": "res://gazou/banper_0.png",
		"sprite_scale": BUMPER_SPRITE_SCALE,
	},
	{
		"position": Vector2(600.0, 240.0),
		"level": 1,
		"damage": 1,
		"impulse_strength": 130.0,
		"bumper_type": "power",
		"sprite_path": "res://gazou/banper_0.png",
		"sprite_scale": BUMPER_SPRITE_SCALE,
	},
	{
		"position": Vector2(920.0, 285.0),
		"level": 1,
		"damage": 1,
		"impulse_strength": 130.0,
		"bumper_type": "slow",
		"sprite_path": "res://gazou/banper_0.png",
		"sprite_scale": BUMPER_SPRITE_SCALE,
	},
]

var wall_configs: Array[Dictionary] = [
	{
		"name": "LeftWall",
		"position": Vector2(20.0, FIELD_HEIGHT * 0.5),
		"size": Vector2(20.0, FIELD_HEIGHT),
		"rotation": -0.08,
		"color": Color(0.4, 0.45, 0.55, 1.0),
		"bounce": 0.75,
		"friction": 0.05,
		"sprite_path": "",
		"sprite_scale": Vector2.ONE,
	},
	{
		"name": "RightWall",
		"position": Vector2(FIELD_WIDTH - 20.0, FIELD_HEIGHT * 0.5),
		"size": Vector2(20.0, FIELD_HEIGHT),
		"rotation": 0.08,
		"color": Color(0.4, 0.45, 0.55, 1.0),
		"bounce": 0.75,
		"friction": 0.05,
		"sprite_path": "",
		"sprite_scale": Vector2.ONE,
	},
	{
		"name": "TopWall",
		"position": Vector2(FIELD_CENTER_X, 20.0),
		"size": Vector2(FIELD_WIDTH, 20.0),
		"rotation": 0.0,
		"color": Color(0.4, 0.45, 0.55, 1.0),
		"bounce": 0.75,
		"friction": 0.05,
		"sprite_path": "",
		"sprite_scale": Vector2.ONE,
	},
	{
		"name": "LeftFlipperGuideWall",
		"position": Vector2(FIELD_CENTER_X - 270.0, 625.0),
		"size": Vector2(520.0, 18.0),
		"rotation": 0.42,
		"is_slope": true,
		"min_thickness": SLOPE_WALL_MIN_THICKNESS,
		"color": Color(0.4, 0.45, 0.55, 1.0),
		"bounce": 0.75,
		"friction": 0.05,
		"sprite_path": "",
		"sprite_scale": Vector2.ONE,
	},
	{
		"name": "RightFlipperGuideWall",
		"position": Vector2(FIELD_CENTER_X + 270.0, 625.0),
		"size": Vector2(520.0, 18.0),
		"rotation": -0.42,
		"is_slope": true,
		"min_thickness": SLOPE_WALL_MIN_THICKNESS,
		"color": Color(0.4, 0.45, 0.55, 1.0),
		"bounce": 0.75,
		"friction": 0.05,
		"sprite_path": "",
		"sprite_scale": Vector2.ONE,
	},
]

var flipper_configs: Array[Dictionary] = [
	{
		"name": "LeftFlipper",
		"position": Vector2(FIELD_CENTER_X - 50.0, 640.0),
		"collision_offset": Vector2(45.0, 0.0),
		"visual_offset": Vector2(45.0, 0.0),
		"size": Vector2(110.0, 16.0),
		"rest_rotation": -0.35,
		"active_rotation": -1.0,
		"rotate_speed": 14.0,
		"input_key": KEY_LEFT,
		"side": -1.0,
		"hit_impulse": 1600.0,
		"color": Color(0.95, 0.5, 0.35, 1.0),
	},
	{
		"name": "RightFlipper",
		"position": Vector2(FIELD_CENTER_X + 50.0, 640.0),
		"collision_offset": Vector2(-45.0, 0.0),
		"visual_offset": Vector2(-45.0, 0.0),
		"size": Vector2(110.0, 16.0),
		"rest_rotation": 0.35,
		"active_rotation": 1.0,
		"rotate_speed": 14.0,
		"input_key": KEY_RIGHT,
		"side": 1.0,
		"hit_impulse": 1600.0,
		"color": Color(0.95, 0.5, 0.35, 1.0),
	},
]

var enemy_configs: Array[Dictionary] = [
	{
		"position": Vector2(FIELD_CENTER_X, 170.0),
		"max_hp": 20,
		"current_hp": 20,
		"contact_damage": 1,
		"move_speed": 35.0,
		"enemy_type": "basic",
		"score_value": 100,
		"move_axis": "horizontal",
		"move_range": 260.0,
		"attack_type": "bullet",
		"attack_interval": 1.1,
		"sprite_path": "res://gazou/enemy_0.png",
		"sprite_scale": ENEMY_SPRITE_SCALE,
	},
]

var ball_config: Dictionary = {
	"sprite_path": "res://gazou/ball_0.png",
	"sprite_scale": BALL_SPRITE_SCALE,
}

var _flippers: Array[Dictionary] = []
var _ball_hp: int = BALL_HP_INITIAL
var _is_victory: bool = false
var _is_game_over: bool = false
var _debug_enemy_zero_hp_key_was_down: bool = false
var _is_ball_alive: bool = true
var _damage_popups: Array[Dictionary] = []
var _reward_selected_this_victory: bool = false
var _current_reward_options: Array[String] = []
var _reward_levels: Dictionary = {}
var _slow_effect_multiplier: float = 1.0
var combo_count: int = 0
var _next_enemy_hit_bonus_damage: int = 0
var _bullet_fire_elapsed: float = 0.0
var _hovered_bumper: Bumper = null
var _ball_collision_radius: float = BALL_SPRITE_TARGET_DIAMETER * 0.5

func _ready() -> void:
	_setup_ball_visual()
	_spawn_flippers()
	_setup_camera()
	ball.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	drain.body_entered.connect(_on_drain_body_entered)
	ball.body_entered.connect(_on_ball_body_entered)
	_spawn_walls()
	_spawn_bumpers()
	_spawn_enemies()
	for bumper_node: Node in bumpers_root.get_children():
		if bumper_node is Bumper:
			var bumper: Bumper = bumper_node
			bumpers.append(bumper)
			bumper.add_to_group(BUMPER_GROUP)
			bumper.body_entered.connect(_on_bumper_body_entered.bind(bumper))
			bumper.hit.connect(_on_bumper_hit)
			bumper.mouse_entered.connect(_on_bumper_mouse_entered.bind(bumper))
			bumper.mouse_exited.connect(_on_bumper_mouse_exited.bind(bumper))
	_setup_bumper_tooltip()
	_setup_ball_hp_bar()
	_setup_reward_panel()
	_update_enemy_hp_label()
	_update_combo_label()
	_update_bonus_damage_label()
	victory_label.visible = false
	game_over_label.visible = false
	_reset_battle()

func _setup_ball_visual() -> void:
	var ball_visual: Node = ball.get_node_or_null("BallVisual")
	if ball_visual == null:
		return
	_try_attach_sprite(ball, ball_config, ball_visual, "BallSprite")
	_sync_ball_size_with_visual()

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

func _spawn_bumpers() -> void:
	for child: Node in bumpers_root.get_children():
		child.queue_free()
	bumpers.clear()
	for index: int in range(bumper_configs.size()):
		var config: Dictionary = bumper_configs[index]
		var bumper: Bumper = Bumper.new()
		bumper.name = "Bumper%d" % (index + 1)
		bumper.position = config.get("position", Vector2.ZERO)
		bumper.base_damage = int(config.get("damage", 1))
		bumper.base_impulse_strength = float(config.get("impulse_strength", 130.0))
		bumper.bumper_type = str(config.get("bumper_type", "normal"))
		bumper.level = int(config.get("level", 1))

		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		var circle_shape: CircleShape2D = CircleShape2D.new()
		circle_shape.radius = BUMPER_COLLISION_RADIUS
		collision_shape.shape = circle_shape
		bumper.add_child(collision_shape)

		var bumper_visual: Polygon2D = Polygon2D.new()
		bumper_visual.name = "BumperVisual"
		bumper_visual.color = _get_bumper_visual_color(bumper.bumper_type)
		bumper_visual.polygon = PackedVector2Array(BUMPER_VISUAL_POINTS)
		bumper.add_child(bumper_visual)
		_try_attach_sprite(bumper, config, bumper_visual, "BumperSprite")
		_sync_bumper_size_with_visual(bumper)

		var level_label: Label = Label.new()
		level_label.name = "LevelLabel"
		level_label.position = Vector2(10.0, 10.0)
		level_label.add_theme_font_size_override("font_size", 12)
		level_label.modulate = Color(1.0, 1.0, 1.0, 0.95)
		level_label.text = "Lv.1"
		bumper.add_child(level_label)

		bumpers_root.add_child(bumper)

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


func _get_wall_size(config: Dictionary) -> Vector2:
	var size: Vector2 = config.get("size", Vector2(20.0, 20.0))
	if bool(config.get("is_slope", false)):
		var min_thickness: float = float(config.get("min_thickness", SLOPE_WALL_MIN_THICKNESS))
		if size.y < min_thickness:
			size.y = min_thickness
	return size

func _spawn_walls() -> void:
	for child: Node in walls_root.get_children():
		child.queue_free()
	for config: Dictionary in wall_configs:
		var wall: StaticBody2D = StaticBody2D.new()
		wall.name = str(config.get("name", "Wall"))
		wall.position = config.get("position", Vector2.ZERO)
		wall.rotation = float(config.get("rotation", 0.0))

		var physics_material: PhysicsMaterial = PhysicsMaterial.new()
		physics_material.bounce = float(config.get("bounce", 0.0))
		physics_material.friction = float(config.get("friction", 1.0))
		wall.physics_material_override = physics_material

		var size: Vector2 = _get_wall_size(config)
		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		collision_shape.name = "CollisionShape2D"
		var rectangle_shape: RectangleShape2D = RectangleShape2D.new()
		rectangle_shape.size = size
		collision_shape.shape = rectangle_shape
		wall.add_child(collision_shape)

		var wall_visual: Polygon2D = Polygon2D.new()
		wall_visual.name = "WallVisual"
		wall_visual.color = config.get("color", Color(0.4, 0.45, 0.55, 1.0))
		wall_visual.polygon = PackedVector2Array([
			Vector2(-size.x / 2.0, -size.y / 2.0),
			Vector2(size.x / 2.0, -size.y / 2.0),
			Vector2(size.x / 2.0, size.y / 2.0),
			Vector2(-size.x / 2.0, size.y / 2.0),
		])
		wall.add_child(wall_visual)
		_try_attach_sprite(wall, config, wall_visual, "WallSprite")

		walls_root.add_child(wall)

func _spawn_enemies() -> void:
	for child: Node in enemies_root.get_children():
		child.queue_free()
	enemies.clear()
	for index: int in range(enemy_configs.size()):
		var config: Dictionary = enemy_configs[index]
		var enemy: Enemy = Enemy.new()
		enemy.name = "Enemy%d" % (index + 1)
		enemy.position = config.get("position", Vector2(200.0, 140.0))
		enemy.max_hp = int(config.get("max_hp", ENEMY_HP_INITIAL))
		enemy.current_hp = int(config.get("current_hp", enemy.max_hp))
		enemy.contact_damage = int(config.get("contact_damage", 1))
		enemy.move_speed = float(config.get("move_speed", 35.0))
		enemy.enemy_type = str(config.get("enemy_type", "basic"))
		enemy.score_value = int(config.get("score_value", 100))
		enemy.move_axis = str(config.get("move_axis", "horizontal"))
		enemy.move_range = float(config.get("move_range", 80.0))
		enemy.attack_type = str(config.get("attack_type", "bullet"))
		enemy.attack_interval = float(config.get("attack_interval", 1.1))

		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		var circle_shape: CircleShape2D = CircleShape2D.new()
		circle_shape.radius = ENEMY_COLLISION_RADIUS
		collision_shape.shape = circle_shape
		enemy.add_child(collision_shape)

		var enemy_visual: Polygon2D = Polygon2D.new()
		enemy_visual.name = "EnemyVisual"
		enemy_visual.color = ENEMY_VISUAL_COLOR
		enemy_visual.polygon = PackedVector2Array(BUMPER_VISUAL_POINTS)
		enemy.add_child(enemy_visual)
		_try_attach_sprite(enemy, config, enemy_visual, "EnemySprite")

		enemy.body_entered.connect(_on_enemy_body_entered.bind(enemy))
		enemy.hit.connect(_on_enemy_hit)
		enemy.defeated.connect(_on_enemy_defeated)

		enemies_root.add_child(enemy)
		enemies.append(enemy)

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
	for child: Node in flippers_root.get_children():
		child.queue_free()
	_flippers.clear()
	for config: Dictionary in flipper_configs:
		var flipper: StaticBody2D = StaticBody2D.new()
		flipper.name = str(config.get("name", "Flipper"))
		flipper.position = config.get("position", Vector2.ZERO)
		flipper.rotation = float(config.get("rest_rotation", 0.0))

		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		collision_shape.position = config.get("collision_offset", Vector2.ZERO)
		var rectangle_shape: RectangleShape2D = RectangleShape2D.new()
		rectangle_shape.size = config.get("size", Vector2(110.0, 16.0))
		collision_shape.shape = rectangle_shape
		flipper.add_child(collision_shape)

		var visual: Polygon2D = Polygon2D.new()
		visual.name = "FlipperVisual"
		visual.position = config.get("visual_offset", Vector2.ZERO)
		visual.color = config.get("color", Color(0.95, 0.5, 0.35, 1.0))
		var size: Vector2 = config.get("size", Vector2(110.0, 16.0))
		visual.polygon = PackedVector2Array([
			Vector2(-size.x / 2.0, -size.y / 2.0),
			Vector2(size.x / 2.0, -size.y / 2.0),
			Vector2(size.x / 2.0, size.y / 2.0),
			Vector2(-size.x / 2.0, size.y / 2.0),
		])
		flipper.add_child(visual)

		flippers_root.add_child(flipper)
		_flippers.append({
			"config": config,
			"node": flipper,
			"previous_rotation": flipper.rotation,
			"angular_speed": 0.0,
		})

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

func _on_bumper_hit(_bumper: Bumper, bumper_type: String, damage: int) -> void:
	if _is_victory or _is_game_over:
		return
	_apply_bumper_effect(bumper_type)
	_update_combo_label()
	_update_bonus_damage_label()
	_spawn_damage_popup(damage)

func _on_enemy_body_entered(body: Node2D, enemy: Enemy) -> void:
	if _is_victory or _is_game_over:
		return
	if body != ball:
		return
	var combo_damage_bonus: int = int(floor(float(combo_count) / 3.0))
	var total_damage: int = 1 + combo_damage_bonus + _next_enemy_hit_bonus_damage
	enemy.take_damage(total_damage)
	_next_enemy_hit_bonus_damage = 0
	_update_bonus_damage_label()
	_reset_combo_count()

func _on_enemy_hit(enemy: Enemy, damage: int) -> void:
	_update_enemy_hp_label()
	_spawn_damage_popup(damage)

func _on_enemy_defeated(_enemy: Enemy) -> void:
	_update_enemy_hp_label()
	_enter_victory_state()

func _spawn_damage_popup(damage: int) -> void:
	var popup_label: Label = Label.new()
	popup_label.text = "-%d" % damage
	popup_label.modulate = Color(1.0, 0.85, 0.45, 1.0)
	popup_label.add_theme_font_size_override("font_size", 20)
	popup_label.top_level = true
	popup_label.global_position = enemy_hp_label.global_position + Vector2(145.0, 6.0)
	add_child(popup_label)
	_damage_popups.append({
		"label": popup_label,
		"elapsed": 0.0,
		"start_position": popup_label.global_position,
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

func _enter_victory_state() -> void:
	_is_victory = true
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
	reward_panel.visible = true
	reward_status_label.text = ""
	_current_reward_options = REWARD_OPTION_IDS.duplicate()
	_current_reward_options.shuffle()
	_current_reward_options = _current_reward_options.slice(0, reward_option_buttons.size())
	for index: int in range(reward_option_buttons.size()):
		var button: Button = reward_option_buttons[index]
		button.disabled = false
		button.text = _get_reward_label(_current_reward_options[index])

func _on_reward_button_pressed(button_index: int) -> void:
	if _reward_selected_this_victory:
		return
	if button_index < 0 or button_index >= _current_reward_options.size():
		return
	_reward_selected_this_victory = true
	var reward_id: String = _current_reward_options[button_index]
	_apply_reward(reward_id)
	_increment_reward_level(reward_id)
	reward_status_label.text = _get_reward_result_text(reward_id)
	for button: Button in reward_option_buttons:
		button.disabled = true
	reward_header_label.text = "次ステージ（仮）へ進みます"
	_start_next_battle_placeholder()

func _get_reward_label(reward_id: String) -> String:
	var current_level: int = _get_reward_level(reward_id)
	match reward_id:
		"normal_to_power":
			return "normalをpowerに変化 (Lv.%d)" % current_level
		"random_bumper_damage":
			return "ランダムなバンパー Lv+1 (最大Lv.%d) (Lv.%d)" % [Bumper.MAX_LEVEL, current_level]
		"add_heal_bumper":
			return "healバンパーを1つ追加 (Lv.%d)" % current_level
		"enhance_slow":
			return "slowバンパー効果を強化 (Lv.%d)" % current_level
		_:
			return "不明な報酬"

func _get_reward_level(reward_id: String) -> int:
	return int(_reward_levels.get(reward_id, 0)) + 1

func _increment_reward_level(reward_id: String) -> void:
	_reward_levels[reward_id] = int(_reward_levels.get(reward_id, 0)) + 1

func _get_reward_result_text(reward_id: String) -> String:
	match reward_id:
		"normal_to_power":
			return "normalバンパーをpowerに変化しました"
		"random_bumper_damage":
			return "ランダムなバンパーのLvが1上がりました（最大Lv.%d）" % Bumper.MAX_LEVEL
		"add_heal_bumper":
			return "healバンパーを追加しました"
		"enhance_slow":
			return "slowバンパー効果を強化しました"
		_:
			return "報酬を獲得しました"

func _apply_reward(reward_id: String) -> void:
	match reward_id:
		"normal_to_power":
			for config: Dictionary in bumper_configs:
				if str(config.get("bumper_type", "normal")) == "normal":
					config["bumper_type"] = "power"
					return
		"random_bumper_damage":
			if bumper_configs.is_empty():
				return
			var random_index: int = randi() % bumper_configs.size()
			var selected_config: Dictionary = bumper_configs[random_index]
			var current_level: int = int(selected_config.get("level", 1))
			selected_config["level"] = mini(current_level + 1, Bumper.MAX_LEVEL)
			bumper_configs[random_index] = selected_config
		"add_heal_bumper":
			var heal_bumper_config: Dictionary = {
				"position": Vector2(FIELD_CENTER_X, 320.0),
				"level": 1,
				"damage": 1,
				"impulse_strength": 130.0,
				"bumper_type": "heal",
			}
			bumper_configs.append(heal_bumper_config)
		"enhance_slow":
			_slow_effect_multiplier += 0.25

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

func _update_bonus_damage_label() -> void:
	bonus_damage_label.text = "Next Bonus DMG: +%d" % _next_enemy_hit_bonus_damage

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
	game_over_label.visible = true

func _reset_battle() -> void:
	_is_victory = false
	_is_game_over = false
	_is_ball_alive = true
	_spawn_bumpers()
	bumpers.clear()
	for bumper_node: Node in bumpers_root.get_children():
		if bumper_node is Bumper:
			var bumper: Bumper = bumper_node
			bumpers.append(bumper)
			bumper.add_to_group(BUMPER_GROUP)
			bumper.body_entered.connect(_on_bumper_body_entered.bind(bumper))
			bumper.hit.connect(_on_bumper_hit)
			bumper.mouse_entered.connect(_on_bumper_mouse_entered.bind(bumper))
			bumper.mouse_exited.connect(_on_bumper_mouse_exited.bind(bumper))
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
	ball_hp_bar.max_value = _ball_hp
	ball_hp_bar.value = _ball_hp
	victory_label.visible = false
	game_over_label.visible = false
	reward_panel.visible = false
	ball.visible = true
	ball.freeze = false
	for child: Node in bullets_root.get_children():
		child.queue_free()
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
		if bullet.global_position.y > FIELD_HEIGHT or bullet.global_position.x < -20.0 or bullet.global_position.x > FIELD_WIDTH + 20.0:
			bullet.queue_free()
