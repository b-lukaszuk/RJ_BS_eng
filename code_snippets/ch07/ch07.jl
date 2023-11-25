###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import Distributions as Dsts
import RDatasets as RD
import Random as Rand
import Statistics as Stats


###############################################################################
#                                 association                                 #
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
#                                  covariance                                  #
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
    # assuming getCov(xs, ys)
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

# calculates the Pearson correlation coefficient and pvalue
# assumption (not tested in the function): v1 & v2 got normal distribution
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
#                                   pitfalls                                  #
###############################################################################
anscombe = RD.dataset("datasets", "anscombe")

# Figure 29
fig = Cmk.Figure()
i = 0
for r in 1:2
    for c in 1:2
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