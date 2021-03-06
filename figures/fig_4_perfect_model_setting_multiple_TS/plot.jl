#=
Plotting figure for section 2 of the perfect-model setting
(Figure 2)

* Version
- as of 25-05-2022, both forecast and parameter estimation are investigated
=#
cd(@__DIR__)
using FileIO, JLD2
using Statistics, LinearAlgebra, Distributions
using PyPlot, Printf
using MiniBatchInference
using DataFrames
using Glob
color_palette = ["tab:red", "tab:orange", "tab:blue", "tab:green",]

df_results_allsp = load("../../parameter_inference/3-species-model/inference_exploration/results/2022-04-18-bis/3-species-model_McKann_simple_minibatch_allsp.jld2", "df_results")
df_results_1sp = load("../../parameter_inference/3-species-model/inference_exploration/results/2022-04-18-bis/3-species-model_McKann_simple_minibatch_1sp.jld2", "df_results")

dfg_datasize_allsp = groupby(df_results_allsp, ["datasize"], sort=true)
dfg_datasize_1sp = groupby(df_results_1sp, ["datasize"], sort=true)

idx_datasize = [1,2,3,4] # which datasize to be considered
#############################
####### plots ###############
#############################
fig, axs = subplots(2,2, 
                    figsize=(8,8), 
                    # sharey="row",
                    )

# plotting figure A and B
labels = ["Complete obs.", "Partial obs."]

for (i,dfg) in enumerate([dfg_datasize_allsp,dfg_datasize_1sp])
    ax = axs[1,i]
    for (j,df_datasize_i) in enumerate(dfg[idx_datasize])
        dfg_noise_i = groupby(df_datasize_i,"noise", sort = true)
        noise_arr = []
        r2_arr = []
        for (i,df_results) in enumerate(dfg_noise_i)
            r2 = cor(df_results.x_p, df_results.x_p_trained)^2
            push!(r2_arr,r2); push!(noise_arr,df_results.noise[1])
        end
        ax.plot(noise_arr,r2_arr,                
                label = "$(j) time series", 
                color = color_palette[j] )
        ax.scatter(noise_arr, r2_arr, color = color_palette[j] )
    end
    ax.set_ylabel(L"R^2")
    ax.set_ylim(-0.05,1.1)
    ax.set_xlabel("Noise level, "*L"r", fontsize = 12)
end
axs[1,1].legend()
display(fig)

############
# Forecasts 
############

df_forecasting_skill_allsp = load("../../parameter_inference/3-species-model/forecast/results/df_forecasting_skill_3-species-model_McKann_simple_minibatch_allsp.jld2", "df_forecasting_skill")
df_forecasting_skill_1sp = load("../../parameter_inference/3-species-model/forecast/results/df_forecasting_skill_3-species-model_McKann_simple_minibatch_1sp.jld2", "df_forecasting_skill")

# plotting figure C (# All SPECIES) and D (1 SPECIES)
for (k,df) in enumerate([df_forecasting_skill_allsp,df_forecasting_skill_1sp])
    dfg = groupby(df, ["datasize"], sort = true)[idx_datasize]
    ax = axs[2,k]
    for (i,_dfg) in enumerate(dfg)
        dfg_noise_i = groupby(_dfg, "noise", sort = true)[1]
        dfg_th = groupby(dfg_noise_i,:timehorizon_length, sort = true)
        x = [df.timehorizon_length[1] * df.step[1] for df in dfg_th ]
        y = [mean(df.forecasting_skill) for df in dfg_th ]
        ax.plot(x, y,                
                label = "$(i) time series", 
                color = color_palette[i])
        ax.scatter(x, y, color = color_palette[i])
    end
    ax.set_xlabel("Time horizon of the forecast", fontsize = 12); 
    ax.set_ylabel("Forecast skill, "*L"\rho", fontsize = 12)
    # k == 1 ? ax.set_ylabel("Forecast skill, "*L"\rho", fontsize = 12) : nothing
    ax.set_ylim(0,1.1)
    # ax.legend()
end

# axs[2,1].set_ylabel("Forecast skill, "*L"\rho", fontsize = 12)
display(fig)

_let = ["A","C","B","D"]
for (i,ax) in enumerate(axs)
    _x = -0.1
    ax.text(_x, 1.05, _let[i],
        fontsize=16,
        fontweight="bold",
        va="bottom",
        ha="left",
        transform=ax.transAxes ,
    )
end

fig.tight_layout()
display(fig)

fig.savefig("perfect_setting_multiple_TS.png", dpi = 300)
