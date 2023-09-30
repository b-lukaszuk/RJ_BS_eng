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
dfEyeColor = Dfs.DataFrame(;
    eyeCol=["blue", "any"], us=[161, 481], uk=[220, 499])

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
1 - Dsts.cdf(Dsts.Chisq(getDf(mEyeColor)), chi2Statistic) |>
x -> round(x, digits=4)
