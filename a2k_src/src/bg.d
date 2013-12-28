/*
	area2048 'BG'

		'bg.d'

	2004/02/05 jumpei isshiki
*/

private	import	std.math;
private	import	main;
private	import	SDL;
version (USE_GLES) {
	private	import	opengles;
} else {
	private	import opengl;
}
private	import	util_sdl;
private	import	util_snd;
private	import	define;
private	import	task;
private	import	stg;
private	import	effect;
private	import	ship;

struct BG_OBJ {
	float[XY]		pos;
	float[XYZW][]	body_list;
	float[XYZW][]	line_list;
}

float[XY]	scr_pos;
float[XY]	scr_base;
float[XY]	scr_ofs;

int	bg_disp;
int	bg_id;

private	BG_OBJ[]	bg_obj;
private	int			bg_mode;


version (PANDORA) {
    // these functions work, because the projection and modelview matrices are identity matrices
    private bool isOutside(ref GLfloat[] vertices) {
        int numVertices = cast(int)(vertices.length / XYZ);
        bool outside[4] = true;
        foreach(i; 0..numVertices) {
            if (vertices[3*i + 0] <= 1.0f) outside[0] = false;
            if (vertices[3*i + 0] >= -1.0f) outside[1] = false;
            if (vertices[3*i + 1] <= 1.0f) outside[2] = false;
            if (vertices[3*i + 1] >= -1.0f) outside[3] = false;
        }
        return (outside[0] || outside[1] || outside[2] || outside[3]);
    }

    private void clipVertices(ref GLfloat[] vertices) {
        int numVertices = cast(int)(vertices.length / 3);
        foreach(i; 0..numVertices) {
            if (vertices[3*i + 0] > 1.0f) vertices[3*i + 0] = 1.0f;
            if (vertices[3*i + 0] < -1.0f) vertices[3*i + 0] = -1.0f;
            if (vertices[3*i + 1] > 1.0f) vertices[3*i + 1] = 1.0f;
            if (vertices[3*i + 1] < -1.0f) vertices[3*i + 1] = -1.0f;
        }
    }
}

