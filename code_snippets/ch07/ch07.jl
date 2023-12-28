###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import Distributions as Dsts
import GLM as Glm
import MultipleTesting as Mt
import RDatasets as RD
import Random as Rand
import Statistics as Stats


###############################################################################
#                               linear relation                               #
###############################################################################
biomass = Csv.read("./biomass.csv", Dfs.DataFrame)
first(biomass, 3)

# Figure 27
fig = Cmk.Figure()
ax1, sc1 = Cmk.scatter(fig[1, 1], biomass.rainL, biomass.plantAkg,
    markersize=25, color="skyblue", strokewidth=1, strokecolor="gray",
    axis=(; title="Effect of rainfall on biomass of plant A",
        xlabel="water [L]", ylabel="biomass [kg]")
)
ax2, sc2 = Cmk.scatter(fig[1, 2], biomass.rainL, biomass.plantBkg,
    markersize=25, color="linen", strokewidth=1, strokecolor="black",
    axis=(; title="Effect of rainfall on bomass of plant B",
        xlabel="water [L]", ylabel="biomass [kg]")
)
Cmk.linkxaxes!(ax1, ax2)
Cmk.linkyaxes!(ax1, ax2)
fig


###############################################################################
#                                  covariance                                 #
###############################################################################
function getCov(v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
    @assert length(v1) == length(v2) "v1 and v2 must be of equal lengths"
    avg1::Float64 = Stats.mean(v1)
    avg2::Float64 = Stats.mean(v2)
    diffs1::Vector{<:Real} = v1 .- avg1
    diffs2::Vector{<:Real} = v2 .- avg2
    return sum(diffs1 .* diffs2) / (length(v1) - 1)
end

# Different types of relation between data
rowLenBiomass, _ = size(biomass)
(
    # assuming: getCov(xs, ys),
    # you may test the distributions with: Cmk.scatter(xs, ys)
    getCov(biomass.rainL, biomass.plantAkg), # /
    getCov(collect(1:1:rowLenBiomass), collect(rowLenBiomass:-1:1)), # \
    getCov(repeat([5], rowLenBiomass), biomass.plantAkg), # |
    getCov(biomass.rainL, repeat([5], rowLenBiomass)) # -
)

# Covariances for plantA and plantB
covPlantA = getCov(biomass.plantAkg, biomass.rainL)
covPlantB = getCov(biomass.plantBkg, biomass.rainL)
(
    covPlantA,
    covPlantB,
)

# Figure 28
covPlantAkg = covPlantA
plantApounds = biomass.plantAkg .* 2.205
covPlantAponds = getCov(plantApounds, biomass.rainL)
fig = Cmk.Figure()
ax1, sc1 = Cmk.scatter(fig[1, 1], biomass.rainL, biomass.plantAkg,
    markersize=25, color="skyblue", strokewidth=1, strokecolor="gray",
    axis=(; title="Effect of rainfall on biomass\nof plant A [kg]",
        xlabel="water [L]", ylabel="biomass [kg]")
)
Cmk.text!(fig[1, 1], 6, 18, text="cov(x, y) = $(round(covPlantAkg, digits=2))")
ax2, sc2 = Cmk.scatter(fig[1, 2], biomass.rainL, plantApounds,
    markersize=25, color="skyblue", strokewidth=1, strokecolor="gray",
    axis=(; title="Effect of rainfall on bomass\nof plant A [pounds]",
        xlabel="water [L]", ylabel="biomass [pounds]")
)
Cmk.text!(fig[1, 2], 6, 18 * 2.205, text="cov(x, y) = $(round(covPlantAponds, digits=2))")
Cmk.linkxaxes!(ax1, ax2)
fig

# Covariance is easily inflated by the units of measurements
(
    getCov(biomass.plantAkg, biomass.rainL),
    getCov(biomass.plantAkg .* 2.205, biomass.rainL),
)


###############################################################################
#                                 correlation                                 #
###############################################################################
# calculates the Pearson correlation coefficient
function getCor(v1::Vector{<:Real}, v2::Vector{<:Real})::Float64
    return getCov(v1, v2) / (Stats.std(v1) * Stats.std(v2))
end

biomassCors = (
    getCor(biomass.plantAkg, biomass.rainL),
    getCor(biomass.plantAkg .* 2.205, biomass.rainL), # pounds
    getCor(biomass.plantBkg, biomass.rainL),
    getCor(biomass.plantBkg .* 2.205, biomass.rainL), # pounds
)
round.(biomassCors, digits=2)


# correlation is influenced by both line slope and spread of points
Rand.seed!(321)
jitter = Rand.rand(-0.2:0.01:0.2, 10)
z1 = collect(1:10)
z2 = repeat([5], 10)
(
    getCor(z1 .+ jitter, z1), # / imaginary line
    getCor(z1, z2 .+ jitter) # - imaginary line
)


# calculates the Pearson correlation coefficient and pvalue
# assumption (not tested in the function): v1 & v2 got normal distributions
function getCorAndPval(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Tuple{Float64,Float64}
    r::Float64 = getCov(v1, v2) / (Stats.std(v1) * Stats.std(v2))
    n::Int = length(v1) # num of points
    df::Int = n - 2
    t::Float64 = r * sqrt(df / (1 - r^2)) # t-statistics
    leftTail::Float64 = Dsts.cdf(Dsts.TDist(df), t)
    pval::Float64 = (t > 0) ? (1 - leftTail) : leftTail
    return (r, pval * 2) # (* 2) two-tailed probability
end

biomassCorsPvals = (
    getCorAndPval(biomass.plantAkg, biomass.rainL),
    getCorAndPval(biomass.plantAkg .* 2.205, biomass.rainL), # pounds
    getCorAndPval(biomass.plantBkg, biomass.rainL),
    getCorAndPval(biomass.plantBkg .* 2.205, biomass.rainL), # pounds
)
biomassCorsPvals


###############################################################################
#                             correlation pitfalls                            #
###############################################################################
anscombe = RD.dataset("datasets", "anscombe")

# Figure 29
fig = Cmk.Figure()
i = 0
for r in 1:2 # r - row
    for c in 1:2 # c - column
        i += 1
        xname = string("X", i)
        yname = string("Y", i)
        xs = anscombe[:, xname]
        ys = anscombe[:, yname]
        cor, pval = getCorAndPval(xs, ys)
        Cmk.scatter(fig[r, c], xs, ys,
            axis=(;
                title=string("Figure ", "ABCD"[i]),
                xlabel=xname, ylabel=yname,
                limits=(0, 20, 0, 15)
            ))
        Cmk.text!(fig[r, c], 9, 3, text="cor(x, y) = $(round(cor, digits=2))")
        Cmk.text!(fig[r, c], 9, 1, text="p-val = $(round(pval, digits=4))")
    end
end
fig

# miceLengths data set
miceLengths = Csv.read("./miceLengths.csv", Dfs.DataFrame)

getCorAndPval(miceLengths.bodyCm, miceLengths.tailCm)

# Figure 30
fig = Cmk.Figure()
ax = Cmk.Axis(fig[1, 1],
    title="Mice body length vs. tail length",
    xlabel="body length [cm]",
    ylabel="tail length [cm]")
for sex in ["f", "m"]
    df = miceLengths[miceLengths.sex.==sex, :]
    Cmk.scatter!(df.bodyCm, df.tailCm,
        color=(sex == "f" ? "salmon1" : "skyblue2"),
        label=(sex == "f" ? "female" : "male"),
        marker=(sex == "f" ? :circle : :utriangle),
        markersize=20, strokewidth=1, strokecolor="gray"
    )
end
Cmk.ablines!(fig[1, 1], -1.3632, 0.4277,
    linestyle=:dash, color="lightgray", linewidth=2)
fig[1, 2] = Cmk.Legend(fig, ax, "Sex", framevisible=false)
fig

# fml - female mice lengths
# mml - male mice lengths
fml = miceLengths[miceLengths.sex.=="f", :] # choose only females
mml = miceLengths[miceLengths.sex.=="m", :] # choose only males
(
    getCorAndPval(fml.bodyCm, fml.tailCm),
    getCorAndPval(mml.bodyCm, mml.tailCm)
)

# candyBars data set
candyBars = Csv.read("./candyBars.csv", Dfs.DataFrame)
first(candyBars, 5)

getCorAndPval(candyBars.carb, candyBars.fat)
getCorAndPval(candyBars.carb, candyBars.total)

Rand.seed!(321)
aa = Rand.rand(Dsts.Normal(100, 15), 10)
getCorAndPval(aa, aa)

bb = Rand.rand(Dsts.Normal(100, 15), 10)
getCorAndPval(aa, bb)

cc = aa .+ bb
(
    getCorAndPval(aa, cc),
    getCorAndPval(bb, cc)
)


###############################################################################
#                           Simple Linear Regression                          #
###############################################################################
biomass = Csv.read("./biomass.csv", Dfs.DataFrame)
first(biomass, 5)

function getSlope(xs::Vector{<:Real}, ys::Vector{<:Real})::Float64
    avgXs::Float64 = Stats.mean(xs)
    avgYs::Float64 = Stats.mean(ys)
    diffsXs::Vector{<:Real} = xs .- avgXs
    diffsYs::Vector{<:Real} = ys .- avgYs
    return sum(diffsXs .* diffsYs) / sum(diffsXs .^ 2)
end

function getIntercept(xs::Vector{<:Real}, ys::Vector{<:Real})::Float64
    return Stats.mean(ys) - getSlope(xs, ys) * Stats.mean(xs)
end

# be careful unlike getCor or getCov, here the order of variables
# in parameters influences the result
plantAIntercept = getIntercept(biomass.rainL, biomass.plantAkg)
plantASlope = getSlope(biomass.rainL, biomass.plantAkg)
plantBIntercept = getIntercept(biomass.rainL, biomass.plantBkg)
plantBSlope = getSlope(biomass.rainL, biomass.plantBkg)

round.([plantASlope, plantBSlope], digits=2)

# Figure 35
fig = Cmk.Figure()
ax1, sc1 = Cmk.scatter(fig[1, 1], biomass.rainL, biomass.plantAkg,
    markersize=25, color="skyblue", strokewidth=1, strokecolor="gray",
    axis=(; title="Effect of rainfall on biomass of plant A",
        xlabel="water [L]", ylabel="biomass [kg]")
)
ax2, sc2 = Cmk.scatter(fig[1, 2], biomass.rainL, biomass.plantBkg,
    markersize=25, color="linen", strokewidth=1, strokecolor="black",
    axis=(; title="Effect of rainfall on bomass of plant B",
        xlabel="water [L]", ylabel="biomass [kg]")
)
Cmk.ablines!(fig[1, 1],
    plantAIntercept,
    plantASlope,
    linestyle=:dash, color="gray")
Cmk.ablines!(fig[1, 2],
    plantBIntercept,
    plantBSlope,
    linestyle=:dash, color="gray")
Cmk.linkxaxes!(ax1, ax2)
Cmk.linkyaxes!(ax1, ax2)
fig

function getPrecictedY(
    x::Real, intercept::Float64, slope::Float64)::Float64
    return intercept + slope * x
end

round.(
    getPrecictedY.([6, 10, 12], plantAIntercept, plantASlope),
    digits=2)

# regression with GLM package
mod1 = Glm.lm(Glm.@formula(plantAkg ~ rainL), biomass)
mod1

# prediction with GLM package
round.(
    Glm.predict(mod1, Dfs.DataFrame(Dict("rainL" => [6, 10, 12]))),
    digits=2
)

# an average estimation error in prediction
# (based on abs differences)
function getAvgEstimError(
    lm::Glm.StatsModels.TableRegressionModel)::Float64
    return abs.(Glm.residuals(lm)) |> Stats.mean
end

getAvgEstimError(mod1)

# coefficient of determination
(
    Glm.r2(mod1),
    Stats.cor(biomass.rainL, biomass.plantAkg)^2
)


###############################################################################
#                          Multiple Linear Regression                         #
###############################################################################
ice = RD.dataset("Ecdat", "Icecream")
first(ice, 5)

# full model
iceMod1 = Glm.lm(Glm.@formula(Cons ~ Income + Price + Temp), ice)
iceMod1

# smaller model
iceMod2 = Glm.lm(Glm.@formula(Cons ~ Income + Temp), ice)
iceMod2

# comparing r2 (coefficients of determination)
round.([Glm.r2(iceMod1), Glm.r2(iceMod2)],
    digits=3)

# comparing adj. r2 (adjusted coefficients of determination)
round.([Glm.adjr2(iceMod1), Glm.adjr2(iceMod2)],
    digits=3)

# comparing two models with ftest
Glm.ftest(iceMod1.model, iceMod2.model)

# examining coefficients again
iceMod2


# a genie example

# fn from ch04
# how many std. devs is a value above or below the mean
function getZScore(value::Real, mean::Real, sd::Real)::Float64
    return (value - mean) / sd
end

# adding new columns to the data frame
ice.ConsStand = getZScore.(
    ice.Cons, Stats.mean(ice.Cons), Stats.std(ice.Cons))
ice.IncomeStand = getZScore.(
    ice.Income, Stats.mean(ice.Income), Stats.std(ice.Income))
ice.TempStand = getZScore.(
    ice.Temp, Stats.mean(ice.Temp), Stats.std(ice.Temp))

iceMod2Stand = Glm.lm(
    Glm.@formula(ConsStand ~ IncomeStand + TempStand), ice)
iceMod2Stand

# categorical variables and interaction
agefat = RD.dataset("HSAUR", "agefat")

agefatM1 = Glm.lm(Glm.@formula(Fat ~ Age + Sex), agefat)
agefatM1

# or shortcut: Glm.@formula(Fat ~ Age * Sex)
agefatM2 = Glm.lm(Glm.@formula(Fat ~ Age + Sex + Age & Sex), agefat)
agefatM2

# Figure 36
fig = Cmk.Figure()
ax1 = Cmk.Axis(fig[1, 1],
    title="Body fat vs Age and Sex\n(without interaction)",
    xlabel="Age [years]",
    ylabel="Body fat [%]")
for sex in ["female", "male"]
    df = agefat[agefat.Sex.==sex, :]
    intercept = Glm.predict(agefatM1, Dfs.DataFrame("Age" => [0], "Sex" => sex))[1]
    slope = Glm.predict(agefatM1, Dfs.DataFrame("Age" => [1], "Sex" => sex))[1] -
            intercept
    Cmk.scatter!(fig[1, 1], df.Age, df.Fat,
        color=(sex == "female" ? "linen" : "skyblue2"),
        label=sex,
        marker=(sex == "female" ? :circle : :utriangle),
        markersize=20, strokewidth=1, strokecolor="gray")
    Cmk.ablines!(intercept, slope,
        linestyle=:dash,
        color=(sex == "female" ? "orange" : "blue"),
        linewidth=2)
end
ax2 = Cmk.Axis(fig[1, 2],
    title="Body fat vs Age and Sex\n(with interaction)",
    xlabel="Age [years]",
    ylabel="Body fat [%]")
for sex in ["female", "male"]
    df = agefat[agefat.Sex.==sex, :]
    intercept = Glm.predict(agefatM2, Dfs.DataFrame("Age" => [0], "Sex" => sex))[1]
    slope = Glm.predict(agefatM2, Dfs.DataFrame("Age" => [1], "Sex" => sex))[1] -
            intercept
    Cmk.scatter!(df.Age, df.Fat,
        color=(sex == "female" ? "linen" : "skyblue2"),
        label=(sex == "female" ? "female" : "male"),
        marker=(sex == "female" ? :circle : :utriangle),
        markersize=20, strokewidth=1, strokecolor="gray"
    )
    Cmk.ablines!(intercept, slope,
        linestyle=:dash,
        color=(sex == "female" ? "orange" : "blue"),
        linewidth=2)
end
fig[1, 3] = Cmk.Legend(fig, ax2, "Sex", framevisible=false)
fig

###############################################################################
#                             Exercise 1. Solution                            #
###############################################################################
animals = RD.dataset("MASS", "Animals")
animals

fig = Cmk.Figure()
Cmk.scatter(fig[1, 1], animals.Body, animals.Brain,
    axis=(;
        title="Brain weight and body weight for 28 species of animals",
        xlabel="Body weight [kg]",
        ylabel="Brain weight [kg]")
)
fig

fig = Cmk.Figure()
Cmk.scatter(fig[1, 1], log10.(animals.Body), log10.(animals.Brain),
    axis=(;
        title="Brain weight and body weight for 28 species of animals\nlog10 scale",
        xlabel="Log10 of Body weight [kg]",
        ylabel="Log10 of brain weight [kg]")
)
fig

# fn for already sorted vector without ties
# for now the function is without types
function getRanksVer1(v)
    # or: ranks = collect(1:length(v))
    ranks = collect(eachindex(v))
    return ranks
end

getRanksVer1([100, 500, 1000])

# fn for already sorted vector with ties
# for now the function is without types
function getRanksVer2(v)
    initialRanks = collect(eachindex(v))
    finalRanks = zeros(length(v))
    for i in eachindex(v)
        indicesInV = findall(x -> x == v[i], v)
        finalRanks[i] = Stats.mean(initialRanks[indicesInV])
    end
    return finalRanks
end

(
    getRanksVer2([100, 500, 500, 1000]),
    getRanksVer2([100, 500, 500, 500, 1000])
)

# fn for (un)shuffled vector with ties
# for now the function is without types
function getRanksVer3(v)
    sortedV = collect(sort(v))
    initialRanks = collect(eachindex(sortedV))
    finalRanks = zeros(length(v))
    for i in eachindex(v)
        indicesInSortedV = findall(x -> x == v[i], sortedV)
        finalRanks[i] = Stats.mean(initialRanks[indicesInSortedV])
    end
    return finalRanks
end

(
    getRanksVer3([500, 100, 1000]),
    getRanksVer3([500, 100, 500, 1000]),
    getRanksVer3([500, 100, 500, 1000, 500])
)

# fn for (un)shuffled vector with ties
# fn with types
function getRanks(v::Vector{<:Real})::Vector{<:Float64}
    sortedV::Vector{<:Real} = collect(sort(v))
    initialRanks::Vector{<:Int} = collect(eachindex(sortedV))
    finalRanks::Vector{<:Float64} = zeros(length(v))
    for i in eachindex(v)
        indicesInSortedV = findall(x -> x == v[i], sortedV)
        finalRanks[i] = Stats.mean(initialRanks[indicesInSortedV])
    end
    return finalRanks
end

(
    getRanks([100, 500, 1000]),
    getRanks([100, 500, 500, 1000]),
    getRanks([500, 100, 1000]),
    getRanks([500, 100, 500, 1000]),
    getRanks([500, 100, 500, 1000, 500])
)

# spearman correlation coefficient
function getSpearmCorAndPval(
    v1::Vector{<:Real}, v2::Vector{<:Real})::Tuple{Float64,Float64}
    return getCorAndPval(getRanks(v1), getRanks(v2))
end

getSpearmCorAndPval(animals.Body, animals.Brain)


###############################################################################
#                             Exercise 2. Solution                            #
###############################################################################
Rand.seed!(321)

letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
bogusCors = Dfs.DataFrame(
    Dict(l => Rand.rand(Dsts.Normal(100, 15), 10) for l in letters)
)
bogusCors[1:3, 1:3]

# fn from ch05
function getUniquePairs(names::Vector{T})::Vector{Tuple{T,T}} where {T}
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

# fn from ch04
function getSortedKeysVals(d::Dict{T1,T2})::Tuple{
    Vector{T1},Vector{T2}} where {T1,T2}
    sortedKeys::Vector{T1} = keys(d) |> collect |> sort
    sortedVals::Vector{T2} = [d[k] for k in sortedKeys]
    return (sortedKeys, sortedVals)
end

function getAllCorsAndPvals(
    df::Dfs.DataFrame, colsNames::Vector{String}
)::Dict{Tuple{String,String},Tuple{Float64,Float64}}

    uniquePairs::Vector{Tuple{String,String}} = getUniquePairs(colsNames)
    allCors::Dict{Tuple{String,String},Tuple{Float64,Float64}} = Dict(
        (n1, n2) => getCorAndPval(df[:, n1], df[:, n2]) for (n1, n2)
        in
        uniquePairs)

    return allCors
end

# number of false positives
allCorsPvals = getAllCorsAndPvals(bogusCors, letters)
falsePositves = (map(t -> t[2], values(allCorsPvals)) .<= 0.05) |> sum
falsePositves # 3, as expexted

function adjustPvals(
    corsAndPvals::Dict{Tuple{String,String},Tuple{Float64,Float64}},
    adjMeth::Type{M}
)::Dict{Tuple{String,String},Tuple{Float64,Float64}} where
{M<:Mt.PValueAdjustment}

    ks, vs = getSortedKeysVals(corsAndPvals)
    cors::Vector{<:Float64} = map(t -> t[1], vs)
    pvals::Vector{<:Float64} = map(t -> t[2], vs)
    adjustedPVals::Vector{<:Float64} = Mt.adjust(pvals, adjMeth())
    newVs::Vector{Tuple{Float64,Float64}} = collect(
        zip(cors, adjustedPVals))

    return Dict(ks[i] => newVs[i] for i in eachindex(ks))
end

# number of false positives
allCorsPvalsAdj = adjustPvals(allCorsPvals, Mt.BenjaminiHochberg)
falsePositves = (map(t -> t[2], values(allCorsPvalsAdj)) .<= 0.05) |> sum
falsePositves # 0, as expected


###############################################################################
#                             Exercise 3. Solution                            #
###############################################################################
function getCorsAndPvalsMatrix(
    df::Dfs.DataFrame,
    colNames::Vector{String})::Array{<:Tuple{Float64,Float64}}

    len::Int = length(colNames)
    corsPvals::Dict{Tuple{String,String},Tuple{Float64,Float64}} =
        getAllCorsAndPvals(df, colNames)
    mCorsPvals::Array{Tuple{Float64,Float64}} = fill((0.0, 0.0), len, len)

    for cn in eachindex(colNames) # cn - column number
        for rn in eachindex(colNames) # rn - row number
            corPval = (
                haskey(corsPvals, (colNames[rn], colNames[cn])) ?
                corsPvals[(colNames[rn], colNames[cn])] :
                get(corsPvals, (colNames[cn], colNames[rn]), (1, 1))
            )
            mCorsPvals[rn, cn] = corPval
        end
    end

    return mCorsPvals
end

# test
getCorsAndPvalsMatrix(bogusCors, ["a", "b", "c"])

# time for heatmap, first, helper variables
mCorsPvals = getCorsAndPvalsMatrix(bogusCors, letters)
cors = map(t -> t[1], mCorsPvals)
pvals = map(t -> t[2], mCorsPvals)
nRows, _ = size(cors) # same num of rows and cols in our matrix
xs = repeat(1:nRows, inner=nRows)
ys = repeat(1:nRows, outer=nRows)[end:-1:1]

# only heatmap, Figure 33
fig = Cmk.Figure()
ax, hm = Cmk.heatmap(fig[1, 1], xs, ys, [cors...],
    colormap=:RdBu, colorrange=(-1, 1),
    axis=(;
        xticks=(1:1:nRows, letters[1:nRows]),
        yticks=(1:1:nRows, letters[1:nRows][end:-1:1])
    ))
Cmk.hlines!(fig[1, 1], 1.5:1:nRows, color="black", linewidth=0.25)
Cmk.vlines!(fig[1, 1], 1.5:1:nRows, color="black", linewidth=0.25)
Cmk.Colorbar(fig[:, end+1], hm)
fig

# helper functions
function getColorForCor(corCoeff::Float64)::String
    @assert (0 <= abs(corCoeff) <= 1) "abc(corCoeff) must be in range [0-1]"
    return (abs(corCoeff) >= 0.65) ? "white" : "black"
end

function getMarkerForPval(pval::Float64)::String
    @assert (0 <= pval <= 1) "probability must be in range [0-1]"
    return (pval <= 0.05) ? "#" : ""
end

# heatmap, correlation coefficients, significance markers
# Figure 34
fig = Cmk.Figure()
ax, hm = Cmk.heatmap(fig[1, 1], xs, ys, [cors...],
    colormap=:RdBu, colorrange=(-1, 1),
    axis=(;
        xticks=(1:1:nRows, letters[1:nRows]),
        yticks=(1:1:nRows, letters[1:nRows][end:-1:1])
    ))
Cmk.text!(fig[1, 1], xs, ys,
    text=string.(round.([cors...], digits=2)) .*
         getMarkerForPval.([pvals...]),
    align=(:center, :center),
    color=getColorForCor.([cors...]))
Cmk.hlines!(fig[1, 1], 1.5:1:nRows, color="black", linewidth=0.25)
Cmk.vlines!(fig[1, 1], 1.5:1:nRows, color="black", linewidth=0.25)
Cmk.Colorbar(fig[:, end+1], hm)
fig


###############################################################################
#                            Exercise 4. Solution.                            #
###############################################################################
function drawDiagPlot(
    reg::Glm.StatsModels.TableRegressionModel,
    byCol::Bool = true)::Cmk.Figure
    dim::Vector{<:Int} = (byCol ? [1, 2] : [2, 1])
    res::Vector{<:Float64} = Glm.residuals(reg)
    pred::Vector{<:Float64} = Glm.predict(reg)
    form::String = string(Glm.formula(reg))
    fig = Cmk.Figure(size=(800, 800))
    Cmk.scatter(fig[1, 1], pred, res,
        axis=(;
            title="Residuals vs Fitted\n" * form,
            xlabel="Fitted values",
            ylabel="Residuals")
    )
    Cmk.hlines!(fig[1, 1], 0, linestyle=:dash, color="gray")
    Cmk.qqplot(fig[dim...],
        Dsts.Normal(0, 1),
        getZScore.(res, Stats.mean(res), Stats.std(res)),
        qqline=:identity,
        axis=(;
            title="Normal Q-Q\n" * form,
            xlabel="Theoretical Quantiles",
            ylabel="Standarized residuals")
    )
    return fig
end

# Figure 37
drawDiagPlot(agefatM1)
#drawDiagPlot(agefatM1, false)

# Figure 38
# drawDiagPlot(iceMod2)
drawDiagPlot(iceMod2, false)


###############################################################################
#                            Exercise 5. Solution.                            #
###############################################################################
Rand.seed!(321)

ice = RD.dataset("Ecdat", "Icecream") # reading fresh data frame
ice2 = ice[2:end, :] # copy of ice data frame
# an attempt to remove autocorrelation from Temp variable
ice2.TempDiff = ice.Temp[1:(end-1)] .- ice.Temp[2:end]

# dummy variables aimed to confuse our new function
ice2.a = Rand.rand(-100:1:100, 29)
ice2.b = Rand.rand(-100:1:100, 29)
ice2.c = Rand.rand(-100:1:100, 29)
ice2.d = Rand.rand(-100:1:100, 29)
ice2

# helper functions
function getLinMod(
    df::Dfs.DataFrame,
    y::String, xs::Vector{<:String}
    )::Glm.StatsModels.TableRegressionModel
    return Glm.lm(Glm.term(y) ~ sum(Glm.term.(xs)), df)
end

function getPredictorsPvals(
    m::Glm.StatsModels.TableRegressionModel)::Vector{<:Float64}
    allPvals::Vector{<:Float64} = Glm.coeftable(m).cols[4]
    # 1st pvalue is for the intercept
    return allPvals[2:end]
end

function getIndsEltsNotEqlM(v::Vector{<:Real}, m::Real)::Vector{<:Int}
    return findall(x -> !isapprox(x, m), v)
end

# the main actor
# returns minimal adequate (linear) model
function getMinAdeqMod(
    df::Dfs.DataFrame, y::String, xs::Vector{<:String}
    )::Glm.StatsModels.TableRegressionModel

    preds::Vector{<:String} = copy(xs)
    mod::Glm.StatsModels.TableRegressionModel = getLinMod(df, y, preds)
    pvals::Vector{<:Float64} = getPredictorsPvals(mod)
    maxPval::Float64 = maximum(pvals)
    inds::Vector{<:Int} = getIndsEltsNotEqlM(pvals, maxPval)

    for _ in xs
        if (maxPval <= 0.05)
            break
        end
        if (length(preds) == 1 && maxPval > 0.05)
            mod = Glm.lm(Glm.term(y) ~ Glm.term(1), df)
            break
        end
        preds = preds[inds]
        mod = getLinMod(df, y, preds)
        pvals = getPredictorsPvals(mod)
        maxPval = maximum(pvals)
        inds = getIndsEltsNotEqlM(pvals, maxPval)
    end

    return mod
end

# minimal adequate model
ice2mod = getMinAdeqMod(ice2, names(ice2)[1], names(ice2)[2:end])

# full model
ice2FullMod = getLinMod(ice2, names(ice2)[1], names(ice2)[2:end])

# comparison
Glm.ftest(ice2FullMod.model, ice2mod.model)

# Figure 39
drawDiagPlot(ice2mod, false)

# comparing adjr2 (the higher the better)
(
    Glm.adjr2(iceMod2),
    Glm.adjr2(ice2mod)
)

# comparing the average prediction error (the lower the better)
(
    getAvgEstimError(iceMod2),
    getAvgEstimError(ice2mod)
)

# the behavior of getMinAdeqMod when there are no meaningful predictors
getMinAdeqMod(ice2, "Cons", ["a", "b", "c", "d"])
