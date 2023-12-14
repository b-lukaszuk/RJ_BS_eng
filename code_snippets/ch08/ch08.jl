###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import Distributions as Dsts
import GLM as Glm
import Random as Rand
import RDatasets as RD
import Statistics as Stats


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

# an average error in prediction
abs.(Glm.residuals(mod1)) |> Stats.mean

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

# examining coefficients
[(cn, round(c, digits=4)) for (cn, c) in
 zip(Glm.coefnames(iceMod2), Glm.coef(iceMod2))]


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
#                            Exercise 1. Solution.                            #
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
#                            Exercise 2. Solution.                            #
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
function getLmMod(
    df::Dfs.DataFrame,
    y::String, xs::Vector{<:String}
    )::Glm.StatsModels.TableRegressionModel
    return Glm.lm(Glm.term(y) ~ sum(Glm.term.(xs)), df)
end

function getPredictorsPvals(
    m::Glm.StatsModels.TableRegressionModel)::Vector{<:Float64}
    allPvals::Vector{<:Float64} = Glm.coeftable(m).cols[4]
    # 1st pvalue is for intercept
    return allPvals[2:end]
end

function getIndsEltsNotEqlM(v::Vector{<:Real}, m::Real)::Vector{<:Int}
    return findall(x -> !isapprox(x, m), v)
end

# the main actor
# returns minimal adequate model
function getMinAdeqMod(
    df::Dfs.DataFrame, y::String, xs::Vector{<:String}
    )::Glm.StatsModels.TableRegressionModel

    preds::Vector{<:String} = copy(xs)
    mod::Glm.StatsModels.TableRegressionModel = getLmMod(df, y, preds)
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
        mod = getLmMod(df, y, preds)
        pvals = getPredictorsPvals(mod)
        maxPval = maximum(pvals)
        inds = getIndsEltsNotEqlM(pvals, maxPval)
    end

    return mod
end

# minimal adequate model
ice2mod = getMinAdeqMod(ice2, names(ice2)[1], names(ice2)[2:end])

# full model
ice2FullMod = getLmMod(ice2, names(ice2)[1], names(ice2)[2:end])

# comparison
Glm.ftest(ice2FullMod.model, ice2mod.model)

# Figure 39
drawDiagPlot(ice2mod)

# comparing adjr2 (the higher the better)
(
    Glm.adjr2(iceMod2),
    Glm.adjr2(ice2mod)
)

# comparing the average prediction error (the lower the better)
(
    abs.(Glm.residuals(iceMod2)) |> Stats.mean,
    abs.(Glm.residuals(ice2mod)) |> Stats.mean
)

# the behavior of getMinAdeqMod when there are no meaningful predictors
getMinAdeqMod(ice2, "Cons", ["a", "b", "c", "d"])
