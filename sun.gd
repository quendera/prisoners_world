extends DirectionalLight

# Called when the node enters the scene tree for the first time.
func _ready():
	#world_goes_round = true
	var seconds = 10*60
	for i in range(seconds):
		self.rotate_y(PI/float(seconds))
		yield(get_tree().create_timer(1), "timeout")
