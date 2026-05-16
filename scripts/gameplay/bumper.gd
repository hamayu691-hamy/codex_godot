class_name Bumper
extends Area2D

signal hit(bumper: Bumper, bumper_type: String, damage: int)

const HIT_SCALE: Vector2 = Vector2(1.15, 1.15)
const HIT_FLASH_COLOR: Color = Color(0.75, 1.0, 1.0, 1.0)

@export var damage: int = 1
@export var impulse_strength: float = 130.0
@export var bumper_type: String = "normal"
@export var cooldown_time: float = 0.08

var _cooldown_remaining: float = 0.0

@onready var _bumper_visual: CanvasItem = get_node_or_null("BumperVisual")


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

func _apply_impulse_to_ball(ball: RigidBody2D) -> void:
	var hit_direction: Vector2 = ball.global_position - global_position
	if hit_direction.length_squared() <= 0.0001:
		hit_direction = Vector2.UP
	else:
		hit_direction = hit_direction.normalized()
	ball.apply_central_impulse(hit_direction * impulse_strength)

func _play_hit_feedback() -> void:
	if _bumper_visual != null:
		var flash_tween: Tween = create_tween()
		flash_tween.tween_property(_bumper_visual, "modulate", HIT_FLASH_COLOR, 0.05)
		flash_tween.tween_property(_bumper_visual, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)

	var scale_tween: Tween = create_tween()
	scale_tween.tween_property(self, "scale", HIT_SCALE, 0.06)
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.1)
