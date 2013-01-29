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
/*
//grupo 8 - Filtro Gradient
void CMMXSurface32Intrinsic::Gradient()
{
	int contador2 = 1;	//contador auxiliar usado de base para o contador principal
	int contador;		//contador principal que fará o incremento de cada canal
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
			contador = contador2/3;			//O contador principal recebe o contador auxiliar/3 para que a gradiência não aconteça tão rápido

			//utilização dos registradores mmx 64 bits com inline assembly 
			__asm{
				movq mm0, pixel		//registrador mm0 recebe o valor do pixel atual
					pand mm0, mascara	//valor de mm0 recebe uma mascara para selecionar seu 1 byte menos significativo (B)
					paddusb mm0, contador

					movq mm1, pixel		//registrador mm1 recebe o valor do pixel atual
					psrlq mm1, 8		//realiza um shift lógico para direita para pegar o 2 byte
					pand mm1, mascara	//valor de mm1 recebe uma mascara para selecionar seu 2 byte menos significativo (G)
					paddusb mm1, contador

					movq mm2, pixel		//registrador mm2 recebe o valor do pixel atual
					psrlq mm2, 16		//realiza um shift lógico para direita para pegar o 3 byte
					pand mm2, mascara	//valor de mm2 recebe uma mascara para selecionar seu 1 byte menos significativo (R)
					paddusb mm2, contador

					movq mm3, pixel     // mm3 <- pixel atual
					psrlq mm3, 24       // mm3 <- canal alpha

					pxor mm4, mm4       //garante que o registrador mm4 esta vazio
					paddd mm4, mm3      //adiciona o canal alpha ao mm4
					psllq mm4, 8        //shift para o proximo byte
					paddd mm4, mm2      //copia o canal R (mm2) para mm4
					psllq mm4, 8		//um shift para esquerda em 1 byte
					paddd mm4, mm1		//copia o canal G (mm1) para mm4
					psllq mm4, 8		//novamente um shift para esquerda em 1 byte
					paddd mm4, mm0		//copia o canal B (mm0) para mm4

					movq pixel, mm4     //retorna para a variavel alto nivel os novos valores do pixel
			}

			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			pixel = next;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
		} while (--width > 0);

		if (contador<255)
			contador2++;

	} while (--height > 0);
}
*/
//Grupo 4
void CMMXSurface32Intrinsic::GrayScale()
{
	int height = GetVisibleHeight()*2;	//altura multiplicada por 2 pois são pixels de 32 bits em variáveis de 64 bits (2x maior)
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
void CMMXSurface32Intrinsic::Azular() {
	int height = GetVisibleHeight()*2;	//altura multiplicada por 2 pois são pixels de 32 bits em variáveis de 64 bits (2x maior)
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
			/*
			__asm{
				movq mm0, pixel		//mm0 recebe a media dos valores RGB
					movq mm1, mm0		//copia mm0 em mm1
					psllq mm0, 8		//realiza um shift lógico para esquerda em 1 byte
					pxor mm2,mm2
					paddd mm1, mm2		//soma a (media<<8) em mm1 
					psllq mm0, 8		//novamente um shift para esquerda em 1 byte
					paddd mm1, mm2		//soma a (media<<16) em mm1
					movq pixel, mm1		//mm1 agora possui os valores médios RGB (GrayScale), então salva isso em pixel
			}
			*/
			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			pixel = next;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
		} while (--width > 0);
	} while (--height > 0);
}

// Grupo5
void CMMXSurface32Intrinsic::Esverdear() {
	int height = GetVisibleHeight()*2;	//altura multiplicada por 2 pois são pixels de 32 bits em variáveis de 64 bits (2x maior)
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
					psllq mm0, 8
					movq pixel, mm0		//mm1 agora possui os valores médios RGB (GrayScale), então salva isso em pixel
			}

			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			pixel = next;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
		} while (--width > 0);
	} while (--height > 0);
}

