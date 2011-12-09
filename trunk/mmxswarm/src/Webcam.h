// Grupo 16

#ifndef WEBCAM_H
#define WEBCAM_H

#include "Surface.h"

#ifdef USE_OPENCV
#include <cv.h>
#include <highgui.h>

using namespace cv;
#endif

class CWebcam
{
private:
	
	#ifdef USE_OPENCV
	// Representa uma captura da webcam
	static CvCapture * capture;
	#endif

public:
	static void Capture(CSurface * surf);
	static void Release();

	#ifdef USE_OPENCV
	inline static bool CaptureIsNull() { return capture == NULL; }
	#endif
};

#endif