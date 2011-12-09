// Grupo 16

#include "stdafx.h"
#include "Webcam.h"

CvCapture * CWebcam::capture = NULL;

void CWebcam::Capture(CSurface * surf)
{
	IplImage * frame = NULL;
	CImage img;

	// inicializa a webcam
	capture = cvCaptureFromCAM(0);

	// checa se a captura foi inicializada
	if ( !capture ) {
		fprintf( stderr, "Nao foi possivel abrir a webcam!\n" );
		return;
	}

	//Pega um frame
	frame = cvQueryFrame( capture );

	// checa se o frame foi capturado
	if (frame)
	{
		// Pega informações de altura, largura e bytes por pixel da imagem
		int imgHeight = -(surf->GetImage()->GetHeight());
		int imgWidth = surf->GetImage()->GetWidth();
		int imgBPP = surf->GetImage()->GetBPP();

		// Cria a imagem no formato CImage
		img.Create(imgWidth, imgHeight, imgBPP);

		// Jeito lerdão, mas garantido que funciona

		int r, g, b;
		int coluna = 0, linha = -1;

		// Copia pixel por pixel da imagem da captura para img
		for (int i = 0; i < frame->width * frame->height * frame->nChannels; i += frame->nChannels) 
		{
			b = frame->imageData[i];
			g = frame->imageData[i + 1];
			r = frame->imageData[i + 2];

			if (i % (frame->width * frame->nChannels) == 0) {
				coluna = 0;
				++linha;
			} else
				++coluna;

			// Powered by POG
			if (coluna < imgWidth && linha < -imgHeight) {
				COLORREF corRGB = RGB(r,g,b);
				img.SetPixel(coluna, linha, corRGB);
			}
		}

		// Copia img para a surface
		surf->Copy(img);
	}
}


void CWebcam::Release()
{
	// Libera a memória
	cvReleaseCapture(&capture);
}