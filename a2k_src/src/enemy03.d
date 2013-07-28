/*
	area2048 source 'ENEMY-03'

		'enemy03.d'

	2004/04/11 jumpei isshiki
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
private	import	util_pad;
private	import	util_snd;
private	import	bulletcommand;
private	import	define;
private	import	task;
private	import	gctrl;
private	import	effect;
private	import	stg;
private	import	bg;
private	import	ship;
private	import	enemy;

private	const float	ENEMY_AREAMAX = (1024.0f - 22.0f);
private	const float	MAX_SPEED = (6.0f);
private	const float	SPEED_RATE = (60.0f);

private	float[]	enemy_poly = [
								/* BODY */
								 -4.0f, +4.0f,
								 -4.0f, -4.0f,
								 +4.0f, -4.0f,
								 +4.0f, +4.0f,
								/* WING-1 */
								 -4.0f, +1.0f,
								 -8.0f, +8.0f,
								 -1.0f, +4.0f,
								 +0.0f, +0.0f,
								/* WING-2 */
								 +4.0f, +1.0f,
								 +8.0f, +8.0f,
								 +1.0f, +4.0f,
								 +0.0f, +0.0f,
								/* WING-3 */
								 -8.0f, -8.0f,
								 -4.0f, -1.0f,
								 +0.0f, -0.0f,
								 -1.0f, -4.0f,
								/* WING-4 */
								 +1.0f, -4.0f,
								 +0.0f, -0.0f,
								 +4.0f, -1.0f,
								 +8.0f, -8.0f,
							];

void	TSKenemy03(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;
	double[XY]		tpos;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].tskid |= TSKID_ZAKO;
			TskBuf[id].px = (Rand() % 1536) - 768.0f;
			TskBuf[id].py = (Rand() % 1536) - 768.0f;
			TskBuf[id].tid = ship_id;
			TskBuf[id].fp_int = null;
			TskBuf[id].fp_draw = &TSKenemy03Draw;
			TskBuf[id].fp_exit = &TSKenemy03Exit;
			TskBuf[id].simple = &TSKeshotSimple;
			TskBuf[id].active = &TSKeshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].vx = 0.0f;
			TskBuf[id].vy = 0.0f;
			TskBuf[id].cx = 16.0f;
			TskBuf[id].cy = 16.0f;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].alpha = 0.0f;
			TskBuf[id].body_list.length = enemy_poly.length / 2;
			TskBuf[id].body_ang.length  = enemy_poly.length / 2;
			for(int i = 0; i < TskBuf[id].body_list.length; i++){
				tpos[X] = enemy_poly[i*2+0];
				tpos[Y] = enemy_poly[i*2+1];
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			TskBuf[id].energy = 2;
			TskBuf[id].bullet_length = 128;
			TskBuf[id].wait = 120;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].wait--;
			TskBuf[id].alpha += 1.0f / 120.0f;
			if(!TskBuf[id].wait){
				cmd = new BulletCommand();
				TskBuf[id].bullet_command = cmd;
				TskBuf[id].bullet_wait = 0;
				TskBuf[id].fp_int = &TSKenemy03Int;
				TskBuf[id].alpha = 1.0f;
				TskBuf[id].step++;
			}
		case	2:
			/* 弾撃ち */
			if(cmd){
				if(TskBuf[id].bullet_wait){
					if(cmd.isEnd()) TskBuf[id].bullet_wait--;
				}else{
					TskBuf[id].bullet_wait = 180;
					cmd.set(id, BULLET_ZAKO03);
				}
				if(!cmd.isEnd()){
					if(getShipLength(TskBuf[id].px, TskBuf[id].py) > TskBuf[id].bullet_length){
						int flag = 0;
						switch(game_level){
							case	GLEVEL_EASY:
								if(getShipLength(TskBuf[id].px, TskBuf[id].py) < eshot_easy) flag = 1;
								break;
							case	GLEVEL_NORMAL:
								if(getShipLength(TskBuf[id].px, TskBuf[id].py) < eshot_normal) flag = 1;
								break;
							case	GLEVEL_HARD:
								flag = 1;
								break;
							default:
								flag = 1;
								break;
						}
						if(flag) cmd.run();
					}
				}
			}
			/* 座標更新 */
			if(TskBuf[id].px < ship_px){
				if(TskBuf[id].vx > +0.0f) TskBuf[id].vx += 1.0f / SPEED_RATE * 1.5f;
				else					  TskBuf[id].vx += 1.0f / SPEED_RATE * 2.0f;
				if(TskBuf[id].vx > +MAX_SPEED) TskBuf[id].vx = +MAX_SPEED;
			}else{
				if(TskBuf[id].vx < +0.0f) TskBuf[id].vx -= 1.0f / SPEED_RATE * 1.5f;
				else					  TskBuf[id].vx -= 1.0f / SPEED_RATE * 2.0f;
				if(TskBuf[id].vx < -MAX_SPEED) TskBuf[id].vx = -MAX_SPEED;
			}
			if(TskBuf[id].py < ship_py){
				if(TskBuf[id].vy > +0.0f) TskBuf[id].vy += 1.0f / SPEED_RATE * 1.5f;
				else					  TskBuf[id].vy += 1.0f / SPEED_RATE * 2.0f;
				if(TskBuf[id].vy > +MAX_SPEED) TskBuf[id].vy = +MAX_SPEED;
			}else{
				if(TskBuf[id].vy < +0.0f) TskBuf[id].vy -= 1.0f / SPEED_RATE * 1.5f;
				else					  TskBuf[id].vy -= 1.0f / SPEED_RATE * 2.0f;
				if(TskBuf[id].vy < -MAX_SPEED) TskBuf[id].vy = -MAX_SPEED;
			}
			TskBuf[id].px += TskBuf[id].vx;
			TskBuf[id].py += TskBuf[id].vy;
			if(TskBuf[id].px < -ENEMY_AREAMAX){
				TskBuf[id].px = -ENEMY_AREAMAX;
				TskBuf[id].vx = -TskBuf[id].vx / 2;
				TskBuf[id].ax = +0.0f;
			}
			if(TskBuf[id].px > +ENEMY_AREAMAX){
				TskBuf[id].px = +ENEMY_AREAMAX;
				TskBuf[id].vx = -TskBuf[id].vx / 2;
				TskBuf[id].ax = +0.0f;
			}
			if(TskBuf[id].py < -ENEMY_AREAMAX){
				TskBuf[id].py = -ENEMY_AREAMAX;
				TskBuf[id].vy = -TskBuf[id].vy / 2;
				TskBuf[id].ay = +0.0f;
			}
			if(TskBuf[id].py > +ENEMY_AREAMAX){
				TskBuf[id].py = +ENEMY_AREAMAX;
				TskBuf[id].vy = -TskBuf[id].vy / 2;
				TskBuf[id].ay = +0.0f;
			}
			TskBuf[id].rot = atan2(-TskBuf[id].vx, -TskBuf[id].vy);
			break;
		default:
			if(cmd){
				cmd.vanish();
				delete cmd;
				TskBuf[id].bullet_command = null;
			}
			clrTSK(id);
			break;

	}
	return;
}


