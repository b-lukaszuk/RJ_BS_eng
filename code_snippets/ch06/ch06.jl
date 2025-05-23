###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as Cmk
import DataFrames as Dfs
import Distributions as Dsts
import HypothesisTests as Ht
import MultipleTesting as Mt
import Random as Rand


###############################################################################
#                                  flashback                                  #
###############################################################################
Ht.BinomialTest(5, 6, 0.5)
# or just: Ht.BinomialTest(5, 6)
# since 0.5 is the default prob. for the population

# some disease prevalence 0.1, desert island 519 adults out of 3’202 affected
Ht.BinomialTest(519, 3202, 0.1)


###############################################################################
#                               chi squared test                              #
###############################################################################
dfEyeColor = Dfs.DataFrame(
    Dict(
        "eyeCol" => ["blue", "any"],
        "us" => [161, 481],
        "uk" => [220, 499]
    )
)

# subtracting eye color "blue" from eye color "any"
dfEyeColor[2, 2:3] = Vector(dfEyeColor[2, 2:3]) .- Vector(dfEyeColor[1, 2:3])
# renaming eye color "any" to "other" (it better reflects current content)
dfEyeColor[2, 1] = "other"
dfEyeColor

# all the elements must be of the same (numeric) type
mEyeColor = Matrix{Int}(dfEyeColor[:, 2:3])
mEyeColor


Ht.ChisqTest(mEyeColor)

# total number of observations
nObsEyeColor = sum(mEyeColor)

# point estimates
chi2pointEstimates = [mEyeColor...] ./ nObsEyeColor
round.(chi2pointEstimates, digits=6)

# cProbs - probability of a value to be found in a given column
cProbs = [sum(c) for c in eachcol(mEyeColor)] ./ nObsEyeColor
# rProbs - probability of a value to be found in a given row
rProbs = [sum(r) for r in eachrow(mEyeColor)] ./ nObsEyeColor

# probability of a value to be found in a given cell of mEyeColor
# under H_0 (the samples are from the same population)
probsUnderH0 = [cp * rp for cp in cProbs for rp in rProbs]
round.(probsUnderH0, digits=6)

# calculating chi^2 statistic
observedCounts = [mEyeColor...]
expectedCounts = probsUnderH0 .* nObsEyeColor
# the statisticians love squaring things, don't they
chi2Diffs = ((observedCounts .- expectedCounts) .^ 2) ./ expectedCounts
chi2Statistic = sum(chi2Diffs)

(
    observedCounts,
    round.(expectedCounts, digits=4),
    round.(chi2Diffs, digits=4),
    round(chi2Statistic, digits=4)
)

# obtaining p-value for chi^2 statistic
function getDf(matrix::Matrix{Int})::Int
    nRows, nCols = size(matrix)
    return (nRows - 1) * (nCols - 1)
end

# p-value
# alternative: Dsts.ccdf(Dsts.Chisq(getDf(mEyeColor)), chi2Statistic)
1 - Dsts.cdf(Dsts.Chisq(getDf(mEyeColor)), chi2Statistic) |> x -> round(x, digits=4)


###############################################################################
#                             Fisher's exact test                             #
###############################################################################
# smaller matrix
mEyeColorSmall = round.(Int, mEyeColor ./ 20)
mEyeColorSmall

# assignment goes column by column (left to right), value by value
a, c, b, d = mEyeColorSmall

Ht.FisherExactTest(a, b, c, d)

###############################################################################
#                                 Bigger table                                #
###############################################################################
mEyeColor

# 3 x 2 table (DataFrame)
dfEyeColorFull = Dfs.DataFrame(
    Dict(
        # "other" from dfEyeColor is split into "green" and "brown"
        "eyeCol" => ["blue", "green", "brown"],
        "us" => [161, 78, 242],
        "uk" => [220, 149, 130]
    )
)

# DataFrame to Matrix (required by Ht.ChisqTest)
mEyeColorFull = Matrix{Int}(dfEyeColorFull[:, 2:3])
mEyeColorFull

chi2testEyeColor = Ht.ChisqTest(mEyeColor)
chi2testEyeColorFull = Ht.ChisqTest(mEyeColorFull)

