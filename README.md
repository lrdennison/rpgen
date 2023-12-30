# rpgen
Parser Generator, written in Ruby

I'm writing this as using standard the bison-generated C++ parser is difficult to work with.
Also, I also need parsers that work with Ruby.

Why write the tool in Ruby?  I wanted to make it easier to write
different backends and even monkey-patch the code.

## References

[Wikipedia LR(0) Parser](https://en.wikipedia.org/wiki/LR_parser)

# Contents

* [First](md/first.md)
* [Follow](md/follow.md)

## Random

The parser literature allows empty rules (productions).  These are
denoted using a special terminal ($\epsilon$).  The use of
epsilon was never really explained, it was just assumed that you knew.

The "dot" is also known as a pointer.

# Key Concepts

* Rule to Items
* Closure of an item set
* Transition table
  * Starts with an item-set of the single top-level rule
  * Close the set
  * Locate symbols of interest to make new item sets + transitions
* Constructing Kernels from an Item Set
  * Items within a kernel have the same item to the left of the dot
  * Items with the dot at the end correspond to reductions
  * Items with the dot not at the end are shifts

## Special Symbols

* start
* eof (end-of-file)
* empty

