local Jobranks = Jobranks
local table = table

Rank:AddPropertyToList( "jobrank", "Zugehöriger Jobrank", "Welcher Jobrank soll dem Rank zugehören?", "dropdown", function()
    local jobranks = { { text = "Kein Jobrank", data = "" } }

    for jobrank, _ in pairs( Jobranks.Config.Jobs ) do
        table.insert( jobranks, { text = jobrank, data = jobrank } )
    end

    return jobranks
end )