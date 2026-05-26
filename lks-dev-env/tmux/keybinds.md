 TMUX KEYBINDS                                   prefix = Alt+E
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 NO PREFIX
──────────────────────────────────────────────────────────────
  M-j          last active pane (MRU toggle)
  M-o          next pane (cycle)
  M-h          enter copy mode
  M-t          thumbs picker (yank text from screen)
  C-f          sessionizer

 PANES                                          prefix then:
──────────────────────────────────────────────────────────────
  "            split horizontal (top/bottom)
  %            split vertical  (left/right)
  z            zoom toggle (fullscreen pane)
  x            kill pane
  o            next pane
  q            show pane numbers (then number = jump)
  arrows       move between panes (or {/} swap with prev/next)
  !            break pane out into its own window
  M-1..5       preset layouts (even-h, even-v, main-h, main-v, tiled)

 WINDOWS
──────────────────────────────────────────────────────────────
  c            new window
  n / p        next / prev window
  l            toggle last window (alt-tab style)
  0-9          switch to window by number
  ,            rename window (name shows in status bar)
  &            kill window
  .            move window to a different index
  w            window picker (tree across sessions)

 SESSIONS
──────────────────────────────────────────────────────────────
  d            detach (keeps everything running)
  $            rename session
  s            session picker
  (  )         prev / next session
  C-f (no pfx) sessionizer popup

 COPY MODE                              enter with M-h or [ 
──────────────────────────────────────────────────────────────
  v            begin selection
  y            yank to system clipboard
  /            search forward
  ?            search backward
  n / N        next / prev match
  q / Esc      exit copy mode

  M-h / M-l    jump word left / right
  M-j / M-k    scroll line down / up
  M-H / M-L    jump to line start / end
  M-J / M-K    half-page down / up

 CLIPBOARD
──────────────────────────────────────────────────────────────
  prefix v     paste from system clipboard

 OTHER
──────────────────────────────────────────────────────────────
  prefix g     fzf search scrollback → load to tmux buffer (paste: prefix+])
  prefix y     yank last command output to clipboard
  prefix r     reload tmux config
  prefix Space this help
  prefix ?     all tmux bindings (built-in)
