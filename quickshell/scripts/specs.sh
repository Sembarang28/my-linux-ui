#!/usr/bin/env bash
# fastfetch-like rows for About This PC (key=value)
. /etc/os-release
echo "OS=$NAME $(uname -m)"
echo "Host=$(cat /sys/devices/virtual/dmi/id/board_name 2>/dev/null || hostname)"
echo "Kernel=$(uname -sr)"
echo "Packages=$(pacman -Qq 2>/dev/null | wc -l) (pacman)"
echo "Shell=$(basename "$(getent passwd "$(id -un)" | cut -d: -f7)") $(${SHELL:-fish} --version 2>/dev/null | grep -o '[0-9][0-9.]*' | head -1)"
niri msg --json outputs 2>/dev/null | python3 -c 'import json,sys
d=json.load(sys.stdin)
for k,o in d.items():
  m=o["modes"][o["current_mode"]]; print("Display=%s %dx%d @ %d Hz" % (o["model"], m["width"], m["height"], round(m["refresh_rate"]/1000))); break' 2>/dev/null
echo "WM=niri $(niri --version 2>/dev/null | awk '{print $2}') (Wayland)"
echo "Terminal=ghostty $(ghostty --version 2>/dev/null | awk '/^Ghostty/{print $2}')"
echo "CPU=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed -E 's/\(R\)|\(TM\)|CPU|Processor| @.*//g; s/ +/ /g; s/^ //; s/ $//') ($(nproc) threads)"
echo "GPU=$(timeout 3 nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)"
free -b | awk '/Mem:/{printf "Memory=%.2f GiB / %.2f GiB (%d%%)\n",$3/1073741824,$2/1073741824,$3*100/$2} /Swap:/{printf "Swap=%.2f GiB / %.2f GiB\n",$3/1073741824,$2/1073741824}'
df -B1 --output=used,size,pcent,fstype / | tail -1 | awk '{gsub("%","",$3); printf "Disk (/)=%.2f GiB / %.2f GiB (%s%%) - %s\n",$1/1073741824,$2/1073741824,$3,$4}'
echo "Locale=${LANG:-en_US.UTF-8}"
echo "_host=$(hostname)"
