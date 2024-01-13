# rpgen

A Parser Generator, written in Ruby.

I'm writing this as using the standard Bison-generated C++ parser is difficult to work with.
Also, I also need parsers that work with Ruby.

Why write the tool in Ruby?  I wanted to make it easier to write
different backends and even monkey-patch the code if necessary.

## Introduction

The tool can generate LR(0), SLR, LALR, and LR(1) *action tables*.
The action tables form the core of a parser.

The parsers differ in how they handle reductions:

* LR(0) allows only one reduction per state (and no shifts in the
  state).  Lookahead is ignored.

* SLR uses lookaheads computed from the grammar.  A state might have
  several shifts and multiple reductions.

* LR(1) uses lookaheads computed from the state transitions.  State
  equivalence includes the lookaheads which can cause a large number
  of states to be generated.

* LALR also uses lookaheads computed from the state transitions.
  However, lookaheads are ignored when determining when to merge states a
  new state.

## Subtle things when writing parser generators

The graph formed by the states and transitions is **not** acyclic.
That means the state generation process can generate a new state
equivalent to a existing state.  Without as-you-go duplicate state
detection and elimination, the state generation process will continue
forever.

## LALR Parsers

During the generation of the LR(0) and SLR transition tables,
lookaheads are ignored.  This allows us to safely deduplicate item
sets, based on them having the same core set of items.

For LR(1) parsers, we can only combine/merge two item sets if they
have the same core items, including the lookaheads.  This is the cause
of the large number of parser states.  However, state deduplication
does not cause the algorithm to revisit the deduplicated state.

Generation of the LALR item set is similar to the LR(0).  States are
combined (deduplicated) based having on a common core. When we combine
two item sets that have a common core, the lookaheads are also merged
(via a union).  This merging is problematic as the new lookaheads
should be propagated to other item sets.  The code is written to
revisit item sets only when changed.

## References

* [Wikipedia LR Parser](https://en.wikipedia.org/wiki/LR_parser)
* [Compilers (aka the Dragon Book), Aho et. al](https://faculty.sist.shanghaitech.edu.cn/faculty/songfu/cav/Dragon-book.pdf)
* [Forming the LALR(1)-item automaton from the LR(0)-item automaton](http://pages.cpsc.ucalgary.ca/~robin/class/411/LALR1/LALR1_follow_sets.html)
* [First and Follow](https://www.cs.uaf.edu/~cs331/notes/FirstFollow.pdf)

### About the references

Item sets become states in the action table.  The word *state* is
sometimes used instead of *item set*.  They mostly mean the same
thing.

The parser literature allows empty rules (productions).  These are
denoted using a special terminal ($\epsilon$).  The use of
epsilon was never really explained, it was just assumed that you knew.

The "dot" is also known as a pointer.

# Contents

* [Grammar](md/grammar.md)
* [Item](md/item.md)
* [Item Set](md/item_set.md)
* [First](md/first.md)
* [Follow](md/follow.md)

# Key Concepts

* Rule to Items
* Closure of an item set
* Transition table
  * Starts with an item-set comprised of the single top-level rule
  * Close the set
  * Locate symbols of interest to make new item sets + transitions
* Constructing Kernels from an Item Set
  * Items within a kernel have the same item to the left of the dot
  * Items with the dot at the end correspond to reductions
  * Items with the dot not at the end are shifts


