extends Node2D

const BALL_START_POSITION: Vector2 = Vector2(200.0, 120.0)
const BALL_MAX_SPEED: float = 1350.0
const BALL_LAUNCH_IMPULSE: Vector2 = Vector2(120.0, -750.0)
const DAMAGE_POPUP_DURATION: float = 0.55
const DAMAGE_POPUP_RISE: float = 24.0
# Minimum angular speed (rad/s) to treat the flipper as actively striking. Tune for feel.
const FLIPPER_ACTIVE_ANGULAR_SPEED_THRESHOLD: float = 3.0
const ENEMY_HP_INITIAL: int = 20
const BALL_HP_INITIAL: int = 20
const REWARD_FLIPPER_POWER_MULTIPLIER_STEP: float = 0.1
const BUMPER_GROUP: StringName = &"bumpers"
const BUMPER_COLLISION_RADIUS: float = 18.0
const BUMPER_VISUAL_COLOR: Color = Color(0.2, 0.9, 0.95, 1.0)
const BULLET_SPEED: float = 420.0
const BULLET_DAMAGE: int = 2
const BULLET_COLLISION_RADIUS: float = 7.0
const BULLET_FIRE_INTERVAL: float = 1.1
const BALL_HP_BAR_SIZE: Vector2 = Vector2(44.0, 7.0)
const BALL_HP_BAR_OFFSET: Vector2 = Vector2(-22.0, -26.0)
const ENEMY_COLLISION_RADIUS: float = 20.0
const ENEMY_VISUAL_COLOR: Color = Color(0.9, 0.3, 0.35, 1.0)
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
@onready var enemy_gun_marker: Marker2D = $EnemyGunMarker
@onready var ball_hp_bar: ProgressBar = $Ball/BallHpBar
@onready var enemy_hp_label: Label = $EnemyHpLabel
@onready var combo_label: Label = $ComboLabel
@onready var victory_label: Label = $VictoryLabel
@onready var game_over_label: Label = $GameOverLabel
@onready var reward_panel: Panel = $RewardPanel
@onready var reward_header_label: Label = $RewardPanel/RewardHeaderLabel
@onready var reward_status_label: Label = $RewardPanel/RewardStatusLabel
@onready var reward_bumper_button: Button = $RewardPanel/RewardButtons/BumperDamageButton
@onready var reward_max_hp_button: Button = $RewardPanel/RewardButtons/MaxHpButton
@onready var reward_flipper_button: Button = $RewardPanel/RewardButtons/FlipperPowerButton
@onready var bumpers: Array[Bumper] = []
@onready var enemies: Array[Enemy] = []

var bumper_configs: Array[Dictionary] = [
	{
		"position": Vector2(130.0, 210.0),
		"damage": 1,
		"impulse_strength": 130.0,
		"bumper_type": "normal",
	},
	{
		"position": Vector2(200.0, 165.0),
		"damage": 1,
		"impulse_strength": 130.0,
		"bumper_type": "normal",
	},
	{
		"position": Vector2(270.0, 210.0),
		"damage": 1,
		"impulse_strength": 130.0,
		"bumper_type": "normal",
	},
]

var wall_configs: Array[Dictionary] = [
	{
		"name": "LeftWall",
		"position": Vector2(20.0, 300.0),
		"size": Vector2(20.0, 700.0),
		"rotation": -0.08,
		"color": Color(0.4, 0.45, 0.55, 1.0),
		"bounce": 0.75,
		"friction": 0.05,
	},
	{
		"name": "RightWall",
		"position": Vector2(380.0, 300.0),
		"size": Vector2(20.0, 700.0),
		"rotation": 0.08,
		"color": Color(0.4, 0.45, 0.55, 1.0),
		"bounce": 0.75,
		"friction": 0.05,
	},
	{
		"name": "TopWall",
		"position": Vector2(200.0, 20.0),
		"size": Vector2(400.0, 20.0),
		"rotation": 0.0,
		"color": Color(0.4, 0.45, 0.55, 1.0),
		"bounce": 0.75,
		"friction": 0.05,
	},
	{
		"name": "LeftFlipperGuideWall",
		"position": Vector2(118.0, 454.0),
		"size": Vector2(240.0, 16.0),
		"rotation": 0.9,
		"color": Color(0.4, 0.45, 0.55, 1.0),
		"bounce": 0.75,
		"friction": 0.05,
	},
	{
		"name": "RightFlipperGuideWall",
		"position": Vector2(282.0, 454.0),
		"size": Vector2(240.0, 16.0),
		"rotation": -0.9,
		"color": Color(0.4, 0.45, 0.55, 1.0),
		"bounce": 0.75,
		"friction": 0.05,
	},
]

