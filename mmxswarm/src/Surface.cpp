// Surface.cpp : implementation of the CSurface class
//
// This is a part of the Microsoft Foundation Classes C++ library.
// Copyright (c) Microsoft Corporation.  All rights reserved.
//
// This source code is only intended as a supplement to the
// Microsoft Foundation Classes Reference and related
// electronic documentation provided with the library.
// See these sources for detailed information regarding the
// Microsoft Foundation Classes product.
//
#include "stdafx.h"
#include "Surface.h"

void CSurface::Create(CWnd *pWnd, int nBitDepth)
{
	// no palettes
	ASSERT(nBitDepth == 24 || nBitDepth == 16 || nBitDepth == 32);

	CRect clientRect;
	pWnd->GetClientRect(clientRect);
	int height = clientRect.Height();
	int width = clientRect.Width();

	if (!height || !width)
		return;

	Destroy();

	m_nBitDepth = nBitDepth;
	m_nByteDepth = nBitDepth/8;
	m_wndHeight = height;
	m_wndWidth = width;
	m_hDestDC = ::GetDC(pWnd->GetSafeHwnd());
	m_pSrcWnd = pWnd;
	ASSERT(m_hDestDC);

	width = m_wndWidth + m_kDeltaX; // not *2 because we don't need it on the left side.
	// Allow derived classes a shot at updating if they need more alignment
	AdjustWidth(&width);

	// pass Negative Height to make it Top Down.
	VERIFY(m_image.Create(width, -(m_wndHeight + m_kDeltaY*2), m_nBitDepth, 0));
	VERIFY(n_image.Create(width, -(m_wndHeight + m_kDeltaY*2), m_nBitDepth, 0));
	VERIFY(o_image.Create(width, -(m_wndHeight + m_kDeltaY*2), m_nBitDepth, 0));
	VERIFY(t_image.Create(width, -(m_wndHeight + m_kDeltaY*2), m_nBitDepth, 0));//Grupo5
	ASSERT((DWORD_PTR(m_image.GetBits()) & 0xf) == 0); // make sure we are at least 128 bit aligned.(SSE2)
	ASSERT((DWORD_PTR(n_image.GetBits()) & 0xf) == 0); // make sure we are at least 128 bit aligned.(SSE2)
	ASSERT((DWORD_PTR(o_image.GetBits()) & 0xf) == 0); // make sure we are at least 128 bit aligned.(SSE2)
	ASSERT((DWORD_PTR(t_image.GetBits()) & 0xf) == 0); // //Grupo5 - make sure we are at least 128 bit aligned.(SSE2)
	ASSERT(m_image.GetPitch() > 0); // Verify top down DIB
	ASSERT(n_image.GetPitch() > 0); // Verify top down DIB
	ASSERT(o_image.GetPitch() > 0); // Verify top down DIB
	ASSERT(t_image.GetPitch() > 0); //Grupo5 - Verify top down DIB
	VERIFY(m_image.GetDC() != NULL); // Prefer the DC to exist for life of object
	VERIFY(n_image.GetDC() != NULL); // Prefer the DC to exist for life of object
	VERIFY(o_image.GetDC() != NULL); // Prefer the DC to exist for life of object
	VERIFY(t_image.GetDC() != NULL); // Grupo5 - Prefer the DC to exist for life of object
	OnCreated();

	//Posterize inicializacao
	setNivel(6);
	inicializar();
}

void CSurface::Destroy()
{ 
	if (IsNull())
		return;

	m_image.ReleaseDC();
	m_image.Destroy(); 
	::ReleaseDC(m_pSrcWnd->GetSafeHwnd(), m_hDestDC);
	n_image.ReleaseDC();
	n_image.Destroy(); 
	::ReleaseDC(m_pSrcWnd->GetSafeHwnd(), n_hDestDC);
	o_image.ReleaseDC();
	o_image.Destroy(); 
	::ReleaseDC(m_pSrcWnd->GetSafeHwnd(), o_hDestDC);

	//Grupo5
	t_image.ReleaseDC();
	t_image.Destroy(); 
	::ReleaseDC(m_pSrcWnd->GetSafeHwnd(), t_hDestDC);

	m_wndHeight = 0;
	m_wndWidth = 0;
}

