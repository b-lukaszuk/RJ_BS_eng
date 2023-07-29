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

To be continued...
