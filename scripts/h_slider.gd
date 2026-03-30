extends HSlider

@onready var master_bus = AudioServer.get_bus_index("Master")

func _ready() -> void:
	value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	if value == 0:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
