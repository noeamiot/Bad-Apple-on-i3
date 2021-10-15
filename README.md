# Bad-Apple-on-i3
Bad Apple !! But it's on the i3 tiling windows manager.
[Link to the video](https://www.youtube.com/watch?v=Q4Mng_Xrtvc)

## What's i3 ? what's tiling ?
"i3 is a tiling window manager designed for X11, inspired by wmii and written in C. It supports tiling, stacking, and tabbing layouts, which it handles dynamically." [Wikipedia](https://en.wikipedia.org/wiki/I3_(window_manager))

"A tiling window manager is a window manager with an organization of the screen into mutually non-overlapping frames, as opposed to the more common approach of coordinate-based stacking of overlapping objects (windows) that tries to fully emulate the desktop metaphor." [Wikipedia](https://en.wikipedia.org/wiki/Tiling_window_manager)


## How does it work ?
Each square visible on the screen is an XTerm instance waiting for an order to change it's background & foreground color by tailing constantly a file dedicated to this pixel.

For a resolution of 40x40, a total of 1600 Xterm instances must be running and tailing 1600 files.
The C program then reads the badapple video using ffmpeg and for each pixel writes a control character to a file corresponding to the pixel.

To turn a pixel black, we write `\e]11;rgb:00/00/00\a\e]10;rgb:00/00/00\a` and to turn it white we write `\e]11;rgb:ff/ff/ff\a\e]10;rgb:ff/ff/ff\a`.

The `\e]11;` part is for the background and `\e]10;` one for the foreground.


## Can I reproduce it ?
You can ! But be prepared, there are a few things to know before doing that.
- X Server limits the number of window you can open at once, move the `99-maxclients.conf` file to `/etc/X11/xorg.conf.d/` (or wherever your X server conf is). This allows to open up to 2048 windows at the same time.
- Your default config may be limiting the number of files you can open at the same time (use `ulimit -n` to display the current limit), for a large resolution (like 40*40, sic) you should make it bigger by running `ulimit -n 2048` [This has to be done on the terminal launching i3, the best is to run it before running `startx`]
- Depending on your config, it will take a LARGE amount of time to get the screen prepared (I mean, like, really large). For the 40*40 screen, preparing the layout took 40 minutes and starting all the XTerms took around 2 hours and a half on my laptop. Running the program can then be done in real time (I ran it at 9 fps for the video).

If you still want to continue (and fry your config with 14400 writes/s) this is the way to go :
- Download the badapple video (using [youtube-dl](https://github.com/ytdl-org/youtube-dl/) for example)
- Update `badApple.c` according to your need then compile it `gcc badApple.c`
- Add the `i3config` file content to your i3 config file (and maybe change your config according to theses changes) then reload your i3 configuration
- Create the directory for the files `mkdir fds`
- Create the files (you can set the default color or the coordinates or empty files) ``for i in {0..1599..1}; do echo "$i" >  `pwd`/fds/controlsequences$i.txt; done;``
- Create the i3 layout (the only parameter is the resolution) `./makeLayout.sh 40 > layout`
- Tell i3 to use the layout in the Bad Apple workspace ``i3-msg "workspace Bad Apple; append_layout `pwd`/layout"`` (can take a while)
- Create the pixels by launching a bunch of XTerm ``for i in {0..1599..1}; do xterm -T "badapple$i" -e bash -c "tail -f `pwd`/fds/controlsequences$i.txt" &  done;`` (will take a while)
- Run the compiled C program `./a.out`
- Profit


## Why would anyone want to create a screen made of terminals ?
yes.

## What problems did you face while making this ?
- There are a lot of system limitations on the number of files and windows open, even on a default install.
- When opening windows using the `&` symbol, we have no guarantee that the windows will be started in the right order. With a small amount of windows it's not a problem, we can simply wait between two windows opening but as we can have more than a thousand we had to find a better solution. The solution here is to make titled windows (using the coordinates) and make a i3 layout capturing those numbers so that even if the 1349th window is created rigth after the first one, it will be correctly placed.
- A limitation we still have here is the I/O overhead, 1600 windows reading 1600 files and 1600*9 writes per second is quite a lot. The number of writes is actually less than that because the program now only writes a file if there is an update, but it's still a high number of read/writes each second.
- Some pixels take a while to update and mess up the display, I will look for a solution when I'll have some time !

## Can we add sound directly ?
Yes, I didn't but you can just start ffplay of vlc in the background and play the sound as well.
