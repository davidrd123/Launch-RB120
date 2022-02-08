require 'pry'
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

  def print_separator
    puts "-" * 20
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
  ALPHA = -1
  BETA = 1
  MAX_VALUE = 100
  MIN_VALUE = -100

  def max_value_ab(mm_board, alpha, beta)
    v = MIN_VALUE
    return mm_board.utility if mm_board.terminal?
    mm_board.actions.each do |action|
      resulting_board = mm_board.result(action)
      v = [v, min_value_ab(resulting_board, alpha, beta)].max
      return v if v >= beta
      alpha = [alpha, v].max
    end
    v
  end

  def min_value_ab(mm_board, alpha, beta)
    v = MAX_VALUE
    return mm_board.utility if mm_board.terminal?
    mm_board.actions.each do |action|
      resulting_board = mm_board.result(action)
      v = [v, max_value_ab(resulting_board, alpha, beta)].min
      return v if v <= alpha
      beta = [beta, v].min
    end
    v
  end

  def minimax_ab(mm_board)
    # Computer is minimizing player
    best_action = nil
    best_value = MAX_VALUE
    mm_board.actions.each do |action|
      max_val = max_value_ab(mm_board.result(action), ALPHA, BETA)
      if max_val < best_value
        best_value = max_val
        best_action = action
        # p "#{best_value} #{best_action}"
      end
    end
    best_action
  end
end

class Board
  attr_accessor :squares, :human_marker, :computer_marker, :first_to_move

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals
  CORNERS = [1, 3, 7, 9]

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

  def actions
    unmarked_keys
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def empty?
    @squares.values.all?(&:unmarked?)
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

  def result(action)
    board_copy = Marshal.load(Marshal.dump(self))
    board_copy[action] = next_player_marker
    board_copy
  end

  def someone_won?
    !!winning_marker
  end

  def middle_square_open?
    unmarked_keys.include?(5)
  end

  def immediate_threat?
    !!at_risk_square(human_marker)
  end

  def immediate_opportunity?
    !!at_risk_square(computer_marker)
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
      squares_in_line = @squares.values_at(*line)
      if three_identical_markers?(squares_in_line)
        return squares_in_line.first.marker
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
  # rubocop:disable Layout/LineLength
  def draw
    ref_board = (1..9).each_slice(3)
                      .map { |row| " " * 3 + "|" + row.join("|") + "|" }
    divider = " " * 3 + "--+-+--"
    padding = " " * 10
    puts padding + "     |     |     "
    puts padding + "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}  "
    puts padding + "     |     |     "
    puts padding + "-----+-----+-----"
    puts padding + "     |     |     "
    puts padding + "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}  "
    puts padding + "     |     |     " + ref_board[0]
    puts padding + "-----+-----+-----" + divider
    puts padding + "     |     |     " + ref_board[1]
    puts padding + "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}  " + divider
    puts padding + "     |     |     " + ref_board[2]
    puts ""
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Layout/LineLength

  private

  def full?
    unmarked_keys.empty?
  end

  # Returns player who has the next turn on the board
  def next_player_marker
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

  def marker_count(marker)
    squares.count { |_, sqr| sqr.marker == marker }
  end

  # return the marker if three in a row, nil otherwise
  def three_identical_markers?(squares)
    markers = squares.filter(&:marked?).map(&:marker)
    markers.size == 3 && markers.uniq.size == 1
  end

  def two_marked_one_empty?(squares, player_marker)
    markers = squares.filter(&:marked?).map(&:marker)
    markers.size == 2 && markers.uniq.size == 1 &&
      markers.first == player_marker
  end
end

