-- Завантаження версіонованих конфігів із папки configs/.

CLA = CLA or {}
CLA.Config = CLA.Config or {}

local Config = CLA.Config

function Config.Load()
	Config.ruleset = require( "configs/ruleset" )
	Config.ai_levels = require( "configs/ai_levels" )
	Config.score_weights = require( "configs/score_weights" )

	CLA.Log.Info( "Конфіги завантажено: ruleset=%s, score=%s",
		Config.ruleset.ruleset_version, Config.score_weights.score_version )
end
