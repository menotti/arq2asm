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
    int height = GetVisibleHeight()*2;				//aumenta a altura em 2 pois s�o processados 2 pixels de 32-bits de uma s� vez em vari�veis de 128 bits	
    DWORD *pCur  = (DWORD *)GetPixelAddress(0,0);	//ponteiro para posi��o atual da tela
	
	ULONGLONG mascara = 0xFF;						//m�scara para selecionar um byte por vez
	ULONGLONG pixel1, pixel2;						//variaveis de 64 bits que receber�o valores de dois pixels consecutivos
	ULONGLONG next1, next2;							//vari�veis que guardam a pr�ximas posi��es de pixel1 e pixel2
	ULONGLONG media1, media2;						//medias RGB de pixel1 e pixel2 respectivamente

	pixel1 = *(ULONGLONG *) pCur;					//pixel1 recebe pixel que est� sendo apontado no inicio (0,0) 
	pixel2 = *(ULONGLONG *) (pCur+1);				//pixel2 recebe pixel consecutivo (0,1)
	
	//loops para percorrer toda a tela
	do {
		int width = m_width;
		do {
			
			next1 = *(ULONGLONG *) (pCur+2);		//guarda pr�ximo valor para pixel1	
			next2 = *(ULONGLONG *) (pCur+3);		//guarda pr�ximo valor para pixel2	
			
			__asm{
				movq xmm0, pixel1					//move pixel1 para os 64 bits menos significativos de xmm0 (128 bits)
				movhpd xmm0, pixel2					//move pixel2 para os 64 bits mais significativos de xmm0
				movq xmm1, mascara					//xmm1 far� o papel de seletor de bytes especificos de xmm0
				pand xmm1,xmm0						//seleciona primeiro byte de xmm0 e guarda em xmm1
				movq xmm2,xmm1						//xmm2 receber� a soma dos bytes selecionados
				movq xmm1,mascara					
				psrldq xmm0,1						//desloca em 1 para direita xmm0 (como s�o registradores 128 bits, na verdade ocorre um deslocamento de 2 unidades)
				pand xmm1,xmm0
				paddq xmm2,xmm1
				movq xmm1,mascara
				psrldq xmm0,1
				pand xmm1,xmm0
				paddq xmm2,xmm1
				movq media1,xmm2					//recebe a soma dos valores RGB de pixel1 (parte menos significativa de xmm0)
				movq xmm1,mascara
				psrldq xmm0,2						//desloca em 2 para direita xmm0, para selecionar agora sua metade mais significativa (pixel2)
				pand xmm1,xmm0
				movq xmm2,xmm1
				movq xmm1,mascara
				psrldq xmm0,1
				pand xmm1,xmm0
				paddq xmm2,xmm1
				movq xmm1,mascara
				psrldq xmm0,1
				pand xmm1,xmm0
				paddq xmm2,xmm1
				movq media2,xmm2					//salva a soma dos valores RGB de pixel2 em media2
			}

			media1 /= 3;							//realiza m�dia efetiva dos pixels
			media2 /= 3;

			__asm{
				movq xmm0,media1					//xmm0 receber� as medias byte a byte 
				movq xmm1,xmm0
				pslldq xmm0,1
				paddq xmm0,xmm1
				pslldq xmm0,1
				paddq xmm0,xmm1
				movq pixel1,xmm0					//atualiza o valor de pixel1, com xmm0 que cont�m a m�dia nos seus valores RGB 
				movq xmm0,media2
				movq xmm1,xmm0
				pslldq xmm0,1
				paddq xmm0,xmm1
				pslldq xmm0,1
				paddq xmm0,xmm1
				movq pixel2,xmm0					//atualiza o valor de pixel2, com xmm0 que cont�m a m�dia nos seus valores RGB
			}

			*(ULONGLONG *)pCur = pixel1;			//joga o valor calculado de pixel1 de volta na tela
			*(ULONGLONG *)(pCur+1) = pixel2;		//joga o valor calculado de pixel2 de volta na tela
			pixel1 = next1;							//pixel1 recebe o pr�ximo pixel 
			pixel2 = next2;							//pixel2 recebe o pr�ximo pixel
			pCur += 2;								//aumenta o ponteiro da tela em 2 (calcula 2 pixels por vez)
		} while (--width > 0);
	} while (--height > 0);
}

// GRUPO 9 - Filtro Posterize
//sobrescreve o Posterize do Surface
void CSSE2Surface32Intrinsic::Posterize()
{
	int height = GetVisibleHeight();
    DWORD *pCur  = (DWORD *) GetPixelAddress(0,0);	// cada pixel tem 32bits, 1byte para cada canal de cor: alfa, red, green, blue

	// Variaveis do tipo unsigned long long, de 64 bits
	ULONGLONG mascara = 0xC0C0C0C0C0C0C0C0;		//0xC = 1100, preservar dois MSD de cada byte.
	ULONGLONG pixel1, pixel2;

	/* Iteracao principal, processa 2 pixels em cada iteracao */
	do {
		int width = m_width;
		do {
			pixel1 = *(ULONGLONG *)pCur;
			pixel2 = *(ULONGLONG *)(pCur+2);
			// inline assembly
			__asm{
				movq xmm0, pixel1	// ler pixels atuais para registrador
				movhpd xmm0, pixel2
				movq xmm1, mascara
				movhpd xmm1, mascara

				pand xmm0, xmm1	// aplicar mascara para descartar bits menos significativos

				movhpd pixel2, xmm0
				movq pixel1, xmm0
			}
			*(ULONGLONG *)pCur = pixel1;
			*(ULONGLONG *)(pCur+2) = pixel2;
			pCur+= 4;
		} while (--width > 0);
	} while (--height > 0);
}