void CSurface::Import(const CImage &image, const CImage &image2)
{
	image2.BitBlt(m_image.GetDC(), 0, m_kDeltaY, GetVisibleWidth(), GetVisibleHeight(), 0, 0);
	m_image.ReleaseDC();
	image2.BitBlt(n_image.GetDC(), 0, m_kDeltaY, GetVisibleWidth(), GetVisibleHeight(), 0, 0);
	n_image.ReleaseDC();
	image.BitBlt(o_image.GetDC(), 0, m_kDeltaY, GetVisibleWidth(), GetVisibleHeight(), 0, 0);
	o_image.ReleaseDC();
	BlitBits();
}
void CSurface::ImportStatic(const CImage &image)  //import para abrir 1 unica imagem
{
    image.BitBlt(o_image.GetDC(), 0, m_kDeltaY, GetVisibleWidth(), GetVisibleHeight(), 0, 0);
    o_image.ReleaseDC();
    BlitBits();
}

void CSurface::ClearBits()
{
	int size = m_image.GetPitch() * m_image.GetHeight();
	memset(m_image.GetBits(), 0x00, size);
}

void CSurface::StripeBits()
{
	int count = 0x880000;
	for (int i = 0; i < m_wndHeight; i++) {
		COLORREF color = count++; // RAND();
		for (int j = 0; j < m_wndWidth; j++) {
			PointColor(j, i, color);
		}
	}

}

//Grupo5 - Função para fazer cópia de uma imagem
void CSurface::Copy(const CImage &image){
	image.BitBlt(m_image.GetDC(), 0, m_kDeltaY, 
		GetVisibleWidth(), GetVisibleHeight(), 0, 0);
	m_image.ReleaseDC();
}

void CSurface::RandomBits()
{
	for (int i = 0; i < m_wndHeight; i++) {
		for (int j = 0; j < m_wndWidth; j++) {
			PointColor(j, i, RGB(Random(), Random(), Random()));
		}
	}
}

void CSurface::ShiftBits()
{
	BYTE *pBits = (BYTE*)m_image.GetBits();
	int nPitch = GetPitch();
	for (int i = 0; i < m_wndHeight; i++) {
		memcpy_s(pBits, nPitch, pBits+nPitch, nPitch);
		pBits += nPitch;
	}
}

void CSurface::BlurBits()
{
	COLORREF cLeft = 0, cCur = PointColor(0,0), cRight, cUp, cDown;
	BYTE r, g, b;
	for (int i = 0; i < m_wndHeight; i++) {
		cLeft = 0;
		for (int j = 0; j < m_wndWidth; j++) {
			cRight = PointColor(j+1, i);
			cUp = PointColor(j, i-1);
			cDown = PointColor(j, i+1);
			r = (BYTE)(((int)(GetRValue(cCur) << 2) + GetRValue(cLeft) + GetRValue(cRight) + GetRValue(cUp) + GetRValue(cDown)) >> 3);
			g = (BYTE)(((int)(GetGValue(cCur) << 2) + GetGValue(cLeft) + GetGValue(cRight) + GetGValue(cUp) + GetGValue(cDown)) >> 3);
			b = (BYTE)(((int)(GetBValue(cCur) << 2) + GetBValue(cLeft) + GetBValue(cRight) + GetBValue(cUp) + GetBValue(cDown)) >> 3);
			PointColor(j, i, RGB(b,g,r)); // RGBs are physically inverted
			cLeft = cCur;
			cCur = cRight;
		}
	}
}

//menotti
void CSurface::FadeInOut()
{
	COLORREF cD, cO;
	BYTE r, g, b;
	if (alphadir > 0) {
		alpha = (float)(alpha + 0.005);
		if (alpha >= 1)
			alphadir = -1;
	}
	else {
		alpha = (float)(alpha - 0.005);
		if (alpha <= 0)
			alphadir = 1;
	}
	for (int i = 0; i < m_wndHeight; i++) {
		for (int j = 0; j < m_wndWidth; j++) {
			cD = PointColorD(j,i);
			cO = PointColorO(j,i);
			r = (BYTE)((GetRValue(cO)*alpha+GetRValue(cD)*(1.0-alpha)));
			g = (BYTE)((GetGValue(cO)*alpha+GetGValue(cD)*(1.0-alpha)));
			b = (BYTE)((GetBValue(cO)*alpha+GetBValue(cD)*(1.0-alpha)));
			PointColor(j, i, RGB(b,g,r)); // RGBs are physically inverted
		}
	}
}


