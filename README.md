# rpgen
Parser Generator, written in Ruby

I'm writing this as using the bison-generated C++ parser is difficult.
Also, I also need parsers that work with Ruby.

# Random

The parser literature allows empty rules (productions).  These are
denoted using a special terminal (lower case epsilon).  The use of
epsilon was never really explained, just assumed.

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

## The First Concept

Every non-terminal eventually starts with a set of terminals.  One of
those terminals might be the empty terminal.  Owing to things like
left recursion, the easiest way to calculate the first sets is using
iterative updates.  These wind up with a fixed-point where further
iterations don't modify the sets.

Note that a *first* set might include the terminal empty.

## The Follow Concept

We want to know the set of terminals which might appear after a
non-terminal, constrained by the grammar.  The set of follow terminals
cannot include the terminal empty.  The start rule in the augmented
grammar has end-of-file as the last element.  All other rules are
followed by end-of-file.

We are calculating follow(A).

Consider:
$$R \rightarrow A B C$$

The incremental update is: follow(A) = follow(A) union (first(B) -
empty).  If first(B) contains empty, then we must also do:

follow(A) := follow(A) union (first(C) - empty).

If first(C) contains empty, then follow(A) := follow(A) union follow(R).

Most of the literature tries to explain first and follow using
mathematical notation.  Owing to the different cases, the math looks
ugly.  For example, note that follow(C) := follow(C) union follow(R).
