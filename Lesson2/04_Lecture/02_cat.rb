class Pet


  def run
    'running!'
  end

  def jump
    'jumping!'
  end

  
end

class Dog < Pet
  def speak
    'bark!'
  end

  def swim
    'swimming!'
  end

  def fetch
    'fetching!'
  end
  
end

class Cat < Pet
  def speak
    'meow!'
  end
end

class Bulldog < Dog

  def swim
    "can't swim!"
  end
end

pete = Pet.new
kitty = Cat.new
dave = Dog.new
bud = Bulldog.new

p pete.run                # => "running!"
# p pete.speak              # => NoMethodError

p kitty.run               # => "running!"
p kitty.speak             # => "meow!"
# p kitty.fetch             # => NoMethodError

p dave.speak              # => "bark!"

p bud.run                 # => "running!"
p bud.swim                # => "can't swim!"

=begin
# Pet
  - run
  - jump
  # Dog
    - speak
    - swim 
    - fetch
    # Bulldog
    - swim
  # Cat
    - speak

The method lookup path is the order in which Ruby will traverse the class
hierarchy to look for methods to invoke.
=end