//Grupo 4
void CSurface::GrayScale()
{
	COLORREF cCur;		//declara um dword
	BYTE r, g, b;		//variáveis tipo byte que receberão os valores RGB

	//realiza um loop dentro do outro para percorrer a tela inteira
	for (int i = 0; i < m_wndHeight; i++) {
		for (int j = 0; j < m_wndWidth; j++) {
			cCur = PointColor(j,i);		//pega um pixel da tela da posição [i,j]
			r = (BYTE)((GetRValue(cCur)+GetGValue(cCur)+GetBValue(cCur))/3);	//realiza média entre valores RGB e atualiza valor R
			g = r;	//atualiza valor de G com média ja calculada em R
			b = r;	//atualiza valor de B com média ja calculada em R
			PointColor(j,i,RGB(b,g,r));		//reescreve na tela o pixel do valores RGB modificados na posição [i,j]
		}
	}
}

//grupo 8
void CSurface::Gradient()
{
	COLORREF cCur;		//declara um dword
	BYTE r, g, b;		//variáveis tipo byte que receberão os valores RGB

	//realiza um loop dentro do outro para percorrer a tela inteira
	for (int i = 0; i < m_wndHeight; i++) {
		for (int j = 0; j < m_wndWidth; j++) {
			cCur = PointColor(j,i);		//pega um pixel da tela da posição [i,j]	
			
			r = ((BYTE)(GetRValue(cCur)) + (BYTE)i/2) > 255 ? 255 :((BYTE)(GetRValue(cCur)) + (BYTE)i/2);
			g = ((BYTE)(GetGValue(cCur)) + (BYTE)i/2) > 255 ? 255 :((BYTE)(GetGValue(cCur)) + (BYTE)i/2);
			b = ((BYTE)(GetBValue(cCur)) + (BYTE)i/2) > 255 ? 255 :((BYTE)(GetBValue(cCur)) + (BYTE)i/2);

			PointColor(j,i,RGB(b,g,r));		//reescreve na tela o pixel do valores RGB modificados na posição [i,j]
		}
	}
}

//Grupo5
void CSurface::Sobel()
{
	COLORREF cCur;

	sumX = 0;
	sumY = 0;
	SUM = 0;

	//Percorre toda imagem
	for (y = 0; y < m_wndHeight; y++) {
		for (x = 0; x <m_wndWidth; x++) {
			sumX = 0;
			sumY = 0;

			//Se for boada, atribui o valor 0(preto)
			if((y==0) || (y == (m_wndHeight - 1)) || (x==0) || (x == (m_wndWidth - 1)))
				SUM = 0;
			else{
				for(I=-1; I<=1; I++){
					for(J=-1; J<=1; J++){
						piX = J + x;
						piY = I + y;

						//Pega o valor da imagem corrente
						cCur = PointColor(piX,piY);

						r = GetRValue(cCur);
						g = GetGValue(cCur);
						b = GetBValue(cCur);

						NC = (r+g+b)/3;

						sumX = sumX + (NC) * GXS[J+1][I+1];
						sumY = sumY + (NC) * GYS[J+1][I+1];
					}
				}

				SUM = abs(sumX) + abs(sumY);
			}

			if(SUM>255) SUM=255;
			if(SUM<0) SUM=0;
			newPixel = ((unsigned char)(SUM));

			PointColorT(x,y,RGB(newPixel,newPixel,newPixel));
		}
	}

	//Quando terminar, copia o resultado para a imagem corrente
	Copy(t_image);
}

