extends Node2D

class_name SnakeWorld

var applePosition = Vector2(-1, -1)
var player : Player
var apple : Sprite
var gameOver = false
var rng : RandomNumberGenerator
var appleScene
var score : int
var requirePass = 15
var isPass = false

#signal tog_up
#signal tog_down
#signal tog_left
#signal tog_right

# Called when the node enters the scene tree for the first time.
func _ready():
	$stillalive.play()
	$StartGame.text = "Press any arrow key on keyboard or monitor to start the game!\n"+"pass if you get "+ str(requirePass)
	# Spawn first snake block
	var p = preload("res://Player.tscn")
	player = p.instance()
	add_child(player)
	player.connect("apple_eaten",self,"on_apple_eaten")
	player.connect("player_collided",self,"on_player_collided")
	
	#player.connect("tog_up", self, "on_tog_up")
	#player.connect("tog_down",self,"on_tog_down")
	#player.connect("tog_left",self,"on_tog_left")
	#player.connect("tog_right",self,"on_tog_right")
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	appleScene = preload("res://Apple.tscn")
	
	restart_game()
	#end

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (not gameOver) and $StartGame.visible and player.didMove:
		$StartGame.hide()
	elif gameOver and Input.is_action_pressed("ui_accept"):
		restart_game()
	elif not gameOver:
		if applePosition == Vector2(-1, -1):
			# Spawn apple
			var legitPosition = false
			while not legitPosition:
				var x = rng.randi_range(1, 17)
				var y = rng.randi_range(1, 10)
				applePosition = Vector2(x * player.step, y * player.step)
				legitPosition = not player.is_player_at(applePosition)
			
			apple = appleScene.instance()
			add_child(apple)
			apple.position = applePosition

func on_player_collided():
	player.canMove = false
	gameOver = true
	if score >= requirePass :
		isPass = true
	$GameOver.show()
	$Restart.show()
	
	if isPass :
		$Passed.show()
	else:
		$Failed.show()

func on_apple_eaten():
	update_score(score+1)
	$du.play()
	apple.free()
	applePosition = Vector2(-1, -1)

func restart_game() -> void:
	update_score(0)
	isPass = false
	$GameOver.hide()
	$Restart.hide()
	$Failed.hide()
	$Passed.hide()
	$StartGame.show()
	if not apple == null:
		apple.free()
	applePosition = Vector2(-1, -1)
	player.set_grid_position(Vector2(1, 1))
	player.reset()
	gameOver = false
	player.canMove = true

func update_score(var newScore : int) -> void:
	score = newScore
	$Score.text = score as String


#func _on_up_toggled(button_pressed):
	#emit_signal("tog_up")


#func _on_down_toggled(button_pressed):
	#emit_signal("tog_down")


#func _on_left_toggled(button_pressed):
	#emit_signal("tog_left")


#func _on_right_toggled(button_pressed):
	#emit_signal("tog_right")

func _on_Restart_pressed():
	restart_game()
