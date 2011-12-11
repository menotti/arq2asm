// ChildView.h : interface of the CChildView class
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
#include "MMXSurface.h"
#include "Swarm.h"

/////////////////////////////////////////////////////////////////////////////
// CChildView window

class CChildView : public CWnd
{
	// Construction
public:
	CChildView();

	// Attributes
public:

	// Operations
public:
	BOOL OnIdle(LONG lCount);
	CSurface *GetSurface() const
	{ return(m_pSurface); }

	// Overrides
protected:
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);

	// Implementation
public:
	virtual ~CChildView();

	// Generated message map functions
protected:
	//{{AFX_MSG(CChildView)
	afx_msg void OnPaint();
	afx_msg void OnTimer(UINT_PTR nIDEvent);
	afx_msg void OnSize(UINT nType, int cx, int cy);
	afx_msg BOOL OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message);
	afx_msg void OnUpdateFPS(CCmdUI* pCmdUI);
	afx_msg void OnUpdatePauseBlur(CCmdUI* pCmdUI);
	afx_msg void OnUpdatePauseSwarm(CCmdUI* pCmdUI);
	afx_msg void OnUpdatePauseBlit(CCmdUI* pCmdUI);
	afx_msg void OnUpdateUseFade(CCmdUI* pCmdUI);
	afx_msg void OnUpdateUseGray(CCmdUI* pCmdUI);	//Grupo 4
	afx_msg void OnUpdateUseGradient(CCmdUI* pCmdUI);	//Grupo 8
	afx_msg void OnUpdateUseSobel(CCmdUI* pCmdUI);//Grupo 5
	afx_msg void OnUpdateUsePosterize(CCmdUI* pCmdUI);//Grupo 9
	afx_msg void OnUpdateUseGrayF(CCmdUI* pCmdUI);	//Grupo 12
	afx_msg void OnUpdateUseRGBAdjust(CCmdUI* pCmdUI);	//Grupo 14
	afx_msg void OnUpdateUseMask(CCmdUI* pCmdUI);	//Grupo 15
	afx_msg void OnUpdateUseMandel(CCmdUI* pCmdUI);	//Grupo 6
	afx_msg void OnUpdateUseSolarize(CCmdUI* pCmdUI);//Grupo 18
	afx_msg void OnUpdateUseThreshold(CCmdUI* pCmdUI); //grupo 13
	afx_msg void OnUpdateUseChannelmix(CCmdUI* pCmdUI); //Grupo 11
	afx_msg void OnUpdateUseInvert(CCmdUI* pCmdUI); //grupo 7
	afx_msg void OnUpdateModeWebcam(CCmdUI* pCmdUI); //grupo 16
	afx_msg void OnUpdateResolution(CCmdUI* pCmdUI);
	afx_msg void OnUpdateImageFormats(CCmdUI* pCmdUI);
	afx_msg void OnFileOpen();
	afx_msg void OnFileSave();
	afx_msg void OnFileOpenStatic();  //abrir unica imagem - grupo 7
	afx_msg void OnViewPauseBlur();
	afx_msg void OnViewPauseSwarm();
	afx_msg void OnViewPauseBlit();
	afx_msg void OnViewUseFade();
	afx_msg void OnViewUseGray();	//Grupo 4
	afx_msg void OnViewUseGradient();	//Grupo 8
	afx_msg void OnViewUseSobel();//Grupo 5
	afx_msg void OnViewUsePosterize();	//Grupo 9
	afx_msg void OnViewUseGrayF();	//Grupo 12
	afx_msg void OnViewUseRGBAdjust(); //Grupo 14
	afx_msg void OnViewUseMask(); //Grupo 15
	afx_msg void OnViewUseMandel(); //Grupo 6
	afx_msg void OnViewUseSolarize();//Grupo 18
	afx_msg void OnViewUseThreshold(); //grupo 13
	afx_msg void OnViewUseChannelmix(); //Grupo 11
	afx_msg void OnViewUseInvert(); //grupo 7
	afx_msg void OnModeWebcam();	//grupo 16
	afx_msg void OnImageFormats(UINT nID);
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
private:
	enum ESurface {
		eNone				= 0,
		e16BitSSE2Intrin	= IDD_16BIT_SSE2INTRINSICS,
		e16BitMMXIntrin		= IDD_16BIT_MMXINTRINSICS,
		e16BitGeneric		= IDD_16BIT_GENERICCBLUR,
		e24BitSSE2Intrin	= IDD_24BIT_SSE2INTRINSICS,
		e24BitMMXIntrin		= IDD_24BIT_MMXINTRINSICS,
		e24BitGeneric		= IDD_24BIT_GENERICCBLUR,
		e32BitSSE2Intrin	= IDD_32BIT_SSE2INTRINSICS,
		e32BitMMXIntrin		= IDD_32BIT_MMXINTRINSICS,
		e32BitGeneric		= IDD_32BIT_GENERICCBLUR,
	};

	void CreateSurface();

	ESurface  m_eSurf;
	CSurface *m_pSurface;
	CSwarm	  m_swarm;

	int		m_nFrameCounter;
	int		m_nFilterLoad; // remember file/open filter
	int		m_nFilterSave; // remember file/save filter
	DWORD	m_dwTickStart;
	bool	m_bSizeChanged;
	bool	m_bPauseBlur;	
	bool	m_bPauseSwarm;
	bool	m_bPauseBlit;
	bool	m_bPauseFade;
	bool	m_bUseGray;  //Grupo 4
	bool	m_bUseGradient;  //Grupo 8
	bool	m_bUseSobel;//Grupo 5
	bool	m_bUsePosterize;//Grupo 9
	bool	m_bUseGrayF;  //Grupo 12
	bool	m_bUseRGBAdjust; //Grupo 14
	bool	m_bUseMask; //Grupo 15
	bool	m_bUseMandel; //Grupo 6
	bool	m_bUseSolarize;//Grupo 18
	bool m_bUseThreshold; //grupo 13
	bool m_bUseChannelmix; //Grupo 11
	bool m_bUseInvert; //grupo 7
	bool m_bTimerPopped;
	bool	execSobel;//Grupo 5 - Verifica se executou o Sobel alguma vez quando fadeIn estEoff
	bool	execGray; //grupo 12
	bool m_bUseStatic; //STATIC MODE - grupo 7
	bool m_bUseWebcam;	// Grupo 16

	static const UINT_PTR m_kTimerID = 31;
	static const UINT m_kTimerDelay = 1500;
public:
	afx_msg void OnDestroy(void);
};