void CSurface::Azular()
{
	// Azular
	COLORREF cCur;
	

	//Percorre toda imagem
    for (int y = 0; y < m_wndHeight; y++) {
        for (int x = 0; x < m_wndWidth; x++) {
			cCur = PointColorD(x,y);
			int R = GetRValue(cCur);
			int G = GetGValue(cCur);
			int B = GetBValue(cCur);
			int NC = (R+G+B)/3;
			COLORREF newPixCol =  RGB(0,0,NC);
			PointColorT(x,y,newPixCol);
		}
     
    }

	//Quando terminar, copia o resultado para a imagem corrente
	Copy(t_image);
}

void CSurface::Esverdear()
{
	// Azular
	COLORREF cCur;
	

	//Percorre toda imagem
    for (int y = 0; y < m_wndHeight; y++) {
        for (int x = 0; x < m_wndWidth; x++) {
			cCur = PointColorD(x,y);
			int R = GetRValue(cCur);
			int G = GetGValue(cCur);
			int B = GetBValue(cCur);
			int NC = (R+G+B)/3;
			COLORREF newPixCol =  RGB(0,NC,0);
			PointColorT(x,y,newPixCol);
		}
     
    }

	//Quando terminar, copia o resultado para a imagem corrente
	Copy(t_image);
}

void CSurface::Envermelhar()
{
	// Azular
	COLORREF cCur;
	

	//Percorre toda imagem
    for (int y = 0; y < m_wndHeight; y++) {
        for (int x = 0; x < m_wndWidth; x++) {
			cCur = PointColorD(x,y);
			int R = GetRValue(cCur);
			int G = GetGValue(cCur);
			int B = GetBValue(cCur);
			int NC = (R+G+B)/3;
			COLORREF newPixCol =  RGB(NC,0,0);
			PointColorT(x,y,newPixCol);
		}
     
    }

	//Quando terminar, copia o resultado para a imagem corrente
	Copy(t_image);
}

//Grupo 12
void CSurface::GrayFilter()
{
	COLORREF cCur;		//declara um dword
	BYTE r, g, b;		//variáveis tipo byte que receberão os valores RGB


	//realiza um loop dentro do outro para percorrer a tela inteira
	for (int i = 0; i < m_wndHeight; i++) {
		for (int j = 0; j < m_wndWidth; j++) {
			cCur = PointColor(j,i);					//pega o pixel de posição [i,j] na tela
			r = (BYTE)((GetRValue(cCur)+255)/2);	//realiza média do canal R com o branco e atualiza
			g = (BYTE)((GetGValue(cCur)+255)/2);	//realiza média do canal G com o branco e atualiza
			b = (BYTE)((GetBValue(cCur)+255)/2);	//realiza média do canal B com o branco e atualiza
			PointColor(j,i,RGB(b,g,r));				//reescreve na tela o pixel do valores RGB modificados na posição [i,j]
		}
	}
}

//Grupo 14
void CSurface::RGBAdjust()
{
	COLORREF cCur;		
	BYTE r, g, b;		//Variáveis que receberão os valores RGB

	//Loop para acessar todos os pixels da imagem
	for (int i = 0; i < m_wndHeight; i++) {
		for (int j = 0; j < m_wndWidth; j++) {
			cCur = PointColor(j,i);		//pega um pixel da tela da posição [i,j]
			b = (BYTE)(GetRValue(cCur)/4);	//divide o valor do canal B por 4
			g = (BYTE)(GetGValue(cCur)/2);	//divide o valor do canal G por 2
			r = (BYTE)(GetBValue(cCur)/1);	//divide o valor do canal R por 1
			PointColor(j,i,RGB(r,g,b));		//reescreve na tela o pixel com os valores RGB modificados na posição [i,j]
		}
	}
}

//Grupo 15
void CSurface::Mask()
{
	//COLORREF mascara = RGB(0,256,256);
	DWORD mascara = 0xff00ffff;

	//COLORREF guarda a cor em RGB como 0x00bbggrr
	COLORREF cor;


	for (int i = 0; i < m_wndHeight; i++) {
		for (int j = 0; j < m_wndWidth; j++) {
			cor = PointColor(j,i) & mascara;

			//Deixa na forma 0x00rrggbb para usar o PointColor
			cor = (cor & 0xff) << 16 | ((cor >> 8) & 0xff) << 8 | (cor >> 16) & 0xff;

			PointColor(j,i,cor);
		}
	}
}

