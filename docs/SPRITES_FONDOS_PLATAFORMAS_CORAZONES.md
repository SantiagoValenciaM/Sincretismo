# Sprites — Fondos, Plataformas y Corazones

**Estilo general:** Pixel art. Paleta oscura: púrpura `#16082A`, ámbar/oro `#E0AF26`, naranja `#D25A00`.  
**Tema:** Interior de parroquia mexicana. Sincretismo religioso — piedra, cera, cempasúchil, calaveras.  
**Todos los sprites miran/apuntan hacia la derecha por default.**  
**Fondo transparente** en todo excepto donde se indique lo contrario.

---

## 1. FONDOS — Zona 1 «La Parroquia»

El nivel mide **1600×800 px** en coordenadas de mundo.  
Los fondos se instancian como `Sprite2D` centrados en `(800, 200)`.  
Capa lejana: `z_index = -10`. Capa media: `z_index = -5`.

### 1.1 Capa lejana — `bg_layer0.png`

| Propiedad | Valor |
|-----------|-------|
| Tamaño | 1600×800 px |
| Formato | RGB (sin transparencia) |
| Ruta | `res://assets/bg_layer0.png` |

**Descripción:**  
Interior de nave de iglesia colonial mexicana visto de frente. Sin perspectiva — completamente plano/2D.

| Zona de la imagen | Contenido |
|-------------------|-----------|
| **Y 0–110** (techo) | Techo oscuro. Degradado de negro-púrpura `#080212` → `#261034`. Hilera de ménsulas de piedra al borde inferior — bloques rectangulares alternados con puntos de cempasúchil `#D25A00` al centro de cada uno. |
| **Y 110–730** (muro) | Pared de piedra con aparejo de sillares: filas horizontales de bloques `#36185E` / `#1A0830`, juntas de mortero `#0C0412` de 2 px. Juntas verticales desfasadas por hilada (como ladrillo real). |
| **Y 110–340** (ventanas) | 4 ventanas de arco apuntado, distribuidas en X: 200, 590, 985, 1375. Cada ventana: marco de piedra oscura, vidrio ámbar luminoso `#B45800`→`#F0C040`, resplandor difuso detrás del marco, crucifijo dorado `#FFD044` en el cristal con travesaño. |
| **Entre ventanas** | Calavera decorativa (3 unidades, centradas entre ventanas). Estilo calavera de Día de Muertos: cráneo estilizado con cuencas vacías, nariz triangular, dientes. Rodeada de 8 flores de cempasúchil en círculo. |
| **Y 380–500** (pared media) | Vela de pared con soporte dorado en cada espacio entre ventanas (3 unidades). Mecha encendida, llama ámbar-blanco, destello sutil alrededor. |
| **Y 730–800** (piso) | Loseta de piedra oscura `#1E0E28`. Juntas en cuadrícula de 80×32 px. |
| **Y 730** (franja de transición) | Friso horizontal de flores de cempasúchil repetidas cada 48 px. |

**Paleta de referencia:**

| Uso | Hex |
|-----|-----|
| Piedra oscura | `#16082A` |
| Piedra media | `#36185E` |
| Piedra clara | `#462846` |
| Mortero | `#0C0412` |
| Ámbar ventana (oscuro) | `#6E3000` |
| Ámbar ventana (medio) | `#B45800` |
| Ámbar ventana (claro) | `#F0A820` |
| Oro crucifijo | `#FFD044` |
| Cempasúchil | `#D25A00` |
| Cempasúchil claro | `#FF820A` |
| Blanco vela/llama | `#FFF0C8` |

---

### 1.2 Capa media — `bg_layer1.png`

| Propiedad | Valor |
|-----------|-------|
| Tamaño | 1600×800 px |
| Formato | RGBA (con transparencia) |
| Ruta | `res://assets/bg_layer1.png` |

**Descripción:**  
Columnas de piedra que se superponen a la pared pero quedan detrás del gameplay.  
El resto de la imagen es **completamente transparente**.

