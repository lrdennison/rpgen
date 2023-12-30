# Grammar

A grammar is a Ruby class, derived from the base Grammar class.  The
base class provides a light-weight DSL for describing a grammar.

Grammars have the usual concepts of *terminals* and *rules*.  The name
of a terminal or rule is a Ruby symbol.

The right-hand side of a rule is just an array of symbols.