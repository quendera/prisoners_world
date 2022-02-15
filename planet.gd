extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var old_pos
var travel_y = 90
var travel_x = 45
var nodes_dict = {"Blue": "G", "Red": "B", "Green": "M", "Yellow": "O"}

var current_node

var state = 0  #play or move



# Called when the node enters the scene tree for the first time.
func _ready():
	question()

func question():
	state = 0
	print("question")
	$question_arrows.visible = true
	
	

func play():
	state = 2
	print("play")
	
func move():
	state = 1
	#current_node = 
	print($planet.get_rotation())

func get_region():
	var node_positions = []
	var node_names = []
	for node in get_tree().get_nodes_in_group("nodes"):
		node_names.append(node.get_name())
		node_positions.append(node.get_global_transform().origin.z)
		print(node)
	var min_pos = node_positions.min()
	var node_pos_in_arr = node_positions.find(min_pos)
	var closest_node_name = node_names[node_pos_in_arr]
	current_node = nodes_dict[closest_node_name]
	print(current_node)
	return(current_node)

func _input(event):
	old_pos = $planet.get_rotation_degrees()
	
	if (event is InputEventKey) and (state == 0): #QUESTIONS
		$question_arrows.visible = false
		if event.scancode == KEY_RIGHT:
			play()
		elif event.scancode == KEY_LEFT:
			move()
			
	if (event is InputEventKey) and (state == 1): #MOVEMENT
		get_region()
		
		if Input.is_key_pressed(KEY_RIGHT):
			#$planet.set_rotation_degrees(Vector3(old_pos.x,old_pos.y + travel_y,old_pos.z))
			$planet.rotate_y(PI/2)
		elif Input.is_key_pressed(KEY_LEFT):
			$planet.rotate_y(PI/2)
		elif Input.is_key_pressed(KEY_UP):
			$planet.rotate_x(PI/2)
		elif Input.is_key_pressed(KEY_DOWN):
			$planet.rotate_x(PI/2)
		#question()
			
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


