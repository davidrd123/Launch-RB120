class Shelter

  def initialize
    @unadopted = []
    @owners_to_adopted_pets = Hash.new { |h, k| h[k] = [] }
  end

  def adopt(owner, pet)
    @owners_to_adopted_pets[owner] += [pet]
    owner.add_pet(pet)
  end

  def print_adoptions
    @owners_to_adopted_pets.keys.each do |owner|
      puts "#{owner} has adopted the following pets:"
      owner.print_pets
      puts
    end
  end
end

class Pet
  attr_reader :kind, :name
  def initialize(kind, name)
    @kind = kind
    @name = name
  end

  def to_s
    "a #{kind} named #{name}"
  end
end

class Owner
  attr_reader :name
  attr_accessor :adopted_pets
  
  def initialize(name)
    @name = name
    @adopted_pets = []
  end

  def add_pet(pet)
    @adopted_pets << pet
  end

  def number_of_pets
    @adopted_pets.size
  end

  def print_pets
    puts adopted_pets
  end

  def to_s
    @name
  end
end


butterscotch = Pet.new('cat', 'Butterscotch')
pudding      = Pet.new('cat', 'Pudding')
darwin       = Pet.new('bearded dragon', 'Darwin')
kennedy      = Pet.new('dog', 'Kennedy')
sweetie      = Pet.new('parakeet', 'Sweetie Pie')
molly        = Pet.new('dog', 'Molly')
chester      = Pet.new('fish', 'Chester')

phanson = Owner.new('P Hanson')
bholmes = Owner.new('B Holmes')

shelter = Shelter.new
shelter.adopt(phanson, butterscotch)
shelter.adopt(phanson, pudding)
shelter.adopt(phanson, darwin)
shelter.adopt(bholmes, kennedy)
shelter.adopt(bholmes, sweetie)
shelter.adopt(bholmes, molly)
shelter.adopt(bholmes, chester)
shelter.print_adoptions
puts "#{phanson.name} has #{phanson.number_of_pets} adopted pets."
puts "#{bholmes.name} has #{bholmes.number_of_pets} adopted pets."

# P Hanson has adopted the following pets:
# a cat named Butterscotch
# a cat named Pudding
# a bearded dragon named Darwin

# B Holmes has adopted the following pets:
# a dog named Molly
# a parakeet named Sweetie Pie
# a dog named Kennedy
# a fish named Chester

# P Hanson has 3 adopted pets.
# B Holmes has 4 adopted pets.