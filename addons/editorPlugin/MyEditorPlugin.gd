# MyEditorPlugin.gd
@tool
extends EditorPlugin

var land_plugin_script = preload("res://addons/editorPlugin/LandPlugin.gd")
var trees_plugin_script = preload("res://addons/editorPlugin/TreesPlugin.gd")
var mountains_plugin_script = preload("res://addons/editorPlugin/MountainsPlugin.gd")

var dock_panel: PanelContainer

var land_plugin
var trees_plugin
var mountains_plugin

var draw_trees_button: Button
var draw_mountains_button: Button
var draw_button: Button

var current_mode = "none"

func _enter_tree():
	set_input_event_forwarding_always_enabled()
	dock_panel = PanelContainer.new()
	dock_panel.name = "Editor Plugin"
	var vbox = VBoxContainer.new()
	dock_panel.add_child(vbox)

	draw_button = Button.new()
	draw_button.text = "Draw Land Parcel"
	draw_button.connect("pressed", _on_draw_button_pressed)
	vbox.add_child(draw_button)

	# Initialize and setup trees and mountains buttons
	draw_trees_button = Button.new()
	draw_trees_button.text = "Draw Trees"
	draw_trees_button.connect("pressed", _on_draw_trees_button_pressed)
	vbox.add_child(draw_trees_button)

	draw_mountains_button = Button.new()
	draw_mountains_button.text = "Draw Mountains"
	draw_mountains_button.connect("pressed", _on_draw_mountains_button_pressed)
	vbox.add_child(draw_mountains_button)

	var dock_name = "LandParcelDock"
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL, dock_panel)
	dock_panel.show()

	land_plugin = land_plugin_script.new()
	trees_plugin = trees_plugin_script.new()
	mountains_plugin = mountains_plugin_script.new()
	add_custom_type("LandParcel", "Node2D", land_plugin.land_parcel_scene, preload("res://icon.svg"))
	add_custom_type("Trees", "Node2D", trees_plugin.tree_scene, preload("res://icon.svg"))
	add_custom_type("Mountains", "Node2D", mountains_plugin.mountain_scene, preload("res://icon.svg"))

func _exit_tree():
	remove_custom_type("LandParcel")
	if dock_panel:
		remove_control_from_docks(dock_panel)
		dock_panel.queue_free()

func _on_draw_button_pressed():
	current_mode = "land"
	land_plugin.handle_draw_button(draw_button)

func _on_draw_trees_button_pressed():
	current_mode = "trees"
	trees_plugin.handle_draw_button(draw_trees_button)

func _on_draw_mountains_button_pressed():
	current_mode = "mountains"
	mountains_plugin.handle_draw_button(draw_mountains_button)

func _handles(object):
	return true

func _forward_canvas_gui_input(event) -> bool:
	match current_mode:
		"land":
			return land_plugin.forward_canvas_gui_input(event)
		"trees":
			return trees_plugin.forward_canvas_gui_input(event)
		"mountains":
			return mountains_plugin.forward_canvas_gui_input(event)
		_:
			return false
