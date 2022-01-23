class Cat
  attr_reader :name
  CAT_COLOR = "black"

  def initialize(name)
    @name = name
  end

  def greet
    puts "Hello! My name is #{name} and I'm a #{CAT_COLOR} cat!"
  end
end

kitty = Cat.new('Sophie')
kitty.greet