void	TSKbg00(int id)
{
	int	eid;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKbg00Draw;
			TskBuf[id].fp_exit = &TSKbg00Exit;
			scr_base[X] = 0.0f;
			scr_base[Y] = 0.0f;
			scr_ofs[X] = 0.0f;
			scr_ofs[Y] = 0.0f;
			cam_pos = BASE_Z + cam_scr;
			bg_obj.length = 512;
			for(int i = 0; i < bg_obj.length; i++){
				if((Rand() % 100) & 0x01){
					bg_obj[i].pos[X] = cast(float)(Rand() % 4096) - 2048.0f;
					bg_obj[i].pos[Y] = 0.0f;
					bg_obj[i].line_list.length = 2;
					bg_obj[i].line_list[0][X] = +0.0f;
					bg_obj[i].line_list[0][Y] = -2048.0f;
					bg_obj[i].line_list[1][X] = +0.0f;
					bg_obj[i].line_list[1][Y] = +2048.0f;
				}else{
					bg_obj[i].pos[X] = 0.0f;
					bg_obj[i].pos[Y] = cast(float)(Rand() % 4096) - 2048.0f;
					bg_obj[i].line_list.length = 2;
					bg_obj[i].line_list[0][X] = -2048.0f;
					bg_obj[i].line_list[0][Y] = +0.0f;
					bg_obj[i].line_list[1][X] = +2048.0f;
					bg_obj[i].line_list[1][Y] = +0.0f;
				}
				bg_obj[i].line_list[0][Z] =
				bg_obj[i].line_list[1][Z] = -(cast(float)(Rand() % 75)) / 100.0f + 0.25f;
			}
			TskBuf[id].step++;
			break;
		case	1:
			fade_r = 0.0f;
			fade_g = 0.0f;
			fade_b = 0.0f;
			fade_a = 0.0f;
			TskBuf[fade_id].tx = 1.0f;
			TskBuf[fade_id].wait = 60;
			TskBuf[fade_id].step = 2;
			TskBuf[id].px = cast(float)(Rand() % 1536 - 768.0f);
			TskBuf[id].py = cast(float)(Rand() % 1536 - 768.0f);
			if((Rand() % 100) & 0x01){
				if(TskBuf[id].px < 0.0f){
					TskBuf[id].tx = +(cast(float)(Rand() % 768));
				}else{
					TskBuf[id].tx = -(cast(float)(Rand() % 768));
				}
				TskBuf[id].ty = TskBuf[id].py;
			}else{
				if(TskBuf[id].py < 0.0f){
					TskBuf[id].ty = +(cast(float)(Rand() % 768));
				}else{
					TskBuf[id].ty = -(cast(float)(Rand() % 768));
				}
				TskBuf[id].tx = TskBuf[id].px;
			}
			TskBuf[id].vx = (TskBuf[id].tx - TskBuf[id].px) / 600.0f;
			TskBuf[id].vy = (TskBuf[id].ty - TskBuf[id].py) / 600.0f;
			scr_pos[X] = scr_base[X] + scr_ofs[X] + TskBuf[id].px;
			scr_pos[Y] = scr_base[Y] + scr_ofs[Y] + TskBuf[id].py;
			TskBuf[id].wait = 540;
			cam_pos = BASE_Z + cam_scr;
			eid = setTSK(GROUP_08,&TSKbgZoom);
			TskBuf[eid].wait = 600;
			TskBuf[eid].tx = BASE_Z - (cast(float)((Rand() % 5000) - 2500 + 10000) / 10000.0f);
			TskBuf[id].step++;
			break;
		case	2:
			TskBuf[id].px += TskBuf[id].vx;
			TskBuf[id].py += TskBuf[id].vy;
			ship_px = TskBuf[id].px;
			ship_py = TskBuf[id].py;
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				fade_r = 0.0f;
				fade_g = 0.0f;
				fade_b = 0.0f;
				fade_a = 1.0f;
				TskBuf[fade_id].tx = 0.01f;
				TskBuf[fade_id].wait = 60;
				TskBuf[fade_id].step = 2;
				TskBuf[id].wait = 60;
				TskBuf[id].step++;
			}
			scr_pos[X] = scr_base[X] + scr_ofs[X] + TskBuf[id].px;
			scr_pos[Y] = scr_base[Y] + scr_ofs[Y] + TskBuf[id].py;
			break;
		case	3:
			TskBuf[id].px += TskBuf[id].vx;
			TskBuf[id].py += TskBuf[id].vy;
			ship_px = TskBuf[id].px;
			ship_py = TskBuf[id].py;
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				TskBuf[id].step = 1;
			}
			scr_pos[X] = scr_base[X] + scr_ofs[X] + TskBuf[id].px;
			scr_pos[Y] = scr_base[Y] + scr_ofs[Y] + TskBuf[id].py;
			break;

		default:
			clrTSK(id);
			break;
	}

	return;
}


void	TSKbg00Draw(int id)
{
	GLfloat[4*XYZ]	drawVertices;

	drawVertices[0*XYZ + X] = getPointX(-1024.0f+scr_pos[X], 0.0f);
	drawVertices[0*XYZ + Y] = getPointY(-1024.0f+scr_pos[Y], 0.0f);
	drawVertices[0*XYZ + Z] = 0.0f;

	drawVertices[1*XYZ + X] = getPointX(-1024.0f+scr_pos[X], 0.0f);
	drawVertices[1*XYZ + Y] = getPointY(+1024.0f+scr_pos[Y], 0.0f);
	drawVertices[1*XYZ + Z] = 0.0f;

	drawVertices[2*XYZ + X] = getPointX(+1024.0f+scr_pos[X], 0.0f);
	drawVertices[2*XYZ + Y] = getPointY(+1024.0f+scr_pos[Y], 0.0f);
	drawVertices[2*XYZ + Z] = 0.0f;

	drawVertices[3*XYZ + X] = getPointX(+1024.0f+scr_pos[X], 0.0f);
	drawVertices[3*XYZ + Y] = getPointY(-1024.0f+scr_pos[Y], 0.0f);
	drawVertices[3*XYZ + Z] = 0.0f;

	version (PANDORA) {
		clipVertices(drawVertices[0..$]);
	}

	glEnableClientState(GL_VERTEX_ARRAY);

	glColor4f(0.015f,0.015f,0.075f,1.0f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(drawVertices.ptr));
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

	for(int i = 0; i < bg_obj.length; i++){
		int	lineNumVertices = cast(int)(bg_obj[i].line_list.length);
		assert(lineNumVertices <= 4);

		foreach(j; 0..lineNumVertices){
			float[XYZ]	pos;
			pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[j][X], bg_obj[i].line_list[j][Z]);
			pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[j][Y], bg_obj[i].line_list[j][Z]);
			pos[Z] = bg_obj[i].line_list[j][Z];
			drawVertices[j*XYZ + X] = pos[X];
			drawVertices[j*XYZ + Y] = pos[Y];
			drawVertices[j*XYZ + Z] = pos[Z];
		}

		bool draw = true;
		version (PANDORA) {
			if (isOutside(drawVertices[0..XYZ*lineNumVertices])) {
				draw = false;
			} else {
				clipVertices(drawVertices[0..XYZ*lineNumVertices]);
			}
		}
		if (!draw) continue;

		glColor4f(0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
				  0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
				  0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
				  1.0f);
		//glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(drawVertices.ptr));
		glDrawArrays(GL_LINES, 0, lineNumVertices);
	}

	glDisableClientState(GL_VERTEX_ARRAY);
}


