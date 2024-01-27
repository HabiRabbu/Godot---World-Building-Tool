@tool
extends EditorPlugin

var land_parcel_scene = preload("res://Scenes/LandParcel.tscn")
var land_parcel_instance: Node = null
var drawing = false
var dock_panel: PanelContainer
var draw_button: Button

func _enter_tree():
	set_input_event_forwarding_always_enabled()
	# Create the dock panel container
	dock_panel = PanelContainer.new()
	dock_panel.name = "Land Parcel Editor"

	# Create a VBoxContainer as a child of the dock panel to organize contents vertically
	var vbox = VBoxContainer.new()
	dock_panel.add_child(vbox)

	# Create the draw button
	draw_button = Button.new()
	draw_button.text = "Draw Land Parcel"
	draw_button.connect("pressed", _on_draw_button_pressed)
	vbox.add_child(draw_button)  # Add the button to the VBoxContainer for layout

	# Add the custom dock to the editor
	var dock_name = "LandParcelDock"
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL, dock_panel)
	dock_panel.show()  # Ensure the dock panel is visible

	# Register the plugin
	add_custom_type("LandParcel", "Node2D", land_parcel_scene, preload("res://icon.svg"))

func _exit_tree():
	remove_custom_type("LandParcel")
	# Here, remove the dock panel from the editor and clean up
	if dock_panel:
		remove_control_from_docks(dock_panel)
		dock_panel.queue_free()

func _on_draw_button_pressed():
	print("Pressed")
	if not drawing:
		land_parcel_instance = land_parcel_scene.instantiate()
		var current_scene = get_editor_interface().get_edited_scene_root()
		var land_parcels_node = current_scene.find_child("LandParcels", true, false)
		land_parcels_node.add_child(land_parcel_instance, true)

		var collision_polygon = land_parcel_instance.find_child("CollisionPolygon2D")
		var polygon2d = land_parcel_instance.find_child("Polygon2D")
		polygon2d.polygon = PackedVector2Array()
		collision_polygon.polygon = PackedVector2Array()

		land_parcel_instance.set_owner(current_scene)
		land_parcel_instance.owner = get_editor_interface().get_edited_scene_root()
		set_owner_recursively(land_parcel_instance, get_editor_interface().get_edited_scene_root())

		drawing = true
		draw_button.text = "Finish Drawing"
		print("Start drawing the land parcel.")
	else:
		drawing = false
		draw_button.text = "Draw Land Parcel"
		#land_parcel_instance.queue_free()  # Properly remove the instance when finished drawing
		#land_parcel_instance = null
		print("Finished drawing the land parcel.")

func set_owner_recursively(node, owner):
	node.owner = owner
	print("I'm setting recursively")
	for child in node.get_children():
		set_owner_recursively(child, owner)

func _handles(object):
	return true

func _forward_canvas_gui_input(event) -> bool:
	if not drawing or land_parcel_instance == null:
		return false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#print("Canvas GUI input received:", event)
		# Directly use event.position if applicable, or adjust as needed based on your context
		var editor_viewport = get_editor_interface().get_editor_viewport_2d()
		var global_mouse_position = editor_viewport.get_mouse_position()
		var local_pos = land_parcel_instance.to_local(global_mouse_position)
		_add_point_to_land_parcel(local_pos)
		return true  # Consuming the event


	return false  # Forwarding the event if not processed


func _add_point_to_land_parcel(position: Vector2):
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
