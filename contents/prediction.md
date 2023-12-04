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
