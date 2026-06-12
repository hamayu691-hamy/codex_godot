class_name Bumper
extends Area2D

const BumperLevelTable = preload("res://scripts/gameplay/bumper_level_table.gd")

signal hit(bumper: Bumper, bumper_type: String, damage: int, ball: RigidBody2D)

const HIT_SCALE: Vector2 = Vector2(1.28, 1.28)
const HIT_FLASH_COLOR_BY_TYPE: Dictionary = {
	"normal": Color(0.75, 1.0, 1.0, 1.0),
	"power": Color(1.0, 0.65, 0.5, 1.0),
	"heal": Color(0.6, 1.0, 0.65, 1.0),
	"slow": Color(0.6, 0.7, 1.0, 1.0),
	"aim": Color(0.75, 0.55, 1.0, 1.0),
	"summon_ball": Color(0.55, 1.0, 0.9, 1.0),
}
const MAX_LEVEL: int = 5
const COOLDOWN_VISUAL_MODULATE: Color = Color(0.38, 0.38, 0.42, 1.0)
const COOLDOWN_LABEL_POSITION: Vector2 = Vector2(-30.0, -23.0)
const COOLDOWN_LABEL_SIZE: Vector2 = Vector2(60.0, 18.0)
const COOLDOWN_LABEL_FONT_SIZE: int = 10

const BUMPER_DISPLAY_NAMES: Dictionary = {
	"normal": "Normal Bumper",
	"power": "Power Bumper",
	"heal": "Heal Bumper",
	"slow": "Slow Bumper",
	"aim": "Aim Bumper",
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
	"summon_ball": "Summon Ball Bumper",
}

const ASSIST_BALL_EFFECT_DESCRIPTIONS: Dictionary = {
	"normal": "標準的な補助ボール。",
	"attack": "攻撃力が高い補助ボール。",
	"shield": "敵弾を防ぐ補助ボール。",
	"combo": "バンパーヒット時にコンボを追加する補助ボール。",
	"bomb": "爆発して範囲ダメージ＋玉を吹き飛ばす補助ボール。",
}

const BUMPER_EFFECT_DESCRIPTIONS: Dictionary = {
	"normal": "基本効果のみの標準バンパー。",
	"power": "次回の敵ヒットダメージ増加や補助ボールの攻撃力強化を狙う攻撃補助。",
	"heal": "メインボールや補助ボールのHP回復に関わる効果。",
	"slow": "敵や弾などの行動速度低下を狙う効果。",
	"aim": "ヒットした玉を最も近い生存中の敵へ向け、Lvに応じて速度を加算する。",
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
	"summon_ball": "設定されたタイプの補助ボールを生成。補助ボールでも発動可能。",
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
@export var bumper_type: String = "normal":
	set(value):
		bumper_type = value
		_recalculate_stats()
@export_enum("normal", "attack", "shield", "combo", "bomb") var summon_assist_ball_type: String = "normal"
@export var cooldown_time: float = 0.08

var _cooldown_remaining: float = 0.0
var _scale_tween: Tween = null
var _flash_tween: Tween = null
var _cooldown_label: Label = null
var _base_visual_self_modulates: Dictionary = {}
var _is_cooldown_visual_active: bool = false

@onready var _bumper_visual: CanvasItem = get_node_or_null("BumperVisual")
@onready var _bumper_sprite: CanvasItem = get_node_or_null("BumperSprite")
@onready var _level_label: Label = get_node_or_null("LevelLabel")


func _ready() -> void:
	_recalculate_stats()
	_update_level_label()
	_ensure_cooldown_label()
	_capture_base_visual_self_modulates()
	_update_cooldown_display()


func _physics_process(delta: float) -> void:
	if _cooldown_remaining > 0.0:
		_cooldown_remaining = max(_cooldown_remaining - delta, 0.0)
	_update_cooldown_display()

func on_ball_entered(ball: RigidBody2D) -> void:
	if _cooldown_remaining > 0.0:
		return
	_cooldown_remaining = cooldown_time
	_update_cooldown_display()
	_apply_impulse_to_ball(ball)
	_apply_bumper_effect(ball)
	_play_hit_feedback()
	hit.emit(self, bumper_type, damage, ball)


func _ensure_cooldown_label() -> void:
	_cooldown_label = get_node_or_null("CooldownLabel") as Label
	if _cooldown_label != null:
		return
	_cooldown_label = Label.new()
	_cooldown_label.name = "CooldownLabel"
	_cooldown_label.position = COOLDOWN_LABEL_POSITION
	_cooldown_label.size = COOLDOWN_LABEL_SIZE
	_cooldown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cooldown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_cooldown_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cooldown_label.z_index = 2
	_cooldown_label.add_theme_font_size_override("font_size", COOLDOWN_LABEL_FONT_SIZE)
	_cooldown_label.add_theme_color_override("font_color", Color.WHITE)
	_cooldown_label.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.05, 0.95))
	_cooldown_label.add_theme_constant_override("outline_size", 2)
	add_child(_cooldown_label)

