# Sprites — Descripción para Arte

**Estilo general:** Pixel art. Paleta oscura con acentos dorados/anaranjados.  
**Resolución base:** 32×48 px por frame (personajes medianos). Boss: 64×80 px.  
**Tema:** Sincretismo religioso mexicano. Tonos sepia, negro, oro viejo, cera, sangre seca.

---

## EL PROMESERO — Personaje Principal

Hombre adulto, ropa de pueblo: calzón blanco, camisa cruda, pies descalzos o huaraches.
Lleva velas o exvotos colgados. Aspecto de peregrino en penitencia.

| Sprite | Archivo | Frames | Descripción |
|--------|---------|--------|-------------|
| Reposo | `idle.png` | 4–6 | De pie, leve respiración. Velas/listones se mecen suavemente. Manos juntas al frente o a los costados. Loop. |
| Caminar | `walk.png` | 6–8 | Paso firme pero cansado. Ligera cojera opcional. Cuerpo oscila. Loop. |
| Saltar (subida) | `jump_up.png` | 2 | Rodillas al pecho, brazos extendidos hacia arriba. |
| Caer | `fall.png` | 2 | Cuerpo ligeramente inclinado hacia abajo, brazos abiertos. |
| Ataque ligero | `attack_light.png` | 4 | Golpe rápido con la mano abierta o con velón pequeño. Arco horizontal. Frames: preparación → golpe → extensión → retorno. |
| Ataque pesado | `attack_heavy.png` | 5 | Golpe contundente con ambas manos o con cruz/objeto ritual. Más amplio y lento. Frames: carga (agachado) → impulso → impacto → seguimiento → retorno. |
| Esquiva | `dodge.png` | 3 | Dash lateral rápido. Cuerpo inclinado al frente, casi a ras de suelo. Estela de polvo/luz opcional. |
| Recibir daño | `hurt.png` | 2 | Retroceso brusco, brazos abiertos, cabeza echada atrás. Flash rojo en el código — el sprite puede ser neutro. |
| Muerto | `dead.png` | 1 | Tendido boca abajo o de lado. Exvotos regados en el suelo alrededor. |

**Nota de implementación:** El código actual usa un solo `.png` por estado (spritesheet horizontal).
Todos los frames del mismo estado van en una sola imagen, separados por 32 px.

---

## PROCESIONAL — Enemigo Zona 1

Penitente encapuchado con túnica morada oscura. Carga una imagen religiosa o una cruz pesada.
Se mueve lento, oscilante. Peligroso en el arco de su swing, vulnerable después.

**Tamaño:** 28×44 px por frame.  
**Paleta:** Morado oscuro `#4D1A3A`, dorado opaco `#7A6020`, piel descolorida.

| Sprite | Archivo | Frames | Descripción |
|--------|---------|--------|-------------|
| Patrulla | `procesional_patrol.png` | 4–6 | Caminar lento y pesado. Cuerpo inclinado hacia adelante bajo el peso de la carga. Loop. |
| Perseguir | `procesional_chase.png` | 4–6 | Mismo ciclo de caminata pero con urgencia. Capucha más inclinada al frente. Puede reutilizar patrol. |
| Ataque (swing) | `procesional_attack.png` | 5 | Arco amplio de 180° con el objeto que carga. Frames: levanta objeto → punto medio del swing → impacto → seguimiento → baja. El hitbox en código dura 0.25 s. |
| Ventana post-swing | `procesional_recovery.png` | 2 | Postura abierta y encorvada tras el swing. Brazo extendido, cuerpo sin guardia. Vulnerable (×1.5 daño en código). |
| Recibir daño | `procesional_hurt.png` | 2 | Retroceso, objeto cae, capucha se sacude. |
| Muerto | `procesional_dead.png` | 3 | Se desmorona. Túnica cae. Objeto rueda en el suelo. Desaparece con queue_free. |

---

