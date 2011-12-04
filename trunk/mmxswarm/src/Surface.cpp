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
	image2.BitBlt(m_image.GetDC(), 0, m_kDeltaY, 
		GetVisibleWidth(), GetVisibleHeight(), 0, 0);
	m_image.ReleaseDC();
	image2.BitBlt(n_image.GetDC(), 0, m_kDeltaY, 
		GetVisibleWidth(), GetVisibleHeight(), 0, 0);
	n_image.ReleaseDC();
	image.BitBlt(o_image.GetDC(), 0, m_kDeltaY, 
		GetVisibleWidth(), GetVisibleHeight(), 0, 0);
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
void CSurface::Invert()
{
	COLORREF cCur;		
	BYTE r, g, b;		//Variáveis que receberão os valores RGB

	//Loop para acessar todos os pixels da imagem
	for (int i = 0; i < m_wndHeight; i++) {
		for (int j = 0; j < m_wndWidth; j++) {
			cCur = PointColor(j,i);		//pega um pixel da tela da posição [i,j]
			r = (BYTE)(255-GetRValue(cCur));	//Para fazer a inversão, o cálculo a ser realizado p/ cada cor é de 255-cor
			g = (BYTE)(255-GetGValue(cCur));	
			b = (BYTE)(255-GetBValue(cCur));	
			PointColor(j,i,RGB(b,g,r));		//reescreve na tela o pixel com os valores RGB modificados na posição [i,j]
		}
	}
}

//Grupo 15
void CSurface::Mask()
{
	COLORREF cCur;		
	BYTE g, b;

	for (int i = 0; i < m_wndHeight; i++) {
		for (int j = 0; j < m_wndWidth; j++) {
			cCur = PointColor(j,i);
			//r = (BYTE)(GetRValue(cCur));
			g = (BYTE)(GetGValue(cCur));	
			b = (BYTE)(GetBValue(cCur));	
			PointColor(j,i,RGB(b,g,0));		//Esse filtro apenas zera o canal vermelho. Tadaaa
		}
	}
}

//Grupo 6
int CSurface::CAL_PIXEL(Complex c)
{
	int count, max;
	Complex z;
	float temp, lengthsq;
	max = 256;
	z.real = 0;
	z.imag = 0;
	count = 0;
	
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
	float real_min = -2, real_max = 2;
	float imag_min = -2, imag_max = 2;
	int disp_width = m_wndWidth, disp_heigth = m_wndHeight;
	int x = 1 ,y = 1;
	int color1;
	float scale_real, scale_imag;
	
	c1.real = real_min + x * (real_max - real_min)/disp_width;
	c1.imag = imag_min + y * (imag_max - imag_min)/disp_heigth;
	
	scale_real = (real_max - real_min)/disp_width;
	scale_imag = (imag_max - imag_min)/disp_heigth;
	
	for(x = 0; x < disp_width; x++)
	{
		for(y = 0; y < disp_heigth; y++)
		{
			c1.real = real_min + ((float) x * scale_real);
			c1.imag = imag_min + ((float) y * scale_imag);
			color1 = CAL_PIXEL(c1);
			r = (BYTE)((color1));
			g = (BYTE)((color1)); 
			b = (BYTE)((color1));
			PointColor(x,y,RGB(r,g,b));
		}
	}
}

void CSurface::Threshold()
{
	COLORREF cCur;		//declara um dword
	BYTE r, g, b;		//variáveis tipo byte que receberão os valores RGB


	//realiza um loop dentro do outro para percorrer a tela inteira
	for (int i = 0; i < m_wndHeight; i++) {
		for (int j = 0; j < m_wndWidth; j++) {
			cCur = PointColor(j,i);					//pega o pixel de posição [i,j] na tela
			//Quando qualquer valor R,G ou B for maior que 123, converte a cor para branca(255)
			if(GetRValue(cCur) > 123 || GetRValue(cCur) > 123 || GetBValue(cCur) > 123){
				r = (BYTE)((255));
				g = (BYTE)((255));
				b = (BYTE)((255));
			}
			else //Converte para preto quando os 3(r,g e b) forem menor que 123.
			{
				r = (BYTE)((0));
				g = (BYTE)((0));
				b = (BYTE)((0));
			}
			PointColor(j,i,RGB(b,g,r));				//reescreve na tela o pixel do valores RGB modificados na posição [i,j]
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