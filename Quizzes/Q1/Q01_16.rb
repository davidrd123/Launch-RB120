class Student
  attr_accessor :name, :grade

  def initialize(name)
    @name = name
    @grade = nil
  end
end

priya = Student.new("Priya")
priya.change_grade('A')
priya.grade # => "A"