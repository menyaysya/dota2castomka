-- Carry Lane Academy — точка входу аддона.
-- Тут нічого не реалізуємо: уся логіка живе в модулях core/, gameplay/, ai/, online/ (ТЗ 15.3).

require( "core/bootstrap" )

-- Рушій викликає Precache перед завантаженням карти: тут оголошуємо ресурси (моделі, звуки, партикли).
function Precache( context )
	CLA.Bootstrap:Precache( context )
end

-- Рушій викликає Activate один раз, коли аддон завантажено на сервері.
function Activate()
	CLA.Bootstrap:Activate()
end
