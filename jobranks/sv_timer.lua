local SQL = SQL
local util = util
local player = player
local table = table

function Jobranks:DistributeExperience()
    local playerIds = {}
    local sqlString = ""

    for _, ply in ipairs( player.GetHumans() ) do
        if ply.IsAfk and ply:IsAFK() then continue end

        local playerData = ply:GetData()
        if not playerData then continue end

        local jobrank = ply:GetCurrentJobRank()
        if not jobrank then continue end

        local xpGain = ply:GetXPGain()
        if xpGain == 0 then continue end

        local success, newLevel, newExp, oldLevel, oldExp = playerData:GiveJobRankExperience( xpGain, jobrank, true, true )
        if not success then continue end

        ply:SetNWInt( "JobRankLevel", newLevel )

        hook.Run( "Jobranks.Player.Updated", ply, jobrank, newLevel, oldLevel, newExp, oldExp )

        table.insert( playerIds, playerData:GetId() )
        sqlString = sqlString .. "UPDATE `player_properties` SET `value` = '" .. util.TableToJSON( playerData:GetJobRanks() ) .. "' WHERE `key` = 'jobranks' AND `player_id` = " .. playerData:GetId() .. "; "
        playerData:SetPropertyChanged( "jobranks", false )
    end

    if #playerIds == 0 then return end

    SQL:Query( sqlString, function( success )
        if success then return end
        for _, playerId in ipairs( playerIds ) do
            local playerData = PlayerData:GetCached( playerId )
            playerData:SetPropertyChanged( "jobranks", true )
            playerData:SaveProperty( "jobranks" )
        end
    end )
end

if timer.Exists( "Jobranks.DistributeEXP" ) then
    timer.Remove( "Jobranks.DistributeEXP" )
end

timer.Create( "Jobranks.DistributeEXP", Jobranks.Config.TimeBetweenTick or 30, 0, function()
    Jobranks:DistributeExperience()
end )