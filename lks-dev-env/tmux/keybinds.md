 TMUX KEYBINDS                                   prefix = Alt+E
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 NO PREFIX
──────────────────────────────────────────────────────────────
  M-j          last active pane (MRU toggle)
  M-o          next pane (cycle)
  M-h          enter copy mode
  M-f          thumbs picker (yank text from screen)
  C-f          sessionizer

 PANES                                          prefix then:
──────────────────────────────────────────────────────────────
  "            split down
  %            split right
  z            zoom toggle (fullscreen pane)
  x            kill pane
  o            next pane
  q            show pane numbers

 WINDOWS
──────────────────────────────────────────────────────────────
  c            new window
  n            next window
  p            prev window
  &            kill window
  ,            rename window
  0-9          switch to window by number

 SESSIONS
──────────────────────────────────────────────────────────────
  d            detach
  $            rename session
  s            session picker
  (  )         prev / next session

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
