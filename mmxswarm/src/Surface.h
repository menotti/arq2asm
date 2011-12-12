// Surface.h : Defines the interface of a DIB surface for swarm
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
#pragma once

#include <AtlImage.h>

template<class T> T ABS(T x) { return(x < 0 ? -x : x); }

//Grupo 6
//Struct para criação de número complexo.
typedef struct{
	float real;
	float imag;
}Complex;

class CSurface
{
public:
	CSurface() :
	 m_pSrcWnd(NULL), m_hDestDC(NULL),
		 m_wndHeight(0), m_wndWidth(0), m_nBitDepth(0), m_nByteDepth(0), alpha(0), alphadir(1)
	 { 

		 //Grupo 5
		 //Máscara do sobel
		 //X
		 GXS[0][0] = -1; GXS[0][1] = 0; GXS[0][2] = 1;
		 GXS[1][0] = -2; GXS[1][1] = 0; GXS[1][2] = 2;
		 GXS[2][0] = -1; GXS[2][1] = 0; GXS[2][2] = 1;
		 //Y
		 GYS[0][0] = -1; GYS[0][1] = -2; GYS[0][2] = -1;
		 GYS[1][0] = 0; GYS[1][1] = 0; GYS[1][2] = 0;
		 GYS[2][0] = 1; GYS[2][1] = 2; GYS[2][2] = 1;

	 }

	void Import(const CImage &image, const CImage &image2);
	void ImportStatic(const CImage &image);  //Static Mode - grupo 7
	
	//Grupo 5 - Método usado para fazer copiar uma imagem para imagem_m(em exibição)
	void Copy(const CImage &image);
	 virtual ~CSurface()
	 { Destroy(); }

	 void Create(CWnd *pWnd, int nBitDepth); // this is stored internally
	 void Destroy();

	 //void Import(const CImage &image, const CImage &image2);

	 //Grupo 5 - Método usado para fazer copiar uma imagem para imagem_m(em exibição)
	 //void Copy(const CImage &image);

	 void ClearBits();
	 void StripeBits();
	 void RandomBits();
	 void ShiftBits();
	 void BlitBits();
	 virtual void BlurBits(); // this is where the MMX action is

	 //menotti
	 void FadeInOut();

	 //Grupo 4
	 virtual void GrayScale();

	 //Grupo 8
	 virtual void Gradient();

	 //grupo 13
	 virtual void Threshold();

	 //Grupo 11
	virtual void ChannelMix();

	 //Grupo 5
	 virtual void Sobel(); // neste método está a implementação do Sobel

	 //Grupo 12
	 virtual void GrayFilter();

	 void Line(const CPoint &p1, const CPoint &p2, COLORREF c);
	 void RandomLine(COLORREF c);

	 //Grupo 14
	 virtual void RGBAdjust();

	 //Grupo 15
	 virtual void Mask();

	 //Grupo 6
	 int CAL_PIXEL(Complex);
	 virtual void MandelBrot();

	 //GRUPO 7
	 virtual void Invert();

	 // These methods compensate for m_kDelta
	 void PointColor(int x, int y, COLORREF c);

	 //Grupo 5 - Altera o valor de um pixel na imagem temporária
	 void PointColorT(int x, int y, COLORREF c);

	 COLORREF PointColor(int x, int y) const;
	 COLORREF PointColorO(int x, int y) const;
	 COLORREF PointColorD(int x, int y) const;

	 //Grupo 5 - Retorna um pixel da imagem temporária
	 COLORREF PointColorT(int x, int y) const;

	 // GRUPO 9 - Filtro Posterize
	 void setNivel(int n);	// definir numero de niveis
	 int getNivel();
	 virtual void Posterize();	//aplicar filtro
	 void inicializar();			//inicializacao de vetor

	 // GRUPO 18 - Filtro Solarize
	 virtual void Solarize();
	 double Sol(double v);

	 BYTE *GetPixelAddress(int x, int y) const
	 { return((BYTE*)m_image.GetPixelAddress(x, y+m_kDeltaY)); }

	 bool IsNull() const
	 { return(m_image.IsNull()); }
	 int GetVisibleWidth() const
	 { return(m_wndWidth); }
	 int GetVisibleHeight() const
	 { return(m_wndHeight); }
	 int GetPitch() const
	 { return(m_image.GetPitch()); }
	 int GetBitDepth() const
	 { return(m_nBitDepth); }
	 int GetByteDepth() const
	 { return(m_nByteDepth); }

	 CImage *GetImage()
	 { return(&m_image); }

	 // Implementation
protected:
	virtual void AdjustWidth(int * /*pWidth */)	{}
	virtual void OnCreated() {}

	//Grupo 5 - Variáveis do Sobel
	char GXS[3][3];
	char GYS[3][3];

