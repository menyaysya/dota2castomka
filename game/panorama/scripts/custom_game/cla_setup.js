"use strict";

// Меню налаштування тренування. Сервер перевіряє вибір і сам призначає команду (ТЗ 11.1, 14.2).

var ClaChoices = {
	side: ["radiant", "dire"],
	lane: ["safe", "mid", "off"],
	difficulty: [1, 2, 3, 4, 5],
	duration_s: [300, 600, 900]
};

var ClaState = {
	side: "radiant",
	lane: "safe",
	difficulty: 3,
	duration_s: 600
};

function ClaRefresh() {
	for (var group in ClaChoices) {
		var values = ClaChoices[group];
		for (var i = 0; i < values.length; i++) {
			var button = $("#" + group + "_" + values[i]);
			if (button) button.SetHasClass("Selected", ClaState[group] === values[i]);
		}
	}
}

function ClaSelect(group, value) {
	ClaState[group] = value;
	ClaRefresh();
}

function ClaStart() {
	$("#ClaStart").enabled = false;
	GameEvents.SendCustomGameEventToServer("cla_setup_confirm", ClaState);
}

(function () {
	// Не даємо екрану налаштування закритися самому, поки гравець не натисне «Почати».
	if (Game.SetAutoLaunchEnabled) Game.SetAutoLaunchEnabled(false);
	ClaRefresh();
})();
