###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as Cmk
import DataFrames as Dfs
import Distributions as Dsts
import HypothesisTests as Htests
import Random as Rand


###############################################################################
#                                  flashback                                  #
###############################################################################
Htests.BinomialTest(5, 6, 0.5)
# or just: Htests.BinomialTest(5, 6)
# since 0.5 is the default prob. for the population

# some disease prevalence 0.1, desert island 519 adults out of 3’202 affected
Htests.BinomialTest(519, 3202, 0.1)


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
dfEyeColor[2, 2:3] = Vector(dfEyeColor[2, 2:3]) .-
                     Vector(dfEyeColor[1, 2:3])
# renaming eye color "any" to "other" (it better reflects current content)
dfEyeColor[2, 1] = "other"
dfEyeColor

# all the elements must be of the same (numeric) type
mEyeColor = Matrix{Int}(dfEyeColor[:, 2:3])
mEyeColor


Htests.ChisqTest(mEyeColor)

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

Htests.FisherExactTest(a, b, c, d)

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

# DataFrame to Matrix (required by Htests.ChisqTest)
mEyeColorFull = Matrix{Int}(dfEyeColorFull[:, 2:3])
mEyeColorFull

chi2testEyeColor = Htests.ChisqTest(mEyeColor)
chi2testEyeColorFull = Htests.ChisqTest(mEyeColorFull)

(
    # chi^2 statistics
    round(chi2testEyeColorFull.stat, digits=2),
    round(chi2testEyeColor.stat, digits=2),

    # p-values
    round(chi2testEyeColorFull |> Htests.pvalue, digits=7),
    round(chi2testEyeColor |> Htests.pvalue, digits=7)
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
    round(chi2testEyeColor |> Htests.pvalue, digits=7),
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

# more tearse/mystyrious version
function getColPerc2(m::Matrix{Int})::Matrix{Float64}
    colSums::Vector{Int} = [sum(c) for c in eachcol(m)]
    return round.(m ./ transpose(colSums) .* 100, digits=2)
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

# more tearse/mystyrious version
function getRowPerc2(m::Matrix{Int})::Matrix{Float64}
    rowSums::Vector{Int} = [sum(r) for r in eachrow(m)]
    return round.(m ./ rowSums .* 100, digits=2)
end

# testing
all(getColPerc(mEyeColor) .== getColPerc2(mEyeColor))
all(getRowPerc(mEyeColor) .== getRowPerc2(mEyeColor))

all(getColPerc(mEyeColorFull) .== getColPerc2(mEyeColorFull))
all(getRowPerc(mEyeColorFull) .== getRowPerc2(mEyeColorFull))

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
all(getColPerc(mEyeColor) .== getColPerc2(mEyeColor) .==
    getPerc(mEyeColor, false) .== getPerc2(mEyeColor, false))
all(getRowPerc(mEyeColor) .== getRowPerc2(mEyeColor) .==
    getPerc(mEyeColor, true) .== getPerc2(mEyeColor, true))

all(getColPerc(mEyeColorFull) .== getColPerc2(mEyeColorFull) .==
    getPerc(mEyeColorFull, false) .== getPerc2(mEyeColorFull, false))
all(getRowPerc(mEyeColorFull) .== getRowPerc2(mEyeColorFull) .==
    getPerc(mEyeColorFull, true) .== getPerc2(mEyeColorFull, true))


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
    Cmk.Axis(fig[1, 1],
        title=title,
        xlabel=dfColLabel, ylabel="% of data",
        xticks=(xs, colNames),
        yticks=0:10:100)

    for r in 1:nRows
        curPerc = columnPerc[r, :]
        push!(barplots,
            Cmk.barplot!(fig[1, 1], xs, curPerc,
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
    Cmk.Axis(fig[1, 1],
        title=title,
        xlabel=xlabel, ylabel=ylabel,
        xticks=xticks,
        yticks=yticks)

    for r in 1:nRows
        curPerc = (byRow ? dimPerc[:, r] : dimPerc[r, :])
        push!(barplots,
            Cmk.barplot!(fig[1, 1], xs, curPerc,
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