// Grupo5
void CMMXSurface32Intrinsic::Envermelhar() {
	int height = GetVisibleHeight()*2;	//altura multiplicada por 2 pois são pixels de 32 bits em variáveis de 64 bits (2x maior)
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
					psllq mm0, 16
					movq pixel, mm0		//mm1 agora possui os valores médios RGB (GrayScale), então salva isso em pixel
			}

			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			pixel = next;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
		} while (--width > 0);
	} while (--height > 0);
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

	/* Iteracao principal, processa 2 pixels em cada iteracao */
	do {
		int width = m_width;
		do {
			pixel = *(ULONGLONG *)pCur;
			// inline assembly
			__asm{
				movq mm0, pixel;	// ler pixels atuais para registrador
				pand mm0, mascara	// aplicar mascara para descardar bits menos significativos
					movq pixel, mm0;
			}
			*(ULONGLONG *)pCur = pixel;
			pCur+= 2;
		} while (--width > 0);
	} while (--height > 0);
}

//grupo 13
void CMMXSurface32Intrinsic::Threshold()
{
	int height = GetVisibleHeight()*2;	//altura multiplicada por 2 pois são pixels de 32 bits em variáveis de64 bits (2x maior)
	DWORD *pCur  = (DWORD *)GetPixelAddress(0,0);	// cada pixel tem 32bits, 1byte para cada canal de cor: alfa, red, green, blue

	// Variaveis do tipo unsigned long long, de 64 bits
	ULONGLONG mascara = 0xFF;	//seleciona um byte de alguma variável (utilizada para pegar valores individuais de RGB)	
	ULONGLONG pixel;	//recebe os valores referentes a um ponto da tela
	ULONGLONG next;		//recebe os valores do próximo ponto a partir de pixel 
	ULONGLONG limiar = 120; //define um limiar para inversao do pixel

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
			if (pixel>limiar){		//define qual a atribuicao do pixel a partir do limiar
				pixel = 0xFFFFFF;
			}else{
				pixel = 0x000000;
			}

			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			pixel = next;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
		} while (--width > 0);
	} while (--height > 0);
}

//Grupo 14
void CMMXSurface32Intrinsic::RGBAdjust()
{
	int height = GetVisibleHeight()*2;
	DWORD *pCur  = (DWORD *)GetPixelAddress(0,0);
	ULONGLONG mascara = 0xFF;
	ULONGLONG pixel;
	ULONGLONG next;

	pixel = *(ULONGLONG *)pCur;
	do
	{
		int width = m_width;
		do
		{
			next = *(ULONGLONG *)(pCur+1);
			__asm
			{
				movq mm0, pixel	//mm0 = pixel atual
				pand mm0, mascara	//mm0 = a componente 'B'
				pxor mm5, mm5
				psrlq mm0, 2		//1 shift para a direita (divide por 4, sem precisão)

				movq mm1, pixel	//mm0 = pixel, novamente
				psrlq mm1, 8		//shift à direita para pegar a componente 'G' do pixel
				pand mm1, mascara
				psrlq mm1, 1	//1 shift para a direita (divide por 2, sem precisão) 

				movq mm2, pixel
				psrlq mm2, 16  //mm0 = a componente 'R'
				pand mm2, mascara
				psrlq mm2, 0		//1 shift para a direita (divide por 1, sem precisão)

				movq mm3, pixel	//mm3 = pixel

				pxor mm4, mm4       //garante que o registrador mm4 esta vazio
				paddd mm4, mm3      //adiciona o canal alpha ao mm4
				psllq mm4, 8        //shift para o proximo byte
				paddd mm4, mm2      //copia o canal R (mm2) para mm4
				psllq mm4, 8		//um shift para esquerda em 1 byte
				paddd mm4, mm1		//copia o canal G (mm1) para mm4
				psllq mm4, 8		//novamente um shift para esquerda em 1 byte
				paddd mm4, mm0		//copia o canal B (mm0) para mm4
				movq pixel, mm4
				}
			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			pixel = next;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
		} while (--width > 0);
	} while (--height > 0);

}