var flipper_configs: Array[Dictionary] = [
	{
		"name": "LeftFlipper",
		"position": Vector2(150.0, 570.0),
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
		"position": Vector2(250.0, 570.0),
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
		"position": Vector2(200.0, 140.0),
		"max_hp": 20,
		"current_hp": 20,
		"contact_damage": 1,
		"move_speed": 35.0,
		"enemy_type": "basic",
		"score_value": 100,
		"move_axis": "horizontal",
		"move_range": 80.0,
	},
]

var _flippers: Array[Dictionary] = []
var _ball_hp: int = BALL_HP_INITIAL
var _is_victory: bool = false
var _is_game_over: bool = false
var _is_ball_alive: bool = true
var _damage_popups: Array[Dictionary] = []
var _bullet_fire_elapsed: float = 0.0
var _bumper_damage_bonus: int = 0
var _max_hp_bonus: int = 0
var _flipper_power_multiplier: float = 1.0
var _reward_selected_this_victory: bool = false
var combo_count: int = 0

func _ready() -> void:
	_spawn_flippers()
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
	_setup_ball_hp_bar()
	_setup_reward_panel()
	_update_enemy_hp_label()
	_update_combo_label()
	victory_label.visible = false
	game_over_label.visible = false
	_reset_battle()

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
		bumper.damage = int(config.get("damage", 1))
		bumper.impulse_strength = float(config.get("impulse_strength", 130.0))
		bumper.bumper_type = str(config.get("bumper_type", "normal"))

		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		var circle_shape: CircleShape2D = CircleShape2D.new()
		circle_shape.radius = BUMPER_COLLISION_RADIUS
		collision_shape.shape = circle_shape
		bumper.add_child(collision_shape)

		var bumper_visual: Polygon2D = Polygon2D.new()
		bumper_visual.name = "BumperVisual"
		bumper_visual.color = BUMPER_VISUAL_COLOR
		bumper_visual.polygon = PackedVector2Array(BUMPER_VISUAL_POINTS)
		bumper.add_child(bumper_visual)

		bumpers_root.add_child(bumper)

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

		var size: Vector2 = config.get("size", Vector2(20.0, 20.0))
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

		enemy.body_entered.connect(_on_enemy_body_entered.bind(enemy))
		enemy.hit.connect(_on_enemy_hit)
		enemy.defeated.connect(_on_enemy_defeated)

		enemies_root.add_child(enemy)
		enemies.append(enemy)

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

	if _is_ball_alive:
		var speed: float = ball.linear_velocity.length()
		if speed > BALL_MAX_SPEED and not _is_victory:
			ball.linear_velocity = ball.linear_velocity.normalized() * BALL_MAX_SPEED

	_update_enemy_bullets(delta)
	_update_damage_popups(delta)

func _update_enemy_bullets(delta: float) -> void:
	if _is_victory or _is_game_over:
		return
	_bullet_fire_elapsed += delta
	if _bullet_fire_elapsed >= BULLET_FIRE_INTERVAL:
		_bullet_fire_elapsed = 0.0
		_spawn_enemy_bullet()

func _spawn_enemy_bullet() -> void:
	if not _is_ball_alive:
		return
	var spawn_position: Vector2 = _get_enemy_bullet_spawn_position()
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

func _get_enemy_bullet_spawn_position() -> Vector2:
	for enemy: Enemy in enemies:
		if is_instance_valid(enemy) and enemy.current_hp > 0:
			return enemy.global_position
	return enemy_gun_marker.global_position

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
	var impulse: Vector2 = impulse_direction * hit_impulse * _flipper_power_multiplier
	ball.apply_central_impulse(impulse)

