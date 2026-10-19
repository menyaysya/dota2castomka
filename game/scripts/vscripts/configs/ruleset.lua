-- Версіонований регламент тренування (ТЗ 9.4).
-- Будь-яка зміна правил, ботів чи ваг => нова ruleset_version.
--
-- Карта — стандартна карта Dota 2 (`dota`). Стартове золото, ціни, XP, хвилі, вежі й респаун
-- бере рушій поточного патча, ми їх не перевизначаємо (ТЗ 5.1, 5.3).

return {
	ruleset_version = "2026-10-std-1",

	-- Тривалості тренування в секундах ігрового часу (ТЗ 1, п. 06).
	durations_s = { 300, 600, 900 },
	default_duration_s = 600,

	-- Рівні складності 1..5 (боти Dota, див. configs/bots.lua).
	difficulties = { 1, 2, 3, 4, 5 },
	default_difficulty = 3,

	-- 3 ролі × 2 сторони = 6 конфігурацій (ТЗ 1, п. 02).
	lanes = { "safe", "mid", "off" },
	sides = { "radiant", "dire" },
	default_side = "radiant",
	default_lane = "safe",
}
