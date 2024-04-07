import Pkg
#Pkg.add("JuMP")
#Pkg.update("JuMP")
#Pkg.add("HiGHS")

using DataFrames
using Plots
using JuMP
using Clp
using Plots, StatsPlots
using DataFrames, CSV, XLSX
using HiGHS

include("functions.jl")

file_path = joinpath(dirname(Base.source_path()), "data.xlsx")

################################
# Hydrogen Cost for each country
sheet_name = "cost_h2"
cost_h2 = process_excel_sheet(file_path, sheet_name)
println(cost_h2)

################################
# Distance from each country
sheet_name = "distance_to_de"
distance_to_de = process_excel_sheet(file_path, sheet_name)
println(distance_to_de)

################################
# Maximum capacity for each country
sheet_name = "max_capacity_h2"
max_capacity_h2 = process_excel_sheet(file_path, sheet_name)
println(max_capacity_h2)

################################
# UNFINISHED
# Maximum transport from each country
sheet_name = "max_transport_to_de"
max_transport_to_de = process_excel_sheet(file_path, sheet_name)
println(max_transport_to_de)


################################
# Preparation of sets 
production_types = unique(cost_h2[:,:Name])
countries = map_names_with_country(max_capacity_h2)

transport = map_names_with_country(distance_to_de)

################################
# Maximum transport to DE per transportation option


################################
# Preparing input for Optimisation




# Optimisation
m = Model(HiGHS.Optimizer)

@variables m begin
    cost_max[types] >= G[disp=P_DISP, T] >= 0
    CU[Z,T] >= 0
    g_max[s] >= D_stor[s=P_S,T] >= 0
    stor_max[s] >= L_stor[s=P_S,T] >= 0
    H[P_CHP, T] >= 0
    EX[z=Z,zz=Z,T] >= 0
end