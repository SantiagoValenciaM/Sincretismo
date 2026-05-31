# Sprites Pendientes — Obstáculos, Decoraciones y Altares

**Estilo:** Pixel art. Misma paleta del juego: púrpura `#16082A`, ámbar/oro `#E0AF26`, naranja `#D25A00`.  
**Todos los sprites miran/apuntan hacia la derecha por default. Fondo transparente.**  
**Resolución:** trabajar a ×4 y exportar al tamaño final. Godot usa `TEXTURE_FILTER_NEAREST`.

---

## 1. ALTAR MENOR

| Propiedad | Valor |
|-----------|-------|
| Tamaño en juego | 32×48 px |
| Colisión | `RectangleShape2D` 32×48 |
| Archivo | `res://assets/sprites/env/altar_menor.png` |
| Ruta de implementación | Reemplazar `Visual (ColorRect)` en `AltarMenor.tscn` |

**Descripción:**  
Pequeño altar de calle mexicano (ofrenda doméstica). Vista frontal 2D.  
Base de madera oscura, nicho central con espacio para una veladora.  
Decoración mínima: moldura dorada en borde, punto de luz en el centro.

### Estados (spritesheet horizontal, 2 frames de 32×48 px cada uno → 64×48 px total)

| Frame | Estado | Descripción visual |
|-------|--------|--------------------|
| 0 | **Inactivo** | Madera oscura `#2A1408`. Nicho vacío o con veladora apagada. Cruz o símbolo grabado en el frente, apenas visible. Sin luz. |
| 1 | **Activado** | Mismo altar pero con veladora encendida en el nicho. Llama ámbar-blanco `#FFF0C8` en el centro. Aureola de luz dorada difusa alrededor del nicho. La madera toma un tono cálido. |

**Paleta:**

| Uso | Hex |
|-----|-----|
| Madera oscura | `#2A1408` |
| Madera media | `#4C2210` |
| Madera clara (borde luz) | `#6E3818` |
| Moldura dorada | `#E0AF26` |
| Nicho (sombra) | `#0E0608` |
| Llama (base) | `#D25A00` |
| Llama (punta) | `#FFF0C8` |

**Nota de implementación:**  
En `AltarMenor.tscn`, reemplazar `Visual (ColorRect)` por `Sprite2D` con `hframes=2`.  
En `altar_menor.gd → _actualizar_visual()`: `visual.frame = 1 if _activado else 0`.  
El `Label "†"/"✦"` puede retirarse cuando el sprite esté activo.

---

## 2. ALTAR MAYOR

| Propiedad | Valor |
|-----------|-------|
| Tamaño en juego | 48×64 px |
| Colisión | `RectangleShape2D` 48×64 |
| Archivo | `res://assets/sprites/env/altar_mayor.png` |
| Ruta de implementación | Reemplazar `Visual (ColorRect)` en `AltarMayor.tscn` |

**Descripción:**  
Retablo de iglesia colonial mexicana. Vista frontal 2D.  
Estructura de tres pisos: base de piedra, cuerpo con nicho central, remate con arco.  
Más elaborado que el Altar Menor — tiene ornamentación barroca simplificada en pixel art.

### Estados (spritesheet horizontal, 2 frames de 48×64 px cada uno → 96×64 px total)

| Frame | Estado | Descripción visual |
|-------|--------|--------------------|
| 0 | **Inactivo** | Piedra fría `#2A1840`. Nicho central vacío con sombra profunda. Molduras visibles pero sin luz. Cruz en remate superior. Tonos púrpura-oscuro. |
| 1 | **Activado/Purificado** | Mismo retablo con velas encendidas a ambos lados del nicho. Resplandor dorado `#E0AF26` irradiando desde el centro. La piedra toma tono cálido. Destellos en los ornamentos. |

**Paleta:**

| Uso | Hex |
|-----|-----|
| Piedra fría | `#2A1840` |
| Piedra media | `#3E2860` |
| Piedra cálida (activo) | `#4A2A50` |
| Moldura dorada | `#E0AF26` |
| Moldura dorada clara | `#FFD044` |
| Nicho oscuro | `#0C0618` |
| Vela cera | `#EBE5C5` |
| Llama | `#D25A00` |
| Llama punta | `#FFF0C8` |
| Cruz remate | `#E0AF26` |

**Nota de implementación:**  
En `AltarMayor.tscn`, reemplazar `Visual (ColorRect)` por `Sprite2D` con `hframes=2`.  
En `altar_mayor.gd → _usar()`: `visual.frame = 1` tras activación.

