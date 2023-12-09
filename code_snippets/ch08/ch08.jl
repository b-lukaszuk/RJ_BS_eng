###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import GLM as Glm
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
    digits = 3)

# comparing adj. r2 (adjusted coefficients of determination)
round.([Glm.adjr2(iceMod1), Glm.adjr2(iceMod2)],
    digits = 3)

# comparing two models with ftest
Glm.ftest(iceMod1.model, iceMod2.model)

# examining coefficients
[(cn, round(c, digits = 4)) for (cn, c) in
     zip(Glm.coefnames(iceMod2), Glm.coef(iceMod2))]


# a genie example

# fn from ch04
# how many std. devs is value above or below the mean
function getZScore(value::Real, mean::Real, sd::Real)::Float64
	return (value - mean)/sd
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
