extends Label

func _ready():
	pass # Replace with function body.

func _on_player_changed_state(new_state_str, new_state_id):
	self.text = new_state_str
