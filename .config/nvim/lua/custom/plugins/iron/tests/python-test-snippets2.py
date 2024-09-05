# Test case 1: Multi-line function call
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)


# Test case 2: If-elif-else structure
def check_number(x):
    if x < 0:
        print("Negative")
    elif x == 0:
        print("Zero")
    else:
        print("Positive")


# Test case 3: Function definition
def complex_function(a, b, c, d=None, e=None):
    """
    This is a multi-line docstring
    for a complex function.
    """
    result = a + b + c
    if d is not None:
        result += d
    if e is not None:
        result += e
    return result


# Test case 4: Class definition
class TestClass:
    def __init__(self, value):
        self.value = value

    def double_value(self):
        return self.value * 2


# Test case 5: Try-except block
try:
    risky_operation()
except ValueError as e:
    print(f"Caught a ValueError: {e}")
except TypeError:
    print("Caught a TypeError")
finally:
    print("This always runs")

# Test case 6: With statement
with open("test.txt", "r") as file:
    content = file.read()
    print(content)

# Test case 7: List comprehension
squares = [x**2 for x in range(10)]


# Test case 8: Nested function
def outer_function(x):
    def inner_function(y):
        return x + y

    return inner_function


# Test case 9: Decorator
def my_decorator(func):
    def wrapper():
        print("Something is happening before the function is called.")
        func()
        print("Something is happening after the function is called.")

    return wrapper


@my_decorator
def say_hello():
    print("Hello!")


# Test case 10: Multi-line string
long_string = """
This is a multi-line string.
It spans several lines.
And should be captured entirely.
"""

# Test case 11: Complex list comprehension
matrix = [
    [1, 2, 3, 4],
    [5, 6, 7, 8],
    [9, 10, 11, 12],
]
flattened = [num for row in matrix for num in row if num % 2 == 0]

# Test case 12: Lambda function
multiply = lambda x, y: x * y


# Test case 13: Async function
async def fetch_data(url):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.text()


# Test case 14: Generator function
def fibonacci(n):
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b


# Test case 15: Type hints
def greet(name: str) -> str:
    return f"Hello, {name}!"


if __name__ == "__main__":
    print("This is the main block")
    check_number(5)
    result = complex_function(1, 2, 3, d=4, e=5)
    print(f"Result: {result}")


from utils.utils import (
    create_partitioner,
    draw_boxes,
    ensure_cache_dir,
    get_pdf_files,
    partition_docs,
    process_or_load,
    read_binary,
    split_docs,
)
