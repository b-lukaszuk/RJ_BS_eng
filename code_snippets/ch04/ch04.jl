###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as cmk
import Distributions as dsts
import Random as rnd

###############################################################################
#                      Probability - theory and practice                      #
###############################################################################
rnd.seed!(321) # optional, needed for reproducibility
gametes = rnd.rand(["A", "B"], 16_000);
first(gametes, 5)

function getCounts(v::Vector{T})::Dict{T,Int} where {T}
    counts::Dict{T,Int} = Dict()
    for elt in v
        if haskey(counts, elt) #1
            counts[elt] = counts[elt] + 1 #2
        else #3
            counts[elt] = 1 #4
        end #5
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
rnd.seed!(321)
gametes = rnd.rand([0, 1], 16_000);
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
    return sum(rnd.rand(1:6, 2))
end

rnd.seed!(321)
numOfRolls = 100_000
diceRolls = [getSumOf2DiceRoll() for _ in 1:numOfRolls]
diceCounts = getCounts(diceRolls)
diceProbs = getProbs(diceCounts)

(diceCounts[12], diceProbs[12])

function getOutcomeOfBet(probWin::Float64, moneyWin::Real,
    probLoose::Float64, moneyLoose::Real)::Float64
    return (probWin * moneyWin) - (probLoose * moneyLoose)
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

fig = cmk.Figure()
cmk.barplot(fig[1, 1:2], xs1, ys1,
    color="red",
    axis=(;
        title="Rolling 2 dice 100'000 times",
        xlabel="Sum of dots",
        ylabel="Number of occurrences",
        xticks=2:12)
)
cmk.barplot(fig[2, 1:2], xs2, ys2,
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
rnd.seed!(321)
binom = rnd.rand(0:1, 100_000)
binomCounts = getCounts(binom)
binomProbs = getProbs(binomCounts)

# multinomial distribution
rnd.seed!(321)
multinom = rnd.rand(1:6, 100_000)
multinomCounts = getCounts(multinom)
multinomProbs = getProbs(unifCounts)

multinomXs, multinomYs = getSortedKeysVals(multinomProbs)
binomXs, binomYs = getSortedKeysVals(binomProbs)

fig = cmk.Figure()
cmk.barplot(fig[1:2, 1], binomXs, binomYs,
    color="blue",
    axis=(;
        title="Binomial distribution (tossing a fair coin)",
        xlabel="Number of heads",
        ylabel="Probability of outcome",
        xticks=0:1)
)
cmk.barplot(fig[1:2, 2], unifXs, unifYs,
    color="red",
    axis=(;
        title="Multinomial distribution (rolling 6-sided dice)",
        xlabel="Number of dots",
        ylabel="Probability of outcome",
        xticks=1:6)
)
fig

# normal distribution
fig = cmk.Figure()
# Standard normal distribution
cmk.lines(fig[1, 1:2], dsts.Normal(0, 1),
    color="red",
    axis=(;
        title="Standard normal distribution",
        xlabel="x",
        ylabel="Probability of outcome",
        xticks=-3:3)
)
# real life normal distribution
rnd.seed!(321)
heights = round.(rnd.rand(dsts.Normal(172, 7), 20_000_000), digits=0)
heightsCounts = getCounts(heights)
heightsProbs = getProbs(heightsCounts)
heightsXs, heightsYs = getSortedKeysVals(heightsProbs)

cmk.barplot(fig[2, 1:2], heightsXs, heightsYs,
    color=cmk.RGBAf(0, 0, 1, 0.4),
    axis=(;
        title="Plausible distribution of male's height in Poland",
        xlabel="Height in cm",
        ylabel="Probability of outcome",
        xticks=151:7:193)
)
cmk.lines!(fig[2, 1:2], heightsXs, heightsYs,
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
    squaredDiffs = diffs .^ 2
    return sqrt(getAvg(squaredDiffs))
end

(getSd(gradesStudA), getSd(gradesStudB))

# distribution package examples
dsts.cdf(dsts.Normal(100, 24), 139)

1 - dsts.cdf(dsts.Normal(172, 7), 181)

dsts.pdf(dsts.Binomial(2, 1 / 6), 2)

heightDist = dsts.Normal(172, 7)
# 2 digits after dot because of the assumed precision of a measuring device
dsts.cdf(heightDist, 181.49) - dsts.cdf(heightDist, 180.50)