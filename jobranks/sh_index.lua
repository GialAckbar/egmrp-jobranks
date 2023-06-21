Jobranks = Jobranks or {}

Jobranks.Config = {}
Jobranks.Config.Jobs = {}

if SERVER then
	AddCSLuaFile( "sh_config.lua" )
	AddCSLuaFile( "sh_errorcheck.lua" )
	AddCSLuaFile( "sh_jobranks.lua" )
	AddCSLuaFile( "cl_jobranks.lua" )

	include( "sh_config.lua" )
	include( "sh_errorcheck.lua" )
	include( "sh_jobranks.lua" )
	include( "sv_jobranks.lua" )
	include( "sv_hooks.lua" )
	include( "sv_timer.lua" )
end

if CLIENT then
	include( "sh_config.lua" )
	include( "sh_errorcheck.lua" )
	include( "sh_jobranks.lua" )
	include( "cl_jobranks.lua" )
end