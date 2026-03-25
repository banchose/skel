# IPython

Understood, and this is a great question! You're exploring **introspection** — one of Python's most powerful and Pythonic features. Let me show you how to discover what `TinfoilAI` is using interactive commands.

You've already started well with `dir()`, but here are the most useful techniques:

## Essential Introspection Commands

**1. Check the docstring (most important first step):**
```python
print(TinfoilAI.__doc__)
# or in IPython, simply:
TinfoilAI?
```
This will tell you exactly what the class does and how to use it.

**2. Get the signature of `__init__`:**
```python
import inspect
print(inspect.signature(TinfoilAI.__init__))
```
This shows you exactly what arguments you need to pass when creating an instance.

**3. Get the full docstring of `__init__`:**
```python
print(TinfoilAI.__init__.__doc__)
# or in IPython:
TinfoilAI.__init__?
```

**4. See the source code (if available):**
```python
import inspect
print(inspect.getsource(TinfoilAI))
```

**5. List only public methods (non-dunder attributes):**
```python
[attr for attr in dir(TinfoilAI) if not attr.startswith('_')]
```

**6. Get type information:**
```python
print(type(TinfoilAI))
print(TinfoilAI.__module__)
```

## In IPython specifically, you have bonus shortcuts:

- `TinfoilAI?` — Shows docstring
- `TinfoilAI??` — Shows source code
- `TinfoilAI.*method*?` — Help on specific methods

**Try this sequence first:**
```python
TinfoilAI?                          # What is it?
inspect.signature(TinfoilAI)        # What arguments does __init__ need?
[x for x in dir(TinfoilAI) if not x.startswith('_')]  # What can it do?
```

This approach is very Pythonic — Python's design encourages exploration and self-documentation. Would you like to try these and tell me what you discover about `TinfoilAI`?
