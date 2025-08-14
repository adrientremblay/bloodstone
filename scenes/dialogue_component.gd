class_name DialogueComponent extends Inspectable

# TODO: Turn this into a singleton

const LETTER_STREAMS_DIR: String = "res://assets/audio/dialog"
const VOWEL_OPTIONS = ['a', 'e', 'i', 'o', 'u']

var letter_streams = {}

@onready var audio_stream_player = $AudioStreamPlayer3D

signal started_speaking
signal stopped_speaking

func _ready():
	var dir = DirAccess.open(LETTER_STREAMS_DIR)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".mp3"):
			var path = LETTER_STREAMS_DIR + "/" + file_name
			letter_streams[file_name] = load(path)  # runtime load
		file_name = dir.get_next()
	dir.list_dir_end()

func play_random_vowel():
	var random_index = randi_range(0, VOWEL_OPTIONS.size()-1)
	var random_vowel_name = VOWEL_OPTIONS[random_index]
	audio_stream_player.stream = letter_streams[random_vowel_name + ".mp3"]
	audio_stream_player.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		play_random_vowel()

func start_speaking() -> void:
	started_speaking.emit()

func stop_speaking() -> void:
	stopped_speaking.emit()
