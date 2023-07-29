# Comparisons - continuous data {#sec:compare_contin_data}

OK, we finished previous chapter with hypothesis testing and calculating probabilities for binomial data (`bi` - two `nomen` - name), e.g. number of successes (tennis wins of Peter).

In this chapter we are going to explore comparisons between the groups containing data in a continuous scale (like the height from @sec:statistics_normal_distribution).

## Chapter imports {#sec:compare_contin_data_imports}

Later in this chapter we are going to use the following libraries

```jl
s = """
import CairoMakie as cmk
import Distributions as dsts
import HypothesisTests as hts
import Random as rnd
import Statistics as sts
"""
sc(s)
```

Make sure you have them installed on your system. A reminder of how to deal (install and such) with packages can be found [here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

The imports will be in in the code snippet when first used, but I thought it is a good idea to put them here, after all imports should be at the top of your file (so here they are at top of the chapter). Moreover, that way they will be easier to find all in one place.

## One sample Student's t-test {#sec:compare_contin_data_one_samp_ttest}

Imagine that in your town there is a small local brewery that produces quite expensive but super tasty beer. You like it a lot, but you got an impression that the producer is not being honest with their costumers and instead of the declared 500 [mL] of beer per bottle, he consistently pours a bit less. Still, there is little you can do to prove it. Or can you?

You boutht 10 bottles of beer (ouch, that was expensive!) and measured the volume of fluid in each of them the results are as follows.

```jl
s = """
beerVolumes = [481, 493, 479, 527, 504, 486, 457, 489, 491, 501]
"""
sc(s)
```

On a graph the volume distribution looks like this (it was drawn with [cmk.hist](https://docs.makie.org/stable/examples/plotting_functions/hist/index.html#hist) function).

![Histogram of beer volume distribution for 10 beer.](./images/histBeerVolume.png){#fig:histBeerVolume}

It resembles you a bit the bell shaped curve that we discussed in the @sec:statistics_normal_distribution. This makes sense, imagine your task is to pour let's say 1'000 bottles daily 500 [mL] each with a big mug. Most likely the volumes would oscilate around your goal volume of 500 [mL], but they would not be exact. Sometimes in a hurry you would add a bit more, sometimes a bit less. So it seems like a reasonable assumption that the 1'000 bottles from our example would have a roughly normal distribution of volumes around the mean.

> **_Note:_** To check for normal distribution of the data in a sample you should probably use e.g. [Shapiro-Wilk test](https://en.wikipedia.org/wiki/Shapiro%E2%80%93Wilk_test), since for a small sample size histograms may be misleading.

Ahh, yes the mean. Now you can calculate the mean and standard deviation for the data

```jl
s = """
import Statistics as sts

meanBeerVol = sts.mean(beerVolumes)
stdBeerVol = sts.std(beerVolumes)

(meanBeerVol, stdBeerVol)
"""
sco(s)
```

Hmm, on average there was `jl meanBeerVol` [mL] of beer per bottle, but the spread of the data around the mean is pretty big (sd = `jl round(stdBeerVol, digits=2)` [mL]). So it seems that there is less beer per bottle than expected but is it enough to draw a conclusion that the real mean in the population of our 1'000 bottles is ≈ `jl round(meanBeerVol, digits=0)` [mL]? Let's try to test that using what we already know about the normal distribution (see @sec:statistics_normal_distribution), the three sigma rule (@sec:statistics_intro_three_sigma_rule) and the `Distributions` package (@sec:statistics_intro_distributions_package).

Let's assume for a moment that the true mean for volume in the population of 1'000 bottles is `meanBeerVol` = `jl meanBeerVol` [mL] and the true standard deviation is `stdBeerVol` = `jl round(stdBeerVol, digits=2)` [mL]. That would be great because now, based on what I've learnt in @sec:statistics_intro_distributions_package in can caluclate the probability that a random bottle of beer got $\ge 500 [mL]$ of fluid (or % of beer in the population that got contain $\ge 500 [mL]$ of fluid). Let's do it

```jl
s = """
import Distributions as dsts

# how many std. devs is value above or below the mean
function getZScore(mean::Real, sd::Real, value::Real)::Float64
	return (value - mean)/sd
end

expectedBeerVol = 500

fractionBeerLess500mL = dsts.cdf(dsts.Normal(),
	getZScore(meanBeerVol, stdBeerVol, expectedBeerVol-1))
fractionBeerEqAbove500mL = 1 - fractionBeerLess500mL

fractionBeerEqAbove500mL
"""
sco(s)
```

I'm not going to explain the code above since for reference you can always check @sec:statistics_intro_distributions_package. Still, under those assumptions roughly `jl round(fractionBeerEqAbove500mL, digits=2)` or `jl round(fractionBeerEqAbove500mL, digits=2) * 100` % of beer cointains more than 500 [mL] of fluid. In other words the probability that a beer contains 500 [mL] of fluid or more is `jl round(fractionBeerEqAbove500mL, digits=2)` or `jl round(fractionBeerEqAbove500mL, digits=2) * 100` %.

There are 2 problems with this solution.

**Problem 1**

It is true that the mean from the sample is our best estimate of the mean in the population of 1'000 beer bottles. However, statisticians proved that the best estimate of the standard deviation in the population is [standard error of the mean](https://en.wikipedia.org/wiki/Standard_error) which can be calculated as follows

$sem = \frac{sd}{\sqrt{n}}$, where

sd - standard deviation

n - number of observations in the sample

\
Let's enclose it into the Julia code

```jl
s = """
function getSEM(vect::Vector{<:Real})::Float64
	return sts.std(vect)/length(vect)
end
"""
sc(s)
```

Now we get a better estimate of the probability

```jl
s = """
fractionBeerLess500mL = dsts.cdf(dsts.Normal(),
	getZScore(meanBeerVol, getSEM(beerVolumes), expectedBeerVol-1))
fractionBeerEqAbove500mL = 1 - fractionBeerLess500mL

fractionBeerEqAbove500mL
"""
sco(s)
```

Under those assumptions the probability that a beer contains $\ge 500 [mL]$ of fluid is `fractionBeerEqAbove500mL` = `jl getFloatStr(fractionBeerEqAbove500mL, "%.6f")` or `jl getFloatStr(fractionBeerEqAbove500mL*100, "%.4f")`%.

**Problem 2**

The sample size is small (`length(beerVolumes)` = `jl length(beerVolumes)`) so the underlying distribution is actually a so called [t-distribution](https://en.wikipedia.org/wiki/Student%27s_t-distribution) and not a normal distributions that we met before.

Luckily our `Distributions` package got the t-distribution included (see [the docs](https://juliastats.org/Distributions.jl/stable/univariate/#Distributions.TDist)). The normal distribution required two parameters that described it: the mean and the standard deviation. The t-distributin requires [degrees of freedom](https://en.wikipedia.org/wiki/Degrees_of_freedom_(statistics)). The concept is fairly easy to understand. Imagine that we got the body mass of 3 people in the room, Tom, Peter, and John.

```jl
s = """
# in kg
peopleBodyMasses = [84, 94, 78]

sum(peopleBodyMasses)
"""
sco(s)
```

As you can see the sum of those body masses is `jl sum(peopleBodyMasses)` [kg].
Notice however that only two of those masses are independent or free to change. Once we know the two body masses (e.g. 94, 78) and the sum: `jl sum(peopleBodyMasses)`, then the third body mass must be equal to `sum(peopleBodyMasses) - 94 - 78` = `jl sum(peopleBodyMasses) - 94 - 78`. So in order to calculate the degrees of freedom we type `length(peopleBodyMasses) - 1` = `jl length(peopleBodyMasses) - 1`. Since our sample size is equal to `length(beerVolumes)` = `jl length(beerVolumes)` then it will follow a t-distribution with `length(beerVolumes) - 1` = `jl length(beerVolumes) - 1` degrees of freedom.

So the probability that a beer contains $\ge 500 [mL]$ fluid is

```jl
s = """
fractionBeerLess500mL = dsts.cdf(dsts.TDist(length(beerVolumes) - 1),
	getZScore(meanBeerVol, getSEM(beerVolumes), expectedBeerVol-1))
fractionBeerEqAbove500mL = 1 - fractionBeerLess500mL

fractionBeerEqAbove500mL
"""
sco(s)
```
> **_Note:_** The z-score (number of standard deviations above the mean) for a t-distribution is called t-score or t-statistics.

Finally, we got the result. Based on our sample (`beerVolumes`) and the assumptions we see that a probability that a random beer contains $\ge 500 [mL]$ of fluid (as it should, and as it is stated on a label) is `fractionBeerEqAbove500mL` = `jl getFloatStr(fractionBeerEqAbove500mL, "%.5f")` or `jl getFloatStr(fractionBeerEqAbove500mL*100, "%.3f")`%.

Given that the cutoff level for $\alpha$ (type I error) from @sec:statistics_intro_errors was 0.05 we can reject our H0 (the assumption that 500 [mL] comes from the population with the mean equal to `meanBeerVol` = `jl meanBeerVol` [mL] and standard deviation equal to `stdBeerVol` = `jl round(stdBeerVol, digits=2)` [mL]).

Conclusion, our hunch was right. The owner of the local brevery is dishonest and intentionally pours slightly less beer (on average `expectedBeerVol - meanBeerVol` = `jl round(expectedBeerVol - meanBeerVol, digits=0)` [mL]). Now we can go to him and get our money back, or alarm the proper authorities for that monstrous crime. *Fun fact:* the story has it that the [code of Hammurabi](https://en.wikipedia.org/wiki/Code_of_Hammurabi) circa 1750 BC was the first to punish for diluting a beer with water (altough it seems to be more of a legend).

To be continued...
