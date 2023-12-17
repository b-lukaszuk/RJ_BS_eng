# Association and Prediction {#sec:assoc_pred}

OK, time to talk about association between two variables and how to predict the
value of one variable based on the value(s) of other variable(s).

## Chapter imports {#sec:assoc_pred_imports}

Later in this chapter we are going to use the following libraries

```jl
s7 = """
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import Distributions as Dsts
import GLM as Glm
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

## Linear relation {#sec:assoc_pred_lin_relation}

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

## Covariance {#sec:assoc_pred_covariance}

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

## Correlation {#sec:assoc_pred_correlation}

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
correlation pitfalls in @sec:assoc_pred_corr_pitfalls.

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

## Correlation Pitfalls {#sec:assoc_pred_corr_pitfalls}

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

```
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
```

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

## Simple Linear Regression {#sec:assoc_pred_simple_lin_reg}

We began @sec:assoc_pred_lin_relation with describing the relation between water
fall volume and biomass of two plants of amazon rain forest. Let's revisit the
problem.

```jl
s = """
biomass
first(biomass, 5)
Options(first(biomass, 5), caption="Effect of rainfall on plants biomass (fictitious data).")
"""
replace(sco(s), Regex("Options.*") => "")
```

![Effect of rainfall on plants' biomass. Revisited.](./images/ch07biomassCor.png)

Previously, we said that the points are scattered around an imaginary line that
goes through their center. Now, we could draw that line at a rough guess using
pen and paper (or a graphics editor). Based on the line we could make a
prediction of the values on Y-axis based on the values on the X-axis. The
variable placed on the X-axis is called independent (the rain does not depend on
a plant, it falls or not), predictor or explanatory variable. The variable
placed on the Y-axis is called dependent (the plant depends on rain) or outcome
variable. The problem with drawing the line by hand is that it wouldn't be
reproducible, a line drawn by the same person would differ slightly from draw to
draw. The same is true if a few different people have undertaken this
task. Luckily, we got a [simple linear
regression](https://en.wikipedia.org/wiki/Simple_linear_regression) a method
that allows us to draw the same line every time based on a simple mathematical
formula that takes the form:

$y = a + b*x$, where:

- y - predicted value of y
- a - intercept (a point on Y-axis where the imaginary line crosses it)
- b - slope (a value by which y increases/decreases when x changes by one unit)
- x - the value of x for which we want to estimate/predict the value of y

The slope (`b`) is fairly easy to calculate with Julia

```jl
s1 = """
import Statistics as Stats

function getSlope(xs::Vector{<:Real}, ys::Vector{<:Real})::Float64
    avgXs::Float64 = Stats.mean(xs)
    avgYs::Float64 = Stats.mean(ys)
    diffsXs::Vector{<:Real} = xs .- avgXs
    diffsYs::Vector{<:Real} = ys .- avgYs
    return sum(diffsXs .* diffsYs) / sum(diffsXs .^ 2)
end
"""
sco(s1)
```

The function resembles the formula for the covariance that we met in
@sec:assoc_pred_covariance. The difference is that there we divided
`sum(diffs1 .* diffs2)` (here we called it `sum(diffsXs .* diffsYs)`) by the the
degrees of freedom (`length(v1) - 1`) and here we divide it by
`sum(diffsXs .^ 2)`. We might not have come up with the formula ourselves,
still, it makes sense given that we are looking for the value by which y
changes when x changes by one unit.

Once we got it, we may proceed to calculating the intercept (`a`) like so

```jl
s1 = """
function getIntercept(xs::Vector{<:Real}, ys::Vector{<:Real})::Float64
	return Stats.mean(ys) - getSlope(xs, ys) * Stats.mean(xs)
end
"""
sco(s1)
```

And now the results.

```jl
s1 = """
# be careful, unlike in getCor or getCov, here the order of variables
# in parameters influences the result
plantAIntercept = getIntercept(biomass.rainL, biomass.plantAkg)
plantASlope = getSlope(biomass.rainL, biomass.plantAkg)
plantBIntercept = getIntercept(biomass.rainL, biomass.plantBkg)
plantBSlope = getSlope(biomass.rainL, biomass.plantBkg)

round.([plantASlope, plantBSlope], digits = 2)
"""
sco(s1)
```

The intercepts are not our primary interest (we will explain why in a moment or
two). We are more concerned with the slopes. Based on the slopes we can say that
on average each additional liter or water (`rainL`) translates into
 `jl round(plantASlope, digits=2)` [kg] more biomass for `plantA` and
 `jl round(plantBSlope, digits=2)` [kg] more biomass for `plantB`. Although,
based on the correlation coefficients from @sec:assoc_pred_correlation we know
that the estimate for `plantB` is less precise. This is because the smaller
correlation coefficient means a greater spread of the points along the line as
can be seen in the figure below.

```
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
Cmk.ablines!(fig[1, 1],
    plantAIntercept,
    plantASlope,
    linestyle=:dash, color="gray")
