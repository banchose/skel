# Python

- program units such as
  - functions (object)
  - modules (object)
  - classes

We’ll meet in later parts of this book—are objects in Python too; they are created with
statements and expressions such as def, class, import, and lambda and may be passed
around scripts freely, stored within other objects, and so on. Python also provides a
set of implementation-related types such as compiled code objects, which are generally
of interest to tool builders more than application developers; we’ll explore these in later
parts too, though in less depth due to their specialized roles

## immutable

- Immutable types include
  - ints
  - floats
  - strings
  - tuples

## Mutable

- lists
- dictionaries
- sets

## iterables

- string

## Literal

- 'literal' simply means an expression whose syntax generates an object

## Negative infinity:

On a number line, 7 / 3 2.33 going to 2 is down which goes to 0 because 2 is closer to zero than 2.33 or even 3 of course
but -7 / 3 = -3 (round to negative infinity) - neg inf is acting like 0 here. -2.33 to -3 is same direction as 2.33 to 2

## Structure

1. Programs are composed of modules.
2. Modules contain statements.
3. Statements contain expressions.
4. Expressions create and process objects.

## Tuples are like lists but are immutable.

tup = (1, 2, 3)
tup[0] # => 1
tup[0] = 3 # Raises a TypeError
