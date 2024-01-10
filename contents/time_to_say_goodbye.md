# Time to say goodbye {#sec:time_to_say_goodbye}

They say that all that has its beginning must have its end. So I guess it's time
to ..., OK, but before we part let me give you a word of advice.

Julia is a nice programming language with many applications, including
statistics (probably way beyond the level covered in this book). Still, if you
are new to (Julia) programming and statistics then most likely you should
calibrate your tools first. Before you run some statistical analysis you may
want to try it out on an example from a textbook written by an expert (not me
though) and see if you get the same (or at least comparable) result on your
own. Although this is a sound approach, I suspect you are more prone to visit
some statistical blog or internet forum and go with the examples that are
contained there. One such option is [rseek.org](https://rseek.org/), i.e. a
search engine for [the R programming
language](https://en.wikipedia.org/wiki/R_(programming_language)). In that case
[RCall.jl](https://github.com/JuliaInterop/RCall.jl) will be of assistance.

For instance let's say that I copied the `beerVolumes` example (see
@sec:compare_contin_data_one_samp_ttest) from some R forum (I didn't). Now,
without leaving Julia I can paste and execute the R's code (R's code goes
between the quotation marks in `RC.R""`).

```
import RCall as RC

RC.R"
beerVolumes <- c(504, 477, 484, 476, 519, 481, 453, 485, 487, 501)
t.test(beerVolumes, mu=500)
"
```

> **_Note:_** For that code to work you need to have the R programming language
> installed on your machine.

```
        One Sample t-test

data:  beerVolumes
t = -2.3294, df = 9, p-value = 0.04479
alternative hypothesis: true mean is not equal to 500
95 percent confidence interval:
 473.7837 499.6163
sample estimates:
mean of x
    486.7
```

Then, I can compare it with the output of `Htests.OneSampleTTest`. That way I
can validate it and see if it is a credible Julia's equivalent of R's `t.test`.
The above, is also the way to test my understanding of Julia's function that
stems from the
[docs](https://juliastats.org/HypothesisTests.jl/stable/parametric/#t-test).

```jl
s = """
import HypothesisTests as Htests

beerVolumes = [504, 477, 484, 476, 519, 481, 453, 485, 487, 501]
Htests.OneSampleTTest(beerVolumes, 500)
"""
sco(s)
```

Once I got both outputs that are similar enough I can be fairly sure I did
right. Otherwise I should investigate where the differences come from and
possibly make some necessary adjustments.

Now, let me follow a word of advice with a word of warning. The book contains a
description of statistics the way I see it, not necessarily the way it really
is. Additionally, many times I simplified stuff, e.g. by avoiding mathematics
(and formulas) beyond the level of a primary school (in Poland grades 1-8) and
limiting the number of Julia's constructs in the examples. In the end I wrote
that book for myself from the past, so if you ever met me then be sure to pass
it on me. I would have loved to read it. But then again, back in the day when I
was a student there was no Julia, and my English was too poor. Oh, well, just
enjoy the book yourself.

Take care.

Bartlomiej Lukaszuk - author