Cmk.ablines!(fig[1, 2],
    plantBIntercept,
    plantBSlope,
    linestyle=:dash, color="gray")
Cmk.linkxaxes!(ax1, ax2)
Cmk.linkyaxes!(ax1, ax2)
fig
```

![Effect of rainfall on plants' biomass with trend line.](./images/ch07biomassCor2.png){#fig:ch07biomassCor2}

The trend line is placed more or less where we would have placed it at a rough
guess, so it seems we got our functions right.

Now we can either use the graph (@fig:ch07biomassCor2) and read the expected
value of the variable on the Y-axis based on a value on the X-axis or we can
write a formula based on $y = a + b*x$ we mentioned before to get that estimate.

```jl
s1 = """
function getPrecictedY(
	x::Float64, intercept::Float64, slope::Float64)::Float64
    return intercept + slope * x
end

round.(
	getPrecictedY.([6.0, 10, 12], plantAIntercept, plantASlope),
	digits = 2)
"""
sco(s1)
```

It appears to work as expected.

OK, and now imagine you intend to introduce `plantA` into a [botanic
garden](https://en.wikipedia.org/wiki/Botanical_garden) and you want it to grow
well and fast. The function `getPrecictedY` tells us that if you add a
35 [L] of water (per e.g. a week) to a field with `plantA` then on average you
should get 42 [kg] of the biomass. Unfortunately after you applied the
treatment it turned out the
biomass actually dropped to 10 [kg] from a field. What happened? Reality. Most
likely you (almost) drowned your plant. Lesson to be learned here. It is unsafe
to use the model to make predictions beyond the data range on which it was
trained.  Ultimately, ["All models are wrong, but some are
useful"](https://en.wikipedia.org/wiki/All_models_are_wrong).

The above is the reason why in most cases we aren't interested in the value of
the intercept. The intercept is the value on the Y-axis when X is equal to 0, it
is necessary for our model to work, but most likely it isn't very informative
(in our case a plant that receives no water simply dies).

So what is regression good for if it only enables us to make a prediction within
the range on which it was trained? Well, if you ever underwent
[spirometry](https://en.wikipedia.org/wiki/Spirometry) then you used regression
in practice (or at least benefited from it). The functional examination of the
respiratory system goes as follows. First, you introduce your data: name, sex,
height, weight, age, etc. Then you breathe (in a manner recommended by a
technician) through a mouthpiece connected to an analyzer. Finally, you compare
your results with the ones you should have obtained. If, let's say your [vital
capacity](https://en.wikipedia.org/wiki/Vital_capacity) is equal 5.1 [L] and
should be equal to 5 [L] then it is a good sign. However, if the obtained value
is equal to 4 [L] when it should be 5 [L] (4/5 = 0.8 = 80% of norm) then you
should consult your physician. But where does the reference value come from?

One way to get it would be to rely on a large database, of let's say 100-200
million healthy individuals (a data frame with 100-200 million rows and 5-6
columns for age, gender, height, etc. that is stored on a hard drive). Then all
you have to do is to find a person (or people) whose data match yours
exactly. But this would be a great burden. For once you would have to collect
data for a lot of individuals to be pretty sure that an exact combination of
a given set of features occurs (hence the 100-200 million mentioned above). The
other problem is that such a data frame would occupy a lot of disk space and
would be slow to search through. A better solution is regression (most likely
multiple linear regression that we will cover in @sec:assoc_pred_multiple_lin_reg). In
that case you collect a smaller sample of let's say 10'000 healthy
individuals. You train your regression model.  And store it together with the
`getPrecictedY` function (where `Y` could be the discussed vital capacity). Now,
you can easily and quickly calculate the reference value for a patient even if
the exact set of features (values of predictor variables) was not in your
training data set (still, you can be fairly sure that the values of the features
of the patient would be in the range of the training data set).

Anyway, in real life whenever you want to fit a regression line in Julia you
should probably use [GLM.jl](https://juliastats.org/GLM.jl/stable/) package.
In our case an exemplary output for `plantA` looks as follows.

```jl
s1 = """
import GLM as Glm

mod1 = Glm.lm(Glm.@formula(plantAkg ~ rainL), biomass)
mod1
"""
replace(sco(s1), Regex(".*}\n\n") => "")
```

We begin with `Glm.lm(formula, dataFrame)` (`lm` stands for linear model).
Next, we specify our relationship (`Cmk.@formula`) in the form `Y ~ X`, where
`Y` is the dependent (outcome) variable, `~` is explained by, and `X` is the
independent (explanatory) variable. This fits our model (`mod1`) to the data and
yields quite some output.

The `Coef.`  column contains the values of the intercept (previously estimated
with `getIntercept`) and slope (`getSlope`). It is followed by the `Std. Error`
of the estimation (similar to the `sem` from
@sec:compare_contin_data_one_samp_ttest). Then, just like in the case of the
correlation (@sec:assoc_pred_correlation), some clever mathematical tweaking
allows us to obtain a t-statistic for the `Coef.`s and p-values for them.  The
p-values tell us if the coefficients are really different from 0 ($H_{0}$: a
`Coeff.` is equal 0) or the probability that such a big value (or bigger)
happened by chance alone (assuming that $H_{0}$ is true). Finally, we end up
with 95% confidence interval (similar to the one discussed in
@sec:compare_contin_data_hypo_tests_package) that (oversimplifying stuff) tells
us, with a degree of certainty, within what limits the true value of coefficient
in the population is.

We can use `GLM` to make our predictions as well.

```jl
s1 = """
round.(
    Glm.predict(mod1, Dfs.DataFrame(Dict("rainL" => [6, 10, 12]))),
    digits = 2
)
"""
sco(s1)
```

For that to work we feed `Glm.predict` with our model (`mod1`) and a `DataFrame`
containing a column `rainL` that was used as a predictor in our model and voila,
the results match those returned by `getPrecictedY` somewhat before in this
section.

We can also get the general impression of how imprecise our prediction is by
using the residuals (differences between the predicted and actual value on the
Y-axis). Like so

```jl
s1 = """
abs.(Glm.residuals(mod1)) |> Stats.mean
"""
sco(s1)
```

So, on average our model miscalculates the value on the Y-axis (`plantAkg`) by 2
units (here kilograms). Of course, this is slightly optimistic view, since we
expect that on a new, previously unseen data set, the prediction error will be
greater.

Moreover, the package allows us to calculate other useful stuff, like the
[coefficient of
determination](https://en.wikipedia.org/wiki/Coefficient_of_determination) that
tells us how much change in the variability on Y-axis is explained by our model
(our explanatory variable(s)).

```jl
s1 = """
(
	Glm.r2(mod1),
	Stats.cor(biomass.rainL, biomass.plantAkg) ^ 2
)
"""
sco(s1)
```

The coefficient of determination is called $r^2$ (r squared) and in this case
(simple linear regression) it is equal to the Pearson's correlation coefficient
(denoted as `r`) times itself. As we can see our model explains roughly 61% of
variability in `plantAkg` biomass.

## Multiple Linear Regression {#sec:assoc_pred_multiple_lin_reg}

Multiple linear regression is a linear regression with more than one predictor
variable. Take a look at the
[Icecream](https://vincentarelbundock.github.io/Rdatasets/doc/Ecdat/Icecream.html)
data frame.

```jl
s = """
ice = RD.dataset("Ecdat", "Icecream")
first(ice, 5)
Options(first(ice, 5), caption="Icecream consumption data.", label="icecreamDf")
"""
replace(sco(s), Regex("Options.*") => "")
```

We got 4 columns altogether (more detail in the link above):

- `Cons` - consumption of ice cream (pints),
- `Income` - average family income (USD),
- `Price` - price of ice cream (USD),
- `Temp` - temperature (Fahrenheit)

Imagine you are an ice cream truck owner and are interested to know which
factors influence (and in what way) the consumption (`Cons`) of ice-cream by
your customers. Let's start by building a model with all the possible
explanatory variables.

```jl
s1 = """
iceMod1 = Glm.lm(Glm.@formula(Cons ~ Income + Price + Temp), ice)
iceMod1
"""
replace(sco(s1), Regex(".*}\n\n") => "")
```

Right away we can see that the price of ice-cream negatively affects (`Coef.` =
-1.044) the volume of ice cream consumed (the more expensive the ice cream is
the less people eat it, 1.044 pint less for every additional USD of price). The
relationship is in line with our intuition. However, there is not enough
evidence (p > 0.05) that the real influence of `Price` on consumption isn't 0
(so no influence).  Therefore, you wonder should you perhaps remove the variable
`Price` from the model like so

```jl
s1 = """
iceMod2 = Glm.lm(Glm.@formula(Cons ~ Income + Temp), ice)
iceMod2
"""
replace(sco(s1), Regex(".*}\n\n") => "")
```

Now, we got `Income` and `Temp` in our model, both of which are statistically
significant. The values of `Coef.`s for `Income` and `Temp` somewhat changed
between the models, but such changes (and even greater) are to be expected.
Still, we would like to know if our new `iceMod2` is really better than
`iceMod1` that we came up with before.

In our first try to solve the problem we could resort to the coefficient of
determination ($r^2$) that we met in @sec:assoc_pred_simple_lin_reg. Intuition tells
us that a better model should have a bigger $r^2$.

```jl
s1 = """
round.([Glm.r2(iceMod1), Glm.r2(iceMod2)],
	digits = 3)
"""
sco(s1)
```

Hmm, $r^2$ is bigger for `iceMod1` than `iceMod2`. However, there are two
problems with it: 1) the difference between the coefficients is quite small, and
2) $r^2$ gets easily inflated by any additional variable in the model. And I
mean any, if you add, let's say 10 random variables to the `ice` data frame and
put them into model the coefficient of determination will go up even though this
makes no sense (we know their real influence is 0). That is why we got an
improved metrics called the adjusted coefficient of determination. This
parameter (adj. $r^2$) penalizes for every additional variable added to the
model. Therefore the 'noise' variables will lower the adjusted $r^2$ whereas
only truly impactful ones will be able to raise it.

```jl
s1 = """
round.([Glm.adjr2(iceMod1), Glm.adjr2(iceMod2)],
	digits = 3)
"""
sco(s1)
```

`iceMod1` still explains more variability in `Cons` (ice cream consumption) but
the magnitude of the difference dropped. This makes our decision even
harder. Luckily, `Glm` has `ftest` function to help us determine if one model is
significantly better than the other.

```jl
s1 = """
Glm.ftest(iceMod1.model, iceMod2.model)
"""
sco(s1)
```

The table contains two rows:

- `[1]` - first model from the left (in `Glm.ftest` argument list)
- `[2]` - second model from the left (in `Glm.ftest` argument list)

and a few columns:

- `DOF` - degrees of freedom (more elements in formula, bigger `DOF`)
- `ΔDOF` - `DOF[2]` - `DOF[1]`
- `SSR` - residual sum of squares (the smaller the better)
- `ΔSSR` - `SSR[2]` - `SSR[1]`
- `R2` - coefficient of determination
- `ΔR2` - `R2[2]` - `R2[1]`
- `F*` - F-Statistic (similar to the one we met in @sec:compare_contin_data_one_way_anova)
- `p(>F)` - p-value for the comparison between the two models

Based on the test we see that none of the models is clearly better from the
other (p > 0.05). Therefore, in line with [Occam's
razor](https://en.wikipedia.org/wiki/Occam%27s_razor) principle (when two
equally good explanations exist, choose the simpler one) we can safely pick
`iceMod2` as our final model.

What we did here was the construction of a so called minimal adequate model (the
smallest model that explains the greatest amount of variance in the
dependent/outcome variable). We did this using top to bottom approach. We
started with a 'full' model. Then we follow by removing explanatory variables
(one by one) that do not contribute to the model (we start from highest p-value
above 0.05) until only meaningful explanatory variables remain. The removal of
the variables reflects our common sense, because usually we (or others that will
use our model) do not want to spend time/money/energy on collecting data that
are of no use to us.

OK, let's inspect our minimal adequate model again.

```jl
s1 = """
[(cn, round(c, digits = 4)) for (cn, c) in
     zip(Glm.coefnames(iceMod2), Glm.coef(iceMod2))]
"""
sco(s1)
```

We can see that for every extra dollar of `Income` our customer consumes 0.003
pint (~1.47 mL) of ice cream more. Roughly the same change is produced by each
additional grade (in Fahrenheit) of temperature. So, a simultaneous increase in
`Income` by 1 USD and `Temp` by 1 unit translates into roughly 0.003 + 0.003 =
0.006 (~2.94 mL) greater consumption of ice cream per person. Now, (remember you
were to imagine you are an ice cream truck owner) you could use the model to
make predictions (with `Glm.predict` as we did in @sec:assoc_pred_simple_lin_reg) to
your benefit (e.g. by preparing enough product for your customers on a hot day).

So the time passes by and one sunny day when you open a bottle of beer a drunk
genie pops out of it. To compensate you for the lost beer he offers to fulfill
one wish. He won't give you cash right away since you will not be able to
explain it to the tax office. Instead, he will give you the ability to control
either `Income` or `Temp` variable at will. That way you will get your money and
none is the wiser. Which one do you choose, answer quickly, before the genie
changes his mind.

Hmm, now that's a dilemma, but judging by the coefficients above it seems it
doesn't make much of a difference (both `Coef.`s are roughly equal to 0.0035).
Or does it? Well, the `Coef.`s are similar, but we are comparing incomparable,
i.e.  dollars (`Income`) with degrees Fahrenheit (`Temp`) and their influence on
`Cons`. We may however, [standardize the
coefficients](https://en.wikipedia.org/wiki/Standardized_coefficient) to
overcome the problem.

```jl
s1 = """
# fn from ch04
# how many std. devs is a value above or below the mean
function getZScore(value::Real, mean::Real, sd::Real)::Float64
	return (value - mean)/sd
end

# adding new columns to the data frame
ice.ConsStand = getZScore.(
	ice.Cons, Stats.mean(ice.Cons), Stats.std(ice.Cons))
ice.IncomeStand = getZScore.(
	ice.Income, Stats.mean(ice.Income), Stats.std(ice.Income))
ice.TempStand = getZScore.(
	ice.Temp, Stats.mean(ice.Temp), Stats.std(ice.Temp))

iceMod2Stand = Glm.lm(
	Glm.@formula(ConsStand ~ IncomeStand + TempStand), ice)
iceMod2Stand
"""
replace(sco(s1), Regex(".*}\n\n") => "")
```

When expressed on the same scale (using `getZScore` function we met in
@sec:statistics_intro_distributions_package) it becomes clear that the `Temp`
(`Coef.` ~0.884) is a much more influential factor with regards to ice cream
consumption (`Cons`) than `Income` (`Coef.` ~0.335). Therefore, we can be pretty
sure that modifying the temperature by 1 standard deviation (which should not
attract much attention) will bring you more money than modifying customers
income by 1 standard deviation. Thanks genie.

Let's look at another example of regression to get a better feel of it and
discuss categorical variables and an interaction term in the model. We will
operate on
[agefat](https://vincentarelbundock.github.io/Rdatasets/doc/HSAUR/agefat.html)
data frame.

```jl
s = """
agefat = RD.dataset("HSAUR", "agefat")
Options(first(agefat, 5), caption="Total body composition.", label="agefatDf")
"""
replace(sco(s), Regex("Options.*") => "")
```

Here we are interested to predict body fat percentage (`Fat`) from the other two
variables. Let's get down to business.

```jl
s1 = """
agefatM1 = Glm.lm(Glm.@formula(Fat ~ Age + Sex), agefat)
agefatM1
"""
replace(sco(s1), Regex(".*}\n\n") => "")
```

It appears that the older a person is the more fat it has (+0.27% of body fat
per 1 extra year of age). Moreover, male subjects got smaller percentage of body
fat (on average by 10.5%) than female individuals (this is to be expected: [see
here](https://en.wikipedia.org/wiki/Body_fat_percentage)). In the case of
categorical variables the reference group is the one that comes first in the
alphabet (here `female` is before `male`). The internals of the model assign 0
to the reference group and 1 to the other group. This yields us the formula: $y
= a + b*x + c*z$ or $Fat = a + b*Age + c*Sex$, where `Sex` is 0 for `female` and
1 for `male`. As before we can use this formula for prediction (either write one
of our own or use `Glm.predict` we met before).

We may also want to fit a model with an interaction term to see if we gain some
additional precision in our predictions.

```jl
s1 = """
# or shortcut: Glm.@formula(Fat ~ Age * Sex)
agefatM2 = Glm.lm(Glm.@formula(Fat ~ Age + Sex + Age&Sex), agefat)
agefatM2
"""
replace(sco(s1), Regex(".*}\n\n") => "")
```

Here, we do not have enough evidence that the interaction term (`Age & Sex:
male`) matters (p > 0.05). Still, let's explain what is this interaction in case
you ever find one that is important. For that, take a look at the graph below.

![Body fat percentage vs. Age and Sex](./images/ch07agefat.png){#fig:ch07agefat}

As you can see the model without interaction fits two regression lines (one for
each `Sex`) with different intercepts, but the same slopes. On the other hand,
the model with interaction fits two regression lines (one for each `Sex`) with
different intercepts and different slopes. Since the coefficient (`Coef.`) for
the interaction term (`Age & Sex: male`) is positive, this means that the slope
for `Sex: male` is more steep (more positive).

So, when to use the interaction term in your model? The advice I heard was that
in general, you should construct simple models and only use interaction when
there are some good reasons for it. For instance, in the discussed case
(`agefat` data frame), we might wanted to know if the accretion of body fat
occurs faster in one of the genders as the people age.

## Exercises - Association and Prediction {#sec:assoc_pred_exercises}

Just like in the previous chapters here you will find some exercises that you
may want to solve to get from this chapter as much as you can (best
option). Alternatively, you may read the task descriptions and the solutions
(and try to understand them).

### Exercise 1 {#sec:assoc_pred_ex1}

The `RDatasets` package mentioned in @sec:assoc_pred_corr_pitfalls contains a
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

```
getRanks([500, 100, 1000]) # returns [2.0, 1.0, 3.0]
getRanks([500, 100, 500, 1000]) # returns [2.5, 1.0, 2.5, 4.0]
getRanks([500, 100, 500, 1000, 500]) # returns [3.0, 1.0, 3.0, 5.0, 3.0]
# etc.
```

Personally, I found
[findall](https://docs.julialang.org/en/v1/base/arrays/#Base.findall-Tuple{Function,%20Any})
and [sort](https://docs.julialang.org/en/v1/base/sort/#Base.sort)
to be useful while writing `getRanks`, but feel free to employ whatever
constructs you want. Anyway, once you got it, you can apply it to get Spearman's
correlation coefficient (`getCorAndPval(getRanks(v1), getRanks(v2))`).

> **_Note:_** In real life to calculate the coefficient you would probably use
> [StatsBase.corspearman](https://juliastats.org/StatsBase.jl/stable/ranking/#StatsBase.corspearman).

### Exercise 2 {#sec:assoc_pred_ex2}

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

### Exercise 3 {#sec:assoc_pred_ex3}

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

### Exercise 4 {#sec:assoc_pred_ex4}

Regression just like other methods mentioned in this book got its
[assumptions](https://en.wikipedia.org/wiki/Regression_analysis#Underlying_assumptions)
that if possible should be verified. The R programming language got a
[plot.lm](https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/plot.lm)
function to verify them graphically. The two most important plots (or at least
the ones that I understand the best) are scatter-plot of residuals vs. fitted
values and [Q-Q plot](https://en.wikipedia.org/wiki/Q%E2%80%93Q_plot) of
standardized residuals (see @fig:ch07ex4v1 below).

![Diagnostic plot for regression model (ageFatM1).](./images/ch07ex4v1.png){#fig:ch07ex4v1}

If the assumptions hold, then the points in residuals vs. fitted plot should be
randomly scattered around 0 (on Y-axis) with equal spread of points from left to
right and no apparent pattern visible. On the other hand, the points in Q-Q plot
should lie along the Q-Q line which indicates their normal distribution. To me
(I'm not an expert though) the above seem to hold in @fig:ch07ex4v1 above. If
that was not the case then we should try to correct our model. We might
transform one or more variables (for instance by using `log10` function
we met in @sec:assoc_pred_ex1) or fit a different model. Otherwise, the
model we got may give poor predictions. For instance, if our residuals
vs. fitted plot displayed a greater spread of points on the right side of
X-axis, then most likely our predictions would be more off for large values of
explanatory variable(s).

Anyway, your task here is to write a function `drawDiagPlot` that accepts a
linear regression model and returns a graph similar to @fig:ch07ex4v1 above
(when called with `ageFatM1` as an input).

Below you will find some (but not all) of the functions that I found useful
while solving this task (feel free to use whatever functions you want):

- `Glm.predict`
- `Glm.residuals`
- `string(Glm.formula(mod))`
- `Cmk.qqplot`

The rest is up to you.

### Exercise 5 {#sec:assoc_pred_ex5}

While developing the solution to exercise 4 (@sec:assoc_pred_ex4_solution) we
pointed out on the flaws of `iceMod2`. We decided to develop a better model. So,
here is a task for you.

Read about [constructing formula
programmatically](https://juliastats.org/StatsModels.jl/stable/formula/#Constructing-a-formula-programmatically-1)
using `StatsModels` package (`GLM` uses it internally).

Next, given the `ice2` data frame below.

```jl
s1 = """
Rand.seed!(321)

ice = RD.dataset("Ecdat", "Icecream") # reading fresh data frame
ice2 = ice[2:end, :] # copy of ice data frame
# an attempt to remove autocorrelation from Temp variable
ice2.TempDiff = ice.Temp[1:(end-1)] .- ice.Temp[2:end]

# dummy variables aimed to confuse our new function
ice2.a = Rand.rand(-100:1:100, 29)
ice2.b = Rand.rand(-100:1:100, 29)
ice2.c = Rand.rand(-100:1:100, 29)
ice2.d = Rand.rand(-100:1:100, 29)
ice2
"""
sc(s1)
```

Write a function that return the minimal adequate model.

```
function getMinAdeqMod(
    df::Dfs.DataFrame, y::String, xs::Vector{<:String}
    )::Glm.StatsModels.TableRegressionModel
