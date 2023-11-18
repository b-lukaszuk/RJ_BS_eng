# Association and Prediction {#sec:assoc_and_pred}

OK, time for the last technical chapter of this book, as the title suggests it's
going to be concerned about association and prediction.

## Chapter imports {#sec:assoc_and_pred_data_imports}

Later in this chapter we are going to use the following libraries

```jl
s = """
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import Statistics as Stats
"""
sc(s)
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

## Association {#sec:assoc_and_pred_association}

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
Options(first(biomass, 5), caption="Effect of rainfall on plants biomass.", label="biomassDf")
"""
replace(sco(s1), Regex("Options.*") => "")
```

I think some plot would be helpful to get a better picture of the data.


```jl
s = """
import CairoMakie as Cmk

fig = Cmk.Figure()
ax1, sc1 = Cmk.scatter(fig[1, 1], biomass.rainL, biomass.plantAkg,
    axis=(; title="Effect of rainfall on biomass of plant A",
        xlabel="water [L]", ylabel="biomass [kg]"),
    markersize=25, color="skyblue", strokewidth=1, strokecolor="gray")
ax2, sc2 = Cmk.scatter(fig[1, 2], biomass.rainL, biomass.plantBkg,
    axis=(; title="Effect of rainfall on bomass of plant B",
        xlabel="water [L]", ylabel="biomass [kg]"),
    markersize=25, color="linen", strokewidth=1, strokecolor="black")
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
line that goes through all the points on a graph and that `plantB` has a
somewhat greater spread. It would be nice to be able to express such a relation
between two variables (here biomass and volume of rain) with a single number.
It turns out that we can. That's the job for
[covariance](https://en.wikipedia.org/wiki/Covariance).

### Covariance {#sec:assoc_and_pred_covariance}

The formula for covariance resembles the one for `variance` that we met in
@sec:statistics_normal_distribution (`getVar` function) only that it is
calculated for pairs of values, so two vectors instead of one. Observe

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
squared the differences (`diffs`), i.e. we multiplied the values by themselves
($x * x = x^2$). Here, we achieve that by multiplying parallel values from each
vector by each other ($x * y$, we multiply a biomass value for a given field by
the volume of rainfall for that exact field). Moreover, instead of taking the
average (so `sum(diffs1 .*  diffs2)/length(v1)`) here we use the more fine tuned
statistical formula that relies on degrees of freedom we met in
@sec:compare_contin_data_one_samp_ttest (there we used `getDf` function, here we
kind of use `getDf` for the number of fields that are represented by the points
in @fig:ch07biomassCor).

Enough explanation, let's see how it works. First, let's see a few possible
associations that roughly take the following shapes: `/`, `\`, `|` and `-`.

```jl
s = """
rowLenBiomass, _ = size(biomass)

(
	getCov(biomass.plantAkg, biomass.rainL), # /
	getCov(biomass.plantAkg, biomass.plantAkg[end:-1:1]), # \\
	getCov(biomass.plantAkg, repeat([5], rowLenBiomass)), # |
	getCov(repeat([5], rowLenBiomass), biomass.rainL) # -
)
"""
sco(s)
```

We can see that whenever both variables (on X- and on Y-axis) increase
simultaneously (points lie alongside `/` imaginary line like in
@fig:ch07biomassCor) then the covariance is positive. If one variable increases
whereas the other decreases (points lie alongside `\` imaginary line) then the
covariance is negative. Whereas in the case when one variable changes and the
other is stable (points lie alongside `|` or `-` line) the covariance is equal
zero.

OK, time to compare are both plants.

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

Just like greater the `variance` (and `standard deviation`) expressed the
greater spread of points around the mean in @sec:statistics_normal_distribution
here the greater covariance expresses the greater spread of the points around
the imaginary trend line (in @fig:ch07biomassCor). Now, the covariance for
`plantB` is like 9% greater than the covariance for `plantA`
 (`round(covPlantB/covPlantA * 100, digits=2)` =
  `jl round(covPlantB/covPlantA * 100, digits=2)`%) so can we say that the
spread of data points is 9% greater for `plantB`? Nope, we cannot. To
understand why let's look at the graph below.

![Effect of rainfall on plants' biomass.](./images/ch07biomassCorDiffUnits.png){#fig:ch07biomassCorDiffUnits}

Here, we got plantA biomass in different units (kilograms and pounds), still
logic and visual inspection of the graph points that the spread of the data
points is the same. Or is it?

```jl
s = """
(
	getCov(biomass.plantAkg, biomass.rainL),
	getCov(biomass.plantAkg .* 2.205, biomass.rainL),
)
"""
sco(s)
```

The covariances suggest that the spread of the data points is roughly 2 times
greater between the two sub-graphs of @fig:ch07biomassCorDiffUnits, but that is
clearly not the case. The problem is that the covariance is easily inflated by
the units of measurements. That is why we got an improved metrics for
association named [correlation](https://en.wikipedia.org/wiki/Correlation).

To be continued...
