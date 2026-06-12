extends RefCounted
class_name RewardManager

const REWARD_OPTION_IDS: Array[String] = [
	"add_normal_bumper",
	"add_power_bumper",
	"add_heal_bumper",
	"add_slow_bumper",
	"add_aim_bumper",
	"add_summon_ball_bumper",
]

const BUMPER_TYPE_BY_REWARD_ID: Dictionary = {
	"add_normal_bumper": "normal",
	"add_power_bumper": "power",
	"add_heal_bumper": "heal",
	"add_slow_bumper": "slow",
	"add_aim_bumper": "aim",
	"add_summon_ball_bumper": "summon_ball",
}

func get_random_reward_options(option_count: int) -> Array[String]:
	var reward_options: Array[String] = REWARD_OPTION_IDS.duplicate()
	reward_options.shuffle()
	return reward_options.slice(0, option_count)

func get_reward_label(reward_id: String, _bumper_max_level: int) -> String:
	var bumper_type: String = get_bumper_type(reward_id)
	if bumper_type.is_empty():
		return "不明な報酬"
	return "%sバンパーを1つ獲得" % bumper_type

func get_reward_result_text(reward_id: String, bumper_max_level: int) -> String:
	var bumper_type: String = get_bumper_type(reward_id)
	if bumper_type.is_empty():
		return "報酬を獲得しました"
	return "%sバンパーを獲得しました。空きPinまたは同種バンパー（最大Lv.%d）を選択してください" % [bumper_type, bumper_max_level]

func get_bumper_type(reward_id: String) -> String:
	return str(BUMPER_TYPE_BY_REWARD_ID.get(reward_id, ""))
