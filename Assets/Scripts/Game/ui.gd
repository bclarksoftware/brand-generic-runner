extends Control

@onready var score_label: Label = $ScoreLabel  # Reference to the Score Label
@onready var score_manager = $"../ScoreManager" as Node  # Ensure it references the script

func _ready():
	if score_manager is Node and score_manager.has_method("get_score"):
		score_manager.connect("score_updated", _update_score_label)
		_update_score_label(score_manager.get_score())  # ✅ Call get_score() instead of score directly

func _update_score_label(new_score):
	score_label.text = "Score: " + str(new_score)
