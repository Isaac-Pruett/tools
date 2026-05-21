# Hint-mode navigation — **open gap, future custom-build project**

## Status: not implemented; do not re-attempt with off-the-shelf tools

The original goal: Vimium-style per-element hint navigation across the Linux desktop. Press a hotkey → labeled overlays appear on every clickable UI element on screen → type the label → cursor warps and clicks that element.

After investigation, **no mature tool exists on Linux that delivers this.** The tools that appear in Internet search results for "Vimium for desktop on Linux" are misleading and do something else. To save future-me and future-Claude-agents the same dead-ends:

| Tool | What it actually does | NOT what we want |
|---|---|---|
| **warpd** | Grid of letter labels across the screen → warp cursor to grid cell, refine with hjkl, press `1` to click | Not per-element |
| **mouseless** (jbensmann) | hjkl cursor movement with custom keymap layers, similar concept to vim-mouse | Not per-element |
| **keynav** | X11 recursive grid (3x3 → pick → 3x3 again) | X11-only, dead project, not per-element |
| **vimac / homerow / shortcat** | Actual per-element accessibility-API hints | **macOS only** — no Linux port |
| **Vimium / Tridactyl** | Per-element hints | **Browser-only** — not desktop |

**Conclusion:** if you want Vimium for the Linux desktop, you have to build it. There is no shortcut. Do not install warpd, mouseless, or anything else hoping it'll be the answer — it won't.

## If we ever build this ourselves

Sketch of what the custom build would need:

### Hint source — AT-SPI2 accessibility tree
- Use `pyatspi` (Python AT-SPI2 bindings) to walk the accessibility tree of the focused application
- Filter to nodes with `Action` interface or specific clickable roles (`push button`, `menu item`, `link`, `radio button`, etc.)
- Get on-screen coordinates via the `Component` interface's `getExtents`
- AT-SPI2 coverage varies wildly: GTK apps are excellent; Qt apps are decent (need `qt-at-spi` plugin); Electron is inconsistent (set `ELECTRON_ENABLE_ACCESSIBILITY=1`); a few apps expose nothing

### Overlay rendering — X11 (this machine) / Wayland (future)
- On X11: transparent `override-redirect` GTK window using `cairo` to draw labels at the harvested coordinates
- On Wayland: `wlr-layer-shell` overlay (requires wlroots-based compositor — would belong in `wayland-tiling/` profile, not this one)
- Need to track window stacking / occlusion to avoid drawing labels behind windows

### Input + click dispatch
- Capture keystrokes while overlay is up (xinput grab on X11, virtual keyboard on Wayland)
- On match, `xdotool mousemove` + `xdotool click 1` (X11) or `wlr-virtual-pointer-v1` (Wayland)
- Release grab + close overlay

### Hard parts (in order of nastiness)
1. Picking the right AT-SPI2 nodes — too few = hints incomplete; too many = visual noise. Needs per-toolkit tuning.
2. Coordinate accuracy when the desktop has multi-monitor + DPI scaling.
3. Latency: building the hint set must feel instant (<100ms); AT-SPI2 tree traversal can be slow for big apps (browsers especially).
4. Handling apps with no AT-SPI2 — graceful fallback message vs silent failure.
5. Focus / occlusion correctness when overlay is up.

### Scope guess: multi-week build
- Week 1: prototype AT-SPI2 enumeration + simple printed coords for one app (gnome-shell)
- Week 2: GTK transparent overlay drawing hints
- Week 3: keyboard grab + dispatch + GNOME shortcut wiring
- Week 4: extend coverage across apps, handle edge cases, ship as a separate tool/repo

If/when this becomes a real project, it deserves its own repo (not bolted onto `lks-dev-env`) and its own design doc.

## In the meantime — what we use instead

Mouse for desktop shell interaction. Keyboard-driven workflows exist where they matter:
- **Vimium** in browsers (`f` to hint links) — covers most of the daily mouse-need
- **kitty copy mode** in terminal
- **Helix / LazyVim** in editors
- **Alt+Tab / Alt+\`** to switch windows
- **Super+number** to focus dock items
- **GNOME activities + typing** to launch apps

These cover ~90% of "I'd otherwise need a mouse" moments. The remaining 10% (clicking a specific button in Slack, dismissing a notification, dragging a window edge) we live with using the mouse, or revisit when the custom-build project actually happens.
