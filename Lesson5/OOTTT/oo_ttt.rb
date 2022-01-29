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

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    # we need some way to model the 3x3 grid. Maybe "squares"?
    # what data structure should we use?
    # - array/hash of Square objects?
    # - array/hash of strings or integers?
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
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
    !!at_risk_square(TTTGame::HUMAN_MARKER)
  end

  def immediate_opportunity?
    !!at_risk_square(TTTGame::COMPUTER_MARKER)
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
  # rubocop:disable Metrics/MethodLength
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
  attr_reader :marker

  def initialize(marker)
    # maybe a "marker" to keep track of this player's symbol (ie, 'X' or 'O')
    @marker = marker
  end
end

class Score
  attr_accessor :computer, :human

  def initialize
    @computer = 0
    @human = 0
  end

  def overall_winner?
    computer == 5 || human == 5
  end

  def get_overall_winner
    return :computer if computer == 5
    return :human if human == 5
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
  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  FIRST_TO_MOVE = HUMAN_MARKER

  attr_reader :board, :human, :computer, :score

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @score = Score.new
    @current_marker = ask_first_to_move
  end

  def play
    clear
    display_welcome_message
    main_game
    display_goodbye_message
  end

  private

  def main_game
    loop do
      display_board
      player_move
      display_result
      update_score
      display_scoreboard
      break if overall_winner?
      break unless play_again?
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
      break if ["h", "c", "r"].include?(answer)
      puts "Sorry, that's not a valid choice."
    end
    case answer
    when 'c' then return COMPUTER_MARKER
    when 'h' then return HUMAN_MARKER
    when 'r' then [COMPUTER_MARKER, HUMAN_MARKER].sample
    end
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts
  end

  def display_goodbye_message
    display_final_results
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def display_final_results
    overall_winner = score.get_overall_winner
    case overall_winner
    when nil then puts "No overall winner"
    when :human then puts "Human is overall winner"
    when :computer then puts "Computer is overall winner"
    end
    display_scoreboard
  end

  def display_scoreboard
    puts "Human: #{score.human}"
    puts "Computer: #{score.computer}"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def display_board
    puts "You're a #{human.marker}. Computer is a #{computer.marker}"
    puts ""
    board.draw
  end

  def joinor(array, delimiter=', ', final_word='or')
    case array.length
    when 0 then ''
    when 1 then array.first
    when 2 then array.join(" #{final_word} ")
    else
      array[..-2].join(delimiter) + delimiter + "#{final_word} #{array.last}"
    end
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
    if board.immediate_opportunity?
      good_next_move = board.at_risk_square(computer.marker)
      computer_places_piece!(good_next_move)
    elsif board.immediate_threat?
      good_next_move = board.at_risk_square(human.marker)
      computer_places_piece!(good_next_move)
    elsif board.middle_square_open?
      good_next_move = 5
      computer_places_piece!(good_next_move)
    else 
      board[board.unmarked_keys.sample] = computer.marker
    end
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
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end

  def display_result
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

  def update_score
    case board.winning_marker
    when human.marker
      score.player_won_game(:human)
    when computer.marker
      score.player_won_game(:computer)
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def clear
    system 'clear'
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts
  end
end

# we'll kick off the game like this
game = TTTGame.new
game.play



# binding.pry