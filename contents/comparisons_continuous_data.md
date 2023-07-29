# Comparisons - continuous data {#sec:compare_contin_data}

OK, we finished the previous chapter with hypothesis testing and calculating probabilities for binomial data (`bi` - two `nomen` - name), e.g. number of successes (wins of Peter in tennis).

In this chapter we are going to explore comparisons between the groups containing data in a continuous scale (like the height from @sec:statistics_normal_distribution).

## Chapter imports {#sec:compare_contin_data_imports}

Later in this chapter we are going to use the following libraries

```jl
s = """
import CairoMakie as cmk
import Distributions as dsts
import HypothesisTests as hts
import Statistics as sts
"""
sc(s)
```

Make sure you have them installed on your system. A reminder of how to deal (install and such) with packages can be found [here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

The imports will be in in the code snippet when first used, but I thought it is a good idea to put them here, after all imports should be at the top of your file (so here they are at top of the chapter). Moreover, that way they will be easier to find all in one place.

## One sample Student's t-test {#sec:compare_contin_data_one_samp_ttest}

Imagine that in your town there is a small local brewery that produces quite expensive but super tasty beer. You like it a lot, but you got an impression that the producer is not being honest with their customers and instead of the declared 500 [mL] of beer per bottle, he pours a bit less. Still, there is little you can do to prove it. Or can you?

You bought 10 bottles of beer (ouch, that was expensive!) and measured the volume of fluid in each of them. The results are as follows

```jl
s = """
beerVolumes = [477, 484, 476, 519, 504, 481, 453, 485, 487, 501]
"""
sc(s)
```

On a graph the volume distribution looks like this (it was drawn with [cmk.hist](https://docs.makie.org/stable/examples/plotting_functions/hist/index.html#hist) function).

![Histogram of beer volume distribution for 10 beer.](./images/histBeerVolume.png){#fig:histBeerVolume}

You look at it and it seems to resemble a bit the bell shaped curve that we discussed in the @sec:statistics_normal_distribution. This makes sense. Imagine your task is to pour let's say 1'000 bottles daily with 500 [mL] of beer in each with a big mug. Most likely the volumes would oscillate around your goal volume of 500 [mL], but they would not be exact. Sometimes in a hurry you would add a bit more, sometimes a bit less. So it seems like a reasonable assumption that the 1'000 bottles from our example would have a roughly normal distribution of volumes around the mean.

> **_Note:_** To check for normal distribution of the data in a sample you should probably use e.g. [Shapiro-Wilk test](https://en.wikipedia.org/wiki/Shapiro%E2%80%93Wilk_test), since for a small sample size a histogram may be misleading.

Ah, yes the mean. Now you can calculate the mean and standard deviation for the data

```jl
s = """
import Statistics as sts

meanBeerVol = sts.mean(beerVolumes)
stdBeerVol = sts.std(beerVolumes)

(meanBeerVol, stdBeerVol)
"""
sco(s)
```

Hmm, on average there was `jl meanBeerVol` [mL] of beer per bottle, but the spread of the data around the mean is also considerable (sd = `jl round(stdBeerVol, digits=2)` [mL]). The lowest value measured was `jl minimum(beerVolumes)` [mL], the heighest value measured was `jl maximum(beerVolumes)` [mL]. Still, it seems that there is less beer per bottle than expected but is it enough to draw a conclusion that the real mean in the population of our 1'000 bottles is ≈ `jl round(meanBeerVol, digits=0)` [mL] and not 500 [mL] as it should be? Let's try to test that using what we already know about the normal distribution (see @sec:statistics_normal_distribution), the three sigma rule (@sec:statistics_intro_three_sigma_rule) and the `Distributions` package (@sec:statistics_intro_distributions_package).

Let's assume for a moment that the true mean for volume of fluid in the population of 1'000 beer bottles is `meanBeerVol` = `jl meanBeerVol` [mL] and the true standard deviation is `stdBeerVol` = `jl round(stdBeerVol, digits=2)` [mL]. That would be great because now, based on what we've learned in @sec:statistics_intro_distributions_package we can calculate the probability that a random bottle of beer got >500 [mL] of fluid (or % of beer bottles in the population that contain >500 [mL] of fluid). Let's do it

```jl
s = """
import Distributions as dsts

# how many std. devs is value above or below the mean
function getZScore(mean::Real, sd::Real, value::Real)::Float64
	return (value - mean)/sd
end

expectedBeerVolmL = 500

fractionBeerLessEq500mL = dsts.cdf(dsts.Normal(),
	getZScore(meanBeerVol, stdBeerVol, expectedBeerVol))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL
"""
sco(s)
```

I'm not going to explain the code above since for reference you can always check @sec:statistics_intro_distributions_package. Still, under those assumptions roughly 0.23 or 23% of beer bottles contain more than 500 [mL] of fluid. In other words the probability that a random beer bottle contains >500 [mL] of fluid is 0.23 or 23%.

There are 2 problems with that solution.

**Problem 1**

It is true that the mean from the sample is our best estimate of the mean in the population (here 1'000 beer bottles poured daily). However, statisticians proved that the best estimate of the standard deviation in the population is [standard error of the mean](https://en.wikipedia.org/wiki/Standard_error) which can be calculated as follows

$sem = \frac{sd}{\sqrt{n}}$, where

sem - standard error of the mean

sd - standard deviation

n - number of observations in the sample

\
Let's enclose it into Julia code

```jl
s = """
function getSem(vect::Vector{<:Real})::Float64
	return sts.std(vect) / sqrt(length(vect))
end
"""
sc(s)
```

Now we get a better estimate of the probability

```jl
s = """
fractionBeerLessEq500mL = dsts.cdf(dsts.Normal(),
	getZScore(meanBeerVol, getSem(beerVolumes), expectedBeerVol))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL
"""
sco(s)
```

Under those assumptions the probability that a beer bottle contains >500 [mL] of fluid is roughly 0.01 or 1%.

**Problem 2**

The sample size is small (`length(beerVolumes)` = `jl length(beerVolumes)`) so the underlying distribution is quasi-normal. It is called [t-distribution](https://en.wikipedia.org/wiki/Student%27s_t-distribution).

Luckily our `Distributions` package got the t-distribution included (see [the docs](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.TDist)). As you remember the normal distribution required two parameters that described it: the mean and the standard deviation. The t-distribution requires [degrees of freedom](https://en.wikipedia.org/wiki/Degrees_of_freedom_(statistics)). The concept is fairly easy to understand. Imagine that we recorded body masses of 3 people in the room: Tom, Peter, and John.

```jl
s = """
# in kg
peopleBodyMasses = [84, 94, 78]

sum(peopleBodyMasses)
"""
sco(s)
```

As you can see the sum of those body masses is `jl sum(peopleBodyMasses)` [kg].
Notice however that only two of those masses are independent or free to change. Once we know any two of the body masses (e.g. 94, 78) and the sum: `jl sum(peopleBodyMasses)`, then the third body mass must be equal to `sum(peopleBodyMasses) - 94 - 78` = `jl sum(peopleBodyMasses) - 94 - 78` (it cannot just freely take any value). So in order to calculate the degrees of freedom we type `length(peopleBodyMasses) - 1` = `jl length(peopleBodyMasses) - 1`. Since our sample size is equal to `length(beerVolumes)` = `jl length(beerVolumes)` then it will follow a t-distribution with `length(beerVolumes) - 1` = `jl length(beerVolumes) - 1` degrees of freedom.

So the probability that a beer bottle contains >500 [mL] of fluid is

```jl
s = """
function getDf(vect::Vector{<:Real})::Int
	return length(vect) - 1
end

fractionBeerLessEq500mL = dsts.cdf(dsts.TDist(getDf(beerVolumes)),
	getZScore(meanBeerVol, getSem(beerVolumes), expectedBeerVol))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL
"""
sco(s)
```
> **_Note:_** The z-score (number of standard deviations above the mean) for a t-distribution is called t-score or t-statistics (it is calculated with sem instead of sd).

Finally, we got the result. Based on our sample (`beerVolumes`) and the assumptions we made we can see that the probability that a random beer contains >500 [mL] of fluid (as it should, and as it is stated on a label) is `fractionBeerAbove500mL` = 0.022 or 2.2% (remember, this is one-tailed probability).

Given that the cutoff level for $\alpha$ (type I error) from @sec:statistics_intro_errors is 0.05 we can reject our $H_{0}$ (the assumption that 500 [mL] comes from the population with the mean equal to `meanBeerVol` = `jl meanBeerVol` [mL] and the standard deviation equal to `stdBeerVol` = `jl round(stdBeerVol, digits=2)` [mL]).

In conclusion, our hunch was right ("...you got an impression that the producer is not being honest with their customers..."). The owner of the local brewery is dishonest and intentionally pours slightly less beer (on average `expectedBeerVolmL - meanBeerVol` = `jl round(expectedBeerVolmL - meanBeerVol, digits=0)` [mL]). Now we can go to him and get our money back, or alarm the proper authorities for that monstrous crime. Still, this is like 2-3% beer in a bottle less than it should be and the two-tailed probability (`fractionBeerAbove500mL * 2` = `jl round(fractionBeerAbove500mL * 2, digits=3)`) is not much less than the cutoff for type 1 error equal to 0.05 (we may want to collect a bigger sample and change the cutoff to 0.01). *Fun fact:* the story has it that the [code of Hammurabi](https://en.wikipedia.org/wiki/Code_of_Hammurabi) (circa 1750 BC) was the first to punish for diluting a beer with water (although it seems to be more of a legend).

### HypothesisTests package {#sec:compare_contin_data_hypo_tests_package}

The above paragraphs were to further your understanding of the topic. In practice you can do this much faster using [HypothesisTests](https://juliastats.org/HypothesisTests.jl/stable/) package.

In our beer example you could go with this short snippet (see [the docs](https://juliastats.org/HypothesisTests.jl/stable/parametric/#t-test) for `hts.OneSampleTTest`)

```jl
s = """
import HypothesisTests as hts

hts.OneSampleTTest(beerVolumes, expectedBeerVol)
"""
sco(s)
```

Let's compare it with our previous results

```jl
s = """
(
expectedBeerVol, # value under h_0
meanBeerVol, # point estimate
fractionBeerAbove500mL * 2, # two-sided p-value
getZScore(meanBeerVol, getSem(beerVolumes), expectedBeerVol), # t-statistic
getDf(beerVolumes), # degrees of freedom
getSem(beerVolumes) # empirical standard error
)
"""
sco(s)
```

The numbers are pretty much the same (and they should be if the previous explanation was right). The t-statistic is positive in our case because `getZScore` subtracts `mean` from `value` (`value - mean`) and some packages (like `HypothesisTests`) swap the numbers.

The value that needs to be additionally explained is the [95% confidence interval](https://en.wikipedia.org/wiki/Confidence_interval) from the output of `HypothesisTests` above. All it means is that: if we were to run our experiment with 10 beers 100 times and calculate 95% confidence intervals 100 times then 95 of the intervals would contained the true mean from the population. Sometimes people simplify it and say that this interval [in our case (473.8, 499.6)] contains the true mean from the population with probability of 95% (but that isn't necessarily the same what was stated in the previous sentence). The narrower interval means better, more precise estimate. If the difference is statistically significant (p-value < 0.05 or 0.01) then the interval should not contain the postulated mean (as in our case).

In general one sample t-test is used to check if a sample comes from a population with the postulated mean (in our case the postulated mean was 500 [mL]). However, I prefer to look at it from the different perspective (the other end) hence my explanation above. The t-test is named after [William Sealy Gosset](https://en.wikipedia.org/wiki/William_Sealy_Gosset) that published his papers under penname Student, hence it is also called a Student's t-test.

To be continued...