---

## 3. VELA DE SUELO (Hazard)

| Propiedad | Valor |
|-----------|-------|
| Tamaño en juego | 60×24 px (hitbox) |
| Visual sugerido | 60×32 px (puede sobresalir hitbox verticalmente) |
| Archivo | `res://assets/sprites/env/vela_suelo.png` |
| Ruta de implementación | Reemplazar `Visual (ColorRect)` en cada `VelaSuelo1–5` en `Zone1.tscn` |

**Descripción:**  
Mancha de cera derretida en el suelo de la iglesia con velas encendidas encima.  
Se ven como 2–3 velitas cortas agrupadas sobre un charco de cera blanca-amarilla.  
Hace daño continuo (5 HP cada 0.5s) al pisar — aspecto de peligro claro.

### Animación (spritesheet horizontal, 3 frames de 60×32 px → 180×32 px total)

| Frame | Descripción |
|-------|-------------|
| 0 | Llama grande, recta. |
| 1 | Llama ligeramente inclinada a la derecha. |
| 2 | Llama ligeramente inclinada a la izquierda, más pequeña. |

**Loop de 3 frames a 6 fps** — parpadeo suave.

**Paleta:**

| Uso | Hex |
|-----|-----|
| Cera derretida (base) | `#EEE5B8` |
| Cera sombra | `#C8BA88` |
| Cuerpo vela | `#F5F0D8` |
| Llama base | `#D25A00` |
| Llama media | `#FFB020` |
| Llama punta | `#FFF0C8` |
| Mecha | `#201008` |

**Nota de implementación:**  
Reemplazar `ColorRect` por `AnimatedSprite2D` en cada `VelaSuelo`.  
`vela_suelo.gd` ya corre `_process` — agregar `_spr.play("burn")` en `_ready()`.  
Offset Y negativo para que la llama salga por encima del suelo: `position.y = -16`.

---

## 4. PUERTA DEL JEFE

| Propiedad | Valor |
|-----------|-------|
| Tamaño en juego | 48×120 px |
| Colisión | `RectangleShape2D` 48×120 |
| Archivo | `res://assets/sprites/env/boss_door.png` |
| Ruta de implementación | Reemplazar `Visual (ColorRect)` en `BossDoor` en `Zone1.tscn` |

**Descripción:**  
Puerta de sacristía de iglesia colonial. Vista frontal 2D. Alta y estrecha.  
Madera oscura con herrajes de hierro. Arco superior. Símbolo amenazante (calavera o cruz invertida) grabado en el centro.  
Emite una luz morada inquietante por las grietas — señal de que el jefe está al otro lado.

### Estados (spritesheet horizontal, 2 frames de 48×120 px → 96×120 px total)

| Frame | Estado | Descripción |
|-------|--------|-------------|
| 0 | **Cerrada** | Madera oscura. Luz morada filtrándose por grietas y borde inferior. Herrajes visibles. |
| 1 | **Abierta/Activada** | (opcional) Misma puerta más iluminada, luz morada intensa. Se puede usar un solo frame estático. |

**Paleta:**

| Uso | Hex |
|-----|-----|
| Madera oscura | `#1A0C08` |
| Madera media | `#2E1610` |
| Madera borde luz | `#4A2218` |
| Herraje hierro | `#1C1C28` |
| Herraje highlight | `#3A3A4E` |
| Luz morada (grietas) | `#6010A0` |
| Luz morada clara | `#9030E0` |
| Símbolo grabado | `#8020C0` |

**Nota de implementación:**  
Reemplazar `Visual (ColorRect)` por `Sprite2D`.  
Mantener o quitar el `BossDoorLabel "JEFE"` según decisión de diseño.

---

## 5. DECORACIONES DE FONDO — Elementos Separados

Los elementos actualmente están **pintados en `bg_layer0.png`**.  
Convertirlos a sprites independientes permite animarlos, ajustarlos por zona, y reutilizarlos.

### 5.1 Estandarte con Cruz (`banner_cross.png`)

| Propiedad | Valor |
|-----------|-------|
| Tamaño | 48×96 px |
| Archivo | `res://assets/sprites/env/bg/banner_cross.png` |
| Uso | `Sprite2D` estático en fondo, z_index = -8 |

**Descripción:**  
Estandarte de tela que cuelga de un gancho en la pared. Fondo dorado `#E0AF26` con borde negro.  
Cruz dorada oscura en el centro. Triángulo de suspensión en la parte superior (tela doblada formando punta invertida).  
Aspecto de procesión religiosa mexicana.

