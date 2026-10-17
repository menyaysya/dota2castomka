-- Параметри 5 рівнів складності AI (ТЗ 7.3).
-- Складність = якість рішень, а НЕ бафи: боти мають те саме золото, XP, шкоду й огляд, що й гравець.
--
-- УВАГА: значення попередні, ще не відкалібровані тестовими матчами (ТЗ 7.4).
--   reactionDelayMs        — затримка реакції на подію (мс)
--   lastHitForecastError   — похибка прогнозу HP крипа при добиванні (частка, 0.2 = ±20%)
--   decisionInterval       — як часто бот переоцінює ситуацію (с)
--   targetSelectionError   — ймовірність обрати неоптимальну ціль (0..1)
--   skillUseLikelihood     — ймовірність використати доречну здібність (0..1)
--   aggressionBudget       — схильність до харасу/тиску (0..1)
--   retreatHPThreshold     — частка HP, нижче якої бот відступає (0..1)
--   pullSkill              — якість відводів/агро (0..1)
--   itemDecisionQuality    — якість рішень про покупки (0..1)
--   coordinatedHarass      — узгодженість харасу з союзником (0..1)

return {
	[1] = { name = "beginner", reactionDelayMs = 650, lastHitForecastError = 0.30, decisionInterval = 0.60,
		targetSelectionError = 0.35, skillUseLikelihood = 0.10, aggressionBudget = 0.10, retreatHPThreshold = 0.25,
		pullSkill = 0.00, itemDecisionQuality = 0.20, coordinatedHarass = 0.00 },

	[2] = { name = "intern", reactionDelayMs = 450, lastHitForecastError = 0.20, decisionInterval = 0.45,
		targetSelectionError = 0.25, skillUseLikelihood = 0.30, aggressionBudget = 0.25, retreatHPThreshold = 0.30,
		pullSkill = 0.20, itemDecisionQuality = 0.40, coordinatedHarass = 0.10 },

	[3] = { name = "ranked", reactionDelayMs = 320, lastHitForecastError = 0.12, decisionInterval = 0.35,
		targetSelectionError = 0.15, skillUseLikelihood = 0.55, aggressionBudget = 0.45, retreatHPThreshold = 0.35,
		pullSkill = 0.50, itemDecisionQuality = 0.60, coordinatedHarass = 0.35 },

	[4] = { name = "advanced", reactionDelayMs = 230, lastHitForecastError = 0.07, decisionInterval = 0.25,
		targetSelectionError = 0.08, skillUseLikelihood = 0.75, aggressionBudget = 0.60, retreatHPThreshold = 0.35,
		pullSkill = 0.75, itemDecisionQuality = 0.80, coordinatedHarass = 0.60 },

	-- Навіть «експерт» має людську реакцію (не 0 мс), ТЗ 7.1: «складні, але людські рішення».
	[5] = { name = "expert", reactionDelayMs = 180, lastHitForecastError = 0.04, decisionInterval = 0.20,
		targetSelectionError = 0.04, skillUseLikelihood = 0.90, aggressionBudget = 0.75, retreatHPThreshold = 0.30,
		pullSkill = 0.90, itemDecisionQuality = 0.90, coordinatedHarass = 0.80 },
}
