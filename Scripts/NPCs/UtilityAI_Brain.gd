extends Node2D
class_name UtilityAI_Brain

var behaviors = []

func _ready():
	# Load and instantiate behavior scripts
	var eating_behavior = preload("res://EatingBehavior.gd").new()
	var sleeping_behavior = preload("res://SleepingBehavior.gd").new()
	behaviors.append(eating_behavior)
	behaviors.append(sleeping_behavior)


func evaluate_behaviors():
	# Evaluate and execute the best behavior
