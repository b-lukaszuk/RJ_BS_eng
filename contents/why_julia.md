# Why Julia {#sec:why_julia}

Before we jump into statistics I think we need to explain why should we use
[Julia](https://julialang.org/) and not, e.g. [Python](https://www.python.org/)
or [R](https://www.r-project.org/).

In other words, am I mad to use Julia for statistics instead of R (a project
developed for statistical computing) or more popular (also in the field of Data
Science) Python?

Well, I hope that I'm just biased. I like Julia because:

1. it's fast
2. it's simple
3. it's a pleasure to write programs with it
4. it's a less mainstream language
5. it's free and open source

## Julia is fast {#sec:julia_is_fast}

Once upon a time I wrote these three time consuming programs (so hold your
horses, you may not want to run them):

```
# file: test.jl
for i in 1:1_000_000_000
	if i == 500_000_000
		println("Half way through. I counted to 500 million.")
	end
end
println("Done. I counted to 1 billion.")
```

```
# file: test.py
for i in range(1_000_000_000):
	if i == 500_000_000:
		print("Half way through. I counted to 500 million.")
print("Done. I counted to 1 billion.")
```

```
# file: test.r
for (i in 1:1000000000) {
  if (i == 500000000) {
    print("Half way through. I counted to 500 million.")
  }
}
print("Done. I counted to 1 billion.")
```

> **_Note:_** Python and Julia allow to write numbers either like this: `1000`,
> or like that `1_000`. The latter form uses `_` to separate thousands, so more
> typing, but it is more legible.

Each program counts to 1 billion (1 with 9 zeros). Once it is half way through
it displays an info on the screen and when it is done counting it prints another
message.

The execution times of the scripts on my few-years old laptop (the specification
is not that important):

1. Julia: ~1.5 [sec]
2. R: ~33 [sec]
3. Python3: ~50 [sec]

Granted, it's not a proper benchmark, and e.g. Python's
[numpy](https://github.com/numpy/numpy) library runs with the speed of
[C](https://en.wikipedia.org/wiki/C_(programming_language)) (so a bit faster
than Julia). Nevertheless, the code that I write in Julia is consistently ~8-10
times faster than the code I write in the other two programming languages. This
is especially evident when running computer simulations like the ones you may
find in this book, still, it is just a subjective feeling.

**Fun fact**: A human being would likely need more than 32 years to count to 1
billion.  Test yourself and show why. *Hint: try to estimate for how long you
are alive [in seconds].*

## Julia is simple {#sec:julia_is_simple}

What I mean by Julia's simplicity is its nice, friendly and terse syntax.

For instance to write a simple [Hello
world](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program) program all I
have to do is to type:

```
println("Hello World!")
```

then save and run the file.

For comparison a similar program in
[Java](https://en.wikipedia.org/wiki/Java_(programming_language)) (a popular
programming language) looks something like:

```
// file: HelloWorld.java
class HelloWorld {
    public static void main(String args[]) {
        System.out.println("Hello World");
    }
}
```

For me too much boilerplate code. The code that I don't want to type, read or
process in my head. Additionally, in general a java code will probably not run
faster than its Julia's counterpart. Moreover, the difference in lengths may be
even greater for more complicated programs.

## Pleasure to write {#sec:jl_pleasure_to_write}

According to [this stack overflow's
survey](https://survey.stackoverflow.co/2022/#section-most-loved-dreaded-and-wanted-programming-scripting-and-markup-languages)
Julia got one of the best loved/dreaded ratio among the examined programming
languages.

This is also true for me. I like writing programs in Julia (hopefully so will
you).

## Not mainstream {#sec:jl_not_mainstream}

Not being 'a mainstream programming language' got its drawbacks (missing
packages or community support, etc.). Luckily, Julia is big and mature enough,
it seems to be growing at a good pace, and got a pretty nice
[interoperability](https://forem.julialang.org/ifihan/interoperability-in-julia-1m26)
with other programming languages.

Moreover, not being a mainstream language is like an opportunity, a gap to fill,
a venue to explore (hence this book).

## Julia is free {#sec:jl_open_source}

Julia is a free and open source programming language as stated on its [official
website](https://julialang.org/):

> Julia is an open source project with over 1,000 contributors. It is made
> available under the MIT license. The source code is available on GitHub.

OK, enough preaching, time for our first date with Julia.
