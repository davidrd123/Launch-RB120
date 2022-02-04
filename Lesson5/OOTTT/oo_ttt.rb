=begin

Tic Tac Toe is a 2-player board game played on a 3x3 grid. Players take turns
marking a square. The first player to mark 3 squares in a row wins.

Nouns: board, player, square, grid
Verbs: play, mark

Board
Square
Player
- mark
- play

=end
require 'pry'
require 'yaml'

module Displayable
  def prompt(message)
    puts "=> #{message}"
  end
  
  def clear
    system 'clear'
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    puts "#{human.name} is #{human.marker}. #{computer.name} is #{computer.marker}"
    puts ""
    board.draw
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    display_final_results
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def display_play_again_message
    prompt "Let's play again!"
    prompt ""
  end

  def display_game_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
  end

  def display_final_results
    overall_winner = score.game_overall_winner
    case overall_winner
    when nil then puts "No overall winner"
    when :human then puts "Human is overall winner"
    when :computer then puts "Computer is overall winner"
    end
    display_scoreboard
  end

  def display_scoreboard
    puts "#{human.name}: #{score.human}"
    puts "#{computer.name}: #{score.computer}"
  end

  def ask_player_name(which_player)
    case which_player
    when :human then prompt "What's your name?"
    when :computer then prompt "What's the computer's name?"
    end
    player_name = nil
    loop do
      player_name = gets.chomp
      break unless player_name.empty?
    end
    player_name
  end

  def ask_player_marker(which_player)
    marker = nil
    loop do
      prompt "What marker would you like to use?"
      marker = gets.chomp
      break if valid_marker?(marker)
      prompt "Sorry, that's not a valid marker."
    end
    marker
  end

  def valid_marker?(marker)
    marker.length == 1 && marker != computer.marker
  end

  def play_again?
    answer = nil
    loop do
      prompt "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      prompt "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def joinor(array, delimiter=', ', final_word='or')
    case array.length
    when 0 then ''
    when 1 then array.first
    when 2 then array.join(" #{final_word} ")
    else
      array[0..-2].join(delimiter) + delimiter + "#{final_word} #{array.last}"
    end
  end
end

module Minimax
  # Returns player who has the next turn on the board
  def player(first_to_move)
    xo_count = {}
    xo_count[human_marker] = squares.values.count {|square| square.marker == human_marker}
    xo_count[computer_marker] = squares.values.count {|square| square.marker == computer_marker}
    # If there is parity of marker count, then the next player is the first_to_move
    if xo_count[human_marker] == xo_count[computer_marker]
      first_to_move
    else
      # Otherwise, the next player is the other marker
      first_to_move == human_marker ? computer_marker : human_marker
    end
  end

  def result(action, first_to_move)
    # action is the number of the square that was selected
    # first_to_move is the marker of the player who is to move next
    # Raise exception if the action is not valid
    # Returns a new board object if the action is valid
    unless unmarked_keys.include?(action)
      raise "Invalid action"
    end
    next_player = player(first_to_move)
    # If the action is valid, then create a new board object
    # and set the square at action to the next player's marker
    board_copy = Marshal.load(Marshal.dump(self))
    board_copy[action] = next_player
    board_copy
  end

  def utility
    # Returns 1 if X has won, -1 if O has won, 0 if it's a draw
    # Returns nil if the board is not terminal
    return nil unless terminal?
    case winning_marker
    when human_marker then 1
    when computer_marker then -1
    else 0
    end
  end

  def max_value(board, first_to_move)
    v = -Float::INFINITY
    return board.utility if board.terminal?
    board.actions.each do |action|
      resulting_board = board.result(action, first_to_move)
      v = [v, min_value(resulting_board, first_to_move)].max
    end
    v
  end

  def min_value(board, first_to_move)
    v = Float::INFINITY
    return board.utility if board.terminal?
    board.actions.each do |action|
      resulting_board = board.result(action, first_to_move)
      v = [v, max_value(resulting_board, first_to_move)].min
    end
    v
  end

  def minimax(first_to_move)
    best_action = nil
    best_value = Float::INFINITY
    actions.each do |action|
      resulting_board = result(action, first_to_move)
      if max_value(resulting_board, first_to_move) < best_value
        best_value = max_value(resulting_board, first_to_move)
        best_action = action
      end
    end
    best_action
  end

  def actions
    unmarked_keys
  end
end

