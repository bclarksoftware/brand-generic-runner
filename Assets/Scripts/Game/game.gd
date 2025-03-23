extends Node

## The CSV File used for the game.
@export var csv_file: String

var drug_list = []  # Stores Brand/Generic pairs
var current_question = {}  # Stores the active Brand/Generic question
var missed_questions = []  # Stores missed questions for review

var _curr_question_index = 0  # Index for the current question
var _feedback_timer: Timer = null  # Timer for feedback display


@onready var brand_label: Label = $Banner/BrandLabel
@onready var lane_container: Node = $LaneContainer
@onready var feedback_label: Label = $UI/FeedbackLabel
@onready var score_manager: Node = $ScoreManager
@onready var player: Node = $Player_CharacterBody2D2
@onready var copy_to_clipboard_button: Button = $UI/CopyToClipboard


func _ready():
	player.player_answered.connect(_on_player_answered_question)

	# Initialize the feedback timer
	_feedback_timer = Timer.new()
	_feedback_timer.one_shot = true
	_feedback_timer.wait_time = 2.0
	_feedback_timer.timeout.connect(_on_feedback_timer_timeout)
	add_child(_feedback_timer)
	
	load_csv(csv_file)
	drug_list.shuffle()  # Shuffle the drug list for randomnessed!")
	set_question()  # Set the first question with a slight delay


func load_csv(csv_path: String):
	var file = FileAccess.open(csv_path, FileAccess.READ)
	if not file:
		print("❌ ERROR: Could not open CSV file.")
		return

	drug_list.clear()
	
	# Skip the header row
	if not file.eof_reached():
		var header = file.get_line()

	while not file.eof_reached():
		var line = file.get_line()
		var fields = line.split(",")

		if len(fields) >= 2:  # Ensure it has at least brand and generic name
			var brand_name = fields[0].strip_edges()
			var generic_name = fields[1].strip_edges()
			drug_list.append({"brand": brand_name, "generic": generic_name})

	file.close()

	print("📄 Loaded Drug List (Showing 5 Entries):", drug_list.slice(0, 5))  # Debugging output


func set_question():
	if drug_list.size() == 0:
		print("❌ ERROR: Drug list is empty!")
		return
	elif _curr_question_index >= drug_list.size():
		return

	current_question = drug_list[_curr_question_index]

	display_question(current_question["brand"])
	assign_answers()

	# Debugging: Check the generic name
	print("✅ Current Question Generic:", current_question["generic"])


func display_question(brand_name: String):
	brand_label.text = brand_name  # Ensure brand name updates


func assign_answers():
	if drug_list.size() == 0:
		print("❌ ERROR: Drug list is empty!")
		return

	var correct_answer = current_question["generic"]

	var incorrect_answers = []
	
	while incorrect_answers.size() < 3:
		var random_drug = drug_list[randi() % drug_list.size()]["generic"]
		if random_drug != correct_answer and not incorrect_answers.has(random_drug):
			incorrect_answers.append(random_drug)

	var all_answers = [correct_answer] + incorrect_answers
	all_answers.shuffle()

	for i in range(lane_container.get_child_count()):
		var lane = lane_container.get_child(i)
		var label = lane.get_node_or_null("Label")

		if label:
			label.text = all_answers[i]  # Assign generic names correctly
			lane.set_meta("correct", all_answers[i] == correct_answer)  # Ensure correct lane is marked


## Check the selected answer.
func _on_player_answered_question(current_lane : int):
	if not _feedback_timer.is_stopped():
		return
	elif _curr_question_index >= drug_list.size():
		return

	var correct_generic = current_question.get("generic", "").strip_edges()

	var player_choice = ""
	if current_lane < lane_container.get_child_count():
		var lane = lane_container.get_child(current_lane)
		var label = lane.get_node_or_null("Label")
		if label:
			player_choice = label.text.strip_edges()

	if player_choice == correct_generic:
		feedback_label.text = "✅ Correct!"
		feedback_label.add_theme_color_override("font_color", Color(0, 1, 0))
		feedback_label.add_theme_color_override("font_outline_color", Color(0,0,0))
		feedback_label.add_theme_constant_override("outline_size", 5)
		if score_manager and score_manager.has_method("add_points"):
			score_manager.add_points(10)
	else:
		feedback_label.text = "❌ Wrong!\nCorrect: " + correct_generic
		feedback_label.add_theme_color_override("font_color", Color(1, 0, 0))
		feedback_label.add_theme_color_override("font_outline_color", Color(0,0,0))
		feedback_label.add_theme_constant_override("outline_size", 5)
		if score_manager and score_manager.has_method("subtract_points"):
			score_manager.subtract_points(5)
		# Add missed question to the list for review
		missed_questions.append(current_question)

	_feedback_timer.start()  # Start the feedback timer to show the result


func _on_feedback_timer_timeout():
	feedback_label.text = ""  # Clear feedback after timeout
	_feedback_timer.stop()  # Stop the timer

	_curr_question_index = _curr_question_index + 1

	# If last question, display list of missed questions
	if _curr_question_index >= drug_list.size():
		print("🔍 All questions answered! Missed Questions:", missed_questions)
		brand_label.text = "End"
	else:
		set_question()

# Handle continue button press
func _on_continue_pressed():
	# Reset game state
	_curr_question_index = 0
	missed_questions.clear()
	drug_list.shuffle()

	# Unpause and start new round
	set_question()


func _on_copy_to_clipboard_pressed():
	# Create CSV data with header
	var csv_data = "Brand,Generic\n"

	# Add each missed question
	for question in missed_questions:
		var brand = question.get("brand", "").replace(",", " ")  # Replace commas to avoid CSV issues
		var generic = question.get("generic", "").replace(",", " ")
		csv_data += "%s,%s\n" % [brand, generic]

	# Copy to clipboard using Godot 4.4 API
	DisplayServer.clipboard_set(csv_data)
