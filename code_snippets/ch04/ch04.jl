###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as cmk
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

outcomeOf1bet = (diceProbs[12] * 125) - ((1 - diceProbs[12]) * 5)
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

function getSortedKeysVals(d::Dict{T1,T2})::Tuple{Vector{T1},Vector{T2}} where {T1,T2}
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