void	TSKbg00Exit(int id)
{
	bg_obj.length = 0;
}


void	TSKbg01(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = &TSKbg01Draw;
			TskBuf[id].fp_exit = &TSKbg01Exit;
			scr_base[X] = START_X;
			scr_base[Y] = START_Y;
			scr_ofs[X] = 0.0f;
			scr_ofs[Y] = 0.0f;
			cam_pos = BASE_Z + cam_scr;
			switch(area_num){
				case	AREA_01:
					bg_mode = 0;
					break;
				case	AREA_02:
					bg_mode = 1;
					break;
				case	AREA_03:
					bg_mode = 2;
					break;
				case	AREA_04:
					bg_mode = 3;
					break;
				case	AREA_05:
					bg_mode = 4;
					break;
				default:
					break;
			}
			bg_disp = 0;
			switch(bg_mode){
				case	0:
					bg_obj.length = 512;
					for(int i = 0; i < bg_obj.length; i++){
						if((Rand() % 100) & 0x01){
							bg_obj[i].pos[X] = cast(float)(Rand() % 4096) - 2048.0f;
							bg_obj[i].pos[Y] = 0.0f;
							bg_obj[i].line_list.length = 2;
							bg_obj[i].line_list[0][X] = +0.0f;
							bg_obj[i].line_list[0][Y] = -2048.0f;
							bg_obj[i].line_list[1][X] = +0.0f;
							bg_obj[i].line_list[1][Y] = +2048.0f;
						}else{
							bg_obj[i].pos[X] = 0.0f;
							bg_obj[i].pos[Y] = cast(float)(Rand() % 4096) - 2048.0f;
							bg_obj[i].line_list.length = 2;
							bg_obj[i].line_list[0][X] = -2048.0f;
							bg_obj[i].line_list[0][Y] = +0.0f;
							bg_obj[i].line_list[1][X] = +2048.0f;
							bg_obj[i].line_list[1][Y] = +0.0f;
						}
						bg_obj[i].line_list[0][Z] =
						bg_obj[i].line_list[1][Z] = -(cast(float)(Rand() % 75)) / 100.0f + 0.25f;
					}
					break;
				case	1:
					bg_obj.length = 1024;
					for(int i = 0; i < bg_obj.length; i++){
						bg_obj[i].pos[X] = cast(float)(Rand() % 2048) - 1024.0f;
						bg_obj[i].pos[Y] = cast(float)(Rand() % 2048) - 1024.0f;
						bg_obj[i].line_list.length = 4;
						bg_obj[i].line_list[0][X] = -64.0f;
						bg_obj[i].line_list[0][Y] = -64.0f;
						bg_obj[i].line_list[1][X] = -64.0f;
						bg_obj[i].line_list[1][Y] = +64.0f;
						bg_obj[i].line_list[2][X] = +64.0f;
						bg_obj[i].line_list[2][Y] = +64.0f;
						bg_obj[i].line_list[3][X] = +64.0f;
						bg_obj[i].line_list[3][Y] = -64.0f;
						bg_obj[i].line_list[0][Z] =
						bg_obj[i].line_list[1][Z] =
						bg_obj[i].line_list[2][Z] =
						bg_obj[i].line_list[3][Z] = -(cast(float)(Rand() % 75)) / 100.0f + 0.25f;
					}
					break;
				case	2:
					bg_obj.length = 768;
					for(int i = 0; i < bg_obj.length; i++){
						bg_obj[i].pos[X] = cast(float)(Rand() % 2048) - 1024.0f;
						bg_obj[i].pos[Y] = cast(float)(Rand() % 2048) - 1024.0f;
						bg_obj[i].line_list.length = 4;
						bg_obj[i].line_list[0][X] = -48.0f;
						bg_obj[i].line_list[0][Y] = -48.0f;
						bg_obj[i].line_list[1][X] = -48.0f;
						bg_obj[i].line_list[1][Y] = +48.0f;
						bg_obj[i].line_list[2][X] = +48.0f;
						bg_obj[i].line_list[2][Y] = +48.0f;
						bg_obj[i].line_list[3][X] = +48.0f;
						bg_obj[i].line_list[3][Y] = -48.0f;
						bg_obj[i].line_list[0][Z] =
						bg_obj[i].line_list[1][Z] =
						bg_obj[i].line_list[2][Z] =
						bg_obj[i].line_list[3][Z] = -(cast(float)(Rand() % 75)) / 100.0f + 0.25f;
					}
					break;
				case	3:
					bg_obj.length = 8192;
					for(int i = 0; i < bg_obj.length; i++){
						bg_obj[i].pos[X] = cast(float)(Rand() % 3072) - 1536.0f;
						bg_obj[i].pos[Y] = cast(float)(Rand() % 3072) - 1536.0f;
						bg_obj[i].line_list.length = 1;
						bg_obj[i].line_list[0][X] = +0.0f;
						bg_obj[i].line_list[0][Y] = +0.0f;
						bg_obj[i].line_list[0][Z] = -(cast(float)(Rand() % 75)) / 100.0f + 0.25f;
					}
					break;
				case	4:
					bg_obj.length = 1024 * 3;
					for(int i = 0; i < bg_obj.length; i++){
						bg_obj[i].pos[X] = cast(float)(Rand() % 2048) - 1024.0f;
						bg_obj[i].pos[Y] = cast(float)(Rand() % 2048) - 1024.0f;
						bg_obj[i].line_list.length = 2;
						bg_obj[i].line_list[0][X] = +0.0f;
						bg_obj[i].line_list[0][Y] = +0.0f;
						bg_obj[i].line_list[1][X] = +0.0f;
						bg_obj[i].line_list[1][Y] = +0.0f;
						bg_obj[i].line_list[0][Z] = +0.0f;
						bg_obj[i].line_list[1][Z] = +4096.0f;
					}
					break;
				default:
					break;
			}
			TskBuf[id].step++;
			break;
		case	1:
			scr_base[X] -= (scr_base[X] - ship_px) / 8.0f;
			scr_base[Y] -= (scr_base[Y] - ship_py) / 8.0f;
			scr_pos[X] = scr_base[X] + scr_ofs[X];
			scr_pos[Y] = scr_base[Y] + scr_ofs[Y];
			break;
		default:
			clrTSK(id);
			break;
	}

	return;
}


