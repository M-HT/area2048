/*
	D-System 'SDL UTILITY'

		'util_sdl.d'

	2003/11/28 jumpei isshiki
*/

private	import	std.string;
private import core.stdc.stdio;
private	import	bindbc.sdl;
private	import	opengl;
private	import	define;

version(PANDORA) version = FORCE_FULLSCREEN;
version(PYRA) version = FORCE_FULLSCREEN;

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


SDL_Window*	window;
SDL_GLContext	context;
SDL_Surface*[]	offscreen;

const float	BASE_Z = 2.0f;
float		cam_scr = -0.75f;
float		cam_pos;

int	screenWidth, screenHeight, screenStartx, screenStarty;

private	int		width = SCREEN_X;
private	int		height = SCREEN_Y;
private	float	nearPlane = 0.0f;
private	float	farPlane = 1000.0f;

private	GLuint[]	tex_bank;

int		initSDL()
{
	if(SDL_Init(SDL_INIT_VIDEO) < 0){
		return	0;
    }

	uint	videoFlags;
	//videoFlags = SDL_WINDOW_OPENGL | SDL_WINDOW_FULLSCREEN_DESKTOP;
	videoFlags = SDL_WINDOW_OPENGL;
	//videoFlags = SDL_WINDOW_OPENGL | SDL_RESIZABLE;
	version (FORCE_FULLSCREEN) {
		videoFlags |= SDL_WINDOW_FULLSCREEN_DESKTOP;
	} else {
		debug{
			videoFlags |= SDL_WINDOW_RESIZABLE;
		}
	}
    window = SDL_CreateWindow(toStringz(PROJECT_NAME), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, videoFlags);
	if(window == null){
		return	0;
	}
	context = SDL_GL_CreateContext(window);
	if(context == null){
		SDL_DestroyWindow(window);
		return	0;
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

	SDL_ShowCursor(SDL_ENABLE);
	SDL_GL_DeleteContext(context);
	SDL_DestroyWindow(window);
	SDL_Quit();
}


void	readSDLtexture(const char[] fname, int bank)
{
	offscreen[bank] = SDL_LoadBMP(toStringz(fname));
	if(offscreen[bank]){
		glGenTextures(1, &tex_bank[bank]);
		glBindTexture(GL_TEXTURE_2D, tex_bank[bank]);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, offscreen[bank].w, offscreen[bank].h, 0, GL_RGB, GL_UNSIGNED_BYTE, offscreen[bank].pixels);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
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
	SDL_GL_SwapWindow(window);
}


void	resizedSDL(int w, int h)
{
	screenStartx = 0;
	screenStarty = 0;
	screenWidth = w;
	screenHeight = h;
	static if(SDL_VERSION_ATLEAST(2, 0, 1)) {
		SDL_version linked;
		SDL_GetVersion(&linked);
		if (SDL_version(linked.major, linked.minor, linked.patch) >= SDL_version(2, 0, 1)) {
			int glwidth, glheight;
			SDL_GL_GetDrawableSize(window, &glwidth, &glheight);
			if (SDL_GetWindowFlags(window) & SDL_WINDOW_FULLSCREEN_DESKTOP) {
				if ((cast(float)(glwidth)) / w <= (cast(float)(glheight)) / h) {
					screenStartx = 0;
					screenWidth = glwidth;
					screenHeight = (glwidth * h) / w;
					screenStarty = (glheight - screenHeight) / 2;
				} else {
					screenStarty = 0;
					screenHeight = glheight;
					screenWidth = (glheight * w) / h;
					screenStartx = (glwidth - screenWidth) / 2;
				}
			} else {
				screenWidth = glwidth;
				screenHeight = glheight;
			}
		}
	}
	glViewport(screenStartx, screenStarty, screenWidth, screenHeight);
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

