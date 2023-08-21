###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as Cmk
import Distributions as Dsts
import Random as Rand


###############################################################################
#                      Probability - theory and practice                      #
###############################################################################
Rand.seed!(321) # optional, needed for reproducibility
gametes = Rand.rand(["A", "B"], 16_000);
first(gametes, 5)

function getCounts(v::Vector{T})::Dict{T,Int} where {T}
    counts::Dict{T,Int} = Dict()
    for elt in v
        counts[elt] = get(counts, elt, 0) + 1
    end
    return counts
end

gametesCounts = getCounts(gametes)
gametesCounts

function getProbs(counts::Dict{T,Int})::Dict{T,Float64} where {T}
    total::Int = sum(values(counts))
    return Dict(k => v / total for (k, v) in counts)
end

gametesProbs = getProbs(gametesCounts)
gametesProbs

# alleles represented as numbers 0 - A, 1 - B
Rand.seed!(321)
gametes = Rand.rand([0, 1], 16_000);
first(gametes, 5)

alleleBCount = sum(gametes)
alleleACount = length(gametes) - alleleBCount
(alleleACount, alleleBCount)

alleleBProb = sum(gametes) / length(gametes)
alleleAProb = 1 - alleleBProb
(round(alleleAProb, digits=6), round(alleleBProb, digits=6))

###############################################################################
#                            Probability distribution                         #
###############################################################################
function getSumOf2DiceRoll()::Int
    return sum(Rand.rand(1:6, 2))
end

Rand.seed!(321)
numOfRolls = 100_000
diceRolls = [getSumOf2DiceRoll() for _ in 1:numOfRolls]
diceCounts = getCounts(diceRolls)
diceProbs = getProbs(diceCounts)

(diceCounts[12], diceProbs[12])

function getOutcomeOfBet(probWin::Float64, moneyWin::Real,
    probLose::Float64, moneyLose::Real)::Float64
    return probWin * moneyWin - probLose * moneyLose
end

outcomeOf1bet = getOutcomeOfBet(diceProbs[12], 125, 1 - diceProbs[12], 5)
round(outcomeOf1bet, digits=2) # round to cents (1/100th of a dollar)


numOfBets = 100

outcomeOf100bets = (diceProbs[12] * numOfBets * 125) -
                   ((1 - diceProbs[12]) * numOfBets * 5)
# or
outcomeOf100bets = ((diceProbs[12] * 125) - ((1 - diceProbs[12]) * 5)) * 100
# or simply
outcomeOf100bets = outcomeOf1bet * numOfBets

round(outcomeOf100bets, digits=2)

pWin = sum([diceCounts[i] for i in 11:12]) / numOfRolls
# or
pWin = sum([diceProbs[i] for i in 11:12])
pLose = 1 - pWin

round(pWin * 90 - pLose * 10, digits=2)

function getSortedKeysVals(d::Dict{T1,T2})::Tuple{
    Vector{T1},Vector{T2}} where {T1,T2}

    sortedKeys::Vector{T1} = keys(d) |> collect |> sort
    sortedVals::Vector{T2} = [d[k] for k in sortedKeys]
    return (sortedKeys, sortedVals)
end

xs1, ys1 = getSortedKeysVals(diceCounts)
xs2, ys2 = getSortedKeysVals(diceProbs)

# Figure 3
fig = Cmk.Figure()
Cmk.barplot(fig[1, 1:2], xs1, ys1,
    color="red",
    axis=(;
        title="Rolling 2 dice 100'000 times",
        xlabel="Sum of dots",
        ylabel="Number of occurrences",
        xticks=2:12)
)
Cmk.barplot(fig[2, 1:2], xs2, ys2,
    color="blue",
    axis=(;
        title="Rolling 2 dice 100'000 times",
        xlabel="Sum of dots",
        ylabel="Probability of occurrence",
        xticks=2:12)
)
fig

###############################################################################
#                             normal distribution                             #
###############################################################################
# binomial distribution
Rand.seed!(321)
binom = Rand.rand(0:1, 100_000)
binomCounts = getCounts(binom)
binomProbs = getProbs(binomCounts)

# multinomial distribution
Rand.seed!(321)
multinom = Rand.rand(1:6, 100_000)
multinomCounts = getCounts(multinom)
multinomProbs = getProbs(multinomCounts)

binomXs, binomYs = getSortedKeysVals(binomProbs)
multinomXs, multinomYs = getSortedKeysVals(multinomProbs)