void	TSKbg01Draw(int id)
{
	if(!bg_disp) return;

	GLfloat[4*XYZ]	drawVertices;

	drawVertices[0*XYZ + X] = getPointX(-1024.0f+scr_pos[X], 0.0f);
	drawVertices[0*XYZ + Y] = getPointY(-1024.0f+scr_pos[Y], 0.0f);
	drawVertices[0*XYZ + Z] = 0.0f;

	drawVertices[1*XYZ + X] = getPointX(-1024.0f+scr_pos[X], 0.0f);
	drawVertices[1*XYZ + Y] = getPointY(+1024.0f+scr_pos[Y], 0.0f);
	drawVertices[1*XYZ + Z] = 0.0f;

	drawVertices[2*XYZ + X] = getPointX(+1024.0f+scr_pos[X], 0.0f);
	drawVertices[2*XYZ + Y] = getPointY(+1024.0f+scr_pos[Y], 0.0f);
	drawVertices[2*XYZ + Z] = 0.0f;

	drawVertices[3*XYZ + X] = getPointX(+1024.0f+scr_pos[X], 0.0f);
	drawVertices[3*XYZ + Y] = getPointY(-1024.0f+scr_pos[Y], 0.0f);
	drawVertices[3*XYZ + Z] = 0.0f;

    version (PANDORA) {
        clipVertices(drawVertices[0..$]);
    }

	glEnableClientState(GL_VERTEX_ARRAY);

	glColor4f(0.015f,0.015f,0.075f,1.0f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(drawVertices.ptr));
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

	switch(bg_mode){
		case	0:
			for(int i = 0; i < bg_obj.length; i++){
				int	lineNumVertices = cast(int)(bg_obj[i].line_list.length);
				assert(lineNumVertices <= 4);

				foreach(j; 0..lineNumVertices){
					float[XYZ]	pos;
					pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[j][X], bg_obj[i].line_list[j][Z]);
					pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[j][Y], bg_obj[i].line_list[j][Z]);
					pos[Z] = bg_obj[i].line_list[j][Z];
					drawVertices[j*XYZ + X] = pos[X];
					drawVertices[j*XYZ + Y] = pos[Y];
					drawVertices[j*XYZ + Z] = pos[Z];
				}

				bool draw = true;
				version (PANDORA) {
					if (isOutside(drawVertices[0..XYZ*lineNumVertices])) {
						draw = false;
					} else {
						clipVertices(drawVertices[0..XYZ*lineNumVertices]);
					}
				}
				if (!draw) continue;

				glColor4f(0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
						  1.0f);
				//glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(drawVertices.ptr));
				glDrawArrays(GL_LINES, 0, lineNumVertices);
			}
			break;
		case	1:
			for(int i = 0; i < bg_obj.length; i++){
				int	lineNumVertices = cast(int)(bg_obj[i].line_list[i].length);
				assert(lineNumVertices <= 4);

				foreach(j; 0..lineNumVertices){
					float[XYZ]	pos;
					pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[j][X], bg_obj[i].line_list[j][Z]);
					pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[j][Y], bg_obj[i].line_list[j][Z]);
					pos[Z] = bg_obj[i].line_list[j][Z];
					drawVertices[j*XYZ + X] = pos[X];
					drawVertices[j*XYZ + Y] = pos[Y];
					drawVertices[j*XYZ + Z] = pos[Z];
				}

				bool draw = true;
				version (PANDORA) {
					if (isOutside(drawVertices[0..XYZ*lineNumVertices])) {
						draw = false;
					}
				}
				if (!draw) continue;

				glColor4f(0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.25f*(1.0f+bg_obj[i].line_list[0][Z]),
						  1.0f);
				//glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(drawVertices.ptr));
				glDrawArrays(GL_LINE_LOOP, 0, lineNumVertices);
			}
			break;
		case	2:
			for(int i = 0; i < bg_obj.length; i++){
				int	lineNumVertices = cast(int)(bg_obj[i].line_list[i].length);
				assert(lineNumVertices == 4);

				foreach(j; 0..lineNumVertices){
					float[XYZ]	pos;
					pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[j][X], bg_obj[i].line_list[j][Z]);
					pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[j][Y], bg_obj[i].line_list[j][Z]);
					pos[Z] = bg_obj[i].line_list[j][Z];
					drawVertices[j*XYZ + X] = pos[X];
					drawVertices[j*XYZ + Y] = pos[Y];
					drawVertices[j*XYZ + Z] = pos[Z];
				}

				bool draw = true;
				version (PANDORA) {
					if (isOutside(drawVertices[0..XYZ*lineNumVertices])) {
						draw = false;
					}
				}
				if (!draw) continue;

				glColor4f(0.05f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.05f*(1.0f+bg_obj[i].line_list[0][Z]),
						  0.05f*(1.0f+bg_obj[i].line_list[0][Z]),
						  1.0f);
				//glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(drawVertices.ptr));
				//foreach(k; 0..lineNumVertices/4){
				//	glDrawArrays(GL_TRIANGLE_FAN, k*4, 4);
				//}
				glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
			}
			break;
		case	3:
			{
				int	lineNumVertices = cast(int)(bg_obj.length);
				GLfloat[]	lineVertices;
				GLfloat[]	lineColors;

				lineVertices.length = lineNumVertices*XYZ;
				lineColors.length = lineNumVertices*XYZW;

				int index = 0;
				foreach(i; 0..lineNumVertices){
					float[XYZ]	pos;
					pos[Z] = bg_obj[i].line_list[0][Z];
					pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[0][X], pos[Z]);
					pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[0][Y], pos[Z]);

					bool draw = true;
					version (PANDORA) {
						if (isOutside(pos[0..XYZ])) {
							draw = false;
						}
					}
					if (!draw) continue;

					lineVertices[index*XYZ + X] = pos[X];
					lineVertices[index*XYZ + Y] = pos[Y];
					lineVertices[index*XYZ + Z] = pos[Z];
					lineColors[index*XYZW + X] = 1.0f+pos[Z];
					lineColors[index*XYZW + Y] = 1.0f+pos[Z];
					lineColors[index*XYZW + Z] = 1.0f+pos[Z];
					lineColors[index*XYZW + W] = 1.0f;
					index++;
				}
				lineNumVertices = index;

				glEnableClientState(GL_COLOR_ARRAY);

				glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(lineVertices.ptr));
				glColorPointer(XYZW, GL_FLOAT, 0, cast(void *)(lineColors.ptr));
				glDrawArrays(GL_POINTS, 0, lineNumVertices);

				glDisableClientState(GL_COLOR_ARRAY);

				lineColors.length = 0;
				lineVertices.length = 0;
			}
			break;
		case	4:
			{
				int	numLines = cast(int)(bg_obj.length);
				int	lineNumVertices = 2*numLines;
				GLfloat[]	lineVertices;
				GLfloat[]	lineColors;

				lineVertices.length = lineNumVertices*XYZ;
				lineColors.length = lineNumVertices*XYZW;

				int index = 0;
				foreach(i; 0..numLines){
					float[XYZ]	pos;
					pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[0][X], bg_obj[i].line_list[0][Z]);
					pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[0][Y], bg_obj[i].line_list[0][Z]);
					pos[Z] = bg_obj[i].line_list[0][Z];
					lineVertices[2*index*XYZ + X] = pos[X];
					lineVertices[2*index*XYZ + Y] = pos[Y];
					lineVertices[2*index*XYZ + Z] = pos[Z];
					lineColors[2*index*XYZW + X] = 0.25f*(1.0f+bg_obj[i].line_list[0][Z]);
					lineColors[2*index*XYZW + Y] = 0.25f*(1.0f+bg_obj[i].line_list[0][Z]);
					lineColors[2*index*XYZW + Z] = 0.25f*(1.0f+bg_obj[i].line_list[0][Z]);
					lineColors[2*index*XYZW + W] = 1.0f;

					pos[X] = getPointX(bg_obj[i].pos[X] + scr_pos[X] - bg_obj[i].line_list[1][X], bg_obj[i].line_list[1][Z]);
					pos[Y] = getPointY(bg_obj[i].pos[Y] + scr_pos[Y] - bg_obj[i].line_list[1][Y], bg_obj[i].line_list[1][Z]);
					pos[Z] = bg_obj[i].line_list[1][Z];
					lineVertices[2*index*XYZ + XYZ + X] = pos[X];
					lineVertices[2*index*XYZ + XYZ + Y] = pos[Y];
					lineVertices[2*index*XYZ + XYZ + Z] = pos[Z];
					lineColors[2*index*XYZW + XYZW + X] = 0.25f*(1.0f+bg_obj[i].line_list[1][Z]);
					lineColors[2*index*XYZW + XYZW + Y] = 0.25f*(1.0f+bg_obj[i].line_list[1][Z]);
					lineColors[2*index*XYZW + XYZW + Z] = 0.25f*(1.0f+bg_obj[i].line_list[1][Z]);
					lineColors[2*index*XYZW + XYZW + W] = 1.0f;

					bool draw = true;
					version (PANDORA) {
						if (isOutside(lineVertices[2*index*XYZ..2*index*XYZ + 2*XYZ])) {
							draw = false;
						}
					}
					if (!draw) continue;

					index++;
				}
				lineNumVertices = index;

				glEnableClientState(GL_COLOR_ARRAY);

				glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(lineVertices.ptr));
				glColorPointer(XYZW, GL_FLOAT, 0, cast(void *)(lineColors.ptr));
				glDrawArrays(GL_LINES, 0, lineNumVertices);

				glDisableClientState(GL_COLOR_ARRAY);

				lineColors.length = 0;
				lineVertices.length = 0;
			}
			break;
		default:
			break;
	}

	glDisableClientState(GL_VERTEX_ARRAY);
}


