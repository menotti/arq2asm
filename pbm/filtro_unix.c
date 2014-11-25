#include <time.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
	clock_t start, end;
	double cpu_time_used;
	char filetype[256], *ptri, *ptro, *img;
	int r, g, b, m;
	int width, height, depth, pixels;
	start = clock();

	fscanf(stdin, "%s\n", filetype);
	fprintf(stdout, "%s\n", filetype);

	fscanf(stdin, "%d %d %d\n", &width, &height, &depth);
	fprintf(stdout, "%d %d %d\n", width, height, depth);

	pixels = width * height;
	ptri = ptro = img = (char *) malloc(pixels * 3);
	
	fread(img, 3, pixels, stdin);
	for (int i = 0; i < pixels; i++) {
		r = (int) *ptri++;
		g = (int) *ptri++;
		b = (int) *ptri++;
		asm("movl %1, %%eax\n"
		    "shll $1, %%eax\n"
		    "addl %0, %%eax\n"
		    "addl %2, %%eax\n"
		    "shrl $2, %%eax\n"
		    "movl %%eax, %3"
		     : "=r"(m)
		     : "r"(r), "r"(g), "r"(b)
		     : "eax");
		//m = (r + (g << 1) + b) >> 2;
		*ptro++ = (char)m;
		*ptro++ = (char)m;
		*ptro++ = (char)m;
	}
	fwrite(img, 3, pixels, stdout);

	free(img);

	end = clock();
	cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
	fprintf(stderr, "tempo = %f segundos\n", cpu_time_used);
	return 0;
}

