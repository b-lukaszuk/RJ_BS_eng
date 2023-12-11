# Association {#sec:association}

OK, time to talk about association between two variables.

## Chapter imports {#sec:association_imports}

Later in this chapter we are going to use the following libraries

```jl
s7 = """
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import Distributions as Dsts
import MultipleTesting as Mt
import Random as Rand
import RDatasets as RD
import Statistics as Stats
"""
sc(s7)
```

If you want to follow along you should have them installed on your system. A
reminder of how to deal (install and such) with packages can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/). But wait, you may prefer
to use `Project.toml` and `Manifest.toml` files from the [code snippets for this
chapter](https://github.com/b-lukaszuk/RJ_BS_eng/tree/main/code_snippets/ch07)
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

## Linear relation {#sec:association_lin_relation}

Imagine you are a biologist that conducts their research in [the Amazon
rainforest](https://en.wikipedia.org/wiki/Amazon_rainforest) known for
biodiversity and heavy rainfalls (see the name). You divided the area into 20
equal size fields on which you measured the volume of rain and biomass of two
plants (named creatively `plantA` and `plantB`). The results are contained in
`biomass.csv` file, let's take a sneak peak at them.

```jl
s1 = """
import CSV as Csv
import DataFrames as Dfs

# if you are in 'code_snippets' folder, then use: "./ch07/biomass.csv"
# if you are in 'ch07' folder, then use: "./biomass.csv"
biomass = Csv.read("./code_snippets/ch07/biomass.csv", Dfs.DataFrame)
first(biomass, 5)
Options(first(biomass, 5), caption="Effect of rainfall on plants biomass (fictitious data).", label="biomassDf")
"""
replace(sco(s1), Regex("Options.*") => "")
```

I think some plot would be helpful to get a better picture of the data (pun
intended).


```jl
s = """
import CairoMakie as Cmk

fig = Cmk.Figure()
ax1, sc1 = Cmk.scatter(fig[1, 1], biomass.rainL, biomass.plantAkg,
    markersize=25, color="skyblue", strokewidth=1, strokecolor="gray",
    axis=(; title="Effect of rainfall on biomass of plant A",
        xlabel="water [L]", ylabel="biomass [kg]")
)
ax2, sc2 = Cmk.scatter(fig[1, 2], biomass.rainL, biomass.plantBkg,
    markersize=25, color="linen", strokewidth=1, strokecolor="black",
    axis=(; title="Effect of rainfall on bomass of plant B",
        xlabel="water [L]", ylabel="biomass [kg]")
)
Cmk.linkxaxes!(ax1, ax2)
Cmk.linkyaxes!(ax1, ax2)
fig
"""
sc(s)
```

![Effect of rainfall on plants' biomass.](./images/ch07biomassCor.png){#fig:ch07biomassCor}

Overall, it looks like the biomass of both plants is directly related (one
increases and the other increases) with the volume of rain. That seems
reasonable. Moreover, we can see that the points are spread along an imaginary
line (go ahead imagine it) that goes through all the points on a graph. We can
also see that `plantB` has a somewhat greater spread of points. It would be nice
to be able to express such a relation between two variables (here biomass and
volume of rain) with a single number. It turns out that we can. That's the job
for [covariance](https://en.wikipedia.org/wiki/Covariance).

## Covariance {#sec:association_covariance}

The formula for covariance resembles the one for `variance` that we met in
@sec:statistics_normal_distribution (`getVar` function) only that it is
calculated for pairs of values (here a plant biomass and rainfall for a field),
so two vectors instead of one. Observe

```jl
s = """
function getCov(v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
    @assert length(v1) == length(v2) "v1 and v2 must be of equal lengths"
    avg1::Float64 = Stats.mean(v1)
    avg2::Float64 = Stats.mean(v2)
    diffs1::Vector{<:Real} = v1 .- avg1
    diffs2::Vector{<:Real} = v2 .- avg2
    return sum(diffs1 .* diffs2) / (length(v1) - 1)
end
"""
sc(s)
```

> **_Note:_** To calculate the covariance you may also use
> [Statistics.cov](https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.cov).

A few points of notice. In @sec:statistics_normal_distribution in `getVar` we
squared the differences (`diffs`), i.e. we multiplied the diffs by themselves
($x * x = x^2$). Here, we do something similar by multiplying parallel values
from both vectors of `diffs` (`diffs1` and `diffs2`) by each other ($x * y$, for
a given field).  Moreover, instead of taking the average (so `sum(diffs1 .*
diffs2)/length(v1)`) here we use the more fine tuned statistical formula that
relies on degrees of freedom we met in @sec:compare_contin_data_one_samp_ttest
(there we used `getDf` function, here we kind of use `getDf` on the number of
fields that are represented by the points in the Figure 27).

Enough explanations, let's see how it works. First, a few possible associations
that roughly take the following shapes on a graph: `/`, `\`, `|`, and `-`.

```jl
s = """
rowLenBiomass, _ = size(biomass)

(
	# assuming getCov(xs, ys)
	getCov(biomass.rainL, biomass.plantAkg), # /
    getCov(collect(1:1:rowLenBiomass), collect(rowLenBiomass:-1:1)), # \\
	getCov(repeat([5], rowLenBiomass), biomass.plantAkg), # |
	getCov(biomass.rainL, repeat([5], rowLenBiomass)) # -
)
"""
sco(s)
```

We can see that whenever both variables (on X- and on Y-axis) increase
simultaneously (points lie alongside `/` imaginary line like in
Figure 27) then the covariance is positive. If one variable increases
whereas the other decreases (points lie alongside `\` imaginary line) then the
covariance is negative. Whereas in the case when one variable changes and the
other is stable (points lie alongside `|` or `-` line) the covariance is equal
zero.

OK, time to compare the both plants.

```jl
s = """
covPlantA = getCov(biomass.plantAkg, biomass.rainL)
covPlantB =	getCov(biomass.plantBkg, biomass.rainL)

(
	covPlantA,
	covPlantB,
)
"""
sco(s)
```

In @sec:statistics_normal_distribution greater `variance` (and `standard
deviation`) meant greater spread of points around the mean, here the greater
covariance expresses the greater spread of the points around the imaginary trend
line (in Figure 27). But beware, you shouldn't judge the spread of
data based on the covariance alone. To understand why let's look at the graph
below.

![Effect of rainfall on plants' biomass.](./images/ch07biomassCorDiffUnits.png){#fig:ch07biomassCorDiffUnits}

Here, we got the biomass of `plantA` in different units (kilograms and
pounds). Logic and visual inspection of the points spread on the graph suggest
that the covariances should be the same. Or maybe not?

```jl
s = """
(
	getCov(biomass.plantAkg, biomass.rainL),
	getCov(biomass.plantAkg .* 2.205, biomass.rainL),
)
"""
sco(s)
```

The covariances suggest that the spread of the data points is like 2 times
greater between the two sub-graphs of @fig:ch07biomassCorDiffUnits, but that is
clearly not the case. The problem is that the covariance is easily inflated by
the units of measurements. That is why we got an improved metrics for
association named [correlation](https://en.wikipedia.org/wiki/Correlation).

## Correlation {#sec:association_correlation}

Correlation is most frequently expressed in the term of [Pearson correlation
coefficient](https://en.wikipedia.org/wiki/Pearson_correlation_coefficient) that
by itself relies on covariance we met in the previous section. Its formula is
pretty straightforward

```jl
s = """
# calculates the Pearson correlation coefficient
function getCor(v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
    return getCov(v1, v2) / (Stats.std(v1) * Stats.std(v2))
end
"""
sco(s)
```

> **_Note:_** To calculate the Pearson correlation coefficient you may also use
> [Statistics.cor](https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.cor).

The correlation coefficient is just the covariance (numerator) divided by the
product of two standard deviations (denominator). The lowest absolute value
(`abs(getCov(v1, v2))`) possible for covariance is 0. The maximum absolute value
possible for covariance is `Stats.std(v1) * Stats.std(v2)`. Therefore, the
correlation coefficient (often abbreviated as `r`) takes values from 0 to 1 for
positive covariance and from 0 to -1 for negative covariance.

Let's see how it works.

```jl
s = """
biomassCors = (
	getCor(biomass.plantAkg, biomass.rainL),
	getCor(biomass.plantAkg .* 2.205, biomass.rainL), # pounds
	getCor(biomass.plantBkg, biomass.rainL),
	getCor(biomass.plantBkg .* 2.205, biomass.rainL), # pounds
)
round.(biomassCors, digits = 2)
"""
sco(s)
```

Clearly, the new and improved coefficient is more useful than the old one
(covariance). Large spread of points along the imaginary line in Figure 27
yields small correlation coefficient (closer to 0). Small spread of points on
the other hand results in a high correlation coefficient (closer to -1 or
1). So, now we can be fairly sure of the greater strength of association between
`plantA` and rainfall than `plantB` and the condition.

Importantly, the correlation coefficient depends not only on the scatter of
points along an imaginary line, but also on the slope of the line. Observe:

```jl
s = """
import Random as Rand

Rand.seed!(321)

jitter = Rand.rand(-0.2:0.01:0.2, 10)
z1 = collect(1:10)
z2 = repeat([5], 10)
(
    getCor(z1 .+ jitter, z1), # / imaginary line
    getCor(z1, z2 .+ jitter) # - imaginary line
)
"""
sco(s)
```

Feel free to draw side by side scatter plots for the example above (remember to
link the axes). In the code snippet above the spread of data points along the
imaginary line is the same in both cases. Yet, the correlation coefficient is
much smaller in the second case. This is because of the covariance that is
present in the `getCor` function (in numerator). The covariance is greater when
the points change together is a given direction. The change is smaller and
non-systematic in the second case, hence the lower correlation coefficient. You
may want to keep that in mind as it will become handy once we talk about
correlation pitfalls in @sec:association_corr_pitfalls.

Anyway, the interpretation of the correlation coefficient differs depending on a
textbook and field of science, but for biology it is approximated by those
cutoffs:

- `abs(r)` = [0 - 0.2) - very weak correlation
- `abs(r)` = [0.2 - 0.4) - weak correlation
- `abs(r)` = [0.4 - 0.6) - moderate correlation
- `abs(r)` = [0.6 - 0.8) - strong correlation
- `abs(r)` = [0.8 - 1] - very strong correlation

> **_Note:_** `]` and `)` signify closed and open interval, respectively.
> So, x in range `[0, 1]` means 0 <= x <= 1, whereas x in range `[0, 1)` means 0
> <= x < 1. Moreover, the Pearson's correlation coefficient is often abbreviated
> as `r`.

In general, if `x` and `y` are correlated then this may mean one of a few
things, the most obvious of which are:

- `x` is a cause, `y` is an effect
- `y` is a cause, `x` is an effect
- changes in `x` and `y` are caused by an unknown third factor(s)
- `x` and `y` are not related but it just happened that in the sample they
  appear to be related by chance alone (in a small sample drawn from a
  population they appear to be associated, but in the population they are not).

We can protect ourselves against the last contingency (to a certain extent) with
our good old Student's T-test (see @sec:compare_contin_data_one_samp_ttest). As
stated in [the wikipedia's
page](https://en.wikipedia.org/wiki/Pearson_correlation_coefficient#Testing_using_Student's_t-distribution):

> [...] Pearson's correlation coefficient follows Student's t-distribution with
> degrees of freedom n − 2. Specifically, if the underlying variables have a
> bivariate normal distribution the variable
>
> $t = \frac{r}{\sigma_r} = r * \sqrt{\frac{n-2}{1-r^2}}$
>
> has a student's t-distribution in the null case (zero correlation)

Let's put that knowledge to good use:

```jl
s = """
# calculates the Pearson correlation coefficient and pvalue
# assumption (not tested in the function): v1 & v2 got normal distribution
function getCorAndPval(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Tuple{Float64, Float64}
    r::Float64 = getCov(v1, v2) / (Stats.std(v1) * Stats.std(v2))
    n::Int = length(v1) # num of points
    df::Int = n - 2
    t::Float64 = r * sqrt(df / (1 - r^2)) # t-statistics
    leftTail::Float64 = Dsts.cdf(Dsts.TDist(df), t)
    pval::Float64 = (t > 0) ? (1 - leftTail) : leftTail
    return (r, pval * 2) # (* 2) two-tailed probability
end
"""
sco(s)
```

The function is just a translation of the formula given above + some
calculations similar to those we did in
@sec:compare_contin_data_one_samp_ttest to get the p-value. And now for our
correlations.

```jl
s = """
biomassCorsPvals = (
	getCorAndPval(biomass.plantAkg, biomass.rainL),
	getCorAndPval(biomass.plantAkg .* 2.205, biomass.rainL), # pounds
	getCorAndPval(biomass.plantBkg, biomass.rainL),
	getCorAndPval(biomass.plantBkg .* 2.205, biomass.rainL), # pounds
)
biomassCorsPvals
"""
replace(sco(s), r"(\d)\)," => s"\1),\n")
```

We can see that both correlation coefficients are unlikely to have occurred by
chance alone ($p \le 0.05$). Therefore, we can conclude that in each case the
biomass is associated with the amount of water a plant receives. I don't know a
formal test to compare two correlation coefficients, but based on the `r`s alone
it appears that the biomass of `plantA` is more tightly related to (or maybe
even it relies more on) the amount of water than the other plant (`plantB`).

## Correlation Pitfalls {#sec:association_corr_pitfalls}

The Pearson correlation coefficient is pretty useful (especially in connection
with the Student's t-test), but it shouldn't be applied thoughtlessly.

Let's take a look at the [Anscombe's
quartet](https://en.wikipedia.org/wiki/Anscombe%27s_quartet).

```jl
s = """
import RDatasets as RD

anscombe = RD.dataset("datasets", "anscombe")
first(anscombe, 5)
Options(first(anscombe, 5), caption="DataFrame for Anscombe's quartet", label="anscombeDf")
"""
replace(sco(s), Regex("Options.*") => "")
```

The data frame is part of
[RDatasets](https://github.com/JuliaStats/RDatasets.jl) that contains a
collection of standard datasets used in the [R programming
language](https://en.wikipedia.org/wiki/R_(programming_language)). The data
frame was carefully designed to demonstrate the perils of relying blindly on
correlation coefficients.

<pre>
fig = Cmk.Figure()
i = 0
for r in 1:2
    for c in 1:2
        i += 1
        xname = string("X", i)
        yname = string("Y", i)
        xs = anscombe[:, xname]
        ys = anscombe[:, yname]
        cor, pval = getCorAndPval(xs, ys)
        Cmk.scatter(fig[r, c], xs, ys,
            axis=(;
                title=string("Figure ", "ABCD"[i]),
                xlabel=xname, ylabel=yname,
                limits=(0, 20, 0, 15)
            ))
        Cmk.text!(fig[r, c], 9, 3,
			text="cor(x, y) = $(round(cor, digits=2))")
        Cmk.text!(fig[r, c], 9, 1,
			text="p-val = $(round(pval, digits=4))")
    end
end

fig
</pre>

There's not much to explain here. The only new part is `string` function that
converts its elements to strings (if they aren't already) and glues them
together into a one long string. The rest is just plain drawing with
`CairoMakie`. Still, take a look at the picture below

![Anscombe's Quartet.](./images/ch07AnscombesQuartet.png){#fig:ch07AnscombesQuartet}

All the sub-figures from @fig:ch07AnscombesQuartet depict different relation
types between the X and Y variables, yet the correlations and p-values are the
same. Two points of notice here. In **Figure B** the points lie in a perfect
order on a curve. So, in a perfect word the correlation coefficient should be
equal to 1. Yet it is not, as it only measures the spread of the points around
an imaginary straight line. Moreover, correlation is sensitive to
[outliers](https://en.wikipedia.org/wiki/Outlier).  In **Figure D** the X and Y
variables appear not to be associated at all. Again, in the perfect world the
correlation coefficient should be equal to 0. Still, the outlier on far right
(that in real life may have occurred by a typographical error) pumps it up to
0.82 (or what we could call a very strong correlation). Lesson to be learned
here, don't trust the numbers, and whenever you can draw a scatter plot to
double check them. And remember, ["All models are wrong, but some are
useful"](https://en.wikipedia.org/wiki/All_models_are_wrong).

Other pitfalls are also possible. For instance, imagine you measured body and
tail length of a certain species of mouse, here are your results.

```jl
s = """
# if you are in 'code_snippets' folder, then use: "./ch07/miceLengths.csv"
# if you are in 'ch07' folder, then use: "./miceLengths.csv"
miceLengths = Csv.read(
	"./code_snippets/ch07/miceLengths.csv",
	Dfs.DataFrame)
first(miceLengths, 5)
Options(first(miceLengths, 5), caption="Body lengths of a certain mouse species (fictitious data).", label="miceLengthsDf")
"""
replace(sco(s), Regex("Options.*") => "")
```

You are interested to know if the tail length is associated with the body length
of the animals.

```jl
s = """
getCorAndPval(miceLengths.bodyCm, miceLengths.tailCm)
"""
sco(s)
```

Clearly it is and even very strongly. Or is it? Well let's take a look

![Mice body length vs. tail length.](./images/ch07miceLengths.png){#fig:ch07miceBodyLengths}

It turns out that we have two clusters of points. In both of them the points
seem to be randomly scattered. This could be confirmed by testing correlation
coefficients for the clusters.

```jl
s = """
# fml - female mice lengths
# mml - male mice lengths
fml = miceLengths[miceLengths.sex .== "f", :] # choose only females
mml = miceLengths[miceLengths.sex .== "m", :] # choose only males

(
	getCorAndPval(fml.bodyCm, fml.tailCm),
	getCorAndPval(mml.bodyCm, mml.tailCm)
)
"""
replace(sco(s), r"(\d)\)," => s"\1),\n")
```

The Pearson correlation coefficients are small and not statistically significant
(p > 0.05). But since the two clusters of points lie on the opposite sides of
the graph, then the overall correlation measures their spread alongside the
imaginary dashed line in @fig:ch07miceBodyLengths. This inflates the value of
the coefficient. Therefore, it is always good to inspect a graph (scatter plot)
to see if there are any clusters of points. The clusters are usually a result of
some grouping present in the data (either different experimental
groups/treatments or due to some natural grouping). Sometimes we may be unaware
of the groups in our data set. Still, if we do know about them, then it is a
good idea to inspect the overall correlation and the correlation coefficients
for each of the groups.

As the last example let's take a look at this data frame.

```jl
s = """
# if you are in 'code_snippets' folder, then use: "./ch07/candyBars.csv"
# if you are in 'ch07' folder, then use: "./candyBars.csv"
candyBars = Csv.read(
	"./code_snippets/ch07/candyBars.csv",
	Dfs.DataFrame)
first(candyBars, 5)
Options(first(candyBars, 5), caption="Candy bar composition [g] (fictitious data).", label="candyBarsDf")
"""
replace(sco(s), Regex("Options.*") => "")
```

Here, we got a data set on composition of different chocolate bars. You are
interested to see if the carbohydrate (`carb`) content in bars is associated
with their fat mass.

```jl
s = """
getCorAndPval(candyBars.carb, candyBars.fat)
"""
sco(s)
```

And it appears it is not. OK, no big deal, and what about `carb` and `total`
mass of a candy bar?

```jl
s = """
getCorAndPval(candyBars.carb, candyBars.total)
"""
sco(s)
```

Now we got it. It's big (r > 0.8) and it's real ($p \le 0.05$). But did it
really make sense to test that?

If we got a random variable `aa` then it is going to be perfectly correlated
with itself.

```jl
s = """
Rand.seed!(321)
aa = Rand.rand(Dsts.Normal(100, 15), 10)

getCorAndPval(aa, aa)
"""
sco(s)
```

On the other hand it shouldn't be correlated with another random variable `bb`.

```jl
s = """
bb = Rand.rand(Dsts.Normal(100, 15), 10)

getCorAndPval(aa, bb)
"""
sco(s)
```

Now, if we add the two variables together we will get the total (`cc`),
that will be correlated with both `aa` and `bb`.

```jl
s = """
cc = aa .+ bb

(
	getCorAndPval(aa, cc),
	getCorAndPval(bb, cc)
)
"""
replace(sco(s), r"(\d)\)," => s"\1),\n")
```

This is because while correlating `aa` with `cc` we are partially
correlating `aa` with itself (`aa .+ bb`). In general, the greater portion of
`cc` our `aa` makes the greater the correlation coefficient. So, although
possible, it makes little logical sense to compare a part of something with its
total. Therefore, in reality running `getCorAndPval(candyBars.carb,
candyBars.total)` makes no point despite the interesting result it seems to
produce.

## Exercises - Association {#sec:association_exercises}

Just like in the previous chapters here you will find some exercises that you
may want to solve to get from this chapter as much as you can (best
option). Alternatively, you may read the task descriptions and the solutions
(and try to understand them).

### Exercise 1 {#sec:association_ex1}

The `RDatasets` package mentioned in @sec:association_corr_pitfalls contains a
lot of interesting data. For instance the
[Animals](https://vincentarelbundock.github.io/Rdatasets/doc/MASS/Animals.html)
data frame.

```jl
s = """
animals = RD.dataset("MASS", "Animals")
first(animals, 5)
Options(first(animals, 5), caption="DataFrame for brain and body weights of 28 animal species.", label="animalsDf")
"""
replace(sco(s), Regex("Options.*") => "")
```

Since this chapter is all about association then we are interested to know if
animal body and brain weights [kg] are correlated. Let's take a sneak peak at
the data points.

![Body and brain weight of 28 animal species.](./images/ch07ex1v1.png){#fig:ch07ex1v1}

Hmm, at first sight the data looks like a little mess. Most likely because of
the large range of data on X- and Y-axis. Moreover, the fact that some animals
like `Brachiosaurus` (`animals[26, :]`) got large body mass with relatively
small brain weight doesn't help either. Still, my impression is that in
general (except for the first three points from the right) greater body weight
is associated with a greater brain weight. However, it is quite hard to tell for
sure as the points on the left are so close to each other on the scale of
X-axis. So, let's put that to the test.

```jl
s = """
getCorAndPval(animals.Body, animals.Brain)
"""
sco(s)
```

The Pearson's correlation coefficient is not able to discern the points and
confirm that either. Nevertheless, let's narrow our ranges by taking logarithms
(with `log10` function) of the data and look at the scatter plot again.

![Body (log10) and brain (log10) weight of 28 animal species.](./images/ch07ex1v2.png){#fig:ch07ex1v2}

The impression we get is quite different than before. The points are much better
separated. The three outliers remain, but they are are much closer to the
imaginary trend line. Now we would like to express that relationship. One
way to do it is with [Spearman's rank correlation
coefficient](https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient).
As the name implies instead of correlating the numbers themselves it correlates
their ranks.

So here is a warm up task for you.

Write a `getSpearmCorAndPval` function and run it on `animals` data frame.
To do that first you will need a function
`getRanks(v::Vector{<:Real})::Vector{<:Float64}` that returns the ranks for you
like this.

<pre>
getRanks([500, 100, 1000]) # returns [2.0, 1.0, 3.0]
getRanks([500, 100, 500, 1000]) # returns [2.5, 1.0, 2.5, 4.0]
getRanks([500, 100, 500, 1000, 500]) # returns [3.0, 1.0, 3.0, 5.0, 3.0]
# etc.
</pre>

Personally, I found
[findall](https://docs.julialang.org/en/v1/base/arrays/#Base.findall-Tuple{Function,%20Any})
and [sort](https://docs.julialang.org/en/v1/base/sort/#Base.sort)
to be useful while writing `getRanks`, but feel free to employ whatever
constructs you want. Anyway, once you got it, you can apply it to get Spearman's
correlation coefficient (`getCorAndPval(getRanks(v1), getRanks(v2))`).

> **_Note:_** In real life to calculate the coefficient you would probably use
> [StatsBase.corspearman](https://juliastats.org/StatsBase.jl/stable/ranking/#StatsBase.corspearman).

### Exercise 2 {#sec:association_ex2}

P-value multiplicity correction, a classic theme in this book. Let's revisit it
again. Take a look at the following data frame.

```jl
s = """
Rand.seed!(321)

letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
bogusCors = Dfs.DataFrame(
	Dict(l => Rand.rand(Dsts.Normal(100, 15), 10) for l in letters)
)
bogusCors[1:3, 1:3]
Options(bogusCors[1:3, 1:3], caption="DataFrame with random variables for bogus correlations.", label="boguscorsDf")
"""
replace(sco(s), Regex("Options.*") => "")
```

It contains a random made up data. In total we can calculate `binomial(10, 2)` =
 `jl binomial(10, 2)` different unique correlations for the
 `jl size(bogusCors)[1]` columns we got here. Out of them roughly 2-3
(`binomial(10, 2) * 0.05` = `jl binomial(10, 2) * 0.05`) would appear to be
valid correlations (p < 0.05), but in reality were the false positives (since we
know that each column is a random variable obtained from the same
distribution). So here is a task for you. Write a function that will return all
the possible correlations (coefficients and p-values). Check how many of them
are false positives. Apply a multiplicity correction
(e.g. `Mt.BenjaminiHochberg()` we met in
@sec:compare_contin_data_multip_correction) to the p-values and check if the
number of false positives drops to zero.

### Exercise 3 {#sec:association_ex3}

Sometimes we would like to have a quick visual way to depict all the
correlations in one plot to get a general impression of the correlation in the
data (and possible patterns in them). One way to do this is to use a so called
heatmap.

So, here is a task for you. Read the documentation and examples for
[CairoMakie's heatmap](https://docs.makie.org/stable/reference/plots/heatmap/)
(or a heatmap from other plotting library) and for the data in `bogusCors` from
the previous section create a graph similar to the one you see below.

![Correlation heatmap for data in `bogusCors`.](./images/ch07ex3v1.png){#fig:ch07ex3v1}

The graph depicts the Pearson's correlation coefficients for all the possible
correlations in `bogusCors`. Positive correlations are depicted as the shades of
blue, negative correlations as the shades of red.

Your figure doesn't have to be the exact replica of mine, for instance you may
choose a different [color
map](https://docs.makie.org/stable/explanations/colors/).

If you like challenges you may add (write it in the center of a given square)
the value of the correlation coefficient (rounded to let's say 2 decimal
digits). Furthermore, you may add a significance marker (e.g. if a 'raw' p-value
is $\le 0.05$ put '#' character in a square) for the correlations.

## Solutions - Association {#sec:association_exercises_solutions}

In this sub-chapter you will find exemplary solutions to the exercises from the
previous section.

### Solution to Exercise 1 {#sec:association_ex1_solution}

Let's write `getRanks`, but let's start simple and use it on a sorted vector
`[100, 500, 1000]` without ties. In this case the body of `getRanks` function
would be something like.

```jl
s = """
# for now the function is without types
function getRanksVer1(v)
	# or: ranks = collect(1:length(v))
	ranks = collect(eachindex(v))
	return ranks
end

getRanksVer1([100, 500, 1000])
"""
sco(s)
```

Time to complicate stuff a bit by adding some ties in numbers.

```jl
s = """
# for now the function is without types
function getRanksVer2(v)
	initialRanks = collect(eachindex(v))
	finalRanks = zeros(length(v))
	for i in eachindex(v)
		indicesInV = findall(x -> x == v[i], v)
		finalRanks[i] = Stats.mean(initialRanks[indicesInV])
	end
	return finalRanks
end

(
	getRanksVer2([100, 500, 500, 1000]),
	getRanksVer2([100, 500, 500, 500, 1000])
)
"""
replace(sco(s), r"(\d)\]," => s"\1],\n")
```

The `findall` function accepts a `Funcion` and a `Vector` (actually, an `Array`,
still, a `Vector` is a special type of an `Array`). Next, it runs the function on
every element of the `Array` and returns the indices for which the result was
`true`. Then, we use `indicesInV` to get the `initialRanks`. The
`initialRanks[indicesInV]` returns a `Vector` that contains one or more (if
ties occur) `initialRanks` for a given element of `v`. Finally, we calculate
the average rank for a given number in `v` by using `Stats.mean`. The function
may be sub-optimall as for `[100, 500, 500, 1000]` the average rank for `500` is
calculated twice (once for `500` at index 2 and once for `500` at index 3) and
for `[100, 500, 500, 500, 1000]` the average rank for `500` is calculated three
times. Still, we are more concerned with the correct result and not the
efficiency (assuming that the function is fast enough) so we will leave it as it
is.

Now, the final tweak. The input vector is shuffled.

```jl
s = """
# for now the function is without types
function getRanksVer3(v)
    sortedV = collect(sort(v))
	initialRanks = collect(eachindex(sortedV))
	finalRanks = zeros(length(v))
	for i in eachindex(v)
		indicesInSortedV = findall(x -> x == v[i], sortedV)
		finalRanks[i] = Stats.mean(initialRanks[indicesInSortedV])
	end
	return finalRanks
end

(
	getRanksVer3([500, 100, 1000]),
	getRanksVer3([500, 100, 500, 1000]),
	getRanksVer3([500, 100, 500, 1000, 500])
)
"""
replace(sco(s), r"(\d)\]," => s"\1],\n")
```

Here, we let the built in function `sort` to arrange the numbers from `v` in
the ascending order. Then for each number from `v` we get its indices in
`sortedV` and its ranks based on that (`initialRanks[indicesInSortedV]`). As
in `getRanksVer2` the latter is used to calculate their average.

OK, time for cleanup + adding some types for future references (before we forget
them).

```jl
s = """
function getRanks(v::Vector{<:Real})::Vector{<:Float64}
	sortedV::Vector{<:Real} = collect(sort(v))
	initialRanks::Vector{<:Int} = collect(eachindex(sortedV))
	finalRanks::Vector{<:Float64} = zeros(length(v))
	for i in eachindex(v)
		indicesInSortedV = findall(x -> x == v[i], sortedV)
		finalRanks[i] = Stats.mean(initialRanks[indicesInSortedV])
	end
	return finalRanks
end

(
	getRanks([100, 500, 1000]),
	getRanks([100, 500, 500, 1000]),
	getRanks([500, 100, 1000]),
	getRanks([500, 100, 500, 1000]),
	getRanks([500, 100, 500, 1000, 500])
)

"""
replace(sco(s), r"(\d)\]," => s"\1],\n")
```

After long last we can define `getSpearmCorAndPval` and apply it to `animals`
data frame.

```jl
s = """
function getSpearmCorAndPval(
	v1::Vector{<:Real}, v2::Vector{<:Real})::Tuple{Float64, Float64}
	return getCorAndPval(getRanks(v1), getRanks(v2))
end

getSpearmCorAndPval(animals.Body, animals.Brain)
"""
sco(s)
```

The result appears to reflect the general relationship well (compare with Figure
32).

### Solution to Exercise 2 {#sec:association_ex2_solution}

The solution should be quite simple assuming you did solve exercise 4 from ch05
(see @sec:compare_contin_data_ex4 and @sec:compare_contin_data_ex4_solution) and
exercise 5 from ch06 (see @sec:compare_categ_data_ex5 and
@sec:compare_categ_data_ex5_solution).

For it we are going to use two helper functions, `getUniquePairs`
(@sec:compare_contin_data_ex4_solution) and `getSortedKeysVals`
(@sec:statistics_prob_distribution) developed previously. For your convenience
I paste them below.

<pre>
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

function getSortedKeysVals(d::Dict{T1,T2})::Tuple{
    Vector{T1},Vector{T2}} where {T1,T2}
    sortedKeys::Vector{T1} = keys(d) |> collect |> sort
    sortedVals::Vector{T2} = [d[k] for k in sortedKeys]
    return (sortedKeys, sortedVals)
end
</pre>

Now, time to get all possible 'raw' correlations.

```jl
s = """
function getAllCorsAndPvals(
    df::Dfs.DataFrame, colsNames::Vector{String}
)::Dict{Tuple{String,String},Tuple{Float64,Float64}}

    uniquePairs::Vector{Tuple{String,String}} = getUniquePairs(colsNames)
    allCors::Dict{Tuple{String,String},Tuple{Float64,Float64}} = Dict(
        (n1, n2) => getCorAndPval(df[:, n1], df[:, n2]) for (n1, n2)
        in
        uniquePairs)

    return allCors
end
"""
sco(s)
```

We start by getting the `uniquePairs` for the columns of interest
`colNames`. Then we use dictionary comprehension to get our result. We iterate
through each pair `for (n1, n2) in uniquePairs`. Each `uniquePair` is composed
of a tuple `(n1, n2)`, where `n1` - name1, `n2` - name2. While traversing the
`uniquePairs` we calculate the correlations and p-values (`getCorAndPval`) by
selecting columns of interest (`df[:, n1]` and `df[:, n2]`). And that's
it. Let's see how it works and how many false positives we got (remember, we
expect 2 or 3).

```jl
s = """
allCorsPvals = getAllCorsAndPvals(bogusCors, letters)
falsePositves = (map(t -> t[2], values(allCorsPvals)) .<= 0.05) |> sum
falsePositves
"""
sco(s)
```

First, we extract the values from our dictionary with `values(allCorsPvals)`.
The values are a vector of tuples [`(cor, pval)`]. To get p-values alone, we use
map function that takes every tuple (`t`) and returns its second element
(`t[2]`). Finally, we compare the p-values with our cutoff level for type 1
error ($\alpha = 0.05$). And sum the `Bool`s (each `true` is counted as 1, and
each `false` as 0).

Anyway, as expected we got 3 false positives. All that's left to do is to apply
the multiplicity correction.

```jl
s = """
function adjustPvals(
    corsAndPvals::Dict{Tuple{String,String},Tuple{Float64,Float64}},
    adjMeth::Type{M}
)::Dict{Tuple{String,String},Tuple{Float64,Float64}} where
	{M<:Mt.PValueAdjustment}

    ks, vs = getSortedKeysVals(corsAndPvals)
    cors::Vector{<:Float64} = map(t -> t[1], vs)
    pvals::Vector{<:Float64} = map(t -> t[2], vs)
	adjustedPVals::Vector{<:Float64} = Mt.adjust(pvals, adjMeth())
    newVs::Vector{Tuple{Float64,Float64}} = collect(
        zip(cors, adjustedPVals))

    return Dict(ks[i] => newVs[i] for i in eachindex(ks))
end
"""
sco(s)
```

The code is rather self explanatory and relies on step by step getting our
p-values (`pvals`) applying an adjustment method (`adjMeth`) on them
(`Mt.adjust`) and combining the adjusted p-values (`adjustedPVals`) with `cors`
again. For that we use `zip` function we met in
@sec:compare_categ_data_ex1_solution. Finally we recreate a dictionary using
comprehension. Time for some tests.

```jl
s = """
allCorsPvalsAdj = adjustPvals(allCorsPvals, Mt.BenjaminiHochberg)
falsePositves = (map(t -> t[2], values(allCorsPvalsAdj)) .<= 0.05) |> sum
falsePositves
"""
sco(s)
```

The correction appears to be working correctly, we got rid of false positives.

### Solution to Exercise 3 {#sec:association_ex3_solution}

Let's start by writing a function to get a correlation matrix. We could use for
that
[Stats.cor](https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.cor)
like so `Stats.cor(bogusCors)`. But since we need to add significance markers
then the p-values for the correlations are indispensable. As far as I'm aware
the package does not have it, then we will write a function of our own.

```jl
s = """
function getCorsAndPvalsMatrix(
    df::Dfs.DataFrame,
	colNames::Vector{String})::Array{<:Tuple{Float64, Float64}}

    len::Int = length(colNames)
    corsPvals::Dict{Tuple{String,String},Tuple{Float64,Float64}} =
        getAllCorsAndPvals(df, colNames)
    mCorsPvals::Array{Tuple{Float64,Float64}} = fill((0.0, 0.0), len, len)

    for cn in eachindex(colNames) # cn - column number
        for rn in eachindex(colNames) # rn - row number
            corPval = (
                haskey(corsPvals, (colNames[rn], colNames[cn])) ?
                corsPvals[(colNames[rn], colNames[cn])] :
                get(corsPvals, (colNames[cn], colNames[rn]), (1, 1))
            )
			mCorsPvals[rn, cn] = corPval
        end
    end

    return mCorsPvals
end
"""
sco(s)
```

The function `getCorsAndPvalsMatrix` uses `getAllCorsAndPvals` we developed
previously (@sec:association_ex2_solution). Then we define the matrix (our
result), we initialize it with the [fill
function](https://docs.julialang.org/en/v1/base/arrays/#Base.fill) that takes an
initial value and returns an array of a given size filled with that value
(`(0.0, 0.0)`). Next, we replace the initial values in `mCorsPvals` with the
correct ones by using two `for` loops. Inside them we extract a tuple
(`corPval`) from the unique `corsPvals`. First, we test if a `corPval`
for a given two variables (e.g. "a" and "b") is in the dictionary `corsPvals`
(`haskey` etc.). If so then we insert it into the `mCorsPvals`. If not, then we
search in `corsPvals` by its reverse (so, e.g. "b" and "a") with
 `get(corsPvals, (colNames[cn], colNames[rn]), etc.)`.
If that combination is not present then we
are looking for the correlation of a variable with itself (e.g. "a" and "a")
which is equal to `(1, 1)` (for correlation coefficient and p-value,
respectively). Once we are done we return our `mCorsPvals` matrix (aka `Array`).
Time to give it a test run.

```jl
s = """
getCorsAndPvalsMatrix(bogusCors, ["a", "b", "c"])
"""
sco(s)
```

The numbers seem to be OK. In the future, you may consider changing the function
so that the p-values are adjusted, e.g. by using `Mt.BenjaminiHochberg`
correction, but here we need some statistical significance for our heatmap so we
will leave it as it is.

Now, let's move to drawing a plot.

<pre>
mCorsPvals = getCorsAndPvalsMatrix(bogusCors, letters)
cors = map(t -> t[1], mCorsPvals)
pvals = map(t -> t[2], mCorsPvals)
nRows, _ = size(cors) # same num of rows and cols in our matrix
xs = repeat(1:nRows, inner=nRows)
ys = repeat(1:nRows, outer=nRows)[end:-1:1]

fig = Cmk.Figure()
ax, hm = Cmk.heatmap(fig[1, 1], xs, ys, [cors...],
	colormap=:RdBu, colorrange=(-1, 1),
    axis=(;
        xticks=(1:1:nRows, letters[1:nRows]),
        yticks=(1:1:nRows, letters[1:nRows][end:-1:1])
    ))
Cmk.hlines!(fig[1, 1], 1.5:1:nRows, color="black", linewidth=0.25)
Cmk.vlines!(fig[1, 1], 1.5:1:nRows, color="black", linewidth=0.25)
Cmk.Colorbar(fig[:, end+1], hm)
fig
</pre>

We begin by preparing the necessary helper variables (`mCorsPvals`, `cors`,
`pvals`, `nRows`, `xs`, `ys`). The last two are the coordinates of the centers
of squares on the X- and Y-axis. The `cors` will be flattened row by row using
`[cors...]` syntax. For your information `repeat([1, 2], inner = 2)` returns
`[1, 1, 2, 2]` and `repeat([1, 2], outer = 2)` returns `[1, 2, 1, 2]`. The `ys`
vector is then reversed with `[end:-1:1]` to make it reflect better the order of
correlations in `cors` (left to right, row by row). The same goes for `yticks`
below. The above was determined to be the right option by trial and error. The
next important parameter is `colorrange=(-1, 1)` it ensures that `-1` is always
the leftmost color (red) from the `:RdBu` colormap and `1` is always the
rightmost color (blue) from the colormap. Without it the colors would be set to
`minimum(cors)` and `maximum(cors)` which we do not want since the `minimum`
will change from matrix to matrix. Over our heatmap we overlay the grid
(`hlines!` and `vlines!`) to make the squares separate better from one
another. The centers of the squares are at integers, and the edges are at
halves, that's why we start the ticks at `1.5`. Finlay, we add `Colorbar` as
they did in the docs for `Cmk.heatmap`. The result of this code is visible in
Figure 33 from the previous section.

OK, let's add the correlation coefficients and statistical significance markers.
But firs, two little helper functions.

```jl
s = """
function getColorForCor(corCoeff::Float64)::String
    @assert (0 <= abs(corCoeff) <= 1) "abc(corCoeff) must be in range [0-1]"
    return (abs(corCoeff) >= 0.65) ? "white" : "black"
end

function getMarkerForPval(pval::Float64)::String
    @assert (0 <= pval <= 1) "probability must be in range [0-1]"
    return (pval <= 0.05) ? "#" : ""
end
"""
sco(s)
```

As you can see `getColorForCor` returns a color ("white" or "black") for a given
value of correlation coefficient (white color will make it easier to read the
correlation coefficient on a dark red/blue background of a square). On the other
hand `getMarkerForPval` returns a marker (" #") when a pvalue is below a
customary cutoff level for type I error.

<pre>
fig = Cmk.Figure()
ax, hm = Cmk.heatmap(fig[1, 1], xs, ys, [cors...],
    colormap=:RdBu, colorrange=(-1, 1),
    axis=(;
        xticks=(1:1:nRows, letters[1:nRows]),
        yticks=(1:1:nRows, letters[1:nRows][end:-1:1])
    ))
Cmk.text!(fig[1, 1], xs, ys,
    text=string.(round.([cors...], digits=2)) .*
		getMarkerForPval.([pvals...]),
    align=(:center, :center),
    color=getColorForCor.([cors...]))
Cmk.hlines!(fig[1, 1], 1.5:1:nRows, color="black", linewidth=0.25)
Cmk.vlines!(fig[1, 1], 1.5:1:nRows, color="black", linewidth=0.25)
Cmk.Colorbar(fig[:, end+1], hm)
fig
</pre>

The only new element here is `Cmk.text!` function but since we used it a couple
of times throughout this book, then I will leave the explanation of how the code
piece works for you. Anyway, the result is to be found below.

![Correlation heatmap for data in `bogusCors` with the coefficients and significance markers.](./images/ch07ex3v2.png){#fig:ch07ex3v2}

It looks good. Also the number of significance markers is right. Previously
(@sec:association_ex2_solution) we said we got 3 significant correlations (based
on 'raw' p-values). Since, the upper right triangle of the heatmap is a mirror
reflection of the lower left triangle, then we should see 6 significance markers
altogether.

To be continued...