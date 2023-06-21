local Jobranks = Jobranks
local SQL = SQL
local player = player

hook.Add( "Jobranks.Player.Updated", "Jobranks.UpdateLoadout", function( ply, jobrank, newLevel, oldLevel )
    local rankData = Jobranks.Config.Jobs[jobrank].Ranks[newLevel]
    local oldRankData = Jobranks.Config.Jobs[jobrank].Ranks[oldLevel]

    if rankData.Health then
        ply:SetMaxHealth( rankData.Health )
        ply:SetHealth( math.min( rankData.Health, ply:Health() ) )
    end

    if rankData.Armor then
        ply:SetMaxArmor( rankData.Armor )
        ply:SetArmor( math.min( rankData.Armor, ply:Armor() ) )
    end

    if oldRankData and oldRankData.Weapons then
        local strip = {}

        for _, wep in ipairs( oldRankData.Weapons ) do
            if table.HasValue( rankData.Weapons or {}, wep ) then continue end
            table.insert( strip, wep )
        end

        for _, wep in ipairs( strip ) do
            ply:StripWeapon( wep )
        end
    end

    for _, wep in ipairs( rankData.Weapons or {} ) do
        ply:Give( wep )
    end
end )


hook.Add( "PlayerSpawn", "Jobranks.UpdateLoadout", function( ply )
    local jobrank = ply:GetCurrentJobRank()
    if not jobrank then return end

    local level = ply:GetJobRankLevel( jobrank )
    if level == 0 then return end

    local ranks = Jobranks.Config.Jobs[jobrank].Ranks
    if not ranks then return end

    local rankData = ranks[level]
    if not rankData then return end

    if rankData.Health then
        ply:SetMaxHealth( rankData.Health )
        ply:SetHealth( rankData.Health )
    end

    if rankData.Armor then
        ply:SetMaxArmor( rankData.Armor )
        ply:SetArmor( rankData.Armor )
    end

    for _, wep in ipairs( rankData.Weapons or {} ) do
        ply:Give( wep )
    end
end )


local function UpdateLoadout( ply, character, clamp )
    local rank = character:GetRank()
    if not rank then
        ply:SetNWInt( "JobRankLevel", 0 )
        return
    end

    local jobrank = rank:GetJobRank()
    if not jobrank then
        ply:SetNWInt( "JobRankLevel", 0 )
        return
    end

    local level = ply:GetJobRankLevel( jobrank )
    ply:SetNWInt( "JobRankLevel", level )

    if level == 0 then return end

    local rankData = Jobranks.Config.Jobs[jobrank].Ranks[level]

    if rankData.Health then
        ply:SetMaxHealth( rankData.Health )
        ply:SetHealth( clamp == true and math.min( rankData.Health, ply:Health() ) or rankData.Health )
    end

    if rankData.Armor then
        ply:SetMaxArmor( rankData.Armor )
        ply:SetArmor( clamp == true and math.min( rankData.Armor, ply:Armor() ) or rankData.Armor )
    end

    local oldRankData = Jobranks.Config.Jobs[jobrank].Ranks[level - 1]

    if oldRankData and oldRankData.Weapons then
        local strip = {}

        for _, wep in ipairs( oldRankData.Weapons ) do
            if table.HasValue( rankData.Weapons or {}, wep ) then continue end
            table.insert( strip, wep )
        end

        for _, wep in ipairs( strip ) do
            ply:StripWeapon( wep )
        end
    end

    for _, wep in ipairs( rankData.Weapons or {} ) do
        ply:Give( wep )
    end
end

hook.Add( "Player.ChangedCharacter", "Jobranks.UpdateLoadout", UpdateLoadout )
hook.Add( "Character.DataChanged", "Jobranks.UpdateLoadout", function( character, key, rankId )
    if key ~= "rankId" then return end

    local ply = character:GetOwner()
    if not ply or ply:GetCurrentCharacterId() ~= character:GetId() then return end

    UpdateLoadout( ply, character, true )
end )


hook.Add( "Rank.PropertyChanged", "Jobranks.UpdateLoadout", function( rank, key, jobrank, oldJobrank )
    if key ~= "jobrank" then return end

    local jobrankData = Jobranks.Config.Jobs[jobrank]
    local oldjobrankData = Jobranks.Config.Jobs[oldJobrank]

    if not jobrankData and not oldjobrankData then return end

    // ToDo
end )


hook.Add( "PlayerData.Created", "Jobranks.DefaultEntryOnCreation", function( playerData )
    local id = playerData:GetId()
    SQL:Query( "INSERT INTO `player_properties` (`player_id`, `key`, `value`) SELECT " .. id .. ", 'jobranks', '[]' FROM DUAL WHERE NOT EXISTS (SELECT * FROM `player_properties` WHERE `player_id`=" .. id .. " AND `key`='jobranks');" )
end )