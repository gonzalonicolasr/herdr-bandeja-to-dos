# bandeja — plugin de herdr

Convierte el panel **agents** del sidebar de herdr en una bandeja de "quién te
necesita": cada agente que requiere algo de vos aparece como una tarjetita, y los
agentes pueden dejarte **to-dos** que se ven en su tarjeta.

```
▲ TE NECESITA            ← rojo: el agente está bloqueado esperándote
misc › Spanish help
├ Spanish comprehension  ← lo que está haciendo (título de la terminal)
╰ □ Probar el deploy     ← to-do que te dejó

□ 3 TO-DOS               ← ámbar: agente quieto, pero con cosas para vos
~w-work › main
├ □ Pedidos Tesorería…
├ □ Decidir quién…
╰ ✔ T̶o̶m̶i̶:̶ ̶c̶o̶n̶t̶r̶o̶l̶…       ← hecho (queda tachado 12 h y desaparece)
```

Estados, en orden: `▲ TE NECESITA` · `✔ LISTO` · `◌ TRABAJANDO` · `□ N TO-DOS`.
Un agente idle sin to-dos no ocupa lugar. Click en la tarjeta = ir a ese agente.
Arriba a la derecha de la fila de pestañas queda un resumen:
`▲ 1 te necesita · 2 listos · 4 to-dos · 1 trabajando`.

## Requisitos

- herdr **0.8.2** o más nuevo
- `python3` (sólo librería estándar)
- Linux o macOS

## Instalación

1. Instalá el plugin:

   ```bash
   herdr plugin install gonzalonicolasr/herdr-bandeja-to-dos --yes
   ```

   (o, si te pasaron la carpeta: `herdr plugin link /ruta/a/herdr-bandeja-to-dos`)

2. Pegá el contenido de [`config-snippet.toml`](config-snippet.toml) en
   `~/.config/herdr/config.toml`. Si ya tenés una sección `[ui]`, sumale las
   claves en vez de duplicarla. Después:

   ```bash
   herdr server reload-config
   ```

3. Arrancala sin reiniciar herdr (de ahí en más arranca sola con el server):

   ```bash
   herdr plugin action invoke bandeja.start
   ```

4. Asegurate de tener `~/.local/bin` en el `PATH`: el plugin deja ahí el comando
   `herdr-todo` (si ya existe uno, no lo pisa).

## To-dos: `herdr-todo`

Se corre **desde adentro de un pane de herdr** (detecta solo el pane por
`$HERDR_PANE_ID`), y el to-do aparece en la tarjeta de ese agente en ≤ 2 s.

```
herdr-todo add "Probar el .exe en la otra PC"
herdr-todo list            # numerados, ✔ = hecho
herdr-todo done 1          # queda tachado
herdr-todo undo 1
herdr-todo rm 1
herdr-todo clear           # borra los hechos (clear --all: todos)
herdr-todo all             # los de todos los panes
```

`--pane <id>` actúa sobre otro pane. Se guardan en `~/.local/state/herdr-todos.json`.

### Que los agentes lo usen solos

Pegá esto en tu `CLAUDE.md` / `AGENTS.md` global:

> **To-dos para mí en herdr (`herdr-todo`).** Es un comando de terminal. Cuando
> dejes algo que **yo tengo que hacer a mano** (probar en otra PC, aprobar un
> deploy, pedirle un dato a alguien, revisar antes de mergear), corré
> `herdr-todo add "texto corto y accionable"`. No lo uses para tus propias
> tareas. Si ya está hecho o no aplica, `herdr-todo done N`.

## Cómo funciona

- `bin/herdr-attn` es un daemon chiquito: cada 2 s lee los agentes
  (`herdr agent list`) y los to-dos, y le reporta a cada pane tokens de metadata
  (`$attn`, `$where`, `$task`, `$t1`…) que el layout de `config-snippet.toml`
  pinta. También fija una vista del panel agents (label **bandeja**) que muestra
  sólo los agentes con tarjeta. Sólo manda cambios.
- Lo lanza el *startup hook* del plugin cada vez que arranca un server de herdr.
  Tiene un lock, así que nunca corren dos. Si herdr se cierra, se apaga solo al
  minuto.
- Log: `~/.local/state/herdr/plugins/bandeja/herdr-attn.log`.

## Personalizar

- **Colores**: los `fg` de `config-snippet.toml`.
- **Textos de los estados**: `HEADS` y `summary()` en `bin/herdr-attn`.
- **Cuántos to-dos por tarjeta**: `TODO_ROWS` (y agregá filas `$t4`… al layout).
- **Cuánto queda visible un to-do hecho**: `DONE_TTL` (12 h).

## Desinstalar

```bash
herdr plugin uninstall bandeja
pkill -f bin/herdr-attn
rm ~/.local/bin/herdr-todo
```

y sacá el bloque del `config.toml`.