6 columnas en X: **88, 428, 748, 1082, 1402, 1558**.  
Cada columna ocupa de Y=92 hasta Y=735 (toda la altura útil del nivel).

| Elemento | Descripción |
|----------|-------------|
| **Fuste** | Columna de 26 px de ancho. Piedra oscura con bisel de luz izquierdo (franja de 4 px más clara). Borde recto negro de 2 px en ambos lados. |
| **Capitel** (top) | Bloque de 44×18 px centrado en la columna. Moldura dorada `#E0AF26` de 2 px en borde superior. Panel rectangular rehundido en el centro. |
| **Base** (bottom) | Bloque de 44×18 px centrado en la columna. Moldura dorada `#E0AF26` de 2 px en borde inferior. |
| **Motivo de cruz** | Centrado verticalmente en el fuste. Cruz con brazos en diamante, color oro `#E0AF26`. Tamaño: 10×30 px (vertical) + travesaño de 20×3 px. |
| **Vela** (derecha de cada columna) | A 20 px a la derecha de la columna, en la base. Soporte dorado, vela blanca-crema, llama ámbar con punto blanco en punta. Halo difuso de 24 px de radio. |
| **Flor cempasúchil** (izquierda de cada columna) | A 20 px a la izquierda de la columna, en la base. 8 pétalos `#D25A00` + centro `#FF820A`. |

---

## 2. PLATAFORMAS

Las plataformas actuales son `ColorRect` marrones — necesitan sprite.  
El juego usa dos tamaños de plataforma:

| Tipo | Ancho en juego | Nombre |
|------|---------------|--------|
| Ancha | 240 px | `plat_wide` |
| Media | 160 px | `plat_mid` |

### Estilo visual

Bancos o cornisas de piedra de iglesia. Vista lateral 2D, sin perspectiva.  
Piedra labrada con pequeños detalles decorativos en el borde.

### 2.1 Tileset de plataforma — `platform_tiles.png`

Spritesheet horizontal con **3 tiles de 32×20 px** en este orden:

| Tile | Nombre | Descripción |
|------|--------|-------------|
| 1 | `left` | Extremo izquierdo. Arista izquierda redondeada o con moldura. Borde superior con franja de luz `#7A5040`. |
| 2 | `mid` | Tramo central, tileable. Superficie de piedra con variación sutil de textura (2–3 tonos de marrón-tierra). Junta vertical cada 16 px. |
| 3 | `right` | Extremo derecho. Espejo del tile izquierdo. |

**Dimensiones del spritesheet:** 96×20 px  
**Ruta:** `res://assets/sprites/env/platform_tiles.png`

**Paleta de referencia:**

| Uso | Hex |
|-----|-----|
| Superficie piedra (oscuro) | `#382010` |
| Superficie piedra (medio) | `#4C2E14` |
| Superficie piedra (claro) | `#644020` |
| Borde superior (luz) | `#7A5040` |
| Borde inferior (sombra) | `#1E1008` |
| Junta mortero | `#28160A` |

**Nota de implementación:** En `Zone1.tscn` reemplazar el `ColorRect` de cada `Plat1–Plat5` por un `Sprite2D` con `hframes=3`. Usar tile `mid` repetido para el centro y tiles `left`/`right` en los extremos. Alternativamente usar `TextureRect` con `stretch_mode = TILE` para el tramo medio.

### 2.2 Suelo — `ground_tile.png`

El suelo (`Ground`) es `ColorRect` de 2000×40 px — necesita sprite tileable.

| Propiedad | Valor |
|-----------|-------|
| Tamaño del tile | 80×40 px |
| Formato | RGB |
| Ruta | `res://assets/sprites/env/ground_tile.png` |

**Descripción:**  
Loseta de piedra de iglesia. Vista frontal. Más grueso y oscuro que las plataformas.  
Superficie ligeramente desgastada. Junta horizontal en Y=4 (moldura superior).  
Variación de color en el cuerpo del bloque cada tile para romper repetición.

**Paleta:** Igual que `platform_tiles.png` pero 15% más oscuro en general.