# Figure 4
fig = Cmk.Figure()
Cmk.barplot(fig[1:2, 1], binomXs, binomYs,
    color="blue",
    axis=(;
        title="Binomial distribution (tossing a fair coin)",
        xlabel="Number of heads",
        ylabel="Probability of outcome",
        xticks=0:1)
)
Cmk.barplot(fig[1:2, 2], multinomXs, multinomYs,
    color="red",
    axis=(;
        title="Multinomial distribution (rolling 6-sided dice)",
        xlabel="Number of dots",
        ylabel="Probability of outcome",
        xticks=1:6)
)
fig

# normal distribution
# Figure 6
fig = Cmk.Figure()
# Standard normal distribution
Cmk.lines(fig[1, 1:2], Dsts.Normal(0, 1),
    color="red",
    axis=(;
        title="Standard normal distribution",
        xlabel="x",
        ylabel="Probability of outcome",
        xticks=-3:3)
)
# real life normal distribution
# be careful, the code below may be a bit time consuming (20M data points)
Rand.seed!(321)
heights = round.(Rand.rand(Dsts.Normal(172, 7), 20_000_000), digits=0);
heightsCounts = getCounts(heights)
heightsProbs = getProbs(heightsCounts)
heightsXs, heightsYs = getSortedKeysVals(heightsProbs)

Cmk.barplot(fig[2, 1:2], heightsXs, heightsYs,
    color=Cmk.RGBAf(0, 0, 1, 0.4),
    axis=(;
        title="Plausible distribution of adult males' height (in Poland)",
        xlabel="Height in cm",
        ylabel="Probability of outcome",
        xticks=151:7:193)
)
Cmk.lines!(fig[2, 1:2], heightsXs, heightsYs,
    color="navy")
fig

# grades example of sd
gradesStudA = [3.0, 3.5, 5.0, 4.5, 4.0]
gradesStudB = [6.0, 5.5, 1.5, 1.0, 6.0]

function getAvg(nums::Vector{<:Real})::Real
    return sum(nums) / length(nums)
end

avgStudA = getAvg(gradesStudA)
avgStudB = getAvg(gradesStudB)
(avgStudA, avgStudB)

diffsStudA = gradesStudA .- avgStudA
diffsStudB = gradesStudB .- avgStudB
(getAvg(diffsStudA), getAvg(diffsStudB))

(sum(diffsStudA), sum(diffsStudB))

absDiffsStudA = abs.(diffsStudA)
absDiffsStudB = abs.(diffsStudB)
(getAvg(absDiffsStudA), getAvg(absDiffsStudB))

function getSd(nums::Vector{<:Real})::Real
    avg::Real = getAvg(nums)
    diffs::Vector{<:Real} = nums .- avg
    squaredDiffs::Vector{<:Real} = diffs .^ 2
    return sqrt(getAvg(squaredDiffs))
end

(getSd(gradesStudA), getSd(gradesStudB))

# distribution package examples

# how many std. devs is value above or below the mean
function getZScore(mean::Real, sd::Real, value::Real)::Float64
    return (value - mean) / sd
end

(getZScore(100, 24, 124), getZScore(100, 24, 76))

zScorePeterIQ139 = getZScore(100, 24, 139)
zScorePeterIQ139

Dsts.cdf(Dsts.Normal(), zScorePeterIQ139)

Dsts.cdf(Dsts.Normal(100, 24), 139)

# for better clarity each method is in a separate line
(
    Dsts.cdf(Dsts.Normal(), getZScore(100, 24, 139)),
    Dsts.cdf(Dsts.Normal(100, 24), 139)
)

1 - Dsts.cdf(Dsts.Normal(172, 7), 181)

Dsts.pdf(Dsts.Binomial(2, 1 / 6), 2)

heightDist = Dsts.Normal(172, 7)
# 2 digits after dot because of the assumed precision of a measuring device
Dsts.cdf(heightDist, 181.49) - Dsts.cdf(heightDist, 180.50)


Rand.seed!(321)
# be careful, the code below may be a bit time consuming (20M data points)
heights = round.(Rand.rand(Dsts.Normal(172, 7), 20_000_000), digits=1);
heightsCounts = getCounts(heights)
heightsProbs = getProbs(heightsCounts)
heightsXs, heightsYs = getSortedKeysVals(heightsProbs)
# usage of cdf, examples with plots
indsLEQ180 = [i for i in eachindex(heightsXs) if heightsXs[i] <= 180]
indsLEQ170 = [i for i in eachindex(heightsXs) if heightsXs[i] <= 170]

