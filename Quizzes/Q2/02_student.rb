class Student
  # class body
  attr_accessor :grade

  def initialize(name, grade=nil)
    @name = name
  end
end

ade = Student.new('Adewale')
p ade # => #<Student:0x00000002a88ef8 @grade=nil, @name="Adewale">