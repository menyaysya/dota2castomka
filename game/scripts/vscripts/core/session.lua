-- Сесія тренування: єдина машина станів (ТЗ 15.2).
--
--   LOBBY → SETUP → PREPARE → PLAYING → FINISHED → REPORTED
--                                  ↘ INVALID (з будь-якого стану до REPORTED)
--
-- Таймер рахує ІГРОВИЙ час (GameRules:GetDOTATime), тому пауза не витрачає час тренування (ТЗ 3.3).

CLA = CLA or {}
CLA.Session = CLA.Session or {}

local Session = CLA.Session

Session.STATES = {
	LOBBY = "LOBBY",
	SETUP = "SETUP",
	PREPARE = "PREPARE",
	PLAYING = "PLAYING",
	FINISHED = "FINISHED",
	REPORTED = "REPORTED",
	INVALID = "INVALID",
}

local S = Session.STATES

-- Дозволені переходи. Усе інше — помилка в коді, яку ми логуємо, а не ковтаємо.
local TRANSITIONS = {
	[ S.LOBBY ] = { [ S.SETUP ] = true, [ S.INVALID ] = true },
	[ S.SETUP ] = { [ S.PREPARE ] = true, [ S.INVALID ] = true },
	[ S.PREPARE ] = { [ S.PLAYING ] = true, [ S.INVALID ] = true },
	[ S.PLAYING ] = { [ S.FINISHED ] = true, [ S.INVALID ] = true },
	[ S.FINISHED ] = { [ S.REPORTED ] = true, [ S.INVALID ] = true },
	[ S.REPORTED ] = {},
	[ S.INVALID ] = {},
}

function Session.Init( settings )
	Session.state = S.LOBBY
	Session.settings = settings          -- { side, lane, difficulty, duration_s }
	Session.started_at = nil             -- ігровий час старту PLAYING
	Session.invalid_reason = nil
	Session.flags = {}                   -- M12 Scenario flags: debug, local_host, ...
end

-- Налаштування, обрані гравцем у меню. Змінювати можна лише до старту (LOBBY).
function Session.Configure( settings )
	if Session.state ~= S.LOBBY then
		CLA.Log.Error( "Налаштування сесії не можна змінити у стані %s", Session.state )
		return false
	end
	Session.settings = settings
	CLA.Log.Info( "Сесія: %s/%s, складність %d, %d с",
		settings.side, settings.lane, settings.difficulty, settings.duration_s )
	return true
end

function Session.SetState( newState, reason )
	local from = Session.state
	if from == newState then
		return true
	end
	if not TRANSITIONS[ from ][ newState ] then
		CLA.Log.Error( "Недозволений перехід сесії %s → %s", tostring( from ), tostring( newState ) )
		return false
	end

	Session.state = newState
	if newState == S.PLAYING then
		Session.started_at = Session.Now()
	elseif newState == S.INVALID then
		Session.invalid_reason = reason or "unknown"
	end

	CLA.Log.Info( "Сесія: %s → %s%s", from, newState, reason and ( " (" .. reason .. ")" ) or "" )
	CLA.Events.Emit( "session_state", { from = from, to = newState, reason = reason } )
	return true
end

-- Ігровий час без прегейму. Під час паузи не росте.
function Session.Now()
	return GameRules:GetDOTATime( false, false )
end

function Session.Elapsed()
	if not Session.started_at then
		return 0
	end
	return math.max( 0, Session.Now() - Session.started_at )
end

function Session.Remaining()
	return math.max( 0, Session.settings.duration_s - Session.Elapsed() )
end

-- Викликається з think-циклу bootstrap.
function Session.Update()
	if Session.state == S.PLAYING and Session.Remaining() <= 0 then
		Session.Finish( "timer" )
	end
end

-- Захист від повторного завершення (ТЗ 15.2): другий виклик нічого не робить.
function Session.Finish( reason )
	if Session.state ~= S.PLAYING then
		return false
	end
	Session.completion_reason = reason
	return Session.SetState( S.FINISHED, reason )
end

function Session.Invalidate( reason )
	if Session.state == S.REPORTED or Session.state == S.INVALID then
		return false
	end
	return Session.SetState( S.INVALID, reason )
end

function Session.AddFlag( flag )
	Session.flags[ flag ] = true
end
