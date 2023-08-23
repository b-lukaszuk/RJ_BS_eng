# Comparisons - continuous data {#sec:compare_contin_data}

OK, we finished the previous chapter with hypothesis testing and calculating probabilities for binomial data (`bi` - two `nomen` - name), e.g. number of successes (wins of Peter in tennis).

In this chapter we are going to explore comparisons between the groups containing data in a continuous scale (like the height from @sec:statistics_normal_distribution).

## Chapter imports {#sec:compare_contin_data_imports}

Later in this chapter we are going to use the following libraries

```jl
s = """
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import Distributions as Dsts
import HypothesisTests as Htests
import Pingouin as Pg
import Statistics as Stats
"""
sc(s)
```

If you want to follow along you should have them installed on your system. A reminder of how to deal (install and such) with packages can be found [here](https://docs.julialang.org/en/v1/stdlib/Pkg/). But wait, you may prefer to use `Project.toml` and `Manifest.toml` files from the [code snippets for this chapter](https://github.com/b-lukaszuk/RJ_BS_eng/tree/main/code_snippets/ch05) to install the required packages. The instructions you will find [here](https://pkgdocs.julialang.org/v1/environments/).

The imports will be in in the code snippet when first used, but I thought it is a good idea to put them here, after all imports should be at the top of your file (so here they are at top of the chapter). Moreover, that way they will be easier to find all in one place.

## One sample Student's t-test {#sec:compare_contin_data_one_samp_ttest}

Imagine that in your town there is a small local brewery that produces quite expensive but super tasty beer. You like it a lot, but you got an impression that the producer is not being honest with their customers and instead of the declared 500 [mL] of beer per bottle, he pours a bit less. Still, there is little you can do to prove it. Or can you?

You bought 10 bottles of beer (ouch, that was expensive!) and measured the volume of fluid in each of them. The results are as follows

```jl
s = """
# a representative sample
beerVolumes = [504, 477, 484, 476, 519, 481, 453, 485, 487, 501]
"""
sc(s)
```

On a graph the volume distribution looks like this (it was drawn with [Cmk.hist](https://docs.makie.org/stable/examples/plotting_functions/hist/index.html#hist) function).

![Histogram of beer volume distribution for 10 beer.](./images/histBeerVolume.png){#fig:histBeerVolume}

You look at it and it seems to resemble a bit the bell shaped curve that we discussed in the @sec:statistics_normal_distribution. This makes sense. Imagine your task is to pour let's say 1'000 bottles daily with 500 [mL] of beer in each with a big mug. Most likely the volumes would oscillate around your goal volume of 500 [mL], but they would not be exact. Sometimes in a hurry you would add a bit more, sometimes a bit less (you could not waste time to correct it). So it seems like a reasonable assumption that the 1'000 bottles from our example would have a roughly bell shaped (aka normal) distribution of volumes around the mean.

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

Hmm, on average there was `jl meanBeerVol` [mL] of beer per bottle, but the spread of the data around the mean is also considerable (sd = `jl round(stdBeerVol, digits=2)` [mL]). The lowest value measured was `jl minimum(beerVolumes)` [mL], the highest value measured was `jl maximum(beerVolumes)` [mL]. Still, it seems that there is less beer per bottle than expected but is it enough to draw a conclusion that the real mean in the population of our 1'000 bottles is ≈ `jl round(meanBeerVol, digits=0)` [mL] and not 500 [mL] as it should be? Let's try to test that using what we already know about the normal distribution (see @sec:statistics_normal_distribution), the three sigma rule (@sec:statistics_intro_three_sigma_rule) and the `Distributions` package (@sec:statistics_intro_distributions_package).

Let's assume for a moment that the true mean for volume of fluid in the population of 1'000 beer bottles is `meanBeerVol` = `jl meanBeerVol` [mL] and the true standard deviation is `stdBeerVol` = `jl round(stdBeerVol, digits=2)` [mL]. That would be great because now, based on what we've learned in @sec:statistics_intro_distributions_package we can calculate the probability that a random bottle of beer got >500 [mL] of fluid (or % of beer bottles in the population that contain >500 [mL] of fluid). Let's do it

```jl
s = """
import Distributions as Dsts

# how many std. devs is value above or below the mean
function getZScore(mean::Real, sd::Real, value::Real)::Float64
	return (value - mean)/sd
end

expectedBeerVolmL = 500

fractionBeerLessEq500mL = Dsts.cdf(Dsts.Normal(),
	getZScore(meanBeerVol, stdBeerVol, expectedBeerVolmL))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL
"""
sco(s)
```

I'm not going to explain the code above since for reference you can always check @sec:statistics_intro_distributions_package. Still, under those assumptions roughly 0.23 or 23% of beer bottles contain more than 500 [mL] of fluid. In other words under these assumptions the probability that a random beer bottle contains >500 [mL] of fluid is 0.23 or 23%.

There are 2 problems with that solution.

**Problem 1**

It is true that the mean from the sample is our best estimate of the mean in the population (here 1'000 beer bottles poured daily). However, statisticians proved that instead of the standard deviation from our sample we should use the [standard error of the mean](https://en.wikipedia.org/wiki/Standard_error). It describes the spread of sample means around the true population mean and it can be calculated as follows

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
	getZScore(meanBeerVol, getSem(beerVolumes), expectedBeerVolmL))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL
"""
sco(s)
```

Under those assumptions the probability that a beer bottle contains >500 [mL] of fluid is roughly 0.01 or 1%.

So, to sum up. Here, we assumed that the true mean in the population is our sample mean ($\mu$ = `meanBeerVol`). Next, if we were to take many small samples like `beerVolumes` and calculate their means then they would be normally distributed around the population mean (here $\mu$ = `meanBeerVol`) with $\sigma$ (standard deviation in the population) = `getSem(beerVolumes)`. Finally, using the three sigma rule (see @sec:statistics_intro_three_sigma_rule) we check if our hypothesized mean (`expectedBeerVolmL`) lies within roughly 2 standard deviations (here approximately 2 `sem`s) from the assumed population mean (here $\mu$ = `meanBeerVol`).

**Problem 2**

The sample size is small (`length(beerVolumes)` = `jl length(beerVolumes)`) so the underlying distribution is quasi-normal. It is called a [t-distribution](https://en.wikipedia.org/wiki/Student%27s_t-distribution) (for comparison of an exemplary normal and t-distribution see the figure below). Therefore to get a better estimate of the probability we should use the distribution.

![Comparison of normal and t-distribution with 4 degrees of freedom (df = 4).](./images/normDistTDist.png){#fig:normDistTDist}

Luckily our `Distributions` package got the t-distribution included (see [the docs](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.TDist)). As you remember the normal distribution required two parameters that described it: the mean and the standard deviation. The t-distribution requires [degrees of freedom](https://en.wikipedia.org/wiki/Degrees_of_freedom_(statistics)). The concept is fairly easy to understand. Imagine that we recorded body masses of 3 people in the room: Paul, Peter, and John.

```jl
s = """
peopleBodyMassesKg = [84, 94, 78]

sum(peopleBodyMassesKg)
"""
sco(s)
```

As you can see the sum of those body masses is `jl sum(peopleBodyMassesKg)` [kg].
Notice however that only two of those masses are independent or free to change. Once we know any two of the body masses (e.g. 94, 78) and the sum: `jl sum(peopleBodyMassesKg)`, then the third body mass must be equal to `sum(peopleBodyMassesKg) - 94 - 78` = `jl sum(peopleBodyMassesKg) - 94 - 78` (it is determined, it cannot just freely take any value). So in order to calculate the degrees of freedom we type `length(peopleBodyMassesKg) - 1` = `jl length(peopleBodyMassesKg) - 1`. Since our sample size is equal to `length(beerVolumes)` = `jl length(beerVolumes)` then it will follow a t-distribution with `length(beerVolumes) - 1` = `jl length(beerVolumes) - 1` degrees of freedom.

So the probability that a beer bottle contains >500 [mL] of fluid is

```jl
s = """
function getDf(vect::Vector{<:Real})::Int
	return length(vect) - 1
end

fractionBeerLessEq500mL = Dsts.cdf(Dsts.TDist(getDf(beerVolumes)),
	getZScore(meanBeerVol, getSem(beerVolumes), expectedBeerVolmL))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL
"""
sco(s)
```
> **_Note:_** The z-score (number of standard deviations above the mean) for a t-distribution is called t-score or t-statistics (it is calculated with sem instead of sd).

Finally, we got the result. Based on our representative sample (`beerVolumes`) and the assumptions we made we can see that the probability that a random beer contains >500 [mL] of fluid (500 [mL] is stated on a label) is `fractionBeerAbove500mL` = 0.022 or 2.2% (remember, this is one-tailed probability, the two-tailed probability is 0.022 * 2 = 0.044 = 4.4%).

Given that the cutoff level for $\alpha$ (type I error) from @sec:statistics_intro_errors is 0.05 we can reject our $H_{0}$ (the assumption that 500 [mL] comes from the population with the mean approximated by $\mu$ = `meanBeerVol` = `jl meanBeerVol` [mL] and the standard deviation approximated by $\sigma$ = `sem` = `jl round(getSem(beerVolumes), digits=2)` [mL]).

In conclusion, our hunch was right ("...you got an impression that the producer is not being honest with their customers..."). The owner of the local brewery is dishonest and intentionally pours slightly less beer (on average `expectedBeerVolmL - meanBeerVol` = `jl round(expectedBeerVolmL - meanBeerVol, digits=0)` [mL]). Now we can go to him and get our money back, or alarm the proper authorities for that monstrous crime. *Fun fact: the story has it that the [code of Hammurabi](https://en.wikipedia.org/wiki/Code_of_Hammurabi) (circa 1750 BC) was the first to punish for diluting a beer with water (although it seems to be more of a legend).* Still, this is like 2-3% beer (≈13/500 = 0.026) in a bottle less than it should be and the two-tailed probability (`fractionBeerAbove500mL * 2` = `jl round(fractionBeerAbove500mL * 2, digits=3)`) is not much less than the cutoff for type 1 error equal to 0.05 (we may want to collect a bigger sample and change the cutoff to 0.01).

### HypothesisTests package {#sec:compare_contin_data_hypo_tests_package}

The above paragraphs were to further your understanding of the topic. In practice you can do this much faster using [HypothesisTests](https://juliastats.org/HypothesisTests.jl/stable/) package.

In our beer example you could go with this short snippet (see [the docs](https://juliastats.org/HypothesisTests.jl/stable/parametric/#t-test) for `Htests.OneSampleTTest`)

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
getZScore(meanBeerVol, getSem(beerVolumes), expectedBeerVolmL),# t-statistic
getDf(beerVolumes), # degrees of freedom
getSem(beerVolumes) # empirical standard error
)
"""
sco(s)
```

The numbers are pretty much the same (and they should be if the previous explanation was right). The t-statistic is positive in our case because `getZScore` subtracts `mean` from `value` (`value - mean`) and some packages (like `HypothesisTests`) swap the numbers.

The value that needs to be additionally explained is the [95% confidence interval](https://en.wikipedia.org/wiki/Confidence_interval) from the output of `HypothesisTests` above. All it means is that: if we were to run our experiment with 10 beers 100 times and calculate 95% confidence intervals 100 times then 95 of the intervals would contained the true mean from the population. Sometimes people simplify it and say that this interval [in our case (473.8, 499.6)] contains the true mean from the population with probability of 95% (but that isn't necessarily the same what was stated in the previous sentence). The narrower interval means better, more precise estimate. If the difference is statistically significant (p-value < 0.05) then the interval should not contain the postulated mean (as in our case).

Notice that in our case the obtained 95% interval (473.8, 499.6) may indicate that the true average volume of fluid in a bottle of beer could be as high as 499.6 [mL] (so this would hardly make a practical difference) or as low as 473.8 [mL] (a small, ~6%, but a practical difference). In the case of our beer example it is just a curious fact, but imagine you are testing a new drug lowering the 'bad cholesterol' (LDL-C) level (the one that was mentioned in @sec:statistics_intro_exercise5_solution). Let's say you got a 95% confidence interval for the reduction of (-132, +2). The interval encompasses 0, so the true effect may be 0 and you cannot reject $H_{0}$ under those assumptions (p-value would be > 0.05). However, the interval is broad, and its lower value is -132, which means that the true reduction level after applying this drug could be even -132 [mg/dL]. Based on the data from [this table](https://en.wikipedia.org/wiki/Low-density_lipoprotein#Normal_ranges) I guess this could have a big therapeutic meaning. So, you might want to consider performing another experiment on the effects of the drug, but this time you should take a bigger sample to dispel the doubt (bigger samples size narrows the 95% confidence interval).

In general one sample t-test is used to check if a sample comes from a population with the postulated mean (in our case in $H_{0}$ the postulated mean was 500 [mL]). However, I prefer to look at it from the different perspective (the other end) hence my explanation above. The t-test is named after [William Sealy Gosset](https://en.wikipedia.org/wiki/William_Sealy_Gosset) that published his papers under the pen-name Student, hence it is also called a Student's t-test.

### Checking the assumptions {#sec:compare_contin_data_check_assump}

Hopefully, the explanations above were clear enough. Still, we shouldn't just jump into performing a test blindly, first we should test its assumptions (see figure below).

![Checking assumptions of a statistical test before running it.](./images/testAssumptionsCheckCycle.png){#fig:testAssumptionsCheckCycle}

First of all we start by choosing a test to perform. Usually it is a [parametric test](https://en.wikipedia.org/wiki/Parametric_statistics), i.e. one that assumes some specific data distribution (e.g. normal). Then we check our assumptions. If they hold we proceed with our test. Otherwise we can either transform the data (e.g. take a logarithm from each value) or choose a different test (the one that got different assumptions or just less of them to fulfill). This different test usually belongs to so called [non-parametric tests](https://en.wikipedia.org/wiki/Nonparametric_statistics), i.e. tests that make less assumptions about the data, but are likely to be slightly less powerful (you remember power of a test from @sec:statistics_intro_errors, right?).

In our case a Student's t-test requires (among [others](https://en.wikipedia.org/wiki/Student%27s_t-test#Assumptions)) the data to be normally distributed. This is usually verified with [Shapiro-Wilk test](https://en.wikipedia.org/wiki/Shapiro%E2%80%93Wilk_test) or [Kolmogorov-Smirnov test](https://en.wikipedia.org/wiki/Kolmogorov%E2%80%93Smirnov_test). As an alternative to Student's t-test (when the normality assumption does not hold) a [Wilcoxon test](https://en.wikipedia.org/wiki/Wilcoxon_signed-rank_test) is often performed (of course before you use it you should check its assumptions, see @fig:testAssumptionsCheckCycle above).

Both Kolmogorov-Smirnov (see [this docs](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#Kolmogorov-Smirnov-test)) and Wilcoxon test (see [that docs](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#Wilcoxon-signed-rank-test)) are at our disposal in `HypothesisTests` package. Behold

```jl
s = """
Htests.ExactOneSampleKSTest(beerVolumes,
	Dsts.Normal(meanBeerVol, stdBeerVol))
"""
sco(s)
```

So it seems we got no grounds to reject the $H_{0}$ that states that our data are normally distributed (p-value > 0.05) and we were right to perform our one-sample Student's t-test. Of course, I had checked the assumptions before I conducted the test. I didn't mention it there because I didn't want to prolong my explanation (and diverge from the topic) back there.

And now a question. Is the boring assumption check before a statistical test really necessary?

Well, only if you want your conclusions to reflect the reality.

So, yes. Even though a statistical textbook for brevity may not check the assumptions of a method you should always do it in your analyses if your care about the correctness of your judgment.

## Two samples Student's t-test {#sec:compare_contin_data_two_samp_ttest}

Imagine a friend that studies biology told you that he conducted a research in order to write a dissertation and earn a [master's degree](https://en.wikipedia.org/wiki/Master_of_Science). As part of the research he tested a new drug (drug X) on mice. He hopes the drug is capable to reduce the body weights of the animals. He asks you for a help with the data analysis. The results obtained by him are as follows

```jl
s = """
import CSV as Csv
import DataFrames as Dfs

# if you are in 'code_snippets' folder, then use: "./ch05/miceBwt.csv"
# if you are in 'ch05' folder, then use: "./miceBwt.csv"
miceBwt = Csv.read("./code_snippets/ch05/miceBwt.csv", Dfs.DataFrame)
first(miceBwt, 3)
Options(first(miceBwt, 3), caption="Body mass [g] of mice.", label="mBwtDf")
"""
replace(sco(s), Regex("Options.*") => "")
```

Here, we opened a table with a made up data for mice body weight [g] (this dataset can be found [here](https://github.com/b-lukaszuk/RJ_BS_eng/tree/main/code_snippets/ch05)). For that we used two new packages ([CSV](https://csv.juliadata.org/stable/), and [DataFrames](https://dataframes.juliadata.org/stable/)).

A `*.csv` file can be opened and created, e.g. with a [spreadsheet](https://en.wikipedia.org/wiki/List_of_spreadsheet_software) program. Here, we read it as a `DataFrame`, i.e. a structure that resembles an array from @sec:julia_arrays. Since the `DataFrame` could potentially have thousands of rows we displayed only the first three (to check that everything succeeded) using `first` function.

> **_Note:_** We can check the size of a `DataFrame` with `size` function which returns the information in a friendly `(numRows, numCols)` format.

OK, let's take a look at some descriptive statistics using [describe](https://dataframes.juliadata.org/stable/lib/functions/#DataAPI.describe) function.

```jl
s = """
Dfs.describe(miceBwt)
Options(Dfs.describe(miceBwt), caption="Body mass of mice. Descriptive statistics.", label="mBwtDescribe")
"""
replace(sco(s), Regex("Options.*") => "")
```

It appears that mice from group `drugX` got somewhat lower body weight. But that could be just a coincidence. Anyway, how should we analyze this data? Well, it depends on the experiment design.

Since we have `jl size(miceBwt)[1]` rows (`size(miceBwt)[1]`). Then, either:

- we had 10 mice at the beginning. The mice were numbered randomly 1:10 on their tails. Then we measured their initial weight (`noDrugX`), administered the drug and measured their body weight after, e.g. one week (`drugX`), or
- we had 20 mice at the beginning. The mice were numbered randomly 1:20 on their tails. Then first 10 of them (numbers 1:10) became controls (regular food, group: `noDrugX`) and the other 10 (11:20) received additionally `drugX` (hence group `drugX`).

Interestingly, the experimental models deserve slightly different statistical methodology. In the first case we will perform paired samples t-test, whereas in the other case we will use unpaired samples t-test. Ready, let's go.

### Paired samples Student's t-test {#sec:compare_contin_data_paired_ttest}

Running a paired Student's t-test with `HypothesisTests` package is very simple. We just have to send the specific column(s) to the appropriate function. Column selection can be done in one of the few ways, e.g. `miceBwt[:, "noDrugX"]` (similarly to array indexing in @sec:julia_arrays `:` means all rows, note that this form copies the column), `miceBwt[!, "noDrugX"]` (`!` instead of `:`, no copying), `miceBwt.noDrugX` (again, no copying).

> **_Note:_** Copying a column is advantageous when a function may modify the input data, but it is less effective for big data frames. If you wonder does a function changes its input then for starter look at its name and compare it with the convention we discussed in @sec:functions_modifying_arguments. Still, to be sure you would have to examine the function's code.

And now we can finally run the paired t-test.

```jl
s = """
# miceBwt.noDrugX or miceBwt.noDrugX returns a column as a Vector
Htests.OneSampleTTest(miceBwt.noDrugX, miceBwt.drugX)
"""
sco(s)
```

And voila. We got the result. It seems that `drugX` actually does lower the body mass of the animals (p < 0.05). But wait, didn't we want to do a (paired) two-samples t-test and not `OneSampleTTest`? Yes, we did. Interestingly enough, a paired t-test is actually a one-sample t-test for the difference. Observe.

```jl
s = """
# miceBwt.noDrugX or miceBwt.noDrugX returns a column as a Vector
# hence we can do elementwise subtraction using dot syntax
miceBwtDiff = miceBwt.noDrugX .- miceBwt.drugX
Htests.OneSampleTTest(miceBwtDiff)
"""
sco(s)
```

Here, we used the familiar dot syntax from @sec:julia_language_dot_functions to obtain the differences and then fed the result to `OneSampleTTest` from the previous section (see @sec:compare_contin_data_one_samp_ttest). The output is the same as in the previous code snippet.

I don't know about you, but when I was a student I often wondered when to choose paired and when unpaired t-test. Now I finally know, and it is so simple. Too bad that most statistical programs/packages separate paired t-test from one-sample t-test (unlike the authors of the `HypothesisTests` package).

Anyway, this also demonstrates an important feature of the data. The data points in both columns/groups need to be properly ordered, e.g. in our case it makes little sense to subtract body mass of a mouse with 1 on its tail from a mouse with 5 on its tail, right? Doing so has just as little sense as subtracting it from mouse number 6, 7, 8, etc. There is only one clearly good way to do this subtraction and this is to subtract mouse number 1 (`noDrugX`) from mouse number 1 (`drugX`). So, if you ever wonder paired or unpaired t-test then think if is there a clearly better way to subtract one column of data from the other. If so, then you should go with the paired t-test, otherwise choose the unpaired t-test.

BTW, do you remember how in @sec:compare_contin_data_check_assump we checked the assumptions of our `oneSampleTTest`, well it turns out that here we should do the same. However, this time instead of Kolmogorov-Smirnov test I'm going to use Shapiro-Wilk's normality test from `Pingouin` package (Shapiro-Wilk is usually more powerful + the syntax and output of the function is nicer here).

```jl
s = """
import Pingouin as Pg
Pg.normality(miceBwtDiff)
Options(Pg.normality(miceBwtDiff), caption="Shapiro-Wilk's normality test.", label="mBwtShapiro")
"""
replace(sco(s), Regex("Options.*") => "")
```

There, all normal (p > 0.05). So, we were right to perform the test. Still, the order was incorrect, in general you should remember to check the assumptions first and then proceed with the test. In case the normality assumption did not hold we should consider doing a [Wilcoxon test](https://en.wikipedia.org/wiki/Wilcoxon_signed-rank_test) (non-parametric test), e.g. like so `Htests.SignedRankTest(df.noDrugX, df.drugX)` or `Htests.SignedRankTest(miceBwtDiff)`. More info on the test can be found in the link above or on the pages of `HypothesisTests` package (see [here](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#Wilcoxon-signed-rank-test)).

### Unpaired samples Student's t-test {#sec:compare_contin_data_unpaired_ttest}

OK, now it's time to move to the other experimental models. A reminder, here we discuss the following situation:

- we had 20 mice at the beginning. The mice were numbered randomly 1:20 on their tails. Then first 10 of them (numbers 1:10) became controls (regular food, group: `noDrugX`) and the other 10 (11:20) received additionally `drugX` (hence group `drugX`).

Here we will compare mice `noDrugX` (miceID: 1:10) with mice `drugX` (miceID: 11:20) using unpaired samples t-test, but this time we will start by checking the assumptions.
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

OK, no reason to doubt the normality (p-vals > 0.05). The other assumption that we may test is homogeneity of variance. Homogeneity means that the spread of data around the mean in each group is similar (sd(gr1) ≈ sd(gr2)). Here, we are going to use [Fligner-Killeen](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#Fligner-Killeen-test) test from the `HypothesisTests` package.

```jl
s = """
Htests.FlignerKilleenTest(miceBwt.noDrugX, miceBwt.drugX)
"""
sco(s)
```

Also this time, the assumption is fulfilled, and now for the unpaired test.

```jl
s = """
Htests.HypothesisTests.EqualVarianceTTest(
	miceBwt.noDrugX, miceBwt.drugX)
"""
sco(s)
```

It appears there is not enough evidence to reject the $H_{0}$ (the mean difference is equal to 0) on the cutoff level of 0.05. So, how could that be, the means in both groups are still the same, i.e. `Stats.mean(miceBwt.noDrugX)` = `jl round(Stats.mean(miceBwt.noDrugX), digits = 2)` and `Stats.mean(miceBwt.drugX)` = `jl round(Stats.mean(miceBwt.drugX), digits = 2)`, yet we got different results (reject $H_{0}$ from paired t-test, not reject $H_{0}$ from unpaired t-test). Well, it is because we calculated slightly different things and because using paired samples usually removes some between subjects variability.

In the case of unpaired t-test we:

1. assume that the difference between the means under $H_{0}$ is equal to 0.
2. calculate the observed difference between the means, `Stats.mean(miceBwt.noDrugX) - Stats.mean(miceBwt.drugX)` = `jl round(Stats.mean(miceBwt.noDrugX) - Stats.mean(miceBwt.drugX), digits=2)`.
3. calculate the sem (with a slightly different formula than for the one-sample/paired t-test)
4. obtain the z-score (in case of t-test it is named t-score or t-statistics)
5. calculate the probability from t-test (slightly different calculation of the degrees of freedom)

When compared with the methodology for one-sample t-test from @sec:compare_contin_data_one_samp_ttest it differs only with respect to the points 3, 4 and 5 above. Observe. First the functions

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

There are different formulas for pooled sem (standard error of the mean), but I only managed to remember this one because it reminded me the famous [Pythagorean theorem](https://en.wikipedia.org/wiki/Pythagorean_theorem), i.e. $c^2 = a^2 + b^2$, so $c = \sqrt{a^2 + b^2}$, that I learned in a primary school. As for the degrees of freedom they are just the sum of the degrees of freedom for each of the vectors. OK, so now the calculations


```jl
s = """
meanDiffBwtH0 = 0
meanDiffBwt = Stats.mean(miceBwt.noDrugX) - Stats.mean(miceBwt.drugX)
pooledSemBwt = getSem(miceBwt.noDrugX, miceBwt.drugX)
zScoreBwt = getZScore(meanDiffBwt, pooledSemBwt, meanDiffBwtH0)
dfBwt = getDf(miceBwt.noDrugX, miceBwt.drugX)
pValBwt = Dsts.cdf(Dsts.TDist(dfBwt), zScoreBwt) * 2
"""
sc(s)
```

And finally the result that you may compare with the output of the unpaired t-test above and the methodology for the one-sample t-test from @sec:compare_contin_data_one_samp_ttest.

```jl
s = """
(
meanDiffBwtH0, # value under h_0
round(meanDiffBwt, digits = 4), # point estimate
round(pooledSemBwt, digits = 4), # empirical standard error
# to get a positive zScore we should have calculated it as:
# getZScore(meanDiffBwtH0, pooledSemBwt, meanDiffBwt)
round(zScoreBwt, digits = 4), # t-statistic
dfBwt, # degrees of freedom
round(pValBwt, digits=4) # two-sided p-value
)
"""
sco(s)
```

Amazing. In the case of the unpaired two-sample t-test we use the same methodology and reasoning as we did in the case of the one-sample t-test from @sec:compare_contin_data_one_samp_ttest (only functions for `sem` and `df` changed slightly). Given the above I recommend you get back to the section @sec:compare_contin_data_one_samp_ttest and make sure you understand the explanations presented there (if you haven't done this already).

As an alternative to our unpaired t-test we should consider `Htests.UnequalVarianceTTest` (if the variances are not equal) or [Htests.MannWhitneyUTest](https://juliastats.org/HypothesisTests.jl/stable/nonparametric/#HypothesisTests.MannWhitneyUTest) (if both the normality and homogeneity assumptions do not hold).

## One-way ANOVA {#sec:compare_contin_data_one_way_anova}

One-way ANOVA is a technique to compare two or more groups of continuous data. It allows us to tell if all the groups are alike or not based on the spread of the data around the mean.

Do you still remember our tennis players Peter and John from @sec:statistics_intro_tennis. Well, guess what they work at two different biological institutes.
The institutes independently test a new weight reducing drug, called drug Y, that is believed to reduce body weight of an animal by 20%. The drug administration is fairly simple. You just dilute it in water and leave in a cage for mice to drink it.

So both our friends independently run the following experiment: a researcher takes eight mice, writes at random numbers at their tails (1:8), and decides that the mice 1:4 will drink pure water, and the mice 5:8 will drink the water with the drug. After a week body weights of all mice are recorded.

As said, Peter and John run the experiments independently not knowing one about the other.
After a week Peter noticed that he messed things up and did not give the drug to mice (when diluted the drug is colorless and by accident he took the wrong bottle). It happened, still let's compare the results that were obtained by both our friends.

```jl
s = """
import Random as Rand

# Peter's mice, experiment 1 (ex1)
Rand.seed!(321)
ex1BwtsWater = Rand.rand(Dsts.Normal(25, 3), 4)
ex1BwtsPlacebo = Rand.rand(Dsts.Normal(25, 3), 4)

# John's mice, experiment 2 (ex2)
ex2BwtsWater = Rand.rand(Dsts.Normal(25, 3), 4)
ex2BwtsDrugY = Rand.rand(Dsts.Normal(25 * 0.8, 3), 4)
"""
sc(s)
```

In Peter's case both mice groups came from the same population `Dsts.Normal(25, 3)` ($\mu = 25$, $\sigma = 3$) since they both ate and drunk the same stuff. For need of different name the other group is named [placebo](https://en.wikipedia.org/wiki/Placebo).

In John's case the other group comes from a different distribution (e.g. the one where body weight is reduced on average by 20%, hence $\mu = 25 * 0.8$).

Let's see the results side by side on the graph.

![The results of drug Y application on body weight of laboratory mice.](./images/oneWayAnovaDrugY.png){#fig:oneWayAnovaDrugY.png}

I don't know about you, but my first impression is that the data points are more scattered around in John's experiment. Let's add some means to the graph to make it more obvious.

To be continued...