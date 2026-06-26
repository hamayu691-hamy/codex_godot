class_name AudioManager
extends Node

const DEFAULT_MAX_PLAYERS: int = 12
const SE_PATHS: Dictionary = {
	"ball_wall_hit": "res://assets/audio/se/ball_wall_hit.ogg",
	"bumper_hit": "res://assets/audio/se/bumper_hit.ogg",
	"enemy_hit": "res://assets/audio/se/enemy_hit.ogg",
	"enemy_defeated": "res://assets/audio/se/enemy_defeated.ogg",
	"player_damage": "res://assets/audio/se/player_damage.ogg",
	"assist_ball_spawn": "res://assets/audio/se/assist_ball_spawn.ogg",
	"bomb_explosion": "res://assets/audio/se/bomb_explosion.ogg",
	"reward_select": "res://assets/audio/se/reward_select.ogg",
	"bumper_level_up": "res://assets/audio/se/bumper_level_up.ogg",
	"fever_start": "res://assets/audio/se/bumper_level_up.ogg",
	"fever_end": "res://assets/audio/se/reward_select.ogg",
	"boss_phase_two": "res://assets/audio/se/enemy_defeated.ogg",
	"boss_fan_burst": "res://assets/audio/se/enemy_hit.ogg",
	"victory": "res://assets/audio/se/victory.ogg",
	"game_over": "res://assets/audio/se/game_over.ogg",
}

@export var enabled: bool = true
@export_range(-80.0, 24.0, 0.1) var se_volume_db: float = 0.0
@export_range(1, 64, 1) var max_players: int = DEFAULT_MAX_PLAYERS

var _players: Array[AudioStreamPlayer] = []
var _stream_cache: Dictionary = {}
var _unavailable_se_ids: Dictionary = {}


func play_se(se_id: String) -> void:
	if not enabled:
		return
	var stream: AudioStream = _get_stream(se_id)
	if stream == null:
		return
	var player: AudioStreamPlayer = _get_available_player()
	if player == null:
		return
	player.stream = stream
	player.volume_db = se_volume_db
	player.play()


func _get_stream(se_id: String) -> AudioStream:
	if _stream_cache.has(se_id):
		return _stream_cache[se_id] as AudioStream
	if _unavailable_se_ids.has(se_id):
		return null
	var stream_path: String = str(SE_PATHS.get(se_id, ""))
	if stream_path.is_empty() or not ResourceLoader.exists(stream_path, "AudioStream"):
		_unavailable_se_ids[se_id] = true
		return null
	var stream: AudioStream = ResourceLoader.load(stream_path, "AudioStream") as AudioStream
	if stream == null:
		_unavailable_se_ids[se_id] = true
		return null
	_stream_cache[se_id] = stream
	return stream


func _get_available_player() -> AudioStreamPlayer:
	for player: AudioStreamPlayer in _players:
		if not player.playing:
			return player
	if _players.size() >= max_players:
		return null
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.name = "SEPlayer_%02d" % (_players.size() + 1)
	add_child(player)
	_players.append(player)
	return player