void	TSKenemy03Int(int id)
{
	if(TskBuf[id].energy > 0){
		playSNDse(SND_SE_EDMG);
		TskBuf[id].energy -= TskBuf[TskBuf[id].trg_id].energy;
	}
	if(TskBuf[id].energy <= 0 && TskBuf[id].step != -1){
		shipLockOff(id);
		TSKenemyDest(id,50);
		effSetBrokenBody(id, enemy_poly,  0, 4,+0.0f,+0.0f);
		effSetBrokenBody(id, enemy_poly,  4, 4,+0.0f,+0.0f);
		effSetBrokenBody(id, enemy_poly,  8, 4,+0.0f,+0.0f);
		effSetBrokenBody(id, enemy_poly, 12, 4,+0.0f,+0.0f);
		effSetBrokenBody(id, enemy_poly, 16, 4,+0.0f,+0.0f);
		effSetBrokenLine(id, enemy_poly,  0, 4,+0.0f,+0.0f);
		effSetBrokenLine(id, enemy_poly,  4, 4,+0.0f,+0.0f);
		effSetBrokenLine(id, enemy_poly,  8, 4,+0.0f,+0.0f);
		effSetBrokenLine(id, enemy_poly, 12, 4,+0.0f,+0.0f);
		effSetBrokenLine(id, enemy_poly, 16, 4,+0.0f,+0.0f);
	}else{
		effSetParticle01(id, 0.0f, 0.0f, 4);
	}

	return;
}


void	TSKenemy03Draw(int id)
{
	float[XYZ]	pos;

	/* BODY */
	GLfloat[4*XYZ]	bodyVertices;

	glEnableClientState(GL_VERTEX_ARRAY);

	foreach(k; 0..5){
		int	bodyNumVertices = (k == 0)?4:4;
		int	startOffset = (k == 0)?0:(4+4*(k-1));

		foreach(j; 0..bodyNumVertices){
			int i = startOffset + j;
			pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
			pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
			pos[Z] = TskBuf[id].body_ang[i][Z];
			bodyVertices[j*XYZ + X] = pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz);
			bodyVertices[j*XYZ + Y] = pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz);
			bodyVertices[j*XYZ + Z] = pos[Z];
		}

		glColor4f(0.65f,0.65f,0.25f,TskBuf[id].alpha);
		glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(bodyVertices.ptr));
		glDrawArrays(GL_TRIANGLE_FAN, 0, bodyNumVertices);

		glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
		glVertexPointer(XYZ, GL_FLOAT, 0, cast(void *)(bodyVertices.ptr));
		glDrawArrays(GL_LINE_LOOP, 0, bodyNumVertices);
	}

	glDisableClientState(GL_VERTEX_ARRAY);
}


void	TSKenemy03Exit(int id)
{
	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
	if(TskBuf[id].bullet_command) delete TskBuf[id].bullet_command;
}
