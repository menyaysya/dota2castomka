-- Ваги Training Score за роллю (ТЗ 9.2). Це конфігурація, а не закон природи:
-- зміна ваг => нова score_version. Сума ваг кожної ролі = 1.0 (перевіряє tests/scoring.lua).

return {
	score_version = "score-0",

	roles = {
		safe = { farm = 0.35, deny = 0.10, wave = 0.20, trade = 0.15, xp_economy = 0.10, survival = 0.10 },
		mid  = { farm = 0.25, deny = 0.15, wave = 0.20, trade = 0.20, xp_economy = 0.10, survival = 0.10 },
		off  = { farm = 0.10, deny = 0.25, wave = 0.20, trade = 0.25, xp_economy = 0.10, survival = 0.10 },
	},
}