void	TSKbg01Exit(int id)
{
	bg_obj.length = 0;
}


void	TSKbgOutBg(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKbgOutBgDraw;
			TskBuf[id].fp_exit = null;
			TskBuf[id].step++;
			break;
		case	1:
			break;
		default:
			clrTSK(id);
			break;
	}
	return;
}


void	TSKbgOutBgDraw(int id)
{
	GLfloat[4*XYZ]	quadVertices;

	glDisable(GL_BLEND);
	glEnableClientState(GL_VERTEX_ARRAY);

	glColor4f(0.035f,0.035f,0.015f,1.0f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(quadVertices.ptr));


	quadVertices[0*XYZ + X] = getPointX(-2048.0f+scr_pos[X], 0.0f);
	quadVertices[0*XYZ + Y] = getPointY(-2048.0f+scr_pos[Y], 0.0f);
	quadVertices[0*XYZ + Z] = 0.0f;

	quadVertices[1*XYZ + X] = getPointX(-2048.0f+scr_pos[X], 0.0f);
	quadVertices[1*XYZ + Y] = getPointY(+2048.0f+scr_pos[Y], 0.0f);
	quadVertices[1*XYZ + Z] = 0.0f;

	quadVertices[2*XYZ + X] = getPointX(-1024.0f+scr_pos[X], 0.0f);
	quadVertices[2*XYZ + Y] = getPointY(+2048.0f+scr_pos[Y], 0.0f);
	quadVertices[2*XYZ + Z] = 0.0f;

	quadVertices[3*XYZ + X] = getPointX(-1024.0f+scr_pos[X], 0.0f);
	quadVertices[3*XYZ + Y] = getPointY(-2048.0f+scr_pos[Y], 0.0f);
	quadVertices[3*XYZ + Z] = 0.0f;

	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);


	quadVertices[0*XYZ + X] = getPointX(+1024.0f+scr_pos[X], 0.0f);
	quadVertices[0*XYZ + Y] = getPointY(-2048.0f+scr_pos[Y], 0.0f);
	quadVertices[0*XYZ + Z] = 0.0f;

	quadVertices[1*XYZ + X] = getPointX(+1024.0f+scr_pos[X], 0.0f);
	quadVertices[1*XYZ + Y] = getPointY(+2048.0f+scr_pos[Y], 0.0f);
	quadVertices[1*XYZ + Z] = 0.0f;

	quadVertices[2*XYZ + X] = getPointX(+2048.0f+scr_pos[X], 0.0f);
	quadVertices[2*XYZ + Y] = getPointY(+2048.0f+scr_pos[Y], 0.0f);
	quadVertices[2*XYZ + Z] = 0.0f;

	quadVertices[3*XYZ + X] = getPointX(+2048.0f+scr_pos[X], 0.0f);
	quadVertices[3*XYZ + Y] = getPointY(-2048.0f+scr_pos[Y], 0.0f);
	quadVertices[3*XYZ + Z] = 0.0f;

	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);


	quadVertices[0*XYZ + X] = getPointX(-1024.0f+scr_pos[X], 0.0f);
	quadVertices[0*XYZ + Y] = getPointY(-2048.0f+scr_pos[Y], 0.0f);
	quadVertices[0*XYZ + Z] = 0.0f;

	quadVertices[1*XYZ + X] = getPointX(-1024.0f+scr_pos[X], 0.0f);
	quadVertices[1*XYZ + Y] = getPointY(-1024.0f+scr_pos[Y], 0.0f);
	quadVertices[1*XYZ + Z] = 0.0f;

	quadVertices[2*XYZ + X] = getPointX(+1024.0f+scr_pos[X], 0.0f);
	quadVertices[2*XYZ + Y] = getPointY(-1024.0f+scr_pos[Y], 0.0f);
	quadVertices[2*XYZ + Z] = 0.0f;

	quadVertices[3*XYZ + X] = getPointX(+1024.0f+scr_pos[X], 0.0f);
	quadVertices[3*XYZ + Y] = getPointY(-2048.0f+scr_pos[Y], 0.0f);
	quadVertices[3*XYZ + Z] = 0.0f;

	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);


	quadVertices[0*XYZ + X] = getPointX(-1024.0f+scr_pos[X], 0.0f);
	quadVertices[0*XYZ + Y] = getPointY(+1024.0f+scr_pos[Y], 0.0f);
	quadVertices[0*XYZ + Z] = 0.0f;

	quadVertices[1*XYZ + X] = getPointX(-1024.0f+scr_pos[X], 0.0f);
	quadVertices[1*XYZ + Y] = getPointY(+2048.0f+scr_pos[Y], 0.0f);
	quadVertices[1*XYZ + Z] = 0.0f;

	quadVertices[2*XYZ + X] = getPointX(+1024.0f+scr_pos[X], 0.0f);
	quadVertices[2*XYZ + Y] = getPointY(+2048.0f+scr_pos[Y], 0.0f);
	quadVertices[2*XYZ + Z] = 0.0f;

	quadVertices[3*XYZ + X] = getPointX(+1024.0f+scr_pos[X], 0.0f);
	quadVertices[3*XYZ + Y] = getPointY(+1024.0f+scr_pos[Y], 0.0f);
	quadVertices[3*XYZ + Z] = 0.0f;

	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);


	glDisableClientState(GL_VERTEX_ARRAY);
	glEnable(GL_BLEND);
}


