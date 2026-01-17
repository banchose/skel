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

## pipx

```sh
# better
uv tool install ruff
pipx install ruff
```

## Pattern

- create a project (mkdir myprog)
- cd into proj directory
- create a virual env in proj direcotry (myprog/.venv)
- when working on prog, activate the venv
- deactivate when done

## iterables

- Can be looped over
- Has `__iter__` method
- The method `__iter__` returns an iterator
- Double underscored methods called "dunder" so "dunder iter"

```Python
nums = [1,2,3]
i_nums = nums.__iter__()
i_nums = iter(nums)
```

### Iteration basics

- This is what a `for` loop does

```Python
while True:
  try:
    item = next(i_nums)
    print(item)
  except StopIteration:
    break
```

### Range (the hard way)

```python
class MyRange:
  # self, can't set things on the object without the object
  def __init__(self, start, end):
    self.value = start
    self.end = end

  def __iter__(self):
    return self # return an object with .__next__()
  # so this class will need a __next__() method

  def __next__(self):
    if self.value >= self.end:
      raise StopIteration
  current= self.value
  self.value += 1
  return current
```

### Generator

- range 'generator'

```python
def my_range(start,end):
  current = start
  while current < end:
    yield current
    current += 1
```

```

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
```
