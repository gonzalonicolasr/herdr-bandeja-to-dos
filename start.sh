#!/bin/sh
# Startup hook: puts herdr-todo on the PATH and launches the tray daemon.
# herdr-attn holds a lock, so running this twice leaves a single instance.
root=${HERDR_PLUGIN_ROOT:-$(cd "$(dirname "$0")" && pwd)}
state=${HERDR_PLUGIN_STATE_DIR:-$HOME/.local/state}
mkdir -p "$HOME/.local/bin" "$state"
[ -e "$HOME/.local/bin/herdr-todo" ] || ln -s "$root/bin/herdr-todo" "$HOME/.local/bin/herdr-todo"
if pgrep -f "bin/herdr-attn" >/dev/null 2>&1; then
  :
elif command -v setsid >/dev/null 2>&1; then
  setsid -f python3 "$root/bin/herdr-attn" >>"$state/herdr-attn.log" 2>&1 </dev/null
else
  nohup python3 "$root/bin/herdr-attn" >>"$state/herdr-attn.log" 2>&1 </dev/null &
fi
