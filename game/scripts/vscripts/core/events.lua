-- Внутрішня шина подій між модулями аддона (не плутати з ігровими подіями рушія).
-- Приклад: CLA.Events.On( "session_state", function( data ) ... end )
--          CLA.Events.Emit( "session_state", { from = "PREPARE", to = "PLAYING" } )

CLA = CLA or {}
CLA.Events = CLA.Events or { listeners = {} }

local Events = CLA.Events

function Events.On( name, callback )
	Events.listeners[ name ] = Events.listeners[ name ] or {}
	table.insert( Events.listeners[ name ], callback )
end

function Events.Emit( name, data )
	local list = Events.listeners[ name ]
	if not list then
		return
	end
	for _, callback in ipairs( list ) do
		-- Помилка в одному слухачі не повинна ламати інших.
		local ok, err = pcall( callback, data )
		if not ok then
			CLA.Log.Error( "Слухач події '%s' впав: %s", name, tostring( err ) )
		end
	end
end
