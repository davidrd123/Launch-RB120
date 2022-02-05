require 'pry'

class Letter
  WIDTH = 7
  HEIGHT = 7
  CHAR = '*'

  def initialize(letter)
    @grid = Array.new(HEIGHT) { Array.new(WIDTH, ' ') }
    make_letter(letter.upcase)
  end

  def display
    @grid.each do |row|
      row.each do |cell|
        print cell
      end
      puts
    end
  end

  def to_s
    @grid.map(&:join).join("\n")
  end

  def get_row(row)
    @grid[row]
  end

  def make_letter(letter)
    case letter
    when 'A'
      fill_left_col
      fill_right_col
      fill_middle_row
      fill_top_row
    when 'C'
      fill_left_col
      fill_top_row
      fill_bottom_row
    when 'E'
      fill_left_col
      fill_top_row
      fill_middle_row
      fill_bottom_row
    when 'I'
      fill_top_row
      fill_bottom_row
      fill_middle_col
    when 'L'
      fill_left_col
      fill_bottom_row
    when 'M'
      fill_left_col
      fill_middle_col
      fill_right_col
      fill_top_row
    when 'N'
      fill_left_col
      fill_left_diag
      fill_right_col
    when 'O'
      fill_left_col
      fill_right_col
      fill_top_row
      fill_bottom_row
    when 'T'
      fill_top_row
      fill_middle_col
    when 'U'
      fill_left_col
      fill_right_col
      fill_bottom_row
    when 'W'
      fill_left_col
      fill_right_col
      fill_middle_col
      fill_bottom_row
    when 'Y'
      fill_top_left_diag
      fill_top_right_diag
      fill_bottom_middle_col
    end
  end

  def set_cell(x, y, char = CHAR)
    @grid[x][y] = char
  end

  def get_cell(x, y)
    @grid[x][y]
  end

  def set_col_to_value(col, value)
    @grid.each do |row|
      row[col] = value
    end
  end

  def fill_left_col(char = CHAR)
    set_col_to_value(0, char)
  end

  def fill_middle_col(char = CHAR)
    set_col_to_value(WIDTH / 2, char)
  end

  def fill_bottom_middle_col(char = CHAR)
    @grid.each_with_index do |row, y|
      row.each_with_index do |_, x|
        @grid[y][x] = char if x == WIDTH / 2 && y > WIDTH / 2 - 1
      end
    end
  end

  def fill_right_col(char = CHAR)
    set_col_to_value(WIDTH - 1, char)
  end

  def fill_top_left_diag(char = CHAR)
    @grid.each_with_index do |row, y|
      row.each_with_index do |_, x|
        @grid[y][x] = char if x == y && y < WIDTH / 2
      end
    end
  end

  def fill_left_diag(char = CHAR)
    @grid.each_with_index do |row, y|
      row.each_with_index do |_, x|
        @grid[y][x] = char if x == y
      end
    end
  end

  def fill_top_right_diag(char = CHAR)
    @grid.each_with_index do |row, y|
      row.each_with_index do |_, x|
        @grid[y][x] = char if x == WIDTH - 1 - y && y < WIDTH / 2
      end
    end
  end

  def fill_right_diag(char = CHAR)
    @grid.each_with_index do |row, y|
      row.each_with_index do |_, x|
        @grid[y][x] = char if x == WIDTH - 1 - y
      end
    end
  end

  def set_row_to_value(row, value)
    @grid[row].map! { |cell| cell = value }
  end

  def fill_top_row(char = CHAR)
    set_row_to_value(0, char)
  end

  def fill_middle_row(char = CHAR)
    set_row_to_value(HEIGHT / 2, char)
  end

  def fill_bottom_row(char = CHAR)
    set_row_to_value(HEIGHT - 1, char)
  end
end

class Word
  def initialize(word)
    @letters = word.split('').map { |letter| Letter.new(letter) }
    @grid_width = (Letter::WIDTH + 1) * @letters.length
    @grid_height = Letter::HEIGHT
    @char_grid = Array.new(@grid_height) { '' }
    fill_grid
  end

  def get_row(row)
    @char_grid[row]
  end

  def grid_width
    @char_grid.first.size
  end

  def num_letters
    @letters.length
  end

  def fill_grid
    0.upto(@grid_height - 1) do |row|
      @letters.each do |letter|
        @char_grid[row] << letter.get_row(row).join + ' '
      end
    end
  end

  def to_s
    @char_grid.join("\n")
  end
end

class Phrase
  def initialize(phrase)
    @words = phrase.split(' ').map { |word| Word.new(word) }
    @grid_height = Letter::HEIGHT
    @char_grid = Array.new(@grid_height) { '' }
    fill_grid
  end

  def fill_grid
    0.upto(@grid_height - 1) do |row|
      @words.each do |word|
        @char_grid[row] << word.get_row(row) + '  '
      end
    end
  end

  def to_s
    @char_grid.join("\n")
  end

  def display_center
    @char_grid.each do |row|
      puts row.center(80)
    end
  end
end

# letters = ['A', 'C', 'E', 'I', 'O', 'T']
# letters.each do |letter|
#   letter = Letter.new(letter)
#   letter.display
#   puts
# end

# A = Letter.new('A')
# tic = Word.new('TIC')
# tictactoe = Phrase.new('TIC TAC TOE')
# puts(tictactoe.to_s.center(80))

# empty_letter = Letter.new('_')
# binding.pry
# you = Phrase.new('YOU')
# you.display_center

# won = Phrase.new('WON')
# won.display_center

# welcome = Phrase.new('welcome')
# to = Phrase.new('to')
# tic = Phrase.new('tic ___ ___')
# tictac = Phrase.new('tic tac ___')
# tictactoe = Phrase.new('tic tac toe')
# system 'clear'
# welcome.display_center
# sleep(1)
# system 'clear'
# to.display_center
# sleep(1)
# system 'clear'
# tic.display_center
# sleep(0.5)
# system 'clear'
# tictac.display_center
# sleep(0.5)
# system 'clear'
# tictactoe.display_center