| Elemento | Descripción |
|----------|-------------|
| Soporte (top) | Gancho de hierro negro `#1C1C28`, 8×6 px |
| Tela cuerpo | Dorado `#E0AF26`, 40×80 px, bordes negros 2px |
| Cruz | Líneas de 4px, color `#A07010`, centrada en el cuerpo |
| Flecos (bottom) | 6 flecos de 4px de ancho, 8px de largo, color dorado oscuro |

**Posiciones sugeridas en `Zone1.tscn`** (z_index = -8, sin colisión):  
x=180, x=540, x=900, x=1260 — alineados con las ventanas del fondo.

---

### 5.2 Calavera Decorativa (`skull_decor.png`)

| Propiedad | Valor |
|-----------|-------|
| Tamaño | 24×24 px |
| Archivo | `res://assets/sprites/env/bg/skull_decor.png` |
| Uso | `Sprite2D` estático en fondo, z_index = -8 |

**Descripción:**  
Calavera de Día de Muertos estilizada en pixel art, montada en la pared entre los estandartes.  
8 flores de cempasúchil alrededor formando corona.

| Elemento | Descripción |
|----------|-------------|
| Cráneo | Blanco `#F0EEE8`, forma de corazón invertido, 16×14 px |
| Cuencas | Negras `#0C0612`, ovaladas, 4×4 px cada una |
| Nariz | Triángulo negro 3×3 px |
| Dientes | 4 rectángulos blancos 2×3 px sobre fondo negro |
| Flores cempasúchil | 8 pétalos `#D25A00`, centro `#FF820A`, 4 px de diámetro |

**Posiciones sugeridas** (z_index = -8):  
Centradas entre los estandartes — x=390, x=780, x=1170.

---

### 5.3 Vela de Pared (`wall_candle.png`)

| Propiedad | Valor |
|-----------|-------|
| Tamaño | 16×32 px |
| Archivo | `res://assets/sprites/env/bg/wall_candle.png` |
| Animación | 2 frames (llama A / llama B) a 4 fps, loop |
| Uso | `AnimatedSprite2D` en fondo, z_index = -8 |

**Descripción:**  
Vela de pared con soporte dorado. Cera blanca-crema. Llama ámbar con punto blanco.

| Elemento | Descripción |
|----------|-------------|
| Soporte | Rectángulo dorado `#E0AF26`, 12×4 px, centrado en la base |
| Cuerpo vela | Crema `#EBE5C5`, 4×16 px |
| Frame 0: llama | Forma de gota alta `#D25A00`, 4×8 px, punta `#FFF0C8` 2×2 px |
| Frame 1: llama | Forma de gota ligeramente más ancha, 1px desplazada a la derecha |

**Spritesheet:** 32×32 px (2 frames de 16×32 px).  
**Posiciones sugeridas** (z_index = -8): x=390, x=780, x=1170 — debajo de las calaveras.

---

## RESUMEN DE ARCHIVOS

| Archivo | Tamaño | Frames | Ruta en proyecto |
|---------|--------|--------|-----------------|
| `altar_menor.png` | 64×48 | 2 | `res://assets/sprites/env/altar_menor.png` |
| `altar_mayor.png` | 96×64 | 2 | `res://assets/sprites/env/altar_mayor.png` |
| `vela_suelo.png` | 180×32 | 3 | `res://assets/sprites/env/vela_suelo.png` |
| `boss_door.png` | 96×120 | 2 | `res://assets/sprites/env/boss_door.png` |
| `banner_cross.png` | 48×96 | 1 | `res://assets/sprites/env/bg/banner_cross.png` |
| `skull_decor.png` | 24×24 | 1 | `res://assets/sprites/env/bg/skull_decor.png` |
| `wall_candle.png` | 32×32 | 2 | `res://assets/sprites/env/bg/wall_candle.png` |

---

## PRIORIDAD DE IMPLEMENTACIÓN

| Prioridad | Sprite | Razón |
|-----------|--------|-------|
| 🔴 Alta | Altar Menor / Mayor | Interacción central del gameplay |
| 🔴 Alta | Vela de Suelo | Hazard visible activo en Zone1 |
| 🟡 Media | Puerta del Jefe | Marcador visual importante de progreso |
| 🟢 Baja | Estandarte / Calavera / Vela pared | Puramente decorativo — ya existe versión en bg_layer0 |