# Figure 7
fig = Cmk.Figure()
Cmk.barplot(fig[1, 1:2], heightsXs, heightsYs,
    color=Cmk.RGBAf(0, 0, 0, 0.3),
    axis=(;
        title="Red color: height of men <= 180 [cm]",
        xlabel="Height in cm",
        ylabel="Probability of outcome",
        xticks=151:7:193)
)
Cmk.barplot!(fig[1, 1:2], heightsXs[indsLEQ180], heightsYs[indsLEQ180],
    color=Cmk.RGBAf(1, 0, 0, 0.8),
)
Cmk.barplot(fig[2, 1:2], heightsXs, heightsYs,
    color=Cmk.RGBAf(0, 0, 0, 0.3),
    axis=(;
        title="Blue color: height of men <= 170 [cm]",
        xlabel="Height in cm",
        ylabel="Probability of outcome",
        xticks=151:7:193)
)
Cmk.barplot!(fig[2, 1:2], heightsXs[indsLEQ170], heightsYs[indsLEQ170],
    color=Cmk.RGBAf(0, 0, 1, 0.8),
)
fig


###############################################################################
#                              hypothesis testing                             #
###############################################################################

# tennis - computer simulation

function getResultOf6TennisGames()
    return sum(Rand.rand(0:1, 6)) # 0 means John won, 1 means Peter won
end

Rand.seed!(321)
tennisGames = [getResultOf6TennisGames() for _ in 1:100_000]
tennisCounts = getCounts(tennisGames)
tennisProbs = getProbs(tennisCounts)

tennisProbs[6]

# sigLevel - significance level for probability
# 5% = 5/100 = 0.05
function shouldRejectH0(prob::Float64, sigLevel::Float64=0.05)::Bool
    @assert (0 <= prob <= 1) "prob must be in range [0-1]"
    @assert (0 <= sigLevel <= 1) "sigLevel must be in range [0-1]"
    return prob <= sigLevel
end

shouldRejectH0(tennisProbs[6])


# tennis - theoretical calculations

# using Distributions package
tennisTheorProbs = Dict(i => Dsts.pdf(Dsts.Binomial(6, 0.5), i) for i in 0:6)
tennisTheorProbs[6]

# plots of experimental and theoretical probabilities
practXs, practYs = getSortedKeysVals(tennisProbs)
theorXs, theorYs = getSortedKeysVals(tennisTheorProbs)

# Figure 8
fig = Cmk.Figure()
Cmk.barplot(fig[1, 1:2], practXs, practYs,
    color="lightblue",
    axis=(;
        title="Results of 6 tennis games if H0 is true\n(experimental probability distribution)",
        xlabel="Number of times Peter won",
        ylabel="Probability of outcome",
        xticks=0:6)
)
Cmk.barplot(fig[2, 1:2], theorXs, theorYs,
    color="lightgray",
    axis=(;
        title="Results of 6 tennis games if H0 is true\n(theoretical probability distribution)",
        xlabel="Number of times Peter won",
        ylabel="Probability of outcome",
        xticks=0:6)
)
fig

# probability using 'by hand' calculation
tennisTheorProbWin6games = 0.5 * 0.5 * 0.5 * 0.5 * 0.5 * 0.5
# or
tennisTheorProbWin6games = 0.5^6

tennisTheorProbWin6games

# comparison Distributions package vs 'by hand' calculations
(tennisTheorProbs[6], tennisTheorProbWin6games)

# One or Two Tails
(tennisTheorProbs[6] + tennisTheorProbs[0], tennisTheorProbs[6] * 2)

shouldRejectH0(tennisTheorProbs[6] + tennisTheorProbs[0])


###############################################################################
#                            solution to exercises                            #
###############################################################################

# Exercise 1
# (method1, method2, method3)
(10 * 10 * 10 * 10, 10^4, length(0:9999))

# Exercise 2
function myFactorial(n::Int)::Int
    @assert n > 0 "n must be positive"
    if n == 1
        return 1
    else
        return n * myFactorial(n - 1)
    end
end

myFactorial(6)

function myFactorial2(n::Int)::Int
    @assert n > 0 "n must be positive"
    product::Int = 1
    foreach(x -> product *= x, 1:n)
    return product
end

myFactorial2(6)

# Exercise 3

prob1to5 = (0.5^6) * 6 # parenthesis were placed for the sake of clarity
prob0to6 = 0.5^6
probBothOneTail = prob1to5 + prob0to6

probBothOneTail

