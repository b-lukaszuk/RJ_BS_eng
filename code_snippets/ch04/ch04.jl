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
#                            binomial distribution                            #
###############################################################################
function getSum2DiceRoll()::Int
    return sum(rnd.rand(1:6, 2))
end

rnd.seed!(321)
diceRolls = [getSum2DiceRoll() for _ in 1:100_000]
diceCounts = getCounts(diceRolls)

diceDotsSums = keys(diceCounts) |> collect |> sort
diceSumsCounts = [diceCounts[ds] for ds in diceDotsSums]
diceSumsProbs = [diceCounts[ds] / sum(diceSumsCounts) for ds in diceDotsSums]

cmk.barplot(diceDotsSums, diceSumsCounts,
    axis=(;
        title="Rolling 2 dice 100'000 times",
        xlabel="Sum of dots",
        ylabel="Number of occurences",
        xticks=2:12))