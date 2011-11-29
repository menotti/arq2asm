// MMXSurface32.cpp : implementation of the CMMXSurface32Intrinsic
// class
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
#include "MMXSurface.h"
#include "MMXWrapper.h"

typedef CMMXUnsigned16Saturated CMMX;

// Optimized for a 2-pixel processing 32 bit buffer
void CMMXSurface32Intrinsic::AdjustWidth(int *pWidth)
{
	ASSERT(pWidth != NULL);
	ASSERT(m_kDeltaX == 1);
	// increment if odd.  If we are even, we stop
	// dead on correctly, reading the single black buffer
	// column. If we are odd, we need an extra column so
	// we don't need to special case the tail of the loop.

	// Because we know there is always a DeltaX black stripe
	// at least 1 pixel wide, we can subtract instead of adding.
	// this allows us to get rid of adding a delta per horizontal
	// loop. while in theory this could cause the left side to bleed
	// to the right, in reality this won't happen.
	if (*pWidth & 0x01)
		*pWidth -= 1;
}

void CMMXSurface32Intrinsic::OnCreated()
{
	ASSERT(GetBitDepth() == 32);
	ASSERT((GetPitch() & 0x7) == 0);
	ASSERT(GetVisibleWidth() && GetVisibleHeight());

	int width = GetVisibleWidth();
    m_dwpl = GetPitch()/4; // dwords Per Line
    m_width = (width+1)/2; // 2 pixels at a time
}

void CMMXSurface32Intrinsic::BlurBits()
{
    int height = GetVisibleHeight();
    DWORD *pCur  = (DWORD *)GetPixelAddress(0,0);

	CMMX cFader;
	CMMX cRight, cRightRight;
	CMMX cDownRight;
	CMMX cLeft;
	CMMX cUpRight;
	CMMX cUp, cDown, cCur;

	cFader.UnpackBytesLo( 0x01010101 );
	cLeft.Clear();
	cCur.UnpackBytesLo( *pCur );

	do {
		int width = m_width;
		do {
			// Load pixels and do the mmx unpack
			cRight.UnpackBytesLo( pCur[1] );
			cRightRight.UnpackBytesLo( pCur[2] );
			cUp.UnpackBytesLo( pCur[-m_dwpl] );
			cUpRight.UnpackBytesLo( pCur[-m_dwpl+1] );
			cDown.UnpackBytesLo( pCur[m_dwpl] );
			cDownRight.UnpackBytesLo( pCur[m_dwpl+1] );

			// Actual math. Don't step on current, or right.
			// Sum the 4 around and double the middle

			// Do current pixel in this line
			cUp = (cDown+cUp+cLeft+cRight+(cCur<<2))>>3;

			// Do next pixel
			cDown = (cDownRight+cUpRight+cCur+cRightRight+(cRight<<2))>>3;

#if defined(TRIPPY)
			cUp += cFader; // increase the fade to white
			cDown += cFader; // increase the fade to white
#elif defined (FAST_FADE)
    	    cUp -= cFader; // increase the fade to black
    	    cDown -= cFader; // increase the fade to black
#endif
			cLeft = cRight; 		// Slide left!
			cCur = cRightRight;

			*(ULONGLONG *)pCur = cUp.PackBytes(cDown);
			pCur += 2;
		} while (--width > 0);
	} while (--height > 0);
}

//Grupo 4
void CMMXSurface32Intrinsic::GrayScale()
{
    int height = GetVisibleHeight()*2;
    DWORD *pCur  = (DWORD *)GetPixelAddress(0,0);

	CMMX cCur,cRight;
	CMMX cMask;
	CMMX cR,cG,cB;
	CMMX media;

	cCur.UnpackBytesLo( *pCur );
	do {
		int width = m_width;
		do {			
			cRight.UnpackBytesLo(pCur[1]);
			cMask.UnpackBytesLo(0xff);
			media.Clear();
			cR = cCur & cMask;
			cMask = cMask*65536;								//cMask <<= 16;			
			cG = cCur & cMask;
			cMask = cMask*65536;								//cMask <<= 16;			
			cB = cCur & cMask;
			cG = cG/65536;										//cG >>= 16;			
			cB = cB/4294967296;									//cB >>= 32;			
			media = (cR + cG + cB)/3;
			cCur.Clear();
			cMask = cMask/4294967296;							//cMask >>= 32;			
			cCur = cMask;
			cCur = cCur*65536;									//cCur <<= 16;			
			cCur += media;
			cCur = cCur*65536;									//cCur <<= 16;			
			cCur += media;
			cCur = cCur*65536;									//cCur <<= 16;			
			cCur += media;
			*(ULONGLONG *)pCur = cCur.PackBytes(cCur);
			cCur = cRight;
			pCur ++;
		} while (--width > 0);
	} while (--height > 0);
}

// Grupo5
void CMMXSurface32Intrinsic::Sobel() {
	CMMX cCur;
	//ULONGLONG *pCur  = (ULONGLONG *)GetPixelAddress(0,0);

	sumX = 0;
	sumY = 0;
	SUM = 0;
	//WORD *pwCur = (WORD *)pCur;
	//Percorre toda imagem
    for (y = 0; y < GetVisibleHeight(); y++) {
        for (x = 0; x < GetVisibleWidth(); x++) {
			sumX = 0;
			sumY = 0;

			//Se for boada, atribui o valor 0(preto)
			if((y==0) || (y == (GetVisibleHeight() - 1))){
				SUM = 0;
			}
			else {
				if((x==0) || (x == (GetVisibleWidth() - 1))){
					SUM = 0;
				}
				else
				{

					for(I=-1; I<=1; I++)  {
						for(J=-1; J<=1; J++)  {

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
			}

			if(SUM>255)
				SUM=255;
			if(SUM<0)
				SUM=0;
			newPixel = (255-(unsigned char)(SUM));
			
			PointColorT(x,y,RGB(newPixel,newPixel,newPixel));
        }
    }

	//Quando terminar, copia o resultado para a imagem corrente
	Copy(t_image);
}



// GRUPO 9 - Filtro Posterize
//sobrescreve o Posterize do Surface
void CMMXSurface32Intrinsic::Posterize()
{
	int height = GetVisibleHeight();
    DWORD *pCur  = (DWORD *)GetPixelAddress(0,0);	// cada pixel tem 32bits, 1byte para cada canal de cor: alfa, red, green, blue

	// Variaveis do tipo unsigned long long, de 64 bits
	ULONGLONG mascara = 0xC0C0C0C0C0C0C0C0;		//0xC = 1100, preservar dois MSD de cada byte.
	ULONGLONG pixel;

	/* Iteracao principal, processa 2 pixeis em cada iteracao */
	do {
		int width = m_width;
		do {
			pixel = *(ULONGLONG *)pCur;
			// inline assembly
			__asm{
				movq mm0, pixel;	// ler pixeis atuais para registrador
				pand mm0, mascara	// aplicar mascara para descardar bits menos significativos
				movq pixel, mm0;
			}
			*(ULONGLONG *)pCur = pixel;
			pCur+= 2;
		} while (--width > 0);
	} while (--height > 0);
}