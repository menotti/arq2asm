#include <time.h>
#include <stdio.h>

int main() {
	clock_t start, end;
	double cpu_time_used;
	char filetype[256], *ptri, *ptro, *img;
	int r, g, b, m, i;
	int width, height, depth, pixels;

	fscanf(stdin, "%s\n", filetype);
	fprintf(stdout, "%s\n", filetype);

	fscanf(stdin, "%d %d %d\n", &width, &height, &depth);
	fprintf(stdout, "%d %d %d\n", width, height, depth);

	pixels = width * height;
	ptri = ptro = img = (char *) malloc(pixels * 3);
	
	fread(img, 3, pixels, stdin);

	start = clock();
	for (i = 0; i < pixels; i++) {
		r = (int) *ptri++;
		g = (int) *ptri++;
		b = (int) *ptri++;
		__asm {
			mov eax, g
			shl eax, 1
			add eax, r
			add eax, b
			shr eax, 2
			mov m, eax
		}
		//m = (r + (g << 1) + b) >> 2;
		*ptro++ = (char)m;
		*ptro++ = (char)m;
		*ptro++ = (char)m;
	}
	end = clock();

	fwrite(img, 3, pixels, stdout);

	free(img);

	cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
	fprintf(stderr, "tempo = %f segundos\n", cpu_time_used);
	return 0;
}