(
    # chi^2 statistics
    round(chi2testEyeColorFull.stat, digits=2),
    round(chi2testEyeColor.stat, digits=2),

    # p-values
    round(chi2testEyeColorFull |> Ht.pvalue, digits=7),
    round(chi2testEyeColor |> Ht.pvalue, digits=7)
)

###############################################################################
#                            Test for independence                          #
###############################################################################
# rows (top - bottom: blue, green, brown)
# columns before (left - right: uk, us)
# columns now (left - right: diseaseX, noDiseaseX)
mEyeColorFull

# row percentages for collapsed rows (eye color: blue, other)
# here it means percentage of people with a given eye color that have diseaseX
rowPerc = [r[1] / sum(r) * 100 for r in eachrow(mEyeColor)]
rowPerc = round.(rowPerc, digits=2)

(
    round(chi2testEyeColor.stat, digits=2),
    round(chi2testEyeColor |> Ht.pvalue, digits=7),
    rowPerc
)


###############################################################################
#                             Exercise 1. Solution                            #
###############################################################################

# test data set 1
Rand.seed!(321)
smoker = Rand.rand(["no", "yes"], 100)
profession = Rand.rand(["Lawyer", "Priest", "Teacher"], 100)

# test data set 2
Rand.seed!(321)
smokerSmall = Rand.rand(["no", "yes"], 10)
professionSmall = Rand.rand(["Lawyer", "Priest", "Teacher"], 10)

# solution
function getCounts(v::Vector{T})::Dict{T,Int} where {T}
    counts::Dict{T,Int} = Dict()
    for elt in v
        counts[elt] = get(counts, elt, 0) + 1
    end
    return counts
end

function getContingencyTable(
    rowVect::Vector{String},
    colVect::Vector{String},
    rowLabel::String,
    colLabel::String,
)::Dfs.DataFrame

    rowNames::Vector{String} = sort(unique(rowVect))
    colNames::Vector{String} = sort(unique(colVect))
    pairs::Vector{Tuple{String,String}} = collect(zip(rowVect, colVect))
    pairsCounts::Dict{Tuple{String,String},Int} = getCounts(pairs)
    labels::String = "↓$rowLabel/$colLabel→" # template string
    df::Dfs.DataFrame = Dfs.DataFrame()
    columns::Dict{String,Vector{Int}} = Dict()

    for cn in colNames
        columns[cn] = [get(pairsCounts, (rn, cn), 0) for rn in rowNames]
    end

    df = Dfs.DataFrame(columns)
    Dfs.insertcols!(df, 1, labels => rowNames)

    return df
end

# testing solution
# test 1
smokersByProfession = getContingencyTable(
    smoker,
    profession,
    "smoker",
    "profession"
)

# test 2
smokersByProfessionTransposed = getContingencyTable(
    profession,
    smoker,
    "profession",
    "smoker"
)

# test 3
smokersByProfessionSmall = getContingencyTable(
    smokerSmall,
    professionSmall,
    "smoker",
    "profession"
)


###############################################################################
#                             Exercise 2. Solution                            #
###############################################################################
function getColPerc(m::Matrix{Int})::Matrix{Float64}
    nRows, nCols = size(m)
    percentages::Matrix{Float64} = zeros(nRows, nCols)
    for c in 1:nCols
        for r in 1:nRows
            percentages[r, c] = m[r, c] / sum(m[:, c])
            percentages[r, c] = round(percentages[r, c] * 100, digits=2)
        end
    end
    return percentages
end

function getRowPerc(m::Matrix{Int})::Matrix{Float64}
    nRows, nCols = size(m)
    percentages::Matrix{Float64} = zeros(nRows, nCols)
    for c in 1:nCols
        for r in 1:nRows
            percentages[r, c] = m[r, c] / sum(m[r, :])
            percentages[r, c] = round(percentages[r, c] * 100, digits=2)
        end
    end
    return percentages
end

# testing
getColPerc(mEyeColor)
getRowPerc(mEyeColor)

getColPerc(mEyeColorFull)
getRowPerc(mEyeColorFull)

function getPerc(m::Matrix{Int}, byRow::Bool)::Matrix{Float64}
    nRows, nCols = size(m)
    percentages::Matrix{Float64} = zeros(nRows, nCols)
    dimSum::Int = 0 # sum in a given dimension of a matrix
    for c in 1:nCols
        for r in 1:nRows
            dimSum = (byRow ? sum(m[r, :]) : sum(m[:, c]))
            percentages[r, c] = m[r, c] / dimSum
            percentages[r, c] = round(percentages[r, c] * 100, digits=2)
        end
    end
    return percentages
