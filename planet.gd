extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var version = "v0.01"

var old_pos
var travel_y = 90
var travel_x = 45
var nodes_dict = {"Blue": "G", "Red": "B", "Green": "M", "Yellow": "O"}

var current_node

var state = 0  #play or move

var can_move = true

var data = {}
var ID
var save_file_name

# Called when the node enters the scene tree for the first time.
func _ready():
	init_file()
	question()

func question():
	state = 0
	print("question")
	$question_arrows.visible = true
	$Text/Choice.visible = true
	$Text/action.visible = false
	$Text/Move.visible = false
	$Text/Coop.visible = false
	$Text/Defect.visible = false
	$question_arrows/ArrowUp.visible = false
	$question_arrows/ArrowDown.visible = false
	
	$question_arrows/KeyC.visible = true
	$question_arrows/KeyD.visible = true
	
	
	

func play():
	state = 2
	print("play")
	$Text/action.visible = true
	$Text/Choice.visible = false
	$Text/movechoice.visible = false
	$Text/actionchoice.visible = false
	
	#let player take action
	$Text/Coop.visible = true
	$Text/Defect.visible = true
	$question_arrows/ArrowUp.visible = false
	$question_arrows/ArrowDown.visible = false
	$question_arrows/KeyC.visible = true
	$question_arrows/KeyD.visible = true
	
	yield(get_tree().create_timer(1.0), "timeout")
	$Text/action.visible = false
	$Text/Coop.visible = false
	$Text/Defect.visible = false
	$Text/Choice.visible = true
	$question_arrows/ArrowUp.visible = true
	$question_arrows/ArrowDown.visible = true
	$Text/movechoice.visible = true
	$Text/actionchoice.visible = true
	state = 0
	
func move():

	#current_node = 
	$question_arrows/KeyC.visible = false
	$question_arrows/KeyD.visible = false
	$Text/Move.visible = true
	$Text/Choice.visible = false
	$Text/movechoice.visible = false
	$Text/actionchoice.visible = false
	
	$question_arrows/ArrowLeft.visible = true
	$question_arrows/ArrowRight.visible = true
	$question_arrows/ArrowUp.visible = true
	$question_arrows/ArrowDown.visible = true
	
	yield(get_tree().create_timer(.2), "timeout")
	state = 1
	yield(get_tree().create_timer(1.0), "timeout")
	
	$Text/Move.visible = false
	$question_arrows/ArrowUp.visible = false
	$question_arrows/ArrowDown.visible = false
	$Text/action.visible = false
	$Text/Choice.visible = true
	$Text/movechoice.visible = true
	$Text/actionchoice.visible = true
	$question_arrows/KeyC.visible = true
	$question_arrows/KeyD.visible = true

	state = 0
	#print($planet.get_rotation())
	



func get_region():
	var node_positions = []
	var node_names = []
	for node in get_tree().get_nodes_in_group("nodes"):
		node_names.append(node.get_name())
		node_positions.append(node.get_global_transform().origin.z)
		#print(node)
	var min_pos = node_positions.min()
	var node_pos_in_arr = node_positions.find(min_pos)
	var closest_node_name = node_names[node_pos_in_arr]
	current_node = nodes_dict[closest_node_name]
	#print(current_node)
	return(current_node)

func _input(event):
	print(event, state)
	old_pos = $planet.get_rotation_degrees()
	
	if (event is InputEventKey) and (state == 0): #QUESTIONS
		#$question_arrows.visible = false
		if event.scancode == KEY_C:
			play()
		elif event.scancode == KEY_D:
			move()

			
			
	if (can_move) and (event is InputEventKey) and (state == 1): #MOVEMENT
		get_region()
		can_move = false
		if Input.is_key_pressed(KEY_RIGHT):
			#$planet.set_rotation_degrees(Vector3(old_pos.x,old_pos.y + travel_y,old_pos.z))
			for _i in range(100):
				$planet.rotate_y((PI/200)*-1)
				yield(get_tree().create_timer(1.0/100), "timeout")
	
		elif Input.is_key_pressed(KEY_LEFT):
			for _i in range(100):
				$planet.rotate_y(PI/200)
				yield(get_tree().create_timer(1.0/100), "timeout")
	
		elif Input.is_key_pressed(KEY_UP):
			for _i in range(100):
				$planet.rotate_x((PI/200)*-1)
				yield(get_tree().create_timer(1.0/100), "timeout")
	
		elif Input.is_key_pressed(KEY_DOWN):
			for _i in range(100):
				$planet.rotate_x(PI/200)
				yield(get_tree().create_timer(1.0/100), "timeout")
		can_move = true
		
		
	
			
			

func init_file():
	ID = OS.get_unix_time()
	save_file_name = str(ID)
	
	#build data dict
	data = {
		
		#trial data
		"trial":[],
		"trial_time":[],
		
		"choice":[],
		"position":[],
		"score":[],
		"rt1":[],
		"rt2":[],
		"other_stuff":[],
		#session metadata
		"subj_id":[],
		"version":[],
		"start_time":[]
		
		#add all variables you want to save here
		
	}
	


# CALL THIS TO ADD A ROW TO YOUR DATA
func save_data():
	data["trial"].push_back(ID)
	data["trial_time"].push_back(ID)
	data["choice"].push_back(ID)
	data["position"].push_back(ID)
	#add all variables you want to save here


# CALL THIS TO END THE TASK
func end_task():
	var file = File.new()
	file.open(str("user://PrisonersWorld_", save_file_name, ".json"), file.WRITE)
	file.store_line(to_json(data))
	file.close()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


