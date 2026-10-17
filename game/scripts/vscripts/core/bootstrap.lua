-- Bootstrap (ТЗ 15.2): завантажує конфіги й модулі, перевіряє API рушія, налаштовує правила гри,
-- підписується на події та запускає think-цикл.

CLA = CLA or {}

require( "core/log" )
require( "core/events" )
require( "core/config" )
require( "core/session" )
require( "gameplay/arena" )
require( "gameplay/metrics" )
require( "gameplay/scoring" )
require( "online/transport" )
require( "tests/scoring" )

CLA.Bootstrap = CLA.Bootstrap or {}

local Bootstrap = CLA.Bootstrap
local THINK_INTERVAL = 0.25

function Bootstrap:Precache( context )
	-- Поки нічого: герої й предмети Dota підвантажуються рушієм самі.
end

-- Перевіряємо, що потрібні глобальні API існують у поточній збірці Dota.
function Bootstrap:CheckEngineApi()
	local required = { "GameRules", "PlayerResource", "CustomNetTables", "CustomGameEventManager",
		"ListenToGameEvent", "Convars", "Entities", "FindClearSpaceForUnit" }
	local ok = true
	for _, name in ipairs( required ) do
		if _G[ name ] == nil then
			CLA.Log.Error( "Немає API рушія: %s", name )
			ok = false
		end
	end
	return ok
end

function Bootstrap:Activate()
	CLA.Log.Info( "Carry Lane Academy завантажується..." )

	CLA.Config.Load()
	local apiOk = self:CheckEngineApi()

	local proto = CLA.Config.ruleset.prototype
	CLA.Session.Init( {
		mode = "solo",
		side = proto.side,
		lane = proto.lane,
		hero = proto.hero,
		difficulty = CLA.Config.ruleset.default_difficulty,
		duration_s = CLA.Config.ruleset.default_duration_s,
	} )
	CLA.Session.AddFlag( "local_host" ) -- T0: результат локальний, не verified
	if not apiOk then
		CLA.Session.AddFlag( "engine_api_missing" )
	end

	-- Арену шукаємо одразу: сутності карти вже існують, а герой ще не з'явився.
	CLA.Arena.Activate( proto.side, proto.lane )

	self:SetupGameRules()
	self:RegisterEvents()
	self:RegisterCommands()

	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "ClaThink", THINK_INTERVAL )

	CLA.Log.Info( "bootstrap ok (ruleset=%s, trust=%s)",
		CLA.Config.ruleset.ruleset_version, CLA.Transport.GetTrustTier() )
end

-- Мінімум втручання в правила (ТЗ 5.1): НЕ змінюємо стартове золото, XP, ціни, респаун.
function Bootstrap:SetupGameRules()
	local s = CLA.Session.settings
	local mode = GameRules:GetGameModeEntity()

	-- Гравці — лише за обрану сторону; суперники будуть ботами (етап 1).
	local team = ( s.side == "radiant" ) and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS
	local other = ( team == DOTA_TEAM_GOODGUYS ) and DOTA_TEAM_BADGUYS or DOTA_TEAM_GOODGUYS
	GameRules:SetCustomGameTeamMaxPlayers( team, 2 )   -- соло або кооп (2 людини)
	GameRules:SetCustomGameTeamMaxPlayers( other, 0 )

	-- Пропускаємо екран налаштування лобі та вибір героя (поки прототип з одним героєм).
	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
	mode:SetCustomGameForceHero( s.hero )
	GameRules:SetStrategyTime( 0 )
	GameRules:SetShowcaseTime( 0 )
	GameRules:SetPreGameTime( CLA.Config.ruleset.pregame_s )
end

function Bootstrap:RegisterEvents()
	ListenToGameEvent( "game_rules_state_change", function() self:OnGameRulesStateChange() end, nil )
	ListenToGameEvent( "npc_spawned", function( e ) self:OnNPCSpawned( e ) end, nil )
end

function Bootstrap:OnGameRulesStateChange()
	local state = GameRules:State_Get()
	local S = CLA.Session.STATES

	if state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		CLA.Session.SetState( S.SETUP )
	elseif state == DOTA_GAMERULES_STATE_PRE_GAME then
		-- Якщо фазу вибору героя пропущено, проходимо SETUP автоматично.
		if CLA.Session.state == S.LOBBY then
			CLA.Session.SetState( S.SETUP )
		end
		CLA.Session.SetState( S.PREPARE )
	elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		CLA.Session.SetState( S.PLAYING )
	end
end

function Bootstrap:OnNPCSpawned( event )
	local unit = EntIndexToHScript( event.entindex )
	if unit and unit:IsRealHero() and not unit.cla_placed then
		unit.cla_placed = true
		CLA.Arena.PlaceHero( unit )
	end
end

function Bootstrap:OnThink()
	CLA.Session.Update()
	self:PublishHud()
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return THINK_INTERVAL
end

-- Дані для Panorama HUD через CustomNetTables (ТЗ 14.2). Таблиця оголошена в scripts/custom_net_tables.txt.
function Bootstrap:PublishHud()
	local session = CLA.Session
	CustomNetTables:SetTableValue( "cla_hud", "session", {
		state = session.state,
		remaining_s = math.floor( session.state == "PLAYING" and session.Remaining() or session.settings.duration_s ),
		trust = CLA.Transport.GetTrustTier(),
	} )

	local elapsed = session.Elapsed()
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID( playerID ) then
			CustomNetTables:SetTableValue( "cla_hud", "player_" .. playerID, CLA.Metrics.Snapshot( playerID, elapsed ) )
		end
	end
end

-- Консольні команди для розробки. Будь-яке використання робить сесію debug (ніколи не verified, ТЗ 15.3).
function Bootstrap:RegisterCommands()
	Convars:RegisterCommand( "cla_test", function()
		CLA.Tests.RunAll()
	end, "Carry Lane Academy: запустити тести", 0 )

	Convars:RegisterCommand( "cla_finish", function()
		CLA.Session.AddFlag( "debug" )
		CLA.Session.Finish( "debug_command" )
	end, "Carry Lane Academy: завершити тренування зараз (debug)", 0 )

	Convars:RegisterCommand( "cla_status", function()
		local s = CLA.Session
		CLA.Log.Info( "state=%s elapsed=%.1f remaining=%.1f", s.state, s.Elapsed(), s.Remaining() )
	end, "Carry Lane Academy: стан сесії", 0 )
end
