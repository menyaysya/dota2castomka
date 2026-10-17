-- Тести scoring. Запуск у консолі Dota (Workshop Tools): cla_test

CLA = CLA or {}
CLA.Tests = CLA.Tests or {}

local function Check( results, name, cond, detail )
	table.insert( results, { name = name, ok = cond, detail = detail } )
end

function CLA.Tests.Scoring()
	local results = {}
	local weights = CLA.Config.score_weights.roles

	-- Сума ваг кожної ролі = 1.0
	for role, w in pairs( weights ) do
		local sum = 0
		for _, v in pairs( w ) do sum = sum + v end
		Check( results, "ваги " .. role .. " = 100%", math.abs( sum - 1 ) < 1e-6, string.format( "%.4f", sum ) )
	end

	local all = { farm = 1, deny = 1, wave = 1, trade = 1, xp_economy = 1, survival = 1 }
	local zero = { farm = 0, deny = 0, wave = 0, trade = 0, xp_economy = 0, survival = 0 }

	local s = CLA.Scoring.Compute( weights.safe, all )
	Check( results, "усі компоненти 1 → 1000", s == 1000, tostring( s ) )

	s = CLA.Scoring.Compute( weights.safe, zero )
	Check( results, "усі компоненти 0 → 0", s == 0, tostring( s ) )

	-- clamp: значення поза 0..1 не виходять за межі
	s = CLA.Scoring.Compute( weights.safe, { farm = 5, deny = -3, wave = 1, trade = 1, xp_economy = 1, survival = 1 } )
	Check( results, "clamp 0..1", s == 900, tostring( s ) )

	-- Перерозподіл ваги недоступного компонента
	local s2, missing = CLA.Scoring.Compute( weights.mid, { farm = 1, deny = 1, wave = 1, trade = 1, xp_economy = 1 } )
	Check( results, "без survival → 1000 і missing=survival", s2 == 1000 and missing[ 1 ] == "survival", tostring( s2 ) )

	return results
end

function CLA.Tests.RunAll()
	local results = CLA.Tests.Scoring()
	local failed = 0
	for _, r in ipairs( results ) do
		if not r.ok then failed = failed + 1 end
		CLA.Log.Info( "%s %s (%s)", r.ok and "PASS" or "FAIL", r.name, tostring( r.detail ) )
	end
	CLA.Log.Info( "Тести: %d пройдено, %d провалено", #results - failed, failed )
	return failed == 0
end
