# Why Julia {#sec:why_julia}

Before we jump into statistics I think we need to explain why do we use [Julia](https://julialang.org/) and not, e.g. [Python](https://www.python.org/) or [R](https://www.r-project.org/).

In other words, mm I mad to use Julia for statistics instead of R (a project developed for statistical computing) or more popular (also in the field of Data Science) Python?

Well, I hope that I'm just biased. I like Julia because:

1. it's fast
2. it's simple
3. it's a pleasure to write programs with it
4. it's a less mainstream language
5. it's free and open source

## Julia is fast {#sec:julia_is_fast}

Once upon a time I wrote three time consuming programs (so hold your horses, you may not want to run them):

```
# file: test.jl
for i in 1:1_000_000_000
# do nothing
end
println("Done. I counted to 1 billion.")
```

```
# file: test.py
for i in range(1_000_000_000):
    pass # do nothing
print("Done. I counted to 1 billion.")
```

```
# file: test.r
for (i in 1:1000000000) {
	# do nothing
}
print("Done. I counted to 1 billion.")
```

> **_Note:_** Python and Julia allow to write numbers either like this: `1000` or `1_000`. The other form uses `_` to separate thousands, so more typing, but it is more legible.

Anyway, each program counts to 1 billion (1 with 9 zeros). Once it is done it prints info on the screen.


Execution times of the scripts on my laptop (the specification is not that important):

1. Julia: ~1 [sec]
2. R: ~9 [sec]
3. Python3: ~27 [sec]

Granted, it's not a proper benchmark, and e.g. Python's [numpy](https://github.com/numpy/numpy) library runs with the speed of [C](https://en.wikipedia.org/wiki/C_(programming_language)) (so a bit faster than Julia). Still, the code that I write in Julia is consistently ~8-10 times faster than the code I write in the other two programming languages (a subjective feeling).

**Fun fact**: a human being would need like 32 years to count to 1 billion.
Test yourself and show why. Hint: try to count/estimate for how long you are alive [in seconds].

## Julia is simple {#sec:julia_is_simple}

What I mean by Julia's simplicity is its nice, friendly and terse syntax.

For instance to write a simple `Hello world` program all I have to do is to type:

```
println("Hello World!")
```

then save and run the file.

For comparison similar program in [Java](https://en.wikipedia.org/wiki/Java_(programming_language)) (a popular programming language) looks something like:

```
// file: HelloWorld.java
class HelloWorld {
    public static void main(String args[]) {
        System.out.println("Hello World");
    }
}
```

For me too much boilerplate code. The code that I don't want to type, read or process in my head. Additionally, probably it will not run faster than the Julia's equivalent.

## Pleasure to write {#sec:jl_pleasure_to_write}

According to [stack overflow's survey](https://survey.stackoverflow.co/2022/#section-most-loved-dreaded-and-wanted-programming-scripting-and-markup-languages) Julia got one of the best loved-dreaded ratio among the examined programming languages.

This is also true for me. I like writing programs with Julia (hopefully so will you).

## Not mainstream {#sec:jl_not_mainstream}

Not being 'a mainstream programming language' got its drawbacks (missing packages or community support, etc.). Luckily, Julia is big and mature enough, seems to be growing at a good pace, and got a pretty nice [interoperability](https://forem.julialang.org/ifihan/interoperability-in-julia-1m26) with other programming languages.

Moreover, not being a mainstream language is like an opportunity, a gap to fill, a chance to explore (hence this book).

## Julia is free {#sec:jl_open_source}

Julia is free and open source as stated on its [official website](https://julialang.org/):

> Julia is an open source project with over 1,000 contributors. It is made available under the MIT license. The source code is available on GitHub.
