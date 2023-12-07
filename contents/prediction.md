# Prediction {#sec:prediction}

OK, time to talk about prediction of a variable value based on the value(s) of
other variable(s).

## Chapter imports {#sec:prediction_imports}

Later in this chapter we are going to use the following libraries

```jl
s8 = """
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import GLM as Glm
import RDatasets as RD
import Statistics as Stats
"""
sc(s8)
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

## Simple Linear Regression {#sec:pred_simple_lin_reg}

We began previous chapter (@sec:association_lin_relation) with the relation
between water fall volume and biomass of two plants of amazon rain forest. Let's
revisit the problem.

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
goes through their center. Now, we could draw that line with pen and paper (or a
graphics editor) and based on the line make a prediction of the values on Y-axis
based on the values on the X-axis. The variable placed on the X-axis is called
independent (the rain does not depend on a plant, it falls or not) or predictor
variable. The variable placed on the Y-axis is called dependent (the plant
depends on rain) or outcome variable. The problem with drawing the line by hand
is that it wouldn't be reproducible, a line drawn by the same person would
differ slightly from draw to draw. The same is true if a few different people
have undertaken this task. Luckily, we got a [simple linear
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
@sec:association_covariance. The difference is that there we divided
`sum(diffs1 .* diffs2)` (here we called it `sum(diffsXs .* diffsYs)`) by the the
degrees of freedom (`length(v1) - 1`) and here we divide it by
`sum(diffsXs .^ 2)`. Although, we might not have come up with the formula
ourselves, still, it makes sense given that we are looking for the value by
which y increases/decreases when x changes by on unit.

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
based on the correlation coefficients from @sec:association_correlation we know
that the estimate for `plantB` is less precise. This is because the smaller
correlation coefficient means a greater spread of the points along the line as
can be seen in the figure below.

<pre>
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
</pre>

![Effect of rainfall on plants' biomass with trend line.](./images/ch08biomassCor.png){#fig:ch08biomassCor}

The trend line is placed more or less where we would have placed it by hand, so
I guess we got our functions right.

Now we can either use the graph (@fig:ch08biomassCor) and read the expected
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
multiple linear regression that we will cover in @sec:pred_multiple_lin_reg). In
that case you collect a smaller sample of let's say 15'000 healthy
individuals. You train your regression model.  And store it together with the
`getPrecictedY` function (where `Y` could the discussed vital capacity). Now,
you can easily and quickly calculate the reference value for a patient even if
the exact set of features (values of predictor variables) was not in your
training data set (still, you can be fairly sure that the values of the features
of the patient would be in the range of the training data set).

Anyway, in real life whenever you want to fit a regression line in Julia you
should probably use [GLM.jl](https://juliastats.org/GLM.jl/stable/) package.
In our case an exemplary output for `plantA` looks like follows.

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
correlation (@sec:association_correlation), some clever mathematical tweaking
allows us to obtain a t-statistic for the `Coef.`s and p-values for them.  The
p-values tell us if the coefficients are really different from 0 ($H_{0}$: a
`Coeff.` is equal 0) or the probability that such a big value (or bigger)
happened by chance alone (assuming that $H_{0}$ is true). Finally, we end up
with 95% confidence interval (similar to the one discussed in
@sec:compare_contin_data_hypo_tests_package) that (simplifying stuff) tells us,
with a degree of certainty, within what limits the true value of coefficient in
the population is.

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
(simple linear regression) is equal to the Pearson's correlation coefficient
(denoted as `r`) times itself. As we can see our model explains roughly 61% of
variability in `plantAkg` biomass.

## Multiple Linear Regression {#sec:pred_multiple_lin_reg}

Multiple linear regression is a linear regression with more than one predictor
variables. Take look at the
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
- `Temp` - average temp. (Fahrenheit)

Imagine you are a ice cream truck owner and are interested to know which factors
influence (and in what way) the consumption (`Cons`) of ice-cream. Let's start
building a model with all the possible explanatory variables.

```jl
s1 = """
iceMod1 = Glm.lm(Glm.@formula(Cons ~ Income + Price + Temp), ice)
iceMod1
"""
replace(sco(s1), Regex(".*}\n\n") => "")
```

Right away we can see that the price of ice-cream negatively affects (`Coef.` =
-1.044) the volume of ice cream consumed (the more expensive the ice cream the
less people eat it, 1.044 pint less for every USD of price). The relationship,
however is not statistically significant at our customary cutoff level (p >
0.05). Therefore we can safely remove it from the model. That's because usually
we (or others that will use our model) do not want to spend time/money/energy on
collecting data that are of no use for us.

```jl
s1 = """
iceMod2 = Glm.lm(Glm.@formula(Cons ~ Income + Temp), ice)
iceMod2
"""
replace(sco(s1), Regex(".*}\n\n") => "")
```

Much better, now we got `Income` and `Temp` in our model, both of which are
statistically significant. We can end here, since we got a so called minimal
adequate model (the smallest model that explains the greatest amount of variance
in the dependent/outcome variable). Notice that the values of `Coef.`s may
somewhat change between the consecutive models, but that is to be expected. Here,
we see that for every extra dollar of `Income` a family consumes 0.003 pint ice
cream more (~1.47 mL). Roughly the same change is produced by each additional
grade (in Fahrenheit) of temperature. So a simultaneous increase in `Income` by
1 unit and `Temp` by 1 unit translates into roughly 0.003 + 0.003 = 0.006 (~2.94
mL) greater consumption of ice cream per person.

Now, we could use our model to make predictions (with `Glm.predict` as we did in
@sec:pred_simple_lin_reg) but instead we would like to know if our new `iceMod2`
is really better than `iceMod1` that we came up with in the first place. Our
first, try would be to use the coefficient of determination ($r^2$) that we met
in @sec:pred_simple_lin_reg. Intuition tells us that a better model should have
a bigger $r^2$.

```jl
s1 = """
round.([Glm.r2(iceMod1), Glm.r2(iceMod2)],
	digits = 3)
"""
sco(s1)
```

Hmm, $r^2$ is slightly bigger for `iceMod1` than `iceMod2`. That's odd, the
models differ only by 1 explanatory variable (`iceMod1` got `Price` in it). but
we said that the variable is not important for the model (p > 0.05). The problem
with $r^2$ is that it gets inflated by any additional variable in the model. And
I mean any, if you add, let's say 10 random variables to the `ice` data frame
and put them into model the coefficient of determination will go up even though
this makes no sense. That is why we got an improved metrics called adjusted
coefficient of determination. This parameter (adj. $r^2$) penalizes for every
additional variable added to the model. Therefore the 'noise' variables will
lower the adjusted $r^2$ whereas only truly impactful ones will be able to raise
it.

```jl
s1 = """
round.([Glm.adjr2(iceMod1), Glm.adjr2(iceMod2)],
	digits = 3)
"""
sco(s1)
```

`iceMod1` still explains slightly more variability in `Cons` (ice cream
consumption) but the magnitude of the difference dropped. Let's use a formal
test to compare both models.

```jl
s1 = """
Glm.ftest(iceMod1.model, iceMod2.model)
"""
sco(s1)
```

To be continued ...