# for better clarity each method is in a separate line
(
    probBothOneTail,
    1 - Dsts.cdf(Dsts.Binomial(6, 0.5), 4),
    Dsts.pdf.(Dsts.Binomial(6, 0.5), 5:6) |> sum,
    tennisProbs[5] + tennisProbs[6] # experimental probability
)

shouldRejectH0(probBothOneTail, 0.15)

# remember the probability distribution is symmetrical, so *2 is OK here
shouldRejectH0(probBothOneTail * 2, 0.15)

# Exercise 4
# (1/3) that Paul won a single game AND six games in a row (^6)
(
    round((1 / 3)^6, digits=5),
    round(Dsts.pdf(Dsts.Binomial(6, 1 / 3), 6), digits=5)
)

# (1/4) that Paul won a single game AND six games in a row (^6)
(
    round((1 / 4)^6, digits=5),
    round(Dsts.pdf(Dsts.Binomial(6, 1 / 4), 6), digits=5)
)

# Exercise 5
# here no getResultOf1TennisGameUnderHA is needed
function getResultOf6TennisGamesUnderHA()::Int
    return Rand.rand([0, 1, 1, 1, 1, 1], 6) |> sum
end

function play6tennisGamesGetPvalue()::Float64
    # result when HA is true
    result::Int = getResultOf6TennisGamesUnderHA()
    # probability based on which we may decide to reject H0
    oneTailPval::Float64 = Dsts.pdf.(Dsts.Binomial(6, 0.5), result:6) |> sum
    return oneTailPval
end

function didFailToRejectHO(pVal::Float64)::Bool
    return pVal > 0.05
end

numOfSimul = 100_000
Rand.seed!(321)
notRejectedH0 = [
    didFailToRejectHO(play6tennisGamesGetPvalue()) for _ in 1:numOfSimul
]
probOfType2error = sum(notRejectedH0) / length(notRejectedH0)


function getPower(beta::Float64)::Float64
    @assert (0 <= beta <= 1) "beta must be in range [0-1]"
    return 1 - beta
end
powerOfTest = getPower(probOfType2error)

# Figure 10
fig = Cmk.Figure()
Cmk.barplot(fig[1, 1], 0:6, Dsts.Binomial(6, 0.5); color=Cmk.RGBAf(1, 0, 0, 0.4),
    axis=(;
        title="Results of 6 tennis games if H0 is true\np(Peter's win) = 0.5",
        xlabel="Number of times Peter won",
        ylabel="Probability of outcome",
        xticks=0:6)
)
Cmk.vlines!(fig[1, 1], 5.5, 0.32, color="black", linestyle=:dot, linewidth=2.5)
Cmk.text!(fig[1, 1], 5.6, 0.2, text=Cmk.L"$\alpha$ = 0.05", fontsize=12)
Cmk.barplot(fig[1, 2], 0:6, Dsts.Binomial(6, 5 / 6); color=Cmk.RGBAf(0, 0, 1, 0.4),
    axis=(;
        title="Results of 6 tennis games if HA is true\np(Peter's win) = 5/6 = 0.83",
        xlabel="Number of times Peter won",
        ylabel="Probability of outcome",
        xticks=0:6)
)
Cmk.barplot(fig[2:3, 1:2], 0:6, Dsts.Binomial(6, 0.5); color=Cmk.RGBAf(1, 0, 0, 0.4),
    axis=(;
        title="H0 (red) and HA (blue) together.\nBeta - blue bar(s) to the left from the dotted line\nPower - blue bar(s) to the right from the dotted line",
        xlabel="Number of times Peter won",
        ylabel="Probability of outcome",
        xticks=0:6)
)
Cmk.text!(fig[2:3, 1:2], 5.6, 0.35, text=Cmk.L"$\alpha$ = 0.05", fontsize=16)
Cmk.barplot!(fig[2:3, 1:2], 0:6, Dsts.Binomial(6, 5 / 6); color=Cmk.RGBAf(0, 0, 1, 0.4))
Cmk.vlines!(fig[2:3, 1:2], 5.5, 0.32, color="black", linestyle=:dot, linewidth=2.5)
fig

# to the right from that point on x-axis (> point) we reject H0 and choose HA
# n - number of trials (games)
function getXForBinomRightTailProb(n::Int, probH0::Float64,
    rightTailProb::Float64)::Int
    @assert (0 <= rightTailProb <= 1) "rightTailProb must be in range [0-1]"
    @assert (0 <= probH0 <= 1) "probH0 must be in range [0-1]"
    return Dsts.cquantile(Dsts.Binomial(n, probH0), rightTailProb)
