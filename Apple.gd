extends Sprite

export(Array, Texture) var textures

# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	if textures.size() > 0:
		var index = rng.randi_range(0, textures.size()-1)
		texture = textures[index]
