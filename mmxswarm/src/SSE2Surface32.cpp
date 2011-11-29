// SSE2Surface32.cpp : implementation of the CSSE2Surface32Intrinsic
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
#include "SSE2Surface.h"
#include "SSE2Wrapper.h"

typedef CSSE2Unsigned16Saturated CSSE2;

// Optimized for a 4-pixel processing 32 bit buffer
void CSSE2Surface32Intrinsic::AdjustWidth(int *pWidth)
{
	ASSERT(pWidth != NULL);
	ASSERT(m_kDeltaX <= 3);

	*pWidth = (*pWidth + 3-m_kDeltaX) & ~3; // round up by 4
}

void CSSE2Surface32Intrinsic::OnCreated()
{
	ASSERT(GetBitDepth() == 32);
	ASSERT((GetPitch() & 0xF) == 0);
	ASSERT(GetVisibleWidth() && GetVisibleHeight());
	ASSERT(sizeof(RGBQUAD) == 4);

	int width = GetVisibleWidth();
    m_qwpl  = GetPitch()/8; // qwords Per Line
    m_width = (width+3)/4; // 4 pixels at a time
}

void CSSE2Surface32Intrinsic::BlurBits()
{
    int height = GetVisibleHeight();
    ULONGLONG *pCur  = (ULONGLONG *)GetPixelAddress(0,0);
	ASSERT((DWORD_PTR(pCur) & 0xF) == 0);

	CSSE2 cFader;
	CSSE2 cRight, cLeft;
	CSSE2 cUp, cDown, cCur;
	CSSE2 cResult;

	cFader.UnpackBytesLo( 0x0101010101010101u );
	cLeft.Clear();

	do {
		int width = m_width;
		ASSERT((DWORD_PTR(pCur) & 0xF) == 0);
		do {
			RGBQUAD *pdwCur = (RGBQUAD*)pCur;
			ULONGLONG *pNext = (ULONGLONG*)(pdwCur+1);

			// Load pixels and do the mmx unpack
			cCur.UnpackBytesLo( *pCur );
			cRight.UnpackBytesLo( *pNext );
			cUp.UnpackBytesLo( pCur[-m_qwpl] );
			cDown.UnpackBytesLo( pCur[m_qwpl] );

			// Actual math. Don't step on current, or right.
			// Sum the 4 around and double the middle
			
			// Do current pixel in this line
			cResult = (cDown+cUp+cLeft+cRight+(cCur<<2))>>3;

			// Do next pixel
			cLeft = cRight; 		// Slide left!
			cCur.UnpackBytesLo( pCur[1] );
			cRight.UnpackBytesLo( pNext[1] );
			cUp.UnpackBytesLo( pCur[-m_qwpl+1] );
			cDown.UnpackBytesLo( pCur[m_qwpl+1] );
			cCur = (cDown+cUp+cLeft+cRight+(cCur<<2))>>3;

#if defined(TRIPPY)
			cCur += cFader; // increase the fade to white
			cResult += cFader; // increase the fade to white
#elif defined (FAST_FADE)
    	    cCur -= cFader; // increase the fade to black
    	    cResult -= cFader; // increase the fade to black
#endif
			cLeft = cRight; 		// Slide left!
	
			cResult.PackBytes(pCur, cCur);
			pCur += 2;
		} while (--width > 0);
	} while (--height > 0);
}

//Grupo 4
void CSSE2Surface32Intrinsic::GrayScale()
{
    int height = GetVisibleHeight()*4;	//altura multiplicada por 4 pois são pixels de 32 bits em variáveis de 128 bits (4x maior)
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