// GRUPO 15
void CMMXSurface32Intrinsic::Mask()
{
	ULONGLONG mascara = 0xFF00FFFFFF00FFFF; // Remove componente vermelha = 00ggbb

	DWORD *pCur  = (DWORD *)GetPixelAddress(0,0);
	ULONGLONG pixels;

	int height = GetVisibleHeight();
	while (height--)
	{
		int width = m_width;	//m_width = (width+1)/2; pois editamos 2 pixels por iteracao
		while(width--)
		{
			pixels = *(ULONGLONG *)pCur;

			__asm
			{
				movq mm0, pixels	// registrador mm0 recebe 2 pixels
					pand mm0, mascara	// aplica mascara
					movq pixels, mm0
			}

			// Imprime dois pixels na tela
			*(ULONGLONG *)pCur = pixels;

			pCur += 2;
		}
	}
}

// Grupo 12 - Gray Filter
void CMMXSurface32Intrinsic::GrayFilter(){

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
				movq mm0, pixel		//registrador mm0 recebe o valor do pixel atual
					pand mm0, mascara	//valor de mm0 recebe uma mascara para selecionar seu 1 byte menos significativo (B)
					paddd mm0, mascara //acresce 255d a B
					psrlq mm0, 1        //1 shift para a direita (divide por 2, sem precisão)

					movq mm1, pixel		//registrador mm1 recebe o valor do pixel atual
					psrlq mm1, 8		//realiza um shift lógico para direita para pegar o 2 byte
					pand mm1, mascara	//valor de mm1 recebe uma mascara para selecionar seu 2 byte menos significativo (G)
					paddd mm1, mascara //acresce 255d a G
					psrlq mm1, 1        //1 shift para a direita (divide por 2, sem precisão)

					movq mm2, pixel		//registrador mm2 recebe o valor do pixel atual
					psrlq mm2, 16		//realiza um shift lógico para direita para pegar o 3 byte
					pand mm2, mascara	//valor de mm2 recebe uma mascara para selecionar seu 1 byte menos significativo (R)
					paddd mm2, mascara //acresce 255d a R
					psrlq mm2, 1        //1 shift para a direita (divide por 2, sem precisão)

					movq mm3, pixel     // mm3 <- pixel atual
					psrlq mm3, 24       // mm3 <- canal alpha

					pxor mm4, mm4       //garante que o registrador mm4 esta vazio
					paddd mm4, mm3      //adiciona o canal alpha ao mm4
					psllq mm4, 8        //shift para o proximo byte
					paddd mm4, mm2      //copia o canal R (mm2) para mm4
					psllq mm4, 8		//um shift para esquerda em 1 byte
					paddd mm4, mm1		//copia o canal G (mm1) para mm4
					psllq mm4, 8		//novamente um shift para esquerda em 1 byte
					paddd mm4, mm0		//copia o canal B (mm0) para mm4

					movq pixel, mm4     //retorna para a variavel alto nivel os novos valores do pixel
			}

			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			pixel = next;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
		} while (--width > 0);
	} while (--height > 0);
}


// Grupo 7 - invertImage
void CMMXSurface32Intrinsic::Invert()
{
    ULONGLONG mascara = 0xFFFFFFFFFFFFFFFF;		//o valor do pixel sera subtraido dessa mascara

	DWORD *pCur  = (DWORD *)GetPixelAddress(0,0);
	ULONGLONG pixels;

	int height = GetVisibleHeight();
	while (height--)
	{
		int width = m_width;	//m_width = (width+1)/2; pois editamos 2 pixels por iteracao
		while(width--)
		{
			pixels = *(ULONGLONG *)pCur;

			__asm
			{
					movq mm0, pixels	// registrador mm0 recebe 2 pixels
					movq mm1, mascara	// registrador mm1 recebe valor da mascara
					psubb mm1, mm0		// mascara - pixel1 e mascara - pixel2
					movq pixels, mm1    // pixel recebe os dois pixels já invertidos
			}

			// Imprime dois pixels na tela
			*(ULONGLONG *)pCur = pixels;

			pCur += 2;
		}
	}
}

