"use strict";

// HUD лише ПОКАЗУЄ дані сервера (ТЗ 11.1: Panorama ніколи не джерело істини).

function FormatTime(seconds) {
	var s = Math.max(0, Math.floor(seconds));
	var m = Math.floor(s / 60);
	var r = s % 60;
	return m + ":" + (r < 10 ? "0" : "") + r;
}

function OnSessionChanged(data) {
	if (!data) return;
	$("#ClaTimer").text = FormatTime(data.remaining_s);
	$("#ClaTrust").text = $.Localize("#cla_trust_" + data.trust);
}

function OnPlayerChanged(data) {
	if (!data) return;
	$("#ClaStats").text = "LH " + data.lh + " / DN " + data.dn + "   GPM " + data.gpm + "   XPM " + data.xpm;
}

(function () {
	var playerKey = "player_" + Players.GetLocalPlayer();

	CustomNetTables.SubscribeNetTableListener("cla_hud", function (table, key, data) {
		if (key === "session") OnSessionChanged(data);
		else if (key === playerKey) OnPlayerChanged(data);
	});

	// Початкові значення, якщо таблиця вже заповнена до завантаження HUD.
	OnSessionChanged(CustomNetTables.GetTableValue("cla_hud", "session"));
	OnPlayerChanged(CustomNetTables.GetTableValue("cla_hud", playerKey));
})();
