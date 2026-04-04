alias editpython='nvim ~/gitdir/skel/bash/bashrc_zen.d/python.sh'
python_help() {

  cat <<'EOF'
# "introspection"
dir(obj) lists all attribute names on the object
  both methods and non-method attributes
type(a.__add__)
# help
help() # interactive help
  keywords
  modules
  topics
  symbols
help(modules)
help(a.bit_length)
help('somestring')
help(0)
callable(a.__add__)
# ref
a = 1
a.bit_length # the method object (a reference to the function
a.bit_length() # calling the method, getting a result
A compound statement consists of 1 or more clauses.
  clause: consistes of header and a suite
  clause header begins with a uniquely identifing key word and ends in a colon
## iterators
One method needs to be defined for container objects to provide iterable support __iter__()
__iter__() returns the iterator object
iterator object support
  iterator.__iter__()
  iterator.__next__()
sequence(support interation methods): string, tuple, list, range
iteration over containers
iterator: an object representing a stream of data, repeated calls to '__inter()__' returning successive items
every iterator is interable and can mostly be used in place of itererables are accepted
EOF
}
