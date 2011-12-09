// Grupo 16

#ifndef WEBCAM_H
#define WEBCAM_H

#include "Surface.h"

#include <cv.h>
#include <highgui.h>

using namespace cv;

class CWebcam
{
private:
	// Representa uma captura da webcam
	static CvCapture * capture;

public:
	static void Capture(CSurface * surf);
	static void Release();

	inline static bool CaptureIsNull() { return capture == NULL; }
};

#endif