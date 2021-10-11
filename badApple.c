// Derived from Ted Burke's work, you may have to update some values such as video path, resolution and/or the framerate
#include <stdio.h>

int main(int argc, char *argv[]) {
	int heigth = 40;
	int width = 40;
	unsigned char frame[40][40][3] = {0};
	unsigned int prevframe[40][40] = {2};
	unsigned int n = 0;

	int x, y, count;

	// Open an input pipe from ffmpeg -re
	FILE *pipein = popen("ffmpeg -re -i Bad_Apple-FtutLA63Cp8-nosound.mp4 -vf 'scale=40:40,mpdecimate,setpts=0.20*PTS' -f image2pipe -vcodec rawvideo  -pix_fmt rgb24 -", "r");

	FILE* fds[heigth*width];
	for(int i = 0; i < heigth*width; i++) {
		char name[50];
		sprintf(name, "fds/controlsequences%d.txt", i);
		fds[i] = fopen(name, "w");
	}


	// Process video frames
	while(1) {
		// Read a frame from the input pipe into the buffer
		count = fread(frame, 1, heigth * width * 3, pipein);

		// If we didn't get a frame of video, we're probably at the end
		if (count != heigth * width * 3) break;

		// Process this frame
		for (x = 0 ; x < heigth ; ++x) {
			for (y = 0 ; y < width ; ++y) {
				// If this pixel was the same on the previous frame, do not update it (limit IO cost)
				if ((frame[y][x][0] > 127 && prevframe[y][x] == 1) || (frame[y][x][0] <= 127 && prevframe[y][x] == 0))
					continue;

				if (frame[y][x][0] > 127)
					fputs("\e]11;rgb:ff/ff/ff\a\e]10;rgb:ff/ff/ff\a\n", fds[x*heigth+y]);
				else
					fputs("\e]11;rgb:00/00/00\a\e]10;rgb:00/00/00\a\n", fds[x*heigth+y]);

				// Save this pixel & flush the file
				prevframe[y][x] = frame[y][x][0] > 127;
				fflush(fds[x*heigth+y]);
			}
		}
	}

	// Close all files
	for(int i = 0; i < heigth*width; i++) {
		fclose(fds[i]);
	}
	fflush(pipein);
	pclose(pipein);
}
