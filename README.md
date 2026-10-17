# Carry Lane Academy

Тренажер ліній для Dota 2 (кастомна гра). Аддон: `carry_lane_academy`.
ТЗ: [Carry_Lane_Academy_Technical_Spec_UA_v1.0.pdf](Carry_Lane_Academy_Technical_Spec_UA_v1.0.pdf) · План: [docs/todo.md](docs/todo.md)

## Структура

- `game/` — скрипти (Lua), KV-файли героїв/здібностей/предметів, локалізація, UI (Panorama).
  У Dota: `dota 2 beta\game\dota_addons\carry_lane_academy`
- `content/` — вихідні ресурси: карти (Hammer), матеріали, партикли.
  У Dota: `dota 2 beta\content\dota_addons\carry_lane_academy`
- `docs/` — план, документація.

## Підключення репозиторію до Dota (один раз)

Закрийте Dota 2 і Workshop Tools, відкрийте **PowerShell від імені адміністратора** і виконайте:

```powershell
$dota = "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta"
$repo = "C:\Users\Den\Desktop\dota2castomka"
foreach ($s in @("game","content")) {
  $old = "$dota\$s\dota_addons\dota2castomka"
  if ((Get-Item $old -ErrorAction SilentlyContinue).LinkType -eq "Junction") { cmd /c rmdir "$old" }
  Rename-Item "$dota\$s\dota_addons\carry_lane_academy" "carry_lane_academy_backup"
  cmd /c mklink /J "$dota\$s\dota_addons\carry_lane_academy" "$repo\$s"
}
```

Що робить команда:
1. Прибирає старі посилання `dota2castomka`. Видаляється тільки посилання, файли в репозиторії залишаються.
2. Перейменовує щойно створені папки `carry_lane_academy` на `carry_lane_academy_backup`.
3. Створює нові посилання `carry_lane_academy` → репозиторій.

Після цього Dota працює напряму з файлами репозиторію. Папки `*_backup` можна видалити, коли все запрацює.
