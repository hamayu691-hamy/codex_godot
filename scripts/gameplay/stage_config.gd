extends RefCounted
class_name StageConfig

const FIELD_WIDTH: float = 1200.0
const FIELD_HEIGHT: float = 700.0
const VIEW_WIDTH: float = 800.0
const VIEW_HEIGHT: float = 700.0
const SLOPE_WALL_MIN_THICKNESS: float = 25.0
const FIELD_CENTER_X: float = FIELD_WIDTH * 0.5

const STAGE_ENEMY_CONFIGS: Dictionary = {
	"stage_01": [
		{"position": Vector2(FIELD_CENTER_X, 170.0), "enemy_type": "basic", "move_range": 260.0, "sprite_path": "res://gazou/enemy_0.png", "sprite_scale": Vector2.ONE * (40.0 / 1254.0)},
	],
	"stage_02": [
		{"position": Vector2(FIELD_CENTER_X - 140.0, 165.0), "enemy_type": "swift", "move_range": 180.0, "sprite_path": "res://gazou/enemy_0.png", "sprite_scale": Vector2.ONE * (34.0 / 1254.0)},
		{"position": Vector2(FIELD_CENTER_X + 140.0, 165.0), "enemy_type": "swift", "move_range": 180.0, "sprite_path": "res://gazou/enemy_0.png", "sprite_scale": Vector2.ONE * (34.0 / 1254.0)},
	],
	"stage_03": [
		{"position": Vector2(FIELD_CENTER_X - 120.0, 165.0), "enemy_type": "tank", "move_range": 120.0, "sprite_path": "res://gazou/enemy_0.png", "sprite_scale": Vector2.ONE * (48.0 / 1254.0)},
		{"position": Vector2(FIELD_CENTER_X + 140.0, 175.0), "enemy_type": "basic", "move_range": 180.0, "sprite_path": "res://gazou/enemy_0.png", "sprite_scale": Vector2.ONE * (40.0 / 1254.0)},
	],
}

