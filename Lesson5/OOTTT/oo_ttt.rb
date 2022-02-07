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
require_relative 'oo_ttt_display.rb'

module GameIO
  def prompt(message)
    puts "=> #{message}"
  end

  def clear
    system 'clear'
  end

  def enter_to_continue
    prompt "Press Enter to continue."
    gets
  end
end

module Stringable
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
  def marker_count(marker)
    squares.count { |_, sqr| sqr.marker == marker }
  end

  def actions
    unmarked_keys
  end

  def utility
    # Returns 1 if human has won, -1 if computer has won, 0 if it's a draw
    return nil unless terminal?
    case winning_marker
    when human_marker then 1
    when computer_marker then -1
    else 0
    end
  end

  def result(action, first_to_move)
    next_player = next_player(first_to_move)
    board_copy = Marshal.load(Marshal.dump(self))
    board_copy[action] = next_player
    board_copy
  end

  # Returns player who has the next turn on the board
  def next_player(first_to_move)
    human_marker_ct = marker_count(human_marker)
    computer_marker_ct = marker_count(computer_marker)
    if human_marker_ct == computer_marker_ct
      first_to_move
    elsif human_marker_ct > computer_marker_ct
      computer_marker
    else
      human_marker
    end
  end

  def max_value(mm_board, first_to_move)
    v = -Float::INFINITY
    return mm_board.utility if mm_board.terminal?
    mm_board.actions.each do |action|
      resulting_board = mm_board.result(action, first_to_move)
      v = [v, min_value(resulting_board, first_to_move)].max
    end
    v
  end

  def min_value(mm_board, first_to_move)
    v = Float::INFINITY
    return mm_board.utility if mm_board.terminal?
    mm_board.actions.each do |action|
      resulting_board = mm_board.result(action, first_to_move)
      v = [v, max_value(resulting_board, first_to_move)].min
    end
    v
  end

  def minimax(first_to_move)
    # Computer is minimizing player
    best_action = nil
    best_value = Float::INFINITY
    actions.each do |action|
      resulting_board = result(action, first_to_move)
      min_val = max_value(resulting_board, first_to_move)
      if min_val < best_value
        best_value = min_val
        best_action = action
      end
    end
    best_action
  end
end

class Board
  include Minimax
  attr_accessor :squares, :human_marker, :computer_marker, :first_to_move

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    @human_marker = nil
    @computer_marker = nil
    @first_to_move = nil
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
        return line.select { |sqr| @squares[sqr].unmarked? }.first
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

  def tutorial
    (1..9).each { |key| @squares[key] = Square.new(key.to_s) }
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    # binding.pry
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
  # rubocop:enable Metrics/MethodLength

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
  attr_reader :board

  def initialize(board)
    @board = board
  end

  def mark_square!(square)
    # binding.pry
    board[square] = marker
  end

  def to_s
    name
  end
end

class Human < Player
  include Stringable
  include GameIO

  def initialize(board)
    super
    @name = ask_player_name
    @marker = ask_player_marker
  end

  def move
    prompt "Choose a square (#{joinor(board.unmarked_keys)}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    mark_square!(square)
  end

  def ask_player_name
    prompt "What's your name?"
    player_name = nil
    loop do
      player_name = gets.chomp
      break unless player_name.delete(' ').empty?
    end
    player_name
  end

  def ask_player_marker
    marker = nil
    loop do
      prompt "What marker would you like to use?"
      marker = gets.chomp
      break if valid_marker?(marker)
      puts "Sorry, that's not a valid marker."
    end
    marker
  end

  def valid_marker?(marker)
    marker.length == 1 && marker != Computer::COMPUTER_MARKER && marker != ' '
  end
end

class Computer < Player
  COMPUTER_MARKER = "O"
  COMPUTER_NAMES = ["Hal", "Colossus", "Ultron", "Skynet", "The Borg"]

  def initialize(board)
    super
    @name = COMPUTER_NAMES.sample
    @marker = COMPUTER_MARKER
  end

  def move(logic = :minimax)
    puts "#{name} is thinking..."
    mark_square!(good_next_move(logic))
    sleep(0.5)
  end

  def good_next_move(logic = :minimax)
    if logic == :minimax
      minimax_move
    else
      heuristic_move
    end
  end

  def minimax_move
    if board.empty?
      1
    else
      board.minimax(board.first_to_move)
    end
  end

  def heuristic_move
    if board.immediate_opportunity?
      board.at_risk_square(marker)
    elsif board.immediate_threat?
      board.at_risk_square(board.human_marker)
    elsif board.middle_square_open?
      5
    else
      board.unmarked_keys.sample
    end
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
  include GameIO

  def initialize
    @board = Board.new
    display_welcome_message
    @human = Human.new(board)
    @computer = Computer.new(board)
    @score = Score.new
    board.set_player_markers(human.marker, computer.marker)
    @first_to_move = ask_first_to_move
    board.first_to_move = @first_to_move
    @current_marker = first_to_move
  end

  def play
    clear
    setup_game
    display_tutorial
    main_game
    display_goodbye_message
  end

  private

  attr_reader :board, :human, :computer, :score, :first_to_move

  def setup_game
    # human.ask_player_name
    # @computer.name = COMPUTER_NAMES.sample
    # human.ask_player_marker
    # @computer.marker = COMPUTER_MARKER
    # @board.set_player_markers(human.marker, computer.marker)
    # @first_to_move = ask_first_to_move
    # @current_marker = @first_to_move
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

  def player_move
    loop do
      current_player_moves
      break if board.terminal?
      clear_screen_and_display_board
    end
  end

  def human_turn?
    @current_marker == human.marker
  end

  def current_player_moves
    if human_turn?
      human.move
      @current_marker = computer.marker
    else
      # computer_moves
      computer.move
      @current_marker = human.marker
    end
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
    welcome = Phrase.new('welcome', 0.75)
    to = Phrase.new('to', 0.75)
    tic = Phrase.new('tic ___ ___', 0.4)
    tictac = Phrase.new('tic tac ___', 0.4)
    tictactoe = Phrase.new('tic tac toe', 0.4)
    full_message = [welcome, to, tic, tictac, tictactoe]
    display_phrases(full_message)
    puts
    enter_to_continue
    clear
  end

  def display_phrases(phrases)
    phrases.each do |phrase|
      clear
      phrase.display_center
    end
  end

  def display_tutorial
    clear
    puts "Game Squares:"
    display_tutorial_board
    puts <<-MSG
    Players take turns marking a square. 
    The first player to mark 3 squares in a row wins the match.
    The first player to win 5 matches wins the game.
    To mark a square, enter the number of the square you'd like to mark.
    MSG
    enter_to_continue
  end

  def display_tutorial_board
    tut_board = Board.new
    tut_board.tutorial
    tut_board.draw
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

  def ask_first_to_move
    puts "Who is first to move? (H)uman, (C)omputer, or (R)andom?"
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if ["h", "human", "c", "computer", "r", "random"].include?(answer)
      puts "Sorry, that's not a valid choice."
    end
    convert_answer_to_marker(answer)
  end

  def convert_answer_to_marker(answer)
    case answer
    when 'c', 'computer' then computer.marker
    when 'h', 'human' then human.marker
    when 'r', 'random' then [computer.marker, human.marker].sample
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