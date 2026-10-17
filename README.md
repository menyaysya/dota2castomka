# dota2castomka

Кастомна гра для Dota 2.

## Структура

- `game/` — скрипти (Lua), KV-файли героїв/здібностей/предметів, локалізація, UI (Panorama).
  У Dota: `dota 2 beta\game\dota_addons\dota2castomka`
- `content/` — вихідні ресурси: карти (Hammer), матеріали, партикли.
  У Dota: `dota 2 beta\content\dota_addons\dota2castomka`

## Підключення репозиторію до Dota (один раз)

Закрийте Dota 2 і Workshop Tools, відкрийте **PowerShell від імені адміністратора** і виконайте:

```powershell
$dota = "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta"
$repo = "C:\Users\Den\Desktop\dota2castomka"
foreach ($s in @("game","content")) {
  Rename-Item "$dota\$s\dota_addons\dota2castomka" "dota2castomka_backup"
  cmd /c mklink /J "$dota\$s\dota_addons\dota2castomka" "$repo\$s"
}
```

Після цього Dota працює напряму з файлами репозиторію. Старі папки лишаються як `dota2castomka_backup`, їх можна видалити, коли все запрацює.
