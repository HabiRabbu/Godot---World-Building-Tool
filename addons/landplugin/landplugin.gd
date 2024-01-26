@tool
extends EditorPlugin

var land_parcel_scene = preload("res://Scenes/LandParcel.tscn")
var land_parcel_instance: Node = null
var drawing = false
var dock_panel: PanelContainer
var draw_button: Button

func _enter_tree():
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
	if land_parcel_instance == null:
		land_parcel_instance = land_parcel_scene.instance()
		var current_scene = get_editor_interface().get_edited_scene_root()

		# Find the "LandParcels" node within the current scene
		var land_parcels_node = current_scene.find_node("LandParcels", true, false)
		if land_parcels_node:
			land_parcels_node.add_child(land_parcel_instance)
			drawing = true
			draw_button.text = "Finish Drawing"
			print("Start drawing the land parcel.")
		else:
			print("Error: 'LandParcels' node not found in the current scene.")
	else:
		drawing = false
		draw_button.text = "Draw Land Parcel"
		print("Finished drawing the land parcel.")
		land_parcel_instance = null


func forward_canvas_gui_input(event):
	if not drawing or land_parcel_instance == null:
		return false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local_pos = land_parcel_instance.to_local(get_editor_interface().get_editor_viewport().get_canvas_transform().affine_inverse().xform(event.global_position))
		_add_point_to_land_parcel(local_pos)
		return true

	return false

func _add_point_to_land_parcel(position: Vector2):
	var collision_polygon = land_parcel_instance.get_node("CollisionPolygon2D")
	var polygon2d = land_parcel_instance.get_node("Polygon2D")

	if collision_polygon and polygon2d:
		# Append the new point
		var points = collision_polygon.polygon
		points.append(position)
		collision_polygon.polygon = points
		polygon2d.polygon = points

		# Update the editor for visual feedback
		polygon2d.update()
		print("Point added to LandParcel's shape: ", position)
	else:
		print("Error: CollisionPolygon2D or Polygon2D not found in LandParcel scene.")

