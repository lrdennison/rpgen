# The Follow Concept

We want to know the set of terminals which might appear after a
non-terminal, constrained by the grammar.  The set of follow terminals
cannot include the terminal empty.  The start rule in the augmented
grammar has end-of-file as the last element.  All other rules are
followed by end-of-file.

We are calculating follow(A).

Consider the rule:
$$R \rightarrow A B C$$

The incremental update is: follow(A) = follow(A) union (first(B) -
empty).  If first(B) contains empty, then we must also do:

follow(A) := follow(A) union (first(C) - empty).

If first(C) contains empty, then follow(A) := follow(A) union follow(R).

Most of the literature tries to explain first and follow using
mathematical notation.  Owing to the different cases, the math looks
ugly.  For example, note that follow(C) := follow(C) union follow(R).