//Grupo 6
//Função que gera o Mandelbrot
int CSurface::CAL_PIXEL(Complex c)
{
	int count, max;
	Complex z;
	float temp, lengthsq;
	max = 256;
	z.real = 0;
	z.imag = 0;
	count = 0;
	//Equação do Mandelbrot
	do
	{
		temp = z.real * z.real - z.imag * z.imag + c.real;
		z.imag = 2 * z.real * z.imag + c.imag;
		z.real = temp;
		lengthsq = z.real * z.real + z.imag * z.imag;
		count++;
	}
	while((lengthsq < 4.0) && (count < max));
	return count;
}

void CSurface::MandelBrot()
{
	BYTE r,g,b;
	Complex c1;
	float real_min = -2, real_max = 2; //Variáveis para o tamanho max e min da parte real
	float imag_min = -2, imag_max = 2; //Variáveis para o tamanho max e min da parte imaginária
	int disp_width = m_wndWidth, disp_heigth = m_wndHeight; //Tamanho da tela
	int x,y;
	int color1;

	for(x = 0; x < disp_width; x++)
	{
		for(y = 0; y < disp_heigth; y++)
		{
			//Calcula o valor do número complexo c para que caiba na tela
			c1.real = real_min + ((float) x * ((real_max - real_min)/disp_width));
			c1.imag = imag_min + ((float) y * ((imag_max - imag_min)/disp_heigth));
			//Função CAL_PIXEL gera o formato do Mandelbrot, em função da cor.
			color1 = CAL_PIXEL(c1);
			r = (BYTE)(0);
			g = (BYTE)(0); 
			b = (BYTE)(color1);
			PointColor(x,y,RGB(b,g,r));
		}
	}
}

// nothing beats good old fashioned Bresenham
void CSurface::Line(const CPoint &p1, const CPoint &p2, COLORREF c)
{
	int x1 = p1.x;
	int x2 = p2.x;
	int y1 = p1.y;
	int y2 = p2.y;

	int d, deltax, deltay, numpixels,
		dinc1, dinc2,
		xinc1, xinc2,
		yinc1, yinc2;

	// Calculate deltax and deltay for startup
	deltax = ABS(x2 - x1);
	deltay = ABS(y2 - y1);

	// Initialize all vars based on which is the independent variable
	if (deltax >= deltay) {
		// x is independent variable
		numpixels = deltax + 1;
		dinc1 = deltay << 1;
		dinc2 = (deltay - deltax) << 1;
		d = dinc1 - deltax;
		xinc1 = xinc2 = yinc2 = 1;
		yinc1 = 0;
	}
	else {
		// y is independent variable
		numpixels = deltay + 1;
		dinc1 = deltax <<  1;
		dinc2 = (deltax - deltay) << 1;
		d = dinc1 - deltay;
		xinc1 = 0;
		xinc2 = yinc1 = yinc2 = 1;
	}

	// Make sure x and y move in the right directions
	if (x1 > x2) {
		xinc1 = -xinc1;
		xinc2 = -xinc2;
	}
	if (y1 > y2) {
		yinc1 = -yinc1;
		yinc2 = -yinc2;
	}

	// Start drawing pixels at [x1, y1]
	for (int i = numpixels; i > 0; i--) {
		PointColor(x1, y1, c);
		if (d < 0) {
			d += dinc1;
			x1 += xinc1;
			y1 += yinc1;
		}
		else {
			d += dinc2;
			x1 += xinc2;
			y1 += yinc2;
		}
	}
}

void CSurface::RandomLine(COLORREF c)
{
	CPoint p1(Random(m_wndWidth), Random(m_wndHeight));
	CPoint p2(Random(m_wndWidth), Random(m_wndHeight));
	Line(p1, p2, c);
}

void CSurface::BlitBits()
{
	ASSERT(m_wndHeight && m_wndWidth);
     BOOL bStat = m_image.BitBlt(m_hDestDC, 0, 0, 
     m_wndWidth, m_wndHeight, 0, m_kDeltaY);

	ASSERT(bStat);
}

