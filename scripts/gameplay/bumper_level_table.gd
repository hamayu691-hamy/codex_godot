class_name BumperLevelTable
extends RefCounted

const MAX_SUPPORTED_LEVEL: int = 5

# Each array is indexed by Lv - 1 so balance changes stay data-only.
const DAMAGE_MULTIPLIERS: Dictionary = {
	"normal": [1.0, 1.2, 1.4, 1.6, 1.8],
	"power": [1.0, 1.28, 1.56, 1.84, 2.12],
	"heal": [1.0, 1.22, 1.44, 1.66, 1.88],
	"slow": [1.0, 1.18, 1.36, 1.54, 1.72],
	"summon_ball": [1.0, 1.2, 1.4, 1.6, 1.8],
}
const IMPULSE_MULTIPLIERS: Dictionary = {
	"normal": [1.0, 1.1, 1.2, 1.3, 1.4],
	"power": [1.0, 1.12, 1.24, 1.36, 1.48],
	"heal": [1.0, 1.08, 1.16, 1.24, 1.32],
	"slow": [1.0, 1.1, 1.2, 1.3, 1.4],
	"summon_ball": [1.0, 1.1, 1.2, 1.3, 1.4],
}
const NORMAL_COMBO_GAIN: Array[int] = [1, 2, 2, 3, 3]
const POWER_COMBO_GAIN: Array[int] = [2, 2, 3, 3, 4]
const POWER_BONUS_DAMAGE: Array[int] = [1, 2, 3, 4, 5]
const HEAL_AMOUNTS: Array[int] = [1, 2, 3, 4, 5]
const SLOW_RATES: Array[float] = [0.8, 0.72, 0.64, 0.56, 0.48]
const SUMMON_BALL_COUNTS: Array[int] = [1, 1, 1, 2, 2]
const AIM_BUMPER_LEVEL_SPEED_BONUS: float = 80.0


static func get_damage_multiplier(bumper_type: String, level: int) -> float:
	return float(_get_type_level_value(DAMAGE_MULTIPLIERS, bumper_type, level, 1.0))


static func get_impulse_multiplier(bumper_type: String, level: int) -> float:
	return float(_get_type_level_value(IMPULSE_MULTIPLIERS, bumper_type, level, 1.0))


static func get_normal_combo_gain(level: int) -> int:
	return NORMAL_COMBO_GAIN[_get_level_index(level)]


static func get_power_combo_gain(level: int) -> int:
	return POWER_COMBO_GAIN[_get_level_index(level)]


static func get_power_bonus_damage(level: int) -> int:
	return POWER_BONUS_DAMAGE[_get_level_index(level)]


static func get_heal_amount(level: int) -> int:
	return HEAL_AMOUNTS[_get_level_index(level)]


static func get_slow_rate(level: int) -> float:
	return SLOW_RATES[_get_level_index(level)]


static func get_summon_ball_count(level: int) -> int:
	return SUMMON_BALL_COUNTS[_get_level_index(level)]


static func get_aim_bumper_speed_bonus(level: int) -> float:
	return AIM_BUMPER_LEVEL_SPEED_BONUS * _get_level_index(level)


static func get_effect_description(bumper_type: String, level: int) -> String:
	match bumper_type:
		"normal":
			return "コンボ +%d" % get_normal_combo_gain(level)
		"power":
			return "コンボ +%d / 次回敵ヒットまたは補助ボール攻撃力 +%d" % [get_power_combo_gain(level), get_power_bonus_damage(level)]
		"heal":
			return "ヒットしたメインボールまたは補助ボールのHPを %d 回復" % get_heal_amount(level)
		"slow":
			return "ヒットしたボールの速度を %.0f%% に低下" % (get_slow_rate(level) * 100.0)
		"summon_ball":
			return "設定タイプの補助ボールを %d 体生成 / コンボ +1" % get_summon_ball_count(level)
		"aim":
			return "最寄りの生存中の敵方向へ向きを変える / 速度 +%.0f" % get_aim_bumper_speed_bonus(level)
		_:
			return "基本効果（Damageと反発力がLvに応じて上昇）"


static func _get_type_level_value(table: Dictionary, bumper_type: String, level: int, fallback: Variant) -> Variant:
	var values: Array = table.get(bumper_type, [])
	if values.is_empty():
		return fallback
	return values[mini(_get_level_index(level), values.size() - 1)]


static func _get_level_index(level: int) -> int:
	return clampi(level, 1, MAX_SUPPORTED_LEVEL) - 1
