# ruby.test.rb

# This is a test Ruby file to verify LSP functionality

# Class definition
class Greeting
  def initialize(name)
    @name = name
  end

  def say_hello
    puts "Hello, #{@name}!"
  end
end

# Method definition
def factorial(n)
  return 1 if n == 0
  n * factorial(n - 1)
end

# String manipulation
message = "Welcome to Ruby!"
puts message.upcase

# Array operations
fruits = ["apple", "banana", "cherry"]
fruits.each { |fruit| puts fruit.capitalize }

# Hash usage
person = {
  name: "John Doe",
  age: 30,
  occupation: "Developer"
}
puts "#{person[:name]} is a #{person[:occupation]}"

# Using the class
greeting = Greeting.new("World")
greeting.say_hello

# Using the factorial method
result = factorial(5)
puts "Factorial of 5 is #{result}"

# Conditional statement
time = Time.now
if time.hour < 12
  puts "Good morning!"
else
  puts "Good afternoon!"
end

# Error handling
begin
  1 / 0
rescue ZeroDivisionError => e
  puts "Caught an error: #{e.message}"
end
