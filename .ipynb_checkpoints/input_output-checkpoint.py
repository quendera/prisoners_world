# Get input from user and display output

# Imports
from threading import Timer, Thread
import time
import pandas as pd
import random
import numpy as np
import os

# Parameters
n_trials = 10
max_time = 30
timeout = 10
number_agents = 5

# Functions to be used across trials

def choose(trial, max_time):
    
    # Prompt subject with question
    print(str('Trial ' + str(trial)))

    t = Timer(max_time, print, ['Sorry, times up']) 
    t.start()
    start = time.time()
    prompt = "Do you want to MOVE to a new location or PLAY? Press 'M' to move or 'P' to play. \n"
    answer = input(prompt)
    t.cancel()

    # Time response
    end = time.time()
    RT = end - start

    # Give warning if response was not one of the expected keys
    if answer not in ['M', 'm', 'P', 'p']:
        print("Invalid choice")
    # Binarize responses
    elif answer in ['M', 'm']:
        answer = 1
    elif answer in ['P', 'p']:
        answer = 0    

    return answer, RT

def play_dilemma(trial, max_time):
    # Prompt subject with question
    print(str('Trial ' + str(trial)))

    t = Timer(max_time, print, ['Sorry, times up']) 
    t.start()
    start = time.time()
    prompt = "Choose whether to COOPERATE (C) or DEFECT (D). You have %d seconds.\n" % max_time
    answer = input(prompt)
    t.cancel()

    # Time response
    end = time.time()
    RT = end - start

    # Give warning if response was not one of the expected keys
    if answer not in ['C', 'c', 'D', 'd']:
        print("Invalid choice")
    # Binarize responses
    elif answer in ['C', 'c']:
        answer = 1
    elif answer in ['D', 'd']:
        answer = 0    

    return answer, RT

def outcome(current_location, previous_choice, play, number_agents):

    # Define parameters for each agent
    params = pd.DataFrame(columns = ['Param', 'Good', 'Bad', 'Match', 'Anti-Match', 'Random1', 
        'Random2'], index = range(3))

    params['Param'][0] = 'Gamma1' # Gamma 1: P(D|D)
    params['Param'][1] = 'Gamma2' # Gamma 2: P(C|C)
    params['Param'][2] = 'Defect_init' # Starting probability of defecting
    
    params['Good'][0] = 0.2
    params['Good'][1] = 0.2
    params['Good'][2] = 0.2

    params['Bad'][0] = 0.8
    params['Bad'][1] = 0.8
    params['Bad'][2] = 0.8

    params['Match'][0] = 0.8
    params['Match'][1] = 0.2
    params['Match'][2] = 0.5

    params['Anti-Match'][0] = 0.2
    params['Anti-Match'][1] = 0.8
    params['Anti-Match'][2] = 0.5

    params['Random1'][0] = 0.5
    params['Random1'][1] = 0.5
    params['Random1'][2] = 0.5

    params['Random2'][0] = 0.5
    params['Random2'][1] = 0.5
    params['Random2'][2] = 0.5

    # Draw choice of the agent(s) from probabilities of corresponding location

    # Starting trial
    if previous_choice == np.nan:
        prob_def = params[current_location][2] # Defect init
        draw = np.random.uniform(0, 1, number_agents)

        agent_choice = draw.copy()
        agent_choice[agent_choice<prob_def] = 0 # defect
        agent_choice[agent_choice>=prob_def] = 1 # Cooperate

    # After cooperation
    elif previous_choice == 1:
        prob_def = params[current_location][1]  # Gamma2
        draw = np.random.uniform(0, 1, number_agents)

        agent_choice = draw.copy()
        agent_choice[agent_choice<prob_def] = 0 # defect
        agent_choice[agent_choice>=prob_def] = 1 # Cooperate

    # After defection
    elif previous_choice == 0:
        prob_def = params[current_location][0] # Gamma1    
        draw = np.random.uniform(0, 1, number_agents)

        agent_choice = draw.copy()
        agent_choice[agent_choice<prob_def] = 0 # defect
        agent_choice[agent_choice>=prob_def] = 1 # Cooperate


    # Calculate score of game
    scores = agent_choice.copy()
    
    coo_coo = (agent_choice==play) & (agent_choice==1) 
    coo_def = (agent_choice!=play) & (agent_choice==0) 
    def_def = (agent_choice==play) & (agent_choice==0) 
    def_coo = (agent_choice!=play) & (agent_choice==1) 

    scores[coo_coo] = 7
    scores[coo_def] = 0
    scores[def_def] = 0
    scores[def_coo] = 10

    score = np.sum(scores)

    return score, agent_choice

""" Data matrix with data to be saved on each trial 

- Trial number
- Choice_1: whether subject wants to move or play
- Move: to one of 4 locations
- RT_choice_1: choice taken to decide whether to move or to play
- RT_choice_2: time taken to choose defect or cooperate
- Current_location: same if play trial or new if move trial
- Score: score for the trial
"""

df = pd.DataFrame(columns=['Trial', 'Choice', 'RT_choice', 'Play', 'RT_play', 
    'Score', 'Current_location'], index=range(n_trials))

for trial in range(n_trials):

    df['Trial'][trial] = trial
    # Start by asking whether subject wants to move or play

    choice, choice_RT = choose(trial, max_time)
    
    # Save corresponding data
    df['Choice'][trial] = choice
    df['RT_choice'][trial] = choice_RT

    # Move location if MOVE (choice == 1)
    if choice == 1:
        ## TODO: UPDATE GUI CHANGING THE LOCATION OF THE SUBJECT
        ## TODO: SAVE INPUT OF MOVEMENT/NEW LOCATION
        # df['Current_location'][trial] = xxxxx
    
    # Play with oponents if PLAY (choice == 0)
    elif choice == 0:
        
        # Make a play
        play, play_RT = play_dilema(trial, max_time)
        # Save corresponding data
        df['Play'][trial] = play
        df['RT_play'][trial] = play_RT

        current_location = df['Current_location'][trial]
        if trial > 0:
            previous_choice = df['Play'][trial-1]
        else:
            previous_choice = np.nan

        # Determine outcome, display score and choices of artificial agents
        score, choices = outcome(current_location, previous_choice, play)

        # Save outcomes and display
        # TODO: save score and agents choices
        # TODO: print out score and agents choices

    # Impose 10-seconds delay for inter-trial-interval
    iti = Timer(timeout, print, [' '])
    iti.start()
    iti.cancel()








