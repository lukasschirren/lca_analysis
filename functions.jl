function process_excel_sheet(file_path::AbstractString, sheet_name::AbstractString)
    # Open the Excel file
    xlsx_file = XLSX.readxlsx(file_path)

    # Read the specified sheet into a DataFrame
    sheet_data = XLSX.getdata(xlsx_file[sheet_name])

    # Extract column names and data
    column_names = sheet_data[1, :]
    data = sheet_data[2:end, :]

    # Convert data to appropriate types
    data = Any[data[i, j] == "" ? missing : data[i, j] for i in 1:size(data, 1), j in 1:size(data, 2)]

    # Convert the read data into a DataFrame
    hydrogen_cost = DataFrame(data, Symbol.(column_names))

    # Extracting the column names (countries)
    countries = names(hydrogen_cost)[2:end]

    # Extracting the row names (hydrogen types)
    hydrogen_types = hydrogen_cost[!, 1]

    # Creating an empty DataFrame to store the combined names and values
    combined_hydrogen_cost = DataFrame(Name = String[], Value = Float64[])

    # Looping through each cell in the original table
    for i in 1:length(hydrogen_types)
        for j in 1:length(countries)
            # Generating the combined name
            name = string(countries[j], "_", hydrogen_types[i])
            # Extracting the value from the original table
            value = hydrogen_cost[i, j+1]  # Adjusting index to skip the first column
            # Adding the combined name and value to the new DataFrame
            push!(combined_hydrogen_cost, (name, value))
        end
    end

    return combined_hydrogen_cost
end

function process_excel_sheet_transport(file_path::AbstractString, sheet_name::AbstractString)
    # Open the Excel file
    xlsx_file = XLSX.readxlsx(file_path)

    # Read the specified sheet into a DataFrame
    sheet_data = XLSX.getdata(xlsx_file[sheet_name])

    # Extract column names and data
    column_names = sheet_data[1, :]
    data = sheet_data[2:end, :]

    # Convert data to appropriate types
    data = Any[data[i, j] == "" ? missing : data[i, j] for i in 1:size(data, 1), j in 1:size(data, 2)]

    # Convert the read data into a DataFrame
    hydrogen_cost = DataFrame(data, Symbol.(column_names))

    # Extracting the column names (countries)
    countries = names(hydrogen_cost)[2:end]

    # Extracting the row names (hydrogen types)
    hydrogen_types = hydrogen_cost[!, 1]

    # Creating an empty DataFrame to store the combined names and values
    combined_hydrogen_cost = DataFrame(Name = String[], Value = Float64[])

    # Looping through each cell in the original table
    for i in 1:length(hydrogen_types)
        for j in 1:length(countries)
            # Generating the combined name
            name = string(hydrogen_types[i])
            # Extracting the value from the original table
            value = hydrogen_cost[i, j+1]  # Adjusting index to skip the first column
            # Adding the combined name and value to the new DataFrame
            push!(combined_hydrogen_cost, (name, value))
        end
    end

    return combined_hydrogen_cost
end


function map_names_with_country(data::DataFrame)
    countries = Dict{String, Vector{String}}()

    for i in 1:size(data, 1)
        country, _ = split(data.Name[i], "_")
        if haskey(countries, country)
            push!(countries[country], data.Name[i])
        else
            countries[country] = [data.Name[i]]
        end
    end

    return countries
end

# function map_names_with_transportation(data::DataFrame)
#     country_methods = Dict{String, String}()

#     for i in 1:size(data, 1)
#         combined_name = data.Name[i]
#         country, method = split(combined_name, "_")
#         country_methods[combined_name] = method
#     end

#     return country_methods
# end
function map_names_with_transportation(data::DataFrame)
    method_combined_names = Dict{String, Vector{String}}()

    for i in 1:size(data, 1)
        combined_name = data.Name[i]
        country, method = split(combined_name, "_")
        if haskey(method_combined_names, method)
            push!(method_combined_names[method], combined_name)
        else
            method_combined_names[method] = [combined_name]
        end
    end

    return method_combined_names
end



function dictzip(df::DataFrame, x::Pair)
    dictkeys = zipcols(df, x[1])
    dictvalues = zipcols(df, x[2])
    return zip(dictkeys, dictvalues) |> collect |> Dict
end

function plot_filtered_data(Q, result_values, filename::String)
    name = axes(Q)[1]

    result_values_array = Float64[]

    for val in result_values
        push!(result_values_array, val)
    end

    # Initialize arrays to store filtered data
    filtered_names = String[]
    filtered_values = Float64[]

    # Iterate over the result_values_array and name arrays, and only add elements with values above 0
    for (val, n) in zip(result_values_array, name)
        if val > 0
            push!(filtered_names, n)
            push!(filtered_values, val)
        end
    end

    # Plot the filtered data
    bar(filtered_names, filtered_values, xlabel="Type", ylabel="Quantity in TWh", legend=false)
    
    savefig(filename)
end
