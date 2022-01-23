class Person
  attr_reader :name

  def name
    @name.clone
  end

  def initialize(name)
    @name = name
  end
end

person1 = Person.new('James')
person1.name.reverse!
puts person1.name

