extends RefCounted
class_name StageConfig

const FIELD_WIDTH: float = 1200.0
const FIELD_HEIGHT: float = 700.0
const VIEW_WIDTH: float = 800.0
const VIEW_HEIGHT: float = 700.0
const SLOPE_WALL_MIN_THICKNESS: float = 25.0
const FIELD_CENTER_X: float = FIELD_WIDTH * 0.5

const STAGES: Dictionary = {
	"stage_01": {
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
				"sprite_scale": Vector2.ONE * (36.0 / 1254.0),
			},
			{
				"position": Vector2(600.0, 240.0),
				"level": 1,
				"damage": 1,
				"impulse_strength": 130.0,
				"bumper_type": "power",
				"sprite_path": "res://gazou/banper_0.png",
				"sprite_scale": Vector2.ONE * (36.0 / 1254.0),
			},
			{
				"position": Vector2(920.0, 285.0),
				"level": 1,
				"damage": 1,
				"impulse_strength": 130.0,
				"bumper_type": "slow",
				"sprite_path": "res://gazou/banper_0.png",
				"sprite_scale": Vector2.ONE * (36.0 / 1254.0),
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
		"enemy_configs": [
			{"position": Vector2(FIELD_CENTER_X, 170.0), "max_hp": 20, "current_hp": 20, "contact_damage": 1, "move_speed": 35.0, "enemy_type": "basic", "score_value": 100, "move_axis": "horizontal", "move_range": 260.0, "attack_type": "bullet", "attack_interval": 1.1, "sprite_path": "res://gazou/enemy_0.png", "sprite_scale": Vector2.ONE * (40.0 / 1254.0)},
		],
	},
}

static func get_stage_data(stage_id: String = "stage_01") -> Dictionary:
	var stage_data: Dictionary = STAGES.get(stage_id, {})
	if stage_data.is_empty():
		stage_data = STAGES["stage_01"]
	return stage_data.duplicate(true)
