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
set of values. Each element of the set is clearly distinct from the other
elements. One such case is a binomial distribution that we met in
@sec:statistics_intro and its subsections.

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
# or just: Htests.BinomialTest(5, 6)
# since 0.5 is the default prob. for the population
"""
sco(s)
```

Works like a charm. Don't you think. Here the we got a two-tailed p-value.
The 95% confidence interval is an estimate of the true probability of Peter's
victory in a game (from data it is 5/6 = `jl round(5/6, digits=2)`). I leave the
rest of the output to decipher to you (as a mini-exercise).

In general `Htests.BinomialTest` is useful when you want to compare the obtained
experimental probability with a known probability in a population.

Let's look at another example from the field of biological sciences. Imagine
that there is some disease that you want to study. Its prevalence in the general
population is estimated to be ≈ $\frac{10}{100}$ = 0.1 = 10%. You happened to
found a human population on a desert island and noticed that 519 adults out of
3'202 suffer from the disease of interest. You run the test to see if that
differs from the general population.

```jl
s = """
Htests.BinomialTest(519, 3202, 0.1)
"""
sco(s)
```

And it turns out that it does. Congratulations, you discovered a local
population with a different, clearly higher prevalence of the disease. Now you
(or other people) can study the population closer (e.g. gene screening) in order
to find the features that are triggering the the onset of the disease.

The story is not that far fetched since there are human populations that are of
particular interest to scientists due to their unusually common occurrence of
some diseases (e.g. [the Akimel
O'odham](https://en.wikipedia.org/wiki/Akimel_O%27odham) and their high
prevalence of [type 2 diabetes](https://en.wikipedia.org/wiki/Type_2_diabetes)).

## Chi squared test {#sec:compare_categ_data_chisq_test}

We finished the previous section by comparing the proportion of subjects with
some feature to the reference population. For that we used
`Htests.BinomialTest`. As we learned in @sec:statistics_normal_distribution the
word binomial means two names. Those names could be anything, like heads and
tails, victory and defeat, but most generally they are called success and
failure (success when an event occurred and failure when it did not).  We can
use `a` to denote individuals with the feature of interest and `b` to denote the
individuals without that feature. In that case `n` is the total number of
individuals (here, individuals with either `a` or `b`). That means that by doing
`Htests.BinomialTest` we compared the sample fraction (e.g. $\frac{a}{n}$ or
equivalently $\frac{a}{a+b}$) with the assumed fraction of individuals with the
feature of interest in the general population.

Now, imagine a different situation. You take the samples from two populations,
and observe the [eye color](https://en.wikipedia.org/wiki/Eye_color) of
people. You want to know if the percentage of people with blue eyes in the two
populations is similar. If it is, then you may deduce they are closely related
(perhaps one stems from the other). Let's not look too far, let's just take the
population of the US and UK. Based on the Wikipedia's page from the link above
and the random number generator in Julia I came up with the following counts.

```jl
s = """
dfEyeColor = Dfs.DataFrame(;
	eyeCol=["blue", "any"], us = [161, 481], uk=[220, 499])
