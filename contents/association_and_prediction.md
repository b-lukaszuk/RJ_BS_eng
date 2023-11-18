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

To be continued...
