require 'pry'

class MyCar
  attr_accessor :color, :year, :model

  def initialize(year, color, model)
    @model = model
    @color = color
    @year = year
    @current_speed = 0
  end

  def self.gas_milage
  end

  def speed_up(number)
    @current_speed += number
  end

  def brake(number)
    @current_speed -= number
    @current_speed = max(0, @current_speed)
  end

  def current_speed
    "You are now going #{@current_speed} mph."
  end

  def turn_off
    @current_speed = 0
  end

  def spray_paint(new_color)
    self.color = new_color
  end

  def to_s
    "#{year} #{color} #{model}"
  end
end

binding.pry