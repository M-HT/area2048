/*
	D-System 'LUMINOUS'

		'luminous.d'

	2004/01/30 jumpei isshiki
*/

private	import std.math;
private	import std.string;
version (USE_GLES) {
	private	import	opengles;
	private	import	opengles_fbo;
	alias	glOrthof	glOrtho;
} else {
	private	import opengl;
}
private	import util_sdl;
private	import task;

private	GLuint		luminousTexture;
private	const int	LUMINOUS_TEXTURE_WIDTH_MAX = 64;
private	const int	LUMINOUS_TEXTURE_HEIGHT_MAX = 64;
private	GLuint[LUMINOUS_TEXTURE_WIDTH_MAX * LUMINOUS_TEXTURE_HEIGHT_MAX * 4 * uint.sizeof]	td;
private	int			luminousTextureWidth = 64, luminousTextureHeight = 64;
private	int			screenWidth, screenHeight, screenStartx, screenStarty;
private	float		luminous;
version (USE_GLES) {
	private	GLuint	luminousFramebuffer;
}

private	int[2][5]	lmOfs = [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]];
private	const float	lmOfsBs = 5;

void	TSKluminous(int id)
{
	switch(TskBuf[id].step){
		case	0:
		    glLineWidth(1);
		    glEnable(GL_LINE_SMOOTH);
		    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		    glEnable(GL_BLEND);
		    glDisable(GL_LIGHTING);
		    glDisable(GL_CULL_FACE);
		    glDisable(GL_DEPTH_TEST);
		    glDisable(GL_TEXTURE_2D);
		    glDisable(GL_COLOR_MATERIAL);
			//init(0.0f,640,480);
			init(0.0f,util_sdl.startx, util_sdl.starty, SCREEN_X,SCREEN_Y);
			TskBuf[id].fp_draw = &TSKluminousDraw;
			TskBuf[id].step++;
			break;
		case	1:
			break;
		default:
			close();
			clrTSK(id);
			break;
	}
	return;
}

void	TSKluminousDraw(int id)
{
	startRenderToTexture();
	draw();
	endRenderToTexture();
}

/*----------------------------------------------------------------------------*/

static	void	init(float lumi, int startx, int starty, int width, int height)
{
	makeLuminousTexture();
	luminous = lumi;
	resized(startx, starty, width, height);
}

static	void	makeLuminousTexture()
{
	uint *data = cast(uint*)td;
	int i;

	//memset(data, 0, luminousTextureWidth * luminousTextureHeight * 4 * uint.sizeof);
	td[0..$] = 0;
	glGenTextures(1, &luminousTexture);
	glBindTexture(GL_TEXTURE_2D, luminousTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, luminousTextureWidth, luminousTextureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	version (USE_GLES) {
		glGenFramebuffersOES(1, &luminousFramebuffer);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, luminousFramebuffer);
		glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, luminousTexture, 0);
		glClear(GL_COLOR_BUFFER_BIT);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
    }
}

static	void	resized(int startx, int starty, int width, int height)
{
	screenStartx = startx;
	screenStarty = starty;
	screenWidth = width;
	screenHeight = height;
}

static	void	close()
{
	glDeleteTextures(1, &luminousTexture);
	version (USE_GLES) {
		glDeleteFramebuffersOES(1, &luminousFramebuffer);
	}
}

static	void	startRenderToTexture()
{
	version (USE_GLES) {
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, luminousFramebuffer);
		glClear(GL_COLOR_BUFFER_BIT);
	}
	glViewport(0, 0, luminousTextureWidth, luminousTextureHeight);
}

static	void	endRenderToTexture()
{
	version (USE_GLES) {
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
	} else {
		glBindTexture(GL_TEXTURE_2D, luminousTexture);
		glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, luminousTextureWidth, luminousTextureHeight, 0);
	}
	//glViewport(0, 0, screenWidth, screenHeight);
	glViewport(screenStartx + (SCREEN_X / 2) - screenWidth / 2, screenStarty + (SCREEN_Y / 2) - screenHeight / 2, screenWidth, screenHeight);
}

static	void	viewOrtho()
{
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrtho(0, screenWidth, screenHeight, 0, -1, 1);
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
}

static	void	viewPerspective()
{
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
}

static	void	draw()
{
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, luminousTexture);
	viewOrtho();
	glColor4f(1, 0.8, 0.9, luminous);
	{
		static	const	GLfloat[2*4]	luminousTexCoords = [
			0, 1,
			0, 0,
			1, 0,
			1, 1
		];
		GLfloat[2*4]	luminousVertices;

		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);

		glVertexPointer(2, GL_FLOAT, 0, cast(void *)(luminousVertices.ptr));
		glTexCoordPointer(2, GL_FLOAT, 0, cast(void *)(luminousTexCoords.ptr));

		foreach (i; 0..5) {
			luminousVertices[0] = 0 + lmOfs[i][0] * lmOfsBs;
			luminousVertices[1] = 0 + lmOfs[i][1] * lmOfsBs;

			luminousVertices[2] = 0 + lmOfs[i][0] * lmOfsBs;
			luminousVertices[3] = screenHeight + lmOfs[i][1] * lmOfsBs;

			luminousVertices[4] = screenWidth + lmOfs[i][0] * lmOfsBs;
			luminousVertices[5] = screenHeight + lmOfs[i][0] * lmOfsBs;

			luminousVertices[6] = screenWidth + lmOfs[i][0] * lmOfsBs;
			luminousVertices[7] = 0 + lmOfs[i][0] * lmOfsBs;

			glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
		}

		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);
	}
	viewPerspective();
	glDisable(GL_TEXTURE_2D);
}
