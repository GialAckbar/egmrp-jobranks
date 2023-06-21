-- This file is loaded directly after sh_config.lua and checks it for errors and 
-- tries to fix them so that the module can continue running without problems.

-- Checks if Jobranks.Config.TimeBetweenTick is a number and replaces it with 30 if it's not the case
if not isnumber( Jobranks.Config.TimeBetweenTick ) then
    Jobranks.Config.TimeBetweenTick = 30
    ErrorNoHaltWithStack( "Jobranks.Config.TimeBetweenTick in sh_config.lua is not a number! (Using 30 instead)\n" )
end

-- Checks if Jobranks.Config.XPGainPerTick is a number and replaces it with 50 if it's not the case
if not isnumber( Jobranks.Config.XPGainPerTick ) then
    Jobranks.Config.XPGainPerTick = 50
    ErrorNoHaltWithStack( "Jobranks.Config.XPGainPerTick in sh_config.lua is not a number! (Using 50 instead)\n" )
end

-- Searches for errors in the jobranks themselves
for jobrank, jobrankData in pairs( Jobranks.Config.Jobs ) do
    -- Checks if the Jobrank has a String as Key
    if not isstring( jobrank ) then
        Jobranks.Config.Jobs[jobrank] = nil
        ErrorNoHaltWithStack( "Jobrank \"" .. jobrank .. "\" is a " .. type( jobrank ) .. " but should be a String! (Jobrank will be disabled)\n" )
        continue
    end

    -- Checks if the Jobrank has Ranks
    if not istable( jobrankData.Ranks ) or #jobrankData.Ranks == 0 then
        Jobranks.Config.Jobs[jobrank] = nil
        ErrorNoHaltWithStack( "Jobrank \"" .. jobrank .. "\" does not have any Ranks! (Jobrank will be disabled)\n" )
        continue
    end

    -- Checks if the table with the Ranks is sequential
    if not table.IsSequential( jobrankData.Ranks ) then
        Jobranks.Config.Jobs[jobrank] = nil
        ErrorNoHaltWithStack( "Ranks of Jobrank \"" .. jobrank .. "\" are not Sequential (1, 2, 3, 4 ...)! (Jobrank will be disabled)\n" )
        continue
    end

    -- Checks every Rank of the Jobrank for necessary values
    for rank, rankData in ipairs( jobrankData.Ranks ) do
        -- Checks if every Rank (except the last) has a Exp value
        if rank < #jobrankData.Ranks and not rankData.Exp then
            Jobranks.Config.Jobs[jobrank].Ranks[rank].Exp = 100
            ErrorNoHaltWithStack( "Rank " .. rank .. " of Jobrank \"" .. jobrank .. "\" does not have a \"Exp\" value! (Using 100 instead)\n" )
        end

        -- Checks if every Rank (except the last) has a Name value
        if not rankData.Name then
            Jobranks.Config.Jobs[jobrank].Ranks[rank].Name = "*Missing Name*"
            ErrorNoHaltWithStack( "Rank " .. rank .. " of Jobrank \"" .. jobrank .. "\" does not have a \"Name\" value! (Using \"*Missing Name*\" instead)\n" )
        end
    end
end