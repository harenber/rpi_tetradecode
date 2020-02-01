export DISPLAY=:20
export USER=root
Xvfb :20 -screen 0 1800x1000x16 &
sleep 1
x0vncserver  -SecurityTypes=VncAuth -PasswordFile=/root/.vnc/passwd -rfbport=5920 &
sleep 1
openbox-session &
sleep 1
cd ~/tetra/osmo-tetra-sq5bpf/src
xterm -e ./receiver1 1 &
cd ~/tetra/telive/
xterm  -font fixed -bg black -fg white -geometry 203x60 -e ./rxx &
cd /tetra/bin/
./tetrad &
cd ~/tetra/telive/gnuradio-companion
gnuradio-companion receiver_pipe/telive_1ch_simple_gr37_th.grc
