require 'pry'

class Transform
  def initialize(data)
    @data = data
  end

  def self.lowercase(data)
    data.downcase
  end

  def uppercase
    @data.upcase
  end

end

# binding.pry
my_data = Transform.new('abc')
puts my_data.uppercase
puts Transform.lowercase('XYZ')