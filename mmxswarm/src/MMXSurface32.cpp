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
    int height = GetVisibleHeight()*2;	//altura multiplicada por 2 pois são pixels de 32 bits em variáveis de64 bits (2x maior)
    DWORD *pCur  = (DWORD *)GetPixelAddress(0,0);	// cada pixel tem 32bits, 1byte para cada canal de cor: alfa, red, green, blue

	// Variaveis do tipo unsigned long long, de 64 bits
	ULONGLONG mascara = 0xFF;	//seleciona um byte de alguma variável (utilizada para pegar valores individuais de RGB)	
	ULONGLONG pixel;	//recebe os valores referentes a um ponto da tela
	ULONGLONG next;		//recebe os valores do próximo ponto a partir de pixel 
	
	pixel = *(ULONGLONG *)pCur;	//faz um casting 64 bits dos dados do ponto atual na variável pixel
	
	//loops para percorrer toda a tela
	do {
		int width = m_width;
		do {
			
			next = *(ULONGLONG *)(pCur+1);	//próximo ponto recebe o ponteiro que aponta para um ponto na tela + 1
			
			//utilização dos registradores mmx 64 bits com inline assembly 
			__asm{
				movq mm0, pixel		//registrador mm0 reebe o valor do pixel atual
				pand mm0, mascara	//valor de mm0 recebe uma mascara para selecionar seu 1 byte menos significativo (B)
				movq mm1, mm0		//guarda o valor calculado acima em mm1
				movq mm0, pixel		//recarrega o valor do pixel em mm0
				psrlq mm0, 8		//realiza um shift lógico para a direita para pegar o próximo byte
				pand mm0, mascara	//utilizar mascara para isolar um byte (G)
				paddd mm1, mm0		//soma o valor calculado anteriormente em mm1 (B+G)
				movq mm0, pixel		//recarrega o valor do pixel em mm0
				psrlq mm0, 16		//realiza um shift lógico para direita para pegar o 3 byte
				pand mm0, mascara	//utiliza mascara para isolar um byte (R)
				paddd mm1,mm0		//soma o valor calculado acima em mm1 (B+G+R)
				movq pixel, mm1		//move para a variável pixel a soma dos valores RGB calculados nos registradores mmx
			}

			pixel /= 3;				//realiza media dos valores RGB ((R+G+B)/3)

			__asm{
				movq mm0, pixel		//mm0 recebe a media dos valores RGB
				movq mm1, mm0		//copia mm0 em mm1
				psllq mm0, 8		//realiza um shift lógico para esquerda em 1 byte
				paddd mm1, mm0		//soma a (media<<8) em mm1 
				psllq mm0, 8		//novamente um shift para esquerda em 1 byte
				paddd mm1, mm0		//soma a (media<<16) em mm1
				movq pixel, mm1		//mm1 agora possui os valores médios RGB (GrayScale), então salva isso em pixel
			}

			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			pixel = next;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
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