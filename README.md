# Bad-Apple-on-i3
Bad Apple !! But it's on the i3 tiling windows manager.

Commands:
gcc badApple.c
mkdir fds
./mkws.sh 40 > workspace
i3-msg "workspace Bad Apple; append_layout `pwd`/workspace"
for i in {0..1599..1}; do echo "$i" >  `pwd`/fds/controlsequences$i.txt; done;
for i in {0..1599..1}; do xterm -T "badapple$i" -e bash -c "tail -f `pwd`/fds/controlsequences$i.txt" &  done;
./a.out
