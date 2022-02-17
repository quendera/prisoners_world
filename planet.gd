extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var version = "v0.01"

var old_pos
var travel_y = 90
var travel_x = 45
var nodes_dict = {"Blue": "Good", "Red": "Bad", "Green": "Match", "Yellow": "Anti-Match", "Purple1": "Random1", "Purple2": "Random2"}

# Define parameters for each agent #TODO: move globally
var good_prob = 0.3
var params = {'Good':[good_prob,good_prob,good_prob], 'Bad':[1-good_prob,1-good_prob,1-good_prob], 
'Match':[0.8,0.2,0.5], 'Anti-Match':[0.2,0.8,0.5], 'Random1':[0.5,0.5,0.5], 'Random2':[0.5,0.5,0.5]}

var last_choice_region = {'Good':NAN, 'Bad':NAN, 'Match':NAN, 'Anti-Match':NAN, 'Random1':NAN, 'Random2':NAN}
var current_node

var state = 0  #play or move
#var position = get_region()
var can_move = true
var can_act = true

var data = {}
var ID
var save_file_name

var rng = RandomNumberGenerator.new()

func draw_n(n):
	var draw = []
	for i in range(n):
		rng.randomize()
		var d = rng.randf()
		draw.append(d)
		#print("Prob:", d)
	return(draw)
	
static func array_sum(array):
	var sum = 0.0
	for element in array:
		 sum += element
	return sum
	
func determine_reward():
	return
	
func get_agent_choices(randnums, prob):
	var agent_choices = []
	for rn in randnums:
		if rn < prob:
			agent_choices.append(0)
		else:
			agent_choices.append(1)
	#print("ACs:", agent_choices)
	return(agent_choices)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.window_fullscreen = true
	init_file()
	question()
	


func question():
	state = 0
	#print("question")
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
	
	$Text/total_score.push_color(Color(0,0,0,1))
	$Text/total_score.add_text("Total score: 0")
	$Text/current_score.push_color(Color(0,0,0,1))
	$Text/current_score.add_text("Score: 0")
	

func play(ID):
	can_act = true
	#store A/M choice, chose ACTION
	save_data(0,  get_region(), 0, -1) #choice, pos, rew, agent_choice
	#print("play")
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
	
	yield(get_tree().create_timer(.3), "timeout")
	state = 2
	var choice = 0
	while not (Input.is_key_pressed(KEY_C) or Input.is_key_pressed(KEY_D)):
		yield(get_tree().create_timer(.01), "timeout")
	
	yield(get_tree().create_timer(.3), "timeout")
	
	$Text/action.visible = false
	$Text/Coop.visible = false
	$Text/Defect.visible = false
	$Text/Choice.visible = true
	$Text/actionchoice.visible = true
	$Text/movechoice.visible = true
	state = 0
	can_act = false
	
	
	
func sample_actions(current_location, previous_choice, choice, agent_number):
	#function that samples the actions/choices of artificial agents
	
	# Draw choice of the agent(s) from probabilities of corresponding location
	var draw = 0
	var prob_def = 0
	var agent_choices = []
	for i in range(agent_number):
		agent_choices.append(0)  
	
	# Starting trial
	if previous_choice == NAN:
		prob_def = params[current_location][2] # Defect init
		draw = draw_n(agent_number)
			
		agent_choices =  get_agent_choices(draw, prob_def)

	# After cooperation
	elif previous_choice == 1:
		prob_def = params[current_location][1]  # Gamma2
		draw = draw_n(agent_number)

		agent_choices =  get_agent_choices(draw, prob_def)

	# After defection
	elif previous_choice == 0:
		prob_def = params[current_location][0] # Gamma1    
		draw = draw_n(agent_number)

		agent_choices =  get_agent_choices(draw, prob_def)


	# Calculate score of game
	var scores = []
	
	for ac in agent_choices:
		if (ac==choice) and (ac==1):
			scores.append(3) #7
		elif ac!=choice and (ac==0):
			scores.append(-2)
		elif ac==choice and (ac==0):
			scores.append(-4)
		elif ac!=choice and (ac==1):
			scores.append(6) #10
		#print("AC", ac, "Score:", scores[-1])

	var score_total = array_sum(scores)
	#print(score_total)
	return [score_total, agent_choices]
	
func move(ID):
	#store A/M choice, chose MOVE
	save_data(1,  get_region(), 0, -1) #choice, pos, rew, agent_choice
	state = 1
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
	
	$Text/agents.add_text("")
	
	yield(get_tree().create_timer(.1), "timeout")
	var keyup = Input.is_key_pressed(KEY_UP)
	var keydown = Input.is_key_pressed(KEY_DOWN)
	var keyl = Input.is_key_pressed(KEY_LEFT)
	var keyr = Input.is_key_pressed(KEY_RIGHT)
	while not (keyup or keydown or keyl or keyr):
		keyup = Input.is_key_pressed(KEY_UP)
		keydown = Input.is_key_pressed(KEY_DOWN)
		keyl = Input.is_key_pressed(KEY_LEFT)
		keyr = Input.is_key_pressed(KEY_RIGHT)
		yield(get_tree().create_timer(.01), "timeout")
	var position = get_region()

	save_data(-1, position, 0, -1) #store choice as well?
	state = 0
	yield(get_tree().create_timer(.1), "timeout")
	
	$Text/Move.visible = false
	$question_arrows/ArrowUp.visible = false
	$question_arrows/ArrowDown.visible = false
	$Text/action.visible = false
	$Text/Choice.visible = true
	$Text/movechoice.visible = true
	$Text/actionchoice.visible = true
	$question_arrows/KeyC.visible = true
	$question_arrows/KeyD.visible = true
	
	$Text/current_score.push_color(Color(0,0,0,1))
	$Text/total_score.push_color(Color(0,0,0,1))
	



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
	return(current_node)

