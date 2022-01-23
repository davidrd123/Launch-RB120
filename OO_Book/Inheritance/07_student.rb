require 'pry'

class Student
  attr_accessor :name

  def initialize(name, grade)
    @name = name
    @grade = grade
  end

  def better_grade_than?(other_student)
    self.grade > other_student.grade
  end

  protected 
  
  def grade
    @grade
  end
end

joe = Student.new("Joe", 95)
bob = Student.new("Bob", 80)

binding.pry