	//Grupo 5 - Imagem auxiliar criada para armazenar o resultado da imagem antes de exibí-la
	int t_nBitDepth;
	HDC t_hDestDC;
	CImage t_image;

	//Grupo 5 - variáveis usadas pelo Sobel
	int	sumX;
	int	sumY;
	int	SUM;
	BYTE r,g,b,NC;
	int piX, piY, x, y, I, J;
	char newPixel;


	// GRUPO 9 - Filtro Posterize
	// variaveis
	int numNivel;
	int nivel[256];
	bool inicializado;

	static const int m_kDeltaX = 1;
	static const int m_kDeltaY = 1;
private:
	CWnd *m_pSrcWnd;
	int m_nByteDepth;
	int m_nBitDepth;
	int m_wndWidth;
	int m_wndHeight;
	HDC m_hDestDC;
	CImage m_image;
	HDC n_hDestDC;
	CImage n_image;
	HDC o_hDestDC;
	CImage o_image;
	float alpha;
	int alphadir;
};

inline void CSurface::PointColor(int x, int y, COLORREF c)
{
	// m_image.SetPixel() call ::SetPixel() which is too slow
	// since it has to work with all DCs.

	BYTE *p = (BYTE*)m_image.GetPixelAddress(x, y+m_kDeltaY);
	if (m_nBitDepth == 16) {
		*(WORD *)p = (WORD)(((c&0xf80000) >> 19) | ((c&0xf800) >> 6) | ((c&0xf8) << 7));
	}
	else {
		*p++ = GetBValue(c);
		*p++ = GetGValue(c);
		*p = GetRValue(c);
	}
}

// Somewhat poor form - for performance reasons these
// come back with R and B exchanged.
inline COLORREF CSurface::PointColor(int x, int y) const
{ 
	// m_image.GetPixel() calls ::GetPixel() which is too slow
	// since it has to work for all types of DCs.
	if (m_nBitDepth == 16) {
		COLORREF c = (COLORREF)*(WORD*)m_image.GetPixelAddress(x, y+m_kDeltaY);
		return((c&0x7c00) << 9 | (c&0x3e0) << 6 | (c&0x1f) << 3);		
	}
	else {
		return(*(COLORREF*)(m_image.GetPixelAddress(x, y+m_kDeltaY))); 
	}
}

inline COLORREF CSurface::PointColorO(int x, int y) const
{ 
	// m_image.GetPixel() calls ::GetPixel() which is too slow
	// since it has to work for all types of DCs.
	if (m_nBitDepth == 16) {
		COLORREF c = (COLORREF)*(WORD*)o_image.GetPixelAddress(x, y+m_kDeltaY);
		return((c&0x7c00) << 9 | (c&0x3e0) << 6 | (c&0x1f) << 3);		
	}
	else {
		return(*(COLORREF*)(o_image.GetPixelAddress(x, y+m_kDeltaY))); 
	}
}

inline COLORREF CSurface::PointColorD(int x, int y) const
{ 
	// m_image.GetPixel() calls ::GetPixel() which is too slow
	// since it has to work for all types of DCs.
	if (m_nBitDepth == 16) {
		COLORREF c = (COLORREF)*(WORD*)n_image.GetPixelAddress(x, y+m_kDeltaY);
		return((c&0x7c00) << 9 | (c&0x3e0) << 6 | (c&0x1f) << 3);		
	}
	else {
		return(*(COLORREF*)(n_image.GetPixelAddress(x, y+m_kDeltaY))); 
	}
}

//Grupo 5
inline void CSurface::PointColorT(int x, int y, COLORREF c)
{
	// m_image.SetPixel() call ::SetPixel() which is too slow
	// since it has to work with all DCs.

	BYTE *p = (BYTE*)t_image.GetPixelAddress(x, y+m_kDeltaY);
	if (m_nBitDepth == 16) {
		*(WORD *)p = (WORD)(((c&0xf80000) >> 19) | ((c&0xf800) >> 6) | ((c&0xf8) << 7));
	}
	else {
		*p++ = GetBValue(c);
		*p++ = GetGValue(c);
		*p = GetRValue(c);
	}
}

//Grupo 5
inline COLORREF CSurface::PointColorT(int x, int y) const
{ 
	// m_image.GetPixel() calls ::GetPixel() which is too slow
	// since it has to work for all types of DCs.
	if (m_nBitDepth == 16) {
		COLORREF c = (COLORREF)*(WORD*)t_image.GetPixelAddress(x, y+m_kDeltaY);
		return((c&0x7c00) << 9 | (c&0x3e0) << 6 | (c&0x1f) << 3);		
	}
	else {
		return(*(COLORREF*)(t_image.GetPixelAddress(x, y+m_kDeltaY))); 
	}
}
