-- Bootstrap (ТЗ 15.2): завантажує конфіги й модулі, перевіряє API рушія, налаштовує правила гри,
-- підписується на події та запускає think-цикл.
--
-- Порядок гри:
--   1. Меню (Panorama, екран налаштування) → гравець обирає сторону, лінію, складність, тривалість.
--   2. Стандартний екран вибору героя Dota (усі герої).
--   3. Прегейм: додаємо ботів на обрану лінію.
--   4. Горн → тренування йде обраний час → пауза й результати.

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
local MAP_NAME = "dota"
local ADDON_NAME = "carry_lane_academy"

function Bootstrap:Precache( context )
	-- Поки нічого: герої й предмети Dota підвантажуються рушієм самі.
end

-- Перевіряємо, що потрібні глобальні API існують у поточній збірці Dota.
function Bootstrap:CheckEngineApi()
	local required = { "GameRules", "PlayerResource", "CustomNetTables", "CustomGameEventManager",
		"ListenToGameEvent", "Convars", "Tutorial", "SendToServerConsole", "PauseGame" }
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

	local r = CLA.Config.ruleset
	CLA.Session.Init( {
		side = r.default_side,
		lane = r.default_lane,
		difficulty = r.default_difficulty,
		duration_s = r.default_duration_s,
	} )
	CLA.Session.AddFlag( "local_host" ) -- T0: результат локальний, не verified
	if not apiOk then
		CLA.Session.AddFlag( "engine_api_missing" )
	end

	-- Режим туторіалу потрібен для Tutorial:AddBot і вимкнення ліній (так роблять приклади Valve).
	Tutorial:StartTutorialMode()

	self:SetupGameRules()
	self:RegisterEvents()
	self:RegisterCommands()

	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "ClaThink", THINK_INTERVAL )

	CLA.Log.Info( "bootstrap ok (ruleset=%s, trust=%s)", r.ruleset_version, CLA.Transport.GetTrustTier() )
end

-- Мінімум втручання в правила (ТЗ 5.1): НЕ змінюємо стартове золото, XP, ціни, респаун, прегейм.
function Bootstrap:SetupGameRules()
	local mode = GameRules:GetGameModeEntity()

	-- Місця в обох командах — для людей і ботів.
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )

	-- Екран налаштування не закривається сам: чекаємо кнопку «Почати» в нашому меню.
	GameRules:SetCustomGameSetupTimeout( -1 )
	GameRules:SetShowcaseTime( 0 )

	-- Боти Dota: думають самі й залишаються в режимі лінії.
	mode:SetBotThinkingEnabled( true )
	mode:SetBotsInLateGame( false )
end

function Bootstrap:RegisterEvents()
	ListenToGameEvent( "game_rules_state_change", function() self:OnGameRulesStateChange() end, nil )

	CustomGameEventManager:RegisterListener( "cla_setup_confirm", function( _, data ) self:OnSetupConfirm( data ) end )
	CustomGameEventManager:RegisterListener( "cla_restart", function() self:OnRestart() end )

	CLA.Events.On( "session_state", function( e )
		if e.to == CLA.Session.STATES.FINISHED then
			self:OnSessionFinished()
		end
	end )
end

-- Гравець натиснув «Почати» в меню.
function Bootstrap:OnSetupConfirm( data )
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		return
	end

	local settings, err = CLA.Config.ValidateSettings( data )
	if not settings then
		CLA.Log.Error( "Некоректні налаштування з меню: %s", err )
		return
	end
	if not CLA.Session.Configure( settings ) then
		return
	end

	-- Усі люди (соло або кооп) — за обрану сторону.
	local team = ( settings.side == "radiant" ) and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID( playerID ) then
			PlayerResource:SetCustomTeamAssignment( playerID, team )
		end
	end

	CLA.Arena.FocusLane( settings.side, settings.lane )
	CLA.Session.SetState( CLA.Session.STATES.SETUP )
	GameRules:FinishCustomGameSetup()
end

function Bootstrap:OnGameRulesStateChange()
	local state = GameRules:State_Get()
	local S = CLA.Session.STATES

	if state == DOTA_GAMERULES_STATE_PRE_GAME then
		CLA.Session.SetState( S.PREPARE )
		self:SpawnBots()
	elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		CLA.Session.SetState( S.PLAYING )
	end
end

function Bootstrap:SpawnBots()
	local taken = {}
	local humans = 0
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID( playerID ) then
			humans = humans + 1
			local hero = PlayerResource:GetSelectedHeroName( playerID )
			if hero and hero ~= "" then
				taken[ hero ] = true
			end
		end
	end
	CLA.Arena.SpawnBots( CLA.Session.settings, taken, humans )
end

function Bootstrap:OnThink()
	CLA.Session.Update()
	self:PublishHud()
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return THINK_INTERVAL
end

-- Людські гравці (без ботів).
local function ForEachHuman( fn )
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID( playerID ) and not PlayerResource:IsFakeClient( playerID ) then
			fn( playerID )
		end
	end
end

-- Дані для Panorama HUD через CustomNetTables (ТЗ 14.2). Таблиця оголошена в scripts/custom_net_tables.txt.
function Bootstrap:PublishHud()
	local session = CLA.Session
	local s = session.settings
	CustomNetTables:SetTableValue( "cla_hud", "session", {
		state = session.state,
		remaining_s = math.floor( session.state == "PLAYING" and session.Remaining() or s.duration_s ),
		side = s.side,
		lane = s.lane,
		difficulty = s.difficulty,
	} )

	if session.state ~= "PLAYING" then
		return
	end
	local elapsed = session.Elapsed()
	ForEachHuman( function( playerID )
		CustomNetTables:SetTableValue( "cla_hud", "player_" .. playerID, CLA.Metrics.Snapshot( playerID, elapsed ) )
	end )
end

-- Таймер вийшов: фіксуємо результат, ставимо гру на паузу, показуємо екран результатів.
function Bootstrap:OnSessionFinished()
	local session = CLA.Session
	local elapsed = session.Elapsed()

	ForEachHuman( function( playerID )
		local result = CLA.Metrics.Snapshot( playerID, elapsed )
		result.hero = PlayerResource:GetSelectedHeroName( playerID )
		result.duration_s = session.settings.duration_s
		result.reason = session.completion_reason
		CustomNetTables:SetTableValue( "cla_hud", "result_" .. playerID, result )
		CLA.Log.Info( "Результат гравця %d: LH %d, DN %d, GPM %d, XPM %d, рівень %d, смерті %d",
			playerID, result.lh, result.dn, result.gpm, result.xpm, result.level, result.deaths )
	end )

	session.SetState( session.STATES.REPORTED, "local" )
	PauseGame( true )
end

-- «Ще раз»: перезапускаємо кастомку з нуля (знову меню → вибір героя).
function Bootstrap:OnRestart()
	CLA.Log.Info( "Перезапуск тренування" )
	SendToServerConsole( "dota_launch_custom_game " .. ADDON_NAME .. " " .. MAP_NAME )
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
