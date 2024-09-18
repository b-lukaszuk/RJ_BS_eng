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
function getZScore(value::Real, mean::Real, sd::Real)::Float64
    return (value - mean) / sd
end

expectedBeerVolmL = 500

fractionBeerLessEq500mL = Dsts.cdf(Dsts.Normal(),
    getZScore(expectedBeerVolmL, meanBeerVol, stdBeerVol))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL

# solution, attempt 2
function getSem(vect::Vector{<:Real})::Float64
    return Stats.std(vect) / sqrt(length(vect))
end

fractionBeerLessEq500mL = Dsts.cdf(Dsts.Normal(),
    getZScore(expectedBeerVolmL, meanBeerVol, getSem(beerVolumes)))
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
    getZScore(expectedBeerVolmL, meanBeerVol, getSem(beerVolumes)))
fractionBeerAbove500mL = 1 - fractionBeerLessEq500mL

fractionBeerAbove500mL


# solution with HypothesisTests package
Htests.OneSampleTTest(beerVolumes, expectedBeerVolmL)

# comparison with solution 3
(
    expectedBeerVolmL, # value under h_0
    meanBeerVol, # point estimate
    fractionBeerAbove500mL * 2, # two-sided p-value
    getZScore(expectedBeerVolmL, meanBeerVol, getSem(beerVolumes)), # t-statistic
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
zScoreBwt = getZScore(meanDiffBwtH0, meanDiffBwt, pooledSemBwt)
dfBwt = getDf(miceBwt.noDrugX, miceBwt.drugX)
pValBwt = Dsts.cdf(Dsts.TDist(dfBwt), zScoreBwt) * 2

# compare with the output of Htests.HypothesisTests.EqualVarianceTTest above
(
    meanDiffBwtH0, # value under h_0
    round(meanDiffBwt, digits=4), # point estimate
    round(pooledSemBwt, digits=4), # empirical standard error
    # to get a positive zScore we should have calculated it as:
    # getZScore(meanDiffBwt, meanDiffBwtH0, pooledSemBwt)
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
    for n in Dfs.names(miceBwtABC) # n stands for name
]

# Alternatives to get means and stds
Dfs.describe(miceBwtABC, :mean, :std)

# checking normality assumption (true means all normal)
[Pg.normality(miceBwtABC[!, n]).pval[1] for n in Dfs.names(miceBwtABC)] |>
pvals -> map(pv -> pv > 0.05, pvals) |>
         all

# checking homogeneity of variance assumption
# (true means variances for each group are roughly equal)
Htests.FlignerKilleenTest(
    [miceBwtABC[!, n] for n in Dfs.names(miceBwtABC)]...
) |> Htests.pvalue |> pv -> pv > 0.05

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


###############################################################################
#                             Exercise 1. Solution                            #
###############################################################################
Rand.seed!(321)
ex1sample = Rand.rand(Dsts.Normal(80, 20), 10)
ex1sampleSd = Stats.std(ex1sample)
ex1sampleSem = getSem(ex1sample)
ex1sampleMeans = [
    Stats.mean(Rand.rand(Dsts.Normal(80, 20), 10))
    for _ in 1:100_000]
ex1sampleMeansMean = Stats.mean(ex1sampleMeans)
ex1sampleMeansSd = Stats.std(ex1sampleMeans)

fig = Cmk.Figure()
Cmk.hist(fig[1, 1], ex1sampleMeans, bins=100, color=Cmk.RGBAf(0, 0, 1, 0.3),
    axis=(;
        title="Histogram of 100'000 sample means",
        xlabel="Adult human body weight [kg]",
        ylabel="Count"))
Cmk.ylims!(0, 4000)
Cmk.vlines!(fig[1, 1], 80, ymin=0.0, ymax=0.85, color="black", linestyle=:dashdot)
Cmk.text!(fig[1, 1], 81, 1000, text="population mean = 80")
Cmk.bracket!(fig[1, 1],
    ex1sampleMeansMean - ex1sampleMeansSd / 2, 3500,
    ex1sampleMeansMean + ex1sampleMeansSd / 2, 3500,
    style=:square
)
Cmk.text!(fig[1, 1], 72.5, 3700,
    text="sample means sd = $(round(ex1sampleMeansSd, digits=2))")
Cmk.text!(fig[1, 1], 90, 3200,
    text="single sample sd = $(round(ex1sampleSd, digits=2))")
Cmk.text!(fig[1, 1], 90, 3000,
    text="single sample sem = $(round(ex1sampleSem, digits=2))")
fig

###############################################################################
#                             Exercise 2. Solution                            #
###############################################################################
# functions from chapter 4
function getCounts(v::Vector{T})::Dict{T,Int} where {T}
    counts::Dict{T,Int} = Dict()
    for elt in v
        counts[elt] = get(counts, elt, 0) + 1
    end
    return counts
end

function getProbs(counts::Dict{T,Int})::Dict{T,Float64} where {T}
    total::Int = sum(values(counts))
    return Dict(k => v / total for (k, v) in counts)
end

function getSortedKeysVals(d::Dict{A,B})::Tuple{
    Vector{A},Vector{B}} where {A,B}

    sortedKeys::Vector{A} = keys(d) |> collect |> sort
    sortedVals::Vector{B} = [d[k] for k in sortedKeys]
    return (sortedKeys, sortedVals)
end

# getLstatistic
function getLStatistic(v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
    absDiffsOverallMean::Vector{<:Real} =
        getAbsGroupDiffsFromOverallMean(v1, v2)
    absDiffsGroupMean::Vector{<:Real} =
        getAbsPointDiffsFromGroupMeans(v1, v2)
    return Stats.mean(absDiffsOverallMean) / Stats.mean(absDiffsGroupMean)
end

# getXStatFn signature: fnName(::Vector{<:Real}, ::Vector{<:Real})::Float64
function getXStatisticsUnderH0(
    getXStatFn::Function,
    popMean::Real, popSd::Real,
    nPerGroup::Int=4, nIter::Int=1_000_000)::Vector{Float64}
    v1::Vector{Float64} = []
    v2::Vector{Float64} = []
    result::Vector{Float64} = zeros(nIter)
    for i in 1:nIter
        v1 = Rand.rand(Dsts.Normal(popMean, popSd), nPerGroup)
        v2 = Rand.rand(Dsts.Normal(popMean, popSd), nPerGroup)
        result[i] = getXStatFn(v1, v2)
    end
    return result
end

# getXStatFn signature: fnName(::Vector{<:Real}, ::Vector{<:Real})::Float64
function getXDistUnderH0(getXStatFn::Function,
    mean::Real, sd::Real,
    nPerGroup::Int=4, nIter::Int=10^6)::Dict{Float64,Float64}

    xStats::Vector{<:Float64} = getXStatisticsUnderH0(
        getXStatFn, mean, sd, nPerGroup, nIter)
    xStats = round.(xStats, digits=1)
    xCounts::Dict{Float64,Int} = getCounts(xStats)
    xProbs::Dict{Float64,Float64} = getProbs(xCounts)

    return xProbs
end

# probability of getting L-Statistic greater than LStatisticEx2
Rand.seed!(321)
lprobs = getXDistUnderH0(getLStatistic, 25, 3)
lprobsGTLStatisticEx2 = [v for (k, v) in lprobs if k > LStatisticEx2]
lStatProb = sum(lprobsGTLStatisticEx2)

Rand.seed!(321)
cutoffFStat = getFStatistic(ex2BwtsWater, ex2BwtsDrugY)
fprobs = getXDistUnderH0(getFStatistic, 25, 3)
fprobsGTFStatisticEx2 = [v for (k, v) in fprobs if k > cutoffFStat]
fStatProb = sum(fprobsGTFStatisticEx2)

Rand.seed!(321)
# L distributions
lxs1, lys1 = getXDistUnderH0(getLStatistic, 25, 3) |> getSortedKeysVals
lxs2, lys2 = getXDistUnderH0(getLStatistic, 100, 50) |> getSortedKeysVals
lxs3, lys3 = getXDistUnderH0(getLStatistic, 25, 3, 8) |> getSortedKeysVals
# F distribution
fxs1, fys1 = getXDistUnderH0(getFStatistic, 25, 3) |> getSortedKeysVals

fig = Cmk.Figure()
ax1, l1 = Cmk.lines(fig[1, 1], fxs1, fys1, color="red",
    axis=(;
        title="F-Distribution (red) and L-Distribution (blue)",
        xlabel="Value of the statistic",
        ylabel="Probability of outcome"))
l2 = Cmk.lines!(fig[1, 1], lxs1, lys1, color="blue")
sc1 = Cmk.scatter!(fig[1, 1], lxs2, lys2, color="blue", marker=:circle)
sc2 = Cmk.scatter!(fig[1, 1], lxs3, lys3, color="blue", marker=:xcross)
Cmk.vlines!(fig[1, 1], LStatisticEx2, color="lightblue", type=:dashdot)
Cmk.text!(fig[1, 1], 1.35, 0.1,
    text="L-Statistic = $(round(LStatisticEx2, digits=2))")
Cmk.xlims!(0, 4)
Cmk.ylims!(0, 0.25)
Cmk.axislegend(ax1,
    [l1, l2, sc1, sc2],
    [
        "F-Statistic(1, 6) [Dsts.Normal(25, 3), n = 4]",
        "L-Statistic [Dsts.Normal(25, 3), n = 4]",
        "L-Statistic [Dsts.Normal(100, 50), n = 4]",
        "L-Statistic [Dsts.Normal(25, 3), n = 8]"
    ],
    "Distributions\n(num groups = 2,\nn - num observations per group)",
    position=:rt)
fig


fprobsGTCutoffFStat = filter(keyValPair -> keyValPair[1] > cutoffFStat, fprobs)
fprobsGTCutoffFStat = collect(values(fprobsGTCutoffFStat))
fprobs


###############################################################################
#                             Exercise 3. Solution                            #
###############################################################################
function areAllDistributionsNormal(vects::Vector{<:Vector{<:Real}})::Bool
    return [Pg.normality(v).pval[1] for v in vects] |>
           pvals -> map(pv -> pv > 0.05, pvals) |>
                    all
end

function areAllVariancesEqual(vects::Vector{<:Vector{<:Real}})
    return Htests.FlignerKilleenTest(vects...) |>
           Htests.pvalue |> pv -> pv > 0.05
end

function getPValUnpairedTest(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Float64

    normality::Bool = areAllDistributionsNormal([v1, v2])
    homogeneity::Bool = areAllVariancesEqual([v1, v2])

    return (
        (normality && homogeneity) ? Htests.EqualVarianceTTest(v1, v2) :
        (normality) ? Htests.UnequalVarianceTTest(v1, v2) :
        Htests.MannWhitneyUTest(v1, v2)
    ) |> Htests.pvalue
end

getPValUnpairedTest([miceBwt[!, n] for n in Dfs.names(miceBwt)]...) |>
x -> round(x, digits=4)


###############################################################################
#                             Exercise 4. Solution                            #
###############################################################################
function getUniquePairs(uniqueNames::Vector{T})::Vector{Tuple{T,T}} where {T}

    @assert (length(uniqueNames) >= 2) "the input must be of length >= 2"

    uniquePairs::Vector{Tuple{T,T}} =
        Vector{Tuple{T,T}}(undef, binomial(length(uniqueNames), 2))
    currInd::Int = 1

    for i in eachindex(uniqueNames)[1:(end-1)]
        for j in eachindex(uniqueNames)[(i+1):end]
            uniquePairs[currInd] = (uniqueNames[i], uniqueNames[j])
            currInd += 1
        end
    end

    return uniquePairs
end

(
    getUniquePairs([10, 20]),
    getUniquePairs([1.1, 2.2, 3.3]),
    getUniquePairs(["w", "x", "y", "z"]), # vector of one element Strings
    getUniquePairs(['a', 'b', 'c']), # vector of single Chars
    getUniquePairs(['a', 'b', 'a']) # names must be unique
)

# df - DataFrame: each column is a continuous variable (one group)
# returns uncorrected p-values
function getPValsUnpairedTests(
    df::Dfs.DataFrame)::Dict{Tuple{String,String},Float64}

    pairs::Vector{Tuple{String,String}} = getUniquePairs(Dfs.names(df))
    pvals::Vector{Float64} = [
        getPValUnpairedTest(df[!, a], df[!, b])
        for (a, b) in pairs
    ]

    return Dict(pairs[i] => pvals[i] for i in eachindex(pairs))
end

getPValsUnpairedTests(miceBwtABC)


# df - DataFrame: each column is a continuous variable (one group)
# returns corrected p-values
function getPValsUnpairedTests(
    df::Dfs.DataFrame,
    multCorr::Type{M}
)::Dict{Tuple{String,String},Float64} where {M<:Mt.PValueAdjustment}

    pairs::Vector{Tuple{String,String}} = getUniquePairs(Dfs.names(df))
    pvals::Vector{Float64} = [
        getPValUnpairedTest(df[!, a], df[!, b])
        for (a, b) in pairs
    ]
    pvals = Mt.adjust(pvals, multCorr())

    return Dict(pairs[i] => pvals[i] for i in eachindex(pairs))
end

# the default Bonferroni correction
getPValsUnpairedTests(miceBwtABC, Mt.Bonferroni)

# Benjamini-Hochberg correction
getPValsUnpairedTests(miceBwtABC, Mt.BenjaminiHochberg)


###############################################################################
#                             Exercise 5. Solution                            #
###############################################################################
# Step 1
ex5nrows = size(miceBwtABC)[1] #1
ex5names = Dfs.names(miceBwtABC) #2
ex5xs = repeat(eachindex(ex5names), inner=ex5nrows) #3
ex5ys = [miceBwtABC[!, n] for n in ex5names] #4
ex5ys = vcat(ex5ys...) #5

fig = Cmk.Figure()
Cmk.boxplot(fig[1, 1], ex5xs, ex5ys)
fig

# Step 2
fig = Cmk.Figure()
Cmk.Axis(fig[1, 1], xticks=(eachindex(ex5names), ex5names),
    title="Body mass of three mice species",
    xlabel="species name", ylabel="body mass [g]")
Cmk.boxplot!(fig[1, 1], ex5xs, ex5ys, whiskerwidth=0.5)
fig

# Step 3
fig = Cmk.Figure()
Cmk.Axis(fig[1, 1], xticks=(eachindex(ex5names), ex5names),
    title="Body mass of three mice species",
    xlabel="species name", ylabel="body mass [g]")
Cmk.boxplot!(fig[1, 1], ex5xs, ex5ys, whiskerwidth=0.5)
Cmk.text!(fig[1, 1],
    eachindex(ex5names), [30, 30, 30],
    text=["", "a", "ab"],
    align=(:center, :top), fontsize=20)
fig

# Step 4
ex5marksYpos = [maximum(miceBwtABC[!, n]) for n in ex5names] #1
ex5marksYpos = map(mYpos -> round(Int, mYpos * 1.1), ex5marksYpos) #2
ex5upYlim = maximum(ex5ys * 1.2) |> x -> round(Int, x) #3
ex5downYlim = minimum(ex5ys * 0.8) |> x -> round(Int, x) #4

# Step 5
function getMarkers(
    pvs::Dict{Tuple{String,String},Float64},
    groupsOrder=["spA", "spB", "spC"],
    markerTypes::Vector{String}=["a", "b", "c"],
    cutoffAlpha::Float64=0.05)::Vector{String}

    @assert (
        length(groupsOrder) == length(markerTypes)
    ) "different groupsOrder and markerTypes lengths"
    @assert (0 <= cutoffAlpha <= 1) "cutoffAlpha must be in range [0-1]"

    markers::Vector{String} = repeat([""], length(groupsOrder))
    tmpInd::Int = 0

    for i in eachindex(groupsOrder)
        for ((g1, g2), pv) in pvs
            if (groupsOrder[i] == g1) && (pv <= cutoffAlpha)
                tmpInd = findfirst(x -> x == g2, groupsOrder)
                markers[tmpInd] *= markerTypes[i]
            end
        end
    end

    return markers
end

(
    getMarkers(
        getPValsUnpairedTests(miceBwtABC, Mt.BenjaminiHochberg),
        ["spA", "spB", "spC"],
        ["a", "b", "c"],
        0.05),
    getPValsUnpairedTests(miceBwtABC, Mt.BenjaminiHochberg)
)

# Step 6
# the function should work fine for up to 26 groups in the df's columns
function drawBoxplot(
    df::Dfs.DataFrame, title::String,
    xlabel::String, ylabel::String)::Cmk.Figure

    nrows, _ = size(df)
    ns::Vector{String} = Dfs.names(df)
    xs = repeat(eachindex(ns), inner=nrows)
    ys = [df[!, n] for n in ns]
    ys = vcat(ys...)
    marksYpos = [maximum(df[!, n]) for n in ns]
    marksYpos = map(mYpos -> round(Int, mYpos * 1.1), marksYpos)
    upYlim = maximum(ys * 1.2) |> x -> round(Int, x)
    downYlim = minimum(ys * 0.8) |> x -> round(Int, x)
    # 'a':'z' generates all lowercase chars of the alphabet
    markerTypes::Vector{String} = map(string, 'a':'z')
    markers::Vector{String} = getMarkers(
        getPValsUnpairedTests(df, Mt.BenjaminiHochberg),
        ns,
        markerTypes[1:length(ns)],
        0.05
    )

    fig = Cmk.Figure()
    Cmk.Axis(fig[1, 1], xticks=(eachindex(ns), ns),
        title=title,
        xlabel=xlabel, ylabel=ylabel)
    Cmk.boxplot!(fig[1, 1], xs, ys, whiskerwidth=0.5)
    Cmk.ylims!(downYlim, upYlim)
    Cmk.text!(fig[1, 1],
        eachindex(ns), marksYpos,
        text=markers,
        align=(:center, :top), fontsize=20)

    return fig
end

fig = drawBoxplot(miceBwtABC,
    "Body mass of three mice species",
    "species name",
    "body mass [g]"
)
Cmk.save("./ch05ex5boxplot.png", fig)

