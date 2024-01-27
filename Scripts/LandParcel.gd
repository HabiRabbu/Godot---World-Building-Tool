extends Node2D

@export var landOwner: String = "none"
@export var cost: int = 1000
@export var details: String = ""

func _ready():
	var area2D = $Area2D
	area2D.connect("input_event", _on_Area2D_input_event)
	details = "This is land parcel" + name
	print(details)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Do something when the land is clicked
		print("Land owner: " + landOwner + " \nCost: " + str(cost) + " \nDetails: " + details)

