extends Node2D

@export_range(0, 10000, 100) var speed = 5000

var dragging = false
var drag_origin = Vector2.ZERO

func _physics_process(delta):
	HandleWASDMovement(delta)
	HandleEdgeMovement(delta)

func _input(event):
	HandleMouseDrag(event)
	HandleMouseZoom(event)

func HandleEdgeMovement(delta):
	#Handle Edge of Screen Movement
	var viewport_rect = get_viewport_rect()
	var mouse_pos = get_viewport().get_mouse_position()

	var edge_threshold = 25  # Pixels from the edge to start moving

	if mouse_pos.x < edge_threshold:
		position.x -= speed * delta
	if mouse_pos.x > viewport_rect.size.x - edge_threshold:
		position.x += speed * delta
	if mouse_pos.y < edge_threshold:
		position.y -= speed * delta
	if mouse_pos.y > viewport_rect.size.y - edge_threshold:
		position.y += speed * delta

func HandleWASDMovement(delta):
	var movement = Vector2.ZERO

	if Input.is_action_pressed("ui_up"):
		movement.y -= 1
	if Input.is_action_pressed("ui_down"):
		movement.y += 1
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_right"):
		movement.x += 1

	movement = movement.normalized() * speed
	position += movement * delta

func HandleMouseDrag(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dragging = true
			drag_origin = get_global_mouse_position()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			dragging = false

	elif event is InputEventMouseMotion and dragging:
		var drag_current = get_global_mouse_position()
		var drag_difference = drag_origin - drag_current
		position += drag_difference
		drag_origin = drag_current  # Update the origin for smooth dragging

func HandleMouseZoom(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			$Camera2D_PlayerCamera.zoom *= Vector2(1.1, 1.1)  # Zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			$Camera2D_PlayerCamera.zoom *= Vector2(0.9, 0.9)  # Zoom out
