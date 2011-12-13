// MMXSurface.h : interface of the MMX Specific Surface classes
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
#include "Surface.h"

class CMMXSurface32Intrinsic : public CSurface
{
public:
	virtual void AdjustWidth(int *pWidth);
	virtual void BlurBits(); // this is where the MMX action is
	virtual void GrayScale();	//Grupo 4
	virtual void Azular();		// Grupo 5
	virtual void Esverdear();		// Grupo 5
	virtual void Envermelhar();		// Grupo 5
	virtual void Posterize();	// Grupo 9
	virtual void GrayFilter();  // Grupo 12
	virtual void RGBAdjust();	// Grupo 14
	virtual void Mask();		// Grupo 15
	virtual void Threshold();    //grupo 13
	virtual void Invert();   //GRUPO 7
	virtual void Solarize();	// Grupo 18
	virtual void Gradient();	//Grupo 8
	virtual void MandelBrot();
	virtual void Rescale();      // grupo 17
protected:
	virtual void OnCreated();
private:
	int m_dwpl;  // dwords per line
	int m_width; // number of times to iterate per line
};

class CMMXSurface24Intrinsic : public CSurface
{
public:
	virtual void BlurBits(); // this is where the MMX action is	
	virtual void Posterize();	// Grupo 9
protected:
	virtual void OnCreated();
private:
	int m_dwpl;  // dwords per line
	int m_width; // number of times to iterate per line
	int m_delta; // number of pointer units to get from end of line to start of next
};

class CMMXSurface16Intrinsic : public CSurface
{
public:
	virtual void AdjustWidth(int *pWidth);
	virtual void BlurBits(); // this is where the MMX action is	
	virtual void Posterize();	// Grupo 9
protected:
	virtual void OnCreated();
private:
	int m_qwpl;  // qwords per line
	int m_width; // number of times to iterate per line
};