## VELADORA — Enemigo Zona 1

Figura etérea envuelta en llamas de vela. Pequeña y ágil. No ataca con golpes — explota al contacto.
Puede destruirse con ataque pesado antes de llegar.

**Tamaño:** 20×28 px por frame.  
**Paleta:** Amarillo llama `#FFD940`, naranja `#FF8C00`, blanco cera, negro quemado.

| Sprite | Archivo | Frames | Descripción |
|--------|---------|--------|-------------|
| Patrulla | `veladora_idle.png` | 4 | Flota ligeramente. Llama parpadea. Movimiento oscilante vertical leve. Loop. |
| Perseguir | `veladora_chase.png` | 4 | Se inclina hacia adelante, llama se alarga en la dirección del movimiento. Más rápida. Loop. |
| Explosión | `veladora_explode.png` | 5 | Expansión radial de llama. Frames: destello central → expansión → bola completa → dispersión → humo/ceniza. Radio 60 px en código. |
| Recibir daño (ligero) | `veladora_hurt.png` | 2 | Llamita se contrae momentáneamente, cuerpo parpadeante. |

**Nota:** El ataque pesado (dmg ≥ 25) la destruye directamente — lleva a `explode` sin `hurt`.

---

## EL MAYORDOMO — Boss Zona 1

Hombre corpulento con traje de mayordomo de fiestas patronales: saco negro, mascada roja, bastón de mando.
Expresión severa. En fase 3 se arrodilla a rezar con un rosario.

**Tamaño:** 64×80 px por frame.  
**Paleta (base):** Negro traje, rojo mascada, dorado botones. Cambia por fase:
- Fase 1: Púrpura `#7A1AB8` — tranquilo, predecible
- Fase 2: Rosa-rojo `#CC1A80` — errático, agresivo
- Fase 3: Rojo oscuro `#FF1A33` — desesperado; durante rezo: lila suave `#CC80FF`

| Sprite | Archivo | Frames | Descripción |
|--------|---------|--------|-------------|
| Reposo / acercarse | `mayordomo_idle.png` | 4 | Camina erguido, bastón golpeando el suelo cada dos pasos. Intimidante. Loop. |
| Golpe lateral (F1) | `mayordomo_atk1.png` | 4 | Swing horizontal del bastón. Lento y predecible. Frames: levanta bastón → swing → impacto → retira. Hitbox 0.25 s. |
| Triple golpe (F2) | `mayordomo_atk2.png` | 6 | Serie de 3 golpes rápidos alternos. Frames por golpe: 2 (impulso + impacto). Total 6. Cada golpe dmg=12. |
| Rezo (F3) | `mayordomo_pray.png` | 6 | Se arrodilla, saca rosario, inclina cabeza. Aura de luz suave que pulsa. Durante 4 s — invulnerable y recupera 10 HP/s. Loop. |
| Recibir daño | `mayordomo_hurt.png` | 2 | Retrocede, mascada se sacude, gesto de rabia. |
| Muerto | `mayordomo_dead.png` | 5 | Suelta el bastón, se lleva la mano al pecho, cae de rodillas, queda inmóvil. Bastón rueda. Lento y dramático. |

---

## NOTAS GENERALES PARA EL ARTISTA

- Todos los personajes miran hacia la **derecha** por default. El código usa `scale.x = -1` para voltear.
- El código aplica `modulate` para flash de daño (blanco) y flash de golpe recibido (rojo). Los sprites deben ser de colores plenos, sin pre-bake de efectos de luz.
- Los frames se cargan como **spritesheet horizontal** (todos los frames en una sola imagen `.png`, sin transparencia entre ellos).
- Fondo **transparente** en todos los sprites.
- Ruta de destino en el proyecto Godot:
  - Promesero: `res://assets/sprites/promesero/`
  - Enemigos: `res://assets/sprites/enemies/`
  - Boss: `res://assets/sprites/bosses/`
