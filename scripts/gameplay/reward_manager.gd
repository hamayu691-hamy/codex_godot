extends RefCounted
class_name RewardManager

const REWARD_OPTION_IDS: Array[String] = [
	"normal_to_power",
	"random_bumper_damage",
	"add_heal_bumper",
	"enhance_slow",
]

var _reward_levels: Dictionary = {}

func get_random_reward_options(option_count: int) -> Array[String]:
	var reward_options: Array[String] = REWARD_OPTION_IDS.duplicate()
	reward_options.shuffle()
	return reward_options.slice(0, option_count)

func get_reward_label(reward_id: String, bumper_max_level: int) -> String:
	var current_level: int = get_reward_level(reward_id)
	match reward_id:
		"normal_to_power":
			return "normalをpowerに変化 (Lv.%d)" % current_level
		"random_bumper_damage":
			return "ランダムなバンパー Lv+1 (最大Lv.%d) (Lv.%d)" % [bumper_max_level, current_level]
		"add_heal_bumper":
			return "healバンパーを1つ追加 (Lv.%d)" % current_level
		"enhance_slow":
			return "slowバンパー効果を強化 (Lv.%d)" % current_level
		_:
			return "不明な報酬"

func get_reward_result_text(reward_id: String, bumper_max_level: int) -> String:
	match reward_id:
		"normal_to_power":
			return "normalバンパーをpowerに変化しました"
		"random_bumper_damage":
			return "ランダムなバンパーのLvが1上がりました（最大Lv.%d）" % bumper_max_level
		"add_heal_bumper":
			return "healバンパーを獲得しました。配置先のピンを選択してください"
		"enhance_slow":
			return "slowバンパー効果を強化しました"
		_:
			return "報酬を獲得しました"

func get_reward_level(reward_id: String) -> int:
	return int(_reward_levels.get(reward_id, 0)) + 1

func increment_reward_level(reward_id: String) -> void:
	_reward_levels[reward_id] = int(_reward_levels.get(reward_id, 0)) + 1
