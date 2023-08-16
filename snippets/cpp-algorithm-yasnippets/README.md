# C++ algorithm yasnippets #

This is loosely based on [Tommy Bennetts](https://github.com/tommybennett) idea
of [algorithm-mnemonics](https://github.com/tommybennett/algorithm-mnemonics).

It contains [YASnippets](https://github.com/joaotavora/yasnippet) for all
algorithms in the C++ standard (including those already voted into the C++20
draft) and some useful combinations of these algorithms. (The versions taking
ExecutionPolicies are currently missing).

## Installation ##

Either add the location of the snippet directory to **yas-snippet-dirs** or place
the directory inside a directory in this path.

    (add-to-list 'yas-snippet-dirs "<snippets_directory>")

The snippets will be active for **c++-mode** and will be added to the **algorithm**
sub-group.

As I work with different standard library implementations which don't all use
the **std** namespace, I have a function that returns the appropriate namespace
for the current file. If you are only using a standard library implementation
that is implemented in the **std** namespace, you either want to define the
function to always return **std** or replace the call in the snippets.

### Add prefix function ###

Add the following function to your configuration:

    (defun rcj-cc-mode-std-prefix-for-file () "std")

### Replace the function call with std ###

    cd <snippet-directory> && sed -i 's/std/std/g'

## Expansion ##

Most snippets are structured in the same way and have multiple replacement
points. Lets look at **reduce**:

    ${1:auto ${2:v} = }std::reduce(${3:std::begin(${4:container})}, ${5:std::end($4)}${6:, ${7:init}${8:, ${9:[](auto ${10:const& }val, auto $10acc) { ${11:return val + acc;} }}}});$0

1.  Decide to capture the result in a variable or delete this replacement if used inside a control structure.
2.  Name of the variable.
3.  Start of input range, defaults to std::begin or could be replaced with an iterator.
4.  Name of the container when using std::begin.
5.  End of input range, defaults to std::end.
6.  Optional init value and binary predicate, just delete (default C-d) the replacement if you want to use the default.
7.  Initial value.
8.  Optional binary predicate, just delete if you want to use the default.
9.  Binary predicate: function object or lambda.
10. If using a lambda, capture by const& (default) or by value (C-d).
11. Implementation of the binary predicate, defaults to the standard implementation as a reminder.
