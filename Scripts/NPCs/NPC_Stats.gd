extends Node2D


@export_range(0, 100) var health: int = 100
@export_range(0, 100) var hunger: int = 0 # Range from 0 (not hungry) to 100 (very hungry)
@export var first_name: String = "John"
@export var last_name: String = "Smith"
@export_range(0, 100) var age: int = 30
@export_range(0, 100) var energy: int = 100 # Range from 0 (exhausted) to 100 (fully rested)
@export_range(0, 100) var happiness: float = 75.0 # Range from 0 to 100

func _ready():
	print("NPC Stats for ", first_name, " ", last_name)
	print("Health: ", health, ", Hunger: ", hunger, ", Age: ", age, ", Energy: ", energy, ", Happiness: ", happiness)