void	TSKbgFrame(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKbgFrameDraw;
			TskBuf[id].fp_exit = null;
			TskBuf[id].step++;
			break;
		case	1:
			break;
		default:
			clrTSK(id);
			break;
	}
	return;
}


void	TSKbgFrameDraw(int id)
{
	float	z;

	z = BASE_Z - cam_pos;

	GLfloat[4*XYZ]	quadVertices;

	glDisable(GL_BLEND);
	glEnableClientState(GL_VERTEX_ARRAY);

	glColor4f(0.0f,0.0f,0.0f,1.0f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(quadVertices.ptr));


	quadVertices[0*XYZ + X] = getPointX(-(SCREEN_X / 2), z);
	quadVertices[0*XYZ + Y] = getPointY(-(SCREEN_Y / 2), z);
	quadVertices[0*XYZ + Z] = 0.0f;

	quadVertices[1*XYZ + X] = getPointX(-(SCREEN_Y / 2), z);
	quadVertices[1*XYZ + Y] = getPointY(-(SCREEN_Y / 2), z);
	quadVertices[1*XYZ + Z] = 0.0f;

	quadVertices[2*XYZ + X] = getPointX(-(SCREEN_Y / 2), z);
	quadVertices[2*XYZ + Y] = getPointY(+(SCREEN_Y / 2), z);
	quadVertices[2*XYZ + Z] = 0.0f;

	quadVertices[3*XYZ + X] = getPointX(-(SCREEN_X / 2), z);
	quadVertices[3*XYZ + Y] = getPointY(+(SCREEN_Y / 2), z);
	quadVertices[3*XYZ + Z] = 0.0f;

	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);


	quadVertices[0*XYZ + X] = getPointX(+(SCREEN_Y / 2), z);
	quadVertices[0*XYZ + Y] = getPointY(-(SCREEN_Y / 2), z);
	quadVertices[0*XYZ + Z] = 0.0f;

	quadVertices[1*XYZ + X] = getPointX(+(SCREEN_X / 2), z);
	quadVertices[1*XYZ + Y] = getPointY(-(SCREEN_Y / 2), z);
	quadVertices[1*XYZ + Z] = 0.0f;

	quadVertices[2*XYZ + X] = getPointX(+(SCREEN_X / 2), z);
	quadVertices[2*XYZ + Y] = getPointY(+(SCREEN_Y / 2), z);
	quadVertices[2*XYZ + Z] = 0.0f;

	quadVertices[3*XYZ + X] = getPointX(+(SCREEN_Y / 2), z);
	quadVertices[3*XYZ + Y] = getPointY(+(SCREEN_Y / 2), z);
	quadVertices[3*XYZ + Z] = 0.0f;

	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);


	glDisableClientState(GL_VERTEX_ARRAY);
	glEnable(GL_BLEND);
}