class Square
  EMPTY_MARKER = ' '

  attr_accessor :marker

  def initialize(marker=EMPTY_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == EMPTY_MARKER
  end

  def marked?
    marker != EMPTY_MARKER
  end
end

class Player
  attr_accessor :marker, :name
  attr_reader :board

  def initialize(board)
    @board = board
  end

  def to_s
    name
  end

  private

  def mark_square!(square)
    board[square] = marker
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

  def move!
    prompt "Choose a square (#{joinor(board.unmarked_keys)}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    mark_square!(square)
  end

  private

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
  include Minimax
  COMPUTER_MARKER = "O"
  COMPUTER_NAMES = ["Hal", "Colossus", "Ultron", "Skynet", "The Borg"]

  attr_accessor :difficulty

  def initialize(board)
    super
    @name = COMPUTER_NAMES.sample
    @marker = COMPUTER_MARKER
    @difficulty = nil
  end

  def move!
    puts "#{name} is thinking..."
    mark_square!(next_move)
    sleep(0.5)
  end

  private

  def next_move
    case difficulty
    when :easy then random_move
    when :medium then heuristic_move
    when :hard then minimax_move
    end
  end

  def minimax_move
    if board.empty?
      Board::CORNERS.sample
    else
      minimax_ab(board)
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

  def random_move
    board.actions.sample
  end
end

class Score
  WINNING_SCORE = 1

  attr_accessor :human, :computer

  def initialize
    @computer = 0
    @human = 0
  end

  def overall_winner?
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
    setup_game
  end

  def play
    clear
    display_tutorial
    main_game
    display_overall_winner if overall_winner?
    display_goodbye_message
  end

  private

  attr_reader :board, :human, :computer, :score, :first_to_move, :current_marker

  def setup_game
    board.set_player_markers(human.marker, computer.marker)
    ask_first_to_move
    computer.difficulty = ask_game_difficulty
  end

  def main_game
    loop do
      clear_screen_and_display_board
      player_move
      display_game_result
      update_score
      display_scoreboard
      break if overall_winner? || !play_again?
      reset
      ask_first_to_move
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
      human.move!
      @current_marker = computer.marker
    else
      computer.move!
      @current_marker = human.marker
    end
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    human_is = "#{human.name} is #{human.marker}."
    computer_is = "#{computer.name} is #{computer.marker}."
    puts "#{human_is} #{computer_is}"
    display_scoreboard(:top)
    board.draw
  end

  def display_welcome_message
    welcome = Phrase.new('welcome', 0.6)
    to = Phrase.new('to', 0.75)
    tic = Phrase.new('tic ___ ___', 0.3)
    tictac = Phrase.new('tic tac ___', 0.3)
    tictactoe = Phrase.new('tic tac toe', 0.3)
    full_message = [welcome, to, tic, tictac, tictactoe]
    display_phrases(full_message)
    puts
    enter_to_continue
    clear
  end

  def display_overall_winner
    case score.game_overall_winner
    when :human
      full_message = compose_you_won_or_lost_message("won")
    when :computer
      full_message = compose_you_won_or_lost_message("lost")
    end
    display_phrases(full_message)

    final_score = Phrase.new("#{score.human}-#{score.computer}", 2)
    display_phrases([final_score])
    puts
  end

  def compose_you_won_or_lost_message(won_or_lost)
    full_message = []
    coda = ['!__', '!!_', '!!!']
    timing = [0.2, 0.2, 0.6]
    2.times do
      0.upto(2) do |i|
        full_message << Phrase.new("you #{won_or_lost}#{coda[i]}", timing[i])
      end
    end
    full_message
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
      puts "#{computer.name} won!"
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
    clear
    display_scoreboard(:bottom)
  end

  def display_scoreboard(loc = :top)
    print_separator if loc == :bottom
    human_score = "#{human.name}: #{score.human}"
    computer_score = "#{computer.name}: #{score.computer}"
    case loc
    when :top
      puts "#{human_score} #{computer_score}"
    when :bottom
      puts "#{human_score} #{computer_score}"
    end
    print_separator if loc == :bottom
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
    new_first_to_move = convert_answer_to_marker(answer)
    assign_first_to_move(new_first_to_move)
  end

  def assign_first_to_move(new_first_to_move)
    @first_to_move = new_first_to_move
    board.first_to_move = new_first_to_move
    @current_marker = new_first_to_move
  end

  def convert_answer_to_marker(answer)
    case answer
    when 'c', 'computer' then computer.marker
    when 'h', 'human' then human.marker
    when 'r', 'random' then [computer.marker, human.marker].sample
    end
  end

  def ask_game_difficulty
    puts "What difficulty would you like to play at? (E)asy, (M)edium, (H)ard?"
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if ["e", "easy", "m", "medium", "h", "hard"].include?(answer)
      puts "Sorry, that's not a valid choice."
    end
    convert_answer_to_difficulty(answer)
  end

  def convert_answer_to_difficulty(answer)
    case answer
    when "e", "easy" then :easy
    when "m", "medium" then :medium
    when "h", "hard" then :hard
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
    @current_marker = first_to_move
    clear
  end
end

game = TTTGame.new
game.play
