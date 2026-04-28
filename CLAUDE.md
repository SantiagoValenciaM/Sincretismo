# CLAUDE.md — Plan de Ejecución: Sincretismo

## CONTEXTO (leer una vez, no repetir)

Sincretismo = videojuego 2D souls-like en Godot 4.6.1 / GDScript.
Temática: sincretismo religioso mexicano. Personaje: El Promesero.
Assets: Kenney.nl (graybox). Entrega: 20 abril 2026.

## RUTAS DEL PROYECTO

```
REPO (raíz Git):
C:\Users\eduar\OneDrive\Escritorio\Carrera_Ing_Software\6to_semestre\Opt IV_Videojuegos\Bullyies\Sincretismo

GODOT (proyecto Godot 4.6.1 — aquí vive project.godot):
C:\Users\eduar\OneDrive\Escritorio\Carrera_Ing_Software\6to_semestre\Opt IV_Videojuegos\Bullyies\Sincretismo\sincretismo-game_beta\sincretismo(beta)
```

**Regla crítica:** Todos los archivos de Godot (.tscn, .gd, .tres, assets) van DENTRO de la carpeta del proyecto Godot. Las rutas `res://` de Godot apuntan a esa carpeta.

```
Ruta en este documento          →  Ruta real en disco
res://scenes/player/Player.tscn →  ...\sincretismo(beta)\scenes\player\Player.tscn
res://scripts/player/promesero.gd → ...\sincretismo(beta)\scripts\player\promesero.gd
```

Los archivos de documentación (GDD, Estado del Arte, etc.) van en la raíz del repo, NO dentro de la carpeta de Godot.

---

## ESTRUCTURA DEL PROYECTO

```
Sincretismo/                          ← REPO (raíz Git)
├── CLAUDE.md                         ← Este archivo
├── README.md
├── docs/
│   ├── GDD_TenPager.pdf
│   ├── EstadoDelArte.docx
│   └── sprint_planning.xlsx
│
└── sincretismo-game_beta/
    └── sincretismo(beta)/            ← GODOT (project.godot aquí)
        ├── project.godot
        ├── scenes/
        │   ├── Main.tscn
        │   ├── Game.tscn
        │   ├── player/Player.tscn
        │   ├── enemies/
        │   │   ├── EnemyBase.tscn
        │   │   ├── Procesional.tscn
        │   │   └── Veladora.tscn
        │   ├── zones/Zone1.tscn
        │   ├── altars/
        │   │   ├── AltarMenor.tscn
        │   │   └── AltarMayor.tscn
        │   ├── bosses/Mayordomo.tscn
        │   └── ui/
        │       ├── HUD.tscn
        │       ├── MandaUI.tscn
        │       ├── TitleScreen.tscn
        │       ├── GameOver.tscn
        │       └── Victory.tscn
        ├── scripts/
        │   ├── player/
        │   │   └── promesero.gd
        │   ├── enemies/
        │   │   ├── enemy_base.gd
        │   │   ├── procesional.gd
        │   │   └── veladora.gd
        │   ├── bosses/
        │   │   └── mayordomo.gd
        │   ├── systems/
        │   │   ├── game_manager.gd       # Autoload
        │   │   ├── gracia_system.gd      # Autoload
        │   │   ├── manda_system.gd       # Autoload
        │   │   └── checkpoint_system.gd  # Autoload
        │   ├── altars/
        │   │   ├── altar_menor.gd
        │   │   └── altar_mayor.gd
        │   └── ui/
        │       ├── hud.gd
        │       ├── manda_ui.gd
        │       └── title_screen.gd
        └── assets/
            ├── kenney/
            ├── audio/
            └── tilesets/
```

---

## COMANDOS DE TERMINAL — RUTAS CORRECTAS

Navegar al proyecto Godot:
```powershell
cd "C:\Users\eduar\OneDrive\Escritorio\Carrera_Ing_Software\6to_semestre\Opt IV_Videojuegos\Bullyies\Sincretismo\sincretismo-game_beta\sincretismo(beta)"
```

Navegar a la raíz del repo Git:
```powershell
cd "C:\Users\eduar\OneDrive\Escritorio\Carrera_Ing_Software\6to_semestre\Opt IV_Videojuegos\Bullyies\Sincretismo"
```

Crear estructura de carpetas (una sola vez desde carpeta Godot):
```powershell
mkdir scenes\player, scenes\enemies, scenes\zones, scenes\altars, scenes\bosses, scenes\ui
mkdir scripts\player, scripts\enemies, scripts\bosses, scripts\systems, scripts\altars, scripts\ui
mkdir assets\kenney, assets\audio, assets\tilesets
```

