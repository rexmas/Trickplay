#include "tp_opengles.h"

void* tp_egl_get_native_window(void)
{
	return TP_OpenGLES_GetEGLNativeWindow();
}

void* tp_egl_get_native_display(void)
{
    return (void*)2;
}

