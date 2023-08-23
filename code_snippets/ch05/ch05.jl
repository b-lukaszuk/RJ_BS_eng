###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import Distributions as Dsts
import HypothesisTests as Htests
import Pingouin as Pg
import Random as Rand
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


###############################################################################
#                         two samples Student's t-test                        #
###############################################################################
miceBwt = Csv.read("./miceBwt.csv", Dfs.DataFrame)
first(miceBwt, 3)

Dfs.describe(miceBwt)

### Paired samples Student's t-test

# miceBwt.noDrugX or miceBwt.noDrugX returns a column as a Vector
Htests.OneSampleTTest(miceBwt.noDrugX, miceBwt.drugX)


# miceBwt.noDrugX or miceBwt.noDrugX returns a column as a Vector
# hence we can do elementwise subtraction using dot syntax
miceBwtDiff = miceBwt.noDrugX .- miceBwt.drugX
Htests.OneSampleTTest(miceBwtDiff)

Pg.normality(miceBwtDiff)

### Unpaired samples Student's t-test

# for brevity we will extract just the p-values
(
    Pg.normality(miceBwt.noDrugX).pval,
    Pg.normality(miceBwt.drugX).pval
)

Htests.FlignerKilleenTest(miceBwt.noDrugX, miceBwt.drugX)


Htests.HypothesisTests.EqualVarianceTTest(
    miceBwt.noDrugX, miceBwt.drugX)


function getSem(v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
    sem1::Float64 = getSem(v1)
    sem2::Float64 = getSem(v2)
    return sqrt((sem1^2) + (sem2^2))
end

function getDf(v1::Vector{<:Real}, v2::Vector{<:Real})::Int
    return getDf(v1) + getDf(v2)
end


meanDiffBwtH0 = 0
meanDiffBwt = Stats.mean(miceBwt.noDrugX) - Stats.mean(miceBwt.drugX)
pooledSemBwt = getSem(miceBwt.noDrugX, miceBwt.drugX)
zScoreBwt = getZScore(meanDiffBwt, pooledSemBwt, meanDiffBwtH0)
dfBwt = getDf(miceBwt.noDrugX, miceBwt.drugX)
pValBwt = Dsts.cdf(Dsts.TDist(dfBwt), zScoreBwt) * 2

# compare with the output of Htests.HypothesisTests.EqualVarianceTTest above
(
    meanDiffBwtH0, # value under h_0
    round(meanDiffBwt, digits=4), # point estimate
    round(pooledSemBwt, digits=4), # empirical standard error
    # to get a positive zScore we should have calculated it as:
    # getZScore(meanDiffBwtH0, pooledSemBwt, meanDiffBwt)
    round(zScoreBwt, digits=4), # t-statistic
    dfBwt, # degrees of freedom
    round(pValBwt, digits=4) # two-sided p-value
)


###############################################################################
#                                One-way ANOVA                                #
###############################################################################

# Peter's mice
Rand.seed!(321)
ex1BwtsWater = Rand.rand(Dsts.Normal(25, 3), 4)
ex1BwtsPlacebo = Rand.rand(Dsts.Normal(25, 3), 4)

# John's mice
ex2BwtsWater = Rand.rand(Dsts.Normal(25, 3), 4)
ex2BwtsDrugY = Rand.rand(Dsts.Normal(25 * 0.8, 3), 4)

# helper fn, to save me some typing
function len(v::Vector{T})::Int where {T}
    return length(v)
end

# Figure
fig = Cmk.Figure()
ax1, sca1ex1 = Cmk.scatter(fig[1, 1], 1:len(ex1BwtsWater), ex1BwtsWater,
    color="blue", marker=:circle, markersize=20,
    axis=(;
        title="Peter's mice",
        xlabel="mice ID",
        ylabel="Body weight [g]",
        xticks=1:8)
)
sca2ex1 = Cmk.scatter!(fig[1, 1],
    (len(ex1BwtsWater)+1):(len(ex1BwtsWater)+len(ex1BwtsPlacebo)),
    ex1BwtsPlacebo,
    color="orange", marker=:utriangle, markersize=20
)
Cmk.ylims!(0, 35)
Cmk.axislegend(ax1,
    [sca1ex1, sca2ex1],
    ["water", "placebo"],
    "Peter's experiment",
    position=:lb)
ax2, sca1ex2 = Cmk.scatter(fig[1, 2],
    1:len(ex2BwtsWater), ex2BwtsWater,
    color="blue", marker=:rect, markersize=20,
    axis=(;
        title="John's mice",
        xlabel="mice ID",
        ylabel="Body weight [g]",
        xticks=1:8)
)
sca2ex2 = Cmk.scatter!(fig[1, 2],
    (len(ex2BwtsWater)+1):(len(ex2BwtsWater)+len(ex2BwtsDrugY)),
    ex2BwtsDrugY,
    color="orange", marker=:star6, markersize=20,
)
Cmk.ylims!(0, 35)
Cmk.axislegend(ax2,
    [sca1ex2, sca2ex2],
    ["water", "drug Y"],
    "John's experiment",
    position=:lb)
fig
