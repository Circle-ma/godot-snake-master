extends KinematicBody2D

class_name Player

var tick = 0.35
var step = 50
var timeToNextTick
var currentMovement = Vector2(0, 0)
var lastMovement = Vector2(0, 0)
var grow = false

var tailScene

var tail = [] # Array of tail Sprites

signal player_collided
signal apple_eaten
var canMove = false
var didMove = false

# Called when the node enters the scene tree for the first time.
func _ready():
	tailScene = preload("res://Tail.tscn")
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not canMove:
		return
	
	# Get inputs
	var right = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	
	if (not didMove) and (right or left or up or down):
		didMove = true
	elif not didMove:
		return
	
	# Set proper movement vector
	var changeDirection = false
	
	if (right) and (tail.size() == 0 or lastMovement != Vector2(-step, 0)):
		currentMovement = Vector2(step, 0)
	elif (left) and (tail.size() == 0 or lastMovement != Vector2(step, 0)):
		currentMovement = Vector2(-step, 0)
	elif (up) and (tail.size() == 0 or lastMovement != Vector2(0, step)):
		currentMovement = Vector2(0, -step)
	elif (down) and (tail.size() == 0 or lastMovement !=  Vector2(0, -step)):
		currentMovement = Vector2(0, step)
	
	if currentMovement != lastMovement:
		changeDirection = true
	
	# only move when ready
	timeToNextTick -= delta
	
	if timeToNextTick > 0 and not changeDirection: return
	else: timeToNextTick = tick
	
	# Collision detection
	collision_layer = 2
	collision_mask = 2
	if test_move(transform, currentMovement):
		emit_signal("apple_eaten")
		grow = true
	
	collision_layer = 1
	collision_mask = 1
	
	if test_move(transform, currentMovement):
		emit_signal("player_collided")
		return
	
	# Movement
	var nextPosition = position
	position = position + currentMovement
	lastMovement = currentMovement
	
	# Move tail
	var tailObject : Tail
	var tailMover : KinematicBody2D
	if grow:
		tick -= 0.01
		tailObject = tailScene.instance() as Tail
		add_child(tailObject)
		tailMover = tailObject.TailMover
		grow = false
	elif tail.size() > 0:
		tailObject = tail[tail.size()-1]
		tail.remove(tail.size()-1)
		tailMover = tailObject.TailMover
	
	if tailMover != null:
		tailMover.position = nextPosition
		tail.insert(0, tailObject)

func eat_apple() -> void:
	grow = true

func is_player_at(var gridPos : Vector2) -> bool:
	if position == gridPos:
		return true
	
	for p in tail:
		var tailSprite : Tail
		tailSprite = p
		if tailSprite.TailMover.position == gridPos:
			return true
	
	return false

func set_grid_position(var gridPos : Vector2) -> bool:
	position = step * gridPos
	return true

func reset() -> void:
	while tail.size() > 0:
		var t = tail.pop_back() as Tail
		t.free()
	
	tick = 0.35
	lastMovement = Vector2(0, 0)
	currentMovement = Vector2(0, 0)
	grow = false
	timeToNextTick = tick
	didMove = false


func _on_up_pressed():
	"""if not didMove:
		didMove = true"""
	if (tail.size() == 0 or lastMovement != Vector2(0, step)):
		currentMovement = Vector2(0, -step)
	
	
func _on_down_pressed():
	if not didMove:
		didMove = true
	if (tail.size() == 0 or lastMovement != Vector2(0,-step)):
		currentMovement = Vector2(0, step)
	

func _on_left_pressed():
	
	if (tail.size() == 0 or lastMovement != Vector2(step,0)):
		currentMovement = Vector2(-step, 0)
	
	
func _on_right_pressed():
	if not didMove:
		didMove = true
	if (tail.size() == 0 or lastMovement != Vector2(-step, 0)):
		currentMovement = Vector2(step, 0)
	



