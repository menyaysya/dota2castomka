-- Суперники й союзники — вбудовані боти Dota 2 (Tutorial:AddBot, як у прикладах Valve).
-- Боти Dota вміють грати не всіма героями, тому тут обмежений список героїв ДЛЯ БОТІВ.
-- Гравець при цьому обирає будь-якого героя (ТЗ 7.4: обмежений bot-roster без обмеження hero-roster).

return {
	-- Наш рівень 1..5 → рівень складності ботів Dota.
	difficulty_names = {
		[1] = "passive",   -- фармить, але не атакує героїв
		[2] = "easy",
		[3] = "medium",
		[4] = "hard",
		[5] = "unfair",
	},

	-- Герої, якими вміють грати стандартні боти, за ролями.
	pools = {
		carry = { "npc_dota_hero_juggernaut", "npc_dota_hero_luna", "npc_dota_hero_phantom_assassin",
			"npc_dota_hero_sven", "npc_dota_hero_drow_ranger", "npc_dota_hero_skeleton_king",
			"npc_dota_hero_chaos_knight" },
		offlane = { "npc_dota_hero_axe", "npc_dota_hero_bristleback", "npc_dota_hero_tidehunter",
			"npc_dota_hero_sand_king", "npc_dota_hero_dragon_knight" },
		mid = { "npc_dota_hero_nevermore", "npc_dota_hero_lina", "npc_dota_hero_zuus",
			"npc_dota_hero_sniper", "npc_dota_hero_viper", "npc_dota_hero_razor" },
		support = { "npc_dota_hero_crystal_maiden", "npc_dota_hero_lion", "npc_dota_hero_witch_doctor",
			"npc_dota_hero_dazzle", "npc_dota_hero_lich", "npc_dota_hero_jakiro", "npc_dota_hero_warlock",
			"npc_dota_hero_vengefulspirit" },
	},

	-- Хто стоїть на лінії разом із гравцем (allies) і проти нього (enemies), залежно від ролі гравця.
	lineups = {
		safe = { allies = { "support" }, enemies = { "offlane", "support" } },
		off  = { allies = { "support" }, enemies = { "carry", "support" } },
		mid  = { allies = {},            enemies = { "mid" } },
	},
}
