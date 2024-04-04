/*
	area2048 source 'ENEMY COMMON'

		'enemy.d'

	2004/04/14 jumpei isshiki
*/

private	import	std.math;
private	import	SDL;
version (USE_GLES) {
	private	import	opengles;
} else {
	private	import opengl;
}
private	import	util_sdl;
private	import	util_snd;
private	import	bulletml;
private	import	bulletcommand;
private	import	define;
private	import	system;
private	import	task;
private	import	stg;
private	import	bg;
private	import	ship;

const float eshot_easy = 512.0f;
const float eshot_normal = 768.0f;
const float eshot_hard = 1024.0f;

private	const float	ESHOT_AREAMAX = (1024.0f + 16.0f);

private	float[]	eshot_body_simple = [
										 -8.0f, +0.0f,
										 +0.0f,-16.0f,
										 +8.0f, +0.0f,
										 +0.0f,+16.0f,
									];

private	float[]	eshot_body_active = [
										 -8.0f, -8.0f,
										 +0.0f,-16.0f,
										 +8.0f, -8.0f,
										 +0.0f,+16.0f,
									];

void	TSKenemyDest(int id, int add_score)
{
	addScore(add_score);
	addScoreBomb();
	playSNDse(SND_SE_EDEST);
	enemy_cnt--;
	enemy_stg--;
	TskBuf[id].step = -1;
	TskBuf[id].tskid &= ~TSKID_ZAKO;
}


void	TSKeshotSimple(int id)
{
	double[XY]	tpos;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].px = TskBuf[TskBuf[id].parent].px;
			TskBuf[id].py = TskBuf[TskBuf[id].parent].py;
			TskBuf[id].cx = 4.0f;
			TskBuf[id].cy = 4.0f;
			TskBuf[id].fp_int = &TSKeshotInt;
			TskBuf[id].fp_draw = &TSKeshotDrawSimple;
			TskBuf[id].fp_exit = &TSKeshotExit;
			TskBuf[id].body_list.length = eshot_body_simple.length / 2;
			TskBuf[id].body_ang.length  = eshot_body_simple.length / 2;
			for(int i = 0; i < TskBuf[id].body_list.length; i++){
				tpos[X] = eshot_body_simple[i*2+0];
				tpos[Y] = eshot_body_simple[i*2+1];
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			TskBuf[id].energy = 1;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].px += TskBuf[id].bullet_velx;
			TskBuf[id].py += TskBuf[id].bullet_vely;
			TskBuf[id].px += TskBuf[id].bullet_accx;
			TskBuf[id].py += TskBuf[id].bullet_accy;
			if(TskBuf[id].px < -ESHOT_AREAMAX || TskBuf[id].px > +ESHOT_AREAMAX || TskBuf[id].py > +ESHOT_AREAMAX || TskBuf[id].py < -ESHOT_AREAMAX){
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
	return;
}


void	TSKeshotActive(int id)
{
	double[XY]	tpos;
	BulletCommand	cmd = TskBuf[id].bullet_command;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].px = TskBuf[TskBuf[id].parent].px;
			TskBuf[id].py = TskBuf[TskBuf[id].parent].py;
			TskBuf[id].cx = 4.0f;
			TskBuf[id].cy = 4.0f;
			TskBuf[id].tid = ship_id;
			TskBuf[id].fp_int = &TSKeshotInt;
			TskBuf[id].fp_draw = &TSKeshotDrawActive;
			TskBuf[id].fp_exit = &TSKeshotExit;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].body_list.length = eshot_body_active.length / 2;
			TskBuf[id].body_ang.length  = eshot_body_active.length / 2;
			for(int i = 0; i < TskBuf[id].body_list.length; i++){
				tpos[X] = eshot_body_active[i*2+0];
				tpos[Y] = eshot_body_active[i*2+1];
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			cmd = new BulletCommand();
			TskBuf[id].bullet_command = cmd;
			cmd.set(id, TskBuf[id].bullet_state);
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].bullet_velx = (sin(TskBuf[id].bullet_direction) * (-TskBuf[id].bullet_speed));
			TskBuf[id].bullet_vely = (cos(TskBuf[id].bullet_direction) * (-TskBuf[id].bullet_speed));
			TskBuf[id].px += TskBuf[id].bullet_velx;
			TskBuf[id].py += TskBuf[id].bullet_vely;
			TskBuf[id].px += TskBuf[id].bullet_accx;
			TskBuf[id].py += TskBuf[id].bullet_accy;
