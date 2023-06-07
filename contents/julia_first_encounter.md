# Julia - first encounter {#sec:julia_first_encounter}

This book is not intended to be a comprehensive introduction to Julia programming. If you are looking for one try, e.g.
[Think Julia](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html).

Still, we need to cover some selected basics of the language in order to use it later. The rest of it we will catch 'on the fly'.
Without further ado let's get our hands dirty.

## Installation {#sec:julia_installation}

In order to use Julia we need to install it first. So, now is the time to go to [julialang.org](https://julialang.org/),
click 'Download' and choose the version suitable for your machine's OS.

To check the installation open the [Terminal](https://en.wikipedia.org/wiki/Terminal_emulator) and type:

```bash
julia --version
```

At the time of writing this words I'm using:

```jl
s = """
VERSION
"""
sco(s)
```

At the bottom of the page you will find 'Editors and IDEs' section presenting the most popular editors that will enable you to effectively write and execute pieces of Julia's code.

For starters I would go with [Visual Studio Code](https://www.julia-vscode.org/docs/dev/gettingstarted/#Installation-and-Configuration-1) as a user friendly code editor for Julia. In the link above you will find installation and configuration instructions for the editor.

From now on you'll be able to use it interactively (to run Julia code from this book).

All You need to do is to create a file (e.g. `chapter03.jl`), type the code presented in this chapter and run it by marking the code and pressing `Ctrl+Enter`.

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

and run it by pressing `Ctrl+Enter`.

This creates a variable (an imaginary box) named `x` (x is a label on the box) that contains the value `1`. The `=` operator assigns `1` (right side) to `x` (left side) [puts `1` into the box].

> **_Note:_** Spaces around mathematical operators like `=` are usually not necessary. Still, they improve legibility of your code

Now, somwehat below type and execute

```jl
s = """
x = 2
"""
sc(s)
```

Congratulations, now the value stored in the box (I mean variable `x` is `2`).

Here, you defined variable `y` with a value `2.2` and reassigned it right away to `3.3`. So the current value in the box is `3.3`

Sometimes (usually I do this inside of functions, see upcoming @sec:julia_language_functions) you may see variables written like that

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

The `::` is a type declaration. Here by using `::Int` you promise Julia that you will be storing only [integers](https://en.wikipedia.org/wiki/Integer)
(like: ..., -1, 0, 1, ...) in this box. Whereas by typing `::Float64` you declare to place only [floats](https://en.wikipedia.org/wiki/Floating-point_arithmetic)
(like: ..., 1.1, 1.0, 0.0, 2.2, 3.14, ...) in that box.

### Optional type declaration {#sec:julia_optional_type_declaration}

**In Julia type declaration is optional.** You don't have to do this, Julia will figure them out anyway. Still, sometimes it is worth to declare them (explanation in a moment).
If you decide to do so, you should declare a variable's type only once (the time it is first created and initialized with a value).

If you use a variable without type declaration then you can freely reassign to it values of different types.

> **_Note:_** in the code snippet below `#` and all the text to the right of it is a comment, the part that is ignored by a computer but read by a human

```jl
s = """
a = 1 # type is not declared
a = 2.2 # can assign any other type
# the "Hello" below is a string (a text in a form readable by Julia)
a = "Hello"
"""
sc(s)
```

But you cannot assign a different type to a variable than the one you declared (you must keep your promises).
Look at the code below.

This is OK

```jl
s = """
b::Int = 1 # type integer declared
b = 2 # type integer delivered
"""
sc(s)
```

But this is not OK (it's wrong! it's wroooong!)

```
c::Int = 1 # type integer declared
c = 3.3 # broke the promise, float delivered, will produce error
```

Now a question arises. Why would you want to use type declaration (like `::Int` or `::Float64`) at all?

In general you put values into variables to use them later. Sometimes, you forget what you placed there and may get the unexpected result (that may go unnoticed).
For instance it makes more sense to use integer instead of string for some operations (e.g. I may wish to multiply `3` by `3` not `"three"` by `"three"`).

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

The latter example is so called [string concatenation](https://docs.julialang.org/en/v1/manual/strings/#man-concatenation), it may be useful, but probably it is not what you wanted.

To avoid such an unexpected events (especially if instead of `*` you will use your own function -> see @sec:julia_language_functions)
you would like a guarding angel that watches over you. This is what Julia does when you ask her for it by using type declarations (for now you need to take my word for it).

Moreover, declaring types can make your code run faster.

Additionally, some [IDEs](https://en.wikipedia.org/wiki/Integrated_development_environment) work better (improved code completions, and hints)
when you place type declarations in your code.

Personally, I like to use type declarations in my own functions (see upcoming @sec:julia_language_functions) to help me reason what they do.

### Meaningful variable names {#sec:julia_meaningful_variable_names}

**Name your variables well**. The variable names I used before are horrible (*mea culpa, mea culpa, mea maxima culpa*).
We use named variables (like `x = 1`) instead of 'loose' variables (you can type `1` alone in a script file and execute it) to use them later.

You can use them later in time (reading and editing your code tomorrow or next month/year) or in space (using it 30 or 300 lines below).
If so, the names need to be memorable (actually just meaningful will do :D). So whenever possible use: `studentAge = 19`, `bookTitle = "Dune"` instead of `x = 19`, `y = "Dune"`.

You may want to check [Julia Docs](https://docs.julialang.org/en/v1/) for
[allowed variable names](https://docs.julialang.org/en/v1/manual/variables/#man-allowed-variable-names)
and their [stylistic conventions](https://docs.julialang.org/en/v1/manual/variables/#Stylistic-Conventions).
Personally, I prefer to use [camelCaseStyle](https://en.wikipedia.org/wiki/Camel_case) so this is what you're gonna see here.

### Floats comparisons {#sec:julia_float_comparisons}

**Be careful with `=` sign**. In mathematics `=` means `equal to` and `≠` means `not equal to`. In programming `=` is usually an assignment operator.
If you want to compare for equality you should use `==` (for `equal to`) and (`!=` for `not equal to`), examples:

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
1.0 != 1
"""
sco(s)
```

```jl
s = """
2 != 2
"""
sco(s)
```

Be careful though since comparing two floats is tricky, e.g.

```jl
s = """
(0.1 * 3) == 0.3
"""
sco(s)
```

It is `false` since float numbers cannot be represented exactly in binary
(see [this StackOverflow's thread](https://stackoverflow.com/questions/8604196/why-0-1-3-0-3)). This is how my computer sees `0.1 * 3`


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

The same caution applies to other comparison operators, like `>` (`is greater than`), `>=` (`is greater than or equal to`), `<` (`is less than`), `<=` (`is less than or equal to`).

*We will see how to deal with that later. (see @sec:julia_language_exercise2)*

### Other types {#sec:julia_other_types}

There are also other types (see [Julia Docs](https://docs.julialang.org/en/v1/manual/types/)) but we will use mostly those mentioned in this chapter, i.e.:

- [floats](https://en.wikipedia.org/wiki/Floating-point_arithmetic)
- [integers](https://en.wikipedia.org/wiki/Integer)
- [strings](https://en.wikipedia.org/wiki/String_(computer_science))
- [booleans](https://en.wikipedia.org/wiki/Boolean_data_type)


The briefly mentioned strings are denoted by `::String` and you type them with quotations (`"any text"`).

The last of the mentioned types is denoted as `::Bool` and can take only two values: `true` or `false` (see the results of the comparison operations above in @sec:julia_float_comparisons).

### Collections {#sec:julia_collections}

Not only do variables store single value but they can also store their collections. The collection type that we will discuss here are `Vector` and `Array` (technically `Vector` is a one dimentional `Array` but don't worry about that now).

### Vectors {#sec:julia_vectors}

```jl
s = """
myMathGrades = [3.5, 3.0, 3.5, 2.0, 4.0, 5.0, 3.0]
"""
sco(s)
```

Here I declared a variable that stores my mock grades.

The variable type is `Vector` of numbers (each of type `Float64`, run `typeof(myMathGrades)` to check it).
I could have declared its type explicitly as `::Vector{Float64}`. Instead I decided to let Julia to figure it out.

You can think of a vector as a [rectangular cuboid](https://en.wikipedia.org/wiki/Cuboid#Rectangular_cuboid) box with drawers (smaller [cube](https://en.wikipedia.org/wiki/Cube) shaped boxes).
The drawers are labeled with consecutive numbers (indices) starting at 1 (we will get to that in a moment). The variable contains `jl length(myMathGrades)` grades in it, which you can check by typing and executing `length(myMathGrades)`.

You can retrieve a single element of the vector by typing `myMathGrades[i]` where `i` is some integer (the aforementioned index). For instance:

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
# it is equivalent to: myMathGrades[7], but I don't need to count elements
"""
sco(s)
```

Be careful though, if You type a none existing index like `myMathGrades[-1]`, `myMathGrades[0]` or `myMathGrades[10]` you will get an error
(e.g. `BoundsError: attempt to access 7-element Vector{Int64} at index [0]`).

Moreover, you can get a slice (a part) of the vector by typing

```jl
s = """
myMathGrades[2:4] # returns Vector with three grades (2nd, 3rd, and 4th)
# the slicing is [inclusive:inclusive]
"""
sco(s)
```

The `2:4` is Julia's range generator, with default syntax `start:stop` (both of which are inclusive).
Assume that under the hood it generates a vector. So, it gives us the same result as writing `myMathGrades[[2, 3, 4]]` by hand.
However, the range syntax is more convenient (less typing).
Let's say I want to print every other grade out of 100 grades, then I can go with `oneHunderedGrades[1:2:end]` and voila,
a magic happened thanks to the `start:step:stop` syntax.

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

Again, remember about proper indexing.
What you put inside (right side) should be compatible with indexing (left side), e.g `myMathGrades[2:3] = [2.0, 2.0, 2.0]` will produce an error (placing 3 numbers to 2 slots).

### Arrays {#sec:julia_arrays}

A `Vector` is actually a special case of an `Array`, a multidimentional structure that holds data.
The most familiar (and useful) form of it is a two-dimentional `Array` (also called `Matrix`). It has rows and columns.
Previously I stored my math grades in a `Vector`, but most likely I would like a place to keep my other grades.
Here, I create an array that stores my grades from math (column1) and chemistry (column2).


```jl
s = """
myGrades = [3.5 3.0; 4.0 3.0; 5.0 2.0]
myGrades
"""
sco(s)
```

I separated the values between columns with a space character and indicated a new row with a semicolon.
Typing it by hand is not very interesting, but they come in handy as we will see later.

As with vectors I can use indexing to get specific element(s) from a matrix. E.g.

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
myGrades[3, 2] # returns value from third row and second column
"""
sco(s)
```

I can also use the indexing to replace a particular element in a `Matrix`. For instance.

```jl
s = """
myGrades[3, 2] = 5
myGrades
"""
sco(s)
```

As with a `Vector` also here you must pay attention to proper indexing.

OK, enough about the variables, time to check functions.

## Functions {#sec:julia_language_functions}

Functions are doers, i.e encapsulated pieces of code that do things for you.
Optimally, a function should be single minded, i.e. doing one thing only and doing it well.
Moreover since they do stuff they names should contain [verbs](https://en.wikipedia.org/wiki/Verb)
(whereas variables' names should be composed of [nouns](https://en.wikipedia.org/wiki/Noun)).

We already met one Julia function (see @sec:julia_is_simple), namely `println`.
As the name suggests it prints something (like a text) to the [standard output](https://en.wikipedia.org/wiki/Standard_streams#Standard_output_(stdout)).
This is one of many Julia build in functions (for more information see [Julia Docs](https://docs.julialang.org/en/v1/)).

### Mathematical functions {#sec:mathematical_functions}

But we can also define some functions on our own:

```jl
s = """
function getRectangleArea(lenSideA::Real, lenSideB::Real)::Real
	return lenSideA * lenSideB
end
"""
sco(s)
```

Here I declared Julia's version of a [mathematical function](https://en.wikipedia.org/wiki/Function_(mathematics)).
It is called `getRectangleArea` and it calculates (surprise, surprise, the [area of a rectangle](https://en.wikipedia.org/wiki/Rectangle#Formulae)).

To do that I used a keyword `function`. The `function` keyword is followed by the name of the function. Inside the parenthesis are arguments of the function.
The function accepts two arguments `lenSideA` (length of one side) and `lenSideB` (length of the other side) and calculates the area of a rectangle.
Both `lenSideA` and `lenSideB` are of type `Real` (Julia's represntation of [real number](https://en.wikipedia.org/wiki/Real_number),
it encompasses `Int` and `Float64` that we encountered before).
The ending of the first line, `)::Real`, signifies that the function will return a value of type `Real`.
The stuff that function returns is preceded by the `return` keyword. The function ends with the `end` keyword.

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

*A quick reference to the topic we discussed in @sec:julia_optional_type_declaration.
Here typig `getRectangleArea("three", "three")` will produce an error.
I can read it now, and based on the error message correct my code so the result is in line with my expectations.*

Hmm, OK, I got `getRectangleArea` and what if I need to calculate the [area of a square](https://en.wikipedia.org/wiki/Square#Perimeter_and_area).
You got it.

```jl
s = """
function getSquareArea(lenSideA::Real)::Real
	return getRectangleArea(lenSideA, lenSideA)
end
"""
sco(s)
```

Notice that I reused previously defined `getRectangleArea` (so, functions can use other functions). Let's see how it works.

```jl
s = """
getSquareArea(3)
"""
sco(s)
```

Appears to be working just fine.

### Functions with generics {#sec:functions_with_generics}

Now, let's say I want a function `getFirstElt` that accepts a vector and returns its first element
(vectors and indexing were briefly discussed in @sec:julia_collections).

```jl
s = """
function getFirstElt(vect::Vector{Int})::Int
	return vect[1]
end
"""
sc(s)
```

It looks OK (test it, e.g. `getFirstElt([1, 2, 3]`). However, the problem is it works only with integers (or maybe not, test it out).
How to make it work with any type, like `getFirstElt(["Eve", "Tom", "Alex"])` or `getFirstElt([1.1, 2.2, 3.3])`?

One way is to declare separate versions of the functions for different type of inputs, i.e.

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

But that is too much typing (I retyped a few times virtually the same code). The other way is to use no type declarations.

```jl
s = """
function getFirstEltVer2(vect)
	return vect[1]
end
"""
sc(s)
```

It turns out that you don't have to declare function types in Julia (just like in the case of variables, see @sec:julia_optional_type_declaration) and a function still may work just fine.

> **_Note:_** If for any reason you don't want to use type declarations then you don't have to. Julia gives you a choice. To be honest, when I begun to write my first computer programs, I preferred to use programming languages that didn't require types. So, I perfectly understand your decision whatever it may be.

Still, a die hard 'typist' (if I may call a person this way) would probably use so called generic types, like

```jl
s = """
function getFirstEltVer3(vect::Vector{T})::T where T
	return vect[1]
end
"""
sc(s)
```

Here we said that the vector is composed of elements of type `T` (`Vector{T}`) and that the function will return type `T` (see `)::T`).
By typing `where T` we let Julia know that `T` is a custom type that we have just created (not a Julia build in type).
Replace `T` with any other letter of the alphabet (`A`, `D`, or whatever) and check if the code still works (it should).

One last remark, it is customary to write generic types with a single capital letter.
Notice that in comparison to the function with no type declarations (`getFirstEltVer2`) the version with generics (`getFirstEltVer3`) is more informative.
You know that the function accepts vector of some elements, and you know that it returns a value of the same type as the the elements that build that vector.

Note that the last function we wrote for fun (it was fun for me, how about you?).
In reality Julia already got a function with a similar functionality (see [first](https://docs.julialang.org/en/v1/base/collections/#Base.first)).

Anyway, as I said if you don't want to use types then don't. Still, I prefer to use them for reasons similar to those described in @sec:julia_optional_type_declaration.

### Functions modifying arguments {#sec:functions_modifying_arguments}

Previously (see @sec:julia_collections) we said that you can change elements of the vector.
So, let's try to write a function that changes the first element.

```jl
s = """
function replaceFirstElt!(vect::Vector{T}, newElt::T) where T
	vect[1] = newElt
	return nothing
end
"""
sc(s)
```

> **_Note:_** The functions name ends with `!` (exclamation mark). This is one of the Julia's conventions to mark a function that modifies its arguments.

In general, you should try to write a function that does not modify its arguments (it often causes errors in big programs).
However, such modifications are sometimes useful, therefore Julia allows you to do so, but you should always be explicit about it.
That is why it is customary to end the name of the function with `!` (exclamation mark draws attention).

Additionally, observe that `T` can still be of any type, but we require `newElt` to be of the same type as the elements in `vect`.
Moreover, since we modify the arguments we wrote `return nothing` and removed returned type after functions name [`) where T` instead of `)::T where T`].

Let's see how the functions work.

First `getFirstEltVer3`:

```jl
s = """
x = [1, 2, 3]
y = getFirstEltVer3(x)
(x, y)
"""
sco(s)
```

and now `replaceFirstElt!`.

```jl
s = """
x = [1, 2, 3]
y = replaceFirstElt!(x, 4)
(x, y)
"""
sco(s)
```

The `(x, y)` returns `Tuple` and it is there is to show both `x` and `y` in one line.
You may think of `Tuple` as something similar to `Vector` but written with parenthesis `()` instead of square brackets `[]`.
Additionally, you cannot modify elements of a tuple after it was created (so, if you got `z = (1, 2, 3)`, then `z[2]` will work just fine, but `z[2] = 8` will produce an error).

### Side Effects vs Returned Values {#sec:side_effects_vs_returned_values}

Notice that so far we encountered two types of Julia functions:

- those that are used for their side effects (like `println`)
- those that return some results (like `getRectangleArea`)

The difference between the two may not be clear while using the interactive mode.
To make it more obvious let's put them to the script like so:

```
# file: sideEffsVsReturnVals.jl

# you need to define function before you call it
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

That's it. I got only one line of output, the rectangle area seems to be missing.
We must remember that a computer does only what we tell it to do, nothing more, nothing less.
Here we said:

- print "Hello World!" to the screen (actually [standard output](https://en.wikipedia.org/wiki/Standard_streams#Standard_output_(stdout)))
- calculate and return the area of the rectangle but we did nothing with it

It the second case the result went into the void (If a tree falls in a forest and no one's there to see it. Did it really make the sound?).

If we want to print both information on the screen we should modify our script to look like:

```
# file: sideEffsVsReturnVals.jl

# you need to define function before you call it
function getRectangleArea(lenSideA::Number, lenSideB::Number)::Number
    return lenSideA * lenSideB
end

println("Hello World!")

# println takes 0 or more arguments (separated by commas)
# if necessary arguments are converted to strings and printed
println("Rectangle area = ", getRectangleArea(3, 2), "[cm^2]")
```

Now You get:

```
Hello World!
Rectangle area = 6 [cm^2]
```

More information about functions can be found, e.g. [in this section of Julia Docs](https://docs.julialang.org/en/v1/manual/functions/).

If You ever encounter a build in function that you don't know, you may always search [the docs](https://docs.julialang.org/en/v1/) (search box -> top left corner of the page).

## Decision Making {#sec:julia_language_decision_making}

In everyday life people have to make decisions and so do computer programs. This is the job for `if ... elseif ... else` constructs.

### If ..., or Else ... {#sec:julia_language_if_else}

To demonstrate decision making in action let's say I want to write a function that accepts an integer as an argument and returns its textual representation.
Here we go.

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

As mentioned in @sec:julia_other_types `Bool` type can take one of two values `true` or `false`.
The code inside `if`/`elseif` clause runs only when the condition is `true`.
You can have any number of `elseif` clauses. Only the code for first `true` clause runs.
If none of the previous condition matches (each and every one is `false`) the code in `else` block is executed.
Only `if` and `end` keywords are obligatory, the rest is not, so you may use

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

or ..., nevermind, I think You got the point.

Below I place another example of a function using `if/elseif/else` construct (in order to remember it better).

```jl
s = """
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

Here I wrote a function that finds a minimal value in a vector of integers. If the vector is sorted in the ascending order it returns the first element.
If it is not, it sorts the vector using build in [sort](https://docs.julialang.org/en/v1/base/sort/#Base.sort) function and returns its first element (*this may not be the most efficient method*).
Note that the `else` block contains two lines of code (it could contain more if necessary, and so could `if` block).
I did this for demonstative purposes.
Alternatively instead those two lines (in `else` block) one could write `return sort(vect)[1]` and it would work just fine.

### Ternary expression {#sec:ternary_expression}

If you need only a single `if ... else` in your code you may prefer to replace it with ternary operator.
Its general form is `condition_or_Bool ? result_if_true : result_if_false`.

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

Much less code, works the same. Still, I would not overuse it.
For more than a single condition it is usually harder to write, read, and process in your head than the good old `if/elseif/else` block.

### Dictionaries {#sec:julia_language_dictionaries}

[Dictionaries in Julia](https://docs.julialang.org/en/v1/base/collections/#Dictionaries) are a sort of mapping.
Just like an ordinary dictionary is a mapping between a word and its definition.
We say that the mapping is between `key` and `value`. For instance let's say I want to define an English-Polish dictionary.

```jl
s = """
engPolDict::Dict{String, String} = Dict("one" => "jeden", "two" => "dwa")
engPolDict # the key order is not preserved on different computers
"""
sco(s)
```

Here I defined a dictionary of type `Dict{String, String}`, so, both the key and the value are of textual type (`String`).
The order of the keys is not preserved (this data structure cares more about lookup performance and not about the order of the keys).
Therefore, you may see different order of items after typing the code on your computer.

If I want to now how to say "two" in Polish I type `someDict[key]` (if the key is not there you will get an error), e.g.

```jl
s = """
engPolDict["two"]
"""
sco(s)
```

To add a new value to a dictionary (or to update the existing value) write `someDict[key] = newVal`.
Right now the key "three" does not exist in `engPolDict` so I would get an error (check it out), but if I type:

```jl
s = """
engPolDict["three"] = "trzy"
"""
sco(s)
```

Then I create (or update if it was already there) a key-value mapping.

Now, to avoid getting errors due to non-existing keys I can use a build-in [get](https://docs.julialang.org/en/v1/base/collections/#Base.get).
You use it in the form `get(collection, key, default)`, e.g. right now the word "four" (key) is not in a dictionary so I should get an error (check it out). But wait, there is `get`.

```jl
s = """
get(engPolDict, "four", "not found")
"""
sco(s)
```

OK, what anything of it got to do with `if/elseif/else` and decision making.
The thing is that if you got a lot of decisions to make then probably you will be better off with a dictionary. Compare

```jl
s = """
function translateEng2polVer1(engWord::String)::String
	if engWord == "one"
		return "jeden"
	elseif engWord == "two"
		return "dwa"
	elseif engWord == "three"
		return "trzy"
	elseif engWord == "four"
		return "jeden"
	else
		return "not found"
	end
end

(translateEng2polVer1("three"), translateEng2polVer1("ten"))
"""
sco(s)
```

with

```jl
s = """
function translateEng2polVer2(engWord::String, someDict::Dict{String, String} = engPolDict)::String
	return get(someDict, engWord, "not found")
end

(translateEng2polVer2("three"), translateEng2polVer2("twelve"))
"""
sco(s)
```

In `translateEng2polVer2` I used so called default value for an argument (`someDict::Dict{String, String} = engPolDict`).
This means that if the function is provided without the second argument then `engPolDict` will be used as its second argument.
If I defined the function as `translateEng2polVer2(engWord::String, someDict::Dict{String, String})` then while running the function I would have to write `(translateEng2polVer2("three", engPolDict), translateEng2polVer2("twelve", engPolDict))`.
Of course, I may prefer to use some other English-Polish dictionary (perhaps the one found on the internet) like so `translateEng2polVer2("three", betterEngPolDict)` instead of using the default `engPolDict` we got here.

*In general, the more `if ... elseif ... else` comparisons you got to the better off you are when you use dictionaries (especially that they could be written by someone else, you just use them).*

OK, enough of that. If you want to know more about conditional evaluation check [this part of Julia docs](https://docs.julialang.org/en/v1/manual/control-flow/#man-conditional-evaluation).

## Repetition {#sec:julia_language_repetition}

Julia, and computers in general, are good at doing boring, repetitive tasks for us without a word of complaint (and they do it much faster than we do). Let's see some constructs that help us with it.

### For loops {#sec:julia_language_for_loops}

A [for loop](https://en.wikipedia.org/wiki/For_loop) is a standard construct present in many programming languages that do the repetition for us. Its general form in Julia is:

```
for i in sequence
	# do_something_useful
end
```

The loop is enclosed between `for` and `end` keywords and repeats some specific action(s) (`# do_something_useful`) for every element of a `sequence`.
On each turnover of a loop consecutive elements of a sequence are referred to by `i`.

> **_Note:_** I could have assigned any name, like: `j`, `k`, `whatever`, it would work the same. Still, `i` and `j` are quite common in [for loops](https://en.wikipedia.org/wiki/For_loop).

Let's say I want a program that will print [hip hip hooray](https://en.wikipedia.org/wiki/Hip_hip_hooray) many times for my friend that celebrates some success. I can proceed like this.

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

Notice two new elements. Here it makes no sense for `n` to be less than of equal to 0.
Hence, I used [\@assert](https://docs.julialang.org/en/v1/base/base/#Base.@assert) construct to test it and print an error message (`"n needs to be greater than 0"`) if it is.
The `1:n` is a range similar to the one we used in @sec:julia_vectors. Here, I used `_` instead of `i` in the example above (to signal that I don't plan to use it further).

OK, how about another example. You remember `myMathGrades`, right?

```jl
s = """
myMathGrades = [3.5, 3.0, 3.5, 2.0, 4.0, 5.0, 3.0]
"""
sc(s)
```

Now, since the end of the school year is coming then I would like to know my [average](https://en.wikipedia.org/wiki/Arithmetic_mean) (likely this will be my final grade).
In order to get that I need to divide the sum by the number of grades. First the sum.


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

In arguments list I wrote `::Vector{<:Real}`. Which means that each element of nums is a subtype (`<:`) of the type `Real` (which includes integers and floats). I declared a `total` and initialized it to 0.
Then in `for` loop I used `i` to hold numbers from 1 to number of elements in the vector (`length(nums)`).
Finally, in the for loop body I added each number from the vector (using indexing see @sec:julia_vectors) to the `total`.
The `total = total + nums[i]` means that new total is equal to old total + element of the vector with index `i`. Finally, I returned the total.

The body of the `for` loop could be improved. Instead of `for i in 1:length(nums)` I could have written `for i in eachindex(nums)` (notice there is no `1:`).
Moreover, instead of `total = total + nums[i]` I could have used `total += nums[i]`.
The `+=` is and [update operator](https://docs.julialang.org/en/v1/manual/mathematical-operations/#Updating-operators), i.e.
a shortcut for updating old value by adding a new value to it. Take a moment to rewrite the function with those new forms and test it.

Alternatively, I can do this without indexing (although `for` loops with indexing are a kind of classical idiom in programming and it is worth to know them).

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

Here `num` (I could have used `n`, `i` or `whatever` if I wanted to) takes the value of each consecutive element of `nums` and adds it to the total.

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

Ups, not quite 3.5, I'll better present some additional projects to improve my final grade.

OK, two more examples that might be useful and will help you master `for` loops even better.

Let's say I got a vector of temperatures in [Celsius](https://en.wikipedia.org/wiki/Celsius) and want to send it to a friend in the US.

```jl
s = """
temperaturesCelsius = [22, 18.3, 20.1, 19.5]
"""
sco(s)
```

To make it easier for him I should probably change it to [Fahrenheit](https://en.wikipedia.org/wiki/Fahrenheit)
using [this formula](https://en.wikipedia.org/wiki/Fahrenheit#Conversion_(specific_temperature_point)).
I start with writing simple converting function for a single value of the temperature in Celsius.


```jl
s = """
function degCels2degFahr(tempCels::Real)::Real
	return tempCels * 1.8 + 32
end

degCels2degFahr(0)
"""
sco(s)
```

Now let's convert the temperatures in the vector. First I would try something like this:

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

Still, this is not good. If I use it (`degCels2degFahr!(temperatureCelsius)`) it will change the values in `temperaturesCelsius` to Fahrenheit which could cause problems (variable name doesn't reflect its contents).
A better approach is to write a function that produces a new vector and doesn't change the old one.

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

First of all, notice that so far I defined two functions named `degCels2degFahr`.
One of them has got a single value as an argument (`degCels2degFahr(tempCels::Real)`) and another a vector as its argument (`degCels2degFahr(tempsCels::Vector{<:Real})`).
But since I explicitly declared argument types, Julia will know when to use each version (see next paragraph).

In the body of `degCels2degFahr(tempsCels::Vector{<:Real})` first I declare and initialize a variable that will hold the result (hence `result`).
I do this using build in [zeros](https://docs.julialang.org/en/v1/base/arrays/#Base.zeros) function.
The function returns a new vector with n elements (where n is equal to `length(tempsCels)`) filled with, you got it, 0s. The 0s are just placeholders.
Then, in the `for` loop, I go through all the indices of `result` (`i` holds the current index) and replace each zero (`result[i]`) with a corresponding value in Fahrenheit (`degCels2degFahr(tempsCels[i])`).
Here, since I pass a single value (`tempsCels[i]`) Julia knows which version (aka method) of the function `degCels2degFahr` to use (i.e. this one `degCels2degFahr(tempCels::Real)`).

OK, enough for the classic `for` loops. Let's go to some build-in goodies that could help us out with repetition.

### Build-in Goodies {#sec:julia_language_buildin_goodies}

If the operation you want to perform is simple enough you may prefer to use some Julia goodies.

### Reduce {#sec:julia_language_reduce}

Remember the `getSum` function that we wrote previously. Well, it can be made shorter by using [reduce](https://docs.julialang.org/en/v1/base/collections/#Base.reduce-Tuple{Any,%20Any}).

```jl
s = """
xs = [1, 2, 3]

function getSum(nums::Vector{<:Real})::Real
	return reduce((x, y) -> x + y, xs, init=0)
end

getSum(xs)
"""
sco(s)
```

As you can see `reduce` accepts 3 arguments: a function, a collection, and initial value.
Here, I used so called [anonymous function](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions), so a function without name.
The expression `(x, y) -> x + y` means a function that takes two arguments and returns their sum. The `reduce` takes this function and executes it many times, each time:

1. one argument is `init` (if executed for the first time) or the result of previous execution
2. the other argument is consecutive element of the collection

So, in the case above I imagine it does something like:

```
# call: reduce((x, y) -> x + y, [1, 2, 3], init=0)
0 + 1 # (init + current element), result: 1
1 + 2 # (previous result + current element), result: 3
3 + 3 # (previous result + current element), result: 6
# no more elements left, the result of the last operation is returned
```

*Note. the order of `+` operation is not guaranteed, e.g. it could go innit/result + current or current + innit/result.*

In this case `reduce` could be further simplified, but I assume you already have a lot to wrap your head around so I leave it as it is.
Just remember to type `init=` and then the default argument
(not the value alone, since it is a [keyword argument](https://docs.julialang.org/en/v1/manual/functions/#Keyword-Arguments)).

### Comprehensions {#sec:julia_language_comprehensions}

Another useful constructs are [comprehensions](https://docs.julialang.org/en/v1/manual/arrays/#man-comprehensions).

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

On the right I use the familiar `for` loop syntax, i.e. `for sth in collection`.
On the left I place a function (named or anonymous) that I want to use and pass consecutive elements (`sth`) to that function.
The expression is surrounded with square brackets so that Julia makes a new vector out of it (the old vector is not changed).

### Map and Foreach {#sec:julia_language_map_foreach}

Comprehensions are nice, but some people find [map](https://docs.julialang.org/en/v1/base/collections/#Base.map) even better. The example above could be rewritten as:

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

Again, I pass function (note I typed only its name) as a first argument to `map`, the second argument is a collection.
Map automatically applies the function to every element of the collection and returns a new collection. Isn't this magic.

If you want to evoke a function on a vector just for side effects (does not return/build a vector) use [foreach](https://docs.julialang.org/en/v1/base/collections/#Base.foreach).
For instance, `getSum` with `foreach` and an anonymous function would look like this

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

### Dot operators/functions {#sec:julia_language_dot_functions}

Last but not least. I can use a [dot operator](https://docs.julialang.org/en/v1/manual/mathematical-operations/#man-dot-operators).
Say I got a vector of numbers and I want to add 10 to each of them. Doing this for a single number is simple, I would have just typed `1 + 10`.
Hmm, but for a vector? Simple as well. I just need to precede the operator with a `.` like so:


```jl
s = """
[1, 2, 3] .+ 10
"""
sco(s)
```

I can do this also for functions (both build-in and written by myself). Notice `.` goes before `(`


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

OK, the goodies are great, but require some time to get used to them (I suspect at first you're gonna use good old `for` loop syntax).
Besides the constructs described in this section are good for simple operations (don't try to put too much logic into them, they are supposed to be one liners).

In any case choose a construct that you know how to use and that gets the job done for you, mastering them all will take some time.

## Additional libraries {#sec:julia_language_libraries}

OK, there is one more thing I want to briefly talk about, and it is [libraries](https://en.wikipedia.org/wiki/Library_(computing)).

A library is a piece of code that someone else wrote for you.
At the time I'm writing these words there are over 9'000 libraries (aka packages) in Julia ([see here](https://julialang.org/packages/)) available under different licenses.
If the package is under [MIT license](https://en.wikipedia.org/wiki/MIT_License) (a lot of them are) then basically you may use it freely, but without any warranty.

To install a package you use [Pkg](https://docs.julialang.org/en/v1/stdlib/Pkg/), i.e. Julia's build in package manager. Click the link in the previous sentence to see how to do it.

In general there are two ways to use a package in your project:

1. by typing `using Some_pkg_name`
2. by typing `import Some_pkg_name`

Personally, I prefer the latter. Actually, I use it in the form `import Some_pkg_name as abbreviated_pkg_name` (you will see why in a moment).

Let's see how it works. Remember the `getSum` and `getAvg` functions that we wrote ourselves. Well, Julia got build-in [sum](https://docs.julialang.org/en/v1/base/collections/#Base.sum) and [Statistics](https://docs.julialang.org/en/v1/stdlib/Statistics/) got [mean](https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.mean).
To use it I type at the top of my file (it is a good practice to do so):


```jl
s = """
import Statistics as stats
"""
sc(s)
```

Now I can assess any of its functions by preceding them with `stat` (my abbreviation) and `.` like so


```jl
s = """
stats.mean([1, 2, 3])
"""
sco(s)
```

And that's it. It just works.

Note that if you type `import Statistics` instead of `import Statistics as stats` then in order to use `mean` you will have to type `Statistics.mean([1, 2, 3])`.
So in general is is worth to give some shorter name for an imported package.

Oh yeah, one more thing. In order to know what are the functions in a library and how to use them you should check the library documentation.

OK, end of theory, time for some practice.

## Julia - Exercises {#sec:julia_language_exercises}

I once heard that in chess you can get only as much as you give. I believe it is also true for programming (and most likely many other human activities).

So, here are some exercises that you may want to solve to get from this chapter as much as you can.

> **_Note:_** Some readers probably will not solve the exercises. They will not want to or will not be able to solve them (in that case my apology for the inapprorpiate difficulty level). Either way, I suggest you read the task descriptions and the solutions (and try to understand them). In those sections I may use, e.g. some language constructs that I will not explain again in the upcoming chapters.

### Exercise 1 {#sec:julia_language_exercise1}

Imagine the following situation. You and your friends call to order out a pizza. You got only \$50 and you are pretty hungry.
But you got a dilemma, for exactly \$50 you can either order 2 pizzas 30 cm in diameter each, or 1 pizza 45 cm in diameter. Which one is more worth it?

*Hint: Assume that the pizza is flat and that you are eating its surface.*

*Hint: You may want to search [the documentation](https://docs.julialang.org/en/v1/) for `Base.MathConstants` and use one of them.*

### Exercise 2 {#sec:julia_language_exercise2}

When we talked about float comparisons (@sec:julia_float_comparisons) we said to be careful since

```jl
s = """
(0.1 * 3) == 0.3
"""
sco(s)
```

Write a function with the following signature `areApproxEqual(f1::Float64, f2::Float64)::Bool`.
It should return `true` when called with those numbers (`areApproxEqual(0.1*3, 0.3)`).
For the task you may use [round](https://docs.julialang.org/en/v1/base/math/#Base.round-Tuple{Complex{%3C:AbstractFloat},%20RoundingMode,%20RoundingMode}) with a precision of, let's say, 16 digits.

### Exercise 3 {#sec:julia_language_exercise3}

Remember `getMin` from previous chapter (see @sec:ternary_expression)

```jl
s = """
function getMin(vect::Vector{Int}, isSortedAsc::Bool)::Int
    return isSortedAsc ? vect[1] : sort(vect)[1]
end"""
sco(s)
```

Write `getMax` with the following signature `getMax(vect::Vector{Int}, isSortedDesc::Bool)::Int` use only the elements from previous version of the function (you should modify them).

### Exercise 4 {#sec:julia_language_exercise4}

Someone once told me that the simplest interview question for a candidate programmer is [fizz buzz](https://en.wikipedia.org/wiki/Fizz_buzz).
If a person doesn't know how to do that there is no point of examining them further.

I don't know if that's true, but here we go.

Write a program for a range of numbers 1 to 30.
If a number is divisible by 3 it prints "Fizz" on the screen.
If a number is divisible by 5 it prints "Buzz" on the screen.
If a number is divisible by 3 and 5 it prints "Fizz Buzz" on the screen.
Otherwise it prints the number itself.

If you feel stuck right now, don't worry. It sounds difficult, because so far you don't know all the necessary elements to solve it.
Still, I believe you can do this by reading the Julia docs and using your favorite web search engine.

Here are some constructs that might be useful to solve this task:

- for loop (see @sec:julia_language_for_loops)
- if/elseif/else (see @sec:julia_language_if_else)
- [modulo operator or rem function](https://docs.julialang.org/en/v1/base/math/#Base.rem)
- 'logical and', see [this](https://docs.julialang.org/en/v1/manual/missing/#Logical-operators) and [that](https://docs.julialang.org/en/v1/manual/missing/#Control-Flow-and-Short-Circuiting-Operators) section of Julia docs
- [string function](https://docs.julialang.org/en/v1/base/strings/#Base.string)

You may use some or all of them. Or perhaps you can come up with something else. Good luck.

### Exercise 5 {#sec:julia_language_exercise5}

I once heard a story about chess.

According to the story the game was created by a Hindu wise man. He presented his invention to his king which was so impressed that he offered to fulfill his request as a reward.

- I want nothing but some wheat grains.
- How many?
- Put 1 grain on the first field, 2 grains on the second, 4 on the third, 8 on the fourth, and so on. I want the grains that are on the last field.

A laughingly small request, thought the king. Or is it?

Use Julia to answer how many grains are on the last (64th) field.

*Hint. If you get a strange looking result, use [BigInt](https://docs.julialang.org/en/v1/base/numbers/#BigFloats-and-BigInts) data type instead of [Int](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Integers).*

### Exercise 6 {#sec:julia_language_exercise6}

Lastly, to cool down a little write a function `getInit` that takes a vector of any type as an argument and returns the vector without its last element.

You may either use the generics (preferred way to solve it, see @sec:functions_with_generics) or write the function without type declarations (acceptable solution).

Remember about the indexing (see @sec:julia_vectors). Think (or search for the answer e.g. in the internet) how to get one but last element of an array.

Usage examples:

```
getInit([1, 2, 3, 4])
# output: [1, 2, 3, 4]
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

In this sub-chapter you may find possible solutions to the exercises from the previous section.

### Solution to Exercise 1 {#sec:julia_language_exercise1_solution}

Since I'm eating a surface, and the task description gives me diameters, then I should probably calculate [area of circle](https://en.wikipedia.org/wiki/Area_of_a_circle).
I will use [Base.MathConstants.pi](https://docs.julialang.org/en/v1/base/numbers/#Base.MathConstants.pi) in my calculations.

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

It seems that I will get more food while ordering this one pizza (45 cm in diameter) and not those two pizzas (each 30 cm in diameter).

If all the pizzas were [cylinders](https://en.wikipedia.org/wiki/Cylinder) of equal heights (say 2 cm each) then I would calculate their volumes like so

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

> **_Note:_** I could have used `^`, which is an exponentiation operator in Julia. If I want to raise 2 to the fourth power I can type `2^4` or `2*2*2*2` and get `jl 2^4`.

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

Seems to be working fine. Still, you may prefer to use Julia's build-in [isapprox](https://docs.julialang.org/en/v1/base/math/#Base.isapprox).
Example

```jl
s = """
isapprox(0.1*3, 0.3)
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

or if you read the documentation for [sort](https://docs.julialang.org/en/v1/base/sort/#Base.sort)

```jl
s2 = """
function getMax(vect::Vector{Int}, isSortedDesc::Bool)::Int
    return isSortedDesc ? vect[1] : sort(vect, rev=true)[1]
end

(getMax([3, 2, 1], true), getMax([2, 3, 1], false))
"""
sco(s2)
```

Sorting an array to get the maximum (or minimum) value is not the most effective (sorting is based on rearanging elements and takes quite some time). Traveling through an array only once should be faster. Therefore probably a better solution (in terms of performance) would be something like

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

> **_Note:_** Julia already got similar functionality to `getMin`, `getMax` that we developed ourselves.
See [min](https://docs.julialang.org/en/v1/base/math/#Base.min),
[max](https://docs.julialang.org/en/v1/base/math/#Base.max),
[minimum](https://docs.julialang.org/en/v1/base/collections/#Base.minimum),
and [maximum](https://docs.julialang.org/en/v1/base/collections/#Base.maximum).

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

Go ahead, test it out.

If you like challenges try to follow the execution of this program

```jl
s2 = """
function getFizzBuzz(num::Int)::String
	return (
		rem(num, 3) == 0 && rem(num, 5) == 0 ? "Fizz Buzz" :
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

There are probably other more creative [or more (unnecessarily) convoluted] ways to solve this task.
Personally, I would be satisfied if you understand the first version.

### Solution to Exercise 5 {#sec:julia_language_exercise5_solution}

For more information about the legend see [this Wikipedia's article](https://en.wikipedia.org/wiki/Sissa_(mythical_brahmin)).

If you want some more detailed mathematical explanation you can read [that Wikipedia's article](https://en.wikipedia.org/wiki/Wheat_and_chessboard_problem).

The Wikipedia's version of the legend differs slightly from mine, but I like mine better.

Anyway I'll jump right into some looping.

```jl
s1 = """
function getNumOfGrainsOnField64()::Int
	noOfGrains::Int = 1 # no of grains on field 1
	for _ in 2:64
		noOfGrains *= 2
	end
	return noOfGrains
end

getNumOfGrainsOnField64()
"""
sco(s1)
```

Hmm, that's odd, a negative number.

Wait a moment. Now I remember, a computer got finite amount of memory. So in order to work efficiently data is stored in small pre-allocated pieces of it.
If the number you put into that small 'memory drawer' is greater than the amount of space you get strange results.

You can read more about it in Julia docs (sections [Integers](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Integers) and [Overflow Behavior](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Overflow-behavior)).

You can check the minimum and maximum value for `Int` by typing `typemin(Int)` and `typemax(Int)` on my laptop those are `jl typemin(Int)` and `jl typemax(Int)`, respectively.

It is enough for most calculations, still if you expect a really big number you should use [BigInt](https://docs.julialang.org/en/v1/base/numbers/#BigFloats-and-BigInts).

So let me correct my code

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

Whoa, that number got like `jl length(string(getNumOfGrainsOnField64()))` digits. I don't even know how to name it. It cannot be that big, can it?

OK, quick verification with some mathematical calculation (don't remember `^`? See @sec:julia_language_exercise1_solution).

```jl
s3 = """
BigInt(2)^63 # we multiply 2 by 2 by 2, etc. for fields 2:64
"""
sco(s3)
```

Yep, numbers appear to be the same

```jl
s = """
getNumOfGrainsOnField64() == BigInt(2)^63
"""
sco(s)
```

So I guess the [aforementioned Wikipedia's article](https://en.wikipedia.org/wiki/Wheat_and_chessboard_problem) is right, it is more than a country (or the world) could produce in a year.

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

The parenthesis around `(end-1)` are not necessary. I added them for better clarity of how the last by one index is calculated.

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

BTW. Try to remove type declarations and see if the function still works (if you do this right then it should).

OK, that's it for now. Let's move to another chapter.