void	setQuake(int frame, float quake)
{
	int	eid;

	eid = setTSK(GROUP_01,&TSKbgQuake);
	TskBuf[eid].wait = frame;
	TskBuf[eid].vx = quake;
	TskBuf[eid].vy = quake;
}


void	TSKbgQuake(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].cnt = TskBuf[id].wait / 2;
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].wait){
				TskBuf[id].px  = ((Rand() % (256.0f * TskBuf[id].vx)) - ((256.0f * TskBuf[id].vx) / 2)) / 256.0f;
				TskBuf[id].py  = ((Rand() % (256.0f * TskBuf[id].vy)) - ((256.0f * TskBuf[id].vy) / 2)) / 256.0f;
				TskBuf[id].vx += (0.0f - TskBuf[id].vx) / TskBuf[id].cnt;
				TskBuf[id].vy += (0.0f - TskBuf[id].vy) / TskBuf[id].cnt;
				scr_ofs[X] = TskBuf[id].px;
				scr_ofs[Y] = TskBuf[id].py;
				TskBuf[id].wait--;
			}else{
				scr_ofs[X] = 0.0f;
				scr_ofs[Y] = 0.0f;
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
	return;
}


void	TSKbgZoom(int id)
{
	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].vx = (TskBuf[id].tx - cam_pos) / TskBuf[id].wait;
			TskBuf[id].step++;
			break;
		case	1:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
				cam_pos += TskBuf[id].vx;
			}else{
				cam_pos = TskBuf[id].tx;
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}

	return;
}