// GRUPO 9 - Filtro Posterize
void CSurface::Posterize()
{
	if (!inicializado) {
		inicializar();
		inicializado = true;
	}
	COLORREF cCur = PointColor(0,0);
	BYTE r, g, b;
	for (int i = 0; i < m_wndHeight; i++) {
		for (int j = 0; j < m_wndWidth; j++) {
			cCur = PointColor(j,i);
			//r = (BYTE)((int)GetRValue(cCur)/2);
			//g = (BYTE)((int)GetGValue(cCur)/2);
			//b = (BYTE)((int)GetBValue(cCur)/2);

			//r = (BYTE)(nivel[(int)GetRValue(cCur)]);
			//g = (BYTE)(nivel[(int)GetGValue(cCur)]);
			//b = (BYTE)(nivel[(int)GetBValue(cCur)]);

			r = (BYTE)( (int)GetRValue(cCur) & 0xC0 );
			g = (BYTE)( (int)GetGValue(cCur) & 0xC0 );
			b = (BYTE)( (int)GetBValue(cCur) & 0xC0 );

			PointColor(j, i, RGB(b,g,r)); // RGBs are physically inverted
		}
	}
}

void CSurface::setNivel(int n)
{
	if(n>0){
		numNivel=n;
		inicializado = false;
	}
}
int CSurface::getNivel()
{
	return numNivel;
}
void CSurface::inicializar()
{
	if (numNivel != 1)
		for (int i = 0; i < 256; i++)
			nivel[i] = 255 * (numNivel*i / 256) / (numNivel-1);
}

// GRUPO 18 - Filtro Solarize
void CSurface::Solarize() {
	// Função antiga - Naive normal
	COLORREF cCur = PointColor(0,0);
    BYTE r, g, b;
	//double rgb, a, b, c;
    for (int i = 0; i < m_wndHeight; i++) {
        for (int j = 0; j < m_wndWidth; j++) {
			cCur = PointColor(j,i);
            r = Sol(GetRValue(cCur));
            g = Sol(GetGValue(cCur));
            b = Sol(GetBValue(cCur));
/*            r = (BYTE)(Sol(GetRValue(cCur)/255.0)*0xFF);
            g = (BYTE)(Sol(GetGValue(cCur)/255.0)*0xFF);
            b = (BYTE)(Sol(GetBValue(cCur)/255.0)*0xFF);
*/			//rgb = GetRValue(cCur) + GetGValue(cCur) + GetBValue(cCur);
			//Sol(rgb);
            PointColor(j, i, RGB(b,g,r)); // RGBs are physically inverted
        }
    }
}
/*	// Função nova - Naive melhorada com Assembly
	DWORD *pCur = (DWORD *)GetPixelAddress(0,0);
	for (int i = 0; i < m_wndHeight; i++) {
        for (int j = 0; j < m_wndWidth; j++) {
			// Inline assembly
			__asm {
				mov ecx, 3			// Move 3 para fazer loop nos 3 canais, RGB
				mov esi, pCur
			SOLARIZANDO:
				mov al, BYTE ptr [esi]
				sub al, 80h			// Subtrai o canal por 128 e modifica o flag de sinal (ou não)
				jns POSITIVO		// Se for positivo, pula
				neg al				// Senão, faz complemento de 2
				inc al
			POSITIVO:
				add al, al			// Dobra o valor
				mov [esi], al
				inc esi
				loop SOLARIZANDO
			}
			pCur++;
		}
	}
}

// Função utilizada pela função antiga do Solarize
/*double CSurface::Sol(double v) {
	return (v > 0.5) ? (2*(v-0.5)) : (2*(0.5-v));
}*/
byte CSurface::Sol(byte v) {
	return (v > 128) ? (2*((byte)(v-128))) : (2*((byte)(128-v)));
}

// GRUPO 18 - Filtro Mirror
void CSurface::Mirror() {	
	COLORREF cCur = PointColor(0,0);
    BYTE r1, g1, b1, r2, g2, b2;
	int wid = m_wndWidth-1;

    for (int i = 0; i < m_wndHeight; i++) {
        for (int j = 0; j < wid/2; j++) {
			cCur = PointColor(j,i);
            r1 = (BYTE)(GetRValue(cCur));
            g1 = (BYTE)(GetGValue(cCur));
            b1 = (BYTE)(GetBValue(cCur));
			cCur = PointColor(wid-j,i);
            r2 = (BYTE)(GetRValue(cCur));
            g2 = (BYTE)(GetGValue(cCur));
            b2 = (BYTE)(GetBValue(cCur));
            PointColor(j, i, RGB(b2,g2,r2)); // RGBs are physically inverted
			PointColor(wid-j, i, RGB(b1,g1,r1)); // RGBs are physically inverted
        }
    }
}

