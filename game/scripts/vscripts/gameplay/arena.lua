-- Арени: 6 ізольованих ділянок на карті (ТЗ 4.1). Активна лише одна.
--
-- Домовленість про імена сутностей у Hammer (info_target / info_player_start_*):
--   cla_<side>_<lane>_hero_spawn     — точка появи героя гравця, напр. cla_radiant_safe_hero_spawn
-- Інші точки (хвилі, вежі, межі) додамо в етапі 1 разом з картою.

CLA = CLA or {}
CLA.Arena = CLA.Arena or {}

local Arena = CLA.Arena

function Arena.EntityName( side, lane, suffix )
	return string.format( "cla_%s_%s_%s", side, lane, suffix )
end

-- Повертає позицію появи героя або nil (і пише помилку — ніяких тихих fallback, ТЗ 15.3).
function Arena.FindHeroSpawn( side, lane )
	local name = Arena.EntityName( side, lane, "hero_spawn" )
	local ent = Entities:FindByName( nil, name )
	if not ent then
		CLA.Log.Error( "На карті немає сутності '%s'. Тренування буде позначено нерейтинговим.", name )
		return nil
	end
	return ent:GetAbsOrigin()
end

function Arena.Activate( side, lane )
	Arena.side = side
	Arena.lane = lane
	Arena.hero_spawn = Arena.FindHeroSpawn( side, lane )
	if not Arena.hero_spawn then
		CLA.Session.AddFlag( "arena_missing" )
	end
	CLA.Log.Info( "Активна арена: %s/%s", side, lane )
end

-- Переносить героя на точку арени, якщо вона є на карті.
function Arena.PlaceHero( hero )
	if Arena.hero_spawn then
		FindClearSpaceForUnit( hero, Arena.hero_spawn, true )
	end
end
