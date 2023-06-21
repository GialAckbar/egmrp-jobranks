local Player = FindMetaTable( "Player" )

local Jobranks = Jobranks
local isstring = isstring
local isnumber = isnumber
local hook = hook
local math = math
local table = table

-- Sets the given level to the current level of the specific Jobrank
-- Will return false if given Jobrank is invalid or new level would be invalid (except parameter clamp is true)
-- Setting parameter clamp to true will set the level always between level 1 and max level
function PlayerData.Meta:SetJobRankLevel( level, jobrank, clamp, skipNWUpdate, preventSave )
    if not level or not jobrank then return false end

    local jobrankData = Jobranks.Config.Jobs[jobrank]
    if not jobrankData or ( clamp ~= true and not jobrankData.Ranks[level] ) then return false end

    local oldLevel, oldExp = 1, 0
    local newLevel = math.Clamp( level, 1, #jobrankData.Ranks )

    local jobranks = table.Copy( self:GetJobRanks() )
    if jobranks[jobrank] then
        oldLevel = jobranks[jobrank].Level or 1
        oldExp = jobranks[jobrank].Exp or 0
    end

    jobranks[jobrank] = { Level = newLevel, Exp = 0 }
    self:SetProperty( "jobranks", jobranks )

    hook.Run( "Jobranks.PlayerData.Updated", self, jobrank, newLevel, oldLevel, 0, oldExp )

    if preventSave ~= true then
        self:SaveProperty( "jobranks" )
    end

    if skipNWUpdate ~= true then
        local ply = self:GetPlayer()
        if ply then
            ply:SetNWInt( "JobRankLevel", newLevel )
            hook.Run( "Jobranks.Player.Updated", ply, jobrank, newLevel, oldLevel, 0, oldExp )
        end
    end

    return newLevel, oldLevel, oldExp
end

-- Alias function for the player entity
-- Will take the current Jobrank if no Jobrank was given
function Player:SetJobRankLevel( level, jobrank, clamp, preventSave )
    if not jobrank then
        jobrank = self:GetCurrentJobRank()
    end

    local playerData = self:GetData()
    if not playerData then return false end

    local newLevel, oldLevel, oldExp = playerData:SetJobRankLevel( level, jobrank, clamp, true, preventSave )
    if not newLevel then return false end

    self:SetNWInt( "JobRankLevel", newLevel )

    hook.Run( "Jobranks.Player.Updated", self, jobrank, newLevel, oldLevel, 0, oldExp )

    return newLevel, oldLevel, oldExp
end

-- Adds the given level to the current level of the specific Jobrank (Works with negative numbers too)
-- Will return false if given Jobrank is invalid or new level would be invalid (except parameter clamp is true)
-- Setting parameter clamp to true will set the level always between level 1 and max level
function PlayerData.Meta:GiveJobRankLevel( jobrank, level, clamp, skipNWUpdate, preventSave )
    local curLevel = self:GetJobRankLevel( jobrank )
    if curLevel == 0 then return false end

    local jobrankData = Jobranks.Config.Jobs[jobrank]

    local newLevel, oldLevel, oldExp = curLevel + ( level or 1 ), 1, 0
    if clamp ~= true and not jobrankData.Ranks[newLevel] then return false end

    newLevel = math.Clamp( newLevel, 1, #jobrankData.Ranks )

    local jobranks = table.Copy( self:GetJobRanks() )
    if jobranks[jobrank] then
        oldLevel = jobranks[jobrank].Level or 1
        oldExp = jobranks[jobrank].Exp or 0
    end

    jobranks[jobrank] = { Level = newLevel, Exp = 0 }
    self:SetProperty( "jobranks", jobranks )

    hook.Run( "Jobranks.PlayerData.Updated", self, jobrank, newLevel, oldLevel, 0, oldExp )

    if preventSave ~= true then
        self:SaveProperty( "jobranks" )
    end

    if skipNWUpdate ~= true then
        local ply = self:GetPlayer()
        if ply then
            ply:SetNWInt( "JobRankLevel", newLevel )
            hook.Run( "Jobranks.Player.Updated", ply, jobrank, newLevel, oldLevel, 0, oldExp )
        end
    end

    return newLevel, oldLevel, oldExp
end

-- Alias function for the player entity
-- Will take the current Jobrank if no Jobrank was given
function Player:GiveJobRankLevel( jobrank, level, clamp, preventSave )
    if not jobrank then
        jobrank = self:GetCurrentJobRank()
    end

    local playerData = self:GetData()
    if not playerData then return false end

    local newLevel, oldLevel, oldExp = playerData:GiveJobRankLevel( jobrank, level, clamp, true, preventSave )
    if not newLevel then return false end

    self:SetNWInt( "JobRankLevel", newLevel )

    hook.Run( "Jobranks.Player.Updated", self, jobrank, newLevel, oldLevel, 0, oldExp )

    return newLevel, oldLevel, oldExp
end

-- Assigns a specific amount of EXP to a particular Jobrank. EXP is carried over to the next levels
-- Will return false if given Jobrank and/or EXP are invalid
function PlayerData.Meta:GiveJobRankExperience( exp, jobrank, skipNWUpdate, preventSave )
    if not isnumber( exp ) or exp < 0 or not isstring( jobrank ) then return false end

    local curLevel = self:GetJobRankLevel( jobrank )
    if curLevel == 0 then return false end

    local curExp = self:GetJobRankExperience( jobrank )
    local jobrankData = Jobranks.Config.Jobs[jobrank].Ranks or {}

    if curLevel >= #jobrankData then return 0, curLevel, curExp end
    if not jobrankData[curLevel] then return false end

    if exp == 0 then return 0, curLevel, curExp end

    local levelUps, oldLevel, oldExp = 0, 1, 0

    while exp > 0 do
        local neededExp = jobrankData[curLevel].Exp or 100

        if curExp + exp >= neededExp then
            exp = exp - ( neededExp - curExp )
            levelUps = levelUps + 1
            curLevel = curLevel + 1
            curExp = 0
            if curLevel == #jobrankData then break end
        else
            curExp = curExp + exp
            exp = 0
        end
    end

    local jobranks = table.Copy( self:GetJobRanks() )
    if jobranks[jobrank] then
        oldLevel = jobranks[jobrank].Level or 1
        oldExp = jobranks[jobrank].Exp or 0
    end

    jobranks[jobrank] = { Level = curLevel, Exp = curExp }
    self:SetProperty( "jobranks", jobranks )

    hook.Run( "Jobranks.PlayerData.Updated", self, jobrank, curLevel, oldLevel, curExp, oldExp )

    if preventSave ~= true then
        self:SaveProperty( "jobranks" )
    end

    if skipNWUpdate ~= true then
        local ply = self:GetPlayer()
        if ply then
            ply:SetNWInt( "JobRankLevel", curLevel )
            hook.Run( "Jobranks.Player.Updated", ply, jobrank, curLevel, oldLevel, curExp, oldExp )
        end
    end

    return levelUps, curLevel, curExp, oldLevel, oldExp
end

-- Alias function
function PlayerData.Meta:GiveJobRankExp( exp, jobrank, skipNWUpdate, preventSave )
    return self:GiveJobRankExperience( exp, jobrank, skipNWUpdate, preventSave )
end

-- Alias function for the player entity
-- Will take the current Jobrank if no Jobrank was given
function Player:GiveJobRankExperience( exp, jobrank, preventSave )
    if not jobrank then
        jobrank = self:GetCurrentJobRank()
    end

    local playerData = self:GetData()
    if not playerData then return false end

    local levelUps, newLevel, newExp, oldLevel, oldExp = playerData:GiveJobRankExperience( exp, jobrank, true, preventSave )
    if not levelUps then return false end

    self:SetNWInt( "JobRankLevel", newLevel )

    hook.Run( "Jobranks.Player.Updated", self, jobrank, newLevel, oldLevel, newExp, oldExp )

    return levelUps, newLevel, newExp, oldLevel, oldExp
end

-- Alias function
function Player:GiveJobRankExp( exp, jobrank, preventSave )
    return self:GiveJobRankExperience( exp, jobrank, preventSave )
end