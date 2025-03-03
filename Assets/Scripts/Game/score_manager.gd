extends Node

var score: int = 0  # The player's score

signal score_updated(new_score)  # Signal to update UI when score changes

@onready var correct_sound = $CorrectSound  # Corrected path
@onready var wrong_sound = $WrongSound  # Corrected path

# Function to add points (Correct Answer)
func add_points(points: int):
	score += points
	emit_signal("score_updated", score)
	print("✅ Score increased! New Score:", score)

	if correct_sound and correct_sound.stream:
		print("🔊 Playing Correct Sound...")
		correct_sound.stop()
		correct_sound.play()
	else:
		print("⚠️ Correct sound node or stream is missing!")

# Function to subtract points (Incorrect Answer)
func subtract_points(points: int):
	score = max(0, score - points)
	emit_signal("score_updated", score)
	print("❌ Score decreased! New Score:", score)

	if wrong_sound and wrong_sound.stream:
		print("🔊 Playing Wrong Sound...")
		wrong_sound.stop()
		wrong_sound.play()
	else:
		print("⚠️ Wrong sound node or stream is missing!")

# Function to reset the score
func reset_score():
	score = 0
	emit_signal("score_updated", score)
	print("🔄 Score reset.")

# Function to return the current score (for UI updates)
func get_score():
	return score