//grupo 13
void CSurface::Threshold()
{
	COLORREF cCur;	//declara um dword
	BYTE r, g, b, limiar, media;
	limiar = 120;
	//percorre a tela em cada ponto
	for (int l = 0; l < m_wndHeight; l++) {
		for (int m = 0; m < m_wndWidth; m++) {
			cCur = PointColor(m,l);
			media = (BYTE)((GetRValue(cCur)+GetGValue(cCur)+GetBValue(cCur))/3); //calcula a media do rgb do pixel corrente
			if (media > limiar) {
				r = 255;	
				g = 255;	
				b = 255;	
			}else{
				r = 0;	
				g = 0;	
				b = 0;
			}
			PointColor(m,l,RGB(b,g,r)); //reatribui o valor alterado no ponto
		}
	}
}

//Grupo 11
void CSurface::ChannelMix()
{
	COLORREF cCur;
	BYTE r, g, b;

	for(int i=0; i < m_wndHeight; i++){
		for(int j=0; j < m_wndWidth; j++){
			cCur = PointColor(j,i);

			
			 r = (BYTE)(GetCValue(cCur));
                g = (BYTE)(GetMValue(cCur));
                b = (BYTE)(GetYValue(cCur));
                        
                PointColor(j,i,RGB(b,g,r));

		}
	}
}

//Grupo 7
void CSurface::Invert(){
	COLORREF cCur;		//declara um dword
	BYTE r, g, b;		//variáveis tipo byte que receberão os valores RGB

	//realiza um loop dentro do outro para percorrer a tela inteira
	for (int i = 0; i < m_wndHeight; i++) {
		for (int j = 0; j < m_wndWidth; j++) {
			cCur = PointColor(j,i);					//pega o pixel de posição [i,j] na tela
			r = (BYTE)(255 - GetRValue(cCur));	
			g = (BYTE)(255 - GetGValue(cCur));
			b = (BYTE)(255 - GetBValue(cCur));
			PointColor(j,i,RGB(b,g,r));				//reescreve na tela o pixel do valores RGB modificados na posição [i,j]
		}
	}
}