---

## 3. CORAZONES — HUD

El HUD muestra **4 corazones** de izquierda a derecha.  
Cada corazón representa 25 HP (HP máx = 100).  
Cada corazón tiene 3 estados:

| Estado | Cuándo | Color actual (código) |
|--------|--------|-----------------------|
| Lleno | HP del slot > 50% | Rojo `#E61919` |
| Medio | HP del slot 1%–50% | Naranja `#E5731A` |
| Vacío | HP del slot = 0% | Gris `#737373` |

### 3.1 Sprite de corazón — `heart_sheet.png`

Spritesheet horizontal con **3 frames de 32×32 px** en este orden: `lleno → medio → vacío`.

| Frame | Nombre | Descripción |
|-------|--------|-------------|
| 0 | `lleno` | Corazón completo estilo calavera mexicana. Forma de corazón clásica pero con detalle decorativo: pequeñas flores o puntos de cempasúchil en la superficie. Color rojo vivo `#CC0000` con highlight `#FF4444` en esquina superior izquierda y sombra `#880000` en la parte baja. |
| 1 | `medio` | Corazón partido por la mitad vertical. Mitad izquierda rellena en naranja `#CC5500`, mitad derecha hueca (solo contorno). Indica daño reciente. |
| 2 | `vacío` | Solo el contorno del corazón. Interior transparente o negro muy oscuro `#1A0808`. Contorno gris-rosado `#664444`. |

**Dimensiones del spritesheet:** 96×32 px  
**Ruta:** `res://assets/sprites/ui/heart_sheet.png`

**Paleta de referencia:**

| Uso | Hex |
|-----|-----|
| Rojo lleno (base) | `#CC0000` |
| Rojo lleno (highlight) | `#FF4444` |
| Rojo lleno (sombra) | `#880000` |
| Naranja medio | `#CC5500` |
| Naranja medio (highlight) | `#FF8833` |
| Contorno vacío | `#664444` |
| Interior vacío | `#1A0808` |
| Detalle cempasúchil | `#D25A00` |
| Punto highlight blanco | `#FFEECC` |

**Nota de implementación:**  
El código en `hud.gd` actualmente usa `Label` con el carácter `♥`/`♡` y `modulate`.  
Al tener el spritesheet, reemplazar cada `Label` por `TextureRect` (o `Sprite2D`) con `hframes=3` y cambiar el `frame` según el estado en lugar de cambiar `modulate`.

```gdscript
# Cambio propuesto en _actualizar_corazones():
# frame 0 = lleno, 1 = medio, 2 = vacío
if hp_en_slot > hp_por_corazon * 0.5:
    _corazones[i].frame = 0
elif hp_en_slot > 0.0:
    _corazones[i].frame = 1
else:
    _corazones[i].frame = 2
```

---

## RESUMEN DE ARCHIVOS

| Archivo | Tamaño | Formato | Ruta en proyecto |
|---------|--------|---------|-----------------|
| `bg_layer0.png` | 1600×800 | RGB | `res://assets/bg_layer0.png` |
| `bg_layer1.png` | 1600×800 | RGBA | `res://assets/bg_layer1.png` |
| `platform_tiles.png` | 96×20 | RGBA | `res://assets/sprites/env/platform_tiles.png` |
| `ground_tile.png` | 80×40 | RGB | `res://assets/sprites/env/ground_tile.png` |
| `heart_sheet.png` | 96×32 | RGBA | `res://assets/sprites/ui/heart_sheet.png` |

---

## NOTAS GENERALES

- Escala de trabajo sugerida: **×4** (diseñar a 4× y exportar al tamaño final). Godot usa `TEXTURE_FILTER_NEAREST` — los bordes pixelados son correctos.
- No pre-hornear efectos de luz ni sombras proyectadas — el código aplica `modulate` para flashes.
- Exportar con fondo transparente excepto `bg_layer0.png` y `ground_tile.png` (RGB puro).
- Convención de nombres: minúsculas, guión bajo, sin espacios.
