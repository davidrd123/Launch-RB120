class Person
  attr_writer :first_name, :last_name

  def full_name
    self.first_name + ' ' + self.last_name
  end
end

mike = Person.new
mike.first_name = 'Michael'
mike.last_name = 'Garcia'
p mike.full_name # => 'Michael Garcia'