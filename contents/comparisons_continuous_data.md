# Comparisons - continuous data {#sec:compare_contin_data}

OK, we finished the previous chapter with hypothesis testing and calculating
probabilities for binomial data (`bi` - two `nomen` - name), e.g. number of
successes (wins of Peter in tennis).

In this chapter we are going to explore comparisons between the groups
containing data on a continuous scale (like the height from
@sec:statistics_normal_distribution).

## Chapter imports {#sec:compare_contin_data_imports}

Later in this chapter we are going to use the following libraries

```jl
s5 = """
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import Distributions as Dsts
import HypothesisTests as Htests
import MultipleTesting as Mt
import Pingouin as Pg
import Random as Rand
import Statistics as Stats
"""
sc(s5)
```

> **_Note:_** At the time I'm writing these words (29-08-2023)
> [Pingouin](https://github.com/clementpoiret/Pingouin.jl) package is still
> under development. This may cause some inconveniences, warnings, etc. Proceed
> with caution.

If you want to follow along you should have them installed on your system. A
reminder of how to deal (install and such) with packages can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/). But wait, you may prefer
to use `Project.toml` and `Manifest.toml` files from the [code snippets for this
chapter](https://github.com/b-lukaszuk/RJ_BS_eng/tree/main/code_snippets/ch05)
to install the required packages. The instructions you will find
[here](https://pkgdocs.julialang.org/v1/environments/).

The imports will be placed in the code snippet when first used, but I thought it
is a good idea to put them here, after all imports should be at the top of your
file (so here they are at the top of the chapter). Moreover, that way they will
be easier to find all in one place.

If during the lecture of this chapter you find a piece of code of unknown
functionality, just go to the code snippets mentioned above and run the code
from the `*.jl` file.  Once you have done that you can always extract a small
piece of it and test it separately (modify and experiment with it if you
wish).

## One sample Student's t-test {#sec:compare_contin_data_one_samp_ttest}

Imagine that in your town there is a small local brewery that produces quite
expensive but super tasty beer. You like it a lot, but you got an impression
that the producer is not being honest with their customers and instead of the
declared 500 [mL] of beer per bottle, he pours a bit less. Still, there is
little you can do to prove it. Or can you?

You bought 10 bottles of beer (ouch, that was expensive!) and measured the
volume of fluid in each of them. The results are as follows

```jl
s = """
# a representative sample
beerVolumes = [504, 477, 484, 476, 519, 481, 453, 485, 487, 501]
"""
sc(s)
```

On a graph the volume distribution looks like this (it was drawn with
[Cmk.hist](https://docs.makie.org/stable/examples/plotting_functions/hist/index.html#hist)
function).

![Histogram of beer volume distribution for 10 beer (fictitious data).](./images/histBeerVolume.png){#fig:histBeerVolume}

You look at it and it seems to resemble a bit the bell shaped curve that we
discussed in the @sec:statistics_normal_distribution. This makes sense. Imagine
your task is to pour let's say 1'000 bottles daily with 500 [mL] of beer in each
with a big mug (there is an erasable mark at a bottle's neck). Most likely the
volumes would oscillate around your goal volume of 500 [mL], but they would not
be exact. Sometimes in a hurry you would add a bit more, sometimes a bit less
(you could not waste time to correct it). So it seems like a reasonable
assumption that the 1'000 bottles from our example would have a roughly bell
shaped (aka normal) distribution of volumes around the mean.

Now you can calculate the mean and standard deviation for the data

```jl
s = """
import Statistics as Stats

meanBeerVol = Stats.mean(beerVolumes)
stdBeerVol = Stats.std(beerVolumes)

(meanBeerVol, stdBeerVol)
"""
sco(s)
```

Hmm, on average there was `jl meanBeerVol` [mL] of beer per bottle, but the
spread of the data around the mean is also considerable (sd =
 `jl round(stdBeerVol, digits=2)` [mL]). The lowest value measured was
 `jl minimum(beerVolumes)` [mL], the highest value measured was
 `jl maximum(beerVolumes)` [mL]. Still, it seems that there is less beer per bottle
than expected, but is it enough to draw a conclusion that the real mean in the
population of our 1'000 bottles is ≈ `jl round(meanBeerVol, digits=0)` [mL] and
not 500 [mL] as it should be? Let's try to test that using what we already know
about the normal distribution (see @sec:statistics_normal_distribution), the
three sigma rule (@sec:statistics_intro_three_sigma_rule) and the
`Distributions` package (@sec:statistics_intro_distributions_package).

Let's assume for a moment that the true mean for volume of fluid in the
population of 1'000 beer bottles is `meanBeerVol` = `jl meanBeerVol` [mL] and
the true standard deviation is `stdBeerVol` = `jl round(stdBeerVol, digits=2)`
[mL]. That would be great because now, based on what we've learned in
@sec:statistics_intro_distributions_package we can calculate the probability
that a random bottle of beer got >500 [mL] of fluid (or % of beer bottles in the
population that contain >500 [mL] of fluid). Let's do it

```jl
s = """
import Distributions as Dsts

# how many std. devs is value above or below the mean
function getZScore(value::Real, mean::Real, sd::Real)::Float64
	return (value - mean)/sd
end

expectedBeerVolmL = 500

fractionBeerLessEq500mL = Dsts.cdf(Dsts.Normal(),
	getZScore(expectedBeerVolmL, meanBeerVol, stdBeerVol))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL
"""
sco(s)
```

I'm not going to explain the code above since for reference you can always check
@sec:statistics_intro_distributions_package. Still, under those assumptions
roughly 0.23 or 23% of beer bottles contain more than 500 [mL] of fluid. In
other words under these assumptions the probability that a random beer bottle
contains >500 [mL] of fluid is 0.23 or 23%.

There are 2 problems with that solution.

**Problem 1**

It is true that the mean from the sample is our best estimate of the mean in the
population (here 1'000 beer bottles poured daily). However, statisticians proved
that instead of the standard deviation from our sample we should use the
[standard error of the mean](https://en.wikipedia.org/wiki/Standard_error). It
describes the spread of sample means around the true population mean and it can
be calculated as follows

$sem = \frac{sd}{\sqrt{n}}$, where

sem - standard error of the mean

sd - standard deviation

n - number of observations in the sample

\
Let's enclose it into Julia code

```jl
s = """
function getSem(vect::Vector{<:Real})::Float64
	return Stats.std(vect) / sqrt(length(vect))
end
"""
sc(s)
```

Now we get a better estimate of the probability

```jl
s = """
fractionBeerLessEq500mL = Dsts.cdf(Dsts.Normal(),
	getZScore(expectedBeerVolmL, meanBeerVol, getSem(beerVolumes)))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL
"""
sco(s)
```

Under those assumptions the probability that a beer bottle contains >500 [mL] of
fluid is roughly 0.01 or 1%.

So, to sum up. Here, we assumed that the true mean in the population is our
sample mean ($\mu$ = `meanBeerVol`). Next, if we were to take many small samples
like `beerVolumes` and calculate their means then they would be normally
distributed around the population mean (here $\mu$ = `meanBeerVol`) with
$\sigma$ (standard deviation in the population) =
`getSem(beerVolumes)`. Finally, using the three sigma rule (see
@sec:statistics_intro_three_sigma_rule) we check if our hypothesized mean
(`expectedBeerVolmL`) lies within roughly 2 standard deviations (here
approximately 2 `sem`s) from the assumed population mean (here $\mu$ =
`meanBeerVol`).

**Problem 2**

The sample size is small (`length(beerVolumes)` = `jl length(beerVolumes)`) so
the underlying distribution is quasi-normal (*quasi* - almost, as it were). It
is called a
[t-distribution](https://en.wikipedia.org/wiki/Student%27s_t-distribution) (for
comparison of an exemplary normal and t-distribution see the figure
below). Therefore to get a better estimate of the probability we should use a
t-distribution.

![Comparison of normal and t-distribution with 4 degrees of freedom (df = 4).](./images/normDistTDist.png){#fig:normDistTDist}

Luckily our `Distributions` package got the t-distribution included (see [the
docs](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.TDist)). As
you remember the normal distribution required two parameters that described it:
the mean and the standard deviation. The t-distribution requires only [the
degrees of
freedom](https://en.wikipedia.org/wiki/Degrees_of_freedom_(statistics)). The
concept is fairly easy to understand. Imagine that we recorded body masses of 3
people in the room: Paul, Peter, and John.

```jl
s = """
peopleBodyMassesKg = [84, 94, 78]

sum(peopleBodyMassesKg)
"""
sco(s)
```

As you can see the sum of those body masses is `jl sum(peopleBodyMassesKg)`
[kg]. Notice, however, that only two of those masses are independent or free to
change. Once we know any two of the body masses (e.g. 94, 78) and the sum:
 `jl sum(peopleBodyMassesKg)`, then the third body mass must be equal to
`sum(peopleBodyMassesKg) - 94 - 78` = `jl sum(peopleBodyMassesKg) - 94 - 78` (it
is determined, it cannot just freely take any value). So in order to calculate
the degrees of freedom we type `length(peopleBodyMassesKg) - 1` =
 `jl length(peopleBodyMassesKg) - 1`. Since our sample size is equal to
`length(beerVolumes)` = `jl length(beerVolumes)` then it will follow a
t-distribution with `length(beerVolumes) - 1` = `jl length(beerVolumes) - 1`
degrees of freedom.

So the probability that a beer bottle contains >500 [mL] of fluid is

```jl
s = """
function getDf(vect::Vector{<:Real})::Int
	return length(vect) - 1
end

fractionBeerLessEq500mL = Dsts.cdf(Dsts.TDist(getDf(beerVolumes)),
	getZScore(expectedBeerVolmL, meanBeerVol, getSem(beerVolumes)))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL
"""
sco(s)
```

> **_Note:_** The z-score (number of standard deviations above or below the
> mean) for a t-distribution is called the t-score or t-statistics (it is
> calculated with sem instead of sd).

Finally, we got the result. Based on our representative sample (`beerVolumes`)
and the assumptions we made we can see that the probability that a random beer
contains >500 [mL] of fluid (500 [mL] is stated on a label) is
`fractionBeerAbove500mL` = 0.022 or 2.2% (remember, this is one-tailed
probability, the two-tailed probability is 0.022 * 2 = 0.044 = 4.4%).

Given that the cutoff level for $\alpha$ (type I error) from
@sec:statistics_intro_errors is 0.05 we can reject our $H_{0}$ (the assumption
that 500 [mL] comes from the population with the mean approximated by $\mu$ =
`meanBeerVol` = `jl meanBeerVol` [mL] and the standard deviation approximated by
$\sigma$ = `sem` = `jl round(getSem(beerVolumes), digits=2)` [mL]).

In conclusion, our hunch was right ("...you got an impression that the producer
is not being honest with their customers..."). The owner of the local brewery is
dishonest and intentionally pours slightly less beer (on average
`expectedBeerVolmL - meanBeerVol` = `jl round(expectedBeerVolmL - meanBeerVol,
digits=0)` [mL]). Now we can go to him and get our money back, or alarm the
proper authorities for that monstrous crime. *Fun fact: the story has it that
the [code of Hammurabi](https://en.wikipedia.org/wiki/Code_of_Hammurabi) (circa
1750 BC) was the first to punish for diluting a beer with water (although it
seems to be more of a legend).* Still, this is like 2-3% beer (≈13/500 = 0.026)
in a bottle less than it should be and the two-tailed probability
(`fractionBeerAbove500mL * 2` = `jl round(fractionBeerAbove500mL * 2,
digits=3)`) is not much less than the cutoff for type 1 error equal to 0.05 (we
may want to collect a bigger sample and change the cutoff to 0.01).

### HypothesisTests package {#sec:compare_contin_data_hypo_tests_package}

The above paragraphs were to further your understanding of the topic. In
practice you can do this much faster using
[HypothesisTests](https://juliastats.org/HypothesisTests.jl/stable/) package.

In our beer example you could go with this short snippet (see [the
docs](https://juliastats.org/HypothesisTests.jl/stable/parametric/#t-test) for
`Htests.OneSampleTTest`)

```jl
s = """
import HypothesisTests as Htests

Htests.OneSampleTTest(beerVolumes, expectedBeerVolmL)
"""
sco(s)
```

Let's compare it with our previous results

```jl
s = """
(
expectedBeerVolmL, # value under h_0
meanBeerVol, # point estimate
fractionBeerAbove500mL * 2, # two-sided p-value
getZScore(expectedBeerVolmL, meanBeerVol, getSem(beerVolumes)),# t-statistic
getDf(beerVolumes), # degrees of freedom
getSem(beerVolumes) # empirical standard error
)
"""
sco(s)
```

The numbers are pretty much the same (and they should be if the previous
explanation was right). The t-statistic is positive in our case because
`getZScore` subtracts `mean` from `value` (`value - mean`) and some packages
(like `HypothesisTests`) swap the numbers.

The value that needs to be additionally explained is the [95% confidence
interval](https://en.wikipedia.org/wiki/Confidence_interval) from the output of
`HypothesisTests` above. All it means is that: if we were to run our experiment
with 10 beers 100 times and calculate 95% confidence intervals 100 times then 95
of the intervals would contain the true mean from the population. Sometimes
people (over?)simplify it and say that this interval [in our case (473.8,
499.6)] contains the true mean from the population with probability of 95% (but
that isn't necessarily the same what was stated in the previous sentence). The
narrower interval means better, more precise estimate. If the difference is
statistically significant (p-value $\le$ 0.05) then the interval should not
contain the postulated mean (as it is in our case).

Notice that the obtained 95% confidence interval (473.8, 499.6) may indicate
that the true average volume of fluid in a bottle of beer could be as high as
499.6 [mL] (so this would hardly make a practical difference) or as low as 473.8
[mL] (a small, ~6%, but a practical difference). In the case of our beer example
it is just a curious fact, but imagine you are testing a new drug lowering the
'bad cholesterol' (LDL-C) level (the one that was mentioned in
@sec:statistics_intro_exercise5_solution). Let's say you got a 95% confidence
interval for the reduction of (-132, +2). The interval encompasses 0, so the
true effect may be 0 and you cannot reject $H_{0}$ under those assumptions
(p-value would be greater than 0.05). However, the interval is broad, and its
lower value is -132, which means that the true reduction level after applying
this drug could be even -132 [mg/dL]. Based on the data from [this
table](https://en.wikipedia.org/wiki/Low-density_lipoprotein#Normal_ranges) I
guess this could have a big therapeutic meaning. So, you might want to consider
performing another experiment on the effects of the drug, but this time you
should take a bigger sample to dispel the doubt (bigger sample size narrows the
95% confidence interval).

In general one sample t-test is used to check if a sample comes from a
population with the postulated mean (in our case in $H_{0}$ the postulated mean
was 500 [mL]). However, I prefer to look at it from the different perspective
(the other end) hence my explanation above. The t-test is named after [William
Sealy Gosset](https://en.wikipedia.org/wiki/William_Sealy_Gosset) that published
his papers under the pen-name Student, hence it is also called a Student's
t-test.

### Checking the assumptions {#sec:compare_contin_data_check_assump}

Hopefully, the explanations above were clear enough. Still, we shouldn't just
jump into performing a test blindly, first we should test its assumptions (see
figure below).

![Checking assumptions of a statistical test before running it.](./images/testAssumptionsCheckCycle.png){#fig:testAssumptionsCheckCycle}

First of all we start by choosing a test to perform. Usually it is a [parametric
test](https://en.wikipedia.org/wiki/Parametric_statistics), i.e. one that
assumes some specific data distribution (e.g. normal). Then we check our
assumptions. If they hold we proceed with our test. Otherwise we can either
transform the data (e.g. take a logarithm from each value) or choose a different
test (the one that got different assumptions or just less of them to
fulfill). We will see an example of a data transformation, and the possible
benefits it can bring us, later in this book (see the upcoming
@sec:assoc_pred_ex1). Anyway, this different test usually belongs to so called
[non-parametric tests](https://en.wikipedia.org/wiki/Nonparametric_statistics),
i.e. tests that make less assumptions about the data, but are likely to be
slightly less powerful (you remember the power of a test from
@sec:statistics_intro_errors, right?).

In our case a Student's t-test requires (among
[others](https://en.wikipedia.org/wiki/Student%27s_t-test#Assumptions)) the data
to be normally distributed. This is usually verified with [Shapiro-Wilk
test](https://en.wikipedia.org/wiki/Shapiro%E2%80%93Wilk_test) or
[Kolmogorov-Smirnov
test](https://en.wikipedia.org/wiki/Kolmogorov%E2%80%93Smirnov_test). As an
alternative to Student's t-test (when the normality assumption does not hold) a
[Wilcoxon test](https://en.wikipedia.org/wiki/Wilcoxon_signed-rank_test) is
often performed (of course before you use it you should check its assumptions,
see @fig:testAssumptionsCheckCycle above).

Both Kolmogorov-Smirnov (see [this
docs](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#Kolmogorov-Smirnov-test))
and Wilcoxon test (see [that
docs](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#Wilcoxon-signed-rank-test))
are at our disposal in `HypothesisTests` package. Behold

```jl
s = """
Htests.ExactOneSampleKSTest(beerVolumes,
	Dsts.Normal(meanBeerVol, stdBeerVol))
"""
sco(s)
```

So it seems we got no grounds to reject the $H_{0}$ that states that our data
are normally distributed (p-value > 0.05) and we were right to perform our
one-sample Student's t-test. Of course, I had checked the assumption before I
conducted the test (`Htests.OneSampleTTest`). I didn't mention it there because
I didn't want to prolong my explanation (and diverge from the topic) back there.

And now a question. Is the boring assumption check before a statistical test
really necessary?

If you want your conclusions to reflect the reality well then yes. So, even
though a statistical textbook for brevity may not check the assumptions of a
method you should do it in your analyses if your care about the correctness of
your judgment.

## Two samples Student's t-test {#sec:compare_contin_data_two_samp_ttest}

Imagine a friend that studies biology told you that he had conducted a research
in order to write a dissertation and earn a [master's
degree](https://en.wikipedia.org/wiki/Master_of_Science). As part of the
research he tested a new drug (drug X) on mice. He hopes the drug is capable to
reduce the body weights of the animals (and if so, then in a distant future it
might be even tested on humans). He asks you for help with the data
analysis. The results obtained by him are as follows.

```jl
s = """
import CSV as Csv
import DataFrames as Dfs

# if you are in 'code_snippets' folder, then use: "./ch05/miceBwt.csv"
# if you are in 'ch05' folder, then use: "./miceBwt.csv"
miceBwt = Csv.read("./code_snippets/ch05/miceBwt.csv", Dfs.DataFrame)
first(miceBwt, 3)
Options(first(miceBwt, 3), caption="Body mass [g] of mice (fictitious data).", label="mBwtDf")
"""
replace(sco(s), Regex("Options.*") => "")
```

> **_Note:_** The path specification above should work fine on GNU/Linux
> operating systems.  I don't know about other OSs.

Here, we opened a table with a made up data for mice body weight [g] (this
data set can be found
[here](https://github.com/b-lukaszuk/RJ_BS_eng/tree/main/code_snippets/ch05)). For
that we used two new packages ([CSV](https://csv.juliadata.org/stable/), and
[DataFrames](https://dataframes.juliadata.org/stable/)).

A `*.csv` file can be opened and created, e.g. with a
[spreadsheet](https://en.wikipedia.org/wiki/List_of_spreadsheet_software)
program. Here, we read it as a `DataFrame`, i.e. a structure that resembles an
array from @sec:julia_arrays. Since the `DataFrame` could potentially have
thousands of rows we displayed only the first three (to check that everything
succeeded) using the `first` function.

> **_Note:_** We can check the size of a `DataFrame` with `size` function which
> returns the information in a friendly `(numRows, numCols)` format.

OK, let's take a look at some descriptive statistics using
[describe](https://dataframes.juliadata.org/stable/lib/functions/#DataAPI.describe)
function.

```jl
s = """
Dfs.describe(miceBwt)
Options(Dfs.describe(miceBwt), caption="Body mass of mice. Descriptive statistics.", label="mBwtDescribe")
"""
replace(sco(s), Regex("Options.*") => "")
```

It appears that mice from group `drugX` got somewhat lower body weight. But that
could be just a coincidence. Anyway, how should we analyze this data? Well, it
depends on the experiment design.

Since we have `jl size(miceBwt)[1]` rows (`size(miceBwt)[1]`). Then, either:

- we had 10 mice at the beginning. The mice were numbered randomly 1:10 on their
  tails. Then we measured their initial weight (`noDrugX`), administered the
  drug and measured their body weight after, e.g. one week (`drugX`), or
- we had 20 mice at the beginning. The mice were numbered randomly 1:20 on their
  tails. Then first 10 of them (numbers 1:10) became controls (regular food,
  group: `noDrugX`) and the other 10 (11:20) received additionally `drugX`
  (hence group `drugX`).

Interestingly, the experimental models deserve slightly different statistical
methodology. In the first case we will perform a paired samples t-test, whereas
in the other case we will use an unpaired samples t-test. Ready, let's go.

### Paired samples Student's t-test {#sec:compare_contin_data_paired_ttest}

Running a paired Student's t-test with `HypothesisTests` package is very
simple. We just have to send the specific column(s) to the appropriate
function. Column selection can be done in one of the few ways, e.g. `miceBwt[:,
"noDrugX"]` (similarly to array indexing in @sec:julia_arrays `:` means all
rows, note that this form copies the column), `miceBwt[!, "noDrugX"]` (`!`
instead of `:`, no copying), `miceBwt.noDrugX` (again, no copying).

> **_Note:_** Copying a column is advantageous when a function may modify the
> input data, but it is less effective for big data frames. If you wonder does a
> function changes its input then for starter look at its name and compare it
> with the convention we discussed in @sec:functions_modifying_arguments. Still,
> to be sure you would have to examine the function's code.

And now we can finally run the paired t-test.

```jl
s = """
# miceBwt.noDrugX or miceBwt.noDrugX returns a column as a Vector
Htests.OneSampleTTest(miceBwt.noDrugX, miceBwt.drugX)
"""
sco(s)
```

And voila. We got the result. It seems that `drugX` actually does lower the body
mass of the animals ($p \le 0.05$). But wait, didn't we want to do a (paired)
two-samples t-test and not `OneSampleTTest`? Yes, we did. Interestingly enough,
a paired t-test is actually a one-sample t-test for the difference. Observe.

```jl
s = """
# miceBwt.noDrugX or miceBwt.noDrugX returns a column as a Vector
# hence we can do element-wise subtraction using dot syntax
miceBwtDiff = miceBwt.noDrugX .- miceBwt.drugX
Htests.OneSampleTTest(miceBwtDiff)
"""
sco(s)
```

Here, we used the familiar dot syntax from @sec:julia_language_dot_functions to
obtain the differences and then fed the result to `OneSampleTTest` from the
previous section (see @sec:compare_contin_data_one_samp_ttest). The output is
the same as in the previous code snippet.

I don't know about you, but when I was a student I often wondered when to choose
a paired and when an unpaired t-test. Now I finally know, and it is so
simple. Too bad that most statistical programs/packages separate paired t-test
from one-sample t-test (unlike the authors of the `HypothesisTests` package).

Anyway, this also demonstrates an important feature of the data. The data points
in both columns/groups need to be properly ordered, e.g. in our case it makes
little sense to subtract body mass of a mouse with 1 on its tail from a mouse
with 5 on its tail, right? Doing so has just as little sense as subtracting it
from mouse number 6, 7, 8, etc. There is only one clearly good way to do this
subtraction and this is to subtract mouse number 1 (`drugX`) from mouse number
1 (`noDrugX`). So, if you ever wonder a paired or unpaired t-test then think if
there is a clearly better way to subtract one column of data from the other. If
so, then you should go with the paired t-test, otherwise choose the unpaired
t-test.

BTW, do you remember how in @sec:compare_contin_data_check_assump we checked the
assumptions of our `oneSampleTTest`, well it turns out that here we should do
the same. However, this time instead of Kolmogorov-Smirnov test I'm going to use
Shapiro-Wilk's normality test from `Pingouin` package (Shapiro-Wilk is usually
more powerful + the syntax and output of the function is nicer here).

```jl
s = """
import Pingouin as Pg
Pg.normality(miceBwtDiff)
Options(Pg.normality(miceBwtDiff), caption="Shapiro-Wilk's normality test.", label="mBwtShapiro")
"""
replace(sco(s), Regex("Options.*") => "", "1.0" => "true")
```

> **_Note:_** At the time I'm writing these words (29-08-2023)
> [Pingouin](https://github.com/clementpoiret/Pingouin.jl) package is still
> under development. This may cause some inconveniences, warnings, etc. Proceed
> with caution.

There, all normal (p > 0.05). So, we were right to perform the test. Still, the
order was incorrect, in general you should remember to check the assumptions
first and then proceed with the test. In case the normality assumption did not
hold we should consider doing a [Wilcoxon
test](https://en.wikipedia.org/wiki/Wilcoxon_signed-rank_test) (non-parametric
test), e.g. like so `Htests.SignedRankTest(df.noDrugX, df.drugX)` or
`Htests.SignedRankTest(miceBwtDiff)`. More info on the test can be found in the
link above or on the pages of `HypothesisTests` package (see
[here](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#Wilcoxon-signed-rank-test)).

### Unpaired samples Student's t-test {#sec:compare_contin_data_unpaired_ttest}

OK, now it's time to move to the other experimental model. A reminder, here we
discuss the following situation:

- we had 20 mice at the beginning. The mice were numbered randomly 1:20 on their
  tails. Then first 10 of them (numbers 1:10) became controls (regular food,
  group: `noDrugX`) and the other 10 (11:20) received additionally `drugX`
  (hence group `drugX`).

Here we will compare mice `noDrugX` (miceID: 1:10) with mice `drugX` (miceID:
11:20) using an unpaired samples t-test, but this time we will start by checking
the assumptions.

First the normality assumption.

```jl
s = """
# for brevity we will extract just the p-values
(
	Pg.normality(miceBwt.noDrugX).pval,
	Pg.normality(miceBwt.drugX).pval
)
"""
sco(s)
```

OK, no reason to doubt the normality (p-vals > 0.05). The other assumption that
we may test is homogeneity of variance. Homogeneity means that the spread of
data around the mean in each group is similar (var(gr1) ≈ var(gr2)). Here, we
are going to use
[Fligner-Killeen](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#Fligner-Killeen-test)
test from the `HypothesisTests` package.

```jl
s = """
Htests.FlignerKilleenTest(miceBwt.noDrugX, miceBwt.drugX)
"""
sco(s)
```

Also this time, the assumption is fulfilled (`p-value` > 0.05), and now for the
unpaired test.

```jl
s = """
Htests.EqualVarianceTTest(
	miceBwt.noDrugX, miceBwt.drugX)
"""
sco(s)
```

It appears there is not enough evidence to reject the $H_{0}$ (the mean
difference is equal to 0) on the cutoff level of 0.05. So, how could that be,
the means in both groups are still the same, i.e. `Stats.mean(miceBwt.noDrugX)`
= `jl round(Stats.mean(miceBwt.noDrugX), digits = 2)` and
`Stats.mean(miceBwt.drugX)` = `jl round(Stats.mean(miceBwt.drugX), digits = 2)`,
yet we got different results (reject $H_{0}$ from paired t-test, not reject
$H_{0}$ from unpaired t-test). Well, it is because we calculated slightly
different things and because using paired samples usually removes some between
subjects variability.

In the case of unpaired t-test we:

1. assume that the difference between the means under $H_{0}$ is equal to 0.
2. calculate the observed difference between the means,
   `Stats.mean(miceBwt.noDrugX) - Stats.mean(miceBwt.drugX)` =
   `jl round(Stats.mean(miceBwt.noDrugX) - Stats.mean(miceBwt.drugX), digits=2)`.
3. calculate the sem (with a slightly different formula than for the
   one-sample/paired t-test)
4. obtain the z-score (in case of t-test it is named t-score or t-statistics)
5. calculate the probability for the t-statistics (slightly different
   calculation of the degrees of freedom)

When compared with the methodology for one-sample t-test from
@sec:compare_contin_data_one_samp_ttest it differs only with respect to the
points 3, 4 and 5 above. Observe. First the functions

```jl
s = """
function getSem(v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
    sem1::Float64 = getSem(v1)
    sem2::Float64 = getSem(v2)
    return sqrt((sem1^2) + (sem2^2))
end

function getDf(v1::Vector{<:Real}, v2::Vector{<:Real})::Int
    return getDf(v1) + getDf(v2)
end
"""
sc(s)
```

There are different formulas for pooled sem (standard error of the mean), but I
only managed to remember this one because it reminded me the famous [Pythagorean
theorem](https://en.wikipedia.org/wiki/Pythagorean_theorem), i.e. $c^2 = a^2 +
b^2$, so $c = \sqrt{a^2 + b^2}$, that I learned in a primary school. As for the
degrees of freedom they are just the sum of the degrees of freedom for each of
the vectors. OK, so now the calculations


```jl
s = """
meanDiffBwtH0 = 0
meanDiffBwt = Stats.mean(miceBwt.noDrugX) - Stats.mean(miceBwt.drugX)
pooledSemBwt = getSem(miceBwt.noDrugX, miceBwt.drugX)
zScoreBwt = getZScore(meanDiffBwtH0, meanDiffBwt, pooledSemBwt)
dfBwt = getDf(miceBwt.noDrugX, miceBwt.drugX)
pValBwt = Dsts.cdf(Dsts.TDist(dfBwt), zScoreBwt) * 2
"""
sc(s)
```

And finally the result that you may compare with the output of the unpaired
t-test above and the methodology for the one-sample t-test from
@sec:compare_contin_data_one_samp_ttest.

```jl
s = """
(
	meanDiffBwtH0, # value under h_0
	round(meanDiffBwt, digits = 4), # point estimate
	round(pooledSemBwt, digits = 4), # empirical standard error
	# to get a positive zScore we should have calculated it as:
	# getZScore(meanDiffBwt, meanDiffBwtH0, pooledSemBwt)
	round(zScoreBwt, digits = 4), # t-statistic
	dfBwt, # degrees of freedom
	round(pValBwt, digits=4) # two-sided p-value
)
"""
sco(s)
```

Amazing. In the case of the unpaired two-sample t-test we use the same
methodology and reasoning as we did in the case of the one-sample t-test from
@sec:compare_contin_data_one_samp_ttest (only functions for `sem` and `df`
changed slightly). Given the above I recommend you get back to the section
@sec:compare_contin_data_one_samp_ttest and make sure you understand the
explanations presented there (if you haven't done this already).

As an alternative to our unpaired t-test we should consider
`Htests.UnequalVarianceTTest` (if the variances are not equal) or
`Htests.MannWhitneyUTest` (if both the normality and homogeneity assumptions do
not hold).

## One-way ANOVA {#sec:compare_contin_data_one_way_anova}

One-way ANOVA is a technique to compare two or more groups of continuous
data. It allows us to tell if all the groups are alike or not based on the
spread of the data around the mean(s).

Let's start with something familiar. Do you still remember our tennis players
Peter and John from @sec:statistics_intro_tennis. Well, guess what, they work at
two different biological institutes. The institutes independently test a new
weight reducing drug, called drug Y, that is believed to reduce body weight of
an animal by roughly 23%. The drug administration is fairly simple. You just
dilute it in water and leave it in a cage for mice to drink it.

So both our friends independently run the following experiment: a researcher
takes eight mice, writes at random numbers at their tails (1:8), and decides
that the mice 1:4 will drink pure water, and the mice 5:8 will drink water with
the drug. After a week body weights of all mice are recorded.

As said, Peter and John run the experiments independently not knowing one about
the other. After a week Peter noticed that he messed things up and did not give
the drug to mice (when diluted the drug is colorless and by accident he took the
wrong bottle). It happened, still let's compare the results that were obtained
by both our friends.

```jl
s = """
import Random as Rand

# Peter's mice, experiment 1 (ex1)
Rand.seed!(321)
ex1BwtsWater = Rand.rand(Dsts.Normal(25, 3), 4)
ex1BwtsPlacebo = Rand.rand(Dsts.Normal(25, 3), 4)

# John's mice, experiment 2 (ex2)
ex2BwtsWater = Rand.rand(Dsts.Normal(25, 3), 4)
ex2BwtsDrugY = Rand.rand(Dsts.Normal(25 * 0.77, 3), 4)
"""
sc(s)
```

In Peter's case both mice groups came from the same population `Dsts.Normal(25,
3)` ($\mu = 25$, $\sigma = 3$) since they both ate and drunk the same stuff. For
need of different name the other group is named
[placebo](https://en.wikipedia.org/wiki/Placebo).

In John's case the other group comes from a different distribution (e.g. the one
where body weight is reduced on average by 23%, hence $\mu = 25 * 0.77$).

Let's see the results side by side on a graph.

![The results of drug Y application on body weight of laboratory mice.](./images/oneWayAnovaDrugY.png){#fig:oneWayAnovaDrugY}

I don't know about you, but my first impression is that the data points are more
scattered around in John's experiment. Let's add some means to the graph to make
it more obvious.

![The results of drug Y application on body weight of laboratory mice with group and overall means.](./images/oneWayAnovaDrugY2.png){#fig:oneWayAnovaDrugY2}

Indeed, with the lines (especially the overall means) the difference in spread
of the data points seems to be even more evident. Notice an interesting fact, in
the case of water and placebo the group means are closer to each other, and to
the overall mean. This makes sense, after all the animals ate and drunk exactly
the same stuff, so they belong to the same population. On the other hand in the
case of the two populations (water and drugY) the group means differ from the
overall mean (again, think of it for a moment and convince yourself that it
makes sense). Since we got Julia on our side we could even try to express this
spread of data with numbers. First, the spread of data points around the group
means

```jl
s = """
function getAbsDiffs(v::Vector{<:Real})::Vector{<:Real}
    return abs.(Stats.mean(v) .- v)
end

function getAbsPointDiffsFromGroupMeans(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Vector{<:Real}
    return vcat(getAbsDiffs(v1), getAbsDiffs(v2))
end

ex1withinGroupsSpread = getAbsPointDiffsFromGroupMeans(
	ex1BwtsWater, ex1BwtsPlacebo)
ex2withinGroupsSpread = getAbsPointDiffsFromGroupMeans(
	ex2BwtsWater, ex2BwtsDrugY)

ex1AvgWithinGroupsSpread = Stats.mean(ex1withinGroupsSpread)
ex2AvgWithingGroupsSpread = Stats.mean(ex2withinGroupsSpread)

(ex1AvgWithinGroupsSpread, ex2AvgWithingGroupsSpread)
"""
sco(s)
```

The code is pretty simple. Here we calculate the distance of data points around
the group means. Since we are not interested in a sign of a difference [`+`
(above), `-` (below) the mean] we use `abs` function. We used a similar
methodology when we calculated `absDiffsStudA` and `absDiffsStudB` in
@sec:statistics_normal_distribution. This is as if we measured the distances
from the group means in @fig:oneWayAnovaDrugY2 with a ruler and took the
average of them. The only new part is the
[vcat](https://docs.julialang.org/en/v1/base/arrays/#Base.vcat) function. All it
does is it glues two vectors together, like: `vcat([1, 2], [3, 4])` gives us
`[1, 2, 3, 4]`. Anyway, na average distance of a point from a group mean is
 `jl round(ex1AvgWithinGroupsSpread, digits=1)` [g] for experiment 1 (left panel
in @fig:oneWayAnovaDrugY2). For experiment 2 (right panel in
@fig:oneWayAnovaDrugY2) it is equal to
 `jl round(ex2AvgWithingGroupsSpread, digits=1)` [g].
 That is nice, as it follows our expectations. However,
`AvgWithinGroupsSpread` by itself is not enough since sooner or later in
`experiment 1` (hence prefix `ex1-`) we may encounter (a) population(s) with a
wide natural spread of the data. Therefore, we need a more robust metric.

This is were the average spread of group means around the overall mean could be
useful. Let's get to it, we will start with these functions

```jl
s = """
function repVectElts(v::Vector{T}, times::Vector{Int})::Vector{T} where {T}
    @assert (length(v) == length(times)) "length(v) not equal length(times)"
    @assert all(map(x -> x > 0, times)) "times elts must be positive"
    result::Vector{T} = Vector{eltype(v)}(undef, sum(times))
    currInd::Int = 1
    for i in eachindex(v)
        for _ in 1:times[i]
            result[currInd] = v[i]
            currInd += 1
        end
    end
    return result
end

function getAbsGroupDiffsFromOverallMean(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Vector{<:Real}
    overallMean::Float64 = Stats.mean(vcat(v1, v2))
    groupMeans::Vector{Float64} = [Stats.mean(v1), Stats.mean(v2)]
    absGroupDiffs::Vector{<:Real} = abs.(overallMean .- groupMeans)
    absGroupDiffs = repVectElts(absGroupDiffs, map(length, [v1, v2]))
    return absGroupDiffs
end
"""
sc(s)
```

The function `repVectElts` is a helper function. It is slightly complicated and
I will not explain it in detail. Just treat it as any other function from a
library. A function you know only by name, input, and output. A function that
you are not aware of its insides (of course if you really want you can figure
them out by yourself). All it does is it takes two vectors `v` and `times`, then
it replicates each element of `v` a number of times specified in `times` like
so: `repVectElts([10, 20], [1, 2])` `jl repVectElts([10, 20], [1, 2])`. And this
is actually all you care about right now.

As for the `getAbsGroupDiffsFromOverallMean` it does exactly what it says. It
subtracts group means from the overall mean `(overallMean .- groupMeans)` and
takes absolute values of that [`abs.(`]. Then it repeats each difference as many
times as there are observations in the group `repVectElts(absGroupDiffs,
map(length, [v1, v2]))` (as if every single point in a group was that far away
from the overall mean). This is what it returns to us.

> **_Note:_** In reality functions in statistical packages probably use a
> different formula for `absGroupDiffs`. Still, I like my explanation better.

OK, time to use the last function, behold

```jl
s = """
ex1groupSpreadFromOverallMean = getAbsGroupDiffsFromOverallMean(
	ex1BwtsWater, ex1BwtsPlacebo)
ex2groupSpreadFromOverallMean = getAbsGroupDiffsFromOverallMean(
	ex2BwtsWater, ex2BwtsDrugY)

ex1AvgGroupSpreadFromOverallMean = Stats.mean(ex1groupSpreadFromOverallMean)
ex2AvgGroupSpreadFromOverallMean = Stats.mean(ex2groupSpreadFromOverallMean)

(ex1AvgGroupSpreadFromOverallMean, ex2AvgGroupSpreadFromOverallMean)
"""
sco(s)
```

OK, we got it. The average group mean spread around the overall mean is
 `jl round(ex1AvgGroupSpreadFromOverallMean, digits=1)` [g] for experiment 1
 (left panel in @fig:oneWayAnovaDrugY2) and
 `jl round(ex2AvgGroupSpreadFromOverallMean, digits=1)` [g] for experiment 2
(right panel in @fig:oneWayAnovaDrugY2). Again, the values are as we
expected them to be based on our intuition.

Now, we can use the obtained before `AvgWithinGroupSpread` as a reference point
for `AvgGroupSpreadFromOverallMean` like so

```jl
s = """
LStatisticEx1 = ex1AvgGroupSpreadFromOverallMean / ex1AvgWithinGroupsSpread
LStatisticEx2 = ex2AvgGroupSpreadFromOverallMean / ex2AvgWithingGroupsSpread

(LStatisticEx1, LStatisticEx2)
"""
sco(s)
```

Here, we calculated a so called `LStatistic`. I made the name up, because that
is the first name that came to my mind. Perhaps it is because my family name is
Lukaszuk or maybe because I'm selfish. Anyway, the higher the L-statistic (so
the ratio of group spread around the overall mean to within group spread) the
smaller the probability that such a big difference was caused by a chance alone
(hmm, I think I said something along those lines in one of the previous
chapters). If only we could reliably determine the cutoff point for my
`LStatistic`.

Luckily, there is no point for us to do that since one-way ANOVA relies on a
similar metric called F-statistic (BTW. Did I mention that the ANOVA was
developed by [Ronald Fisher](https://en.wikipedia.org/wiki/Ronald_Fisher)? Of
course in that case others bestow the name in his honor). Observe. First,
experiment 1:

```jl
s = """
Htests.OneWayANOVATest(ex1BwtsWater, ex1BwtsPlacebo)
"""
sco(s)
```

Here, my made up `LStatistic` was `jl round(LStatisticEx1, digits=2)` whereas
the F-Statistic is 0.35, so kind of close. Chances are they measure the same
thing but using slightly different methodology. Here, the p-value (p > 0.05)
demonstrates that the groups come from the same population.

OK, now time for experiment 2:

```jl
s = """
Htests.OneWayANOVATest(ex2BwtsWater, ex2BwtsDrugY)
"""
sco(s)
```

Here, the p-value ($p \le 0.05$) demonstrates that the groups come from different
populations (the means of those populations differ). As a reminder, in this case
my made up `LStatistic` was `jl round(LStatisticEx2, digits=2)` whereas the
F-Statistic is 6.56, so this time it is more distant.  The differences stem from
different methodology. For instance, just like in
@sec:statistics_normal_distribution here we used `abs` function as our power
horse. But do you remember, that statisticians love to get rid of the sign from
a number by squaring it. Anyway, let's rewrite our functions in a more
statistical manner.

```jl
s = """
# compare with our getAbsDiffs
function getSquaredDiffs(v::Vector{<:Real})::Vector{<:Real}
    return (Stats.mean(v) .- v) .^ 2
end

# compare with our getAbsPointDiffsFromOverallMean
function getResidualSquaredDiffs(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Vector{<:Real}
    return vcat(getSquaredDiffs(v1), getSquaredDiffs(v2))
end

# compare with our getAbsGroupDiffsAroundOverallMean
function getGroupSquaredDiffs(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Vector{<:Real}
    overallMean::Float64 = Stats.mean(vcat(v1, v2))
    groupMeans::Vector{Float64} = [Stats.mean(v1), Stats.mean(v2)]
    groupSqDiffs::Vector{<:Real} = (overallMean .- groupMeans) .^ 2
    groupSqDiffs = repVectElts(groupSqDiffs, map(length, [v1, v2]))
    return groupSqDiffs
end
"""
sc(s)
```

The functions are very similar to the ones we developed earlier. Of course,
instead of `abs.(` we used `.^2` to get rid of the sign. Here, I adopted
the names (`group sum of squares` and `residual sum of squares`) that you may
find in a statistical textbook/software.

Now we can finally calculate averages of those squares and the F-statistics
itself with the following functions

```jl
s = """
function getResidualMeanSquare(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
    residualSquaredDiffs::Vector{<:Real} = getResidualSquaredDiffs(v1, v2)
    return sum(residualSquaredDiffs) / getDf(v1, v2)
end

function getGroupMeanSquare(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
    groupSquaredDiffs::Vector{<:Real} = getGroupSquaredDiffs(v1, v2)
    groupMeans::Vector{Float64} = [Stats.mean(v1), Stats.mean(v2)]
    return sum(groupSquaredDiffs) / getDf(groupMeans)
end

function getFStatistic(v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
	return getGroupMeanSquare(v1, v2) / getResidualMeanSquare(v1, v2)
end
"""
sc(s)
```

Again, here I tried to adopt the names (`group mean square` and `residual mean
square`) that you may find in a statistical textbook/software. Anyway, notice
that in order to calculate `MeanSquare`s we divided our sum of squares by the
degrees of freedom (we met this concept and developed the functions for its
calculation in @sec:compare_contin_data_one_samp_ttest and in
@sec:compare_contin_data_unpaired_ttest). Using degrees of freedom (instead of
`length(vector)` like in the arithmetic mean) is usually said to provide better
estimates of the desired values when the sample size(s) is/are small.

OK, time to verify our functions for the F-statistic calculation.

```jl
s = """
(
	getFStatistic(ex1BwtsWater, ex1BwtsPlacebo),
	getFStatistic(ex2BwtsWater, ex2BwtsDrugY),
)
"""
sco(s)
```

To me, they look similar to the ones produced by `Htests.OneWayANOVATest`
before, but go ahead scroll up and check it yourself. Anyway, under $H_{0}$ (all
groups come from the same population) the F-statistic (so
$\frac{groupMeanSq}{residMeanSq}$) got the
[F-Distribution](https://en.wikipedia.org/wiki/F-distribution) (a probability
distribution), hence we can calculate the probability of obtaining such a value
(or greater) by chance and get our p-value (similarily as we did in
@sec:statistics_intro_distributions_package or in
@sec:compare_contin_data_one_samp_ttest). Based on that we can deduce whether
samples come from the same population (p > 0.05) or from different populations
($p \le 0.05$). Ergo, we get to know if any group (means) differ(s) from the
other(s).

## Post-hoc tests {#sec:compare_contin_data_post_hoc_tests}

Let's start with a similar example to the ones we already met.

Imagine that you are a scientist and in the Amazon rain forest you discovered
two new species of mice (`spB`, and `spC`). Now, you want to compare their body
masses with an ordinary lab mice (`spA`) so you collect the data. If the body
masses differ perhaps in the future they will become the criteria for species
recognition.

```jl
s = """
# if you are in 'code_snippets' folder, then use: "./ch05/miceBwtABC.csv"
# if you are in 'ch05' folder, then use: "./miceBwtABC.csv"
miceBwtABC = Csv.read("./code_snippets/ch05/miceBwtABC.csv", Dfs.DataFrame)
Options(miceBwtABC, caption="Body mass [g] of three mice species.", label="mBwtABCDf")
"""
replace(sco(s), Regex("Options.*") => "")
```

Now, let us quickly look at the means and standard deviations in the three
groups to get some impression about the data.

```jl
s = """
[
(n, Stats.mean(miceBwtABC[!, n]), Stats.std(miceBwtABC[!, n]))
	for n in Dfs.names(miceBwtABC)
]
"""
sco(s)
```

Here, the function `Dfs.names` returns `Vector{T}` with names of the
columns. In connection with comprehensions we met in
@sec:julia_language_comprehensions it allows us to quickly obtain the desired
statistics without typing the names by hand. Alternatively we would have to type

```
[
("spA", Stats.mean(miceBwtABC[!, "spA"]), Stats.std(miceBwtABC[!, "spA"])),
("spB", Stats.mean(miceBwtABC[!, "spB"]), Stats.std(miceBwtABC[!, "spB"])),
("spC", Stats.mean(miceBwtABC[!, "spC"]), Stats.std(miceBwtABC[!, "spC"])),
]
```

It didn't save us a lot of typing in this case, but think what if we had 10, 30
or even 100 columns. The gain would be quite substantial.

Anyway, based on the means it appears that the three species differ slightly in
their body masses. Still, in connection with the standard deviations, we can
see that the body masses in the groups overlap slightly. So, is it enough to
claim that they are statistically different at the cutoff level of 0.05
($\alpha$)? Let's test that with the one-way ANOVA that we met in the previous
chapter.

Let's start by checking the assumptions. First, the normality assumption

```jl
s = """
[Pg.normality(miceBwtABC[!, n]).pval[1] for n in Dfs.names(miceBwtABC)] |>
pvals -> map(pv -> pv > 0.05, pvals) |>
all
"""
sco(s)
```

All normal. Here we get the p-values from Shapiro-Wilk test for all our
groups. The documentation for
[Pingouin](https://github.com/clementpoiret/Pingouin.jl) (and some tries and
errors) shows that to get the p-value alone you must type
`Pg.normality(vector).pval[1]`. Then we pipe (`|>`, see:
@sec:statistics_prob_distribution) the result to `map` to check if the p-values
(`pvals`) are greater than 0.05 (then we do not reject the null hypothesis of
normal distribution). Finally, we pipe (`|>`) the `Vector{Bool}` to the function
[all](https://docs.julialang.org/en/v1/base/collections/#Base.all-Tuple{Any})
which returns `true` only if all the elements of the vector are true.

OK, time for the homogeneity of variance assumption

```jl
s = """
Htests.FlignerKilleenTest(
	[miceBwtABC[!, n] for n in Dfs.names(miceBwtABC)]...
	) |> Htests.pvalue |> pv -> pv > 0.05
"""
sco(s)
```

The variances are roughly equal. Here `[miceBwtABC[!, n] for n in
Dfs.names(miceBwtABC)]` returns `Vector{Vector{<:Real}}` so vector of vectors,
e.g. `[[1, 2], [3, 4], [5, 6]]` but `Htests.FlingerTest` expects separate
vectors `[1, 2], [3, 4], [5, 6]` (no outer square brackets). The splat operator
(`...`) placed after the array removes the outer square brackets. Then we pipe
the result of the test `Htests.FlingerTest` to `Htests.pvalue` because according
to [the documentation](https://juliastats.org/HypothesisTests.jl/stable/) it
extracts the p-value from the result of the test. Finally, we pipe (`|>`) the
result to an anonymous function (`pv -> pv > 0.05`) to check if the p-value is
greater than 0.05 (then we do not reject the null hypothesis of variance
homogeneity).

OK, and now for the one-way ANOVA.

```jl
s = """
Htests.OneWayANOVATest(
	[miceBwtABC[!, n] for n in Dfs.names(miceBwtABC)]...
	) |> Htests.pvalue
"""
sco(s)
```

Hmm, OK, the p-value is lower than the cutoff level of 0.05. What now. Well, by
doing one-way ANOVA you ask your computer a very specific question: "Does at
least one of the group means differs from the other(s)?". The computer does
exactly what you tell it, nothing more, nothing less. Here, it answers your
question precisely with: "Yes" (since $p \le 0.05$). I assume that right now you
are not satisfied with the answer. After all, what good is it if you still don't
know which group(s) differ one from another: `spA` vs. `spB` and/or `spA` vs
`spC` and/or `spB` vs `spC`. If you want your computer to tell you that then you
must ask it directly to do so. That is what post-hoc tests are for (`post hoc`
means `after the event`, here the event is one-way ANOVA).

The split to one-way ANOVA and post-hoc tests made perfect sense in the
1920s-30s and the decades after the method was introduced. Back then you
performed calculations with a pen and paper (perhaps a calculator as well). Once
one-way ANOVA produced p-value greater than 0.05 you stopped. Otherwise, and
only then, you performed a post-hoc test (again with a pen and paper). Anyway,
as mentioned in @sec:statistics_intro_exercise4_solution the popular choices for
post-hoc tests include Fisher's LSD test and Tukey's HSD test. Here we are going
to use a more universal approach and apply a so called `pairwise t-test` (which
is just a t-test, that you already know, done between every pairs of
groups). Ready, here we go

```jl
s = """
evtt = Htests.EqualVarianceTTest
getPval = Htests.pvalue

# for "spA vs spB", "spA vs spC" and "spB vs spC", respectively
postHocPvals = [
evtt(miceBwtABC[!, "spA"], miceBwtABC[!, "spB"]) |> getPval,
evtt(miceBwtABC[!, "spA"], miceBwtABC[!, "spC"]) |> getPval,
evtt(miceBwtABC[!, "spB"], miceBwtABC[!, "spC"]) |> getPval,
]

postHocPvals
"""
sco(s)
```

OK, here to save us some typing we assigned the long function names
(`Htests.EqualVarianceTTest` and `Htests.pvalue`) to the shorter ones (`evtt`
and `getPval`). Then we used them to conduct the t-tests and extract the
p-values for all the possible pairs to compare (we will develop some more user
friendly functions in the upcoming exercises, see @sec:compare_contin_data_ex4).
Anyway, it appears that here any mouse species differs with respect to their
average body weight from the other two species (all p-vaues are below 0.05). Or
does it?

## Multiplicity correction {#sec:compare_contin_data_multip_correction}

In the previous section we performed a pairwise t-test for the following
comparisons:

- `spA` vs `spB`,
- `spA` vs `spC`,
- `spB` vs `spC`.

The obtained p-values were

```jl
s = """
postHocPvals
"""
sco(s)
```

Based on that we concluded that every group mean differs from every other group
mean (all p-values are lower than the cutoff level for $\alpha$ equal to
0.05). However, there is a small problem with this approach (see the explanation
below).

In @sec:statistics_intro_errors we said that it is impossible to reduce the type
1 error ($\alpha$) probability to 0. Therefore if all our null hypothesis
($H_{0}$) were true we need to accept the fact that we will report some false
positive findings. All we can do is to keep that number low.

Imagine you are testing a set of random substances to see if they reduce the
size (e.g. diameter) of a
[tumor](https://en.wikipedia.org/wiki/Neoplasm). Most likely the vast majority
of the tested substances will not work (so let's assume that in reality all
$H_{0}$s are true). Now imagine, that the result each substance has on the tumor
is placed in a separate graph. So, you draw a
[boxplot](https://en.wikipedia.org/wiki/Box_plot)
(like the one you will do in the upcoming @sec:compare_contin_data_ex5).
Now the question. How many
graphs would contain false positive results if the cutoff level for $\alpha$ is
0.05? Pause for a moment and come up with the number. That is easy, 100 graphs
times 0.05 (probability of false positive) gives us the expected `100 * 0.05` =
 `jl convert(Int, 100 * 0.05)` figures with false positives. BTW. If you got it,
congratulations. If not compare the solution with the calculations we did in
@sec:statistics_prob_distribution. Anyway, you decided that this will be your
golden standard, i.e. no more than 5% ($\frac{5}{100}$ = 0.05) of figures
with false positives.

But here (in `postHocPvals` above) you got 3 comparisons and therefore 3
p-values. Imagine that you place such three results into a single figure. Now,
the question is: under the conditions given above (all $H_{0}$s true, cutoff for
$\alpha$ = 0.05) how many graphs would contain false positives if you placed
three such comparisons per graph for 100 figures? Think for a moment and come up
with the number.

OK, so we got 100 graphs, each reporting 3 comparisons (3 p-values), which gives
us in total 300 results. Out of them we expect `300 * 0.05` =
 `jl convert(Int, 300 * 0.05)` to be false positives. Now, we pack those
300 results into 100 figures. In the best case scenario the 15 false positives
will land in the first five graphs (three false positives per graph, `5*3` =
 `jl 5*3`), the remaining 285 true negatives will land in the remaining 95
figures (three true negatives per graph, `95*3` = `jl 95*3`).
The golden standard seems
to be kept (`5/100` = `jl 5/100`). The problem is that we don't know which
figures get the false positives. The [Murphy's
law](https://en.wikipedia.org/wiki/Murphy%27s_law) states: "Anything that can go
wrong will go wrong, and at the worst possible time." (or in the worst possible
way). If so, then the 15 false positives will go to 15 different figures (1
false positive + 2 true negatives per graph), and the remaining `285 - 2*15` =
 `jl 285-2*15` true negatives will go to the remaining
`255/3` = `jl convert(Int, 255/3)` figures.
Here, your golden standard (5% of figures with false positives)
is violated (`15/100` = `jl 15/100`).

This is why we cannot just leave the three `postHocPvals` as they are. We need
to act, but what can we do to counteract the problem. Well, if the initial
cutoff level for $\alpha$ was 3 times smaller (`0.05/3` =
 `jl round(0.05/3, digits=3)`) then in the case above we would
have `300 * (0.05/3)` ≈ `jl round(300 * (0.05/3), digits=2)` false positives
to put into 100 figures and everything would be OK even in the worst
case scenario. Alternatively, since
division is inverse operation to multiplication we could just multiply every
p-value by 3 (number of comparisons) and check its significance at the cutoff
level for $\alpha$ equal 0.05, like so

```jl
s = """
function adjustPvalue(pVal::Float64, by::Int)::Float64
	@assert (0 <= pVal <= 1) "pVal must be in range [0-1]"
	return min(1, pVal*by)
end

function adjustPvalues(pVals::Vector{Float64})::Vector{Float64}
	return adjustPvalue.(pVals, length(pVals))
end

# p-values for comparisons: spA vs spB, spA vs spC, and spB vs spC
adjustPvalues(postHocPvals)
"""
sco(s)
```

Notice, the since on entry a p-value may be, let's say, 0.6 then multiplying it
by 3 would give us `jl round(0.6*3, digits=2)` which is an impossible value for
probability (see @sec:statistics_intro_probability_summary). That is why we
set the upper limit to 1 by using `min(1, pVal*by)`. Anyway, after adjusting for
multiple comparisons only one species differs from the other (`spA` vs `spC`,
adjusted $p-value \le 0.05$). And this is our final conclusion.

The method we used above (in `adjustPvalue` and `adjustPvalues`) is called the
[Bonferroni correction](https://en.wikipedia.org/wiki/Bonferroni_correction).
Probably it is the simplest method out there and it is useful if we have a
small number of independent comparisons/p-values (let's say up to 6). For a
large number of comparisons you are likely to end up with a paradox:

- one-way ANOVA (which controls the overall $\alpha$ at the level of 0.05)
  indicates that there are some statistically significant differences,
- the corrected p-values (which rely on different assumptions) show no
  significant differences.

Therefore, for large number of comparisons you may choose a different (less
strict) method, e.g. the [Benjamini-Hochberg
procedure](https://en.wikipedia.org/wiki/False_discovery_rate#Benjamini%E2%80%93Hochberg_procedure).
Both of those (Bonferroni and Benjamini-Hochberg) are available in the
[MultipleTesting](https://github.com/juliangehring/MultipleTesting.jl)
package. Observe

```jl
s = """
import MultipleTesting as Mt
# p-values for comparisons: spA vs spB, spA vs spC, and spB vs spC
resultsOfThreeAdjMethods = (
	adjustPvalues(postHocPvals),
	Mt.adjust(postHocPvals, Mt.Bonferroni()),
	Mt.adjust(postHocPvals, Mt.BenjaminiHochberg())
)

resultsOfThreeAdjMethods
"""
replace(sco(s), "]," => "],\n")
```

As expected, the first two lines give the same results (since they both use the
same adjustment method). The third line, and a different method, produces a
different result (and hence yields distinctive interpretation).

A word of caution, you shouldn't just apply 10
different methods on the obtained p-values and choose the one that produces the
greatest number of significant differences. Instead you should choose a
correction method a priori (up front, in advance) and stick to it later (make
the final decision of which group(s) differ based on the adjusted p-values).
Therefore it takes some consideration to choose the multiplicity correction
well.

OK, enough of theory, time for some practice. Whenever you're ready click the
right arrow to go to the exercises for this chapter.

## Exercises - Comparisons of Continuous Data {#sec:compare_contin_data_exercises}

Just like in the previous chapters here you will find some exercises that you
may want to solve to get from this chapter as much as you can (best
option). Alternatively, you may read the task descriptions and the solutions
(and try to understand them).

### Exercise 1 {#sec:compare_contin_data_ex1}

In @sec:compare_contin_data_one_samp_ttest we said that when we draw a small
random sample from a normal distribution of a given mean ($\mu$) and standard
deviation ($\sigma$) then the distribution of the sample means will be
pseudo-normal with the mean roughly equal to the population mean and the
standard deviation roughly equal to sem (standard error of the mean).

Time to confirm that. Moreover, it's time to practice our plotting skills (I
think we neglected them so far).

In this task your population of interest is `Dsts.Normal(80, 20)`. To make it
more concrete let's say
this is the distribution of body weight for adult humans. To plot you may use
[CairoMakie](https://docs.makie.org/stable/documentation/backends/cairomakie/)
or some other plotting library (read the tutorial(s)/docs first).

1) draw a random sample of size 10 from the population
 `Dsts.Normal(80, 20)`. Calculate `sem` and `sd` for the sample,
2) draw 100'000 random samples of size 10 from the population
 `Dsts.Normal(80, 200)` and calculate the samples means (100'000 sample means)
3) draw the histogram of the sample means from point 2 using,
e.g. [Cmk.hist](https://docs.makie.org/stable/examples/plotting_functions/hist/index.html#hist). Afterwards, you may set the y-axis limits from 0 to 4000,
with `Cmk.ylims!(0, 4000)`.
4) on the histogram mark the population mean ($\mu = 80$) with a vertical line
using, e.g. [Cmk.vlines](https://docs.makie.org/stable/examples/plotting_functions/hvlines/index.html#vlines)
5) annotate the line from point 4 (e.g. type "population mean = 80") using,
e.g. [Cmk.text](https://docs.makie.org/stable/examples/plotting_functions/text/index.html#text)
6) on the histogram mark the means standard deviation using,
e.g. [Cmk.bracket](https://docs.makie.org/stable/examples/plotting_functions/bracket/),
7) annotate the histogram (above the bracket from point 6) with the means
standard deviation, using,
e.g. [Cmk.text](https://docs.makie.org/stable/examples/plotting_functions/text/index.html#text),
8) annotate the histogram with the sample's `sem` and `sd` (from point 1) and
compare them with the means standard deviation from point 7.

And that's it. This may look like a lot of work to do, but don't freak out, do
it one point at a time, look at the instructions (they are pretty precise on
purpose).

*Remember that each of those functions may have an equivalent that ends
with `!` (a function that modifies an already existing figure). It is for you to
decide when to use which version of a plotting function.*

### Exercise 2 {#sec:compare_contin_data_ex2}

Do you remember how in @sec:compare_contin_data_one_way_anova we calculated the
L-statistic for `ex2BwtsWater` and `ex2BwtsDrugY` and find out its value was
equal to `LStatisticEx2` = `jl round(LStatisticEx2, digits=2)`? Then we
calculated the famous F-statistics for the same two groups (`ex2BwtsWater` and
`ex2BwtsDrugY`) and it was equal to `getFStatistic(ex2BwtsWater, ex2BwtsDrugY)`
= `jl round(getFStatistic(ex2BwtsWater, ex2BwtsDrugY), digits=2)`. The
probability of obtaining an F-value greater than this (by chance) if $H_{0}$ is
true (i.e. both groups come from the same distribution (`Dsts.Normal(25, 3)`) is
equal to:

```jl
s = """
# the way we calculated it in the chapter (more or less)
Htests.OneWayANOVATest(ex2BwtsWater, ex2BwtsDrugY) |> Htests.pvalue
"""
sco(s)
```

Alternatively, we cold calculate it also with our friendly `Distributions`
package (similarly to how we used in in, e.g.
@sec:statistics_intro_distributions_package)

```jl
s = """
# the way we can calculate it with Distributions package
# 1 - Dfs for groups (number of groups - 1),
# 6 - Dfs for residuals (number of observations - number of groups)
1 - Dsts.cdf(Dsts.FDist(1, 6), getFStatistic(ex2BwtsWater, ex2BwtsDrugY))
"""
sco(s)
```

Hopefully, you remember that. OK, here is the task.

1) write a function `getLStatistic(v1::Vector{<:Real},
v2::Vector{<:Real})::Float64` that calculates the L-Statistic for
two given vectors
2) estimate the L-Distribution. To do that:

	2.1) run, let's say 1'000'000 simulations under $H_{0}$ that `v1` and `v2`
	come from the same population (`Dsts.Normal(25, 3)`, draw 4 observations
	per vector). Calculate the L-Statistic each time (round it to 1 decimal
	place with `round(getLStatistic(v1, v2), digits=1)`

	2.2) use `getCounts` (@sec:statistics_prob_theor_practice), `getProbs`
	(@sec:statistics_prob_theor_practice) and
	`getSortedKeysVals` (@sec:statistics_prob_distribution) to obtain the
	probabilities for each value of the L-Statistic produced in point 2.1

	2.3) based on the data from point 2.2 calculate the probability of
	L-Statistic being greater than `LStatisticEx2` =
	 `jl round(LStatisticEx2, digits=2)`.
	Compare the probability with the probability obtained for the F-Statistics
	(presented in the code snippets above)

3) using,
e.g. [Cmk.lines](https://docs.makie.org/stable/examples/plotting_functions/lines/index.html#lines) (`color="blue"`)
and the data from point 2.2 plot the probability distribution for the
L-Distribution
4) add vertical line, e.g with `Cmk.vlines` at L-Statistic = 1.28, annotate the
line with `Cmk.text`
5) check what happens if both the samples from point 2.1 come from a different
population (e.g. `Dsts.Normal(100, 50)`). Plot the new distribution on the old
one (point 3) with,
e.g. [Cmk.scatter](https://docs.makie.org/stable/examples/plotting_functions/scatter/index.html#scatter)
(`marker=:circle`, `color="blue"`).
6) check what happens if the samples from point 2.1 come from the same
distribution (`Dsts.Normal(25, 3)`) but are of different size (8 observations
per vector). Plot the new distribution on the old one (point 3) with,
e.g. `Cmk.scatter` (`marker=:xcross`, `color="blue"`).

*Optionally, if you want to make your plots more readable and if you like
challenges you may:*

7) add the F-Distribution to the plot, e.g. with `Cmk.lines` (`color="red"`)
8) add
[legends](https://docs.makie.org/stable/examples/blocks/legend/index.html#multi-group_legends)
to the plots

Again. This may look like a lot of work to do, but don't freak out, do it one
point at a time, look at the instructions (they are pretty precise on purpose).
If you get stuck, take a sneak peak at the solution and continue once you get
back on the track.

### Exercise 3 {#sec:compare_contin_data_ex3}

Let's cool down after the last two demanding exercises.

In this task I want you to write the function `getPValUnpairedTest(v1::Vector{<:Real},
v2::Vector{<:Real})::Float64`. The function accepts two vectors runs an unpaired test and returns the p-value.

The function should check the:

1) normality (`Pg.normality`), and
2) homogeneity of variance (`Htests.FlingerTest`)

assumptions.

If both the assumptions hold then run `Htests.EqualVarianceTTest`.

If only normality assumption holds then the `Htests.UnequalVarianceTTest`.

Otherwise run `Htests.MannWhitneyUTest`.

### Exercise 4 {#sec:compare_contin_data_ex4}

Write a function with the following signature

```
function getPValsUnpairedTests(
    df::Dfs.DataFrame
	)::Dict{Tuple{String,String},Float64}
```

The function accepts a data frame (like `miceBwtABC` we met in
@sec:compare_contin_data_post_hoc_tests). Then it runs the appropriate
comparisons (use `getPValUnpairedTest` that you developed in
@sec:compare_contin_data_ex3) and returns the p-values for comparisons in the
form of a dictionary where the keys are the names of the compared groups
(`Tuple{String, String}`), and the values are pvalues (e.g. `Dict(("grX", "grY")
=> 0.3, ("grX", "grZ") => 0.022)`. The function should compare every group with
every other group.

Once you are done with this task tweak your function slightly to have the
following signature

```
function getPValsUnpairedTests(
	df::Dfs.DataFrame,
	multCorr
	)::Dict{Tuple{String,String},Float64}
```

This function adjusts the obtained p-values using some sort of multiplicity
correction (`multCorr`) from `MultipleTesting` package we discussed before
(@sec:compare_contin_data_multip_correction).

Test your function on `miceBwtABC` and compare the results with those we
obtained in @sec:compare_contin_data_post_hoc_tests and in
@sec:compare_contin_data_multip_correction.

### Exercise 5 {#sec:compare_contin_data_ex5}

It appears that when a scientific paper presents a comparison between few groups
of continuous variables it does so in a form of bar-plot or
[box-plot](https://en.wikipedia.org/wiki/Box_plot) with some markers for
statistically significant differences over the bars/boxes.

So here is your task. For data from `miceBwtABC` from
@sec:compare_contin_data_post_hoc_tests write a function that draws a plot
similar to the one below (it doesn't have to be the exact copy).

![Boxplot of body mass of three mice species. a - difference vs. spA (p < 0.05), b - difference vs. spB (p < 0.05).](./images/ch05ex5boxplot.png){#fig:ch05ex5boxplot}

In the graph a middle horizontal line in a box is [the
median](https://en.wikipedia.org/wiki/Median), a box depicts [interquartile
range](https://en.wikipedia.org/wiki/Interquartile_range) (IQR), the whiskers
length is equal to 1.5 * IQR (or the maximum and minimum if they are smaller
than 1.5 * IQR).

For the task you may use:

- [Cmk.boxplot](https://docs.makie.org/stable/examples/plotting_functions/boxplot/index.html#boxplot) -
  to draw the boxplot
- [Cmk.xticks](https://docs.makie.org/stable/examples/blocks/axis/index.html#xticks) -
  to add group labels in x-ticks
- p-values provided by `getPValsUnpairedTests(miceBwtABC, Mt.BenjaminiHochberg)`
  from the last exercise to generate statistical significance markers.
- [Cmk.text](https://docs.makie.org/stable/examples/plotting_functions/text/index.html#text)
  to place the markers in the correct positions on the plot.

The function should also work for different data frames of similar kind with
different number of groups in the columns.

## Solutions - Comparisons of Continuous Data  {#sec:compare_contin_data_exercises_solutions}

In this sub-chapter you will find exemplary solutions to the exercises from the
previous section.

### Solution to Exercise 1 {#sec:compare_contin_data_ex1_solution}

First the sample and the 100'000 simulations:

```jl
s = """
Rand.seed!(321)
ex1sample = Rand.rand(Dsts.Normal(80, 20), 10)
ex1sampleSd = Stats.std(ex1sample)
ex1sampleSem = getSem(ex1sample)
ex1sampleMeans = [
    Stats.mean(Rand.rand(Dsts.Normal(80, 20), 10))
    for _ in 1:100_000]
ex1sampleMeansMean = Stats.mean(ex1sampleMeans)
ex1sampleMeansSd = Stats.std(ex1sampleMeans)
"""
sc(s)
```

The code doesn't contain any new elements, so I will leave it to you to figure
out what happened there.

And now, let's move to the plot.

```jl
s = """
fig = Cmk.Figure()
Cmk.hist(fig[1, 1], ex1sampleMeans, bins=100, color=Cmk.RGBAf(0, 0, 1, 0.3),
    axis=(;
        title="Histogram of 100'000 sample means",
        xlabel="Adult human body weight [kg]",
        ylabel="Count"))
Cmk.ylims!(0, 4000)
Cmk.vlines!(fig[1, 1], 80,
	ymin=0.0, ymax=0.85, color="black", linestyle=:dashdot)
Cmk.text!(fig[1, 1], 81, 1000, text="population mean = 80")
Cmk.bracket!(fig[1, 1],
    ex1sampleMeansMean - ex1sampleMeansSd / 2, 3500,
    ex1sampleMeansMean + ex1sampleMeansSd / 2, 3500,
    style=:square
)
Cmk.text!(fig[1, 1], 72.5, 3700,
    text="sample means sd = $(round(ex1sampleMeansSd, digits=2))")
Cmk.text!(fig[1, 1], 90, 3200,
    text="single sample sd = $(round(ex1sampleSd, digits=2))")
Cmk.text!(fig[1, 1], 90, 3000,
    text="single sample sem = $(round(ex1sampleSem, digits=2))")
fig
"""
sc(s)
```

This produces the following graph.

![Histogram of drawing 100'000 random samples from a population with $\mu = 80$ and $\sigma = 20$.](./images/histCh05Ex1.png){#fig:histCh05Ex1}

The graph clearly demonstrates that a better approximation of the samples means
sd is `sem` and not `sd` (as stated in @sec:compare_contin_data_one_samp_ttest).

I'm not gonna explain the code snippet above in great detail since this is a
warm up exercise, and [the tutorials](https://docs.makie.org/stable/tutorials/)
(e.g. the basic tutorial) and the documentation for the plotting functions (see
the links in @sec:compare_contin_data_ex1) are pretty good. Moreover, we already
used `CairoMakie` plotting functions in
@sec:statistics_prob_distribution. Still, a few quick notes are in order.

First of all, drawing a graph like that is not an enormous feat, you just need
some knowledge (you read the tutorial and the function docs, right?). The rest
is just patience and replication of the examples. Ah yes, I forgot about the try
and error process [that happens from time to time (OK, more often than I would
like to admit) in my case]. If an error happens, do not panic try to read the
error's message and think what it tells you).

It is always a good idea to annotate the graph, add the title, x- and y-axis
labels (to make the reader's, and your own, reasoning easier). Figures are
developed from top to bottom (in the code), layer after layer (top line of code
-> bottom layer, next line of code places a layer above the previous layer).
First function (`fig` and `Cmk.hist`) creates the figure, the following
functions (e.g. `Cmk.text!` and `Cmk.vlines`), write/paint something on the
previous layers. After some time and tweaking you should be able to produce
quite pleasing figures (just remember, patience is the key). One more point,
instead of typing strings by hand (like `text="sample sd = 17.32"`) you may let
Julia do that by using [strings
interpolation](https://docs.julialang.org/en/v1/manual/strings/#string-interpolation),
like `text="sample sd = $(round(ex1sampleSd, digits=2))"`(with time you will
appreciate the convenience of this method).

One more thing, the `:dashdot` (after the [keyword
argument](https://docs.julialang.org/en/v1/manual/functions/#Keyword-Arguments)
`linetype`) is a
[Symbol](https://docs.julialang.org/en/v1/manual/metaprogramming/#Symbols). For
now you may treat it like a string but written differently, i.e. `:dashdot`
instead of `"dashdot"`.

### Solution to Exercise 2 {#sec:compare_contin_data_ex2_solution}

First let's start with the functions we developed in @sec:statistics_intro (and
its subsections). We already now them, so I will not explain them here.

```
function getCounts(v::Vector{T})::Dict{T,Int} where {T}
    counts::Dict{T,Int} = Dict()
    for elt in v
        counts[elt] = get(counts, elt, 0) + 1
    end
    return counts
end

function getProbs(counts::Dict{T,Int})::Dict{T,Float64} where {T}
    total::Int = sum(values(counts))
    return Dict(k => v / total for (k, v) in counts)
end

function getSortedKeysVals(d::Dict{T1,T2})::Tuple{
    Vector{T1},Vector{T2}} where {T1,T2}
    sortedKeys::Vector{T1} = keys(d) |> collect |> sort
    sortedVals::Vector{T2} = [d[k] for k in sortedKeys]
    return (sortedKeys, sortedVals)
end
```

Now, time to define `getLstatistic` based on what we learned in
@sec:compare_contin_data_one_way_anova (note, the function uses
`getAbsGroupDiffsAroundOverallMean` and `getAbsPointDiffsFromGroupMeans` that we
developed in that section).

```jl
s = """
function getLStatistic(v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
    absDiffsOverallMean::Vector{<:Real} =
		getAbsGroupDiffsFromOverallMean(v1, v2)
    absDiffsGroupMean::Vector{<:Real} =
		getAbsPointDiffsFromGroupMeans(v1, v2)
    return Stats.mean(absDiffsOverallMean) / Stats.mean(absDiffsGroupMean)
end
"""
sc(s)
```

OK, that was easy, after all we practically did it all before, we only needed to
look for the components in the previous chapters. Now, the function to determine
the distribution.

```jl
s = """
function getLStatisticsUnderH0(
    popMean::Real, popSd::Real,
    nPerGroup::Int=4, nIter::Int=1_000_000)::Vector{Float64}

    v1::Vector{Float64} = []
    v2::Vector{Float64} = []
    result::Vector{Float64} = zeros(nIter)

    for i in 1:nIter
        v1 = Rand.rand(Dsts.Normal(popMean, popSd), nPerGroup)
        v2 = Rand.rand(Dsts.Normal(popMean, popSd), nPerGroup)
        result[i] = getLStatistic(v1, v2)
    end

    return result
end
"""
sc(s)
```

This one is slightly more complicated so I think a bit of explanation is in
order here. First we initialize some variables that we will use later. For
instance, `v1` and `v2` will hold random samples drawn from a population of
interest (`Dsts.Normal(popMean, popSd)`) and will change with each
iteration. The vector `result` is initialized with `0`s and will hold the
`LStatistic` calculated during each iteration for `v1` and `v2`. The result
vector is returned by the function. Later on we will be able to use it to
`getCounts` and `getProbs` for the L-Statistics. This should work just
fine. However, if we slightly modify our function (`getLStatisticsUnderH0`), we
could use it not only with the L-Statistic but also F-Statistic (optional points
in this task) or any other statistic of interest. Observe

```jl
s1 = """
# getXStatFn signature: fnName(::Vector{<:Real}, ::Vector{<:Real})::Float64
function getXStatisticsUnderH0(
    getXStatFn::Function,
    popMean::Real, popSd::Real,
    nPerGroup::Int=4, nIter::Int=1_000_000)::Vector{Float64}

    v1::Vector{Float64} = []
    v2::Vector{Float64} = []
    result::Vector{Float64} = zeros(nIter)

    for i in 1:nIter
        v1 = Rand.rand(Dsts.Normal(popMean, popSd), nPerGroup)
        v2 = Rand.rand(Dsts.Normal(popMean, popSd), nPerGroup)
        result[i] = getXStatFn(v1, v2)
    end

    return result
end
"""
sc(s1)
```

Here, instead of `getLStatisticsUnderH0` we named the function
`getXStatisticsUnderH0`, where `X` is any statistic we can come up with. The
function that calculates our statistic of interest is passed as a first
argument to `getXStatisticsUnderH0` (`getXStatFn`). The `getXStatFn` should work
just fine, if it accepts two vectors (`::Vector{<:Real}`) and returns `Float64`
(the statistic) of interest. Both those assumptions are fulfilled by
`getLStatistic` (defined above) and `getFStatistic` defined in
@sec:compare_contin_data_one_way_anova. To use our `getXStatisticsUnderH0` we
would type, e.g.: `getXStatisticsUnderH0(getLStatistic, 25, 3, 4)` instead of
`getLStatisticsUnderH0(25, 3, 4)` that we would have used for
`getLStatisticsUnderH0` defined above (more typing, but greater flexibility,
and the result would be the same).

Now, to get a distribution of interest we use the following function

```jl
s = """
# getXStatFn signature: fnName(::Vector{<:Real}, ::Vector{<:Real})::Float64
function getXDistUnderH0(getXStatFn::Function,
    mean::Real, sd::Real,
    nPerGroup::Int=4, nIter::Int=10^6)::Dict{Float64,Float64}

    xStats::Vector{<:Float64} = getXStatisticsUnderH0(
        getXStatFn, mean, sd, nPerGroup, nIter)
    xStats = round.(xStats, digits=1)
    xCounts::Dict{Float64,Int} = getCounts(xStats)
    xProbs::Dict{Float64,Float64} = getProbs(xCounts)

    return xProbs
end
"""
sc(s)
```

First, we calculate the statistics of interest (`xStats`), then we round the
statistics to a 1 decimal point (`round.(xStats, digits=1)`). This is necessary,
since in a moment we will use `getCounts` so we need some repetitions in our
`xStats` vector (e.g. 1.283333331 and 1.283333332 will, both get rounded to 1.3
and the count for this value of the statistic will be 2). Once we got the
counts, we change them to probabilities (fraction of times that the given value
of the statistic occurred) with `getProbs`.

Now we can finally, use them to estimate the probability that the L-statistic
greater than `LStatisticEx2` = `jl round(LStatisticEx2, digits=2)` occurred by
chance.

```jl
s = """
Rand.seed!(321)
lprobs = getXDistUnderH0(getLStatistic, 25, 3)
lprobsGTLStatisticEx2 = [v for (k, v) in lprobs if k > LStatisticEx2]
lStatProb = sum(lprobsGTLStatisticEx2)
"""
sco(s)
```

Here, we used a comprehension with `if`. So, for every key-value pair (`(k, v)`)
that is in `lprobs` we choose only those whose key (LStatistic) is greater than
`LStatisticEx2` (`if k > LStatisticEx2`). In the last step we take only value
(`[v`) from the pair (the value is the probability of such LStatistic happening
by chance alone) to our result `lprobsGTLStatisticEx2`.

The estimated probability for our L-Statistic is `jl round(lStatProb, digits=3)`
which is pretty close to the probability obtained for the F-Statistic
(`Htests.OneWayANOVATest(ex2BwtsWater, ex2BwtsDrugY) |> Htests.pvalue` =
 `jl Htests.OneWayANOVATest(ex2BwtsWater, ex2BwtsDrugY) |> Htests.pvalue |> x -> round(x, digits=3)`)
(and well it should).

In virtually the same way we can get the experimental probability of an
F-statistic being greater than `getFStatistic(ex2BwtsWater, ex2BwtsDrugY)` =
 `jl round(getFStatistic(ex2BwtsWater, ex2BwtsDrugY), digits=2)` by chance.
 Observe

```jl
s = """
Rand.seed!(321)
cutoffFStat = getFStatistic(ex2BwtsWater, ex2BwtsDrugY)
fprobs = getXDistUnderH0(getFStatistic, 25, 3)
fprobsGTFStatisticEx2 = [v for (k, v) in fprobs if k > cutoffFStat]
fStatProb = sum(fprobsGTFStatisticEx2)
"""
sco(s)
```

Again, the p-value is quite similar to the one we got from a formal
`Htests.OneWayANOVATest` (as it should be).

OK, now it's time to draw some plots. First, let's get the values for x- and
y-axes

```jl
s = """
Rand.seed!(321)
# L distributions
lxs1, lys1 = getXDistUnderH0(getLStatistic, 25, 3) |> getSortedKeysVals
lxs2, lys2 = getXDistUnderH0(getLStatistic, 100, 50) |> getSortedKeysVals
lxs3, lys3 = getXDistUnderH0(getLStatistic, 25, 3, 8) |> getSortedKeysVals
# F distribution
fxs1, fys1 = getXDistUnderH0(getFStatistic, 25, 3) |> getSortedKeysVals
"""
sc(s)
```

No, big deal L-Distributions start with `l`, the classical F-Distribution starts
with `f`. BTW. Notice that thanks to `getXDistUnderH0` we didn't have to write
two almost identical functions (`getLDistUnderH0` and `getFDistUnderH0`).

OK, let's place them on the graph

```jl
s = """
fig = Cmk.Figure()
ax1, l1 = Cmk.lines(fig[1, 1], fxs1, fys1, color="red",
    axis=(;
        title="F-Distribution (red) and L-Distribution (blue)",
		xlabel="Value of the statistic",
        ylabel="Probability distribution"))
l2 = Cmk.lines!(fig[1, 1], lxs1, lys1, color="blue")
sc1 = Cmk.scatter!(fig[1, 1], lxs2, lys2, color="blue", marker=:circle)
sc2 = Cmk.scatter!(fig[1, 1], lxs3, lys3, color="blue", marker=:xcross)
Cmk.vlines!(fig[1, 1], LStatisticEx2, color="lightblue", type=:dashdot)
Cmk.text!(fig[1, 1], 1.35, 0.1,
	text="L-Statistic = $(round(LStatisticEx2, digits=2))")
Cmk.xlims!(0, 4)
Cmk.ylims!(0, 0.25)
Cmk.axislegend(ax1,
    [l1, l2, sc1, sc2],
    [
	"F-Statistic(1, 6) [Dsts.Normal(25, 3), n = 4]",
	"L-Statistic [Dsts.Normal(25, 3), n = 4]",
    "L-Statistic [Dsts.Normal(100, 50), n = 4]",
	"L-Statistic [Dsts.Normal(25, 3), n = 8]"
	],
    "Distributions\n(num groups = 2,\nn - num observations per group)",
	position=:rt)
fig
"""
sc(s)
```

Behold

![Experimental F- and L-Distributions.](./images/fAndLDistCh05Ex2.png){#fig:fAndLDistCh05Ex2}

Wow, what a beauty.

A few points of notice. Before, we calculated the probability (`lStatProb`) of
getting the L-Statistic value greater than the vertical light blue line (the
area under the blue curve to the right of that line). This is a one tail
probability only. Interestingly, for the L-Distribution the mean and sd in the
population of origin are not that important (blue circles for `Dsts.Normal(100,
50)` lie exactly on the blue line for `Dsts.Normal(25, 3)`). However, the number
of groups and the number of observations per group affect the shape of the
distribution (blue xcrosses for `Dsts.Normal(25, 3) n = 8` diverge from the blue
curve for `Dsts.Normal(25, 3) n = 4`).

The same is true for the F-Distribution. That is why the F-Distribution depends
only on the degrees of freedom (`Dsts.FDist(dfGroup, dfResidual)`). The degrees
of freedom depend on the number of groups and the number of observations per
group.

### Solution to Exercise 3 {#sec:compare_contin_data_ex3_solution}

OK, let's start with functions for checking the assumptions

```jl
s = """
function areAllDistributionsNormal(vects::Vector{<:Vector{<:Real}})::Bool
    return [Pg.normality(v).pval[1] for v in vects] |>
		pvals -> map(pv -> pv > 0.05, pvals) |>
		all
end

function areAllVariancesEqual(vects::Vector{<:Vector{<:Real}})
	return Htests.FlignerKilleenTest(vects...) |>
		Htests.pvalue |> pv -> pv > 0.05
end
"""
sc(s)
```

The functions above are basically just wrappers around the code we wrote in
@sec:compare_contin_data_post_hoc_tests. Now, time for `getPValUnpairedTest`

```jl
s = """
function getPValUnpairedTest(
	v1::Vector{<:Real}, v2::Vector{<:Real})::Float64

	normality::Bool = areAllDistributionsNormal([v1, v2])
	homogeneity::Bool = areAllVariancesEqual([v1, v2])

	return (
		(normality && homogeneity) ? Htests.EqualVarianceTTest(v1, v2) :
		(normality) ? Htests.UnequalVarianceTTest(v1, v2) :
		Htests.MannWhitneyUTest(v1,v2)
		) |> Htests.pvalue
end
"""
sc(s)
```

The code is rather self-explanatory, of course if you remember the ternary
expression from @sec:ternary_expression and
@sec:julia_language_exercise4_solution.

Let's test our newly created function with the data from
@sec:compare_contin_data_unpaired_ttest (`miceBwt`)

```jl
s = """
getPValUnpairedTest([miceBwt[!, n] for n in Dfs.names(miceBwt)]...) |>
x -> round(x, digits=4)
"""
sco(s)
```

The p-value is the same as in @sec:compare_contin_data_unpaired_ttest (as it
should be), but this time we didn't have to explicitly check the assumptions
before applying the appropriate test.

### Solution to Exercise 4 {#sec:compare_contin_data_ex4_solution}

First, let's start with a helper function that will return us all the possible
pairs from a vector.

```jl
s = """
function getUniquePairs(names::Vector{T})::Vector{Tuple{T,T}} where {T}

	@assert (length(names) >= 2) "the input must be of length >= 2"

    uniquePairs::Vector{Tuple{T,T}} =
        Vector{Tuple{T,T}}(undef, binomial(length(names), 2))
    currInd::Int = 1

    for i in eachindex(names)[1:(end-1)]
        for j in eachindex(names)[(i+1):end]
            uniquePairs[currInd] = (names[i], names[j])
            currInd += 1
        end
    end

    return uniquePairs
end
"""
sc(s)
```

The function is generic, so it can be applied to vector of any type (`T`), here
designed as `Vector{T}`. It starts by initializing an empty vector
(`uniquePairs`) to hold the results. The initialization takes the following
form: `Vector{typeOfVectElements}(iniaialValues, lengthOfTheVector)`. The vector
is filled with `undef`s (undefined values, some garbage) as placeholders. The
size of the new vector is calculated by the
[binomial](https://docs.julialang.org/en/v1/base/math/#Base.binomial)
function. It is applied in the form `binomial(n, k)` where `n` is number of
values to choose from and `k` is number of values per gruop. The function
returns the number of possible groups of a given size. The rest is just
iteration (`for` loops) over the indexes (`eachindex`) of the `names` vector to
get all the possible pairs. Let's quickly check if the function works as
expected.

```jl
s = """
(
	getUniquePairs([10, 20]),
	getUniquePairs([1.1, 2.2, 3.3]),
	getUniquePairs(["w", "x", "y", "z"]),
)
"""
replace(sco(s), "]," => "],\n")
```

OK, now it's time for `getPValsUnpairedTests`

```jl
s = """
# df - DataFrame: each column continuous variable
# returns uncorrected p-values
function getPValsUnpairedTests(
    df::Dfs.DataFrame)::Dict{Tuple{String,String},Float64}

    pairs::Vector{Tuple{String,String}} = getUniquePairs(Dfs.names(df))
    pvals::Vector{Float64} = [
        getPValUnpairedTest(df[!, a], df[!, b])
        for (a, b) in pairs
    ]

    return Dict(pairs[i] => pvals[i] for i in eachindex(pairs))
end
"""
sc(s)
```

First, we obtain the pairs of group names that we will compare later
(`pairs`). In the next few lines we use comprehension to obtain the
p-values.  Since each element of `pairs` vector is a tuple (e.g. `[("spA",
"spB"), etc.]`) we assign its elements to `a` and `b` (`for (a, b)`) and pass
them to `df` to get the values of interest (e.g. `df[!, a]`). The values are
send to `getPValUnpairedTest` from the previous section. We terminate (`return`)
with another comprehension that creates a dictionary with the desired result.

Let's see how the function works and compare the results with the ones we
obtained in @sec:compare_contin_data_post_hoc_tests.

```jl
s = """
getPValsUnpairedTests(miceBwtABC)
"""
sco(s)
```

OK, the uncorrected p-values are the same as in
@sec:compare_contin_data_post_hoc_tests.

Now, the improved version.

```jl
s1 = """
# df - DataFrame: each column continuous variable
# returns corrected p-values
function getPValsUnpairedTests(
    df::Dfs.DataFrame,
    multCorr::Type{M}
)::Dict{Tuple{String,String},Float64} where {M<:Mt.PValueAdjustment}

    pairs::Vector{Tuple{String,String}} = getUniquePairs(Dfs.names(df))
    pvals::Vector{Float64} = [
        getPValUnpairedTest(df[!, a], df[!, b])
        for (a, b) in pairs
    ]
    pvals = Mt.adjust(pvals, multCorr())

    return Dict(pairs[i] => pvals[i] for i in eachindex(pairs))
end
"""
sc(s1)
```

Don't worry about the strange type declarations like `::Type{M}` and `where
{M<:Mt.PValueAdjustment}`. I added them for the sake of consistency (after
reading the code in [the package
repo](https://github.com/juliangehring/MultipleTesting.jl) and some try and
error). When properly called, the function should work equally well without
those parts.

Anyway, it wasn't that bad, we basically just added a small piece of code
(`multCorr` in the arguments list and `pvals = Mt.adjust(pvals, multCorr())` in
the function body) similar to the one in
@sec:compare_contin_data_multip_correction.

Let's see how it works.

```jl
s = """
# Bonferroni correction
getPValsUnpairedTests(miceBwtABC, Mt.Bonferroni)
"""
sco(s)
```

That looks quite alright. Time for one more swing.

```jl
s = """
# Benjamini-Hochberg correction
getPValsUnpairedTests(miceBwtABC, Mt.BenjaminiHochberg)
"""
sco(s)

```
Again, the p-values appear to be the same as those we saw in
@sec:compare_contin_data_multip_correction.

### Solution to Exercise 5 {#sec:compare_contin_data_ex5_solution}

OK, let's do this step by step. First let's draw a bare box-plot (no group
names, no significance markers, titles, etc.).

The docs for
[Cmk.boxplot](https://docs.makie.org/stable/examples/plotting_functions/boxplot/index.html#boxplot)
show that to do that we need two vectors for xs and ys (values to be placed on
the x- and y-axis respectively). Both need to be of numeric types. We can
achieve it by typing, e.g.

```jl
s = """
# Step 1
ex5nrows = size(miceBwtABC)[1] #1
ex5names = Dfs.names(miceBwtABC) #2
ex5xs = repeat(eachindex(ex5names), inner=ex5nrows) #3
ex5ys = [miceBwtABC[!, n] for n in ex5names] #4
ex5ys = vcat(ex5ys...) #5

Cmk.boxplot(ex5xs, ex5ys)
"""
sc(s)
```

In the first line (`#1`) we get the dimensions of our data frame,
`size(miceBwtABC)` returns a tuple `(numberOfRows, numberOfColumns)` from which
we take only the first part (`numberOfRows`) that we will need later. In line 3
(`#3`) we assign a number to the names (`eachindex(vect)` returns a sequence
`1:length(vect)`, e.g. `[1, 2, 3]`). We multiply each number the same amount of
times (`ex5nrows`) using `repeat` (e.g. `repeat([1, 2, 3], inner=2)` returns
`[1, 1, 2, 2, 3, 3]`). In line 4 and 5 (`#4` and `#5`) we take all the body
weights from columns and put them into a one long vector (`ex5ys`). We end up
with two vectors: groups coded as integers and body weights. Finally, we check
if it works by running `Cmk.boxplot(ex5xs, ex5ys)`. The result is below.

![Box-plot for exercise 5. Step 1.](./images/ch05ex5step1.png){#fig:ch05ex5step1}

Now, let's add title, label the axis, etc.

```jl
s = """
# Step 2
fig = Cmk.Figure()
Cmk.Axis(fig[1, 1], xticks=(eachindex(ex5names), ex5names),
    title="Body mass of three mice species",
    xlabel="species name", ylabel="body mass [g]")
Cmk.boxplot!(fig[1, 1], ex5xs, ex5ys)
fig
"""
sc(s)
```

The only new part here is the `xticks` argument. It takes a tuple of ticks on x
axis (`1:3` in @fig:ch05ex5step1) and a vector of strings (`ex5names`) to be
displayed instead of those values. The result is seen below.

![Box-plot for exercise 5. Step 2.](./images/ch05ex5step2.png){#fig:ch05ex5step2}

Let's move on to the significance markers. First, let's hard-code them and
produce a plot (just to see if it works), then we will introduce some
improvements.

```jl
s = """
# Step 3
fig = Cmk.Figure()
Cmk.Axis(fig[1, 1], xticks=(eachindex(ex5names), ex5names),
    title="Body mass of three mice species",
    xlabel="species name", ylabel="body mass [g]")
Cmk.boxplot!(fig[1, 1], ex5xs, ex5ys)
Cmk.text!(fig[1, 1],
	eachindex(ex5names), [30, 30, 30],
	text=["", "a", "ab"],
    align=(:center, :top), fontsize=20)
fig
"""
sc(s)
```

OK, we're almost there (see figure below).

![Box-plot for exercise 5. Step 3.](./images/ch05ex5step3.png){#fig:ch05ex5step3}

However, it appears that we still need a few things:

1) a way to generate y-values for `Cmk.text!` (for now it is `[30, 30, 30]`, but
other dataframe may have different value ranges, e.g. [200-250], then the
markers would be placed too low)
2) a way to generate the markers (`["", "a", "ab"]` based on p-values) over the
appropriate boxes

The first problem can be solved in the following way:

```jl
s = """
# Step 4
ex5marksYpos = [maximum(miceBwtABC[!, n]) for n in ex5names] #1
ex5marksYpos = map(mYpos -> round(Int, mYpos * 1.1), ex5marksYpos) #2
ex5upYlim = maximum(ex5ys * 1.2) |> x -> round(Int, x) #3
ex5downYlim = minimum(ex5ys * 0.8) |> x -> round(Int, x) #4
"""
sc(s)
```

Here, in the first line (`#1`) we get maximum values from every group. Then
(`#2`) we increase them by 10% (`* 1.1`) and round them to the closest integers
(`round(Int, `). At this height (y-axis) we are going to place our significance
markers. Additionally, in lines 3 and 4 (`#3` and `#4`) we found the maximum and
minimum values in all groups. We increase (`* 1.2`) and decrease (`* 0.8`) the
values by 20%. The rounded (to the nearest integer) values will be the maximum
and minimum values displayed on the y-axis of our graph.

Now, time for a function that will translate p-values to significance markers.

```jl
s = """
# Step 5
function getMarkers(
    pvs::Dict{Tuple{String,String},Float64},
    groupsOrder=["spA", "spB", "spC"],
    markerTypes::Vector{String}=["a", "b", "c"],
    cutoffAlpha::Float64=0.05)::Vector{String}

    @assert (
        length(groupsOrder) == length(markerTypes)
    ) "different groupSOrder and markerTypes lengths"
    @assert (0 <= cutoffAlpha <= 1) "cutoffAlpha must be in range [0-1]"

    markers::Vector{String} = repeat([""], length(groupsOrder))
    tmpInd::Int = 0

    for i in eachindex(groupsOrder)
        for ((g1, g2), pv) in pvs
            if (groupsOrder[i] == g1) && (pv <= cutoffAlpha)
                tmpInd = findfirst(x -> x == g2, groupsOrder)
                markers[tmpInd] *= markerTypes[i]
            end
        end
    end

    return markers
end
"""
sc(s)
```

Here, `getMarkers` accepts p-values in the format returned by
`getPValsUnpairedTests` defined in
@sec:compare_contin_data_ex4_solution. Another input argument is `groupsOrder`
which contains the position of groups (boxes, x-axis labels) in
@fig:ch05ex5step3 from left to right. The third argument is `makrerTypes` so a
symbol that is to be used if a statistical difference for a given group is
found.

The function defines `markers` (the strings placed over each box with `Cmk.txt`)
initialized with a vector of empty strings. Next, it walks through each index in
group (`eachindex(groups)`) and checks the `((g1, g2), pv)` in p-values
(`pvs`). If `g1` is equal to the examined group (`groups[i] == g1`) and the
p-value (`pv`) is $\le$ the cutoff level then the appropriate marker
(`markerTypes[i]`) is inserted by [string
concatenation](https://docs.julialang.org/en/v1/manual/strings/#man-concatenation)
with an [update
operator](https://docs.julialang.org/en/v1/manual/mathematical-operations/#Updating-operators)
(`*=`). Which
maker to change is determined by the index of `g2` in the `groups` returned by
[findfirst](https://docs.julialang.org/en/v1/base/strings/#Base.findfirst-Tuple{AbstractString,%20AbstractString})
function. In general, `g2` receives a marker when it is statistically different
from `g1` (`pv < cutoffAlpha`).

Let's test our function

```jl
s = """
(
getMarkers(
    getPValsUnpairedTests(miceBwtABC, Mt.BenjaminiHochberg),
    ["spA", "spB", "spC"],
    ["a", "b", "c"],
    0.05),

getPValsUnpairedTests(miceBwtABC, Mt.BenjaminiHochberg)
)
"""
replace(sco(s), "Dict" => "\nDict", r"[0-9], " => ",\n")
```

The markers appear to be OK (they reflect the p-values well).

Now, it is time to pack it all into a separate function

```jl
s = """
# Step 6

# the function should work fine for up to 26 groups in the df's columns
function drawBoxplot(
    df::Dfs.DataFrame, title::String,
    xlabel::String, ylabel::String)::Cmk.Figure

    nrows, _ = size(df)
    ns::Vector{String} = Dfs.names(df)
    xs = repeat(eachindex(ns), inner=nrows)
    ys = [df[!, n] for n in ns]
    ys = vcat(ys...)
    marksYpos = [maximum(df[!, n]) for n in ns]
    marksYpos = map(mYpos -> round(Int, mYpos * 1.1), marksYpos)
    upYlim = maximum(ys * 1.2) |> x -> round(Int, x)
    downYlim = minimum(ys * 0.8) |> x -> round(Int, x)
    alphabet::String = "abcdefghijklmnopqrstuvwxyz"
    markerTypes::Vector{String} = split(alphabet, "")
    markers::Vector{String} = getMarkers(
        getPValsUnpairedTests(df, Mt.BenjaminiHochberg),
        ns,
        markerTypes[1:length(ns)],
        0.05
    )

    fig = Cmk.Figure()
    Cmk.Axis(fig[1, 1], xticks=(eachindex(ns), ns),
        title=title,
        xlabel=xlabel, ylabel=ylabel)
    Cmk.boxplot!(fig[1, 1], xs, ys)
    Cmk.ylims!(downYlim, upYlim)
    Cmk.text!(fig[1, 1],
        eachindex(ns), marksYpos,
        text=markers,
        align=(:center, :top), fontsize=20)

    return fig
end
"""
sc(s)
```

and run it

```jl
s = """
drawBoxplot(miceBwtABC,
    "Body mass of three mice species",
    "species name",
    "body mass [g]"
)
"""
sc(s)
```

And voilà this is your result

![Boxplot of body mass of three mice species. Steps 1-6 (completed). a - difference vs. spA (p < 0.05), b - difference vs. spB (p < 0.05).](./images/ch05ex5step4.png){#fig:ch05ex5step4}

Once again (we said this already in the task description see
@sec:compare_contin_data_ex5). In the graph above a middle horizontal line in a
box is [the median](https://en.wikipedia.org/wiki/Median), a box depicts
[interquartile range](https://en.wikipedia.org/wiki/Interquartile_range) (IQR),
the whiskers length is equal to 1.5 * IQR (or the maximum and minimum if they
are smaller than 1.5 * IQR).

You could make the function more plastic, e.g. by moving some of its insides to
its argument list. But this form will do for now. You may want to test the
function with some other output, even with `miceBwt` from
@sec:compare_contin_data_two_samp_ttest (here it should draw a box-plot with no
statistical significance markers).

> **_Note:_** The code we developed in the exercises
> (e.g. `getPValsUnpairedTests`, `drawBoxplot`) is to help us automate stuff,
> still it shouldn't be applied automatically (think before you leap).
