-- Журнал: усі повідомлення аддона мають префікс [CLA], щоб їх легко шукати в консолі (vconsole).

CLA = CLA or {}
CLA.Log = CLA.Log or {}

local Log = CLA.Log

local function Format( level, msg, ... )
	if select( "#", ... ) > 0 then
		msg = string.format( msg, ... )
	end
	return string.format( "[CLA][%s] %s", level, msg )
end

function Log.Info( msg, ... )
	print( Format( "INFO", msg, ... ) )
end

function Log.Warn( msg, ... )
	print( Format( "WARN", msg, ... ) )
end

-- Помилки не ховаємо (ТЗ 15.3 «No silent fallback»): друкуємо в консоль і віддаємо в Warning рушія.
function Log.Error( msg, ... )
	local text = Format( "ERROR", msg, ... )
	print( text )
	Warning( text .. "\n" )
end
