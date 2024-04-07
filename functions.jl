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