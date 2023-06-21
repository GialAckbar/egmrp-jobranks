local Player = FindMetaTable( "Player" )

local Jobranks = Jobranks
local isstring = isstring
local istable = istable
local isnumber = isnumber
local math = math

Rank:AddProperty( "jobrank", "string", "", function( rank, value )
    if not isstring( value ) then
        return false, egmt( "shared.invalid_type" )
    end

    if value ~= "" and not Jobranks.Config.Jobs[value] then
        return false, "Übergebener Jobrank existiert nicht!"
    end

    return true
end,
function( rank, ply )
    return true
end )

PlayerData:AddProperty( "jobranks", "table", {}, function( playerData, value )
    if not istable( value ) then
        return false, egmt( "shared.invalid_type" )
    end

    return true
end,
function( playerData, ply )
    return playerData:BelongsTo( ply )
end )


-- Returns the config of a specific Jobrank
-- If no Jobrank is given, alle existing Jobranks will be returned
-- Returns false if a invalid Jobrank was given
function Jobranks:GetData( jobrank )
    if not jobrank then return self.Config.Jobs end

    local config = self.Config.Jobs[jobrank]
    if config then return config end

    return false
end

-- Returns the config of a specific level of a Jobrank
-- If no level is given then it returns the configs of all ranks of the Jobrank
-- Returns false when invalid parameters are given
function Jobranks:GetRankData( jobrank, level )
    if not jobrank then return false end

    local jobrankData = self.Config.Jobs[jobrank]
    if not jobrankData then return false end

    local rankData = jobrankData.Ranks
    if not rankData then return false end

    if not level then return rankData end

    local rankLevelData = rankData[level]
    if not rankLevelData then return false end

    return rankLevelData
end

-- Returns how much XP a player would get in a Jobrank at a specific level
-- Use hook "Jobranks.OverrideXPGain" to override default xp in sh_config.lua
-- Function won't return anything below 0 for safety reasons!
-- Function will return 0 if Jobrank and/or level are invalid!
function Jobranks:GetXPGain( jobrank, level )
    if not isstring( jobrank ) or not isnumber( level ) then return 0 end

    local data = Jobranks.Config.Jobs[jobrank]
    if not data or not data.Ranks[level] or #data.Ranks == level then return 0 end

    local xpGain = hook.Run( "Jobranks.OverrideXPGain", jobrank, level )
    if isnumber( xpGain ) then return math.max( 0, xpGain ) end

    return math.max( 0, Jobranks.Config.XPGainPerTick or 50 )
end

-- Returns how much XP the player would get during the XP distribution
function Player:GetXPGain()
    local jobrank = self:GetCurrentJobRank()
    local curLevel = self:GetJobRankLevel( jobrank )

    if curLevel == 0 then return 0 end

    return Jobranks:GetXPGain( jobrank, curLevel )
end

-- Returns the name of the Jobrank assigned to the rank
-- Returns false if no Jobrank is assigned or Jobrank doesn't exists anymore
function Rank.Meta:GetJobRank()
    local jobrank = self:GetProperty( "jobrank", "" )
    if Jobranks.Config.Jobs[jobrank] then return jobrank end

    return false
end

-- Returns the data of the rank's Jobrank
-- Returns false if no Jobrank is assigned or Jobrank doesn't exists anymore
function Rank.Meta:GetJobRankData()
    local jobrank = self:GetJobRank()
    if jobrank then return Jobranks.Config.Jobs[jobrank] end

    return false
end

-- Returns a table with every Jobrank saved on the player's data
-- Key = Name of Jobrank, Value = Table with "Level" and "Exp"
-- Works only on LocalPlayer() for the Client!
function PlayerData.Meta:GetJobRanks()
    return self:GetProperty( "jobranks", {} )
end

-- Alias function for the player entity
function Player:GetJobRanks()
    local playerData = self:GetData()
    if not playerData then return {} end

    return playerData:GetJobRanks()
end

-- Returns the Jobrank the player currently has
-- Returns false if the player doesn't have a Jobrank
function Player:GetCurrentJobRank()
    local char = self:GetCurrentCharacter()
    if not char then return false end

    local rank = char:GetRank()
    if not rank then return false end

    return rank:GetJobRank()
end

-- Returns the Jobrank the player currently has
-- Returns false if the player doesn't have a Jobrank
function Player:GetCurrentJobRankData()
    local char = self:GetCurrentCharacter()
    if not char then return false end

    local rank = char:GetRank()
    if not rank then return false end

    return rank:GetJobRank()
end

-- Returns the player's level of the given Jobrank name
-- Returns 0 if given Jobrank is invalid or used Clientside on other players!
function PlayerData.Meta:GetJobRankLevel( jobrank )
    if CLIENT and not self:BelongsTo( LocalPlayer() ) then return 0 end
    if not jobrank or not Jobranks.Config.Jobs[jobrank] then return 0 end

    local data = self:GetJobRanks()[jobrank]
    if not data or not data.Level then return 1 end

    return data.Level
end

-- Alias function for the player entity
-- Will take the current Jobrank if no Jobrank was given
-- Clientside this function only works on other player's if no parameter is given!
function Player:GetJobRankLevel( jobrank )
    if CLIENT and self ~= LocalPlayer() then
        return jobrank and 0 or self:GetNWInt( "JobRankLevel", 0 )
    end

    local playerData = self:GetData()
    if not playerData then return 0 end

    if not jobrank then
        jobrank = self:GetCurrentJobRank()
    end

    return playerData:GetJobRankLevel( jobrank )
end

-- Returns the player's experience of the given Jobrank name
-- Returns 0 if given Jobrank is invalid
-- Works only on LocalPlayer() for the Client!
function PlayerData.Meta:GetJobRankExperience( jobrank )
    if not jobrank or not Jobranks.Config.Jobs[jobrank] then return 0 end

    local data = self:GetJobRanks()[jobrank]
    if not data or not data.Exp then return 0 end

    return data.Exp
end

-- Alias function
function PlayerData.Meta:GetJobRankExp( jobrank )
    return self:GetJobRankExperience( jobrank )
end

-- Alias function for the player entity
-- Will take the current Jobrank if no Jobrank was given
-- Works only on LocalPlayer() for the Client!
function Player:GetJobRankExperience( jobrank )
    local playerData = self:GetData()
    if not playerData then return 0 end

    if not jobrank then
        jobrank = self:GetCurrentJobRank()
    end

    return playerData:GetJobRankExperience( jobrank )
end

-- Alias function
function Player:GetJobRankExp( jobrank )
    return self:GetJobRankExperience( jobrank )
end

-- Calculates how much XP are missing to reach the next level of the Jobrank
-- Couldn't find a better name for the function :D
-- Will return 0 if already max-level or -1 if something went wrong
-- Works only on LocalPlayer() for the Client!
function Player:GetRemainXPTillNextJobRank()
    if CLIENT and self ~= LocalPlayer() then return -1 end

    local jobrank = self:GetCurrentJobRank()
    if not jobrank then return -1 end

    local playerData = self:GetData()
    if not playerData then return -1 end

    local playerValues = playerData:GetJobRanks()[jobrank] or {}
    local curLevel = playerValues.Level or 1
    local curExp = playerValues.Exp or 0

    local jobrankData = Jobranks.Config.Jobs[jobrank].Ranks or {}

    if curLevel >= #jobrankData then return 0 end
    if not jobrankData[curLevel] then return -1 end

    local neededExp = jobrankData[curLevel].Exp
    if not neededExp then return -1 end

    return neededExp - curExp
end