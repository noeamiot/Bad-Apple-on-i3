# Bad-Apple-on-i3
Bad Apple !! But it's on the i3 tiling windows manager.
[Link to the video](https://www.youtube.com/watch?v=1JkRM9LUueY)

## What's i3 ? what's tiling ?
"i3 is a tiling window manager designed for X11, inspired by wmii and written in C. It supports tiling, stacking, and tabbing layouts, which it handles dynamically." [Wikipedia](https://en.wikipedia.org/wiki/I3_(window_manager))

"A tiling window manager is a window manager with an organization of the screen into mutually non-overlapping frames, as opposed to the more common approach of coordinate-based stacking of overlapping objects (windows) that tries to fully emulate the desktop metaphor." [Wikipedia](https://en.wikipedia.org/wiki/Tiling_window_manager)

## How does it work ?
Each square visible on the screen is an XTerm instance waiting for an order to change it's background & foreground color by tailing constantly a file dedicated to this pixel.

For a resolution of 45x45, a total of 2025 Xterm instances must be running and tailing 2025 files.
The C program then reads the badapple video using ffmpeg and for each pixel writes a control character to the file corresponding to the pixel.

To turn a pixel black, we write `\e]11;rgb:00/00/00\a\e]10;rgb:00/00/00\a` and to turn it white we write `\e]11;rgb:ff/ff/ff\a\e]10;rgb:ff/ff/ff\a`.

The `\e]11;` part is for the background and `\e]10;` one for the foreground.

## Can I reproduce it ?
You can ! But be prepared, there are a few things to know before doing that.
- X Server limits the number of window you can open at once, move the `99-maxclients.conf` file to `/etc/X11/xorg.conf.d/` (or wherever your X server conf is). This allows to open up to 2048 windows at the same time.
- Your default config may be limiting the number of files you can open at the same time (use `ulimit -n` to display the current limit), for a large resolution (like 45*45, yes ...) you should make it higher by running `ulimit -n 2048` [This has to be done on the terminal launching i3, the best is to run it before running `startx`]
- Depending on your config, it will take a LARGE amount of time to get the screen prepared (I mean, like, really large). For the 45*45 screen, preparing the layout took an hour and a half and starting all the XTerms took around 4 hours and a half on my laptop. Running the program can then be done in real time.

If you still want to continue (and fry your computer with 10000+ writes/s) this is the way to go :
- Download the badapple video (using [youtube-dl](https://github.com/ytdl-org/youtube-dl/) for example)
- Update `badApple.c` according to your need then compile it `gcc badApple.c`
- Add the `i3config` file content to your i3 config file (and maybe change your config according to theses changes) then reload your i3 configuration
- Create the directory for the files `mkdir fds` (you can mount a tmpfs here even though the IO is bufferized so it should not change the performances that much)
- Create the files (you can set the default color or the coordinates or empty files) ``for i in {0..899..1}; do echo "$i" >  `pwd`/fds/controlsequences$i.txt; done;``
- Create the i3 layout (the only parameter is the resolution) `./makeLayout.sh 30 > layout`
- Tell i3 to use the layout in the Bad Apple workspace ``i3-msg "workspace Bad Apple; append_layout `pwd`/layout"`` (can take a while)
- Create the pixels by launching a bunch of XTerm ``for i in {0..899..1}; do xterm -T "badapple$i" -e bash -c "tail -f `pwd`/fds/controlsequences$i.txt" &  done;`` (will take a while)
- Run the compiled C program `./a.out` (I recommand doing it on the side terminals to see everything from the beginning)
- Profit

## Why would anyone want to create an unoptimized screen made out of terminals ?
yes.

## What problems did you face while making this ?
- There are a lot of system limitations on the number of files and windows open, even on a default install.
- When opening windows using the `&` symbol, we have no guarantee that the windows will be started in the right order. With a small amount of windows it's not a problem, we can simply wait between two windows opening but as we can have more than a thousand we had to find a better solution. The solution here is to make titled windows (using the coordinates) and make a i3 layout capturing those numbers so that even if the 1349th window is created rigth after the first one, it will be correctly placed.
- A limitation we still have here is the I/O overuse, 2025 windows reading 2025 files and 2025*30 (60750) writes per second is quite a lot. The number of writes is actually less than that because the program now only writes a file if there is an update, but it's still a high number of read/writes each second.
- Some pixels take a while to update and mess up the display when the resolutions is high but there's not much to do here.
- The maximum resolution is 45x45 because the X11 server will not allow to move the limit above 2048.

## Can we add sound directly ?
Yes, just uncomment the systems lines in the C program and ffplay will play the sound in the background. I added this option later so the video isn't recoded with that option but the result is almost the same.
