-- Базові метрики M01–M06 (ТЗ 8.2).
-- Беремо значення напряму зі стану рушія (PlayerResource), щоб вони збігалися з авторитетним
-- engine state (ТЗ 16.3, Telemetry P0), а не рахуємо власні лічильники паралельно.

CLA = CLA or {}
CLA.Metrics = CLA.Metrics or {}

local Metrics = CLA.Metrics

-- Знімок метрик гравця. elapsed_s — скільки секунд триває тренування (для GPM/XPM).
function Metrics.Snapshot( playerID, elapsed_s )
	local minutes = math.max( elapsed_s, 1 ) / 60
	local earnedGold = PlayerResource:GetTotalEarnedGold( playerID )
	local earnedXP = PlayerResource:GetTotalEarnedXP( playerID )
	local hero = PlayerResource:GetSelectedHeroEntity( playerID )

	return {
		lh = PlayerResource:GetLastHits( playerID ),       -- M01
		dn = PlayerResource:GetDenies( playerID ),         -- M02
		gold = PlayerResource:GetGold( playerID ),
		gpm = math.floor( earnedGold / minutes ),          -- M04
		xpm = math.floor( earnedXP / minutes ),            -- M05
		level = hero and hero:GetLevel() or 0,             -- M05
		deaths = PlayerResource:GetDeaths( playerID ),     -- M06
	}
end
