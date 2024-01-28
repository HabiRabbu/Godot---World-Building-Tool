extends Node2D

@export var landOwner: String = "none"
@export var cost: int = 0
@export var details: String = ""
@export var landArea = 0
@export var pricePerArea = 0.01

func _ready():
	var area2D = $Area2D
	area2D.connect("input_event", _on_Area2D_input_event)
	details = "This is land parcel" + name
	print(details)

	var polygon_node = area2D.get_node("Polygon2D") as Polygon2D
	if polygon_node:
		landArea = int(calculate_polygon_area(polygon_node))
		cost = int(landArea * pricePerArea)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Do something when the land is clicked
		print("Land owner: " + landOwner + " \nCost: " + str(cost) + " \nDetails: " + details + " \nArea: " + str(landArea))


#My Functions
func calculate_polygon_area(polygon: Polygon2D) -> float:
	var vertices = polygon.polygon
	var num_vertices = vertices.size()
	var area = 0.0

	# Calculate the area using the Shoelace formula
	for i in range(num_vertices):
		var j = (i + 1) % num_vertices
		area += vertices[i].x * vertices[j].y
		area -= vertices[j].x * vertices[i].y

	return abs(area) / 2.0
