"use strict";

// HUD лише ПОКАЗУЄ дані сервера (ТЗ 11.1: Panorama ніколи не джерело істини).

function FormatTime(seconds) {
	var s = Math.max(0, Math.floor(seconds));
	var m = Math.floor(s / 60);
	var r = s % 60;
	return m + ":" + (r < 10 ? "0" : "") + r;
}

function DescribeSettings(data) {
	return $.Localize("#cla_side_" + data.side) + " · " +
		$.Localize("#cla_lane_" + data.lane) + " · " +
		$.Localize("#cla_difficulty_" + data.difficulty);
}

function OnSessionChanged(data) {
	if (!data) return;
	$("#ClaTimer").text = FormatTime(data.remaining_s);
	$("#ClaInfo").text = DescribeSettings(data);
}

function OnPlayerChanged(data) {
	if (!data) return;
	$("#ClaStats").text = "LH " + data.lh + " / DN " + data.dn + "   GPM " + data.gpm + "   XPM " + data.xpm;
}

function OnResult(data) {
	if (!data) return;
	var session = CustomNetTables.GetTableValue("cla_hud", "session");
	$("#ClaResultInfo").text = $.Localize("#" + data.hero) + " · " +
		(session ? DescribeSettings(session) + " · " : "") + Math.round(data.duration_s / 60) + " " + $.Localize("#cla_minutes_short");
	$("#ResLH").text = String(data.lh);
	$("#ResDN").text = String(data.dn);
	$("#ResGPM").text = String(data.gpm);
	$("#ResXPM").text = String(data.xpm);
	$("#ResLevel").text = String(data.level);
	$("#ResDeaths").text = String(data.deaths);
	$("#ClaResult").SetHasClass("Hidden", false);
}

function ClaRestart() {
	GameEvents.SendCustomGameEventToServer("cla_restart", {});
}

(function () {
	var playerID = Players.GetLocalPlayer();
	var playerKey = "player_" + playerID;
	var resultKey = "result_" + playerID;

	CustomNetTables.SubscribeNetTableListener("cla_hud", function (table, key, data) {
		if (key === "session") OnSessionChanged(data);
		else if (key === playerKey) OnPlayerChanged(data);
		else if (key === resultKey) OnResult(data);
	});

	// Початкові значення, якщо таблиця вже заповнена до завантаження HUD.
	OnSessionChanged(CustomNetTables.GetTableValue("cla_hud", "session"));
	OnPlayerChanged(CustomNetTables.GetTableValue("cla_hud", playerKey));
	OnResult(CustomNetTables.GetTableValue("cla_hud", resultKey));
})();
