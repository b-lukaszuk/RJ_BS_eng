# Comparisons - categorical data {#sec:compare_categ_data}

OK, once we have comparisons of continuous data under our belts we can move to
groups of categorical data.

## Chapter imports {#sec:compare_categ_data_imports}

Later in this chapter we are going to use the following libraries

```jl
s = """
import CairoMakie as Cmk
import DataFrames as Dfs
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
dfEyeColor = Dfs.DataFrame(
	Dict(
		"eyeCol" => ["blue", "any"],
		"us" => [161, 481],
		"uk" => [220, 499]
	)
)
Options(dfEyeColor, caption="Eye color distribution in two samples.", label="dfEyeColor")
"""
replace(sco(s), Regex("Options.*") => "")
```

Here, we would like to compare if the two proportions ($\frac{a_1}{n_1} =
\frac{161}{481}$ and $\frac{a_2}{n_2} = \frac{220}{499}$) are roughly equal
($H_0$: they come from the same population with some fraction of
blue eyed people). Unfortunately, one look into [the
docs](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#Binomial-test)
and we see that we cannot use `Htests.BinomialTest` for that since, e.g. it
requires a different input. But do not despair that's the job for
[Htests.ChisqTest](https://juliastats.org/HypothesisTests.jl/stable/parametric/#Pearson-chi-squared-test)
(see also [this Wikipedia's
entry](https://en.wikipedia.org/wiki/Chi-squared_test)).
First we need to change our data slightly, because the test requires a matrix
(aka array from @sec:julia_arrays) with the following proportions in columns:
$\frac{a_1}{b_1}$ and $\frac{a_2}{b_2}$ (`b` instead of `n`, where `n` = `a` +
`b`). Let's adjust our data for that.

```jl
s = """
# all the elements must be of the same (numeric) type
mEyeColor = Matrix{Int}(dfEyeColor[:, 2:3])
mEyeColor[2, :] = mEyeColor[2, :] .- mEyeColor[1, :]
mEyeColor
"""
sco(s)
```

OK, we got the necessary data structure. The only new part here was
`Matrix{Int}()` closed over `dfEyeColor[:, 2:3]`. All it does it is takes the
needed part of the data frame and converts it to a matrix (aka array) of
integers. And now for the $\chi^2$ (chi squared) test.

```jl
s = """
Htests.ChisqTest(mEyeColor)
"""
replace(sco(s), Regex("interval:") => "interval:\n\t")
```

OK, first of all we can see right away that the p-value is below the customary
cutoff level of 0.05 or even 0.01. This means that the samples do not come from
the same population (we reject $H_{0}$). More likely they came from the
populations with different underlying proportions of blue eyed people. This
could indicate for instance, that the population of the US stemmed from the UK
(at least partially) but it has a greater admixture of other cultures, which
could potentially influence the distribution of blue eyed people. Still, this is
just an exemplary explanation, I'm not an anthropologist, so it may be
incorrect.

Anyway, I'm pretty sure You got the part with the p-value on your own, but what
are some of the other outputs. Point estimates are the observed probabilities in
each of the cells from `mEyeColor`. Observe

```jl
s = """
# total number of observations
nObsEyeColor = sum(mEyeColor)

chi2pointEstimates = [mEyeColor...] ./ nObsEyeColor
round.(chi2pointEstimates, digits = 6)
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
falling into a given cell of the matrix is the probability of an observation
falling into a given column times the probability of an observation falling into
a given row. Observe

```jl
s = """
# cProbs - probability of a value to be found in a given column
cProbs = [sum(c) for c in eachcol(mEyeColor)] ./ nObsEyeColor
# rProbs - probability of a value to be found in a given row
rProbs = [sum(r) for r in eachrow(mEyeColor)] ./ nObsEyeColor

# probability of a value to be found in a given cell of mEyeColor
# under H_0 (the samples are from the same population)
probsUnderH0 = [cp * rp for cp in cProbs for rp in rProbs]
round.(probsUnderH0, digits = 6)
"""
sco(s)
```

Here, `[cp * rp for cp in cProbs for rp in rProbs]` is an example of a [nested
for
loops](https://en.wikibooks.org/wiki/Introducing_Julia/Controlling_the_flow#Nested_loops)
enclosed in a comprehension (see @sec:julia_language_comprehensions). Notice
that in the case of this comprehension there is no comma before the second `for`
(the comma is present in the long, non-comprehension version of nested for loops
in the link above).

Anyway, note that since the calculations from
@sec:statistics_intro_probability_properties assumed the probability
independence, then the same assumption is made here. That means that, e.g. a
given person cannot be classified at the same time as the citizen of the US and
UK since we would have openly violated the assumption (some countries allow
double citizenship, so you should think carefully about the inclusion criteria
for the categories). Moreover, the eye color also needs to be clear cut.

Out of the remaining output we are mostly interested in the `statistic`, namely
$\chi^2$ (chi square) statistic. Under the null hypothesis ($H_{0}$, both groups
come from the same population with a given fraction of blue eyed individuals)
the probability distribution for counts to occur is called $\chi^2$ (chi
squared) distribution. Next, we calculate $\chi^2$ (chi squared) statistic for
the observed result (from `mEyeColor`). Then, we obtain the probability of a
statistic greater than that to occur by chance. This is similar to the
F-Statistic (@sec:compare_contin_data_one_way_anova) and L-Statistic
(@sec:compare_contin_data_ex2_solution) we met before. Let's see this in
practice

```jl
s = """
observedCounts = [mEyeColor...]
expectedCounts = probsUnderH0 .* nObsEyeColor
# the statisticians love squaring numbers, don't they
chi2Diffs = ((observedCounts .- expectedCounts) .^2) ./ expectedCounts
chi2Statistic = sum(chi2Diffs)

(
	observedCounts,
	round.(expectedCounts, digits = 4),
	round.(chi2Diffs, digits = 4),
	round(chi2Statistic, digits = 4)
)
"""
replace(sco(s), Regex("], ") => "],\n")
```

The code is rather self explanatory. BTW. You might have noticed that: a)
statisticians love squaring numbers, and b) there are some similarities to the
calculations of expected values from @sec:statistics_prob_distribution. Anyway,
now, we can use the $\chi^2$ statistic to get the p-value, like so

```jl
s = """
function getDf(matrix::Matrix{Int})::Int
	nRows, nCols = size(matrix)
	return (nRows - 1) * (nCols - 1)
end

# p-value
# alternative: Dsts.ccdf(Dsts.Chisq(getDf(mEyeColor)), chi2Statistic)
1 - Dsts.cdf(Dsts.Chisq(getDf(mEyeColor)), chi2Statistic) |>
	x -> round(x, digits = 4)
"""
sco(s)
```

So, the pattern is quite similar to what we did in the case of
F-Distribution/Statistic in @sec:compare_contin_data_ex2. First we created the
distribution of interest with the appropriate number of the degrees of freedom
(why only the degrees of freedom matter see the conclusion of
@sec:compare_contin_data_ex2_solution). Then we calculated the probability of a
$\chi^2$ Statistic being greater than the observed one by chance alone and
that's it.

## Fisher's exact test {#sec:compare_categ_data_fisher_exact_text}

This was all nice, but there is a small problem with the $\chi^2$ test, namely
it relies on some approximations and works well only for large sample sizes. How
large, well, I've heard about the rule of fives (that's what I called it). The
rule states that there should be >= 50 (not quite 5) observations per matrix and
>= 5 expected observations per cell (applies to every cell). In case this
assumption does not hold, one should use, e.g. [Fisher's exact
test](https://en.wikipedia.org/wiki/Fisher%27s_exact_test) (Fisher, yes, I think
I heard that name before).

So let's assume for a moment that we were able to collect only a smaller sample,
like the one in the matrix below

```jl
s = """
mEyeColorSmall = round.(Int, mEyeColor ./ 20)
mEyeColorSmall
"""
sco(s)
```

Here, we reduced the number of observations 20 times compared to the original
`mEyeColor` matrix from the previous section. Since the test we are going to
apply
([Htests.FisherExactTest](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#Fisher-exact-test))
requires integers then instead of rounding a number to 0 digits (`round(12.3,
digits = 0)` would returned `Float64`, i.e. 12.0) we asked the round function to
deliver us the closest integers (e.g. 12).

OK, let's, run the said `Htests.FisherExactTest`. Right away we see a
problem, the test requires separate integers as input:
`Htests.FisherExactTest(a::Integer, b::Integer, c::Integer, d::Integer)`. Still,
we can obtain the necessary results very simply, by

```jl
s = """
# assignment goes column by column (left to right), value by value
a, c, b, d = mEyeColorSmall

Htests.FisherExactTest(a, b, c, d)
"""
sco(s)
```

We are not going to discuss the output in detail. Still, we can see that here
due to the small sample size we don't have enough evidence to reject the $H_{0}$
(p > 0.05) on favor of $H_{A}$ (the same underlying populations, the same
proportions, different conclusion due to the to small sample size).

> **_Note:_** Just like `Real` type from @sec:julia_language_functions also
> `Integer` is a composed type, it encompasses, e.g. `Int` and `BigInt` we met
> in @sec:julia_language_exercise5_solution.

## Bigger table {#sec:compare_categ_data_bigger_table}

We started @sec:compare_categ_data_chisq_test with a fictitious eye color
distribution [`blue` and `other`, rows (top-down) in the matrix below] in the US
and UK [columns (left-right) in the matrix below].

```jl
s = """
mEyeColor
"""
sco(s)
```

But in reality there are more eye colors than just blue and other. For instance
let's say that in humans we got three types of eye color: blue, green, and
brown. Let's adjust our table for that:

```jl
s = """
# 3 x 2 table (DataFrame)
dfEyeColorFull = Dfs.DataFrame(
	Dict(
		# "other" from dfEyeColor is split into "green" and "brown"
		"eyeCol" => ["blue", "green", "brown"],
		"us" => [161, 78, 242],
		"uk" => [220, 149, 130]
	)
)

mEyeColorFull = Matrix{Int}(dfEyeColorFull[:, 2:3])
mEyeColorFull
"""
sco(s)
```

Can we say that the two populations differ (with respect to the eye color
distribution) given the data in this table? Well, we can, that's the job for ...

chi squared ($\chi^2$) test.

Wait, but I thought it is used to compare two proportions found in some
samples. Granted, it could be used for that, but in broader sense it is a
non-parametric test that determines the probability that the difference between
the observed and expected frequencies (counts) occurred by chance alone. Here,
non-parametric means it does not assume a specific underlying distribution of
data (like the normal or binomial distribution we met before). As we learned in
@sec:compare_categ_data_chisq_test the expected distribution of frequencies
(counts) is assessed based on the data itself.

Let's give it a try with our new data set (`mEyeColorFull`) and compare it with
the previously obtained results (for `mEyeColor` from
@sec:compare_categ_data_chisq_test).

```jl
s = """
chi2testEyeColor = Htests.ChisqTest(mEyeColor)
chi2testEyeColorFull = Htests.ChisqTest(mEyeColorFull)

(
	# chi^2 statistics
	round(chi2testEyeColorFull.stat, digits = 2),
	round(chi2testEyeColor.stat, digits = 2),

	# p-values
	round(chi2testEyeColorFull |> Htests.pvalue, digits = 7),
	round(chi2testEyeColor |> Htests.pvalue, digits = 7)
)
"""
replace(sco(s), "62, " => "62,\n")
```

That's odd. All we did was to split the `other` category from `dfEyeColor` (and
therefore `mEyeColor`) into `green` and `brown` to create `dfEyeColorFull` (and
therefore `mEyeColorFull`) and yet we got a different $\chi^2$ statistic, and
diffrent p-values. How come?

Well, because we are comparing different things (and different populations).

Imagine that in the case of `dfEyeColor` (and `mEyeColor`) we actually compare
not the eye color, but currency of both countries.  So, we change the labels in
our table. Instead of `blue` we got `heads` and instead of `other` we got
`tails` and instead of `us` we got
[eagle](https://en.wikipedia.org/wiki/Eagle_(United_States_coin)) and instead of
`uk` we got [one pound](https://en.wikipedia.org/wiki/One_pound_(British_coin)).
We want to test if the proportion of heads/tails is roughly the same for both
the coins.

Imagine that in the case of `dfEyeColorFull` (and `mEyeColorFull`) we actually
compare not the eye color, but [three sided
dice](https://www.google.com/search?sca_esv=571684704&q=three+sided+dice&tbm=isch&source=lnms&sa=X&ved=2ahUKEwj1k-bB-uWBAxUa3AIHHWDvDoIQ0pQJegQIDBAB&biw=1437&bih=696&dpr=1.33)
produced in those countries.  So, we change the labels in our table. Instead of
`blue` we got `1` and instead of `green` we got `2`, instead of `brown` we got
`3` (`1`, `2`, `3` is a convention, equally well one could write on the sides of
a dice, e.g. `Tom`, `Alice`, and `John`). We want to test if the distribution of
`1`s, `2`s, and `3`s is roughly the same for both types of dice.

Now, it so happened that the number of dice throws was the same that the number
of coin tosses from the example above. It also happened that the number of `1`s
was the same as the number of `head`s from the previous example. Still, we are
comparing different things (coins and dices) and so we would not expect to get
the same results from our chi squared ($\chi^2$) test. And that is how it is,
the test is label blind. All it cares is the difference between the
observed and expected frequencies (counts).

Anyway, the value of $\chi^2$ statistic for `mEyeColorFull` is
 `jl round(chi2testEyeColorFull.stat, digits = 2)`
and the probability that such a value occurred by chance approximates 0.
Therefore, it is below our customary cutoff level of 0.05, and we may conclude
that the populations differ with respect to the distribution of eye color (as we
did in @sec:compare_categ_data_bigger_table).

The test may be label blind, but we are not. It is possible that sooner
or later you will come across a data set where splitting groups into different
categories will lead you to different conclusions, e.g. p-value from $\chi^2$
test for `mEyeColorPlSp` for Poland and Spain would be 0.054, and for
`mEyeColorPlSpFull` it would be 0.042 (so it is and it isn't statistically
different at the same time). What should you do then?

Well, it happens. There is not much to be done here. We need to live with
that. It is like the accused and judge analogy from
@sec:statistics_intro_errors. In reality the accused is guilty or not.  We don't
know the truth, the best we can do is to examine the evidence. After that one
judge may incline to declare the accused guilty the other will give him the
benefit of doubt. There is no certainty or a great solution here. In such a case
some people suggest to present both the results with the author's conclusions
and let the readers decide for themselves. Others suggest to collect a greater
sample to make sure which conclusion is right. Still, others suggest that you
should plan your experiment (its goals and the ways to achieve them) carefully
beforehand. Once you got your data you stick to the plan even if the result is
disappointing to you. So, if we decide to compare `blue` vs `other` and did not
establish the statistical significance we stop there, we do not go fishing for
statistical significance by splitting `other` to `green` and `brown`.

## Test for independence {#sec:compare_categ_test_for_independence}

Another way to look at the chi squared ($\chi^2$) test is that this is a test
that allows to check the independence of the distribution of the data between
the rows and columns (see the assumption we made when calculating the expected
counts with `probsUnderH0` in @sec:compare_categ_data_chisq_test). Let's make
this more concrete with the following example.

Previously we concerned ourselves with the `mEyeColorFull` table.

```jl
s = """
mEyeColorFull
"""
sco(s)
```

The rows contain (top to bottom) eye colors: `blue`, `green`, and `brown`. The
columns (left to right) are for `us` and `uk`.

Interestingly enough, the eye color depends on the concentration of
[melanin](https://en.wikipedia.org/wiki/Melanin), a pigment that is also present
in skin and hair and protects us from the harmful UV radiation. So imagine that
the columns contain the data for some skin condition (left column: `diseaseX`,
right column: `noDiseaseX`). Now, we are interested to know, if people with a
certain eye color are more exposed (more vulnerable) to the disease (if so then
some preventive measures, e.g. a stronger sun screen, could be applied by them).

Since we only changed the column labels then we already know the answer (see
the reminder from @sec:compare_categ_data_bigger_table below)

```jl
s = """
(
	round(chi2testEyeColorFull.stat, digits = 2),
	round(chi2testEyeColorFull |> Htests.pvalue, digits = 7)
)
"""
sco(s)
```

OK, so based on the (fictitious) data there is enough evidence to consider that
the occurrence of `diseaseX` isn't independent from eye color (p < 0.05). In
other words, people of some eye color get the `diseaseX` more often than people
with some other eye color. But which eye color carries the greater risk? Pause
for a moment and think how to answer the question.

Well, one thing we could do is to collapse some rows (if it makes sense), for
instance we could collapse `green` and `brown` into `other` category (we would
end up with two eye colors: `blue` and `other`). So in practice we would answer
the same question that we did in @sec:compare_categ_data_chisq_test for
`mEyeColor` (of course here we changed column labels to `diseaseX` and
`noDiseaseX`).

```jl
s = """
rowPerc = [r[1] / sum(r) * 100 for r in eachrow(mEyeColor)]
rowPerc = round.(rowPerc, digits = 2)

(
	round(chi2testEyeColor.stat, digits = 2),
	round(chi2testEyeColor |> Htests.pvalue, digits = 7),
	rowPerc
)
"""
sco(s)
```

We see that roughly `jl rowPerc[1]`% of `blue` eyed people got `diseaseX`
compared to roughly `jl rowPerc[2]`% of people with `other` eye color and that
the difference is statistically significant (p < 0.05). So people with `other`
eye color should be more careful with exposure to sun (of course, these are just
made up data).

Another option is to use a method analogous to the one we applied in
@sec:compare_contin_data_one_way_anova and
@sec:compare_contin_data_post_hoc_tests. Back then we compared three groups of
continuous variables with one-way ANOVA [it controls for the overall $\alpha$
(type 1 error)]. Then we used a post-hoc tests (Student's t-tests) to figure out
which group(s) differ(s) from the other(s). Naturally, we could/should adjust
the obtained p-values by using a multiplicity correction (as we did in
@sec:compare_contin_data_multip_correction). This is exactly what we are going
to do in one of the upcoming exercises. For now take some rest and click the
right arrow when you're ready.

## Exercises - Comparisons of Categorical Data {#sec:compare_categ_data_exercises}

Just like in the previous chapters here you will find some exercises that you
may want to solve to get from this chapter as much as you can (best
option). Alternatively, you may read the task descriptions and the solutions
(and try to understand them).

### Exercise 1 {#sec:compare_categ_data_ex1}

In @sec:compare_categ_data_chisq_test and @sec:compare_categ_data_bigger_table
we dealt with `dfEyeColor` and `dfEyeColorFull`, i.e. the data sets that were
already in the form of a contingency table. Usually, this is not the case.

Imagine that you are a researcher and you want to find out if certain
professions are associated with a greater risk of smoking cigarettes (perhaps as
a way to alleviate the stress). So you prepare a questionnaire. People answer
two questions: "Q1. What is your profession?" and "Q2. Do you smoke?". The
answers to Q1 are placed in one column of a spreadsheet, the answers to
Q2 are placed into the second column. An exemplary data could look this way:

```jl
s = """
Rand.seed!(321)
smoker = Rand.rand(["no", "yes"], 100)
profession = Rand.rand(["Lawyer", "Priest", "Teacher"], 100)
"""
sc(s)
```

Write a function with the following signature

<pre>
function getContingencyTable(
    rowVect::Vector{String},
    colVect::Vector{String},
    )::Matrix{Int}
</pre>

The function should take two arguments (observations as vectors of strings) and
return a contingency table (`Matrix{Int}`) with the counts (similar to
`mEyeColor` or `mEyeColorFull`). You may modify the function slightly, e.g to
return `Dfs.DataFrame` similar to the one produced by
[FreqTables.freqtable](https://github.com/nalimilan/FreqTables.jl) (it doesn't
have to be exact).

Test your function with the data presented above. Make sure it works properly
also for smaller data sets, i.e. for

```jl
s = """
Rand.seed!(321)
smokerSmall = Rand.rand(["no", "yes"], 10)
professionSmall = Rand.rand(["Lawyer", "Priest", "Teacher"], 10)
"""
sc(s)
```

the contingency table should contain zeros in some cells.

Below you may find a list of functions that I found useful (you may check them
in [the docs](https://docs.julialang.org/en/v1/)). Of course you don't have to
use any of them. The functions are sorted alphabetically.

- `Dfs.insertcols!` ([DataFrames docs](https://dataframes.juliadata.org/stable/))
- `collect`
- `getCounts` (from @sec:statistics_prob_theor_practice)
- `sort`
- `unique`
- `zip`

### Exercise 2 {#sec:compare_categ_data_ex2}

In @sec:compare_categ_data_chisq_test we concluded that the populations of the
`us` and `uk` differ with respect to eye color distribution (we used data from
`mEyeColor`).

Still, it's often nice to know not just the numbers themselves, but the
proportions (or percentage distribution of the data in a table).

So, here is a task for you. Write the following functions

<pre>
function getColPerc(m::Matrix{Int})::Matrix{Float64}

# and

function getRowPerc(m::Matrix{Int})::Matrix{Float64}
</pre>

that should work similarly to
[FreqTables.prop](https://github.com/nalimilan/FreqTables.jl) (`prop(tbl2,
margins=2)`, and `prop(tbl2, margins=1)`), i.e they should return the column and
row percentage of observations, respectively.

To reduce code duplication you may
want to combine them into a single function, e.g. `getPerc(m::Matrix{Int},
byRow::Bool)::Matrix{Float64}` that returns row percentages when `byRow` is
true, and column percentages otherwise. You my also want to round the numbers
(percents) to e.g. 2 decimal points.

In my solution I used [nested for
loops](https://en.wikibooks.org/wiki/Introducing_Julia/Controlling_the_flow#Nested_loops),
but feel free to write it whatever way you like (as long as it works fine).

### Exercise 3 {#sec:compare_categ_data_ex3}

The functions we developed previously (see @sec:compare_categ_data_ex2_solution)
are nice and useful. Still, we might want to have a visual aid to help us with
the interpretation of our data.

So here is another task for you. Using
[CairoMakie](https://docs.makie.org/stable/explanations/backends/cairomakie/index.html)
or your favorite plotting library write a function that accepts a data frame
like `dfEyeColorFull` and draws a stacked bar plot depicting column percentages
(search CairoMakie documentation for `barplot`).

You may use the functions we developed before.

If you want you can make your function also draw row percentages (optional).

## Solutions - Comparisons of Categorical Data  {#sec:compare_categ_data_exercises_solutions}

In this sub-chapter you will find exemplary solutions to the exercises from the
previous section.

### Solution to Exercise 1 {#sec:compare_categ_data_ex1_solution}

An exemplary `getContingencyTable` could look like this (here, a version that
produces output that resembles the result of `FreqTables.freqtable`):

```jl
s = """
function getContingencyTable(
    rowVect::Vector{String},
    colVect::Vector{String},
    rowLabel::String,
    colLabel::String,
    )::Dfs.DataFrame

    rowNames::Vector{String} = sort(unique(rowVect))
    colNames::Vector{String} = sort(unique(colVect))
    pairs::Vector{Tuple{String, String}} = collect(zip(rowVect, colVect))
    pairsCounts::Dict{Tuple{String, String}, Int} = getCounts(pairs)
	labels::String = "↓" * rowLabel * "/" * colLabel * "→"
    df::Dfs.DataFrame = Dfs.DataFrame()
    columns::Dict{String, Vector{Int}} = Dict()

    for cn in colNames
        columns[cn] = [get(pairsCounts, (rn, cn), 0) for rn in rowNames]
    end

    df = Dfs.DataFrame(columns)
    Dfs.insertcols!(df, 1, labels => rowNames)

    return df
end
"""
sc(s)
```

Here, as we often do, we start by declaring some of the helpful variables.
`rowNames` and `colNames` contain all the possible unique groups for each input
variable (`rowVect` and `colVect`). Then we get all the consecutive pairings
that are in the data by using `zip` and `collect` functions. For instance
`collect(zip(["a", "a", "b"], ["x", "y", "x"]))` will yield us the following
vector of tuples: `[("a", "x"), ("a", "y"), ("b", "x")]`. The pairs are then
sent to `getCounts` (from @sec:statistics_prob_theor_practice) to find out how
often a given pair occurs.

In the next step we define a variable `df` (for now it is empty) to hold our
final result. We saw in @sec:compare_categ_data_chisq_test that a data frame can
be created by sending dictionary to the `Dfs.DataFrame` function. Therefore, we
declare `columns` that will hold the count for every column of our contingency
table.

We fill the columns one by one with `for cn in colNames` loop. To get a count
for a particular row of a given column (`(rn, cn)`) we use `get` function that
extracts it from `pairsCounts`. If the key is not there (a given combination of
`(rn, cn)` does not exist) we return `0` as a default value. We fill columns by
using comprehensions (see @sec:julia_language_comprehensions).

Finally, we put our counts (`columns`) into the data frame (`df`). Now, we
insert a column with `rowNames` at position `1` (first column from left) with
`Dfs.insertcols!`.

All that it is left to do is to return the result.

Let's find out how our `getContingencyTable` works.

```jl
s = """
smokersByProfession = getContingencyTable(
	smoker,
	profession,
	"smoker",
	"profession"
)
Options(smokersByProfession, caption="Number of smokers by profession.", label="smokersByProfession")
"""
replace(sco(s), Regex("Options.*") => "")
```

It appears to work just fine. Let's swap the inputs and see if we get a
consistent result.

```jl
s = """
smokersByProfessionTransposed = getContingencyTable(
	profession,
	smoker,
	"profession",
	"smoker"
)
Options(smokersByProfessionTransposed, caption="Number of smokers by profession transposed.", label="smokersByProfessionTransposed")
"""
replace(sco(s), Regex("Options.*") => "")
```

Looks good. And now for the small data set with possible zeros.


```jl
s = """
smokersByProfessionSmall = getContingencyTable(
	smokerSmall,
	professionSmall,
	"smoker",
	"profession"
)
Options(smokersByProfessionSmall, caption="Number of smokers by profession (small data set).", label="smokersByProfessionSmall")
"""
replace(sco(s), Regex("Options.*") => "")
```

Seems to be OK as well. Of course we can use this function with a data frame,
e.g. `getContingencyTable(df[!, "col1"], df[!, "col2"], "col1", "col2")` or
adopt it slightly to take a data frame as an input.

### Solution to Exercise 2 {#sec:compare_categ_data_ex2_solution}

OK, the the most direct solution to the problem (for `getColPerc`) would be
something like

```jl
s = """
function getColPerc(m::Matrix{Int})::Matrix{Float64}
    nRows, nCols = size(m)
    percentages:: Matrix{Float64} = zeros(nRows, nCols)
    for c in 1:nCols
        for r in 1:nRows
            percentages[r, c] = m[r, c] / sum(m[:, c])
            percentages[r, c] = round(percentages[r, c] * 100, digits = 2)
        end
    end
    return percentages
end
"""
sc(s)
```

Here, we begin by extracting the number of rows (`nRows`) and columns
(`nCols`). We use them right away by defining `percentages` matrix that will hold our
final result (for now it is filled with 0s). Then we use the classical [nested
for
loops](https://en.wikibooks.org/wiki/Introducing_Julia/Controlling_the_flow#Nested_loops)
idiom to calculate the percentage for every cell in the matrix/table (we use
array indexing we met in @sec:julia_arrays). For that we divide each count
(`m[r, c]`) by column sum (`sum(m[:, c])`). Next, we multiply it by 100 (`*
100`) to change the decimals to percentages. We round the percentage to two
decimal points (`round` and `digits = 2`).

The algorithm is not the most efficient (we calculate `sum(m[:, c])` separately
for every cell) nor terse (9 lines of code). Still, it is pretty clear and for
small matrices (a few rows/cols) does the trick. A shorter, but more cryptic
version of the function would look something like this

<pre>
function getColPerc2(m::Matrix{Int})::Matrix{Float64}
    colSums::Vector{Int} = [sum(c) for c in eachcol(m)]
    return round.(m ./ transpose(colSums) .* 100, digits = 2)
end
</pre>

but I feared it would have been too vague. OK, let's move to the `getRowPerc`
function

```jl
s = """
function getRowPerc(m::Matrix{Int})::Matrix{Float64}
    nRows, nCols = size(m)
    percentages:: Matrix{Float64} = zeros(nRows, nCols)
    for c in 1:nCols
        for r in 1:nRows
            percentages[r, c] = m[r, c] / sum(m[r, :])
            percentages[r, c] = round(percentages[r, c] * 100, digits = 2)
        end
    end
    return percentages
end
"""
sc(s)
```

Hmm, it's almost identical to `getColPerc` (`sum(m[:, c])` was replaced with
`sum(m[r, :])`). Let's remove the code duplication and put it into a single
function.

```jl
s = """
function getPerc(m::Matrix{Int}, byRow::Bool)::Matrix{Float64}
    nRows, nCols = size(m)
    percentages:: Matrix{Float64} = zeros(nRows, nCols)
	dimSum::Int = 0 # sum in a given dimension of a matrix
    for c in 1:nCols
        for r in 1:nRows
			dimSum = (byRow ? sum(m[r, :]) : sum(m[:, c]))
            percentages[r, c] = m[r, c] / dimSum
            percentages[r, c] = round(percentages[r, c] * 100, digits = 2)
        end
    end
    return percentages
end
"""
sc(s)
```

Here, we replaced the function specific sums with a more general `dimSum`
(initialized with 0). Then inside the inner for loop we decide which sum to
compute (row sum with `sum(m[r, :])` and column sum with `sum(m[:, c])`) with a
ternary expression from @sec:ternary_expression. OK, enough of tweaking and code
optimization, let's test our new function.

```jl
s = """
mEyeColor
"""
sco(s)
```

And now column percentages

```jl
s = """
eyeColorColPerc = getPerc(mEyeColor, false)
eyeColorColPerc
"""
sco(s)
```

So, based on the data in `mEyeColor` we see that in the `uk` (first column)
there is roughly `jl eyeColorColPerc[1, 1]`% of people
with blue eyes. Whereas in the `us` (second column) there is roughly
 `jl eyeColorColPerc[1, 2]`% of people with that eye color.

And now for the row percentages.

```jl
s = """
eyeColorRowPerc = getPerc(mEyeColor, true)
eyeColorRowPerc
"""
sco(s)
```

So, based on the data in `mEyeColor` we see that among the investigated groups
roughly `jl eyeColorRowPerc[1, 1]`% of blue eyed people live in the `uk` and
 `jl eyeColorRowPerc[1, 2]`% of blue eyed people live in the `us`.

OK, let's just quickly make sure our function also works fine for a bigger
table.

```jl
s = """
mEyeColorFull
"""
sco(s)
```

And now column percentages.

```jl
s = """
eyeColorColPercFull = getPerc(mEyeColorFull, false)
eyeColorColPercFull
"""
sco(s)
```

So, based on the data in `mEyeColor` we see that in the `uk` (first column)
there is roughly:

- `jl eyeColorColPercFull[1, 1]`% of people with blue eyes,
- `jl eyeColorColPercFull[2, 1]`% of people with green eyes, and
- `jl eyeColorColPercFull[3, 1]`% of people with brown eyes.

For `us` (second column) we got:

- `jl eyeColorColPercFull[1, 2]`% of people with blue eyes,
- `jl eyeColorColPercFull[2, 2]`% of people with green eyes, and
- `jl eyeColorColPercFull[3, 2]`% of people with brown eyes.

Of course, remember that this is all fictitious data inspired by the lecture of
[this Wikipedia's page](https://en.wikipedia.org/wiki/Eye_color).

OK, enough for the task solution. If you want to see more terse (and
mysterious) versions of the functions developed here then go to [this chapter's
code
snippets](https://github.com/b-lukaszuk/RJ_BS_eng/tree/main/code_snippets/ch06).

### Solution to Exercise 3 {#sec:compare_categ_data_ex3_solution}

OK, so an exemplary function drawing column percentages from a contingency table
could look like this.

```jl
s = """
function drawColPerc(df::Dfs.DataFrame,
    xlabel::String, ylabel::String, title::String,
    colors::Vector{String})::Cmk.Figure

    m::Matrix{Int} = Matrix{Int}(df[:, 2:end])
    columnPerc::Matrix{Float64} = getPerc(m, false)
    nRows, nCols = size(columnPerc)
    colNames::Vector{String} = names(df)[2:end]
    rowNames::Vector{String} = df[1:end, 1]
    xs::Vector{Int} = collect(1:nCols)
    offsets::Vector{Float64} = zeros(nCols)
    barplots = []

    fig = Cmk.Figure()
    Cmk.Axis(fig[1, 1],
        title=title,
        xlabel=xlabel, ylabel=ylabel,
        xticks=(xs, colNames))

    for r in 1:nRows
        push!(barplots,
            Cmk.barplot!(fig[1, 1], xs, columnPerc[r, :],
                offset=offsets, color=colors[r]))
        offsets = offsets .+ columnPerc[r, :]
    end
    Cmk.Legend(fig[1, 2], barplots, rowNames)

    return fig
end
"""
sc(s)
```

To be continued...
