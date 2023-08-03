###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as Cmk
import Distributions as Dsts
import HypothesisTests as Htests
import Statistics as Stats


###############################################################################
#                         one-sample Student's t-test                         #
###############################################################################
beerVolumes = [504, 477, 484, 476, 519, 481, 453, 485, 487, 501]

# Figure 12
fig = Cmk.Figure()
Cmk.hist(fig[1, 1], beerVolumes, bins=5, strokewidth=1, strokecolor="black",
    axis=(;
        title="Histogram of beer volume distribution for 10 beer",
        xlabel="Volume of beer in a bottle [mL]",
        ylabel="Count"))
fig

# mean and sd for beer volumes
meanBeerVol = Stats.mean(beerVolumes)
stdBeerVol = Stats.std(beerVolumes)
(meanBeerVol, stdBeerVol)

# solution, attempt 1
# how many std. devs is value above or below the mean
function getZScore(mean::Real, sd::Real, value::Real)::Float64
    return (value - mean) / sd
end

expectedBeerVolmL = 500

fractionBeerLessEq500mL = Dsts.cdf(Dsts.Normal(),
    getZScore(meanBeerVol, stdBeerVol, expectedBeerVolmL))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL

# solution, attempt 2
function getSem(vect::Vector{<:Real})::Float64
    return Stats.std(vect) / sqrt(length(vect))
end

fractionBeerLessEq500mL = Dsts.cdf(Dsts.Normal(),
    getZScore(meanBeerVol, getSem(beerVolumes), expectedBeerVolmL))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL

# Figure 13
fig = Cmk.Figure()
# Standard normal distribution
Cmk.lines(fig[1, 1], Dsts.Normal(0, 1),
    color="red",
    axis=(;
        title="Standard normal distribution (solid red line)\n" *
              "and\nt-distribution (dotted blue line)",
        xlabel="x",
        ylabel="Probability of outcome",
        xticks=-3:3)
)
Cmk.xlims!(-4, 4)
# Standard normal distribution
Cmk.lines!(fig[1, 1], Dsts.TDist(4),
    color="blue", linestyle=:dot)
Cmk.text!(fig[1, 1], 1.5, 0.2, text="df = 4", fontsize=20, color="blue")
fig

# df, explanation
peopleBodyMassesKg = [84, 94, 78]
sum(peopleBodyMassesKg)

# solution, attempt 3 (successful)
function getDf(vect::Vector{<:Real})::Int
    return length(vect) - 1
end

fractionBeerLessEq500mL = Dsts.cdf(Dsts.TDist(getDf(beerVolumes)),
    getZScore(meanBeerVol, getSem(beerVolumes), expectedBeerVolmL))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL


# solution with HypothesisTests package
Htests.OneSampleTTest(beerVolumes, expectedBeerVolmL)

# comparison with solution 3
(
    expectedBeerVolmL, # value under h_0
    meanBeerVol, # point estimate
    fractionBeerAbove500mL * 2, # two-sided p-value
    getZScore(meanBeerVol, getSem(beerVolumes), expectedBeerVolmL), # t-statistic
    getDf(beerVolumes), # degrees of freedom
    getSem(beerVolumes) # empirical standard error
)

# checking the assumptions
Htests.ExactOneSampleKSTest(beerVolumes,
    Dsts.Normal(meanBeerVol, stdBeerVol))

# Flashback
Htests.BinomialTest(5, 6, 0.5)
# or just: Htests.BinomialTest(5, 6) # (since 0.5 is the default value)
