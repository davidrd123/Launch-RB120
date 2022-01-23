require 'pry'

class Circle
  attr_reader :radius

  def initialize(r)
    @radius = r
  end

  def >(other)
    radius > other.radius
  end

  def ==(other)
    radius == other.radius
  end
end

circle1 = Circle.new(5)
circle2 = Circle.new(3)
circle3 = Circle.new(5)

binding.pry