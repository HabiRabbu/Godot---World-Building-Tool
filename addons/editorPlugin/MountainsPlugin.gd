extends EditorPlugin

var mountain_scene = preload("res://Scenes/MapEditorObjects/Mountain.tscn")
var bezier_curve_script = preload("res://addons/editorPlugin/BezierCurving.gd")
var bezier_script
var mountain_instance: Node = null
var drawing = false

func handle_draw_button(draw_button: Button):
	if not drawing:
		mountain_instance = mountain_scene.instantiate()
		var current_scene = get_editor_interface().get_edited_scene_root()
		var mountains_node = current_scene.find_child("Mountains", true, false)
		if mountains_node:
			mountains_node.add_child(mountain_instance, true)
			mountain_instance.owner = current_scene
			reset_polygon_shapes(mountain_instance)
			set_owner_recursively(mountain_instance, current_scene)

			drawing = true
			draw_button.text = "Finish Drawing"
			print("Start drawing the mountain.")
	else:
		drawing = false
		draw_button.text = "Draw Mountains"
		finalise_mountain_shape()
		print("Finished drawing the Mountains.")

func forward_canvas_gui_input(event) -> bool:
	if not drawing or mountain_instance == null:
		return false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var editor_viewport = get_editor_interface().get_editor_viewport_2d()
		var global_mouse_position = editor_viewport.get_mouse_position()
		var local_pos = mountain_instance.to_local(global_mouse_position)
		add_point_to_tree(local_pos)
		return true  # Consuming the event

	return false

func add_point_to_tree(position: Vector2):
	var undo_redo_manager = get_undo_redo()  # Obtain the EditorUndoRedoManager

	var collision_polygon = mountain_instance.find_child("CollisionPolygon2D", true, false)
	var polygon2d = mountain_instance.find_child("Polygon2D", true, false)

	if collision_polygon and polygon2d:
		# Start creating an action
		undo_redo_manager.create_action("Add Mountain Point")

		# Duplicate current polygons for the undo action
		var undo_polygon2d_points = polygon2d.polygon.duplicate()
		var undo_collision_polygon_points = collision_polygon.polygon.duplicate()

		# Prepare new points for the do action
		var new_polygon2d_points = undo_polygon2d_points.duplicate()
		var new_collision_polygon_points = undo_collision_polygon_points.duplicate()
		new_polygon2d_points.append(position)
		new_collision_polygon_points.append(position)

		# Register the undo and do actions
		undo_redo_manager.add_undo_property(polygon2d, "polygon", undo_polygon2d_points)
		undo_redo_manager.add_undo_property(collision_polygon, "polygon", undo_collision_polygon_points)
		undo_redo_manager.add_do_property(polygon2d, "polygon", new_polygon2d_points)
		undo_redo_manager.add_do_property(collision_polygon, "polygon", new_collision_polygon_points)

		# Commit the action
		undo_redo_manager.commit_action()

		print("Point added to Mountain's shape: ", position)
	else:
		print("Error: CollisionPolygon2D or Polygon2D not found in Mountain scene.")

func reset_polygon_shapes(node: Node):
	var collision_polygon = node.find_child("CollisionPolygon2D", true, false)
	var polygon2d = node.find_child("Polygon2D", true, false)
	if collision_polygon and polygon2d:
		collision_polygon.polygon = PackedVector2Array()
		polygon2d.polygon = PackedVector2Array()

# Sets the owner property of a node and all its children recursively
func set_owner_recursively(node: Node, owner: Node):
	node.owner = owner
	for child in node.get_children():
		set_owner_recursively(child, owner)

func finalise_mountain_shape():
	var polygon2d = mountain_instance.find_child("Polygon2D", true, false)
	var innerPolygon2d = mountain_instance.find_child("InnerPolygon2D", true, false)
	var collision_polygon = mountain_instance.find_child("CollisionPolygon2D", true, false)
	if polygon2d and collision_polygon:
		var original_vertices = polygon2d.polygon
		bezier_script = bezier_curve_script.new()
		var smoothness = 10
		var corner_radius = 100

		var rounded_vertices = bezier_script.create_rounded_polygon(original_vertices, smoothness, corner_radius)
		polygon2d.polygon = rounded_vertices
		collision_polygon.polygon = rounded_vertices
		print("Tree shape finalized with rounded edges.")


	else:
		if not polygon2d:
			print("Error: Polygon2D not found in Tree instance.")
		if not collision_polygon:
			print("Error: CollisionPolygon2D not found in Tree instance.")
