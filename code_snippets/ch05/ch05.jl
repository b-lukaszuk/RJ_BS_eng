###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as cmk
import Distributions as dsts
import HypothesisTests as hts
import Statistics as sts


###############################################################################
#                         one-sample Student's t-test                         #
###############################################################################
beerVolumes = [504, 477, 484, 476, 519, 481, 453, 485, 487, 501]

# Figure 12
fig = cmk.Figure()
cmk.hist(fig[1, 1], beerVolumes, bins=5, strokewidth=1, strokecolor="black",
    axis=(;
        title="Histogram of beer volume distribution for 10 beer",
        xlabel="Volume of beer in a bottle [mL]",
        ylabel="Count"))
fig

# mean and sd for beer volumes
meanBeerVol = sts.mean(beerVolumes)
stdBeerVol = sts.std(beerVolumes)
(meanBeerVol, stdBeerVol)

# solution, attempt 1
# how many std. devs is value above or below the mean
function getZScore(mean::Real, sd::Real, value::Real)::Float64
    return (value - mean) / sd
end

expectedBeerVolmL = 500

fractionBeerLessEq500mL = dsts.cdf(dsts.Normal(),
    getZScore(meanBeerVol, stdBeerVol, expectedBeerVolmL))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL

# solution, attempt 2
function getSem(vect::Vector{<:Real})::Float64
    return sts.std(vect) / sqrt(length(vect))
end

fractionBeerLessEq500mL = dsts.cdf(dsts.Normal(),
    getZScore(meanBeerVol, getSem(beerVolumes), expectedBeerVolmL))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL

# Figure 13
fig = cmk.Figure()
# Standard normal distribution
cmk.lines(fig[1, 1], dsts.Normal(0, 1),
    color="red",
    axis=(;
        title="Standard normal distribution (solid red line)\nand\nt-distribution (dotted blue line)",
        xlabel="x",
        ylabel="Probability of outcome",
        xticks=-3:3)
)
cmk.xlims!(-4, 4)
# Standard normal distribution
cmk.lines!(fig[1, 1], dsts.TDist(4),
    color="blue", linestyle=:dot)
cmk.text!(fig[1, 1], 1.5, 0.2, text="df = 4", fontsize=20, color="blue")
fig

# df, explanation
peopleBodyMassesKg = [84, 94, 78]
sum(peopleBodyMassesKg)

# solution, attempt 3 (successful)
function getDf(vect::Vector{<:Real})::Int
    return length(vect) - 1
end

fractionBeerLessEq500mL = dsts.cdf(dsts.TDist(getDf(beerVolumes)),
    getZScore(meanBeerVol, getSem(beerVolumes), expectedBeerVolmL))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL


# solution with HypothesisTests package
hts.OneSampleTTest(beerVolumes, expectedBeerVolmL)

# comparison with solution 3
(
    expectedBeerVolmL, # value under h_0
    meanBeerVol, # point estimate
    fractionBeerAbove500mL * 2, # two-sided p-value
    getZScore(meanBeerVol, getSem(beerVolumes), expectedBeerVolmL), # t-statistic
    getDf(beerVolumes), # degrees of freedom
    getSem(beerVolumes) # empirical standard error
)

# Flashback
hts.BinomialTest(5, 6, 0.5)
# or just: hts.BinomialTest(5, 6) # (since 0.5 is the default value)