class Board
  include Minimax
  attr_accessor :squares, :human_marker, :computer_marker

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize(human_marker='X', computer_marker='O')
    @squares = {}
    @human_marker = human_marker
    @computer_marker = computer_marker
    reset
  end

  def [](num)
    squares[num]
  end

  def []=(num, marker)
    squares[num].marker = marker
  end

  def set_player_markers(human, computer)
    self.human_marker = human
    self.computer_marker = computer
  end

  def terminal?
    # Returns true if the board is a terminal board
    # (i.e. someone has won or the board is full)
    # Otherwise, returns false
    someone_won? || full?
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def empty?
    @squares.values.all?(&:unmarked?)
  end

  def someone_won?
    !!winning_marker
  end

  def middle_square_open?
    unmarked_keys.include?(5)
  end

  # If there are two squares marked human.marker in a WINNING_LINE
  # and one empty square, return true
  def immediate_threat?
    !!at_risk_square(@human_marker)
  end

  def immediate_opportunity?
    !!at_risk_square(@computer_marker)
  end

  # Finds the location at risk for the player denoted by player_marker
  def at_risk_square(player_marker)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if two_marked_one_empty?(squares, player_marker)
        # Find location of empty square
        # binding.pry
        loc = squares.find_index { |square| square.marker == Square::INITIAL_MARKER}
        return line[loc]
      end
    end
    nil
  end

  # returns winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |     "
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}  "
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}  "
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}  "
    puts "     |     |     "
    puts ""
  end
  # rubocop:enable Metrics/AbcSize

  private

  # return the marker if three in a row, nil otherwise
  def three_identical_markers?(squares)
    markers = squares.filter(&:marked?).map(&:marker)
    markers.size == 3 && markers.uniq.size == 1
  end

  def two_marked_one_empty?(squares, player_marker)
    markers = squares.filter(&:marked?).map(&:marker)
    markers.size == 2 && markers.uniq.size == 1 && markers.first == player_marker
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    # maybe a "status" to keep track of this square's mark?
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_accessor :marker, :name

  def initialize(marker)
    # maybe a "marker" to keep track of this player's symbol (ie, 'X' or 'O')
    @marker = marker
    @name = nil
  end
end

class Score
  WINNING_SCORE = 5

  attr_accessor :computer, :human

  def initialize
    @computer = 0
    @human = 0
  end

  def overall_winner?
    # computer == WINNING_SCORE || human == WINNING_SCORE
    !!game_overall_winner
  end

  def game_overall_winner
    return :computer if computer == WINNING_SCORE
    return :human if human == WINNING_SCORE
    nil
  end

  def player_won_game(winner)
    case winner
    when :human then self.human += 1
    when :computer then self.computer += 1
    end
  end
end

class TTTGame
  include Displayable

  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  COMPUTER_NAMES = ["Hal", "Colossus", "Ultron", "Skynet", "The Borg"]

  attr_reader :board, :human, :computer, :score, :first_to_move

  def initialize
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @board = Board.new
    @score = Score.new
    @first_to_move = nil
    @current_marker = nil
    @human_name = nil
    @computer_name = nil
  end

  def play
    clear
    display_welcome_message
    setup_game
    main_game
    display_goodbye_message
  end

  private

  def setup_game
    @human.name = ask_player_name(:human)
    @computer.name = COMPUTER_NAMES.sample
    @human.marker = ask_player_marker(:human)
    @board.set_player_markers(@human.marker, @computer.marker)
    @first_to_move = ask_first_to_move
    @current_marker = @first_to_move
  end

  def main_game
    loop do
      clear
      display_board
      player_move
      display_game_result
      update_score
      display_scoreboard
      break if overall_winner? || !play_again?
      reset
      display_play_again_message
    end
  end

  def overall_winner?
    score.overall_winner?
  end

  def ask_first_to_move
    puts "Who is first to move? (H)uman, (C)omputer, or (R)andom?"
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if ["h", "human", "c", "computer", "r", "random"].include?(answer)
      puts "Sorry, that's not a valid choice."
    end
    case answer
    when 'c', 'computer' then computer.marker
    when 'h', 'human' then human.marker
    when 'r', 'random' then [computer.marker, human.marker].sample
    end
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board # if human_turn?
    end
  end

  def human_turn?
    @current_marker == @human.marker
  end



  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys)}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    human_places_piece!(square)
  end

  def computer_moves
    puts "#{@computer.name} is thinking..."
    if board.empty?
      good_next_move = 1
    else
      good_next_move = board.minimax(@first_to_move)
    end
    sleep(0.5)
    # if board.immediate_opportunity?
    #   good_next_move = board.at_risk_square(computer.marker)
    # elsif board.immediate_threat?
    #   good_next_move = board.at_risk_square(human.marker)
    # elsif board.middle_square_open?
    #   good_next_move = 5
    # else 
    #   good_next_move = board.unmarked_keys.sample
    # end
    computer_places_piece!(good_next_move)
  end

  def human_places_piece!(square)
    board[square] = human.marker
  end

  def computer_places_piece!(square)
    board[square] = computer.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = @computer.marker
    else
      computer_moves
      @current_marker = @human.marker
    end
  end

  def update_score
    case board.winning_marker
    when human.marker
      score.player_won_game(:human)
    when computer.marker
      score.player_won_game(:computer)
    end
  end

  def reset
    board.reset
    @current_marker = @first_to_move
    clear
  end
  
end

# we'll kick off the game like this
game = TTTGame.new
# game.board[1] = 'X'
# game.board[3] = 'O'
# game.board[5] = 'X'
# binding.pry
game.play



# binding.pry