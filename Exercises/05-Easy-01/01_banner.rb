=begin

# PROBLEM:
- input: string
- output: multi-line string
   
# Rules/Requirements


# Questions:



# Examples:


# DATA STRUCTURES


# ALGORITHM


=end

class Banner
  def initialize(message)
    @message = message
  end

  def to_s
    [horizontal_rule, empty_line, message_line, empty_line, horizontal_rule].join("\n")
  end

  private

  def horizontal_rule
    total_length = message_line.length
    "+#{'-' * (total_length - 2)}+"
  end

  def empty_line
    total_length = message_line.length
    "|#{' ' * (total_length - 2)}|"
  end

  def message_line
    "| #{@message} |"
  end
end



banner = Banner.new('To boldly go where no one has gone before.')
puts banner
# +--------------------------------------------+
# |                                            |
# | To boldly go where no one has gone before. |
# |                                            |
# +--------------------------------------------+

banner = Banner.new('')
puts banner
# +--+
# |  |
# |  |
# |  |
# +--+