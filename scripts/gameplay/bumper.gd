class_name Bumper
extends Area2D

signal hit(bumper: Bumper, bumper_type: String, damage: int)

const HIT_SCALE: Vector2 = Vector2(1.15, 1.15)
const HIT_FLASH_COLOR_BY_TYPE: Dictionary = {
	"normal": Color(0.75, 1.0, 1.0, 1.0),
	"power": Color(1.0, 0.65, 0.5, 1.0),
	"heal": Color(0.6, 1.0, 0.65, 1.0),
	"slow": Color(0.6, 0.7, 1.0, 1.0),
}
const MAX_LEVEL: int = 5

const BUMPER_DISPLAY_NAMES: Dictionary = {
	"normal": "Normal Bumper",
	"power": "Power Bumper",
	"heal": "Heal Bumper",
	"slow": "Slow Bumper",
	"charge": "Charge Bumper",
	"critical": "Critical Bumper",
	"pierce": "Pierce Bumper",
	"combo_plus": "Combo+ Bumper",
	"combo_lock": "Combo Lock Bumper",
	"jackpot": "Jackpot Bumper",
	"spawn": "Spawn Bumper",
	"transform": "Transform Bumper",
	"shield": "Shield Bumper",
	"poison": "Poison Bumper",
	"lightning": "Lightning Bumper",
	"bomb": "Bomb Bumper",
	"multiball": "Multiball Bumper",
}

const BUMPER_EFFECT_DESCRIPTIONS: Dictionary = {
	"normal": "基本効果のみの標準バンパー。",
	"power": "次回の敵ヒットダメージ増加を狙う攻撃補助。",
	"heal": "ボールやプレイヤーの回復に関わる効果（実装予定含む）。",
	"slow": "敵や弾などの行動速度低下を狙う効果。",
	"charge": "チャージ系の蓄積や解放に関わる効果。",
	"critical": "クリティカル関連の強化効果。",
	"pierce": "貫通系の補助効果。",
	"combo_plus": "コンボ増加を補助する効果。",
	"combo_lock": "コンボ維持を補助する効果。",
	"jackpot": "高リターン獲得を狙う特殊効果。",
	"spawn": "生成系（追加出現など）に関わる効果。",
	"transform": "対象変化に関わる効果。",
	"shield": "防御・被ダメ軽減を補助する効果。",
	"poison": "継続ダメージ付与を狙う効果。",
	"lightning": "電撃系の追加効果。",
	"bomb": "範囲爆発系の追加効果。",
	"multiball": "ボール増加に関わる効果。",
}

@export var base_damage: int = 1
@export var base_impulse_strength: float = 130.0
@export var level: int = 1:
	set(value):
		level = clampi(value, 1, MAX_LEVEL)
		_recalculate_stats()
		_update_level_label()
@export var damage: int = 1
@export var impulse_strength: float = 130.0
@export var bumper_type: String = "normal"
@export var cooldown_time: float = 0.08

var _cooldown_remaining: float = 0.0
var _scale_tween: Tween = null
var _flash_tween: Tween = null

@onready var _bumper_visual: CanvasItem = get_node_or_null("BumperVisual")
@onready var _level_label: Label = get_node_or_null("LevelLabel")


func _ready() -> void:
	_recalculate_stats()
	_update_level_label()


func _physics_process(delta: float) -> void:
	if _cooldown_remaining > 0.0:
		_cooldown_remaining = max(_cooldown_remaining - delta, 0.0)

func on_ball_entered(ball: RigidBody2D) -> void:
	if _cooldown_remaining > 0.0:
		return
	_cooldown_remaining = cooldown_time
	_apply_impulse_to_ball(ball)
	_apply_bumper_effect(ball)
	_play_hit_feedback()
	hit.emit(self, bumper_type, damage)

func _apply_bumper_effect(ball: RigidBody2D) -> void:
	match bumper_type:
		"normal":
			_apply_normal_bumper_effect(ball)
		"heal":
			_apply_heal_bumper_effect(ball)
		"slow":
			_apply_slow_bumper_effect(ball)
		"charge":
			_apply_charge_bumper_effect(ball)
		"power":
			_apply_power_bumper_effect(ball)
		"critical":
			_apply_critical_bumper_effect(ball)
		"pierce":
			_apply_pierce_bumper_effect(ball)
		"combo_plus":
			_apply_combo_plus_bumper_effect(ball)
		"combo_lock":
			_apply_combo_lock_bumper_effect(ball)
		"jackpot":
			_apply_jackpot_bumper_effect(ball)
		"spawn":
			_apply_spawn_bumper_effect(ball)
		"transform":
			_apply_transform_bumper_effect(ball)
		"shield":
			_apply_shield_bumper_effect(ball)
		"poison":
			_apply_poison_bumper_effect(ball)
		"lightning":
			_apply_lightning_bumper_effect(ball)
		"bomb":
			_apply_bomb_bumper_effect(ball)
		"multiball":
			_apply_multiball_bumper_effect(ball)
		_:
			_apply_normal_bumper_effect(ball)

