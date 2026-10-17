-- Training Score 0–1000 (ТЗ 9.2):
--   Score = round( 1000 × Σ( weight_i × clamp( metric_i_normalized, 0, 1 ) ) )
--
-- Модуль «чистий»: не звертається до рушія, тому його можна тестувати (tests/scoring.lua).
-- Нормалізацію метрик (сирі LH → 0..1) додамо в етапі 2, коли будуть калібрувальні дані.

CLA = CLA or {}
CLA.Scoring = CLA.Scoring or {}

local Scoring = CLA.Scoring

local function Clamp01( x )
	if x < 0 then return 0 end
	if x > 1 then return 1 end
	return x
end

-- weights    — таблиця ваг ролі з configs/score_weights.lua
-- components — нормалізовані компоненти { farm = 0.83, deny = 0.64, ... }
--
-- Якщо компонент недоступний (немає в components), його вага перерозподіляється
-- пропорційно між доступними (ТЗ 9.2). Повертає score і список пропущених компонентів.
function Scoring.Compute( weights, components )
	local availableWeight = 0
	local missing = {}
	for name, w in pairs( weights ) do
		if components[ name ] ~= nil then
			availableWeight = availableWeight + w
		else
			table.insert( missing, name )
		end
	end

	if availableWeight <= 0 then
		return 0, missing
	end

	local sum = 0
	for name, w in pairs( weights ) do
		local value = components[ name ]
		if value ~= nil then
			sum = sum + ( w / availableWeight ) * Clamp01( value )
		end
	end

	table.sort( missing )
	return math.floor( 1000 * sum + 0.5 ), missing
end
