# TTTGame
- State: @board, @score, @human, @computer, @first_to_move, @current_marker
- Interface: play
- Collaborators: Board, Player, Score

# Board
- State:
- Interface: set_player_markers, terminal?, actions, unmarked_keys, 
- Collaborators:
 

# Square
- State: @marker
- Interface: to_s, marked? unmarked?
- Collaborators:


# Player
- State: @marker, @name
- Interface: marker, marker=, name, name=
- Collaborators: Board

# Computer
- State: @marker, @name, @difficulty
- Interface: move!, difficulty, difficulty=
- Collaborators: Board

# Human
- State: @marker, @name
- Interface: move!, 
- Collaborators: Board

# Score
- State: human, computer
- Interface: player_won_game, overall_winner?, game_overall_winner, 
- Collaborators:


|1|2|3|
|4|5|6|
|7|8|9|
