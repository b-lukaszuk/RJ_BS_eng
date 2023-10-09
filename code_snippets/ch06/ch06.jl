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

# here all elements must be of the same (numeric) type
mEyeColor = Matrix{Int}(dfEyeColor[:, 2:3])
mEyeColor[2, :] = mEyeColor[2, :] .- mEyeColor[1, :]
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
rowPerc = round.(rowPerc, digits = 2)

(
    round(chi2testEyeColor.stat, digits=2),
    round(chi2testEyeColor |> Htests.pvalue, digits=7),
    rowPerc
)
