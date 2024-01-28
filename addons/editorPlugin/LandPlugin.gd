# LandPlugin.gd
extends EditorPlugin

var land_parcel_scene = preload("res://Scenes/LandParcel.tscn")
var land_parcel_instance: Node = null
var drawing = false

# Handles the draw button click event
func handle_draw_button(draw_button: Button):
	if not drawing:
		land_parcel_instance = land_parcel_scene.instantiate()
		var current_scene = get_editor_interface().get_edited_scene_root()
		var land_parcels_node = current_scene.find_child("LandParcels", true, false)
		if land_parcels_node:
			land_parcels_node.add_child(land_parcel_instance, true)
			land_parcel_instance.owner = current_scene
			reset_polygon_shapes(land_parcel_instance)
			set_owner_recursively(land_parcel_instance, current_scene)

			drawing = true
			draw_button.text = "Finish Drawing"
			print("Start drawing the land parcel.")
	else:
		drawing = false
		draw_button.text = "Draw Land Parcel"
		print("Finished drawing the land parcel.")

# Forwards canvas GUI input event
func forward_canvas_gui_input(event) -> bool:
	if not drawing or land_parcel_instance == null:
		return false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var editor_viewport = get_editor_interface().get_editor_viewport_2d()
		var global_mouse_position = editor_viewport.get_mouse_position()
		var local_pos = land_parcel_instance.to_local(global_mouse_position)
		add_point_to_land_parcel(local_pos)
		return true  # Consuming the event

	return false

# Adds a point to the land parcel's polygon
func add_point_to_land_parcel(position: Vector2):
	var undo_redo_manager = get_undo_redo()  # Obtain the EditorUndoRedoManager

	var collision_polygon = land_parcel_instance.find_child("CollisionPolygon2D", true, false)
	var polygon2d = land_parcel_instance.find_child("Polygon2D", true, false)

	if collision_polygon and polygon2d:
		# Start creating an action
		undo_redo_manager.create_action("Add LandParcel Point")

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

		print("Point added to LandParcel's shape: ", position)
	else:
		print("Error: CollisionPolygon2D or Polygon2D not found in LandParcel scene.")

# Resets the polygon shapes of a land parcel
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
