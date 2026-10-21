# linux-ui

Konfigurasi desktop Linux pribadi saya: compositor [niri](https://github.com/YaLTeR/niri) dipasangkan dengan shell [Quickshell](https://quickshell.org) bertema **Catppuccin Mocha** ("Mocha Shell"), terinspirasi tampilan macOS.

## Isi repo

| Folder | Fungsi | Target install |
| --- | --- | --- |
| [`niri/`](niri) | Konfigurasi compositor niri (modular, satu file per urusan) | `~/.config/niri` |
| [`quickshell/`](quickshell) | Bar, launcher, panel, notifikasi, OSD, lock screen, wallpaper | `~/.config/quickshell` |

## Fitur

- **niri:** kolom scrolling selebar monitor, aplikasi baru terbuka sebagai kolom di kanan pada workspace yang sama.
- **Bar ala macOS:** menu Arch, menu aplikasi, status sistem, kalender, dan panel cepat.
- **Panel Quickshell:** Launcher (aplikasi, kalkulator, link, pencarian web), Wi-Fi, Bluetooth, Sound, Brightness, Stats, Notifikasi, Power, Kalender, dan Settings.
- **Lock screen** (PAM), **OSD** volume/brightness, **toast**, dan jendela *About This PC* / *Force Quit*.
- **Wallpaper** digambar oleh Quickshell.
- Semua panel bisa dibuka lewat keybind niri melalui IPC Quickshell.

## Struktur

```
linux-ui/
├── niri/
│   ├── config.kdl          # file utama, hanya `include`
│   ├── conf/               # environment, input, output, layout, animations, rules, startup, binds
│   ├── themes/mocha.kdl    # tema aktif (warna, border, shadow, blur)
│   ├── scripts/            # start-shell.sh, shellctl.sh, theme.sh
│   └── assets/wallpaper.jpg
└── quickshell/
    ├── shell.qml           # entry point + IPC
    ├── services/           # Theme, Prefs, Sys, Net, Notifs, SettingsData
    ├── components/         # komponen UI reusable
    ├── modules/            # Bar, Overlay, panels/, LockScreen, Osd, Toasts, dll
    ├── scripts/            # stats.sh, specs.sh
    ├── pam/                # konfigurasi PAM lock screen
    └── assets/             # ikon SVG dan wallpaper
```

## Kebutuhan

- niri 26.04 atau lebih baru (memakai `background-effect` untuk blur)
- Quickshell 0.3 atau lebih baru
- `pipewire` + `wireplumber` (`wpctl`), `networkmanager` (`nmcli`), `bluez` (`bluetoothctl`)
- `power-profiles-daemon`, `playerctl`
- `libqalculate` (`qalc`) dan `wl-clipboard` (`wl-copy`) untuk kalkulator launcher
- `firefox` untuk link dan pencarian web dari launcher
- `ghostty` (terminal) dan `fuzzel` (launcher alternatif)
- `qt6ct` + tema Kvantum untuk aplikasi Qt
- Font: [Quicksand](https://fonts.google.com/specimen/Quicksand) dan JetBrainsMono Nerd Font
- Opsional: `cava` (visualizer), `ddcutil` (brightness monitor via DDC/CI, user harus masuk grup `i2c`), `nvidia-smi` (statistik GPU), `wlsunset` (Night Light), akses `wttr.in` (widget cuaca)

Contoh instalasi di Arch Linux:

```sh
sudo pacman -S niri quickshell pipewire wireplumber networkmanager bluez \
  power-profiles-daemon playerctl libqalculate wl-clipboard firefox \
  ghostty fuzzel qt6ct kvantum ttf-jetbrains-mono-nerd
```

## Instalasi

```sh
git clone https://github.com/<username>/linux-ui.git
cd linux-ui

# cadangkan konfigurasi lama (jika ada)
mv ~/.config/niri ~/.config/niri.bak 2>/dev/null
mv ~/.config/quickshell ~/.config/quickshell.bak 2>/dev/null

# pasang (symlink supaya mudah di-update lewat git pull)
ln -s "$PWD/niri" ~/.config/niri
ln -s "$PWD/quickshell" ~/.config/quickshell

chmod +x ~/.config/niri/scripts/*.sh ~/.config/quickshell/scripts/*.sh
```

Lalu pilih sesi **niri** di layar login (SDDM). Setelah login, niri menjalankan `scripts/start-shell.sh` yang menyalakan Quickshell otomatis.

Sesuaikan sebelum dipakai:

- `niri/conf/output.kdl`: resolusi, scale, dan posisi monitor Anda.
- `niri/conf/input.kdl`: layout keyboard dan pengaturan touchpad/mouse.
- `niri/conf/binds.kdl`: aplikasi default (terminal, dll).

## Keybinding utama

| Tombol | Aksi |
| --- | --- |
| `Mod+T` | Buka Ghostty |
| `Alt+Space` / `Mod+D` | Launcher Quickshell |
| `Mod+Shift+D` | fuzzel |
| `Mod+S` | Panel Settings |
| `Mod+N` | Notifikasi |
| `Mod+Shift+C` | Kalender |
| `Mod+Shift+A` | About This PC |
| `Mod+Shift+Q` | Force Quit |
| `Super+Alt+L` | Kunci layar |
| `Mod+Q` | Tutup jendela |
| `Mod+H` / `Mod+L` | Kolom sebelumnya / berikutnya |
| `Mod+O` | Overview |
| `Mod+Shift+/` | Daftar keybind lengkap dari niri |

Tombol media (volume, brightness, play/pause) sudah terhubung ke OSD Quickshell.

## Kontrol manual (IPC)

```sh
# buka/tutup panel
~/.config/niri/scripts/shellctl.sh toggle <launcher|settings|about|forcequit|lock|wifi|bluetooth|sound|quick|calendar|stats|power|brightness|notifications>

# tampilkan OSD
~/.config/niri/scripts/shellctl.sh osd <volumeUp|volumeDown|volumeMute|brightnessUp|brightnessDown>

# restart Quickshell
~/.config/niri/scripts/start-shell.sh
```

Validasi konfigurasi niri sebelum menyimpan:

```sh
niri validate -c ~/.config/niri/config.kdl
```

## Catatan

- `quickshell/mocha-shell.html` adalah prototipe HTML asli yang menjadi acuan desain shell.
- `quickshell/events.txt` (opsional) berisi agenda untuk bagian "Today" di kalender, satu baris per acara: `HH:MM – HH:MM|Judul`.
- Preferensi Quickshell disimpan di `state.json` (diabaikan git).
- Radius blur tidak bisa diatur di niri 26.04; atur opacity jendela untuk mengontrol seberapa terlihat blurnya.
- Hibernate butuh swap sebesar RAM dan parameter kernel `resume=`.
- `niri/README.md` dan `quickshell/README.md` adalah catatan per bagian; sebagian masih menyebut tema glassmorphism/neobrutalism yang lama.

## Lisensi

Tambahkan file `LICENSE` sesuai pilihan Anda (mis. MIT) sebelum dipublikasikan.