func _capture_base_visual_self_modulates() -> void:
	_base_visual_self_modulates.clear()
	for visual: CanvasItem in _get_bumper_visuals():
		_base_visual_self_modulates[visual] = visual.self_modulate

func _get_bumper_visuals() -> Array[CanvasItem]:
	var visuals: Array[CanvasItem] = []
	if _bumper_visual != null:
		visuals.append(_bumper_visual)
	if _bumper_sprite != null:
		visuals.append(_bumper_sprite)
	return visuals

func _update_cooldown_display() -> void:
	var is_on_cooldown: bool = _cooldown_remaining > 0.0
	if _cooldown_label != null:
		_cooldown_label.visible = is_on_cooldown
		if is_on_cooldown:
			var displayed_remaining: float = ceil(_cooldown_remaining * 10.0) / 10.0
			_cooldown_label.text = "%.1fs" % displayed_remaining
	if is_on_cooldown == _is_cooldown_visual_active:
		return
	_is_cooldown_visual_active = is_on_cooldown
	for visual: CanvasItem in _get_bumper_visuals():
		if is_on_cooldown:
			visual.self_modulate = COOLDOWN_VISUAL_MODULATE
		else:
			visual.self_modulate = _base_visual_self_modulates.get(visual, Color.WHITE)

func _apply_bumper_effect(ball: RigidBody2D) -> void:
	match bumper_type:
		"normal":
			_apply_normal_bumper_effect(ball)
		"heal":
			_apply_heal_bumper_effect(ball)
		"slow":
			_apply_slow_bumper_effect(ball)
		"aim":
			_apply_aim_bumper_effect(ball)
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
		"summon_ball":
			_apply_summon_ball_bumper_effect(ball)
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

func _apply_aim_bumper_effect(_ball: RigidBody2D) -> void:
	# 敵の探索を管理する戦闘シーン側で速度補正を適用する
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

func _apply_summon_ball_bumper_effect(_ball: RigidBody2D) -> void:
	pass

func level_up() -> bool:
	if level >= MAX_LEVEL:
		return false
	level += 1
	return true

func _recalculate_stats() -> void:
	damage = maxi(1, int(round(base_damage * BumperLevelTable.get_damage_multiplier(bumper_type, level))))
	impulse_strength = base_impulse_strength * BumperLevelTable.get_impulse_multiplier(bumper_type, level)

func _update_level_label() -> void:
	if _level_label == null:
		return
	_level_label.text = "Lv.%d" % level

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

	var feedback_target: CanvasItem = _get_feedback_visual_target()
	if feedback_target != null:
		var base_modulate: Color = feedback_target.modulate
		var flash_color: Color = _get_hit_flash_color()
		_flash_tween = create_tween()
		_flash_tween.tween_property(feedback_target, "modulate", flash_color, 0.06)
		_flash_tween.tween_property(feedback_target, "modulate", base_modulate, 0.12)

	_scale_tween = create_tween()
	_scale_tween.tween_property(self, "scale", HIT_SCALE, 0.07)
	_scale_tween.tween_property(self, "scale", Vector2.ONE, 0.12)

func _get_feedback_visual_target() -> CanvasItem:
	if _bumper_sprite != null and _bumper_sprite.visible:
		return _bumper_sprite
	return _bumper_visual

func _get_hit_flash_color() -> Color:
	if HIT_FLASH_COLOR_BY_TYPE.has(bumper_type):
		return HIT_FLASH_COLOR_BY_TYPE[bumper_type]
	return HIT_FLASH_COLOR_BY_TYPE["normal"]


func get_tooltip_text() -> String:
	var display_name: String = str(BUMPER_DISPLAY_NAMES.get(bumper_type, "Unknown Bumper"))
	var effect_description: String = str(BUMPER_EFFECT_DESCRIPTIONS.get(bumper_type, "効果説明は未登録です。"))
	var cooldown_state: String = "使用可能"
	if _cooldown_remaining > 0.0:
		cooldown_state = "クールタイム中（残り %.2f 秒）" % _cooldown_remaining
	if bumper_type == "summon_ball":
		var assist_description: String = str(ASSIST_BALL_EFFECT_DESCRIPTIONS.get(summon_assist_ball_type, "特殊な補助ボール。"))
		effect_description = "%s 生成タイプ: %s（%s）" % [effect_description, summon_assist_ball_type, assist_description]
	var level_effect_description: String = BumperLevelTable.get_effect_description(bumper_type, level)
	return "バンパー名: %s\n種別: %s / Lv.%d\nLv効果: %s\n概要: %s\nDamage: %d / 反発力: %.0f\nCooldown: %.2f 秒\n現在の状態: %s" % [
		display_name,
		bumper_type,
		level,
		level_effect_description,
		effect_description,
		damage,
		impulse_strength,
		cooldown_time,
		cooldown_state,
	]
