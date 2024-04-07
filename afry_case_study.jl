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
# Hydrogen Production Cost for each country
sheet_name = "cost_h2"
cost_h2 = process_excel_sheet(file_path, sheet_name)
# Changing from MWh to TWh
cost_h2.Value .= cost_h2.Value .* 1000000

# Maximum capacity for each country
sheet_name = "max_capacity_h2"
max_production_h2 = process_excel_sheet(file_path, sheet_name)

################################
# Transportation Cost 
sheet_name = "transport_cost"
transport_cost = process_excel_sheet_transport(file_path, sheet_name)

# Conversion Cost
sheet_name = "transport_conversion"
transport_conversion = process_excel_sheet_transport(file_path,sheet_name) 

# Distance from each country
sheet_name = "distance_to_de"
distance_to_de = process_excel_sheet(file_path, sheet_name)

# Chaning per 1,000 km
distance_to_de.Value .= distance_to_de.Value ./ 1000


# Maximum transport per pipeline from each country
sheet_name = "max_transport_to_de"
max_transport_to_de = process_excel_sheet(file_path, sheet_name)




################################
## Preparation of Sets
country_names = [split(row.Name, "_")[1] for row in eachrow(cost_h2)]

COUNTRY = sort!(unique(country_names))
TRANSPORT = unique(transport_cost[:,:Name])
TYPES = unique(cost_h2[:,:Name])

TYPES_T = unique(distance_to_de[:,:Name])

# PRODUCTION
# Sum of production from each country 
map_countries_h2 = map_names_with_country(max_capacity_h2)


# TRANSPORT
map_countries_transport = map_names_with_country(distance_to_de)
map_transportation = map_names_with_transportation(distance_to_de)

################################
# Core parameters
q_cost = dictzip(cost_h2, :Name => :Value)
q_max = dictzip(max_production_h2, :Name => :Value)

transportation_cost = dictzip(transport_cost, :Name => :Value)
t_cost = Dict{String, Float64}()

# Iterate over the keys and values in t_cost
for (mode, cost) in transportation_cost
    # Split the mode string by "_" to get the prefix
    prefix = split(mode, "_")[end]
    # Iterate over the strings in TYPES_T
    for t in TYPES_T
        # Check if the prefix matches the string in TYPES_T
        if endswith(t, "_$prefix")
            # If there is a match, add the association to the new dictionary
            t_cost[t] = cost
        end
    end
end
t_cost

t_max = dictzip(max_transport_to_de, :Name => :Value)




conversion = dictzip(transport_conversion, :Name => :Value)
distance = dictzip(distance_to_de, :Name => :Value)




# Optimisation
m = Model(Clp.Optimizer)

@variables m begin
    q_max[types] >= Q[types=TYPES] >= 0
    t_max[types_t] >= T[types_t=TYPES_T] >= 0
end

@objective(m, Min,
    sum(q_cost[types] * Q[types] for types in TYPES)
    + sum(t_cost[types_t] * distance[types_t] * T[types_t] for types_t in TYPES_T)
    
)

# Demand of 100 TWh in Germany
@constraint(m, Demand,
    sum(Q[types] for types in TYPES) 
    >=
    100.1
)



# Set sum of production of each country equal to sum of transport
@constraint(m, Transport[country=COUNTRY],
    sum(Q[prod] for prod in map_countries_h2[country]) == sum(T[tran] for tran in map_countries_transport[country])
) 

# Transport constraint 


optimize!(m)
objective_value(m)
print(JuMP.value.(Q))
print(JuMP.value.(T))




plot_filtered_data(Q, JuMP.value.(Q), "non_transport.png")

plot_filtered_data(T, JuMP.value.(T), "transport_dist.png")
