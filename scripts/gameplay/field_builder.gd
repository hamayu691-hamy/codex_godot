extends RefCounted
class_name FieldBuilder

const StageConfig = preload("res://scripts/gameplay/stage_config.gd")
const Pin = preload("res://scripts/gameplay/pin.gd")
const Bumper = preload("res://scripts/gameplay/bumper.gd")
const Enemy = preload("res://scripts/gameplay/enemy.gd")

const DEFAULT_SPRITE_SCALE: Vector2 = Vector2.ONE

var _pin_collision_radius: float
var _bumper_collision_radius: float
var _enemy_collision_radius: float
var _bumper_visual_color: Color
var _bumper_visual_color_by_type: Dictionary
var _bumper_visual_points: Array[Vector2]
var _enemy_visual_color: Color
var _enemy_hp_initial: int

func _init(
	pin_collision_radius: float,
	bumper_collision_radius: float,
	enemy_collision_radius: float,
	bumper_visual_color: Color,
	bumper_visual_color_by_type: Dictionary,
	bumper_visual_points: Array[Vector2],
	enemy_visual_color: Color,
	enemy_hp_initial: int
) -> void:
	_pin_collision_radius = pin_collision_radius
	_bumper_collision_radius = bumper_collision_radius
	_enemy_collision_radius = enemy_collision_radius
	_bumper_visual_color = bumper_visual_color
	_bumper_visual_color_by_type = bumper_visual_color_by_type
	_bumper_visual_points = bumper_visual_points
	_enemy_visual_color = enemy_visual_color
	_enemy_hp_initial = enemy_hp_initial

func spawn_walls(walls_root: Node2D, wall_configs: Array[Dictionary]) -> void:
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

func spawn_pins(pins_root: Node2D, pin_configs: Array[Dictionary]) -> void:
	for child: Node in pins_root.get_children():
		child.queue_free()
	for index: int in range(pin_configs.size()):
		var config: Dictionary = pin_configs[index]
		var pin: Pin = Pin.new()
		pin.name = "Pin%d" % (index + 1)
		pin.position = config.get("position", Vector2.ZERO)
		pin.pin_id = str(config.get("pin_id", ""))
		pin.slot_id = str(config.get("slot_id", ""))
		pin.replaceable = bool(config.get("replaceable", true))
		pin.occupied = bool(config.get("occupied", false))
		pin.impulse_strength = float(config.get("impulse_strength", 80.0))
		pin.sprite_path = str(config.get("sprite_path", ""))
		pin.sprite_scale = config.get("sprite_scale", Vector2.ONE)
		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		var circle_shape: CircleShape2D = CircleShape2D.new()
		circle_shape.radius = _pin_collision_radius
		collision_shape.shape = circle_shape
		pin.add_child(collision_shape)
		var pin_visual: Polygon2D = Polygon2D.new()
		pin_visual.name = "PinVisual"
		pin_visual.color = Pin.DEFAULT_VISUAL_COLOR
		pin_visual.polygon = PackedVector2Array(Pin.DEFAULT_VISUAL_POINTS)
		pin.add_child(pin_visual)
		_try_attach_sprite(pin, config, pin_visual, "PinSprite")
		_sync_pin_size_with_visual(pin)
		pins_root.add_child(pin)

func spawn_bumpers(bumpers_root: Node, bumper_configs: Array[Dictionary]) -> Array[Bumper]:
	for child: Node in bumpers_root.get_children():
		child.queue_free()
	var spawned_bumpers: Array[Bumper] = []
	for index: int in range(bumper_configs.size()):
		var config: Dictionary = bumper_configs[index]
		var bumper: Bumper = _create_bumper_from_config(config, "Bumper%d" % (index + 1))
		bumpers_root.add_child(bumper)
		spawned_bumpers.append(bumper)
	return spawned_bumpers

func spawn_flippers(flippers_root: Node2D, flipper_configs: Array[Dictionary]) -> Array[Dictionary]:
	for child: Node in flippers_root.get_children():
		child.queue_free()
	var flippers: Array[Dictionary] = []
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
		flippers.append({"config": config, "node": flipper, "previous_rotation": flipper.rotation, "angular_speed": 0.0})
	return flippers

func spawn_enemies(enemies_root: Node2D, enemy_configs: Array[Dictionary]) -> Array[Enemy]:
	for child: Node in enemies_root.get_children():
		child.queue_free()
	var spawned_enemies: Array[Enemy] = []
	for index: int in range(enemy_configs.size()):
		var config: Dictionary = enemy_configs[index]
		var enemy: Enemy = Enemy.new()
		enemy.name = "Enemy%d" % (index + 1)
		enemy.position = config.get("position", Vector2(200.0, 140.0))
		enemy.max_hp = int(config.get("max_hp", _enemy_hp_initial))
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
		circle_shape.radius = _enemy_collision_radius
		collision_shape.shape = circle_shape
		enemy.add_child(collision_shape)
		var enemy_visual: Polygon2D = Polygon2D.new()
		enemy_visual.name = "EnemyVisual"
		enemy_visual.color = _enemy_visual_color
		enemy_visual.polygon = PackedVector2Array(_bumper_visual_points)
		enemy.add_child(enemy_visual)
		_try_attach_sprite(enemy, config, enemy_visual, "EnemySprite")
		_sync_enemy_size_with_visual(enemy)
		enemies_root.add_child(enemy)
		spawned_enemies.append(enemy)
	return spawned_enemies

