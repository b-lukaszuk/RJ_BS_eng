# Prediction {#sec:prediction}

OK, time to talk about prediction of a variable value based on the value(s) of
other variable(s).

## Chapter imports {#sec:prediction_imports}

Later in this chapter we are going to use the following libraries

```jl
s8 = """
import CairoMakie as Cmk
import DataFrames as Dfs
import GLM as Glm
import Random as Rand
import RDatasets as RD
import Statistics as Stats
"""
sc(s8)
```

If you want to follow along you should have them installed on your system. A
reminder of how to deal (install and such) with packages can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/). But wait, you may prefer
to use `Project.toml` and `Manifest.toml` files from the [code snippets for this
chapter](https://github.com/b-lukaszuk/RJ_BS_eng/tree/main/code_snippets/ch08)
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

We began the previous chapter (@sec:association_lin_relation) with describing
the relation between water fall volume and biomass of two plants of amazon rain
forest. Let's revisit the problem.

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
@sec:association_covariance. The difference is that there we divided
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
based on the correlation coefficients from @sec:association_correlation we know
that the estimate for `plantB` is less precise. This is because the smaller
correlation coefficient means a greater spread of the points along the line as
can be seen in the figure below.

<pre>
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

The trend line is placed more or less where we would have placed it at a rough
guess, so it seems we got our functions right.

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
correlation (@sec:association_correlation), some clever mathematical tweaking
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
import DataFrames as Dfs

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

## Multiple Linear Regression {#sec:pred_multiple_lin_reg}

Multiple linear regression is a linear regression with more than one predictor
variable. Take a look at the
[Icecream](https://vincentarelbundock.github.io/Rdatasets/doc/Ecdat/Icecream.html)
data frame.

```jl
s = """
import RDatasets as RD

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
determination ($r^2$) that we met in @sec:pred_simple_lin_reg. Intuition tells
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
make predictions (with `Glm.predict` as we did in @sec:pred_simple_lin_reg) to
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

![Body fat percentage vs. Age and Sex](./images/ch08agefat.png){#fig:ch08agefat}

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

## Exercises - Prediction {#sec:prediction_exercises}

Just like in the previous chapters here you will find some exercises that you
may want to solve to get from this chapter as much as you can (best
option). Alternatively, you may read the task descriptions and the solutions
(and try to understand them).

### Exercise 1 {#sec:prediction_ex1}

Regression just like other methods mentioned in this book got its
[assumptions](https://en.wikipedia.org/wiki/Regression_analysis#Underlying_assumptions)
that if possible should be verified. The R programming language got a
[plot.lm](https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/plot.lm)
function to verify them graphically. The two most important plots (or at least
the ones that I understand the best) are scatter-plot of residuals vs. fitted
values and [Q-Q plot](https://en.wikipedia.org/wiki/Q%E2%80%93Q_plot) of
standardized residuals (see @fig:ch08ex1v1 below).

![Diagnostic plot for regression model (ageFatM1).](./images/ch08ex1v1.png){#fig:ch08ex1v1}

If the assumptions hold, then the points in residuals vs. fitted plot should be
randomly scattered around 0 (on Y-axis) with equal spread of points from left to
right and no apparent pattern visible. On the other hand, the points in Q-Q plot
should lie along the Q-Q line which indicates their normal distribution. To me
(I'm not an expert though) the above seem to hold in @fig:ch08ex1v1 above. If
that was not the case then we should try to correct our model. We might
transform one or more variables (for instance by using `log10` function
we met in @sec:association_ex1) or fit a different model. Otherwise, the
model we got may give poor predictions. For instance, if our residuals
vs. fitted plot displayed a greater spread of points on the right side of
X-axis, then most likely our predictions would be more off for large values of
explanatory variable(s).

Anyway, your task here is to write a function `drawDiagPlot` that accepts a
linear regression model and returns a graph similar to @fig:ch08ex1v1 above
(when called with `ageFatM1` as an input).

Below you will find some (but not all) of the functions that I found useful
while solving this task (feel free to use whatever functions you want):

- `Glm.predict`
- `Glm.residuals`
- `string(Glm.formula(mod))`
- `Cmk.qqplot`

The rest is up to you.

### Exercise 2 {#sec:prediction_ex2}

While developing the solution to exercise 1 (@sec:prediction_ex1_solution) we
pointed out on the flaws of `iceMod2`. We decided to develop a better model. So,
here is a task for you.

Read about [constructing formula
programmatically](https://juliastats.org/StatsModels.jl/stable/formula/#Constructing-a-formula-programmatically-1)
using `StatsModels` package (`GLM` uses it internally).

Next, given the `ice2` data frame below.

```jl
s1 = """
import Random as Rand
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

<pre>
function getMinAdeqMod(
    df::Dfs.DataFrame, y::String, xs::Vector{<:String}
    )::Glm.StatsModels.TableRegressionModel
</pre>

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

*Hint: `GLM` got its own function for constructing model terms (`Glm.term`). You
can add the terms either using `+` operator or `sum` function (if you got a
vector of terms).*

## Solutions - Prediction {#sec:prediction_exercises_solutions}

In this sub-chapter you will find exemplary solutions to the exercises from the
previous section.

### Solution to Exercise 1 {#sec:prediction_ex1_solution}

OK, the code for this task is quite straightforward so let's get right to it.

<pre>
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
</pre>

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
@sec:pred_multiple_lin_reg. Behold the result of `drawDiagPlot(iceMod2, false)`.

![Diagnostic plot for regression model (iceMod2).](./images/ch08ex1v2.png){#fig:ch08ex1v2}

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

To be continued ...