//Grupo 17
void CSurface::Rescale() {
	COLORREF cCur;
	int r,g,b;
	for(int i = 0; i< m_wndHeight;i++) {
		for(int j = 0; j < m_wndWidth; j++) {
		
					cCur = PointColor (j,i);   
					r = GetRValue(cCur)*2;		// Multiplica as 3 componentes das cores por 2
					g = GetGValue(cCur)*2;
					b = GetBValue(cCur)*2;
					if(r>255) r = 255;			// Estabelece a cor branca como teto, evitando wrap around
					if(g>255) g = 255;
					if(b>255) b = 255;
					PointColor(j,i,RGB(b,g,r)); // Atualiza o pixel com a nova cor

		}
	}
}
// Grupo 20
void CSurface::Amarelar()
{	
	// Azular
	COLORREF cCur;
	

	//Percorre toda imagem
    for (int y = 0; y < m_wndHeight; y++) {
        for (int x = 0; x < m_wndWidth; x++) {
			cCur = PointColorD(x,y);
			int R = GetRValue(cCur);
			int G = GetGValue(cCur);
			int B = GetBValue(cCur);
			int NC = (R+G+B)/3;
			COLORREF newPixCol =  RGB(NC,NC,0);
			PointColorT(x,y,newPixCol);
		}
     
    }

	//Quando terminar, copia o resultado para a imagem corrente
	Copy(t_image);
}
//Grupo 2012
void CSurface::RB3D()
{	
	
	COLORREF pEsquerdo = 0, pAtual = PointColor(0,0), pDireito;
	BYTE r, g, b;
    
	for (int k=0; k<30; k++){
		// Aplica o efeito 30 vezes
        
		for (int i = 0; i < m_wndHeight; i++) {
		pEsquerdo = 0; // Para não pegar fora da imagem

			for (int j = 0; j < m_wndWidth; j++) {
				pDireito = PointColor(j+1, i);
		        
				r = (BYTE)(GetRValue(pEsquerdo));// Joga o valor para o pixel esquerdo
				g = (BYTE)(GetGValue(pAtual));
				b = (BYTE)(GetBValue(pDireito));// Joga o valor para o pixel direito
                
				PointColor(j, i, RGB(b,g,r)); // RGB é invertido

				//Movimenta o pixel atual salvo
				pEsquerdo = pAtual;
				pAtual = pDireito;
			}
		}
	}
}
//Função usada para ordenar o vetor do Median
void Ordena (int *vetor, int tamanho) {
int auxiliar;
for (int i = 0; i < tamanho; i++){
for (int j = i+1; j < tamanho; j++){
if (vetor[i] > vetor[j]){
auxiliar = vetor[i];
vetor[i] = vetor[j];
vetor[j] = auxiliar;
}
}
}
}
//Grupo 2012
void CSurface::Median()
{
COLORREF pAtual, pEsquerda, pDireita, pCima, pBaixo, pDiagEsqCima, pDiagEsqBaixo, pDiagDirCima, pDiagDirBaixo;
int r, g, b;
int vetorTemp[9];
for (int i = 1; i < m_wndHeight; i++) {
for (int j = 1; j < m_wndWidth; j++) {

pAtual = PointColor(j, i);
pEsquerda = PointColor(j-1, i);
pDireita = PointColor(j+1, i);
pCima = PointColor(j, i-1);
pBaixo = PointColor(j, i+1);
pDiagEsqCima = PointColor(j-1, i-1);
pDiagEsqBaixo = PointColor(j-1, i+1);
pDiagDirCima = PointColor(j+1, i-1);
pDiagDirBaixo = PointColor(j+1, i+1);

vetorTemp[0] = GetRValue(pAtual);	
vetorTemp[1] = GetRValue(pEsquerda);
vetorTemp[2] = GetRValue(pDireita);
vetorTemp[3] = GetRValue(pCima);
vetorTemp[4] = GetRValue(pBaixo);
vetorTemp[5] = GetRValue(pDiagEsqCima);
vetorTemp[6] = GetRValue(pDiagEsqBaixo);
vetorTemp[7] = GetRValue(pDiagDirCima);
vetorTemp[8] = GetRValue(pDiagDirBaixo);	

Ordena(vetorTemp,sizeof(vetorTemp)/sizeof(int));
r = vetorTemp[4];

vetorTemp[0] = GetGValue(pAtual);	
vetorTemp[1] = GetGValue(pEsquerda);
vetorTemp[2] = GetGValue(pDireita);
vetorTemp[3] = GetGValue(pCima);
vetorTemp[4] = GetGValue(pBaixo);
vetorTemp[5] = GetGValue(pDiagEsqCima);
vetorTemp[6] = GetGValue(pDiagEsqBaixo);
vetorTemp[7] = GetGValue(pDiagDirCima);
vetorTemp[8] = GetGValue(pDiagDirBaixo);

Ordena(vetorTemp,sizeof(vetorTemp)/sizeof(int));	
g = vetorTemp[4];
vetorTemp[0] = GetBValue(pAtual);
vetorTemp[1] = GetBValue(pEsquerda);
vetorTemp[2] = GetBValue(pDireita);
vetorTemp[3] = GetBValue(pCima);
vetorTemp[4] = GetBValue(pBaixo);
vetorTemp[5] = GetBValue(pDiagEsqCima);
vetorTemp[6] = GetBValue(pDiagEsqBaixo);
vetorTemp[7] = GetBValue(pDiagDirCima);
vetorTemp[8] = GetBValue(pDiagDirBaixo);

Ordena(vetorTemp,sizeof(vetorTemp)/sizeof(int));	
b = vetorTemp[4];

PointColor(j, i, RGB(b,g,r)); // RGBs are physically inverted
}
}

}