**Nota:** La carpeta `sincretismo(beta)` tiene paréntesis. En PowerShell/cmd usar comillas. En Git Bash escapar: `sincretismo\(beta\)`.

---

## FASES DE EJECUCIÓN

Ejecutar en orden. Cada fase depende de la anterior.
Todos los archivos .gd y .tscn se crean DENTRO de la carpeta Godot.

---

### FASE 0 — SETUP

**Objetivo:** Proyecto Godot funcional que corre vacío.
**Directorio:** `sincretismo(beta)\`

1. Verificar/crear `project.godot`: resolución 1280×720, stretch canvas_items, keep aspect, gravedad 980, texture filter Nearest
2. Input Map: move_left(A), move_right(D), jump(Space), attack_light(J), attack_heavy(K), dodge(Shift), interact(E), pause(Esc) — todos con gamepad
3. Crear `scenes\Main.tscn` (Node2D) y `scenes\Game.tscn` (Node2D + Camera2D)
4. Crear `scripts\systems\game_manager.gd`, registrar como Autoload
5. **Validar:** F5 abre ventana 1280×720 sin errores

---

### FASE 1 — PERSONAJE BASE

**Objetivo:** Promesero se mueve, salta, tiene FSM visual.
**Crear:** `scripts\player\promesero.gd` + `scenes\player\Player.tscn`

**Player.tscn:** CharacterBody2D → Sprite2D(32×48) + CollisionShape2D(Capsule r12 h40) + HitboxLight(Area2D off) + HitboxHeavy(Area2D off) + Hurtbox(Area2D)

**FSM:** IDLE, RUN, JUMP, FALL, ATTACK_LIGHT, ATTACK_HEAVY, DODGE, HURT, DEAD
**Constantes:** SPEED=300, ACCEL=1800, FRICTION=1400, JUMP=-550, CUT=0.4, FALL_GRAV=1.6, COYOTE=0.12, BUFFER=0.12

Implementar: movimiento con aceleración/fricción → salto variable → coyote+buffer → FSM → debug colores por estado

**TestLevel.tscn:** Node2D + Player + Floor(WorldBoundary) + Platform + Camera2D

**Validar:** Se mueve, salta variable, coyote funciona al caer de plataforma, colores cambian.

---

### FASE 2 — COMBATE

**Objetivo:** Atacar, esquivar, recibir daño, morir.
**Modificar:** `promesero.gd`

Recursos: hp=100, devocion=10, stamina=100.0, gracia=0.0, is_invincible=false
Señales: hp_changed, devocion_changed, stamina_changed, gracia_changed, player_died

Ataque ligero: J, sin costo, daño=10, hitbox 0.15s, total 0.35s
Ataque pesado: K, consume 1 devocion, daño=25, knockback=350, hitbox 0.2s, total 0.55s
Esquiva: Shift, consume stamina 30, iframes 0.3s, impulso ×2.2
Daño: knockback, invencibilidad 0.6s, HP=0→DEAD
Stamina regen: 25/s en reposo

**Validar:** J/K/Shift funcionan con costos correctos, morir funciona.

---

### FASE 3 — HUD

**Objetivo:** HUD con 4 recursos visibles.
**Crear:** `scripts\ui\hud.gd` + `scenes\ui\HUD.tscn`

CanvasLayer con ProgressBar para HP/Stamina, Label numérico para Devoción/Gracia. BossBar oculta por defecto.
Conectar señales del Player (add_to_group "player").

**Validar:** Barras se mueven en tiempo real.

---

### FASE 4 — ENEMIGO BASE

**Objetivo:** Clase reutilizable con FSM.
**Crear:** `scripts\enemies\enemy_base.gd` + `scenes\enemies\EnemyBase.tscn`

CharacterBody2D + Sprite2D(rojo) + DetectionZone(Area2D r150) + Hitbox(grupo enemy_hitbox, var damage=10) + Hurtbox
FSM: PATROL(80px/s) → CHASE(120) → ATTACK(hitbox 0.2s, cd 1.5s) → HURT → DEAD(soltar Gracia, queue_free)

**Validar:** Patrulla, persigue, ataca, muere, suelta Gracia.

---

### FASE 5 — ENEMIGOS ZONA 1

**Objetivo:** Procesional y Veladora específicos.
**Crear:** `procesional.gd`/`.tscn` + `veladora.gd`/`.tscn` (extends enemy_base)

Procesional: HP=40, daño=15, gracia=8, lento(50), swing arco radio 60, ventana post-swing 0.8s
Veladora: HP=15, daño=20(explosión), gracia=5, chase 130, explota al contacto (área 60px a todos), destruible con pesado

**Validar:** Ambos funcionan, Procesional tiene ventana, Veladora explota y daña otros enemigos.

---

### FASE 6 — ALTARES Y RESPAWN

**Objetivo:** Checkpoints funcionales.
**Crear:** `checkpoint_system.gd`(Autoload) + `altar_menor.gd`/`.tscn` + `altar_mayor.gd`/`.tscn`

Altar Menor: interact→consume gracia(5)→checkpoint. Una vez.
Altar Mayor: interact→consume gracia(20)→elimina enemigos grupo "enemies".
Respawn: morir→delay 1.5s→reaparecer en último altar→HP restaurado→Gracia perdida.

**Validar:** Activar altar → morir → reaparece allí. Altar Mayor limpia enemigos.

---

### FASE 7 — MANDA

**Objetivo:** Manda de Salud funcional.
**Crear:** `manda_system.gd`(Autoload) + `manda_ui.gd`/`.tscn`

Manda de Salud: activar→HP max×0.8→ataque pesado×1.4. Cumplir=permanente. Romper=pierde HP sin bonus.
UI: panel con sacrificio(rojo)/beneficio(dorado), aceptar/rechazar.

**Validar:** Activar manda → HP baja → pesado hace +40%.

---

### FASE 8 — ZONA 1

**Objetivo:** La Parroquia jugable completa.
**Crear:** `scenes\zones\Zone1.tscn`

Node2D con TileMap + Player + Camera2D + 3 Procesionales + 2 Veladoras + 3 Altares Menor + 1 Altar Mayor + 5 VelasSuelo(hazard) + BossDoor + HUD.

Layout izq→der: entrada segura → altarM1 a 90seg → zona patrulla → altarM2 → zona vertical → Altar Mayor → altarM3 → puerta boss.

**Validar:** Recorrer toda la zona, altares funcionan, enemigos activos, morir y reaparecer.

---

### FASE 9 — BOSS

**Objetivo:** Mayordomo con 3 fases.
**Crear:** `scripts\bosses\mayordomo.gd` + `scenes\bosses\Mayordomo.tscn`

HP=200. Sprite 64×80 púrpura.
Fase 1 (200→134): predecible, golpe lateral, d=15, v=100.
Fase 2 (133→67): errático, triple rápido, d=12×3, v=160.
Fase 3 (66→0): alterna ataque(3s)/rezo(4s). Rezo=invulnerable+cura 10HP.
Morir: GameManager.zone1_boss_defeated=true → victoria.
Barra de vida en HUD al entrar arena.

**Validar:** 3 fases distintas, rezo=recuperación, derrotar→victoria.

---

### FASE 10 — UI Y FLUJO

**Objetivo:** Run completa: Título → Zona 1 → Boss → Victoria/GameOver.
**Crear:** TitleScreen, GameOver, Victory (.tscn + .gd)

Title: "SINCRETISMO" + "Nueva promesa"→Zone1 + "Salir".
GameOver: "El pueblo no duerme..." + reiniciar/menú.
Victory: "La manda se ha cumplido" + menú.
Main.tscn carga TitleScreen.

**Validar:** Run completa sin crash en ambos caminos.

---

### FASE 11 — POLISH Y EXPORT

1. Fade negro 0.5s entre escenas
2. Flash blanco al golpear, rojo al recibir daño, camera shake 2px
3. SFX Kenney (salto, ataque, daño, muerte, altar)
4. Export .exe Windows, probar en otra máquina

**Checklist:**
- [ ] Run completa sin crash
- [ ] Gracia funcional
- [ ] Respawn en altares
- [ ] Manda de Salud activa
- [ ] HUD legible
- [ ] 2 enemigos Zona 1
- [ ] Boss 3 fases
- [ ] .exe exportado

---

## NOTAS PARA CLAUDE CODE

- Godot 4.6.1, GDScript. No C#. No Godot 3 syntax.
- `@onready` no `onready`. `@export` no `export`.
- Señales: `signal nombre(param: tipo)`. Conectar: `señal.connect(callable)`.
- `move_and_slide()` sin argumentos. velocity es propiedad.
- `is_on_floor()` no `is_on_ground()`.
- Cambiar escena: `get_tree().change_scene_to_file("res://path")`.
- Autoloads en project.godot bajo `[autoload]`.
- .tscn son texto plano — se pueden generar desde terminal.
- Priorizar funcionalidad. Rectángulos de colores son válidos.
- **Carpeta con paréntesis:** `sincretismo(beta)` — usar comillas en terminal.
- **OneDrive:** hacer commits frecuentes, pull antes de cada sesión.
