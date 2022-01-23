require 'pry'

module Towable
  def can_tow?(pounds)
    pounds < 2000 ? true : false
  end
end

class Vehicle
  attr_accessor :color
  attr_reader :year, :model
  @@number_of_vehicles = 0


  def self.number_of_vehicles
    puts "There are #{@@number_of_vehicles} vehicles created"
  end

  def initialize(year, color, model)
    @model = model
    @color = color
    @year = year
    @current_speed = 0
    @@number_of_vehicles += 1
  end

  def speed_up(number)
    @current_speed += number
    puts "You push the gas and accelerate #{number} mph."
  end

  def brake(number)
    @current_speed -= number
    @current_speed = max(0, @current_speed)
    puts "You push the brake and decelerate #{number} mph."
  end

  def current_speed
    "You are now going #{@current_speed} mph."
  end

  def turn_off
    @current_speed = 0
    puts "Let's park this bad boy!"
  end

  def self.gas_mileage(gallons, miles)
    puts "#{miles / gallons} miles per gallon of gas"
  end

  def spray_paint(new_color)
    self.color = new_color
  end

  def age
    "Your #{self.model} is #{years_old} years old."
  end

  def to_s
    "#{year} #{color} #{model}"
  end

  private

  def years_old
    Time.now.year - self.year
  end
end

class MyCar < Vehicle
  NUMBER_OF_DOORS = 4

  def to_s
    "My car is a #{self.color}, #{self.year}, #{self.model}!"
  end
end

class MyTruck < Vehicle
  include Towable
  NUMBER_OF_DOORS = 2
  def to_s
    "My truck  is a #{self.color}, #{self.year}, #{self.model}!"
  end
end

my_car = MyCar.new(1996, "Green", "Honda Civic")

binding.pry

# puts MyCar.ancestors
# puts MyTruck.ancestors
# puts Vehicle.ancestors