# Carry Lane Academy

Особистий тренажер ліній для Dota 2 на стандартній карті.
Обираєш сторону, лінію, складність ботів і тривалість, потім будь-якого героя, і тренуєшся проти ботів Dota на одній лінії. У кінці бачиш результати.

**Запуск:** двічі клацнути [start_training.bat](start_training.bat). Детальніше: [docs/run.md](docs/run.md).

ТЗ: [Carry_Lane_Academy_Technical_Spec_UA_v1.0.pdf](Carry_Lane_Academy_Technical_Spec_UA_v1.0.pdf) · План: [docs/todo.md](docs/todo.md)

## Структура

- `game/scripts/vscripts/` — логіка на Lua: `core/` (запуск, сесія, таймер), `gameplay/` (лінія, боти, метрики), `configs/` (налаштування).
- `game/panorama/` — інтерфейс: меню, HUD, результати.
- `game/resource/` — тексти українською та англійською.
  У Dota: `dota 2 beta\game\dota_addons\carry_lane_academy`
- `content/` — вихідні ресурси (зараз не використовуються).
  У Dota: `dota 2 beta\content\dota_addons\carry_lane_academy`
- `docs/` — план, інструкції.

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