end

function getPerc2(m::Matrix{Int}, byRow::Bool)::Matrix{Float64}
    dimSums::Vector{Int} = [sum(d) for d in (byRow ? eachrow(m) : eachcol(m))]
    transformingFn::Function = (byRow ? identity : transpose)
    return round.(m ./ (transformingFn(dimSums)) .* 100, digits=2)
end

# Testing
# a matrix
mEyeColor

eyeColorColPerc = getPerc(mEyeColor, false)
eyeColorColPerc

eyeColorRowPerc = getPerc(mEyeColor, true)
eyeColorRowPerc

# another matrix
mEyeColorFull

eyeColorColPercFull = getPerc(mEyeColorFull, true)
eyeColorColPercFull

# more testing
all(getColPerc(mEyeColor) .==
    getPerc(mEyeColor, false) .== getPerc2(mEyeColor, false))
# the above is equivalent to:
getColPerc(mEyeColor) == getPerc(mEyeColor, false) == getPerc2(mEyeColor, false)

# even more testing
getRowPerc(mEyeColor) == getPerc(mEyeColor, true) == getPerc2(mEyeColor, true)

getColPerc(mEyeColorFull) == getPerc(
    mEyeColorFull, false) == getPerc2(mEyeColorFull, false)

getRowPerc(mEyeColorFull) == getPerc(
    mEyeColorFull, true) == getPerc2(mEyeColorFull, true)


###############################################################################
#                             Exercise 3. Solution                            #
###############################################################################
function drawColPerc(df::Dfs.DataFrame,
    dfColLabel::String,
    dfRowLabel::String,
    title::String,
    dfRowColors::Vector{String})::Cmk.Figure

    m::Matrix{Int} = Matrix{Int}(df[:, 2:end])
    columnPerc::Matrix{Float64} = getPerc(m, false)
    nRows, nCols = size(columnPerc)
    colNames::Vector{String} = names(df)[2:end]
    rowNames::Vector{String} = df[1:end, 1]
    xs::Vector{Int} = collect(1:nCols)
    offsets::Vector{Float64} = zeros(nCols)
    curPerc::Vector{Float64} = []
    barplots = []

    fig = Cmk.Figure()
    ax1 = Cmk.Axis(fig[1, 1],
                   title=title, xlabel=dfColLabel, ylabel="% of data",
                   xticks=(xs, colNames), yticks=0:10:100)

    for r in 1:nRows
        curPerc = columnPerc[r, :]
        push!(barplots,
              Cmk.barplot!(ax1, xs, curPerc,
                           offset=offsets, color=dfRowColors[r]))
        offsets = offsets .+ curPerc
    end
    Cmk.Legend(fig[1, 2], barplots, rowNames, dfRowLabel)

    return fig
end

drawColPerc(dfEyeColorFull, "Country", "Eye color",
    "Eye Color distribution by country\n(column percentages)",
    ["lightblue1", "seagreen3", "peachpuff3"])

function drawPerc(df::Dfs.DataFrame, byRow::Bool,
    dfColLabel::String,
    dfRowLabel::String,
    title::String,
    groupColors::Vector{String})::Cmk.Figure

    m::Matrix{Int} = Matrix{Int}(df[:, 2:end])
    dimPerc::Matrix{Float64} = getPerc(m, byRow)
    nRows, nCols = size(dimPerc)
    colNames::Vector{String} = names(df)[2:end]
    rowNames::Vector{String} = df[1:end, 1]
    ylabel::String = "% of data"
    xlabel::String = (byRow ? dfRowLabel : dfColLabel)
    xs::Vector{Int} = collect(1:nCols)
    yticks::Tuple{Vector{Int},Vector{String}} = (
        collect(0:10:100), map(string, 0:10:100)
    )
    xticks::Tuple{Vector{Int},Vector{String}} = (xs, colNames)

    if byRow
        nRows, nCols = nCols, nRows
        xs = collect(1:nCols)
        colNames, rowNames = rowNames, colNames
        dfColLabel, dfRowLabel = dfRowLabel, dfColLabel
        xlabel, ylabel = ylabel, xlabel
        yticks, xticks = (xs, colNames), yticks
    end

    offsets::Vector{Float64} = zeros(nCols)
    curPerc::Vector{Float64} = []
    barplots = []

    fig = Cmk.Figure()
    ax1 = Cmk.Axis(fig[1, 1], title=title,
                   xlabel=xlabel, ylabel=ylabel,
                   xticks=xticks, yticks=yticks)

    for r in 1:nRows
        curPerc = (byRow ? dimPerc[:, r] : dimPerc[r, :])
        push!(barplots,
              Cmk.barplot!(ax1, xs, curPerc,
                           offset=offsets, color=groupColors[r],
                           direction=(byRow ? :x : :y)))
        offsets = offsets .+ curPerc
    end
    Cmk.Legend(fig[1, 2], barplots, rowNames, dfRowLabel)

    return fig