const STAGES: Dictionary = {
	"stage_01": {
		"background_sprite_path": "",
		"background_color": Color(0.08, 0.1, 0.15, 1.0),
		"ball_config": {
			"sprite_path": "res://gazou/ball_0.png",
			"sprite_scale": Vector2.ONE * (24.0 / 1254.0),
		},
		"bumper_configs": [
			{
				"position": Vector2(280.0, 280.0),
				"level": 1,
				"damage": 1,
				"impulse_strength": 130.0,
				"bumper_type": "normal",
				"sprite_path": "res://gazou/banper_0.png",
				"sprite_scale": Vector2.ONE * (72.0 / 1254.0),
			},
			{
				"position": Vector2(600.0, 240.0),
				"level": 1,
				"damage": 1,
				"impulse_strength": 130.0,
				"bumper_type": "power",
				"sprite_path": "res://gazou/banper_0.png",
				"sprite_scale": Vector2.ONE * (72.0 / 1254.0),
			},
			{
				"position": Vector2(920.0, 285.0),
				"level": 1,
				"damage": 1,
				"impulse_strength": 130.0,
				"bumper_type": "slow",
				"sprite_path": "res://gazou/banper_0.png",
				"sprite_scale": Vector2.ONE * (72.0 / 1254.0),
			},
			{
				"position": Vector2(420.0, 400.0),
				"level": 1,
				"damage": 1,
				"impulse_strength": 130.0,
				"bumper_type": "summon_ball",
				"assist_ball_type": "normal",
				"cooldown_time": 1.2,
				"sprite_path": "res://gazou/banper_3.png",
				"sprite_scale": Vector2.ONE * (72.0 / 1254.0),
			},
			{
				"position": Vector2(540.0, 400.0),
				"level": 1,
				"damage": 1,
				"impulse_strength": 130.0,
				"bumper_type": "summon_ball",
				"assist_ball_type": "attack",
				"cooldown_time": 1.2,
				"sprite_path": "res://gazou/banper_0.png",
				"sprite_scale": Vector2.ONE * (72.0 / 1254.0),
			},
			{
				"position": Vector2(660.0, 400.0),
				"level": 1,
				"damage": 1,
				"impulse_strength": 130.0,
				"bumper_type": "summon_ball",
				"assist_ball_type": "shield",
				"cooldown_time": 1.2,
				"sprite_path": "res://gazou/banper_1.png",
				"sprite_scale": Vector2.ONE * (72.0 / 1254.0),
			},
			{
				"position": Vector2(780.0, 400.0),
				"level": 1,
				"damage": 1,
				"impulse_strength": 130.0,
				"bumper_type": "summon_ball",
				"assist_ball_type": "combo",
				"cooldown_time": 1.2,
				"sprite_path": "res://gazou/banper_2.png",
				"sprite_scale": Vector2.ONE * (72.0 / 1254.0),
			},
			{
				"position": Vector2(900.0, 400.0),
				"level": 1,
				"damage": 1,
				"impulse_strength": 130.0,
				"bumper_type": "summon_ball",
				"assist_ball_type": "bomb",
				"cooldown_time": 1.2,
				"sprite_path": "res://gazou/banper_0.png",
				"sprite_scale": Vector2.ONE * (72.0 / 1254.0),
			},
		],
		"pin_configs": [
			{"position": Vector2(360.0, 205.0), "pin_id": "pin_01", "slot_id": "slot_01", "replaceable": true, "occupied": false, "impulse_strength": 85.0, "sprite_path": "", "sprite_scale": Vector2.ONE},
			{"position": Vector2(600.0, 185.0), "pin_id": "pin_02", "slot_id": "slot_02", "replaceable": true, "occupied": false, "impulse_strength": 85.0, "sprite_path": "", "sprite_scale": Vector2.ONE},
			{"position": Vector2(840.0, 205.0), "pin_id": "pin_03", "slot_id": "slot_03", "replaceable": true, "occupied": false, "impulse_strength": 85.0, "sprite_path": "", "sprite_scale": Vector2.ONE},
			{"position": Vector2(480.0, 325.0), "pin_id": "pin_04", "slot_id": "slot_04", "replaceable": true, "occupied": false, "impulse_strength": 90.0, "sprite_path": "", "sprite_scale": Vector2.ONE},
			{"position": Vector2(720.0, 325.0), "pin_id": "pin_05", "slot_id": "slot_05", "replaceable": true, "occupied": false, "impulse_strength": 90.0, "sprite_path": "", "sprite_scale": Vector2.ONE},
		],
		"wall_configs": [
			{"name": "LeftWall", "position": Vector2(20.0, FIELD_HEIGHT * 0.5), "size": Vector2(20.0, FIELD_HEIGHT), "rotation": -0.08, "color": Color(0.4, 0.45, 0.55, 1.0), "bounce": 0.75, "friction": 0.05, "sprite_path": "", "sprite_scale": Vector2.ONE},
			{"name": "RightWall", "position": Vector2(FIELD_WIDTH - 20.0, FIELD_HEIGHT * 0.5), "size": Vector2(20.0, FIELD_HEIGHT), "rotation": 0.08, "color": Color(0.4, 0.45, 0.55, 1.0), "bounce": 0.75, "friction": 0.05, "sprite_path": "", "sprite_scale": Vector2.ONE},
			{"name": "TopWall", "position": Vector2(FIELD_CENTER_X, 20.0), "size": Vector2(FIELD_WIDTH, 20.0), "rotation": 0.0, "color": Color(0.4, 0.45, 0.55, 1.0), "bounce": 0.75, "friction": 0.05, "sprite_path": "", "sprite_scale": Vector2.ONE},
			{"name": "LeftFlipperGuideWall", "position": Vector2(FIELD_CENTER_X - 270.0, 625.0), "size": Vector2(520.0, 18.0), "rotation": 0.42, "is_slope": true, "min_thickness": SLOPE_WALL_MIN_THICKNESS, "color": Color(0.4, 0.45, 0.55, 1.0), "bounce": 0.75, "friction": 0.05, "sprite_path": "", "sprite_scale": Vector2.ONE},
			{"name": "RightFlipperGuideWall", "position": Vector2(FIELD_CENTER_X + 270.0, 625.0), "size": Vector2(520.0, 18.0), "rotation": -0.42, "is_slope": true, "min_thickness": SLOPE_WALL_MIN_THICKNESS, "color": Color(0.4, 0.45, 0.55, 1.0), "bounce": 0.75, "friction": 0.05, "sprite_path": "", "sprite_scale": Vector2.ONE},
		],
		"flipper_configs": [
			{"name": "LeftFlipper", "position": Vector2(FIELD_CENTER_X - 50.0, 640.0), "collision_offset": Vector2(45.0, 0.0), "visual_offset": Vector2(45.0, 0.0), "size": Vector2(110.0, 16.0), "rest_rotation": -0.35, "active_rotation": -1.0, "rotate_speed": 14.0, "input_key": KEY_LEFT, "side": -1.0, "hit_impulse": 1600.0, "color": Color(0.95, 0.5, 0.35, 1.0)},
			{"name": "RightFlipper", "position": Vector2(FIELD_CENTER_X + 50.0, 640.0), "collision_offset": Vector2(-45.0, 0.0), "visual_offset": Vector2(-45.0, 0.0), "size": Vector2(110.0, 16.0), "rest_rotation": 0.35, "active_rotation": 1.0, "rotate_speed": 14.0, "input_key": KEY_RIGHT, "side": 1.0, "hit_impulse": 1600.0, "color": Color(0.95, 0.5, 0.35, 1.0)},
		],
		"enemy_configs": STAGE_ENEMY_CONFIGS["stage_01"],
	},
}

static func get_stage_data(stage_id: String = "stage_01") -> Dictionary:
	var stage_data: Dictionary = STAGES.get(stage_id, {})
	if stage_data.is_empty():
		stage_data = STAGES["stage_01"]
	var result: Dictionary = stage_data.duplicate(true)
	result["enemy_configs"] = get_stage_enemy_configs(stage_id)
	return result

static func get_stage_enemy_configs(stage_id: String = "stage_01") -> Array:
	var configs: Array = STAGE_ENEMY_CONFIGS.get(stage_id, [])
	if configs.is_empty():
		configs = STAGE_ENEMY_CONFIGS["stage_01"]
	return configs.duplicate(true)