func _apply_normal_bumper_effect(_ball: RigidBody2D) -> void:
	# 通常バンパー: 追加効果なし
	pass

func _apply_power_bumper_effect(_ball: RigidBody2D) -> void:
	# 攻撃補助系(power): 次回敵ヒットダメージ増加
	# TODO: ゲーム側の状態管理実装後に適用処理を追加する
	pass

func _apply_heal_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_slow_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_charge_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_critical_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_pierce_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_combo_plus_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_combo_lock_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_jackpot_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_spawn_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_transform_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_shield_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_poison_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_lightning_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_bomb_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func _apply_multiball_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func level_up() -> bool:
	if level >= MAX_LEVEL:
		return false
	level += 1
	return true

func _recalculate_stats() -> void:
	var level_index: int = level - 1
	damage = maxi(1, int(round(base_damage * _get_damage_growth_multiplier(level_index))))
	impulse_strength = base_impulse_strength * _get_impulse_growth_multiplier(level_index)

func _update_level_label() -> void:
	if _level_label == null:
		return
	_level_label.text = "Lv.%d" % level

func _get_damage_growth_multiplier(level_index: int) -> float:
	match bumper_type:
		"power":
			return 1.0 + (0.28 * level_index)
		"slow":
			return 1.0 + (0.18 * level_index)
		"heal":
			return 1.0 + (0.22 * level_index)
		_:
			return 1.0 + (0.2 * level_index)

func _get_impulse_growth_multiplier(level_index: int) -> float:
	match bumper_type:
		"power":
			return 1.0 + (0.12 * level_index)
		"slow":
			return 1.0 + (0.1 * level_index)
		"heal":
			return 1.0 + (0.08 * level_index)
		_:
			return 1.0 + (0.1 * level_index)

func _apply_impulse_to_ball(ball: RigidBody2D) -> void:
	var hit_direction: Vector2 = ball.global_position - global_position
	if hit_direction.length_squared() <= 0.0001:
		hit_direction = Vector2.UP
	else:
		hit_direction = hit_direction.normalized()
	ball.apply_central_impulse(hit_direction * impulse_strength)

func _play_hit_feedback() -> void:
	if _scale_tween != null and _scale_tween.is_running():
		_scale_tween.kill()
	if _flash_tween != null and _flash_tween.is_running():
		_flash_tween.kill()

	if _bumper_visual != null:
		var base_modulate: Color = _bumper_visual.modulate
		var flash_color: Color = _get_hit_flash_color()
		_flash_tween = create_tween()
		_flash_tween.tween_property(_bumper_visual, "modulate", flash_color, 0.05)
		_flash_tween.tween_property(_bumper_visual, "modulate", base_modulate, 0.1)

	_scale_tween = create_tween()
	_scale_tween.tween_property(self, "scale", HIT_SCALE, 0.06)
	_scale_tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func _get_hit_flash_color() -> Color:
	if HIT_FLASH_COLOR_BY_TYPE.has(bumper_type):
		return HIT_FLASH_COLOR_BY_TYPE[bumper_type]
	return HIT_FLASH_COLOR_BY_TYPE["normal"]


func get_tooltip_text() -> String:
	var display_name: String = str(BUMPER_DISPLAY_NAMES.get(bumper_type, "Unknown Bumper"))
	var effect_description: String = str(BUMPER_EFFECT_DESCRIPTIONS.get(bumper_type, "効果説明は未登録です。"))
	var cooldown_state: String = "はい"
	if _cooldown_remaining <= 0.0:
		cooldown_state = "いいえ"
	return "バンパー名: %s\n種別: %s\n効果: %s\nDamage: %d\nCooldown: %.2f 秒\nクールダウン中: %s" % [
		display_name,
		bumper_type,
		effect_description,
		damage,
		cooldown_time,
		cooldown_state,
	]
