# Test 1: Simple one-line statement
x = 42
print(x)

# Test 2: Function definition
def greet(name):
    """This function greets the person passed in as a parameter"""
    print(f"Hello, {name}!")

# Test 3: Class definition
class Rectangle:
    def __init__(self, width, height):
        self.width = width
        self.height = height
    
    def area(self):
        return self.width * self.height

# Test 4: If-elif-else statement
x = 10
if x < 0:
    print("Negative")
elif x == 0:
    print("Zero")
else:
    print("Positive")

# Test 5: For loop
fruits = ["apple", "banana", "cherry"]
for fruit in fruits:
    print(fruit)

# Test 6: While loop
count = 0
while count < 5:
    print(count)
    count += 1

# Test 7: Try-except-finally block
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero!")
finally:
    print("This is always executed")

# Test 8: With statement
with open("test.txt", "w") as file:
    file.write("Hello, World!")

# Test 9: Decorator
def uppercase_decorator(func):
    def wrapper():
        result = func()
        return result.upper()
    return wrapper

@uppercase_decorator
def greet():
    return "hello, world!"

# Test 10: Lambda function (multiline)
multiply = lambda x, y: (
    x * y
)

# Test 11: List comprehension (multiline)
squares = [
    x**2
    for x in range(10)
    if x % 2 == 0
]

# Test 12: Generator expression (multiline)
sum_of_squares = sum(
    x**2
    for x in range(10)
    if x % 2 == 0
)

# Test 13: Multiline string
long_string = """
This is a long string
that spans multiple lines.
It uses triple quotes.
"""

# Test 14: Multiline statement using explicit line continuation
long_calculation = (
    1 + 2 + 3 + 4 + 5 +
    6 + 7 + 8 + 9 + 10
)