end

# testing
getPerc(mEyeColorFull, false)
drawColPerc(dfEyeColorFull, "Country", "Eye color",
    "Eye Color distribution by country\n(column percentages)",
    ["lightblue1", "seagreen3", "peachpuff3"])
drawPerc(dfEyeColorFull, false,
    "Country", "Eye color",
    "Eye Color distribution by country\n(percentages)",
    ["lightblue1", "seagreen3", "peachpuff3"])

# more testing
getPerc(mEyeColorFull, true)
drawPerc(dfEyeColorFull, true,
    "Country", "Eye color",
    "Eye Color distribution by country\n(row percentages)",
    ["red", "blue"])


###############################################################################
#                             Exercise 4. Solution                            #
###############################################################################
# helper functions
function isSumAboveCutoff(m::Matrix{Int}, cutoff::Int=49)::Bool
    return sum(m) > cutoff
end

function getExpectedCounts(m::Matrix{Int})::Vector{Float64}
    nObs::Int = sum(m)
    cProbs::Vector{Float64} = [sum(c) / nObs for c in eachcol(m)]
    rProbs::Vector{Float64} = [sum(r) / nObs for r in eachrow(m)]
    probsUnderH0::Vector{Float64} = [
        cp * rp for cp in cProbs for rp in rProbs
    ]
    return probsUnderH0 .* nObs
end

function areAllExpectedCountsAboveCutoff(
    m::Matrix{Int}, cutoff::Float64=5.0)::Bool
    expectedCounts::Vector{Float64} = getExpectedCounts(m)
    return map(x -> x >= cutoff, expectedCounts) |> all
end

function areChiSq2AssumptionsOK(m::Matrix{Int})::Bool
    sumGTEQ50::Bool = isSumAboveCutoff(m)
    allExpValsGTEQ5::Bool = areAllExpectedCountsAboveCutoff(m)
    return sumGTEQ50 && allExpValsGTEQ5
end

# proper functionality for ex 4 solution
function runFisherExactTestGetPVal(m::Matrix{Int})::Float64
    @assert (size(m) == (2, 2)) "input matrix must be of size (2, 2)"
    a, c, b, d = m
    return Ht.FisherExactTest(a, b, c, d) |> Ht.pvalue
end

function runCategTestGetPVal(m::Matrix{Int})::Float64
    @assert (size(m) == (2, 2)) "input matrix must be of size (2, 2)"
    if areChiSq2AssumptionsOK(m)
        return Ht.ChisqTest(m) |> Ht.pvalue
    else
        return runFisherExactTestGetPVal(m)
    end
end

function runCategTestGetPVal(df::Dfs.DataFrame)::Float64
    @assert (size(df) == (2, 3)) "input df must be of size (2, 3)"
    return runCategTestGetPVal(Matrix{Int}(df[:, 2:3]))
end

# testing
round.(
    [
        runCategTestGetPVal(mEyeColor),
        runCategTestGetPVal(mEyeColorSmall),
        runCategTestGetPVal(dfEyeColor)
    ],
    digits=4
)


###############################################################################
#                             Exercise 5. Solution                            #
###############################################################################
# previously (ch05) defined function
function getUniquePairs(names::Vector{T})::Vector{Tuple{T,T}} where T
    @assert (length(names) >= 2) "the input must be of length >= 2"
    uniquePairs::Vector{Tuple{T,T}} =
        Vector{Tuple{T,T}}(undef, binomial(length(names), 2))
    currInd::Int = 1
    for i in eachindex(names)[1:(end-1)]
        for j in eachindex(names)[(i+1):end]
            uniquePairs[currInd] = (names[i], names[j])
            currInd += 1
        end
    end
    return uniquePairs