Options(dfEyeColor, caption="Eye color distribution in two samples.", label="dfEyeColor")
"""
replace(sco(s), Regex("Options.*") => "")
```

Here, we would like to compare if the two proportions ($\frac{a_1}{n_1} =
\frac{161}{481}$ and $\frac{a_2}{n_2} = \frac{220}{499}$) are roughly equal
($H_0$ they come from the same population with currently unknown fraction of
blue eyed people). Unfortunately, one look into [the
docs](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#Binomial-test)
and we see that we cannot use `Htests.BinomialTest` for that since, e.g. it
requires a different input. But do not despair that's the job for
[Htests.ChisqTest](https://juliastats.org/HypothesisTests.jl/stable/parametric/#Pearson-chi-squared-test). First
we need to change our data slightly, because the test requires a matrix (aka
array from @sec:julia_arrays) with the following proportions in columns:
$\frac{a_1}{b_1}$ and $\frac{a_2}{b_2}$ (`b` instead of `n`, where `n` = `a` +
`b`). Let's adjust our data for that.

```jl
s = """
# here all elements must be of the same (numeric) type
mEyeColor = Matrix{Int}(dfEyeColor[:, 2:3])
mEyeColor[2, :] = mEyeColor[2, :] .- mEyeColor[1, :]
mEyeColor
"""
sco(s)
```

OK, we got the necessary data structure. The only new part here was
`Matrix{Int}()` closed over `dfEyeColor[:, 2:3]` where we took the needed part
of the data frame and converted it to a matrix (aka array) of integers. And now
for the $\chi^2$ (chi squared) test.

```jl
s = """
Htests.ChisqTest(mEyeColor)
"""
replace(sco(s), Regex("interval:") => "interval:\n\t")
```

OK, first of all we can see right away that the p-value is below the customary
cutoff level of 0.05 or even 0.01. This means that the samples do not come from
the same population (we reject $H_{0}$). More likely they came from the
populations with different underlying proportion of blue eyed people. This could
indicate for instance, that the population of the US stemmed from the UK (at
least partially) but it has a greater admixture of other cultures, which could
potentially influence the distribution of blue eyed people. Still, this is just
an exemplary explanation, I'm not an anthropologist, so this putative
explanation may be incorrect.

Anyway, I'm pretty sure You got the part with p-value on your own, but what are
some of the other outputs. Point estimates are the observed probabilities in
each of the cells from `mEyeColor`. Observe

```jl
s = """
# total number of observations
nObsEyeColor = sum(mEyeColor)

chi2pointEstimates = [mEyeColor...] ./ nObsEyeColor
round.(chi2pointEstimates, digits=6)
"""
sco(s)
```

The `[mEyeColor...]` flattens the 2x2 matrix (2 rows, 2 columns) to a vector
(column 2 is appended to the end of column 1). The `./ nObsEyeColor` divides the
observations in each cell by the total number of observations.

`95% confidence interval` is a 95% confidence interval (who would have guessed)
similar to the one explained in @sec:compare_contin_data_hypo_tests_package for
`Htests.OneSampleTTest` but for each of the point estimates in
`chi2pointEstimates`. Some simplify it and say that within those limits the true
probability for this group of observations most likely lies.

As for the `value under h_0` those are the probabilities of the observations
being in a given cell of `mEyeColor`. But how to get that probabilities. Well,
in a similar way to the method we met in
@sec:statistics_intro_probability_properties. Back then we answered the
following question: If parents got blood groups AB and O then what is the
probability that a child will produce a gamete with allele `A`? The answer:
proportion of children with allele `A` and then the proportion of their gametes
with allele `A` (see @sec:statistics_intro_probability_properties for
details). We calculated it using the following formula

$P(A\ in\ CG) = P(A\ in\ C) * P(A\ in\ gametes\ of\ C\ with\ A)$

Getting back to our `mEyeColor` the expected probability of an observation
falling into a given cell is the probability of an observation falling into a
given column times the probability of an observation falling into a given
row. Observe

```jl
s = """
# cProbs - probability of a value to be found in a given column
cProbs = [sum(c) for c in eachcol(mEyeColor)] ./ nObsEyeColor
# rProbs - probability of a value to be found in a given row
rProbs = [sum(r) for r in eachrow(mEyeColor)] ./ nObsEyeColor

# probability of a value to be found in a given cell of mEyeColor
# under H_0 (the samples are from the same population)
chi2ValsUnderH0 = [cp*rp for cp in cProbs for rp in rProbs]
round.(chi2ValsUnderH0, digits=6)
"""
sco(s)
```

Here, `[cp*rp for cp in cProbs for rp in rProbs]` is an example of a [nested for
loops](https://en.wikibooks.org/wiki/Introducing_Julia/Controlling_the_flow#Nested_loops)
enclosed in a comprehension (see @sec:julia_language_comprehensions). Notice
that in the case of this comprehension there is no comma before the second `for`
(the comma is present in the long, non-comprehension version of nested for loops
in the link above).

Anyway, note that since the calculations from
@sec:statistics_intro_probability_properties assumed the probability
independence, then the same assumption is made here. That means, e.g. that a
given person cannot be classified at the same time as the citizen of the US and
UK (you should think carefully about the inclusion criteria for the categories).
Moreover, the eye color also needs to be clear cut.

To be continued...
