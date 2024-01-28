# MyEditorPlugin.gd
@tool
extends EditorPlugin

var land_plugin_script = preload("res://addons/editorPlugin/LandPlugin.gd")
var land_plugin
var dock_panel: PanelContainer
var draw_button: Button

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

	var dock_name = "LandParcelDock"
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL, dock_panel)
	dock_panel.show()

	land_plugin = land_plugin_script.new()
	add_custom_type("LandParcel", "Node2D", land_plugin.land_parcel_scene, preload("res://icon.svg"))

func _exit_tree():
	remove_custom_type("LandParcel")
	if dock_panel:
		remove_control_from_docks(dock_panel)
		dock_panel.queue_free()

func _on_draw_button_pressed():
	land_plugin.handle_draw_button(draw_button)

func _handles(object):
	return true

func _forward_canvas_gui_input(event) -> bool:
	return land_plugin.forward_canvas_gui_input(event)
