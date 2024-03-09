# Julia - first encounter {#sec:julia_first_encounter}

Before we begin a warning. This book is not intended to be a comprehensive
introduction to Julia programming. If you are looking for one try, e.g. [Think
Julia](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html). On the
other hand, if the above-mentioned book is too much for you, and all you want is
a short introduction see [learn Julia in Y
minutes](https://learnxinyminutes.com/docs/julia/). For a video introduction
try, e.g. [A Gentle Introduction to
Julia](https://www.youtube.com/watch?v=4igzy3bGVkQ).

Still, regarding the current book, I think we need to cover some selected basics
of the language in order to use it later. The rest of it we will catch 'on the
fly'. Without further ado let's get our hands dirty.

## Installation {#sec:julia_installation}

In order to use Julia we need to install it first. So, now is the time to go to
[julialang.org](https://julialang.org/), click 'Download' and choose the version
suitable for your machine's OS.

To check the installation open the
[Terminal](https://en.wikipedia.org/wiki/Terminal_emulator) and type:

```bash
julia --version
```

At the time of writing these words I'm using:

```jl
s = """
VERSION
"""
sco(s)
```

running on a Gnu/Linux operating system. Keep that in mind, cause sometimes it
may make a difference, e.g. reading the contents of a file (file path) may be OS
specific.

At the bottom of the Julia's web page you will find 'Editors and IDEs' section
presenting the most popular editors that will enable you to effectively write
and execute pieces of Julia's code.

For starters I would go with [Visual Studio
Code](https://www.julia-vscode.org/docs/dev/gettingstarted/#Installation-and-Configuration-1)
a popular, user friendly code editor for Julia. In the link above you will find
the installation and configuration instructions for the editor.

From now on you'll be able to use it interactively (to run Julia code from this
book).

All You need to do is to create a file, e.g. `chapter03.jl` (or open that file
from [the
code_snippets](https://github.com/b-lukaszuk/RJ_BS_eng/tree/main/code_snippets/ch03)),
type the code presented in this chapter and run it by marking the code and
pressing `Ctrl+Enter`.

## Language Constructs {#sec:julia_language_constructs}

Let's start by looking at some language features, namely:

1. Variables
2. Functions
3. Decision making
4. Repetition

## Variables {#sec:julia_language_variables}

The way I see it a variable is a box to store some value.

Type

```jl
s = """
x = 1
"""
sc(s)
```

mark it (highlight it with a mouse) and run by pressing `Ctrl+Enter`.

This creates a variable (an imaginary box) named `x` (`x` is a label on the box)
that contains the value `1`. The `=` operator assigns `1` (right side) to `x`
(left side) [puts `1` into the box].

> **_Note:_** Spaces around mathematical operators like `=` are usually not
> necessary. Still, they improve legibility of your code.

Now, somwehat below type and execute

```jl
s = """
x = 2
"""
sc(s)
```

Congratulations, now the value stored in the box (I mean variable `x`) is `2`
(the previous value is gone).

Sometimes (usually I do this inside of functions, see
@sec:julia_language_functions) you may see variables written like that

```jl
s = """
z::Int = 4
"""
sc(s)
```

or

```jl
s = """
zz::Float64 = 4.4
"""
sc(s)
```

The `::` is a type declaration. Here by using `::Int` you promise Julia that you
will store only [integers](https://en.wikipedia.org/wiki/Integer) (like: ...,
-1, 0, 1, ...) in this box. Whereas by typing `::Float64` you declare to place
only [floats](https://en.wikipedia.org/wiki/Floating-point_arithmetic) (like:
..., 1.1, 1.0, 0.0, 2.2, 3.14, ...) in that box.

> **_Note:_** You can either explicitly declare a type (with `::`) or let Julia
> guess it (when it's not declared, like in the case of `x` above). In either
> situation you can check the type of a variable with `typeof` function,
> e.g. `typeof(x)` or `typeof(zz)`.

### Optional type declaration {#sec:julia_optional_type_declaration}

**In Julia type declaration is optional.** You don't have to do this, Julia will
figure out the types anyway. Still, sometimes it is worth to declare them
(explanation in a moment). If you decide to do so, you should declare a
variable's type only once (the time it is first created and initialized with a
value).

If you use a variable without a type declaration then you can freely reassign to
it values of different types.

> **_Note:_** In the code snippet below `#` and all the text to the right of it
> is a comment, the part that is ignored by a computer but read by a human.

```jl
s = """
a = 1 # type is not declared
a = 2.2 # can assign a value of any other type
# the "Hello" below is a string (a text in a form readable by Julia)
a = "Hello"
"""
sc(s)
```

But you cannot assign (to a variable) a value of a different type than the one
you declared (you must keep your promises). Look at the code below.

This is OK

```jl
s = """
b::Int = 1 # type integer declared
b = 2 # value of type integer delivered
"""
sc(s)
```

But this is not OK (it's wrong! it's wroooong!)

```
c::Int = 1 # type integer declared
c = 3.3 # broke the promise, float delivered, it will produce an error
c = 3.0 # again, broke the promise, float delivered, expect error
```

Now a question arises. Why would you want to use a type declaration (like
`::Int` or `::Float64`) at all?

In general you put values into variables to use them later. Sometimes, you
forget what you placed there and may get an unexpected result (it may even go
unnoticed for some time). For instance it makes more sense to use integer
instead of string for some operations (e.g. I may wish to multiply `3` by `3`
not `"three"` by `"three"`).

```jl
s = """
x = 3
x * x # works as you intended
"""
sco(s)
```

```jl
s = """
x = "three"
x * x # the result may be surprising
"""
sco(s)
```

> **_Note:_** Julia gives you a standard set of mathematical operators, like
> addition (`+`), subtraction (`-`), multiplication (`*`), division (`/`) and
> more (see the [docs](https://docs.julialang.org/en/v1/base/math/#math-ops)).

The latter is an example of a so called [string
concatenation](https://docs.julialang.org/en/v1/manual/strings/#man-concatenation),
it may be useful (as we will see later in this book), but probably it is not
what you wanted.

To avoid such unexpected events (especially if instead of `*` you use your own
function, see @sec:julia_language_functions) you would like a guarding angel
that watches over you. This is what Julia does when you require it by using
type declarations (for now you need to take my word for it).

Moreover, declaring types sometimes may make your code run faster.

Additionally, some
[IDEs](https://en.wikipedia.org/wiki/Integrated_development_environment) work
better (improved code completions, and hints) when you place type declarations
in your code.

*Personally, I like to use type declarations in my own functions (see the
upcoming @sec:julia_language_functions) to help me reason what they do. At first
I write functions without types at all (it's easier that way). Once I got them
running I add the types to them (it us useful for future reference, code
maintenance, etc.).*

### Meaningful variable names {#sec:julia_meaningful_variable_names}

**Name your variables well**. The variable names I used before are horrible
(*mea culpa, mea culpa, mea maxima culpa*). We use named variables (like `x =
1`) instead of 'loose' variables (you can type `1` alone in a script file and
execute that line) to use them later.

You can use them later in time (reading and editing your code tomorrow or next
month/year) or in space (using it 30 or 300 lines below). If so, the names need
to be memorable (actually just meaningful will do :D). So whenever possible use:
`studentAge = 19`, `bookTitle = "Dune"` (grammatical correctness is not that
important) instead of `x = 19`, `y = "Dune"`.

You may want to check Julia's Docs for the [allowed variable
names](https://docs.julialang.org/en/v1/manual/variables/#man-allowed-variable-names)
and their recommended [stylistic
conventions](https://docs.julialang.org/en/v1/manual/variables/#Stylistic-Conventions)
(for now, always start with a small letter, and use alphanumeric characters from
the Latin alphabet). Personally, I prefer to use
[camelCaseStyle](https://en.wikipedia.org/wiki/Camel_case) so this is what
you're gonna see here.

### Floats comparisons {#sec:julia_float_comparisons}

**Be careful with `=` sign**. In mathematics `=` means `equal to` and `≠` means
`not equal to`. In programming `=` is usually an assignment operator (see
@sec:julia_language_variables before). If you want to compare for equality you
should use `==` (for `equal to`) and (`!=` for `not equal to`), examples:

```jl
s = """
1 == 1
"""
sco(s)
```


```jl
s = """
2 == 1
"""
sco(s)
```

```jl
s = """
2.0 != 1.0
"""
sco(s)
```

```jl
s = """
# comparing float (1.0) with integer (1)
1.0 != 1
"""
sco(s)
```

```jl
s = """
# comparing integer (2) with float (2.0)
2 == 2.0
"""
sco(s)
```

Be careful though because the comparisons of two floats are sometimes tricky,
e.g.

```jl
s = """
(0.1 * 3) == 0.3
"""
sco(s)
```

It is `false` since float numbers cannot be represented exactly in binary (for
techinical details see [this StackOverflow's
thread](https://stackoverflow.com/questions/8604196/why-0-1-3-0-3)). This is how
my computer sees `0.1 * 3`

```jl
s = """
0.1 * 3
"""
sco(s)
```

and `0.3`

```jl
s = """
0.3
"""
sco(s)
```

The same caution applies to other comparison operators, like:

- `x > y` (`x` is greater than `y`),
- `x >= y` (`x` is greater than or equal to `y`),
- `x < y` (`x` is less than `y`),
- `x <= y` (`x` is less than or equal to `y`).

*We will see how to deal with the lack of precision in comparisons later (see
@sec:julia_language_exercise2).*

### Other types {#sec:julia_other_types}

There are also other types (see [Julia's
Docs](https://docs.julialang.org/en/v1/manual/types/)), but we will use mostly
those mentioned in this chapter, i.e.:

- [floats](https://en.wikipedia.org/wiki/Floating-point_arithmetic)
- [integers](https://en.wikipedia.org/wiki/Integer)
- [strings](https://en.wikipedia.org/wiki/String_(computer_science))
- [booleans](https://en.wikipedia.org/wiki/Boolean_data_type)

The briefly aforementioned strings contain text of any kind. They are denoted by
(optional type declaration) `::String` and you type them within double quotation
marks (`"any text"`). If you ever want to place `"` in a string you need to use
`\` (backslash) before it [otherwise Julia will terminate the string on the
second `"` it encounters and throw an error (because it will be confused by the
remaining, stray, characters)]. Moreover, if you wish the text to be displayed
in the next line (e.g. in a figure's title like the one in
@sec:statistics_intro_tennis_theor_calc) you should place `\n` in it. For
instance:

```
title = "I enjoy reading\n\"Title of my favorite book\"."
println(title)
```

Displays:

```
I enjoy reading
"Title of my favorite book".
```

on the screen.

A string is composed of individual characters (d'ooh!). An individual character
(type `::Char`) is enclosed between single quotation marks, e.g. `'a'`, `'b'`,
`'c'`, ..., `'z'` (also uppercase) are individual characters. So whenever you
want to type a single character you got a choice, either use `'a'` (single
`Char`) or `"a"` (`String` composed of one `Char`). But when typing two or more
characters that are 'glued' together you must use double quotations (`"ab"`). In
the rest of the book we will focus mostly on strings, still, a bit more
knowledge never hurt anyone (or did it?). In Solution to exercise 5 from
@sec:compare_contin_data_ex5_solution, we will see how to easily generate a
complete alphabet (or a part of it, if you ever need one) with `Char`s. If you
want to know more about the
[Strings](https://docs.julialang.org/en/v1/manual/strings/#man-characters) and
[Chars](https://docs.julialang.org/en/v1/manual/strings/#man-characters) just
click the links to the docs that are to be found in this sentence.

The last of the earlier referenced types (boolean) is denoted as `::Bool` and
can take only two values: `true` or `false` (see the results of the comparison
operations above in @sec:julia_float_comparisons). `Bool`s are often used in
decision making in our programs (see the upcoming
@sec:julia_language_decision_making) and can be used with a small set of
[logical
operators](https://docs.julialang.org/en/v1/manual/mathematical-operations/#Boolean-Operators)
like AND (`&&`)

```jl
s = """
# && returns true only if both values are true
# those return false:
# true && false
# false && true
# false && false
# this returns true:
true && true
"""
sco(s)
```

OR (`||`)

```jl
s = """
# || returns true if any value is true
# those return true:
# true || false
# false || true
# true || true
# this returns false:
false || false
"""
sco(s)
```

and NOT (`!`)

```jl
s = """
# ! flips the value to the opposite
# returns false: !true
# returns true
!false
"""
sco(s)
```

### Collections {#sec:julia_collections}

Not only do variables may store a single value but they can also store their
collections. The collection types that we will discuss here are `Vector`
(technically `Vector` is a one dimensional `Array` but don't worry about that
now), `Array` and `struct` (it is more like a composite type, but again at that
moment we will not be bothered by that fact).

### Vectors {#sec:julia_vectors}

```jl
s = """
myMathGrades = [3.5, 3.0, 3.5, 2.0, 4.0, 5.0, 3.0]
"""
sco(s)
```

Here I declared a variable that stores my mock grades.

The variable type is `Vector` of numbers (each of type `Float64`, run
`typeof(myMathGrades)` to check it). I could have declared its type explicitly
as `::Vector{Float64}`. Instead I decided to let Julia figure it out.

You can think of a vector as a [rectangular
cuboid](https://en.wikipedia.org/wiki/Rectangular_cuboid) box with
drawers (smaller [cube](https://en.wikipedia.org/wiki/Cube) shaped boxes). The
drawers are labeled with consecutive numbers (indices) starting at 1 (we will
get to that in a moment). The variable contains `jl length(myMathGrades)` grades
in it, which you can check by typing and executing `length(myMathGrades)`.

You can retrieve a single element of the vector by typing `myMathGrades[i]`
where `i` is some integer (the aforementioned index). For instance:

```jl
s = """
myMathGrades[3] # returns 3rd element
"""
sco(s)
```

or

```jl
s = """
myMathGrades[end] # returns last grade
# equivalent to: myMathGrades[7], but here I don't have to count elements
"""
sco(s)
```

Be careful though, if You type a non-existing index like `myMathGrades[-1]`,
`myMathGrades[0]` or `myMathGrades[10]` you will get an error
(e.g. `BoundsError: attempt to access 7-element Vector{Float64} at index [0]`).

You can get a slice (a part) of the vector by typing

```jl
s = """
myMathGrades[[2, 5]] # returns Vector with 2nd, and 5th element
"""
sco(s)
```

or

```jl
s = """
myMathGrades[[2, 3, 4]] # returns Vector with 2nd, 3rd, and 4th element
"""
sco(s)
```

or simply

```jl
s = """
myMathGrades[2:4] # returns Vector with three grades (2nd, 3rd, and 4th)
# the slicing is [inclusive:inclusive]
"""
sco(s)
```

The `2:4` is Julia's
[range](https://docs.julialang.org/en/v1/base/math/#Base.range) generator, with
default syntax `start:stop` (both of which are inclusive). Assume that under the
hood it generates a vector (check it by using
[collect](https://docs.julialang.org/en/v1/base/collections/#Base.collect-Tuple{Type,%20Any})
function, e.g, just run `collect(2:4)`). So, it gives us the same result as
writing `myMathGrades[[2, 3, 4]]` by hand. However, the range syntax is more
convenient (less typing especially for broad ranges). Now, let's say I want to
print every other grade out of 100 grades, then I can go with
`oneHunderedGrades[1:2:end]` and voila, a magic happened thanks to the
`start:step:stop` syntax (`collect(1:2:end)` returns a vector of indices like
`[1, 3, 5, 7, ..., 97, 99]`).

One last remark, You can change the elements that are in the vector like this.

```jl
s = """
myMathGrades[1] = 2.0
myMathGrades
"""
sco(s)
```

or like that

```jl
s = """
myMathGrades[2:3] = [5.0, 5.0]
myMathGrades
"""
sco(s)
```

Again, remember about proper indexing. What you put inside (right side) should
be compatible with indexing (left side), e.g `myMathGrades[2:3] = [2.0, 2.0,
2.0]` will produce an error (placing 3 numbers to 2 slots).

### Arrays {#sec:julia_arrays}

A `Vector` is actually a special case of an `Array`, a multidimensional
structure that holds data. The most familiar (and useful) form of it is a
two-dimensional `Array` (also called `Matrix`). It has rows and
columns. Previously I stored my math grades in a `Vector`, but most likely I
would like a place to keep my other grades. Here, I create an array that stores
my grades from math (column1) and chemistry (column2).

```jl
s = """
myGrades = [3.5 3.0; 4.0 3.0; 5.0 2.0]
myGrades
"""
sco(s)
```

I separated the values between columns with a space character and indicated a
new row with a semicolon. Typing it by hand is not very interesting, but they
come in handy as we will see later in the book.

As with vectors I can use indexing to get specific element(s) from a matrix, e.g.

```jl
s = """
myGrades[[1, 3], 2] # returns second column (rows 1 and 3) as Vector
"""
sco(s)
```

or

```jl
s = """
myGrades[:, 2] # returns second column (and all rows)
"""
sco(s)
```

Above, the `:` symbol means all indices in a row.

```jl
s = """
myGrades[1, :] # returns first row (and all columns)
"""
sco(s)
```

By analogy, the `:` symbol means all indices in a column.

```jl
s = """
myGrades[3, 2] # returns a value from third row and second column
"""
sco(s)
```

I can also use the indexing to replace a particular element in a `Matrix`. For
instance.

```jl
s = """
myGrades[3, 2] = 5
myGrades
"""
sco(s)
```

or

```jl
s = """
myGrades[1:2, 1] = [5, 5]
myGrades
"""
sco(s)
```

As with a `Vector` also here you must pay attention to proper indexing.

When dealing with `Array`s (or `Vector`s which are one dimensional arrays) one
needs to be cautious not to change their contents accidentally.

In case of atomic variables the values are assigned/passed as copies (i.e. a
new number `3` is put to the box, the old number in the variable `x` is
unaffected). Observe.

```jl
s = """
x = 2
y = x # y contains the same value as x
y = 3 # y is assigned a new value, x is unaffected

(x, y)
"""
sco(s)
```

> **_Note:_** The `(x, y)` returns `Tuple` (see [Tuple in the
> docs](https://docs.julialang.org/en/v1/manual/functions/#Tuples)) and it is
> there to show both `x` and `y` in one line. You may think of `Tuple` as
> something similar to `Vector` but written with parenthesis `()` instead of
> square brackets `[]`. Additionally, you cannot modify elements of a tuple
> after it was created (so, if you got `z = (1, 2, 3)`, then `z[2]` will work
> fine (since it just returns an element), but `z[2] = 8` will produce an
> error). Technically speaking, you could just type `x, y` and run the line to
> get a tuple (test it out), but I prefer to use parenthesis to be explicit.

However, the arrays are assigned/passed as references.

```jl
s = """
xx = [2, 2]
yy = xx # yy refers to the same box of drawers as xx
yy[1] = 3 # new value 3 is put to the first drawer of the box pointed by yy

# both xx, and yy are changed, cause both point at the same box of drawers
(xx, yy)
"""
sco(s)
```

As stated in the comments to the code snippet above, here both `xx` and `yy`
variables point on (reference to) the same box of drawers. So, when we change a
value in one drawer, then both variables reflect the change. If we want to avoid
that we can, e.g. make a
[copy](https://docs.julialang.org/en/v1/base/base/#Base.copy) of the
`Vector`/`Array` like so:

```jl
s = """
xx = [2, 2]
# yy refers to a different box of drawers
# with the same (copied) numbers inside
yy = copy(xx)
yy[1] = 3 # this does not affect xx

(xx, yy)
"""
sco(s)
```

### Structs {#sec:julia_structs}

Another Julia's type worth mentioning is
[struct](https://docs.julialang.org/en/v1/base/base/#struct). It is a composite
type (so it contains other type(s) inside).

Let's say I want to have a thing that resembles fractions that we know from
mathematics. It should allow to store the data for numerator and denominator
($\frac{numerator}{denominator}$). Let's use `struct` for that

```jl
s = """
struct Fraction
	numerator::Int
	denominator::Int
end

fr1 = Fraction(1, 2)
fr1
"""
sco(s)
```

> **_Note:_** `Structs`' names are usually defined with a capital
> letter.

If I ever wanted to get a component of the `struct` I can use the dot syntax,
like so

```jl
s = """
fr1.numerator
"""
sco(s)
```

> **_Note:_** If you type `fr1.` and press TAB key then you should see a hint
> with the available field names. You may choose one with arrow keys and confirm
> it with Enter key.

or

```jl
s = """
fr1.denominator
"""
sco(s)
```

Of course, as you probably have guessed, there is no need to define your own
type for fraction since Julia is already equipped with one. It is
[Rational](https://docs.julialang.org/en/v1/base/numbers/#Base.Rational). For
convenience the fraction is written as

```jl
s = """
1//2 # equivalent to: Rational(1, 2)
"""
sco(s)
```

Notice the double slash character (`//`).

In general, `struct`s are worth knowing. A lot of libraries (see
@sec:julia_language_libraries) define their own `struct` objects and we may want
to extract their content using the dot syntax (as we probably sometimes will in
the upcoming sections).

OK, enough about the variables, time to meet functions.

## Functions {#sec:julia_language_functions}

Functions are doers, i.e encapsulated pieces of code that do things for
us. Optimally, a function should be single minded, i.e. doing one thing only and
doing it well. Moreover since they do stuff their names should contain
[verbs](https://en.wikipedia.org/wiki/Verb) (whereas variables' names should be
composed of [nouns](https://en.wikipedia.org/wiki/Noun)).

We already met one of many Julia's built in functions, namely `println` (see
@sec:julia_is_simple). As the name suggests it prints something (like a text) to
the [standard
output](https://en.wikipedia.org/wiki/Standard_streams#Standard_output_(stdout)).

### Mathematical functions {#sec:mathematical_functions}

We can also define some functions on our own:

```jl
s = """
function getRectangleArea(lenSideA::Real, lenSideB::Real)::Real
	return lenSideA * lenSideB
end
"""
sco(s)
```

Here I declared Julia's version of a [mathematical
function](https://en.wikipedia.org/wiki/Function_(mathematics)). It is called
`getRectangleArea` and it calculates (surprise, surprise) the
[area of a rectangle](https://en.wikipedia.org/wiki/Rectangle#Formulae).

To do that I used a keyword `function`. The `function` keyword is followed by
the name of the function (`getRectangleArea`). Inside the parenthesis are
arguments of the function. The function accepts two arguments `lenSideA` (length
of one side) and `lenSideB` (length of the other side) and calculates the area
of a rectangle (by multiplying `lenSideA` by `lenSideB`). Both `lenSideA` and
`lenSideB` are of type `Real`. It is Julia's representation of a [real
number](https://en.wikipedia.org/wiki/Real_number), it encompasses (it's kind of
a supertype), among others, `Int` and `Float64` that we encountered before. The
ending of the first line, `)::Real`, signifies that the function will return a
value of type `Real`. The stuff that function returns is preceded by the
`return` keyword. The function ends with the `end` keyword.

> **_Note:_** A Julia's function does not need the `return` keyword since it
> returns the result of its last expression. Still, I prefer to be explicit.

Time to run our function and see how it works.

```jl
s = """
getRectangleArea(3, 4)
"""
sco(s)
```

```jl
s = """
getRectangleArea(1.5, 2)
"""
sco(s)
```

> **_Note:_** In some other languages, e.g. Python, you could use the function
> like: `getRectangleArea(3, 4)`, `getRectangleArea(lenSideA=3, lenSideB=4)` or
> `getRectangleArea(lenSideB=4, lenSideA=3)`. However, for performance reasons a
> Julia's function accepts arguments in a positional manner. Therefore, here
> you may only use `getRectangleArea(3, 4)` form. Internally, the first argument
> (`3`) will be assigned to `lenSideA` and the second (`4`) to `lenSideB` inside
> the `getRectangleArea` function.

Hmm, OK, I got `getRectangleArea` and what if I need to calculate the [area of a
square](https://en.wikipedia.org/wiki/Square#Perimeter_and_area). You got it.

```jl
s = """
function getSquareArea(lenSideA::Real)::Real
	return getRectangleArea(lenSideA, lenSideA)
end
"""
sco(s)
```

> **_Note:_** The argument (`lenSideA`) of `getSquareArea` is only known inside
> the function. Another function can use the same name for its arguments and it
> will not collide with this one. For instance,
> `getRectangleArea(lenSideA::Real, lenSideB::Real)` will receive the same
> number twice, which `getSquareArea` knows as `lenSideA`, but
> `getRectangleArea` will see only the numbers (it will receive their copies)
> and it will name them `lenSideA` and `lenSideB` for its own usage.

Here I can either write its body from scratch (`return lendSideA * lenSideA`) or
reuse (as I did) our previously defined `getRectangleArea`. Lesson to be learned
here, functions can use other functions. This is especially handy if those inner
functions are long and complicated. Anyway, let's see how it works.

```jl
s = """
getSquareArea(3)
"""
sco(s)
```

Appears to be working just fine.

### Functions with generics {#sec:functions_with_generics}

Now, let's say I want a function `getFirstElt` that accepts a vector and returns
its first element (vectors and indexing were briefly discussed in
@sec:julia_collections).

```jl
s = """
# works fine for non-empty vectors
function getFirstElt(vect::Vector{Int})::Int
	return vect[1]
end
"""
sc(s)
```

It looks OK (test it, e.g. `getFirstElt([1, 2, 3]`). However, the problem is
that it works only with integers (or maybe not, test it out). How to make it
work with any type, like `getFirstElt(["Eve", "Tom", "Alex"])` or
`getFirstElt([1.1, 2.2, 3.3])`?

One way is to declare separate versions of the function for different types of
inputs, i.e.

```jl
s = """
function getFirstElt(vect::Vector{Int})::Int
	return vect[1]
end

function getFirstElt(vect::Vector{Float64})::Float64
	return vect[1]
end

function getFirstElt(vect::Vector{String})::String
	return vect[1]
end
"""
sco(s)
```

> **_Note:_** The function's name is exactly the same in each case. Julia will
> choose the correct version (aka method, see the output of the code snippet
> above) based on the type of the argument (`vect`) send to the function,
> e.g. `getFirstElt([1, 2, 3])`, `getFirstElt([1.1, 2, 3.0])`, and
> `getFirstElt(["a", "b", "c"])` for the three versions above, respectively.

But that is too much typing (I retyped a few times virtually the same code). The
other way is to use no type declarations.

```jl
s = """
function getFirstEltVer2(vect)
	return vect[1]
end
"""
sc(s)
```

It turns out that you don't have to declare function types in Julia (just like
in the case of variables, see @sec:julia_optional_type_declaration) and a
function may work just fine.

Still, a die hard 'typist' (if I may call a person this way) would probably use
so called generic types, like

```jl
s = """
function getFirstEltVer3(vect::Vector{T})::T where T
	return vect[1]
end
"""
sc(s)
```

Here we said that the vector is composed of elements of type `T` (`Vector{T}`)
and that the function will return type `T` (see `)::T`). By typing `where T` we
let Julia know that `T` is our custom type that we just made up and it can be
any Julia's built in type whatsoever (but what it is exactly will be determined
once the function is used). We needed to say `where T` otherwise Julia would
throw an error (since it wouldn't be able to find its own built in type
`T`). Anyway, we could replace `T` with any other letter (or e.g. two letters)
of the alphabet (`A`, `D`, or whatever) and the code would still work.

One last remark, it is customary to write generic types with a single capital
letter. Notice that in comparison to the function with no type declarations
(`getFirstEltVer2`) the version with generics (`getFirstEltVer3`) is more
informative. You know that the function accepts a vector of some elements, and
you know that it returns a value of the same type as the elements that build
that vector.

Of course, that last function we wrote for fun (it was fun for me, how about
you?). In reality Julia already got a function with a similar functionality (see
[Base.first](https://docs.julialang.org/en/v1/base/collections/#Base.first)).

> **_Note:_** Functions from Base package, like `Base.first` mentioned above may
> be used in a shorter form (without the prefix) like this: `first([1, 2, 3,
> 4])`.

Anyway, as I wrote before if you don't want to use types then don't, Julia gives
you a choice. When I begun to write my first computer programs, I preferred to
use programming languages that didn't require types. However, nowadays I prefer
to use them for the reasons similar to those described in
@sec:julia_optional_type_declaration so be tolerant and bear with me.

### Functions operating on structs {#sec:functions_operating_on_structs}

Functions may also work on custom types like the ones created with `struct`.
Do you still remember our `Fraction` type from @sec:julia_structs? I hope so.

Let's say I want to define a function that adds two fractions. I can proceed
like so

```jl
s = """
function add(f1::Fraction, f2::Fraction)::Fraction
	newDenom::Int = f1.denominator * f2.denominator
	f1NewNom::Int = newDenom / f1.denominator * f1.numerator
	f2NewNom::Int = newDenom / f2.denominator * f2.numerator
	newNom::Int = f1NewNom + f2NewNom
	return Fraction(newNom, newDenom)
end

add(Fraction(1, 3), Fraction(2, 6))
"""
sco(s)
```

> **_Note:_** The variables `newDenom`, `f1NewNom`, `f2NewNom`, `newNom` are
> local, e.g. they are created and exist only inside the function when it is
> called (like here with `add(Fraction(1, 3), Fraction(2, 6))`) and do not
> affect the variables outside the function even if they happened to have the
> same names.

Works correctly, but the addition algorithm is not optimal (for now you don't
have to worry too much about the function's hairy internals). Luckily the built
in `Rational` type (@sec:julia_structs) is more polished. Observe

```jl
s = """
# equivalent to: Rational(1, 3) + Rational(2, 6)
1//3 + 2//6
"""
sco(s)
```

Much better ($\frac{12}{18} = \frac{12 / 6}{18 / 6} = \frac{2}{3}$). Of course
also other operations like subtraction, multiplication and division work for
`Rational`.

We will meet some functions operating on `struct`s when we use custom made
libraries (e.g. `Htests.pvalue` that works on the object (struct) returned by
`Htests.OneWayANOVATest` in the upcoming
@sec:compare_contin_data_post_hoc_tests). Again, for now don't worry about it
too much.

### Functions modifying arguments {#sec:functions_modifying_arguments}

Previously (see @sec:julia_collections) we said that we can change elements of
a vector. Sometimes even unintentionally, because, e.g. we may forget that
`Arrays`s/`Vector`s are assigned/passed by references (as mentioned in
@sec:julia_arrays).

```jl
s = """
function wrongReplaceFirstElt(
	ints::Vector{Int}, newElt::Int)::Vector{Int}
	ints[1] = newElt
	return ints
end

xx = [2, 2]
yy = wrongReplaceFirstElt(xx, 3)

# unintentionally we changed xx defined outside a function
(xx, yy)
"""
sco(s)
```

Let's try to re-write the function that changes the first element improving
upon it at the same time.

```jl
s = """
# the function works fine for non-empty vectors
function replaceFirstElt!(vect::Vector{T}, newElt::T) where T
	vect[1] = newElt
	return nothing
end
"""
sc(s)
```

> **_Note:_** The function's name ends with `!` (exclamation mark). This is one
> of the Julia's conventions to mark a function that modifies its arguments.

In general, you should try to write a function that does not modify its
arguments (as modification often causes errors, especially in big
programs). However, such modifications are sometimes useful, therefore Julia
allows you to do so, but you should always be explicit about it. That is why it
is customary to end the name of such a function with `!` (exclamation mark draws
attention).

Additionally, observe that `T` can be of any type, but we require `newElt` to be
of the same type as the elements in `vect`. Moreover, since we modify the
arguments we wrote `return nothing` (to be explicit we do not return a thing)
and removed returned type after the function's name, i.e. we used [`) where T`
instead of `)::Vector{T} where T`].

Let's see how the function works.

```jl
s = """
x = [1, 2, 3]
y = replaceFirstElt!(x, 4)
(x, y)
"""
sco(s)
```

Let me finish this subsection by mentioning a classical example of a built-in
function that modifies its argument. The function is
[push!](https://docs.julialang.org/en/v1/base/collections/#Base.push!). It adds
elements to a collection (e.g. `Array`s, or `Vector`s). Observe:

```jl
s = """
xx = [] # empty vector
push!(xx, 1, 2) # now xx is [1, 2]
push!(xx, 3) # now xx is [1, 2, 3]
push!(xx, 4, 5) # now xx is [1, 2, 3, 4, 5]
"""
sc(s)
```

I mentioned it since that was my favorite way of constructing a vector (to start
with an empty vector and add elements one by one with a `for` loop that we will
meet in @sec:julia_language_for_loops) back in the day when I started my
programming journey. Nowadays I do it a bit differently, but I thought it would
be good to mention it in case you find it useful while solving some exercises
from this book.

### Side Effects vs Returned Values {#sec:side_effects_vs_returned_values}

Notice that so far we encountered two types of Julia's functions:

- those that are used for their side effects (like `println`)
- those that return some results (like `getRectangleArea`)

The difference between the two may not be clear while we use the interactive
mode. To make it more obvious let's put them in the script like so:

```
# file: sideEffsVsReturnVals.jl

# you should define a function before you call it
function getRectangleArea(lenSideA::Number, lenSideB::Number)::Number
    return lenSideA * lenSideB
end

println("Hello World!")

getRectangleArea(3, 2) # calling the function
```

After running the code from terminal:

```bash
cd folder_with_the_sideEffsVsReturnVals.jl
julia sideEffsVsReturnVals.jl
```

I got printed on the screen:

```
Hello World!
```

That's it. I got only one line of output, the rectangle area seems to be
missing. We must remember that a computer does only what we tell it to do,
nothing more, nothing less. Here we said:

- print "Hello World!" to the screen (actually [standard
  output](https://en.wikipedia.org/wiki/Standard_streams#Standard_output_(stdout)))
- calculate and return the area of the rectangle (but we did nothing with it)

In the second case the result went into the void ("If a tree falls in a forest
and no one is around to hear it, does it make a sound?").

If we want to print both pieces of information on the screen we should modify
our script to look like:

```
# file: sideEffsVsReturnVals.jl

# you should define a function before you call it
function getRectangleArea(lenSideA::Number, lenSideB::Number)::Number
    return lenSideA * lenSideB
end

println("Hello World!")

# println takes 0 or more arguments (separated by commas)
# if necessary arguments are converted to strings and printed
println("Rectangle area = ", getRectangleArea(3, 2), "[cm^2]")
```

Now when we run `julia sideEffsVsReturnVals.jl` from terminal, we get:

```
Hello World!
Rectangle area = 6 [cm^2]
```

More information about functions can be found, e.g. [in this section of Julia's
Docs](https://docs.julialang.org/en/v1/manual/functions/).

If You ever encounter a built in function that you don't know, you may always
search for it in [the docs](https://docs.julialang.org/en/v1/) (search box: top
left corner of the page).

## Decision Making {#sec:julia_language_decision_making}

In everyday life people have to make decisions and so do computer programs. This
is the job for `if ... elseif ... else` constructs.

### If ..., or Else ... {#sec:julia_language_if_else}

To demonstrate decision making in action let's say I want to write a function
that accepts an integer as an argument and returns its textual
representation. Here we go.

```jl
s = """
function turnInt2string(num::Int)::String
	if num == 0
		return "zero"
	elseif num == 1
		return "one"
	elseif num == 2
		return "two"
	else
		return "three or above"
	end
end

(turnInt2string(2), turnInt2string(5)) # a tuple with results
"""
sco(s)
```

The general structure of the construct goes like this:

```
# pseudocode, don't run this snippet
if (condition_that_returns_Bool)
	what_to_do
elseif (another_condition_that_returns_Bool)
	what_to_do
elseif (another_condition_that_returns_Bool)
	what_to_do
else
	what_to_do
end
```

As mentioned in @sec:julia_other_types `Bool` type can take one of two values
`true` or `false`. The code inside `if`/`elseif` clause runs only when the
condition is `true`. You can have any number of `elseif` clauses. Only the code
for the first `true` clause runs. If none of the previous conditions matches
(each and every one is `false`) the code in the `else` block is executed. Only
`if` and `end` keywords are obligatory, the rest is not, so you may use

```
# pseudocode, don't run this snippet
if (condition_that_returns_Bool)
	what_to_do
end
```

or

```
# pseudocode, don't run this snippet
if (condition_that_returns_Bool)
	what_to_do
else
	what_to_do
end
```

or

```
# pseudocode, don't run this snippet
if (condition_that_returns_Bool)
	what_to_do
elseif (condition_that_returns_Bool)
	what_to_do
else
	what_to_do
end
```

or

```
# pseudocode, don't run this snippet
if (condition_that_returns_Bool)
	what_to_do
elseif (condition_that_returns_Bool)
	what_to_do
elseif (condition_that_returns_Bool)
	what_to_do
else
	what_to_do
end
```

or ..., nevermind, I think you got the point.

Below I place another example of a function using `if/elseif/else` construct (in
order to remember it better).

```jl
s = """
# works fine for non-empty vectors
function getMin(vect::Vector{Int}, isSortedAsc::Bool)::Int
	if isSortedAsc
		return vect[1]
	else
		sortedVect::Vector{Int} = sort(vect)
		return sortedVect[1]
	end
end

x = [1, 2, 3, 4]
y = [3, 4, 1, 2]

(getMin(x, true), getMin(y, false))
"""
sco(s)
```

Here I wrote a function that finds the minimal value in a vector of integers. If
the vector is sorted in the ascending order it returns the first element. If it
is not, it sorts the vector using the built in
[sort](https://docs.julialang.org/en/v1/base/sort/#Base.sort) function and
returns its first element (*this may not be the most efficient method but it
works*). Note that the `else` block contains two lines of code (it could contain
more if necessary, and so could `if` block). I did this for demonstrative
purposes. Alternatively instead those two lines (in the `else` block) one could
write `return sort(vect)[1]` and it would work just fine.

### Ternary expression {#sec:ternary_expression}

If you need only a single `if ... else` in your code, then you may prefer to
replace it with ternary operator. Its general form is `condition_or_Bool ?
result_if_true : result_if_false`.

Let me rewrite `getMin` from @sec:julia_language_if_else using ternary expression.

```jl
s = """
function getMin(vect::Vector{Int}, isSortedAsc::Bool)::Int
	return isSortedAsc ? vect[1] : sort(vect)[1]
end

x = [1, 2, 3, 4]
y = [3, 4, 1, 2]

(getMin(x, true), getMin(y, false))
"""
sco(s)
```

Much less code, works the same. Still, I would not overuse it. For more than a
single condition it is usually harder to write, read, and process in your head
than the good old `if/elseif/else` block.

### Dictionaries {#sec:julia_language_dictionaries}

[Dictionaries in
Julia](https://docs.julialang.org/en/v1/base/collections/#Dictionaries) are a
sort of mapping. Just like an ordinary dictionary is a mapping between a word
and its definition. Here, we say that the mapping is between `key` and
`value`. For instance let's say I want to define an English-Polish dictionary.

```jl
s = """
engPolDict::Dict{String, String} = Dict("one" => "jeden", "two" => "dwa")
engPolDict # the key order is not preserved on different computers
"""
sco(s)
```

Here I defined a dictionary of type `Dict{String, String}`, so, both `key` and
`value` are of textual type (`String`). The order of the keys is not preserved
(this data structure cares more about lookup performance and not about the order
of the keys). Therefore, you may see a different order of items after executing
the code on your computer.

If we want to now how to say "two" in Polish I type `aDict[key]` (if the key is
not there you will get an error), e.g.

```jl
s = """
engPolDict["two"]
"""
sco(s)
```

To add a new value to a dictionary (or to update the existing value) write
`aDict[key] = newVal`. Right now the key "three" does not exist in `engPolDict`
so I would get an error (check it out), but if I type:

```jl
s = """
engPolDict["three"] = "trzy"
"""
sco(s)
```

Then I create (or update if it was already there) a key-value mapping.

Now, to avoid getting errors due to non-existing keys I can use the built in
[get](https://docs.julialang.org/en/v1/base/collections/#Base.get) function.
You use it in the form `get(collection, key, default)`, e.g. right now the word
"four" (key) is not in a dictionary so I should get an error (check it out). But
wait, there is `get`.

```jl
s = """
get(engPolDict, "four", "not found")
"""
sco(s)
```

OK, what anything of it got to do with `if/elseif/else` and decision making.
The thing is that if you got a lot of decisions to make then probably you will
be better off with a dictionary. Compare

```jl
s = """
function translEng2polVer1(engWord::String)::String
	if engWord == "one"
		return "jeden"
	elseif engWord == "two"
		return "dwa"
	elseif engWord == "three"
		return "trzy"
	elseif engWord == "four"
		return "cztery"
	else
		return "not found"
	end
end

(translEng2polVer1("three"), translEng2polVer1("ten"))
"""
sco(s)
```

with

```jl
s = """
function translEng2polVer2(engWord::String,
                           aDict::Dict{String, String} = engPolDict)::String
	return get(aDict, engWord, "not found")
end

(translEng2polVer2("three"), translEng2polVer2("twelve"))
"""
sco(s)
```

> **_Note:_** Dictionaries like Arrays (see @sec:julia_arrays) are passed by
> references

In `translEng2polVer2` I used a so called [optional
argument](https://docs.julialang.org/en/v1/manual/functions/#Optional-Arguments)
for `aDict` (`aDict::Dict{String, String} = engPolDict`). This means that if the
function is provided without the second argument then `engPolDict` will be used
as its second argument. If I defined the function as
`translEng2polVer2(engWord::String, aDict::Dict{String, String})` then while
running the function I would have to write `(translEng2polVer2("three",
engPolDict), translEng2polVer2("twelve", engPolDict))`. Of course, I may prefer
to use some other English-Polish dictionary (perhaps the one found on the
internet) like so `translEng2polVer2("three", betterEngPolDict)` instead of
using the default `engPolDict` we got here.

*In general, the more `if ... elseif ... else` comparisons you got to do the
better off you are when you use dictionaries (especially that they could be
written by someone else, you just use them). Still, in the rest of the book we
will probably use dictionaries for data storage and a quick lookup.*

OK, enough of that. If you want to know more about conditional evaluation check
[this part of Julia's
docs](https://docs.julialang.org/en/v1/manual/control-flow/#man-conditional-evaluation).

## Repetition {#sec:julia_language_repetition}

Julia, and computers in general, are good at doing boring, repetitive tasks for
us without a word of complaint (and they do it much faster than we do). Let's
see some constructs that help us with it.

### For loops {#sec:julia_language_for_loops}

A [for loop](https://en.wikipedia.org/wiki/For_loop) is a standard construct
present in many programming languages that does the repetition for us. Its
general form in Julia is:

```
# pseudocode, do not run this snippet
for i in sequence
	# do_something_useful
end
```

The loop is enclosed between `for` and `end` keywords and repeats some specific
action(s) (`# do_something_useful`) for every element of a `sequence`. On each
turnover of a loop consecutive elements of a sequence are referred to by `i`.

> **_Note:_** I could have assigned any name, like: `j`, `k`, `whatever`, it
> would work the same. Still, `i` and `j` are quite common in [for
> loops](https://en.wikipedia.org/wiki/For_loop).

Let's say I want a program that will print [hip hip
hooray](https://en.wikipedia.org/wiki/Hip_hip_hooray) many times for my friend
that celebrates some success. I can proceed like this.

```jl
s = """
function printHoorayNtimes(n::Int)
	@assert (n > 0) "n needs to be greater than 0"
	for _ in 1:n
		println("hip hip hooray!")
	end
	return nothing
end
"""
sc(s)
```

Go ahead, run it (e.g. `printHoorayNtimes(3)`).

Notice two new elements. Here it makes no sense for `n` to be less than or equal
to 0. Hence, I used
[\@assert](https://docs.julialang.org/en/v1/base/base/#Base.@assert) construct
to test it and print an error message (`"n needs to be greater than 0"`) if it
is. The `1:n` is a range similar to the one we used in
@sec:julia_vectors. Here, I used `_` instead of `i` in the example above (to
signal that I don't plan to use it further).

OK, how about another example. You remember `myMathGrades`, right?

```jl
s = """
myMathGrades = [3.5, 3.0, 3.5, 2.0, 4.0, 5.0, 3.0]
"""
sc(s)
```

Now, since the end of the school year is coming then I would like to know my
[average](https://en.wikipedia.org/wiki/Arithmetic_mean) (likely this will be my
final grade). In order to get that I need to divide the sum by the number of
grades. First the sum.

```jl
s = """
function getSum(nums::Vector{<:Real})::Real
	total::Real = 0
	for i in 1:length(nums)
		total = total + nums[i]
	end
	return total
end

getSum(myMathGrades)
"""
sco(s)
```

A few explanations regarding the new bits of code here.

In the arguments list I wrote `::Vector{<:Real}`. Which means that each element
of nums is a subtype (`<:`) of the type `Real` (which includes integers and
floats). I declared a `total` and initialized it to 0. Then in `for` loop I used
`i` to hold numbers from 1 to number of elements in the vector
(`length(nums)`). Finally, in the for loop body I added each number from the
vector (using indexing see @sec:julia_vectors) to the `total`. The `total =
total + nums[i]` means that new total is equal to old total + element of the
vector (`nums`) with index `i` (`nums[i]`). Finally, I returned the total.

The body of the `for` loop could be improved. Instead of `for i in
1:length(nums)` I could have written
`for i in eachindex(nums)` (notice there is
no `1:`, `eachindex` is a built in Julia function, see
[here](https://docs.julialang.org/en/v1/base/arrays/#Base.eachindex)). Moreover,
instead of `total = total + nums[i]` I could have used `total += nums[i]`. The
`+=` is and [update
operator](https://docs.julialang.org/en/v1/manual/mathematical-operations/#Updating-operators),
i.e. a shortcut for updating old value by adding a new value to it. Take a
moment to rewrite the function with those new forms and test it.

> **_Note:_** The update operator must be written as `accumulator +=
> updateValue` (e.g. `total += 2`) and not `accumulator =+ updateValue`
> (e.g. `total =+ 2`). In the latter case Julia will asign `updateValue` (`+2`)
> as a new value of `accumulator` [it will interpret `=+ 2` as assign (`=`)
> plus/positive two (`+2`) instead of update (`+=`) by `2`].

Alternatively, I can do this without indexing (although `for` loops with
indexing are a classical idiom in programming and it is worth to know them).

```jl
s = """
function getSum(nums::Vector{<:Real})::Real
	total::Real = 0
	for num in nums
		total += num
	end
	return total
end

getSum(myMathGrades)
"""
sco(s)
```

Here `num` (I could have used `n`, `i` or `whatever` if I wanted to) takes the
value of each consecutive element of `nums` and adds it to the total.

OK, and now back to the [average](https://en.wikipedia.org/wiki/Arithmetic_mean).

```jl
s = """
function getAvg(nums::Vector{<:Real})::Real
	return getSum(nums) / length(nums)
end

getAvg(myMathGrades)
"""
sco(s)
```

Ups, not quite 3.5, I'll better present some additional projects to improve my
final grade.

OK, two more examples that might be useful and will help you master `for` loops
even better.

Let's say I got a vector of temperatures in
[Celsius](https://en.wikipedia.org/wiki/Celsius) and want to send it to a friend
in the US.

```jl
s = """
temperaturesCelsius = [22, 18.3, 20.1, 19.5]
"""
sco(s)
```

To make it easier for him I should probably change it to
[Fahrenheit](https://en.wikipedia.org/wiki/Fahrenheit) using [this
formula](https://en.wikipedia.org/wiki/Fahrenheit#Conversion_(specific_temperature_point)). I
start with writing a simple converting function for a single value of the
temperature in Celsius scale.

```jl
s = """
function degCels2degFahr(tempCels::Real)::Real
	return tempCels * 1.8 + 32
end

degCels2degFahr(0)
"""
sco(s)
```

Now let's convert the temperatures in the vector. First I would try something
like this:

```jl
s = """
function degCels2degFahr!(tempsCels::Vector{<:Real})
	for i in eachindex(tempsCels)
		tempsCels[i] = degCels2degFahr(tempsCels[i])
	end
	return nothing
end
"""
sc(s)
```

Notice the `!` in the function name (don't remember what it mean?
[see here](https://docs.julialang.org/en/v1/manual/style-guide/#bang-convention)).

Still, this is not good. If I use it (`degCels2degFahr!(temperatureCelsius)`) it
will change the values in `temperaturesCelsius` to Fahrenheit which could cause
problems (variable name doesn't reflect its contents). A better approach is to
write a function that produces a new vector and doesn't change the old one.

```jl
s = """
function degCels2degFahr(tempsCels::Vector{<:Real})::Vector{<:Real}
	result::Vector{<:Real} = zeros(length(tempsCels))
	for i in eachindex(tempsCels)
		result[i] = degCels2degFahr(tempsCels[i])
	end
	return result
end
"""
sco(s)
```

Now I can use it like that:

```jl
s = """
temperaturesFahrenheit = degCels2degFahr(temperaturesCelsius)
"""
sco(s)
```

First of all, notice that so far I defined two functions named
`degCels2degFahr`. One of them has got a single value as an argument
(`degCels2degFahr(tempCels::Real)`) and another a vector as its argument
(`degCels2degFahr(tempsCels::Vector{<:Real})`). But since I explicitly declared
argument types, Julia will know when to use each version based on the function's
arguments (see next paragraph). The different function versions are called
methods (hence the message: `degCels2degFahr (generic function with 2 methods)`
under the code snippet above).

In the body of `degCels2degFahr(tempsCels::Vector{<:Real})` first I declare and
initialize a variable that will hold the result (hence `result`). I do this
using built in [zeros](https://docs.julialang.org/en/v1/base/arrays/#Base.zeros)
function. The function returns a new vector with n elements (where n is equal to
`length(tempsCels)`) filled with, you got it, 0s. The 0s are just
placeholders. Then, in the `for` loop, I go through all the indices of `result`
(`i` holds the current index) and replace each zero (`result[i]`) with a
corresponding value in Fahrenheit (`degCels2degFahr(tempsCels[i])`). Here, since
I pass a single value (`tempsCels[i]`) Julia knows which version (aka method) of
the function `degCels2degFahr` to use (i.e. this one
`degCels2degFahr(tempCels::Real)`).

For loops can be
[nested](https://en.wikibooks.org/wiki/Introducing_Julia/Controlling_the_flow#Nested_loops)
(even a few times). This is useful, e.g. when iterating over every call in an
array (we met arrays in @sec:julia_arrays). We will use nested loops later in
the book (e.g. in @sec:compare_categ_data_ex2_solution).

OK, enough for the classic `for` loops. Let's go to some built in goodies that
could help us out with repetition.

### Built-in Goodies {#sec:julia_language_built_in_goodies}

If the operation you want to perform is simple enough you may prefer to use some
of the Julia's goodies mentioned below.

### Comprehensions {#sec:julia_language_comprehensions}

Another useful constructs are
[comprehensions](https://docs.julialang.org/en/v1/manual/arrays/#man-comprehensions).

Let's say this time I want to convert inches to centimeters using this function.

```jl
s = """
function inch2cm(inch::Real)::Real
	return inch * 2.54
end

inch2cm(1)
"""
sco(s)
```

If I want to do it for a bunch of values I can use comprehensions like so.

```jl
s = """
inches = [10, 20, 30]

function inches2cms(inches::Vector{<:Real})::Vector{<:Real}
	return [inch2cm(inch) for inch in inches]
end

inches2cms(inches)
"""
sco(s)
```

On the right I use the familiar `for` loop syntax, i.e. `for sth in
collection`. On the left I place a function (named or
[anonymous](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions))
that I want to use (here `inch2cm`) and pass consecutive elements (`sth`, here
`inch`) to that function. The expression is surrounded with square brackets so
that Julia makes a new vector out of it (the old vector is not changed).

*In general comprehensions are pretty useful, chances are that I'm going to use
them a lot in this book so make sure to learn them (e.g. read their description
in the link at the beginning of this subchapter,
i.e. @sec:julia_language_comprehensions or look at the examples shown
[here](https://en.wikibooks.org/wiki/Introducing_Julia/Controlling_the_flow#Comprehensions)).*

### Map and Foreach {#sec:julia_language_map_foreach}

Comprehensions are nice, but some people find
[map](https://docs.julialang.org/en/v1/base/collections/#Base.map) even
better. The example above could be rewritten as:

```jl
s1 = """
inches = [10, 20, 30]

function inches2cms(inches::Vector{<:Real})::Vector{<:Real}
	return map(inch2cm, inches)
end

inches2cms(inches)
"""
sco(s1)
```

Again, I pass a function (note I typed only its name) as a first argument to
`map`, the second argument is a collection. Map automatically applies the
function to every element of the collection and returns a new collection. Isn't
this magic.

If you want to evoke a function on a vector just for side effects (since you
don't need to build a vector and return it) use
[foreach](https://docs.julialang.org/en/v1/base/collections/#Base.foreach). For
instance, `getSum` with `foreach` and an anonymous function would look like this

```jl
s = """
function getSum(vect::Vector{<:Real})::Real
	total::Real = 0
	foreach(x -> total += x, vect) # side effect is to increase total
	return total
end

getSum([1, 2, 3, 4])
"""
sco(s)
```

Here, `foreach` will perform an action (its first argument) on each element of
its second argument (`vect`). The first argument (`x -> total += x`) is an
[anonymous function](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions)
that takes some value `x` and in its body (`->` points at the body) adds `x` to
`total` (`total += x`). The `x` takes each value of `vect` (second argument).

> **_Note:_** Anonymous functions will be used quite a bit in this book, so make
> sure you understand them (read their description in the link above or look at
> the examples shown
> [here](https://en.wikibooks.org/wiki/Introducing_Julia/Functions#Anonymous_functions)).

### Dot operators/functions {#sec:julia_language_dot_functions}

Last but not least. I can use a [dot
operator](https://docs.julialang.org/en/v1/manual/mathematical-operations/#man-dot-operators). Say
I got a vector of numbers and I want to add 10 to each of them. Doing this for a
single number is simple, I would have just typed `1 + 10`. Hmm, but for a
vector? Simple as well. I just need to precede the operator with a `.` like so:


```jl
s = """
[1, 2, 3] .+ 10
"""
sco(s)
```

I can do this also for functions (both built-in and written by myself). Notice
`.` goes before `(`

```jl
s2 = """
inches = [10, 20, 30]

function inches2cms(inches::Vector{<:Real})::Vector{<:Real}
	return inch2cm.(inches)
end

inches2cms(inches)
"""
sco(s2)
```

Isn't this nice.

OK, the goodies are great, but require some time to get used to them (I suspect
at first you're gonna use good old `for` loop syntax). Besides the constructs
described in this section are good for simple operations (don't try to put too
much stuff into them, they are supposed to be one liners).

In any case choose a construct that you know how to use and that gets the job
done for you, mastering them all will take some time.

*Still, in general dot operations are pretty useful, chances are that I'm going
to use them a lot in this book so make sure to understand them.*

## Additional libraries {#sec:julia_language_libraries}

OK, there is one more thing I want to briefly talk about, and it is
[libraries](https://en.wikipedia.org/wiki/Library_(computing)) (sometimes called
packages).

A library is a piece of code developed by someone else. At the time I'm writing
these words there are over 9'000 libraries (aka packages) in Julia ([see
here](https://julialang.org/packages/)) available under different licenses. If
the package is under [MIT license](https://en.wikipedia.org/wiki/MIT_License) (a
lot of them are) then basically you may use it freely, but without any warranty.

To install a package you use
[Pkg](https://docs.julialang.org/en/v1/stdlib/Pkg/), i.e. Julia's built in
package manager. Click the link in the previous sentence to see how to do it (be
aware that installation may take some time).

In general there are two ways to use a package in your project:

1. by typing `using Some_pkg_name`
2. by typing `import Some_pkg_name`

Personally, I prefer the latter. Actually, I use it in the form `import
Some_pkg_name as Abbreviated_pkg_name` (you will see why in a moment).

Let's see how it works. Remember the `getSum` and `getAvg` functions that we
wrote ourselves. Well, it turns out Julia got a built-in
[sum](https://docs.julialang.org/en/v1/base/collections/#Base.sum) and
[Statistics](https://docs.julialang.org/en/v1/stdlib/Statistics/) package got a
[mean](https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.mean)
function. To use it I type at the top of my file (it is a good practice to do
so):

```jl
s = """
import Statistics as Stats
"""
sc(s)
```

Now I can access any of its functions by preceding them with `Stats` (my
abbreviation) and `.` like so

```jl
s = """
Stats.mean([1, 2, 3])
"""
sco(s)
```

And that's it. It just works.

Note that if you type `import Statistics` instead of `import Statistics as
Stats` then in order to use `mean` you will have to type `Statistics.mean([1, 2,
3])`. So in general is is a good idea to give some shorter name for an imported
package.

Oh yeah, one more thing. In order to know what are the functions in a library
and how to use them you should check the library's documentation.

OK, enough theory, time for some practice.

## Julia - Exercises {#sec:julia_language_exercises}

I once heard that in chess you can get only as much as you give. I believe it is
also true for programming (and most likely many other human activities).

So, here are some exercises that you may want to solve to get from this chapter
as much as you can.

> **_Note:_** Some readers probably will not solve the exercises. They will not
> want to (because of the waste of time) or will not be able to solve them (in
> that case my apology for the inappropriate difficulty level). Either way, I
> suggest you read the tasks' descriptions and the solutions (and try to
> understand them). In those sections I may use, e.g. some language constructs
> that I will not explain again in the upcoming chapters.

### Exercise 1 {#sec:julia_language_exercise1}

Imagine the following situation. You and your friends make a call to order out a
pizza. You got only \$50 and you are pretty hungry. But you got a dilemma, for
exactly \$50 you can either order 2 pizzas 30 cm in diameter each, or 1 pizza 45
cm in diameter. Which one is more worth it?

*Hint: Assume that the pizza is flat and that you are eating its surface.*

*Hint: You may want to search [the
documentation](https://docs.julialang.org/en/v1/) for `Base.MathConstants` and
use one of them.*

### Exercise 2 {#sec:julia_language_exercise2}

When we talked about float comparisons (@sec:julia_float_comparisons) we said to
be careful since

```jl
s = """
(0.1 * 3) == 0.3
"""
sco(s)
```

Write a function with the following signature `areApproxEqual(f1::Float64,
f2::Float64)::Bool`. It should return `true` when called with those numbers
(`areApproxEqual(0.1*3, 0.3)`). For the task you may use
[round](https://docs.julialang.org/en/v1/base/math/#Base.round-Tuple{Complex{%3C:AbstractFloat},%20RoundingMode,%20RoundingMode})
with a precision of, let's say, 16 digits.

> **_Note:_** Probably there is no point of greater precision than 16 digits
> since your machine won't be able to see it anyway. For technical details see
> [Base.eps](https://docs.julialang.org/en/v1/base/base/#Base.eps-Tuple{Type{%3C:AbstractFloat}}).

### Exercise 3 {#sec:julia_language_exercise3}

Remember `getMin` from previous chapter (see @sec:ternary_expression)

```jl
s = """
function getMin(vect::Vector{Int}, isSortedAsc::Bool)::Int
    return isSortedAsc ? vect[1] : sort(vect)[1]
end"""
sc(s)
```

Write `getMax` with the following signature `getMax(vect::Vector{Int},
isSortedDesc::Bool)::Int` use only the elements from previous version of the
function (you should modify them).

### Exercise 4 {#sec:julia_language_exercise4}

Someone once told me that the simplest interview question for a candidate
programmer is [fizz buzz](https://en.wikipedia.org/wiki/Fizz_buzz). If a person
doesn't know how to do that there is no point of examining them further.

I don't know if that's true, but here we go.

Write a program for a range of numbers 1 to 30.

- If a number is divisible by 3 print "Fizz" on the screen.
- If a number is divisible by 5 print "Buzz" on the screen.
- If a number is divisible by 3 and 5 print "Fizz Buzz" on the screen.
- Otherwise print the number itself.

If you feel stuck right now, don't worry. It sounds difficult, because so far
you haven't met all the necessary elements to solve it. Still, I believe you
can do this by reading the Julia's docs or using your favorite web search
engine.

Here are some constructs that might be useful to solve this task:

- for loop (see @sec:julia_language_for_loops)
- if/elseif/else (see @sec:julia_language_if_else)
- [modulo operator or rem function](https://docs.julialang.org/en/v1/base/math/#Base.rem)
- 'logical and' (see @sec:julia_other_types and
  [this](https://docs.julialang.org/en/v1/manual/missing/#Logical-operators) and
  [that](https://docs.julialang.org/en/v1/manual/missing/#Control-Flow-and-Short-Circuiting-Operators)
  section of Julia's docs)
- [string function](https://docs.julialang.org/en/v1/base/strings/#Base.string)

You may use some or all of them. Or perhaps you can come up with something
else. Good luck.

### Exercise 5 {#sec:julia_language_exercise5}

I once heard a story about chess.

According to the story the game was created by a Hindu wise man. He presented
the invention to his king who was so impressed that he offered to fulfill his
request as a reward.

- I want nothing but some wheat grains.
- How many?
- Put 1 grain on the first chess field, 2 grains on the second, 4 on the third,
  8 on the fourth, and so on. I want the grains that are on the last field.

A laughingly small request, thought the king. Or is it?

Use Julia to answer how many grains are on the last (64th) field.

*Hint. If you get a strange looking result, use
[BigInt](https://docs.julialang.org/en/v1/base/numbers/#BigFloats-and-BigInts)
data type instead of
[Int](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Integers).*

### Exercise 6 {#sec:julia_language_exercise6}

Lastly, to cool down a little write a function `getInit` that takes a vector of
any type as an argument and returns the vector without its last element.

You may either use the generics (preferred way to solve it, see
@sec:functions_with_generics) or write the function without type declarations
(acceptable solution).

Remember about the indexing (see @sec:julia_vectors). Think (or search for the
answer e.g. in the internet) how to get one but last element of an array.

Usage examples:

```
getInit([1, 2, 3, 4])
# output: [1, 2, 3]
```

```
getInit(["ab", "cd", "ef", "gh"])
# output: ["ab", "cd", "ef"]
```

```
getInit([3.3])
# output: Float64[]
```

```
getInit([])
# output: Any[]
```

## Julia - Solutions {#sec:julia_language_exercises_solutions}

In this sub-chapter you will find exemplary solutions to the exercises from the
previous section.

### Solution to Exercise 1 {#sec:julia_language_exercise1_solution}

Since I'm eating a surface, and the task description gives me diameters, then I
should probably calculate [area of a
circle](https://en.wikipedia.org/wiki/Area_of_a_circle). I will use
[Base.MathConstants.pi](https://docs.julialang.org/en/v1/base/numbers/#Base.MathConstants.pi)
in my calculations.

```jl
s = """
function getCircleArea(r::Real)::Real
	return pi * r * r
end
"""
sc(s)
```

---

```jl
s = """
(getCircleArea(30/2) * 2, getCircleArea(45/2))
"""
sco(s)
```

It seems that I will get more food while ordering this one pizza (45 cm in
diameter) and not those two pizzas (each 30 cm in diameter).

> **_Note:_** Instead of `pi * r * r` I could have used `r^2`, where `^` is an
> exponentiation operator in Julia. If I want to raise 2 to the fourth power I
> can either type `2^4` or `2*2*2*2` and get `jl 2^4`.

If all the pizzas were [cylinders](https://en.wikipedia.org/wiki/Cylinder) of
equal heights (say 2 cm or an inch each) then I would calculate their volumes
like so

```jl
s = """
function getCylinderVolume(r::Real, h::Real=2)::Real
	# hmm, is cylinder just many circles stacked one on another?
	return getCircleArea(r) * h
end
"""
sc(s)
```

---

```jl
s = """
(getCylinderVolume(30/2) * 2, getCylinderVolume(45/2))
"""
sco(s)
```

Still, the conclusion is the same.

### Solution to Exercise 2 {#sec:julia_language_exercise2_solution}

My solution to that problem would look something like

```jl
s = """
function areApproxEqual(f1::Float64, f2::Float64)::Bool
	return round(f1, digits=16) == round(f2, digits=16)
end
"""
sc(s)
```

Let's put it to the test

```jl
s = """
areApproxEqual(0.1*3, 0.3)
"""
sco(s)
```

Seems to be working fine. Still, you may prefer to use Julia's built-in
[isapprox](https://docs.julialang.org/en/v1/base/math/#Base.isapprox).

For example.

```jl
s = """
isapprox(0.1*3, 0.3)
# compare with
# isapprox(0.11*3, 0.3)
# or to test if the values are not equal
# !isapprox(0.11*3, 0.3)
"""
sco(s)
```

Lesson to be learned here. If you want to do something you can:

1. look for a function in the language documentation
2. look for a function in some library
3. write a function yourself by using what you already got at your disposal

### Solution to Exercise 3 {#sec:julia_language_exercise3_solution}

Possible solution

```jl
s1 = """
function getMax(vect::Vector{Int}, isSortedDesc::Bool)::Int
    return isSortedDesc ? vect[1] : sort(vect)[end]
end

(getMax([3, 2, 1], true), getMax([2, 3, 1], false))
"""
sco(s1)
```

or if you read the documentation for
[sort](https://docs.julialang.org/en/v1/base/sort/#Base.sort)

```jl
s2 = """
function getMax(vect::Vector{Int}, isSortedDesc::Bool)::Int
    return isSortedDesc ? vect[1] : sort(vect, rev=true)[1]
end

(getMax([3, 2, 1], true), getMax([2, 3, 1], false))
"""
sco(s2)
```

Sorting an array to get the maximum (or minimum) value is not the most effective
method (sorting is based on rearranging elements and takes quite some
time). Traveling through an array only once should be faster. Therefore probably
a better solution (in terms of performance) would be something like

```jl
s2 = """
function getMaxUnsorted(unsortedVect::Vector{Int})::Int
	maxVal::Int = unsortedVect[1]
	for elt in unsortedVect[2:end]
		if maxVal < elt
			maxVal = elt
		end
	end
	return maxVal
end

function getMax(vect::Vector{Int}, isSortedDesc::Bool)::Int
    return isSortedDesc ? vect[1] : getMaxUnsorted(vect)
end

(getMax([3, 2, 1], true), getMax([2, 3, 1], false))
"""
sco(s2)
```

Read it carefully and try to figure out how it works.

> **_Note:_** Julia already got similar functionality to `getMin`, `getMax` that
> we developed ourselves. See
> [min](https://docs.julialang.org/en/v1/base/math/#Base.min),
> [max](https://docs.julialang.org/en/v1/base/math/#Base.max),
> [minimum](https://docs.julialang.org/en/v1/base/collections/#Base.minimum),
> and
> [maximum](https://docs.julialang.org/en/v1/base/collections/#Base.maximum).

### Solution to Exercise 4 {#sec:julia_language_exercise4_solution}

Perhaps the most direct version of the program would be

```jl
s1 = """
function printFizzBuzz()
	for i in 1:30
		# or: if rem(i, 15) == 0
		if rem(i, 3) == 0 && rem(i, 5) == 0
			println("Fizz Buzz")
		elseif rem(i, 3) == 0
			println("Fizz")
		elseif rem(i, 5) == 0
			println("Buzz")
		else
			println(i)
		end
	end
	return nothing
end
"""
sc(s1)
```

> **_Note:_** Julia applies operators based on [precedence and
> associativity](https://docs.julialang.org/en/v1/manual/mathematical-operations/#Operator-Precedence-and-Associativity). If
> you are unsure about the order of their evaluation check the docs or use
> parenthesis `()` to enforce the desired order of evaluation.


Go ahead, test it out.

If you like challenges try to follow the execution of the following program.

```jl
s2 = """
function getFizzBuzz(num::Int)::String
	return (
		rem(num, 15) == 0 ? "Fizz Buzz" :
		rem(num, 3) == 0 ? "Fizz" :
		rem(num, 5) == 0 ? "Buzz" :
		string(num)
	)
end

function printFizzBuzz()
	foreach(x -> println(getFizzBuzz(x)), 1:30)
	return nothing
end

# you can use it like so: printFizzBuzz()
"""
sc(s2)
```

There are probably other more creative [or more (unnecessarily) convoluted] ways
to solve this task. Personally, I would be satisfied if you understand the first
version.

### Solution to Exercise 5 {#sec:julia_language_exercise5_solution}

For more information about the legend see [this Wikipedia's
article](https://en.wikipedia.org/wiki/Sissa_(mythical_brahmin)).

If you want some more detailed mathematical explanation you can read [that
Wikipedia's
article](https://en.wikipedia.org/wiki/Wheat_and_chessboard_problem).

The Wikipedia's version of the legend differs slightly from mine, but I like
mine better.

Anyway let's jump right into some looping.

```jl
s1 = """
function getNumOfGrainsOnField64()::Int
	noOfGrains::Int = 1 # no of grains on field 1
	for _ in 2:64
		noOfGrains *= 2 # *= is update operator similar to +=
	end
	return noOfGrains
end

getNumOfGrainsOnField64()
"""
sco(s1)
```

Hmm, that's odd, a negative number.

Wait a moment. Now I remember, a computer got finite amount of memory. So in
order to work efficiently data is stored in small pre-allocated pieces of it. If
the number you put into that small 'memory drawer' is greater than the amount of
space then you get strange results (imagine that a number sticks out of the
drawer but Julia looks only at the part inside the drawer, hence the strange
result).

If you are interested in technical stuff then you can read more about it in
Julia's docs (sections
[Integers](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Integers)
and [Overflow
Behavior](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Overflow-behavior)).

You can check the minimum and maximum value for `Int` by typing `typemin(Int)`
and `typemax(Int)` on my laptop those are `jl typemin(Int)` and
 `jl typemax(Int)`, respectively.

The broad range of `Int` is enough for most calculations, still if you expect a
really big number you should use
[BigInt](https://docs.julialang.org/en/v1/base/numbers/#BigFloats-and-BigInts)
(`BigInt` calculations are slower than the ones for `Int`, but now you should be
only limited by the amount of memory on your computer).

So let me correct the code.

```jl
s2 = """
function getNumOfGrainsOnField64()::BigInt
	noOfGrains::BigInt = 1 # no of grains on field 1
	for _ in 2:64
		noOfGrains *= 2
	end
	return noOfGrains
end

getNumOfGrainsOnField64()
"""
sco(s2)
```

Whoa, that number got like `jl length(string(getNumOfGrainsOnField64()))`
digits. I don't even know how to name it. It cannot be that big, can it?

OK, quick verification with some mathematical calculation (don't remember `^`?
See @sec:julia_language_exercise1_solution).

```jl
s3 = """
BigInt(2)^63 # we multiply 2 by 2 by 2, etc. for fields 2:64
"""
sco(s3)
```

Yep, the numbers appear to be the same.

```jl
s = """
getNumOfGrainsOnField64() == BigInt(2)^63
"""
sco(s)
```

So I guess the [aforementioned Wikipedia's
article](https://en.wikipedia.org/wiki/Wheat_and_chessboard_problem) is right,
it takes much more grain than a country (or the world) could produce in a year.

### Solution to Exercise 6 {#sec:julia_language_exercise6_solution}

A possible solution with generics looks something like that

```jl
s = """
function getInit(vect::Vector{T})::Vector{T} where T
	return vect[1:(end-1)]
end
"""
sco(s)
```

The parenthesis around `end-1` are not necessary. I added them for better
clarity of how the last by one index is calculated.

Tests:

```jl
s = """
getInit([1, 2, 3, 4])
"""
sco(s)
```

```jl
s = """
getInit(["ab", "cd", "ef", "gh"])
"""
sco(s)
```

```jl
s = """
getInit([3.3])
"""
sco(s)
```

```jl
s = """
getInit([])
"""
sco(s)
```

BTW. Try to remove type declarations and see if the function still works (if you
do this right then it should).

OK, that's it for now. Let's move to another chapter.
