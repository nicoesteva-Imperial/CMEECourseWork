#!/usr/bin/env python3

"""Small functions practising conditionals and loops (MQB control-flow exercises)."""


def foo_1(x):
    """Return the square root of x."""
    return x**0.5


def foo_2(x, y):
    """Return the larger of x and y."""
    if x > y:
        return x
    return y


def foo_3(x, y, z):
    """Return x, y and z as a list sorted from smallest to largest."""
    if x > y:
        x, y = y, x
    if x > z:
        x, z = z, x
    if y > z:
        y, z = z, y
    return [x, y, z]


def foo_4(x):
    """Return the factorial of x, calculated with a for loop."""
    result = 1
    for i in range(1, x + 1):
        result = result * i
    return result


def foo_5(x):
    """Return the factorial of x, calculated recursively."""
    if x <= 1:
        return 1
    return x * foo_5(x - 1)


def foo_6(x):
    """Return the factorial of x, calculated with a while loop (no if statement)."""
    facto = 1
    while x >= 1:
        facto = facto * x
        x = x - 1
    return facto


if __name__ == "__main__":
    # foo_1: a perfect square
    print(f"foo_1(9) = {foo_1(9)}")

    # foo_2: x bigger, y bigger, x equal to y (the boundary)
    print(f"foo_2(5, 2) = {foo_2(5, 2)}")
    print(f"foo_2(2, 5) = {foo_2(2, 5)}")
    print(f"foo_2(5, 5) = {foo_2(5, 5)}")

    # foo_3: sorted, reverse sorted, mixed
    print(f"foo_3(1, 2, 3) = {foo_3(1, 2, 3)}")
    print(f"foo_3(3, 2, 1) = {foo_3(3, 2, 1)}")
    print(
        f"foo_3(2, 3, 1) = {foo_3(2, 3, 1)}"
    )

    # Factorials at the boundaries 0 and 1, and a normal value 5
    for n in [0, 1, 5]:
        print(
            f"{n}! : foo_4 = {foo_4(n)}, foo_5 = {foo_5(n)}, foo_6 = {foo_6(n)}"
        )

    # The three factorial functions should agree
    print(f"All three agree for 5: {foo_4(5) == foo_5(5) == foo_6(5)}")
