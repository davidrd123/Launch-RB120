class Student
  attr_accessor :name, :grade
  # assume that this code includes an appropriate #initialize method
  def initialize(name, age)
    @name = name
    @age = age
  end
end

jon = Student.new('John', 22)
p jon.name # => 'John'
jon.name = 'Jon'
jon.grade = 'B'
p jon.grade # => 'B'