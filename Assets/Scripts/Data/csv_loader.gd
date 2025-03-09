extends Node

## The CSV File used for the game.
@export var csv_file: String

var drug_list = []  # Stores Brand/Generic pairs
var generic_to_brands = {}  # Maps Generic names to multiple brands
var current_question = {}  # Stores the active Brand/Generic question

@onready var brand_label: Label = $Banner/BrandLabel
@onready var lane_container: Node = $LaneContainer
@onready var feedback_label: Label = $UI/FeedbackLabel
@onready var score_manager: Node = $ScoreManager
@onready var player: Node = $Player_CharacterBody2D2


func _ready():
	player.player_answered.connect(_on_player_answered_question)
	
	load_csv(csv_file)
	print("✅ Drug list successfully loaded!")
	set_question()  # Set the first question with a slight delay


func load_csv(csv_path: String):
	var file = FileAccess.open(csv_path, FileAccess.READ)
	if not file:
		print("❌ ERROR: Could not open CSV file.")
		return

	drug_list.clear()
	generic_to_brands.clear()

	while not file.eof_reached():
		var line = file.get_line()
		var fields = line.split(",")  

		if len(fields) >= 2:  # Ensure it has at least brand and generic name
			var brand_name = fields[0].strip_edges()
			var generic_name = fields[1].strip_edges()

			drug_list.append({"brand": brand_name, "generic": generic_name})

			if not generic_to_brands.has(generic_name):
				generic_to_brands[generic_name] = []
			generic_to_brands[generic_name].append(brand_name)

	file.close()

	print("📄 Loaded Drug List (Showing 5 Entries):", drug_list.slice(0, 5))  # Debugging output


func set_question():
	if drug_list.size() == 0:
		print("❌ ERROR: Drug list is empty!")
		return

	current_question = drug_list[randi() % drug_list.size()]  

	# Debugging: Check the content of the current question
	print("🔍 Selected Question BEFORE Assignment:", current_question)

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
	all_answers.shuffle()  # Randomize answer placement

	print("✅ Correct Generic BEFORE Assigning to Lanes:", correct_answer)

	for i in range(lane_container.get_child_count()):
		var lane = lane_container.get_child(i)
		var label = lane.get_node_or_null("Label")

		if label:
			label.text = all_answers[i]  # Assign generic names correctly
			lane.set_meta("correct", all_answers[i] == correct_answer)  # Ensure correct lane is marked


## Check the selected answer.
func _on_player_answered_question(current_lane : int):
	var correct_generic = current_question.get("generic", "").strip_edges()

	var player_choice = ""
	if current_lane < lane_container.get_child_count():
		var lane = lane_container.get_child(current_lane)
		var label = lane.get_node_or_null("Label")
		if label:
			player_choice = label.text.strip_edges()

	print("🔍 Checking Answer: Player chose:", player_choice, "| Correct:", correct_generic)

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

	await get_tree().create_timer(1.5).timeout
	feedback_label.text = ""
	set_question()