// GRUPO 18 - Filtro Solarize
void CMMXSurface32Intrinsic::Solarize()
{
	DWORD *pCur  = (DWORD *)GetPixelAddress(0,0);			// Ponteiro para o início dos pixels
	int i, j;
	int hei = GetVisibleHeight(), wid = GetVisibleWidth();

	for(i=0;i<hei;i++)
		for(j=0;j<wid;j++) {

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

void CMMXSurface32Intrinsic::MandelBrot()
{

}

//Grupo 17
void CMMXSurface32Intrinsic::Rescale()
{
	int height = GetVisibleHeight()*2;
	DWORD *pCur  = (DWORD *)GetPixelAddress(0,0);
	ULONGLONG mascara = 0xFF;
	ULONGLONG pixel;
	ULONGLONG next;

	pixel = *(ULONGLONG *)pCur;
	do
	{
		int width = m_width;
		do
		{
			next = *(ULONGLONG *)(pCur+1);
			__asm
			{
				movq mm0, pixel		//mm0 = pixel atual
				pand mm0, mascara	//mm0 = a componente 'B'
				pxor mm5, mm5
				paddusb mm0, mm0	//adiciona a si próprio (multiplica por 2)


				movq mm1, pixel		//mm0 = pixel, novamente
				psrlq mm1, 8		//shift à direita para pegar a componente 'G' do pixel
				pand mm1, mascara
				paddusb mm1, mm1	//adiciona a si próprio (multiplica por 2)

				movq mm2, pixel
				psrlq mm2, 16		//mm0 = a componente 'R'
				pand mm2, mascara
				paddusb mm2, mm2	//adiciona a si próprio (multiplica por 2)

				movq mm3, pixel		//mm3 = pixel

				pxor mm4, mm4       //garante que o registrador mm4 esta vazio
				paddd mm4, mm3      //adiciona o canal alpha ao mm4
				psllq mm4, 8        //shift para o proximo byte
				paddd mm4, mm2      //copia o canal R (mm2) para mm4
				psllq mm4, 8		//um shift para esquerda em 1 byte
				paddd mm4, mm1		//copia o canal G (mm1) para mm4
				psllq mm4, 8		//novamente um shift para esquerda em 1 byte
				paddd mm4, mm0		//copia o canal B (mm0) para mm4
				movq pixel, mm4
				}
			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			pixel = next;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
		} while (--width > 0);
	} while (--height > 0);

}

 // Grupo 11
void CMMXSurface32Intrinsic::ChannelMix() {
	int height = GetVisibleHeight()*2;	//altura multiplicada por 2 pois são pixels de 32 bits em variáveis de 64 bits (2x maior)
	DWORD *pCur  = (DWORD *)GetPixelAddress(0,0);	// cada pixel tem 32bits, 1byte para cada canal de cor: alfa, red, green, blue

	// Variaveis do tipo unsigned long long, de 64 bits
	ULONGLONG mascara = 0xFF;	//seleciona um byte de alguma variável (utilizada para pegar valores individuais de RGB)	
	ULONGLONG pixel;	//recebe os valores referentes a um ponto da tela
	ULONGLONG next;		//recebe os valores do próximo ponto a partir de pixel 
	ULONGLONG mascara2 = 0xFFFFFFFF;  //usada para zerar os 32 primeiros bits de um registrador

	pixel = *(ULONGLONG *)pCur;	//faz um casting 64 bits dos dados do ponto atual na variável pixel

	//loops para percorrer toda a tela
	do {
		int width = m_width;
		do {

			next = *(ULONGLONG *)(pCur+1);	//próximo ponto recebe o ponteiro que aponta para um ponto na tela + 1

			//utilização dos registradores mmx 64 bits com inline assembly 
			__asm{
					movq mm0, pixel	//move o pixel para um registrador
					pand mm0, mascara2	//aplica a mascara2 para garantir que os 32 primeiros bits são zeros
					movq mm1, pixel	//repete o processo em outro registrador
					pand mm1, mascara2
					pslld mm1, 32		//faz em mm1 um shift de 32 bits pra esquerda
					paddd mm0, mm1		//adiciona o valor de mm1 em mm2, assim a dword mais significativa fica igual à menos significativa

					movq mm1, mm0		//copia mm0 para mm1
					pand mm1, mascara	//aplica a mascara para isolar o byte menos significativo
					pslld mm1, 56		//faz um shift para a esquerda de 56 bits para colocar o byte na posição mais significativa do registrador

					psrld mm0, 8		//shift a direita em mm0, de 1 byte
					paddd mm0, mm1		//adiciona mm1 à mm0, colocando o byte isolado em mm1, na posição mais significativa de mm0

					movq pixel, mm0	//copia o valor de mm0 para o pixel	
			}

			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			pixel = next;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
		} while (--width > 0);
	} while (--height > 0);
}
////////////////////////////////////////////Rodrigo

void CMMXSurface32Intrinsic::Ciano() {
	int height = GetVisibleHeight()*2;	//altura multiplicada por 2 pois são pixels de 32 bits em variáveis de 64 bits (2x maior)
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
					movq mm1, pixel
					psllq mm1, 8
					por mm1,mm0

					movq pixel, mm1	//mm0 agora possui os valores médios RGB (GrayScale), então salva isso em pixel
			}

			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			pixel = next;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
		} while (--width > 0);
	} while (--height > 0);
}

