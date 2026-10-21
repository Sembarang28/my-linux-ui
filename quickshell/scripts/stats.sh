#!/usr/bin/env bash
# key=value lines consumed by services/Sys.qml
grep '^cpu' /proc/stat | awk '{printf "stat%s=%s\n", ($1=="cpu"?"":$1), $0}' | sed 's/^stat\(cpu[0-9]*\)=/\1=/;s/^stat=/stat=/'
awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}/SwapTotal/{st=$2}/SwapFree/{sf=$2}END{printf "ram=%d\nramused=%.2f\nramtotal=%.2f\nswapused=%.2f\nswaptotal=%.2f\n",(t-a)*100/t,(t-a)/1048576,t/1048576,(st-sf)/1048576,st/1048576}' /proc/meminfo
df -B1 --output=pcent,used,size / | tail -1 | awk '{gsub("%","",$1); printf "disk=%s\ndiskused=%.1f\ndisktotal=%.1f\n",$1,$2/1073741824,$3/1073741824}'
timeout 2 sensors 2>/dev/null | awk '
  /^[a-z]/ && !/:/{chip=$1}
  /Package id 0/{gsub(/[^0-9.]/,"",$4); print "ctemp="$4}
  chip ~ /^spd5118/ && /^temp1/{v=$2; gsub(/[^0-9.]/,"",v); if(v+0>m)m=v+0}
  chip ~ /^nvme/ && /^Composite/{v=$2; gsub(/[^0-9.]/,"",v); if(v+0>d)d=v+0}
  END{if(m)print "rtemp="m; if(d)print "dtemp="d}'
awk '$3 ~ /^(nvme[0-9]+n[0-9]+|sd[a-z]+)$/{r+=$6;w+=$10}END{printf "dio=%d %d\n",r*512,w*512}' /proc/diskstats
awk -F'[: ]+' '/:/ && $2!="lo"{r+=$3;t+=$11}END{printf "net=%d %d\n",r,t}' /proc/net/dev
timeout 3 nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,power.draw,memory.used,memory.total,fan.speed --format=csv,noheader,nounits 2>/dev/null \
  | awk -F', *' '{print "gpu="$1; print "gtemp="$2; print "gpow="$3; print "gvram="$4/1024; print "gvramt="$5/1024; print "gfan="$6}'
echo "vol=$(timeout 2 wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)"
echo "mic=$(timeout 2 wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)"
echo "wifi=$(timeout 2 nmcli radio wifi 2>/dev/null)"
echo "wname=$(timeout 2 nmcli -t -f TYPE,STATE,CONNECTION dev 2>/dev/null | awk -F: '$1=="wifi"&&$2=="connected"{print $3;exit}')"
echo "bt=$(timeout 2 bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2}')"
echo "rf=$(rfkill list -n -o SOFT 2>/dev/null | sort -u | tr '\n' ' ')"
echo "prof=$(timeout 2 busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile 2>/dev/null | cut -d\" -f2)"
echo "cpumhz=$(awk '/cpu MHz/{s+=$4;n++}END{if(n)printf "%d",s/n}' /proc/cpuinfo)"
awk '{s=int($1); d=int(s/86400); h=int(s%86400/3600); m=int(s%3600/60); out=""; if(d>0) out=d"d "; printf "uptime=%s%dh %dm\n", out, h, m}' /proc/uptime
awk '{print "load="$1}' /proc/loadavg
ps -eo pcpu=,rss=,comm= --sort=-pcpu 2>/dev/null | head -6 | awk '{c=$1; r=$2; $1=$2=""; sub(/^ +/,""); printf "proc=%s|%s|%d\n",$0,c,r}'
