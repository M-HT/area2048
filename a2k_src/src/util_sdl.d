/*
	D-System 'SDL UTILITY'

		'util_sdl.d'

	2003/11/28 jumpei isshiki
*/

private	import	std.string;
private import core.stdc.stdio;
private	import	SDL;
version (USE_GLES) {
	private	import opengles;
	private	import opengles_fbo;
	private	import eglport;
	alias	glFrustumf	glFrustum;
} else {
	private	import	opengl;
}
private	import	define;

enum{
	SURFACE_MAX = 100,
	SCREEN_X = 640,
	SCREEN_Y = 480,
	SCREEN_S = SCREEN_Y,

	X = 0,
	Y,
	Z,
	W,
	XY = 2,
	XYZ = 3,
	XYZW = 4,

	SX = 0,
	SY,
	EX,
	EY,
}


SDL_Surface*	primary;
SDL_Surface*[]	offscreen;

const float	BASE_Z = 2.0f;
float		cam_scr = -0.75f;
float		cam_pos;

private	int		width = SCREEN_X;
private	int		height = SCREEN_Y;
public	int		startx = 0;
public	int		starty = 0;
private	float	nearPlane = 0.0f;
private	float	farPlane = 1000.0f;

private	GLuint[]	tex_bank;

int		initSDL()
{
	if(SDL_Init(SDL_INIT_VIDEO) < 0){
		return	0;
    }

	Uint32	videoFlags;
	version (USE_GLES) {
		videoFlags = SDL_SWSURFACE;
	} else {
		videoFlags = SDL_OPENGL;
	}
	version (PANDORA) {
		videoFlags |= SDL_FULLSCREEN;
	} else {
		debug{
			videoFlags |= SDL_RESIZABLE;
		}
	}
	int physical_width = width;
	int physical_height = height;
	version (PANDORA) {
		physical_width = 800;
		physical_height = 480;
		startx = (800 - width) / 2;
		starty = (480 - height) / 2;
	}
	primary = SDL_SetVideoMode(physical_width, physical_height, 0, videoFlags);
	if(primary == null){
		return	0;
	}
	version (USE_GLES) {
		if (EGL_Open(cast(ushort)physical_width, cast(ushort)physical_height) != 0) {
			return	0;
		}

		if (!loadFBOExtension()) {
			return	0;
		}
	}

	offscreen.length = SURFACE_MAX;
	tex_bank.length  = SURFACE_MAX;
	for(int i = 0; i < SURFACE_MAX; i++){
		offscreen[i] = null;
		tex_bank[i]  = cast(GLuint)-1;
	}

	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    resizedSDL(width, height);
	SDL_ShowCursor(SDL_DISABLE);

	SDL_WM_SetCaption(toStringz(PROJECT_NAME), null);

	return	1;
}


void	closeSDL()
{
	for(int i = 0; i < SURFACE_MAX; i++){
		if(tex_bank[i] != -1){
			glDeleteTextures(1, &tex_bank[i]);
			printf("free texture bank %d.\n",i);
		}
		if(offscreen[i]){
			SDL_FreeSurface(offscreen[i]);
			printf("free off-screen surface %d.\n",i);
		}
	}

	version (USE_GLES) {
		EGL_Close();
	}
	SDL_ShowCursor(SDL_ENABLE);
	SDL_Quit();
}


void	readSDLtexture(const char[] fname, int bank)
{
	offscreen[bank] = SDL_LoadBMP(toStringz(fname));
	if(offscreen[bank]){
		glGenTextures(1, &tex_bank[bank]);
		glBindTexture(GL_TEXTURE_2D, tex_bank[bank]);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, offscreen[bank].w, offscreen[bank].h, 0, GL_RGB, GL_UNSIGNED_BYTE, offscreen[bank].pixels);
		glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	}
}


void	bindSDLtexture(int bank)
{
	if(tex_bank[bank] != -1) glBindTexture(GL_TEXTURE_2D, tex_bank[bank]);
}


void	clearSDL()
{
	glClear(GL_COLOR_BUFFER_BIT);
}


void	flipSDL()
{
	glFlush();
	version (USE_GLES) {
		EGL_SwapBuffers();
	} else {
		SDL_GL_SwapBuffers();
	}
}


void	resizedSDL(int w, int h)
{
	glViewport(startx, starty, w, h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	if (nearPlane != 0.0f) {
		glFrustum(-nearPlane,nearPlane,
				  -nearPlane * h / w,
				   nearPlane * h / w,
				  0.1f, farPlane);
	}
	glMatrixMode(GL_MODELVIEW);
}

float	getPointX(float p,float z)
{
	return	p / SCREEN_X * (z + cam_pos);
}

float	getPointY(float p,float z)
{
	return	p / SCREEN_Y * (z + cam_pos);
}

