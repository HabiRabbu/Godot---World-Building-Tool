extends EditorPlugin

# Function to generate a quadratic bezier curve point.
# t: The interpolation factor [0, 1]
# p0, p1, p2: The points defining the bezier curve (start, control, end)
func bezier_point(t, p0, p1, p2):
	return (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2

# Function to create rounded corners for a polygon.
func create_rounded_polygon(polygon, smoothness, corner_radius):
	corner_radius = adjust_corner_radius(polygon, corner_radius)
	var new_polygon = PackedVector2Array()
	var n = polygon.size()

	for i in range(n):
		var prev_index = (i - 1 + n) % n
		var next_index = (i + 1) % n

		var p0 = polygon[prev_index]
		var p1 = polygon[i] # Corner point
		var p2 = polygon[next_index]

		# Calculate vectors from the corner to the previous and next points
		var to_prev = (p0 - p1).normalized() * corner_radius
		var to_next = (p2 - p1).normalized() * corner_radius

		# Calculate the start and end points for the curve around the corner
		var curve_start = p1 + to_prev
		var curve_end = p1 + to_next

		# For a simple quadratic bezier curve, the control point can be the corner itself
		# For more sophisticated rounding, this might need adjustment

		# Only generate bezier points between curve_start and curve_end
		for j in range(1, smoothness):
			var t = j / float(smoothness)
			var bezier_point = bezier_point(t, curve_start, p1, curve_end)
			new_polygon.append(bezier_point)

	return new_polygon

func adjust_corner_radius(polygon, desired_radius):
	var min_edge_length = INF
	var n = polygon.size()
	for i in range(n):
		var edge_length = polygon[i].distance_to(polygon[(i + 1) % n])
		min_edge_length = min(min_edge_length, edge_length)

	# Assume the maximum allowable radius is half the shortest edge length
	return min(desired_radius, min_edge_length * 0.5)