void CMMXSurface32Intrinsic::Magenta() {
	int height = GetVisibleHeight()*2;	//altura multiplicada por 2 pois são pixels de 32 bits em variáveis de 64 bits (2x maior)
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
					movq mm1, pixel
					psllq mm1, 16
					por mm1,mm0

					movq pixel, mm1	//mm0 agora possui os valores médios RGB (GrayScale), então salva isso em pixel
			}

			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			pixel = next;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
		} while (--width > 0);
	} while (--height > 0);
}
// Grupo 20
void CMMXSurface32Intrinsic::Amarelar() {
	int height = GetVisibleHeight()*2;	//altura multiplicada por 2 pois são pixels de 32 bits em variáveis de 64 bits (2x maior)
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
					psllq mm0, 24
					movq pixel, mm0		//mm1 agora possui os valores médios RGB (GrayScale), então salva isso em pixel
			}
			
			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			pixel = next;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
		} while (--width > 0);
	} while (--height > 0);
}

// Grupo 2012
void CMMXSurface32Intrinsic::RB3D() {
	//altura multiplicada por 2 pois são pixels de 32 bits em variáveis de 64 bits (2x maior)
	DWORD *pCur  = (DWORD *)GetPixelAddress(0,0);	// cada pixel tem 32bits, 1byte para cada canal de cor: alfa, red, green, blue

	// Variaveis do tipo unsigned long long, de 64 bits
	ULONGLONG mascara = 0xFF;	//seleciona um byte de alguma variável (utilizada para pegar valores individuais de RGB)	
	ULONGLONG mascara2 = 0xFFFFFF00;
	ULONGLONG mascara3 = 0xFF0000;
	ULONGLONG mascara4 = 0xFF00FFFF;
	ULONGLONG pixel;	//recebe os valores referentes a um ponto da tela
	ULONGLONG direito, esquerdo=0;		//recebe os valores do próximo ponto a partir de pixel 
	int t=100, u=100;

	pixel = *(ULONGLONG *)pCur;	//faz um casting 64 bits dos dados do ponto atual na variável pixel
	for (int i=0; i<30; i++){
	//loops para percorrer toda a tela
	do {
		do {

			direito = *(ULONGLONG *)(pCur+1);	//próximo ponto recebe o ponteiro que aponta para um ponto na tela + 1

			//utilização dos registradores mmx 64 bits com inline assembly 
			__asm{
					movq mm0, pixel		//registrador mm0 reebe o valor do pixel atual
					pand mm0, mascara	//valor de mm0 recebe uma mascara para selecionar seu 1 byte menos significativo (B)
					movq mm1, direito
					pand mm1, mascara2
					paddd mm1, mm0
					movq direito, mm1
										
					movq mm0, pixel		//recarrega o valor do pixel em mm0
					pand mm0, mascara3
					movq mm1, esquerdo
					pand mm1, mascara4	//utiliza mascara para isolar um byte (R)
					paddd mm1, mm0
					movq esquerdo, mm1

				
					
			}


	
			
			*(ULONGLONG *)pCur = pixel;		//joga o resultado no ponto apontado da tela
			*(ULONGLONG *)(pCur+1) = direito;
			*(ULONGLONG *)(pCur-1) = esquerdo;
			esquerdo = pixel;
			pixel = direito;					//recebe o próximo pixel a ser processado
			pCur++;							//avança o ponteiro sobre a tela
		} while (--t > 0);
	} while (--u > 0);
}
}

void CMMXSurface32Intrinsic::Median() {
	
}
