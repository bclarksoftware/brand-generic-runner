extends Node2D  # Ensure this matches your lane node type

@onready var label: Label = null  # Reference to the label inside the lane

func _ready():
	label = get_node_or_null("Label")  # Find the Label node inside the Lane
	if label == null:
		print("❌ Label node missing in", self.name, "! Ensure each Lane has a Label child.")
	else:
		print("✅ Label found in", self.name)
		_center_label()  # Ensure label is properly centered when the scene loads

# Function to update lane text with the assigned generic name
func set_lane_text(new_text: String):
	if label:
		label.text = new_text  # ✅ Update label text
		_center_label()  # Center the label after updating the text
		print("✅ Lane", self.name, "updated with:", new_text)
	else:
		print("❌ Unable to update text - Label not found in", self.name)

# Function to center the label within its lane
func _center_label():
	if label and self.get_child_count() > 0:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER  # Center horizontally
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER  # Center vertically (if needed)
		
		var lane_size = get_viewport_rect().size  # Get the viewport size (adjust if needed)
		label.set_position(Vector2((lane_size.x - label.size.x) / 2, (lane_size.y - label.size.y) / 2))
