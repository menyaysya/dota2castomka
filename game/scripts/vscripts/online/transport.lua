-- Мережевий транспорт до бекенду (ТЗ 11, 15.2).
--
-- Зараз завжди офлайн: зовнішні HTTP-запити з кастомок зламані (Valve #35497), а бекенду ще немає.
-- Тому trust tier = T0 (локальний результат, НЕ verified, ТЗ 11.2). Матч ніколи не чекає мережу.

CLA = CLA or {}
CLA.Transport = CLA.Transport or {}

local Transport = CLA.Transport

Transport.TRUST_TIER = "T0"

function Transport.GetTrustTier()
	return Transport.TRUST_TIER
end

function Transport.IsOnline()
	return false
end
