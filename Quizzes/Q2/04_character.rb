class Character
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def speak
    "#{name} is speaking."
  end

  def name
    @name
  end
end

class Knight < Character
  def name
    "Sir " + super
  end
end

sir_gallant = Knight.new("Gallant")
p sir_gallant.name # => "Sir Gallant"
p sir_gallant.speak # => "Sir Gallant is speaking."