//			TskBuf[id].tx  = TskBuf[TskBuf[id].tid].px;
//			TskBuf[id].ty  = TskBuf[TskBuf[id].tid].py;
			if(TskBuf[id].px < -ESHOT_AREAMAX || TskBuf[id].px > +ESHOT_AREAMAX || TskBuf[id].py > +ESHOT_AREAMAX || TskBuf[id].py < -ESHOT_AREAMAX){
				TskBuf[id].step = -1;
			}
			if(!cmd.isEnd()) cmd.run();
			break;
		default:
			if(cmd){
				cmd.vanish();
				destroy(cmd);
				TskBuf[id].bullet_command = null;
			}
			clrTSK(id);
			break;
	}
	return;
}

void	TSKeshotInt(int id)
{
	TskBuf[id].step = -1;

	return;
}

void	TSKeshotDrawSimple(int id)
{
	float[XYZ]	pos;
	int	bodyNumVertices = cast(int)(TskBuf[id].body_ang.length);
	GLfloat[]	bodyVertices;
	GLfloat[XYZ]	pointVertices;

	bodyVertices.length = bodyNumVertices*XYZ;

	foreach(i; 0..bodyNumVertices){
		pos[X] = sin(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][X]) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][Y]) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		bodyVertices[i*XYZ + X] = pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz);
		bodyVertices[i*XYZ + Y] = pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz);
		bodyVertices[i*XYZ + Z] = pos[Z];
	}

	pointVertices[X] = getPointX(scr_pos[X] - TskBuf[id].px, TskBuf[id].pz);
	pointVertices[Y] = getPointY(scr_pos[Y] - TskBuf[id].py, TskBuf[id].pz);
	pointVertices[Z] = 0.0f;

	glEnableClientState(GL_VERTEX_ARRAY);

	glColor4f(0.50f,0.25f,0.25f,1.0f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(bodyVertices.ptr));
	glDrawArrays(GL_TRIANGLE_FAN, 0, bodyNumVertices);

	glColor4f(1.0f,1.0f,1.0f,1.0f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(bodyVertices.ptr));
	glDrawArrays(GL_LINE_LOOP, 0, bodyNumVertices);

	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(pointVertices.ptr));
	glDrawArrays(GL_POINTS, 0, 1);

	glDisableClientState(GL_VERTEX_ARRAY);

	bodyVertices.length = 0;
}

void	TSKeshotDrawActive(int id)
{
	float[XYZ]	pos;
	int	bodyNumVertices = cast(int)(TskBuf[id].body_ang.length);
	GLfloat[]	bodyVertices;
	GLfloat[XYZ]	pointVertices;

	bodyVertices.length = bodyNumVertices*XYZ;

	foreach(i; 0..bodyNumVertices){
		pos[X] = sin(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][X]) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][Y]) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		bodyVertices[i*XYZ + X] = pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz);
		bodyVertices[i*XYZ + Y] = pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz);
		bodyVertices[i*XYZ + Z] = pos[Z];
	}

	pointVertices[X] = getPointX(scr_pos[X] - TskBuf[id].px, TskBuf[id].pz);
	pointVertices[Y] = getPointY(scr_pos[Y] - TskBuf[id].py, TskBuf[id].pz);
	pointVertices[Z] = 0.0f;

	glEnableClientState(GL_VERTEX_ARRAY);

	glColor4f(0.50f,0.25f,0.25f,1.0f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(bodyVertices.ptr));
	glDrawArrays(GL_TRIANGLE_FAN, 0, bodyNumVertices);

	glColor4f(1.0f,1.0f,1.0f,1.0f);
	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(bodyVertices.ptr));
	glDrawArrays(GL_LINE_LOOP, 0, bodyNumVertices);

	glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(pointVertices.ptr));
	glDrawArrays(GL_POINTS, 0, 1);

	glDisableClientState(GL_VERTEX_ARRAY);

	bodyVertices.length = 0;
}

void	TSKeshotExit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
	if(cmd){
		destroy(cmd);
		TskBuf[id].bullet_command = null;
	}
}

float	getShipDirection(int id)
{
	float	px,py;
	float	dir;
	int		tid;

	tid = TskBuf[id].tid;
	px = TskBuf[id].px - TskBuf[tid].px;
	py = TskBuf[id].py - TskBuf[tid].py;
	dir = atan2(px, py);

	return	dir;
}

