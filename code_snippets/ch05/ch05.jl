###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import Distributions as Dsts
import HypothesisTests as Htests
import MultipleTesting as Mt
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
    color="blue", linestyle=:dashdot)
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

# Peter's mice, experiment 1 (ex1)
Rand.seed!(321)
ex1BwtsWater = Rand.rand(Dsts.Normal(25, 3), 4)
ex1BwtsPlacebo = Rand.rand(Dsts.Normal(25, 3), 4)

# John's mice, experiment 2 (ex2)
ex2BwtsWater = Rand.rand(Dsts.Normal(25, 3), 4)
ex2BwtsDrugY = Rand.rand(Dsts.Normal(25 * 0.77, 3), 4)


# helper fn, to save me some typing (when constructing the graphs below)
function len(v::Vector{T})::Int where {T}
    return length(v)
end

# Figure 15
fig = Cmk.Figure()
ax1, sca1ex1 = Cmk.scatter(fig[1, 1], 1:len(ex1BwtsWater), ex1BwtsWater,
    color="blue", marker=:circle, markersize=20,
    axis=(;
        title="Peter's mice (experiment 1)",
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
        title="John's mice (experiment 2)",
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

# Figure 16
fig = Cmk.Figure()
ax1, sca1ex1 = Cmk.scatter(fig[1, 1], 1:len(ex1BwtsWater), ex1BwtsWater,
    color="blue", marker=:circle, markersize=20,
    axis=(;
        title="Peter's mice (experiment 1)",
        xlabel="mice ID",
        ylabel="Body weight [g]",
        xticks=1:8)
)
l1ex1 = Cmk.hlines!(fig[1, 1], Stats.mean(ex1BwtsWater), color="blue", linestyle=:dashdot, linewidth=2,
    xmin=0, xmax=0.5)
sca2ex1 = Cmk.scatter!(fig[1, 1],
    (len(ex1BwtsWater)+1):(len(ex1BwtsWater)+len(ex1BwtsPlacebo)),
    ex1BwtsPlacebo,
    color="orange", marker=:utriangle, markersize=20
)
l2ex1 = Cmk.hlines!(fig[1, 1], Stats.mean(ex1BwtsPlacebo), color="orange", linestyle=:dashdot, linewidth=2,
    xmin=0.5, xmax=1)
l3ex1 = Cmk.hlines!(fig[1, 1], Stats.mean(vcat(ex1BwtsWater, ex1BwtsPlacebo)), color="gray",
    linestyle=:solid, linewidth=2)
Cmk.ylims!(0, 35)
Cmk.axislegend(ax1,
    [sca1ex1, sca2ex1, l3ex1, l1ex1, l2ex1],
    ["water", "placebo", "overall mean", "water mean", "placebo mean"],
    "Peter's experiment",
    position=:lb)
ax2, sca1ex2 = Cmk.scatter(fig[1, 2],
    1:len(ex2BwtsWater), ex2BwtsWater,
    color="blue", marker=:rect, markersize=20,
    axis=(;
        title="John's mice (experiment 2)",
        xlabel="mice ID",
        ylabel="Body weight [g]",
        xticks=1:8)
)
l1ex2 = Cmk.hlines!(fig[1, 2], Stats.mean(ex2BwtsWater), color="blue", linestyle=:dashdot, linewidth=2,
    xmin=0, xmax=0.5)
sca2ex2 = Cmk.scatter!(fig[1, 2],
    (len(ex2BwtsWater)+1):(len(ex2BwtsWater)+len(ex2BwtsDrugY)),
    ex2BwtsDrugY,
    color="orange", marker=:star6, markersize=20,
)
l2ex2 = Cmk.hlines!(fig[1, 2], Stats.mean(ex2BwtsDrugY), color="orange", linestyle=:dashdot, linewidth=2,
    xmin=0.5, xmax=1)
l3ex2 = Cmk.hlines!(fig[1, 2], Stats.mean(vcat(ex2BwtsWater, ex2BwtsDrugY)), color="gray", linestyle=:solid,
    linewidth=2)
Cmk.ylims!(0, 35)
Cmk.axislegend(ax2,
    [sca1ex2, sca2ex2, l3ex2, l1ex2, l2ex2],
    ["water", "drug Y", "overall mean", "water mean", "drug Y mean"],
    "John's experiment",
    position=:lb)
fig

# asessing distances of the points (see the Figure above) from the means
function getAbsDiffs(v::Vector{<:Real})::Vector{<:Real}
    return abs.(Stats.mean(v) .- v)
end

function getAbsPointDiffsFromGroupMeans(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Vector{<:Real}
    return vcat(getAbsDiffs(v1), getAbsDiffs(v2))
end

ex1withinGroupsSpread = getAbsPointDiffsFromGroupMeans(
    ex1BwtsWater, ex1BwtsPlacebo)
ex2withinGroupsSpread = getAbsPointDiffsFromGroupMeans(
    ex2BwtsWater, ex2BwtsDrugY)

ex1AvgWithinGroupsSpread = Stats.mean(ex1withinGroupsSpread)
ex2AvgWithingGroupsSpread = Stats.mean(ex2withinGroupsSpread)

(ex1AvgWithinGroupsSpread, ex2AvgWithingGroupsSpread)


function repVectElts(v::Vector{T}, times::Vector{Int})::Vector{T} where {T}
    @assert (length(v) == length(times)) "length(v) not equal length(times)"
    @assert all(map(x -> x > 0, times)) "times elts must be positive"
    result::Vector{T} = Vector{eltype(v)}(undef, sum(times))
    currInd::Int = 1
    for i in eachindex(v)
        for _ in 1:times[i]
            result[currInd] = v[i]
            currInd += 1
        end
    end
    return result
end

function getAbsGroupDiffsFromOverallMean(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Vector{<:Real}
    overallMean::Float64 = Stats.mean(vcat(v1, v2))
    groupMeans::Vector{Float64} = [Stats.mean(v1), Stats.mean(v2)]
    absGroupDiffs::Vector{<:Real} = abs.(overallMean .- groupMeans)
    absGroupDiffs = repVectElts(absGroupDiffs, map(length, [v1, v2]))
    return absGroupDiffs
end

ex1groupSpreadFromOverallMean = getAbsGroupDiffsFromOverallMean(
    ex1BwtsWater, ex1BwtsPlacebo)
ex2groupSpreadFromOverallMean = getAbsGroupDiffsFromOverallMean(
    ex2BwtsWater, ex2BwtsDrugY)

ex1AvgGroupSpreadFromOverallMean = Stats.mean(ex1groupSpreadFromOverallMean)
ex2AvgGroupSpreadFromOverallMean = Stats.mean(ex2groupSpreadFromOverallMean)

(ex1AvgGroupSpreadFromOverallMean, ex2AvgGroupSpreadFromOverallMean)

LStatisticEx1 = ex1AvgGroupSpreadFromOverallMean / ex1AvgWithinGroupsSpread
LStatisticEx2 = ex2AvgGroupSpreadFromOverallMean / ex2AvgWithingGroupsSpread

Htests.OneWayANOVATest(ex1BwtsWater, ex1BwtsPlacebo)
Htests.OneWayANOVATest(ex2BwtsWater, ex2BwtsDrugY)

## calculating F-statistic on our own
# compare with our getAbsDiffs
function getSquaredDiffs(v::Vector{<:Real})::Vector{<:Real}
    return (Stats.mean(v) .- v) .^ 2
end

# compare with our getAbsPointDiffsFromOverallMean
function getResidualSquaredDiffs(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Vector{<:Real}
    return vcat(getSquaredDiffs(v1), getSquaredDiffs(v2))
end

# compare with our getAbsGroupDiffsAroundOverallMean
function getGroupSquaredDiffs(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Vector{<:Real}
    overallMean::Float64 = Stats.mean(vcat(v1, v2))
    groupMeans::Vector{Float64} = [Stats.mean(v1), Stats.mean(v2)]
    groupSqDiffs::Vector{<:Real} = (overallMean .- groupMeans) .^ 2
    groupSqDiffs = repVectElts(groupSqDiffs, map(length, [v1, v2]))
    return groupSqDiffs
end

## calculating F-statistic on our own (continuation)
function getResidualMeanSquare(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
    residualSquaredDiffs::Vector{<:Real} = getResidualSquaredDiffs(v1, v2)
    return sum(residualSquaredDiffs) / getDf(v1, v2)
end

function getGroupMeanSquare(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
    groupSquaredDiffs::Vector{<:Real} = getGroupSquaredDiffs(v1, v2)
    groupMeans::Vector{Float64} = [Stats.mean(v1), Stats.mean(v2)]
    return sum(groupSquaredDiffs) / getDf(groupMeans)
end

function getFStatistic(v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
    return getGroupMeanSquare(v1, v2) / getResidualMeanSquare(v1, v2)
end

(
    getFStatistic(ex1BwtsWater, ex1BwtsPlacebo),
    getFStatistic(ex2BwtsWater, ex2BwtsDrugY),
)

###############################################################################
#                                Post-hoc tests                               #
###############################################################################

miceBwtABC = Csv.read("./miceBwtABC.csv", Dfs.DataFrame)

# means and sds in the groups
[
    (n, Stats.mean(miceBwtABC[!, n]), Stats.std(miceBwtABC[!, n]))
    for n in Dfs.names(miceBwtABC)
]

# checking normality assumption (true means all normal)
[Pg.normality(miceBwtABC[!, n]).pval[1] for n in Dfs.names(miceBwtABC)] |>
vect -> map(vElt -> vElt > 0.05, vect) |>
        all

# checking homogeneity of variance assumption
# (true means variances for each group are roughly equal)
Htests.FlignerKilleenTest(
    [miceBwtABC[!, n] for n in Dfs.names(miceBwtABC)]...
) |> Htests.pvalue |> x -> x > 0.05

# one-way anova (p < 0.05, means that some group(s) differ, from the others)
Htests.OneWayANOVATest(
    [miceBwtABC[!, n] for n in Dfs.names(miceBwtABC)]...
) |> Htests.pvalue

## post-hoc tests

# abbreviating names
evtt = Htests.EqualVarianceTTest
getPval = Htests.pvalue

# for "spA vs spB", "spA vs spC" and "spB vs spC", respectively
postHocPvals = [
    evtt(miceBwtABC[!, "spA"], miceBwtABC[!, "spB"]) |> getPval,
    evtt(miceBwtABC[!, "spA"], miceBwtABC[!, "spC"]) |> getPval,
    evtt(miceBwtABC[!, "spB"], miceBwtABC[!, "spC"]) |> getPval,
]

postHocPvals

###############################################################################
#                           multiplicity correction                           #
###############################################################################

# unadjusted (uncorrected p-values) reminder
postHocPvals

## functions to adjust p-values (given the number of multiple independent tests)
function adjustPvalue(pVal::Float64, by::Int)::Float64
    @assert (0 <= pVal <= 1) "pVal must be in range [0-1]"
    return min(1, pVal * by)
end

function adjustPvalues(pVals::Vector{Float64})::Vector{Float64}
    return adjustPvalue.(pVals, length(pVals))
end

# p-values for comparisons: spA vs spB, spA vs spC, and spB vs spC
adjustPvalues(postHocPvals)

## comparison of different methods for p-values adjustment
# p-values for comparisons: spA vs spB, spA vs spC, and spB vs spC
resultsOfThreeAdjMethods = (
    adjustPvalues(postHocPvals),
    Mt.adjust(postHocPvals, Mt.Bonferroni()),
    Mt.adjust(postHocPvals, Mt.BenjaminiHochberg())
)

resultsOfThreeAdjMethods
