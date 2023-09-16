# Comparisons - categorical data {#sec:compare_categ_data}

OK, once we have comparisons of continuous data under our belts we can move to
groups of categorical data.

## Chapter imports {#sec:compare_categ_data_imports}

Later in this chapter we are going to use the following libraries

```jl
s = """
import CairoMakie as Cmk
import Distributions as Dsts
import HypothesisTests as Htests
import Random as Rand
"""
sc(s)
```

If you want to follow along you should have them installed on your system. A
reminder of how to deal (install and such) with packages can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/). But wait, you may prefer
to use `Project.toml` and `Manifest.toml` files from the [code snippets for this
chapter](https://github.com/b-lukaszuk/RJ_BS_eng/tree/main/code_snippets/ch06)
to install the required packages. The instructions you will find
[here](https://pkgdocs.julialang.org/v1/environments/).

The imports will be in in the code snippet when first used, but I thought it is
a good idea to put them here, after all imports should be at the top of your
file (so here they are at top of the chapter). Moreover, that way they will be
easier to find all in one place.

If during the lecture of this chapter you find a piece of code of unknown
functionality, just go to the code snippets mentioned above and run the code
from the `*.jl` file.  Once you have done that you can always extract a small
piece of it and test it separately (modify and experiment with it if you
wish).

## Flashback {#sec:compare_categ_data_flashback}

We deal with a categorical data when a variable can take a value from a small
set, each element of the set is clearly distinct from the other elements. One
such case is a binomial distribution that we met in @sec:statistics_intro and
its subsections.

For instance in Exercise 3 (see @sec:statistics_intro_exercise3 and
@sec:statistics_intro_exercise3_solution) we calculated the probability that
Peter is a better tennis player than John if he won 5 games out of 6. The
two-tailed probability was roughly equal to
 `jl round(probBothOneTail * 2, digits=2)`.
Once we know the logic behind the calculations (see
@sec:statistics_intro_exercise3_solution) we can fast forward
to the solution with
[Htests.BinomialTest](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#Binomial-test)
like so

```jl
s = """
Htests.BinomialTest(5, 6, 0.5)
# or just: Htests.BinomialTest(5, 6) # (since 0.5 is the default value)
"""
sco(s)
```

Works like a charm. Don't you think. Here the 95% confidence interval is an
estimate of the true probability of Peter's victory in a game (from data it is
5/6 = `jl round(5/6, digits=2)`). I leave the rest of the output to decipher to
you (as a mini-exercise).

In general `Htests.BinomialTest` is useful when you want to compare the obtained
experimental probability with a known probability in a population. Another use
case in biological sciences would be this. Imagine that there is some disease
that you study. It's prevalence in a general population is estimated to be ≈
$\frac{10}{100}$ = 0.1 = 10%. You happened to found a human population on an
island and noticed that 519 adults out of 3'202 suffer from the disease of
interest. You run the test to see if that differs from the general population.

```jl
s = """
Htests.BinomialTest(519, 3202, 0.1)
"""
sco(s)
```

And it turns out that it does. You discovered a local population with a
different, clearly higher prevalence of the disease. Now you (or other people)
can study the population closer (e.g. gene screening) in order to find the
features that are triggering the the onset of the disease.

The story is not that far fetched since there are human populations investigated
closely due to their unusually common occurrence of some diseases (e.g. [the
Akimel O'odham](https://en.wikipedia.org/wiki/Akimel_O%27odham) and their high
prevalence of [type 2 diabetes](https://en.wikipedia.org/wiki/Type_2_diabetes)).

To be continued...
