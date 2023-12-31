# rpgen
A Parser Generator, written in Ruby.

I'm writing this as using standard the bison-generated C++ parser is difficult to work with.
Also, I also need parsers that work with Ruby.

Why write the tool in Ruby?  I wanted to make it easier to write
different backends and even monkey-patch the code if necessary.

## Introduction

The tool currently generates an Simple LR (SLR) parser.  It works by:

* Generating an LR(0) transition table

* Some states might have shift/reduce or reduce/reduce conflicts.
  These are resolved using the reduction rule's *follow* set.  For SRL, the
  follow set is taken from the full grammar.

It does use the look-ahead token to resolve shift/reduce conflicts, so the tool can handle
more grammars than an LR(0) parser.

## LALR Parsers

During the generation of the LR(0) table, lookaheads are ignored.
This allows us to safely deduplicate item sets, based on them having the same
core set of items.

For LR(1) parsers, we can only combine/merge two item sets if they
have the same core items, including the lookaheads.  This is the cause
of the large number of parser states.

Generation of the LALR item set is similar to the LR(0) using the
combining, except that it also includes the lookahead sets.  When we
combine two item sets, the lookaheads are also merged (via a union).
This merging is problematic as the lookaheads may need to be
propagated to other item sets.  Instead, we first compute the item
sets without lookaheads and then compute the lookaheads in a separate
phase.

## References

* [Wikipedia LR Parser](https://en.wikipedia.org/wiki/LR_parser)
* [Compilers (aka the Dragon Book), Aho et. al](https://faculty.sist.shanghaitech.edu.cn/faculty/songfu/cav/Dragon-book.pdf)
* [Forming the LALR(1)-item automaton from the LR(0)-item automaton](http://pages.cpsc.ucalgary.ca/~robin/class/411/LALR1/LALR1_follow_sets.html)
* [First and Follow](https://www.cs.uaf.edu/~cs331/notes/FirstFollow.pdf)

### About the references

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


