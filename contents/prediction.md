# Prediction {#sec:prediction}

OK, time to talk about prediction of a variable value based on the value(s) of
other variable(s).

## Chapter imports {#sec:pred_data_imports}

Later in this chapter we are going to use the following libraries

```jl
s7 = """
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import GLM as Glm
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