func _get_wall_size(config: Dictionary) -> Vector2:
	var size: Vector2 = config.get("size", Vector2(20.0, 20.0))
	if bool(config.get("is_slope", false)):
		var min_thickness: float = float(config.get("min_thickness", StageConfig.SLOPE_WALL_MIN_THICKNESS))
		if size.y < min_thickness:
			size.y = min_thickness
	return size

func _create_bumper_from_config(config: Dictionary, bumper_name: String) -> Bumper:
	var bumper: Bumper = Bumper.new()
	bumper.name = bumper_name
	bumper.position = config.get("position", Vector2.ZERO)
	bumper.base_damage = int(config.get("damage", 1))
	bumper.base_impulse_strength = float(config.get("impulse_strength", 130.0))
	bumper.bumper_type = str(config.get("bumper_type", "normal"))
	bumper.level = int(config.get("level", 1))
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	var circle_shape: CircleShape2D = CircleShape2D.new()
	circle_shape.radius = _bumper_collision_radius
	collision_shape.shape = circle_shape
	bumper.add_child(collision_shape)
	var bumper_visual: Polygon2D = Polygon2D.new()
	bumper_visual.name = "BumperVisual"
	bumper_visual.color = _bumper_visual_color_by_type.get(bumper.bumper_type, _bumper_visual_color)
	bumper_visual.polygon = PackedVector2Array(_bumper_visual_points)
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
	return bumper

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

func _sync_pin_size_with_visual(pin: Pin) -> void:
	var collision_radius: float = _pin_collision_radius
	var pin_sprite: Sprite2D = pin.get_node_or_null("PinSprite") as Sprite2D
	if pin_sprite != null and pin_sprite.texture != null:
		var texture_size: Vector2 = pin_sprite.texture.get_size()
		var applied_scale: Vector2 = pin_sprite.scale
		var scaled_size: Vector2 = Vector2(texture_size.x * absf(applied_scale.x), texture_size.y * absf(applied_scale.y))
		var diameter: float = max(scaled_size.x, scaled_size.y)
		collision_radius = max(diameter * 0.5, 1.0)
	_update_circle_collision_shape(pin.get_node_or_null("CollisionShape2D") as CollisionShape2D, collision_radius)

func _sync_bumper_size_with_visual(bumper: Bumper) -> void:
	var collision_radius: float = _bumper_collision_radius
	var bumper_sprite: Sprite2D = bumper.get_node_or_null("BumperSprite") as Sprite2D
	if bumper_sprite != null and bumper_sprite.texture != null:
		var texture_size: Vector2 = bumper_sprite.texture.get_size()
		var applied_scale: Vector2 = bumper_sprite.scale
		var scaled_size: Vector2 = Vector2(texture_size.x * absf(applied_scale.x), texture_size.y * absf(applied_scale.y))
		var diameter: float = max(scaled_size.x, scaled_size.y)
		collision_radius = max(diameter * 0.5, 1.0)
	_update_circle_collision_shape(bumper.get_node_or_null("CollisionShape2D") as CollisionShape2D, collision_radius)

func _sync_enemy_size_with_visual(enemy: Enemy) -> void:
	var collision_radius: float = _enemy_collision_radius
	var enemy_sprite: Sprite2D = enemy.get_node_or_null("EnemySprite") as Sprite2D
	if enemy_sprite != null and enemy_sprite.texture != null:
		var texture_size: Vector2 = enemy_sprite.texture.get_size()
		var applied_scale: Vector2 = enemy_sprite.scale
		var scaled_size: Vector2 = Vector2(texture_size.x * absf(applied_scale.x), texture_size.y * absf(applied_scale.y))
		var diameter: float = max(scaled_size.x, scaled_size.y)
		collision_radius = max(diameter * 0.5, 1.0)
	_update_circle_collision_shape(enemy.get_node_or_null("CollisionShape2D") as CollisionShape2D, collision_radius)

func _update_circle_collision_shape(collision_shape: CollisionShape2D, collision_radius: float) -> void:
	if collision_shape == null:
		return
	var circle_shape: CircleShape2D = collision_shape.shape as CircleShape2D
	if circle_shape == null:
		circle_shape = CircleShape2D.new()
		collision_shape.shape = circle_shape
	circle_shape.radius = collision_radius