end

function get2x2Dfs(biggerDf::Dfs.DataFrame)::Vector{Dfs.DataFrame}
    nRows, nCols = size(biggerDf)
    @assert ((nRows > 2) || (nCols > 3)) "matrix of counts must be > 2x2"
    rPairs::Vector{Tuple{Int,Int}} = getUniquePairs(collect(1:nRows))
    # counts start from column 2
    cPairs::Vector{Tuple{Int,Int}} = getUniquePairs(collect(2:nCols))
    return [
        biggerDf[[r...], [1, c...]] for r in rPairs for c in cPairs
    ]
end

function runCategTestsGetPVals(
    biggerDf::Dfs.DataFrame
)::Tuple{Vector{Dfs.DataFrame},Vector{Float64}}
    overallPVal::Float64 = Ht.ChisqTest(
        Matrix{Int}(biggerDf[:, 2:end])) |> Ht.pvalue
    if (overallPVal <= 0.05)
        dfs::Vector{Dfs.DataFrame} = get2x2Dfs(biggerDf)
        pvals::Vector{Float64} = runCategTestGetPVal.(dfs)
        return (dfs, pvals)
    else
        return ([biggerDf], [overallPVal])
    end
end

# testing, data frames
resultCategTests = runCategTestsGetPVals(dfEyeColorFull)
resultCategTests[1]
# testing, corresponding unadjusted p-values
resultCategTests[2]

# adjusting p-values
function adjustPVals(
    multCategTestsResults::Tuple{Vector{Dfs.DataFrame},Vector{Float64}},
    multCorr::Type{<:Mt.PValueAdjustment}
)::Tuple{Vector{Dfs.DataFrame},Vector{Float64}}
    dfs, pvals = multCategTestsResults
    adjPVals::Vector{Float64} = Mt.adjust(pvals, multCorr())
    return (dfs, adjPVals)
end

resultAdjustedCategTests = adjustPVals(resultCategTests, Mt.Bonferroni)
resultAdjustedCategTests[2]


###############################################################################
#                             Exercise 6. Solution                            #
###############################################################################
function drawColPerc2(
    biggerDf::Dfs.DataFrame,
    dfColLabel::String,
    dfRowLabel::String,
    title::String,
    dfRowColors::Dict{String,String},
    alpha::Float64=0.05,
    adjMethod::Type{<:Mt.PValueAdjustment}=Mt.Bonferroni)::Cmk.Figure

    multCategTests::Tuple{
        Vector{Dfs.DataFrame},
        Vector{Float64}} = runCategTestsGetPVals(biggerDf)
    multCategTests = adjustPVals(multCategTests, adjMethod)
    dfs, pvals = multCategTests

    fig = Cmk.Figure(size=(800, 400 * length(dfs)))

    for i in eachindex(dfs)
        m::Matrix{Int} = Matrix{Int}(dfs[i][:, 2:end])
        columnPerc::Matrix{Float64} = getPerc(m, false)
        nRows, nCols = size(columnPerc)
        colNames::Vector{String} = names(dfs[i])[2:end]
        rowNames::Vector{String} = dfs[i][1:end, 1]
        xs::Vector{Int} = collect(1:nCols)
        offsets::Vector{Float64} = zeros(nCols)
        curPerc::Vector{Float64} = []
        barplots = []

        ax = Cmk.Axis(fig[i, 1],
                      title=title, xlabel=dfColLabel, ylabel="% of data",
                      xticks=(xs, colNames), yticks=0:10:100)

        for r in 1:nRows
            curPerc = columnPerc[r, :]
            push!(barplots,
                  Cmk.barplot!(ax, xs, curPerc,
                               offset=offsets,
                               color=get(dfRowColors, rowNames[r], "black"),
                               strokewidth=(pvals[i] <= alpha) ? 2 : 0))
            offsets = offsets .+ curPerc
        end
        Cmk.Legend(fig[i, 2], barplots, rowNames, dfRowLabel)
    end

    return fig
end

# testing
drawColPerc2(dfEyeColorFull, "Country", "Eye color", "Eye color by country",
    Dict("blue" => "lightblue1",
        "green" => "seagreen3",
        "brown" => "peachpuff3"))
