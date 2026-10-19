-- «Арена» на стандартній карті Dota: обрана лінія + боти на ній.
--
-- Роль гравця → фізична лінія карти (ТЗ 1, уточнення):
--   Radiant: safe = нижня (bot), off = верхня (top);  Dire: safe = верхня (top), off = нижня (bot).
-- Інші лінії вимикаємо (крипи там не йдуть), щоб тренування було зосереджене на одній лінії.

CLA = CLA or {}
CLA.Arena = CLA.Arena or {}

local Arena = CLA.Arena

local PHYSICAL_LANE = {
	radiant = { safe = "bot", mid = "mid", off = "top" },
	dire = { safe = "top", mid = "mid", off = "bot" },
}

local ALL_LANES = { "top", "mid", "bot" }

function Arena.PhysicalLane( side, lane )
	return PHYSICAL_LANE[ side ][ lane ]
end

-- Вмикає хвилі лише на обраній лінії.
function Arena.FocusLane( side, lane )
	local active = Arena.PhysicalLane( side, lane )
	for _, l in ipairs( ALL_LANES ) do
		Tutorial:SetTutorialConvar( "dota_disable_" .. l .. "_lane", ( l == active ) and "0" or "1" )
	end
	CLA.Log.Info( "Активна лінія: %s (%s/%s)", active, side, lane )
end

-- Випадковий герой з пулу, якого ще ніхто не взяв.
local function PickHero( pool, taken )
	local free = {}
	for _, hero in ipairs( pool ) do
		if not taken[ hero ] then
			table.insert( free, hero )
		end
	end
	if #free == 0 then
		return nil
	end
	local hero = free[ RandomInt( 1, #free ) ]
	taken[ hero ] = true
	return hero
end

-- Додає ботів на лінію гравця. takenHeroes — герої, яких уже взяли люди.
-- humanCount — скільки людей у команді: у кооперативі другий гравець замінює союзного бота.
function Arena.SpawnBots( settings, takenHeroes, humanCount )
	local bots = CLA.Config.bots
	local physical = Arena.PhysicalLane( settings.side, settings.lane )
	local difficulty = bots.difficulty_names[ settings.difficulty ]
	local playerRadiant = ( settings.side == "radiant" )
	local lineup = bots.lineups[ settings.lane ]

	local function Add( role, isRadiant )
		local hero = PickHero( bots.pools[ role ], takenHeroes )
		if not hero then
			CLA.Log.Error( "Немає вільного героя для бота ролі %s", role )
			CLA.Session.AddFlag( "bot_missing" )
			return
		end
		Tutorial:AddBot( hero, physical, difficulty, isRadiant )
		CLA.Log.Info( "Бот: %s (%s, %s, %s, %s)", hero, role, physical, difficulty,
			isRadiant and "radiant" or "dire" )
	end

	if humanCount < 2 then
		for _, role in ipairs( lineup.allies ) do
			Add( role, playerRadiant )
		end
	end
	for _, role in ipairs( lineup.enemies ) do
		Add( role, not playerRadiant )
	end
end