func reset_ball() -> void:
	if not _is_ball_alive:
		return
	ball.sleeping = true
	ball.global_position = BALL_START_POSITION
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	ball.sleeping = false
	ball.apply_central_impulse(BALL_LAUNCH_IMPULSE)

func _on_bumper_body_entered(body: Node2D, bumper: Bumper) -> void:
	if _is_victory or _is_game_over:
		return
	if body != ball:
		return
	bumper.on_ball_entered(ball)

func _on_bumper_hit(_bumper: Bumper, damage: int) -> void:
	if _is_victory or _is_game_over:
		return
	combo_count += 1
	_update_combo_label()
	_spawn_damage_popup(damage + _bumper_damage_bonus)

func _on_enemy_body_entered(body: Node2D, enemy: Enemy) -> void:
	if _is_victory or _is_game_over:
		return
	if body != ball:
		return
	var combo_damage_bonus: int = int(floor(float(combo_count) / 3.0))
	var total_damage: int = 1 + combo_damage_bonus
	enemy.take_damage(total_damage)
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
	reward_bumper_button.pressed.connect(_on_reward_selected.bind("bumper_damage"))
	reward_max_hp_button.pressed.connect(_on_reward_selected.bind("max_hp"))
	reward_flipper_button.pressed.connect(_on_reward_selected.bind("flipper_power"))
	reward_header_label.text = "報酬を1つ選んでください"
	reward_status_label.text = ""

func _show_reward_panel() -> void:
	_reward_selected_this_victory = false
	reward_panel.visible = true
	reward_status_label.text = ""
	reward_bumper_button.disabled = false
	reward_max_hp_button.disabled = false
	reward_flipper_button.disabled = false

func _on_reward_selected(reward_id: String) -> void:
	if _reward_selected_this_victory:
		return
	_reward_selected_this_victory = true
	match reward_id:
		"bumper_damage":
			_bumper_damage_bonus += 1
			reward_status_label.text = "バンパーダメージ +1 を獲得"
		"max_hp":
			_max_hp_bonus += 5
			reward_status_label.text = "最大HP +5 を獲得"
		"flipper_power":
			_flipper_power_multiplier += REWARD_FLIPPER_POWER_MULTIPLIER_STEP
			reward_status_label.text = "フリッパー打ち返し力 +10% を獲得"
	reward_bumper_button.disabled = true
	reward_max_hp_button.disabled = true
	reward_flipper_button.disabled = true
	reward_header_label.text = "次ステージ（仮）へ進みます"
	_start_next_battle_placeholder()

func _start_next_battle_placeholder() -> void:
	await get_tree().create_timer(0.8).timeout
	reward_panel.visible = false
	_reset_battle()

func _get_ball_max_hp() -> int:
	return BALL_HP_INITIAL + _max_hp_bonus

func _update_enemy_hp_label() -> void:
	var current_hp: int = 0
	if enemies.size() > 0 and is_instance_valid(enemies[0]):
		current_hp = enemies[0].current_hp
	if current_hp < 0:
		current_hp = 0
	enemy_hp_label.text = "Enemy HP: %d" % current_hp

func _update_combo_label() -> void:
	combo_label.text = "Combo: %d" % combo_count

func _reset_combo_count() -> void:
	combo_count = 0
	_update_combo_label()

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
	for enemy: Enemy in enemies:
		if is_instance_valid(enemy):
			enemy.current_hp = enemy.max_hp
	_ball_hp = _get_ball_max_hp()
	_bullet_fire_elapsed = 0.0
	_reset_combo_count()
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
	for index: int in range(bullets_root.get_child_count() - 1, -1, -1):
		var bullet_node: Node = bullets_root.get_child(index)
		if not (bullet_node is Area2D):
			continue
		var bullet: Area2D = bullet_node
		var velocity: Vector2 = bullet.get_meta("velocity", Vector2.ZERO)
		bullet.global_position += velocity * delta
		if _is_ball_alive and bullet.global_position.distance_to(ball.global_position) <= (12.0 + BULLET_COLLISION_RADIUS):
			_damage_ball(int(bullet.get_meta("damage", BULLET_DAMAGE)))
			bullet.queue_free()
			continue
		if bullet.global_position.y > 700.0 or bullet.global_position.x < -20.0 or bullet.global_position.x > 420.0:
			bullet.queue_free()
