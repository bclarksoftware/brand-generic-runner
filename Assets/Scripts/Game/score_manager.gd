extends Node

var score: int = 0  # The player's score

signal score_updated(new_score)  # Signal to update UI when score changes

@onready var correct_sound = $CorrectSound  # Corrected path
@onready var wrong_sound = $WrongSound  # Corrected path

# Function to add points (Correct Answer)
func add_points(points: int):
	score += points
	emit_signal("score_updated", score)

	if correct_sound and correct_sound.stream:
		correct_sound.stop()
		correct_sound.play()

# Function to subtract points (Incorrect Answer)
func subtract_points(points: int):
	score = max(0, score - points)
	emit_signal("score_updated", score)

	if wrong_sound and wrong_sound.stream:
		wrong_sound.stop()
		wrong_sound.play()

# Function to reset the score
func reset_score():
	score = 0
	emit_signal("score_updated", score)

# Function to return the current score (for UI updates)
func get_score():
	return score
