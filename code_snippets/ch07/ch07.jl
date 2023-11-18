###############################################################################
#                                   imports                                   #
###############################################################################
import CairoMakie as Cmk
import CSV as Csv
import DataFrames as Dfs
import Statistics as Stats


###############################################################################
#                                 association                                 #
###############################################################################
biomass = Csv.read("./biomass.csv", Dfs.DataFrame)
first(biomass, 3)

# Figure 27
fig = Cmk.Figure()
ax1, sc1 = Cmk.scatter(fig[1, 1], biomass.rainL, biomass.plantAkg,
    axis=(; title="Effect of rainfall on biomass of plant A",
        xlabel="water [L]", ylabel="biomass [kg]"),
    markersize=25, color="skyblue", strokewidth=1, strokecolor="gray")
ax2, sc2 = Cmk.scatter(fig[1, 2], biomass.rainL, biomass.plantBkg,
    axis=(; title="Effect of rainfall on bomass of plant B",
        xlabel="water [L]", ylabel="biomass [kg]"),
    markersize=25, color="linen", strokewidth=1, strokecolor="black")
Cmk.linkxaxes!(ax1, ax2)
Cmk.linkyaxes!(ax1, ax2)
fig