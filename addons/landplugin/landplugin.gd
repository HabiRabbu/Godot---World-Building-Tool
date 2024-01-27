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
		land_parcels_node.add_child(land_parcel_instance)
		land_parcel_instance.set_owner(current_scene)

		var collision_polygon = land_parcel_instance.find_child("CollisionPolygon2D")
		var polygon2d = land_parcel_instance.find_child("Polygon2D")
		polygon2d.polygon = PackedVector2Array()
		collision_polygon.polygon = PackedVector2Array()

		drawing = true
		draw_button.text = "Finish Drawing"
		print("Start drawing the land parcel.")
	else:
		drawing = false
		draw_button.text = "Draw Land Parcel"
		#land_parcel_instance.queue_free()  # Properly remove the instance when finished drawing
		#land_parcel_instance = null
		print("Finished drawing the land parcel.")

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
	var undo_redo = get_undo_redo()  # Get the editor's UndoRedo manager

	var collision_polygon = land_parcel_instance.find_child("CollisionPolygon2D", true, false)
	var polygon2d = land_parcel_instance.find_child("Polygon2D", true, false)

	if collision_polygon and polygon2d:
		undo_redo.create_action("Add LandParcel Point")
		var points_polygon2d = polygon2d.polygon.duplicate()
		var points_collision_polygon = collision_polygon.polygon.duplicate()
		points_polygon2d.append(position)
		points_collision_polygon.append(position)

		# Register the change with undo_redo for both nodes
		undo_redo.add_do_method(polygon2d, "set", "polygon", points_polygon2d)
		undo_redo.add_do_method(collision_polygon, "set", "polygon", points_collision_polygon)
		undo_redo.add_undo_method(polygon2d, "set", "polygon", polygon2d.polygon)
		undo_redo.add_undo_method(collision_polygon, "set", "polygon", collision_polygon.polygon)

		undo_redo.commit_action()

		print("Point added to LandParcel's shape: ", position)
	else:
		print("Error: CollisionPolygon2D or Polygon2D not found in LandParcel scene.")