end

# n - number of trials (games), x - number of successes (Peter's wins)
# returns probability from far left upto (and including) x
function getBetaForBinomialHA(n::Int, x::Int, probHA::Float64)::Float64
    @assert (0 <= probHA <= 1) "probHA must be in range [0-1]"
    return Dsts.cdf(Dsts.Binomial(n, probHA), x)
end

xCutoff = getXForBinomRightTailProb(6, 0.5, 0.05)
probOfType2error2 = getBetaForBinomialHA(6, xCutoff, 5 / 6)
powerOfTest2 = getPower(probOfType2error2)

(probOfType2error, probOfType2error2, powerOfTest, powerOfTest2)

# Bonus. Sample size estimation

# checks sample sizes between start and finish (inclusive, inclusive)
function getSampleSizeBinomial(probH0::Float64,
    probHA::Float64,
    cutoffBeta::Float64=0.2,
    cutoffAlpha::Float64=0.05,
    start::Int=6, finish::Int=20)::Int
    # other probs are asserted to be within limits in the functions below
    @assert (0 <= cutoffBeta <= 1) "cutoffBeta must be in range [0-1]"
    sampleSize::Int = -99
    xCutoffForAlpha::Int = 0
    beta::Float64 = 1.0
    for n in start:finish
        xCutoffForAlpha = getXForBinomRightTailProb(n, probH0, cutoffAlpha)
        beta = getBetaForBinomialHA(n, xCutoffForAlpha, probHA)
        if beta <= cutoffBeta
            sampleSize = n
            break
        end
    end
    return sampleSize
end

sampleSizeHA5to1 = getSampleSizeBinomial(0.5, 5 / 6, 0.2, 0.05, 6, 20)
sampleSizeHA5to1

# Figure 11
fig = Cmk.Figure()
Cmk.barplot(fig[1, 1], 0:13, Dsts.Binomial(13, 0.5); color=Cmk.RGBAf(1, 0, 0, 0.4),
    axis=(;
        title="Results of 13 tennis games if H0 is true\np(Peter's win) = 0.5",
        xlabel="Number of times Peter won",
        ylabel="Probability of outcome",
        xticks=0:13)
)
Cmk.vlines!(fig[1, 1], 9.5, 0.25, color="black", linestyle=:dot, linewidth=2.5)
Cmk.text!(fig[1, 1], 9.7, 0.15, text=Cmk.L"$\alpha$ = 0.05", fontsize=12)
Cmk.barplot(fig[1, 2], 0:13, Dsts.Binomial(13, 5 / 6); color=Cmk.RGBAf(0, 0, 1, 0.4),
    axis=(;
        title="Results of 13 tennis games if HA is true\np(Peter's win) = 5/6 = 0.83",
        xlabel="Number of times Peter won",
        ylabel="Probability of outcome",
        xticks=0:13)
)
Cmk.barplot(fig[2:3, 1:2], 0:13, Dsts.Binomial(13, 0.5); color=Cmk.RGBAf(1, 0, 0, 0.4),
    axis=(;
        title="H0 (red) and HA (blue) together.\nBeta - blue bar(s) to the left from the dotted line\nPower - blue bar(s) to the right from the dotted line",
        xlabel="Number of times Peter won",
        ylabel="Probability of outcome",
        xticks=0:13)
)
Cmk.text!(fig[2:3, 1:2], 9.7, 0.25, text=Cmk.L"$\alpha$ = 0.05", fontsize=16)
Cmk.barplot!(fig[2:3, 1:2], 0:13, Dsts.Binomial(13, 5 / 6); color=Cmk.RGBAf(0, 0, 1, 0.4))
Cmk.vlines!(fig[2:3, 1:2], 9.5, 0.30, color="black", linestyle=:dot, linewidth=2.5)
fig

(
    # alternative to the line below: 1 - Dsts.cdf(Dsts.Binomial(13, 5/6), 9),
    Dsts.pdf.(Dsts.Binomial(13, 5 / 6), 10:13) |> sum,
    Dsts.cdf(Dsts.Binomial(13, 5 / 6), 9)
)

sampleSizeHA4to2 = getSampleSizeBinomial(0.5, 4 / 6, 0.2, 0.05, 6, 20)
sampleSizeHA4to2

sampleSizeHA4to2 = getSampleSizeBinomial(0.5, 4 / 6, 0.2, 0.05, 6, 100)
sampleSizeHA4to2