func _input(event):
	#print(event, state)
	old_pos = $planet.get_rotation_degrees()
	$Text/current_score.push_color(Color(0,0,0,1))
	$Text/total_score.push_color(Color(0,0,0,1))
	#print(get_region())
	if event is InputEventKey and Input.is_key_pressed(KEY_0):
		#print("save")
		end_task()
	
	if (event is InputEventKey) and (state == 0): #QUESTIONS
		#$question_arrows.visible = false
		ID = OS.get_ticks_msec()
		if event.scancode == KEY_C:
			state = 3
			yield(get_tree().create_timer(.3), "timeout")
			play(ID)
		elif event.scancode == KEY_D:
			state = 3
			yield(get_tree().create_timer(.1), "timeout")
			move(ID)

			
			
	if (can_move) and (event is InputEventKey) and (state == 1): #MOVEMENT
		#get_region()
		can_move = false
		var nsteps = 25
		if Input.is_key_pressed(KEY_RIGHT):
			#$planet.set_rotation_degrees(Vector3(old_pos.x,old_pos.y + travel_y,old_pos.z))
			for _i in range(nsteps):
				$planet.rotate_y((PI/(nsteps*2))*-1)
				yield(get_tree().create_timer(1.0/500), "timeout")
	
		elif Input.is_key_pressed(KEY_LEFT):
			for _i in range(nsteps):
				$planet.rotate_y(PI/(nsteps*2))
				yield(get_tree().create_timer(1.0/500), "timeout")
	
		elif Input.is_key_pressed(KEY_UP):
			for _i in range(nsteps):
				$planet.rotate_x((PI/(nsteps*2))*-1)
				yield(get_tree().create_timer(1.0/500), "timeout")
	
		elif Input.is_key_pressed(KEY_DOWN):
			for _i in range(nsteps):
				$planet.rotate_x(PI/(nsteps*2))
				yield(get_tree().create_timer(1.0/500), "timeout")
		can_move = true
		
	
	if (can_act) and (event is InputEventKey) and (state == 2): #ACTION
		can_act = false
		var choice = 0
		if Input.is_key_pressed(KEY_C):
			choice = 0
		elif Input.is_key_pressed(KEY_D):
			choice = 1
		else: 
			yield(get_tree().create_timer(.1), "timeout")
		yield(get_tree().create_timer(.3), "timeout")
		var value = 0
		var position = get_region()
		value  = sample_actions(position, last_choice_region[position], choice, 5)
		var reward = value[0] 
		var agent_choices = value[1]
		var ncoop = array_sum(agent_choices)
		$Text/agents.text = "Opponent actions:\n" + " Number of cooperators: " + str(ncoop) + "\n" + " Number of defectors: " + str(5-ncoop)
		#how to change color accordingly?
		#var color = Color(position)
		#$Text/agents.push_color(color)
		$Text/total_score.text = "Total score:" + str(data['total_score'][-1]+reward)
		#$Text/current_score.push_color(Color(0,0,0,1))
		$Text/current_score.text = "Score:" + str(reward)
		
		#print(choice+2)
		save_data(choice+2, position, reward, agent_choices)
		last_choice_region[position] = choice
		can_act = true

func init_file():
	ID = OS.get_unix_time()
	save_file_name = "data_" + str(ID)
	
	#build data dict
	data = {
		#trial data
		"trial":[],
		"decision_time":[],
		"choice":[],
		"position":[],
		"score":[],
		"total_score":[],
		"expected_score":[],
		"agent_choices":[],
		#"rt1":[],
		#"rt2":[],
		
		#session metadata
		"subj_id":[],
		"starting_location":[],
		"version":[1.0],
		"start_time":[ID]
	}


# CALL THIS TO ADD A ROW TO YOUR DATA
func save_data(choice, position, reward, agent_choices):
	ID = OS.get_ticks_msec()
	if len(data["trial"])>0:
		data["trial"].push_back(data["trial"][-1]+1)
		data['total_score'].push_back(data['total_score'][-1]+reward)
	else:
		data["trial"].push_back(0)
		data['total_score'].push_back(reward)
	data["decision_time"].push_back(ID)
	data["choice"].push_back(choice)
	data["position"].push_back(position)
	data["score"].push_back(reward)
	data["agent_choices"].push_back(agent_choices)
	
	var file = File.new()
	file.open(str("res://Data/PrisonersWorld_", save_file_name, ".json"), file.WRITE)
	file.store_string(to_json(data))
	file.close()


# CALL THIS TO END THE TASK
func end_task():
	#print("saving..")
	var file = File.new()
	file.open(str("ser://PrisonersWorld_", save_file_name, ".json"), file.WRITE)
	file.store_line(to_json(data))
	file.close()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


