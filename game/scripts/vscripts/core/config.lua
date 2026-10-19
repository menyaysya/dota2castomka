-- Завантаження версіонованих конфігів із папки configs/.

CLA = CLA or {}
CLA.Config = CLA.Config or {}

local Config = CLA.Config

function Config.Load()
	Config.ruleset = require( "configs/ruleset" )
	Config.bots = require( "configs/bots" )
	Config.ai_levels = require( "configs/ai_levels" )
	Config.score_weights = require( "configs/score_weights" )

	CLA.Log.Info( "Конфіги завантажено: ruleset=%s, score=%s",
		Config.ruleset.ruleset_version, Config.score_weights.score_version )
end

local function Contains( list, value )
	for _, v in ipairs( list ) do
		if v == value then
			return true
		end
	end
	return false
end

-- Перевіряє налаштування, що прийшли з меню (клієнту не довіряємо, ТЗ 14.2).
-- Повертає чисту таблицю налаштувань або nil і причину.
function Config.ValidateSettings( data )
	local r = Config.ruleset
	local side = tostring( data.side )
	local lane = tostring( data.lane )
	local difficulty = tonumber( data.difficulty )
	local duration_s = tonumber( data.duration_s )

	if not Contains( r.sides, side ) then return nil, "side=" .. side end
	if not Contains( r.lanes, lane ) then return nil, "lane=" .. lane end
	if not Contains( r.difficulties, difficulty ) then return nil, "difficulty=" .. tostring( difficulty ) end
	if not Contains( r.durations_s, duration_s ) then return nil, "duration_s=" .. tostring( duration_s ) end

	return { side = side, lane = lane, difficulty = difficulty, duration_s = duration_s }
end
