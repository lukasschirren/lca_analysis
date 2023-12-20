import Pkg
#Pkg.add("JuMP")
#Pkg.update("JuMP")
#Pkg.add("HiGHS")

using DataFrames
using Plots
using JuMP
using Clp
using Plots, StatsPlots
using DataFrames, CSV 
using HiGHS

# VARIABLES
# From 3c --> To be calculated
E_burden_a = 16.93
E_burden_b = 13.06

e_t_m1 = 7.8 * 20 
e_t_m2 = 10.9 * 50 
e_t_h_g_a = 11.4 * 5
e_t_h_g_b = 20.3 * 3

m = Model(HiGHS.Optimizer)
@variable(m,q_a_m1 >=0)
@variable(m,q_a_m2 >=0)
@variable(m,q_b_m1 >=0)
@variable(m,q_b_m2 >=0)

E_a = 17.7 * E_burden_a 
E_b = 19.0 * E_burden_b 

production_emission = E_a * (q_a_m1 + q_a_m2) + E_b * (q_b_m1 + q_b_m2)
transportation_bio = e_t_m1 * (q_a_m1 + q_b_m1) + e_t_m2 * (q_a_m2 + q_b_m2)
transportation_h_g = e_t_h_g_a * 5/8 * (q_a_m1 + q_a_m2) + e_t_h_g_b * 5/8 * (q_b_m1 + q_b_m2)

@objective(m, Min, production_emission + transportation_bio + transportation_h_g)

@constraint(m, pc1, (q_a_m1+q_a_m2)>=200)
@constraint(m, pc2,(q_b_m1+q_b_m2)>=250)
@constraint(m, prod1a, q_a_m1 + q_b_m1 >= 800)
@constraint(m, prod1b, q_a_m1 + q_b_m1 <= 800)
@constraint(m, prod2, q_a_m2 + q_b_m2 >= 500)
@constraint(m, prod3, (q_a_m1 + q_a_m2 + q_b_m1 + q_b_m2)<= 1495)

# Execution

print(m)
optimize!(m)

objective_value(m)
value(q_a_m1)
value(q_a_m2)
value(q_b_m1)
value(q_b_m2)

latex_formulation(m)