```

The function accepts a data frame (`df`), name of the outcome variable (`y`),
and names of the explanatory variables (`xs`). In its insides the functions
builds a full additive model (`y ~ x1 + x2 + ... + etc.`). Then, it eliminates
an `x` (predictor variable) with the greatest p-value (only if it is greater
than 0.05). The removal process is continued for all `xs` until only `xs` with
p-values $\le 0.05$ remain. If none of the `xs` is impactful it should return
the model in the form `y ~ 1` (the intercept of this model is equal to
`Stats.mean(y)`). Test it out, e.g. for
`getMinAdeqMod(ice2, names(ice2)[1], names(ice2)[2:end])` it should return a
model in the form `Cons ~ Income + Temp + TempDiff`.

*Hint: You can extract p-values for the coeficients of the model with
`Glm.coeftable(m).cols[4]`. `GLM` got its own function for constructing model
terms (`Glm.term`). You can add the terms either using `+` operator or `sum`
function (if you got a vector of terms).*

## Solutions - Association {#sec:assoc_pred_exercises_solutions}

In this sub-chapter you will find exemplary solutions to the exercises from the
previous section.

### Solution to Exercise 1 {#sec:assoc_pred_ex1_solution}

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

### Solution to Exercise 2 {#sec:assoc_pred_ex2_solution}

The solution should be quite simple assuming you did solve exercise 4 from ch05
(see @sec:compare_contin_data_ex4 and @sec:compare_contin_data_ex4_solution) and
exercise 5 from ch06 (see @sec:compare_categ_data_ex5 and
@sec:compare_categ_data_ex5_solution).

For it we are going to use two helper functions, `getUniquePairs`
(@sec:compare_contin_data_ex4_solution) and `getSortedKeysVals`
(@sec:statistics_prob_distribution) developed previously. For your convenience
I paste them below.

```
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
```

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

### Solution to Exercise 3 {#sec:assoc_pred_ex3_solution}

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
previously (@sec:assoc_pred_ex2_solution). Then we define the matrix (our
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

```
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
```

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

```
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
```

The only new element here is `Cmk.text!` function but since we used it a couple
of times throughout this book, then I will leave the explanation of how the code
piece works for you. Anyway, the result is to be found below.

![Correlation heatmap for data in `bogusCors` with the coefficients and significance markers.](./images/ch07ex3v2.png){#fig:ch07ex3v2}

It looks good. Also the number of significance markers is right. Previously
(@sec:assoc_pred_ex2_solution) we said we got 3 significant correlations (based
on 'raw' p-values). Since, the upper right triangle of the heatmap is a mirror
reflection of the lower left triangle, then we should see 6 significance markers
altogether.

### Solution to Exercise 4 {#sec:assoc_pred_ex4_solution}

OK, the code for this task is quite straightforward so let's get right to it.

```
function drawDiagPlot(
    reg::Glm.StatsModels.TableRegressionModel,
    byCol::Bool = true)::Cmk.Figure
    dim::Vector{<:Int} = (byCol ? [1, 2] : [2, 1])
    res::Vector{<:Float64} = Glm.residuals(reg)
    pred::Vector{<:Float64} = Glm.predict(reg)
    form::String = string(Glm.formula(reg))
    fig = Cmk.Figure(size=(800, 800))
    Cmk.scatter(fig[1, 1], pred, res,
        axis=(;
            title="Residuals vs Fitted\n" * form,
            xlabel="Fitted values",
            ylabel="Residuals")
    )
    Cmk.hlines!(fig[1, 1], 0, linestyle=:dash, color="gray")
    Cmk.qqplot(fig[dim...],
        Dsts.Normal(0, 1),
        getZScore.(res, Stats.mean(res), Stats.std(res)),
        qqline=:identity,
        axis=(;
            title="Normal Q-Q\n" * form,
            xlabel="Theoretical Quantiles",
            ylabel="Standarized residuals")
    )
    return fig
