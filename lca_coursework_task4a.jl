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
# From 3c
E_burden_a = 16.93
E_burden_b = 13.06

e_t_m2 = 10.9 * 50 / 1000
e_t_h_g_a = 11.4 * 5 / 1000
e_t_h_g_b = 20.3 * 3 / 1000


m = Model(HiGHS.Optimizer)
@variable(m,q_a_m1 >=0)
@variable(m,q_a_m2 >=0)
@variable(m,q_b_m1 >=0)
@variable(m,q_b_m2 >=0)


# 
#q_a_m1 = 800

production_cost = 700 * (q_a_m1 + q_a_m2) + 900 * (q_b_m1 + q_b_m2)
transportation_bio = 10 * (q_a_m1 + q_b_m1) + 15 * (q_a_m2 + q_b_m2)
transportation_h_g = 10 * 5/8 * (q_a_m1 + q_a_m2) + 40 * 5/8 * (q_b_m1 + q_b_m2)

q_co2_eq_a = 17.7 * E_burden_a / 1000 
q_co2_eq_b = 19.0 * E_burden_b / 1000

q_h_g_a_m2 = 5/8 * q_a_m2
q_h_g_b_m2 = 5/8 * q_a_m2


carbon_tax_a = (q_co2_eq_a * q_a_m2 + q_a_m2 * e_t_m2 + q_h_g_a_m2 *e_t_h_g_a) * 80
carbon_tax_b = (q_co2_eq_b * q_b_m2 + q_b_m2 * e_t_m2 + q_h_g_b_m2 *e_t_h_g_b) * 40

@objective(m, Min, production_cost + transportation_bio + transportation_h_g + (carbon_tax_a+carbon_tax_b))


@constraint(m, pc1, (q_a_m1+q_a_m2)>=200)

@constraint(m, pc2,(q_b_m1+q_b_m2)>=250)

@constraint(m, prod1a, q_a_m1 + q_b_m1 >=800)
@constraint(m, prod1b, q_a_m1 + q_b_m1 <=800)
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