# The First Concept

Every non-terminal eventually starts with a set of terminals.  One of
those terminals might be the empty terminal.  Owing to things like
left recursion, the easiest way to calculate the first sets is using
iterative updates.  These wind up with a fixed-point where further
iterations don't modify the sets.

Note that a *first* set might include the terminal empty.