end
```

We begin with extracting residuals (`res`) and predicted (`pred`) values from
our model (`reg`). Additionally, we extract the formula (`form`) as a
string. Then, we prepare a scatter plot (`Cmk.scatter`) with `pred` and `res`
placed on X- and Y-axis, respectively. Next, we add a horizontal line
(`Cmk.hlines!`) at 0 on Y-axis (the points should be randomly scattered around
it). All that's left to do is to build the required Q-Q plot (`qqplot`) with
X-axis that contains the theoretical [standard normal
distribution](https://en.wikipedia.org/wiki/Normal_distribution#Standard_normal_distribution)
(`Dsts.Normal(0, 1)`) and Y-axis with the standardized (`getZScore`) residuals
(`res`). We also add `qqline=:identity` (here, identity means x = y) to
facilitate the interpretation [if two distributions (on X- and Y-axis)] are
alike then the points should lie roughly on the line. Since the visual
impression we get may depend on the spacial arrangement (stretching or tightening
of the points on a graph) our function enables us to choose (`byCol`) between
column (`true`) and row (`false`) alignment of the subplots.

For a change let's test our function on the `iceMod2` from
@sec:assoc_pred_multiple_lin_reg. Behold the result of `drawDiagPlot(iceMod2, false)`.

![Diagnostic plot for regression model (iceMod2).](./images/ch07ex4v2.png){#fig:ch07ex4v2}

Hmm, I don't know about you but to me the bottom panel looks rather
normal. However, the top panel seems to display a wave ('w') pattern. This may
be a sign of auto-correlation (explanation in a moment) and translate into
instability of the error in estimation produced by the model across the values
of the explanatory variable(s). The error will display a wave pattern (once
bigger once smaller). Now we got a choice, either we leave this model as it is
(and we bear the consequences) or we try to find a better one.

To understand what the auto-correlation means in our case let's do a thought
experiment. Right now in the room that I am sitting the temperature is equal to
20 degrees of Celsius (68 deg. Fahrenheit). Which one is the more probable value
of the temperature in 1 minute from now: 0 deg. Cels. (32 deg. Fahr.) or 21
deg. Cels. (70 deg. Fahr.)? I guess the latter is the more reasonable
option. That is because the temperature one minute from now is a derivative of
the temperature at present (i.e. both values are correlated).

The same might be true for
[Icecream](https://vincentarelbundock.github.io/Rdatasets/doc/Ecdat/Icecream.html)
data frame, since it contains `Temp` column that we used in our model
(`iceMod2`). We could try to remedy this by removing (kind of) the
auto-correlation, e.g. with `ice2 = ice[2:end, :]` and
`ice2.TempDiff = ice.Temp[1:(end-1)] .- ice.Temp[2:end]` and building our model
a new. This is what we will do in the next exercise (although we will try to
automate the process a bit).

### Solution to Exercise 5 {#sec:assoc_pred_ex5_solution}

Let's start with a few helper functions.

```jl
s1 = """
function getLmMod(
    df::Dfs.DataFrame,
    y::String, xs::Vector{<:String}
    )::Glm.StatsModels.TableRegressionModel
    return Glm.lm(Glm.term(y) ~ sum(Glm.term.(xs)), df)
end

function getPredictorsPvals(
    m::Glm.StatsModels.TableRegressionModel)::Vector{<:Float64}
    allPvals::Vector{<:Float64} = Glm.coeftable(m).cols[4]
    # 1st pvalue is for intercept
    return allPvals[2:end]
end

function getIndsEltsNotEqlM(v::Vector{<:Real}, m::Real)::Vector{<:Int}
    return findall(x -> !isapprox(x, m), v)
end
"""
sc(s1)
```

We begin with `getLmMod` that accepts a data frame (`df`), name of the dependent
variable (`y`) and names of the independent/predictor variables (`xs`). Based on
the inputs it creates the model programmatically using `Glm.term`.

Next, we go with `getPredictorsPvals` that returns the p-values corresponding to
a model's coefficients.

Then, we define `getIndsEltsNotEqlM` that we will use to filter out the highest
p-value from our model.

OK, time for the main actor of the show.

```jl
s1 = """
# returns minimal adequate model
function getMinAdeqMod(
    df::Dfs.DataFrame, y::String, xs::Vector{<:String}
    )::Glm.StatsModels.TableRegressionModel

    preds::Vector{<:String} = copy(xs)
    mod::Glm.StatsModels.TableRegressionModel = getLmMod(df, y, preds)
    pvals::Vector{<:Float64} = getPredictorsPvals(mod)
    maxPval::Float64 = maximum(pvals)
    inds::Vector{<:Int} = getIndsEltsNotEqlM(pvals, maxPval)

    for _ in xs
        if (maxPval <= 0.05)
            break
        end
        if (length(preds) == 1 && maxPval > 0.05)
            mod = Glm.lm(Glm.term(y) ~ Glm.term(1), df)
            break
        end
        preds = preds[inds]
        mod = getLmMod(df, y, preds)
        pvals = getPredictorsPvals(mod)
        maxPval = maximum(pvals)
        inds = getIndsEltsNotEqlM(pvals, maxPval)
    end

    return mod
end
"""
sc(s1)
```

We begin with defining the necessary variables that we will update in a for
loop.  The variables are: predictors (`preds`), linear model (`mod`), p-values
for the model's coefficients (`pvals`), maximum p-value (`maxPval`) and indices
of predictors that we will leave in our model (`inds`). We start each iteration
(`for _ in xs`) by checking if we already reached our minimal adequate model. To
that end we make sure that all the remaining coefficients are statistically
significant (`if (maxPval <= 0.05)`) or if we run out of the explanatory
variables (`length(preds) == 1 && maxPval > 0.05`) we return our default
(`y ~ 1`) model (the intercept of this model is equal to `Stats.mean(y)`). If
not then we remove one predictor variable from the model (`preds = preds[inds]`)
and update the remaining helper variables (`mod`, `pvals`, `maxPval`,
`inds`). And that's it, let's see how it works.

```jl
s1 = """
ice2mod = getMinAdeqMod(ice2, names(ice2)[1], names(ice2)[2:end])
"""
replace(sco(s1), Regex(".*}\n\n") => "")
```

It appears to work as expected. Let's compare it with a full model.

```jl
s1 = """
ice2FullMod = getLmMod(ice2, names(ice2)[1], names(ice2)[2:end])

Glm.ftest(ice2FullMod.model, ice2mod.model)
"""
sco(s1)
```

It looks good as well. We reduced the number of explanatory variables while
maintaining comparable (p > 0.05) explanatory power of our our model.

Time to check the assumptions with our diagnostic plot (`drawDiagPlot` from
@sec:assoc_pred_ex1_solution).

![Diagnostic plot for regression model (ice2mod).](./images/ch07ex5.png){#fig:ch07ex5}

To me, the plot has slightly improved.

Now, let's compare our `ice2mod`, that aimed to counteract the auto-correlation,
with its predecessor (`iceMod2`). We will focus on the explanatory powers
(adjusted $r^2$, the higher the better)

```jl
s1 = """
(
	Glm.adjr2(iceMod2),
	Glm.adjr2(ice2mod)
)
"""
sco(s1)
```

and the average prediction errors (the lower the better).

```jl
s1 = """
(
	abs.(Glm.residuals(iceMod2)) |> Stats.mean,
	abs.(Glm.residuals(ice2mod)) |> Stats.mean
)
"""
sco(s1)
```

Again, it appears that we managed to improve our model.

At a very long last we may check how our `getMinAdeqMod` will behave when there
are no meaningful explanatory variables.

```jl
s1 = """
getMinAdeqMod(ice2, "Cons", ["a", "b", "c", "d"])
"""
replace(sco(s1), Regex(".*}\n\n") => "")
```

In that case (no meaningful explanatory variables) our best estimate of `y`
(here `Cons`) is the variable's average (`Stats.mean(ice2.Cons)`) which is
returned as the `Coef.` for `(Intercept)`. In that case `Std. Error` is just the
standard error of the mean that we met in
@sec:compare_contin_data_one_samp_ttest (compare with `getSem(ice2.Cons)`).
