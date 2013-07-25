/*
	area2048 'SHIP CTRL'

		'ship.d'

	2003/12/01 jumpei isshiki
*/

private	import	std.math;
private	import	std.intrinsic;
private	import	SDL;
private	import	opengl;
private	import	util_sdl;
private	import	util_pad;
private	import	util_snd;
private	import	bulletml;
private	import	bulletcommand;
private	import	main;
private	import	init;
private	import	define;
private	import	task;
private	import	effect;
private	import	gctrl;
private	import	system;
private	import	bg;
private	import	stg;
private	import	enemy;

const float	START_X = +0.0f;
const float	START_Y = +768.0f;
const float	RANK_ADD = (1.0f / 2400.0f);

const int	PAD_SHOT = PAD_BUTTON1;
const int	PAD_BOMB = PAD_BUTTON2;

int		ship_id;
float	ship_px;
float	ship_py;
int		ship_bomb = 0;
int		ship_bomb_wait = 0;
int		ship_lock = 0;
int 	ship_trg;

private	const float	SHIP_SRATE = 1.0f / SQRT2;
private	const float	SHIP_SX1 = 8.0f;
private	const float	SHIP_SY1 = 8.0f;
private	const float	SHIP_SX2 = (SHIP_SX1 * SHIP_SRATE);
private	const float	SHIP_SY2 = (SHIP_SY1 * SHIP_SRATE);
private	const float	ACC_RATE = 30.0f;

private	const float	SHIP_AREAMAX = (1024.0f - 22.0f);
private	const float	SSHOT_AREAMAX = (1024.0f + 16.0f);

private	int		ship_pad = 0;
private	int		ship_pbk = 0;
private	int		ship_cnt = 0;

private	float[]	ship_poly = [
								+0.0f,+0.0f,
								-1.0f,+7.0f,
								-3.0f,+0.0f,
								-8.0f,-4.0f,
								-3.0f,-5.0f,
								-1.0f,-8.0f,
								+1.0f,-8.0f,
								+3.0f,-5.0f,
								+8.0f,-4.0f,
								+3.0f,+0.0f,
								+1.0f,+7.0f,
								-1.0f,+7.0f,
							];

private	float[]	ship_line = [
								-1.0f,+7.0f,
								-3.0f,+0.0f,
								-8.0f,-4.0f,
								-3.0f,-5.0f,
								-1.0f,-8.0f,
								+1.0f,-8.0f,
								+3.0f,-5.0f,
								+8.0f,-4.0f,
								+3.0f,+0.0f,
								+1.0f,+7.0f,
							];

private	float[]	sshot_body = [
								 -2.0f,+16.0f,
								 -4.0f,-16.0f,
								 +4.0f,-16.0f,
								 +2.0f,+16.0f,
							];

private	float[]	barrier_poly = [
								 +0.0f,-16.0f,
								+16.0f, +0.0f,
								 +0.0f,+16.0f,
								-16.0f, +0.0f,
							];

private	float[][]	ship_move = [
									[               0.0f,    +0.0f,    +0.0f,    +0.0f,    +0.0f ],	/*  0 PAD_NONE */
									[               0.0f,    +0.0f,-SHIP_SY1,    +0.0f,+SHIP_SY1 ],	/*  1 PAD_UP */
									[                 PI,    +0.0f,+SHIP_SY1,    +0.0f,+SHIP_SY1 ],	/*  2 PAD_DOWN */
									[               0.0f,    +0.0f,    +0.0f,    +0.0f,    +0.0f ],	/*  3 PAD_NONE */
									[        (PI + PI_2),+SHIP_SX1,    +0.0f,+SHIP_SX1,    +0.0f ],	/*  4 PAD_LEFT */
									[ (PI * 2.0f - PI_4),+SHIP_SX2,-SHIP_SY2,+SHIP_SX2,+SHIP_SY2 ],	/*  5 PAD_UP+PAD_LEFT */
									[        (PI + PI_4),+SHIP_SX2,+SHIP_SY2,+SHIP_SX2,+SHIP_SY2 ],	/*  6 PAD_DOWN+PAD_LEFT */
									[               0.0f,    +0.0f,    +0.0f,    +0.0f,    +0.0f ],	/*  7 NONE */
									[               PI_2,-SHIP_SX1,    +0.0f,+SHIP_SX1,    +0.0f ],	/*  8 PAD_RIGHT */
									[               PI_4,-SHIP_SX2,-SHIP_SY2,+SHIP_SX2,+SHIP_SY2 ],	/*  9 PAD_UP+PAD_RIGHT */
									[        (PI - PI_4),-SHIP_SX2,+SHIP_SY2,+SHIP_SX2,+SHIP_SY2 ],	/* 10 PAD_DOWN+PAD_RIGHT */
									[               0.0f,    +0.0f,    +0.0f,    +0.0f,    +0.0f ],	/* 11 NONE */
									[               0.0f,    +0.0f,    +0.0f,    +0.0f,    +0.0f ],	/* 12 NONE */
									[               0.0f,    +0.0f,    +0.0f,    +0.0f,    +0.0f ],	/* 13 NONE */
									[               0.0f,    +0.0f,    +0.0f,    +0.0f,    +0.0f ],	/* 14 NONE */
									[               0.0f,    +0.0f,    +0.0f,    +0.0f,    +0.0f ],	/* 15 NONE */
								];

private	int old_dat;
private	int pad_dat;
private	int trg_dat;

private	int demo_move;
private	int demo_fire;
private	int demo_eid;

void	TSKship(int id)
{
	double[XY]		tpos;
	float			acc;
	BulletCommand	cmd = TskBuf[id].bullet_command;

	switch(TskBuf[id].step){
		case	0:
			ship_id = id;
			TskBuf[id].tskid |= TSKID_MUTEKI;
			TskBuf[id].px = START_X;
			TskBuf[id].py = START_Y;
			ship_px = TskBuf[id].px;
			ship_py = TskBuf[id].py;
			TskBuf[id].tid = id;
			TskBuf[id].fp_draw = &TSKshipDraw;
			TskBuf[id].fp_exit = &TSKshipExit;
			TskBuf[id].simple = &TSKsshotSimple;
			TskBuf[id].active = &TSKsshotActive;
			TskBuf[id].target = &getShipShotDirection;
			TskBuf[id].cx = 2.0f;
			TskBuf[id].cy = 2.0f;
			TskBuf[id].pz = 0.0f;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].alpha = 0.0f;
			TskBuf[id].body_list.length = ship_poly.length / 2;
			TskBuf[id].body_ang.length  = ship_poly.length / 2;
			for(int i = 0; i < TskBuf[id].body_list.length; i++){
				tpos[X] = ship_poly[i*2+0];
				tpos[Y] = ship_poly[i*2+1];
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			TskBuf[id].line_list.length = ship_line.length / 2;
			TskBuf[id].line_ang.length  = ship_line.length / 2;
			for(int i = 0; i < TskBuf[id].line_list.length; i++){
				tpos[X] = ship_line[i*2+0];
				tpos[Y] = ship_line[i*2+1];
				TskBuf[id].line_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].line_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].line_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].line_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			ship_bomb_wait = 0;
			TskBuf[id].wait = 120;
			TskBuf[id].cnt = TskBuf[id].wait;
			cmd = new BulletCommand();
			TskBuf[id].bullet_command = cmd;
			setTSK(GROUP_03,&TSKlock);
			old_dat = 0;
			pad_dat = 0;
			trg_dat = 0;
			demo_move = 0;
			demo_fire = 0;
			demo_eid = -1;
			TskBuf[id].step++;
			break;
		case	1:
			if(!TskBuf[id].wait){
				TskBuf[id].fp_int = &TSKshipInt;
				TskBuf[id].tskid &= ~TSKID_MUTEKI;
				TskBuf[id].alpha = 1.0f;
				TskBuf[id].step++;
				BombON();
			}else{
				TskBuf[id].wait--;
				if(TskBuf[id].cnt) TskBuf[id].alpha += 1.0f / TskBuf[id].cnt;
			}
		case	2:
			old_dat = pad_dat;
			pad_dat = getAttractPadData(id);
			trg_dat = getAttractTrgData(id,pad_dat,old_dat);
			/* ロック処理 */
			ship_trg = getNearEnemy(id,512.0f);
			if((trg_dat & PAD_SHOT) && ship_trg != -1){
				ship_lock = 1;
				TskBuf[id].trg_id = ship_trg;
			}else if(!(pad_dat & PAD_SHOT) || ship_trg == -1){
				ship_lock = 0;
				TskBuf[id].trg_id = -1;
			}
			/* 方向取得(敏感に反応しないための処理) */
			int	trg = trg_dat & PAD_DIR;
			int	pad = pad_dat & PAD_DIR;
			if(trg){
				ship_pad = pad;
				ship_pbk = pad;
				ship_cnt = 2;
			}else if(pad && pad != ship_pad){
				ship_pad = ship_pbk;
				if(ship_cnt) ship_cnt--;
				else		 ship_pbk = pad;
			}else if(!pad){
				ship_pad = 0;
				ship_pbk = 0;
				ship_cnt = 0;
			}
			/* 速度＆方向設定 */
			if(ship_lock == 0){
				if(ship_pad) TskBuf[id].rot = ship_move[ship_pad][0];
			}else{
				TskBuf[id].rot = getTargetDirection(id);
			}
			TskBuf[id].ax = ship_move[ship_pad][1];
			TskBuf[id].ay = ship_move[ship_pad][2];
			TskBuf[id].nx = ship_move[ship_pad][3];
			TskBuf[id].ny = ship_move[ship_pad][4];
			if((pad_dat & PAD_SHOT) || BombTSTexec()){
				TskBuf[id].ax *= 1.5f;
				TskBuf[id].ay *= 1.5f;
			}
			/* 加減速 */
			acc = ACC_RATE;
			if(TskBuf[id].ax != 0.0f){
				if(TskBuf[id].vx < TskBuf[id].ax){
					TskBuf[id].vx += TskBuf[id].nx / acc;
					if(TskBuf[id].vx > TskBuf[id].ax) TskBuf[id].vx = TskBuf[id].ax;
				}
				if(TskBuf[id].vx > TskBuf[id].ax){
					TskBuf[id].vx -= TskBuf[id].nx / acc;
					if(TskBuf[id].vx < TskBuf[id].ax) TskBuf[id].vx = TskBuf[id].ax;
				}
			}else{
				TskBuf[id].vx -= TskBuf[id].vx / (acc * 2.0f);
			}
			if(TskBuf[id].ay != 0.0f){
				if(TskBuf[id].vy < TskBuf[id].ay){
					TskBuf[id].vy += TskBuf[id].ny / acc;
					if(TskBuf[id].vy > TskBuf[id].ay) TskBuf[id].vy = TskBuf[id].ay;
				}
				if(TskBuf[id].vy > TskBuf[id].ay){
					TskBuf[id].vy -= TskBuf[id].ny / acc;
					if(TskBuf[id].vy < TskBuf[id].ay) TskBuf[id].vy = TskBuf[id].ay;
				}
			}else{
				TskBuf[id].vy -= TskBuf[id].vy / (acc * 2.0f);
			}
			/* 座標更新 */
			TskBuf[id].px += TskBuf[id].vx;
			TskBuf[id].py += TskBuf[id].vy;
			if(TskBuf[id].px < -SHIP_AREAMAX){
				TskBuf[id].px = -SHIP_AREAMAX;
				TskBuf[id].vx = -TskBuf[id].vx / 2;
				TskBuf[id].ax = +0.0f;
			}
			if(TskBuf[id].px > +SHIP_AREAMAX){
				TskBuf[id].px = +SHIP_AREAMAX;
				TskBuf[id].vx = -TskBuf[id].vx / 2;
				TskBuf[id].ax = +0.0f;
			}
			if(TskBuf[id].py < -SHIP_AREAMAX){
				TskBuf[id].py = -SHIP_AREAMAX;
				TskBuf[id].vy = -TskBuf[id].vy / 2;
				TskBuf[id].ay = +0.0f;
			}
			if(TskBuf[id].py > +SHIP_AREAMAX){
				TskBuf[id].py = +SHIP_AREAMAX;
				TskBuf[id].vy = -TskBuf[id].vy / 2;
				TskBuf[id].ay = +0.0f;
			}
			ship_px = TskBuf[id].px;
			ship_py = TskBuf[id].py;
			TskBuf[id].tx = TskBuf[id].px + sin(TskBuf[id].rot) * 1.0f;
			TskBuf[id].ty = TskBuf[id].py + cos(TskBuf[id].rot) * 1.0f;
			/* ボム */
			if(!enemy_stg) BombOFF();
			if(TskBuf[id].step == 2){
				if(bomb && BombTST() && (trg_dat & PAD_BOMB)){
					setTSK(GROUP_08,&TSKbomb);
					BombEXEC();
				}
			}
			/* ショット */
			if(BombTSTwait()){
				cmd.vanish();
				BombSTOP();
			}
			if(ship_bomb_wait){
				ship_bomb_wait--;
				if(!ship_bomb_wait){
					playSNDse(SND_VOICE_CHARGE);
					BombON();
				}
			}
			if(!BombTSTexec()){
				if((pad_dat & PAD_SHOT)){
					if(!cmd.isEnd()) cmd.run();
					else			 cmd.set(id, BULLET_SHIP01);
				}else{
					cmd.vanish();
				}
			}else{
				if((pad_dat & PAD_BOMB)){
					if(bomb) bomb -= BOMB_SUB;
					if(bomb < 0) bomb = 0;
					if(!cmd.isEnd()) cmd.run();
					else			 cmd.set(id, BULLET_SHIP02);
				}
			}
			/* ボム溜め */
			if(BombTST()){
				if((pad_dat & PAD_SHOT)) BmbGaugeAdd(BOMB_ADD_MIN);
				else					 BmbGaugeAdd(BOMB_ADD_MAX);
				BombREMAINscore();
			}
			/* 時間チェック */
			if(time_flag && !time_left){
				playSNDse(SND_SE_SDEST);
				effSetBrokenLine(id, ship_line,  0, 10, 0.0f, 0.0f);
				effSetBrokenLine(id, ship_line,  0, 10, 0.0f, 0.0f);
				effSetBrokenLine(id, ship_line,  0, 10, 0.0f, 0.0f);
				effSetBrokenLine(id, ship_line,  0, 10, 0.0f, 0.0f);
				if(cmd.isEnd()) cmd.vanish();
				TskBuf[id].fp_int = null;
				TskBuf[id].alpha = 0.0f;
				left = 0;
				stg_ctrl = STG_GAMEOVER;
				TskBuf[id].step = 255;
				break;
			}
			/* クリアチェック */
			if(!enemy_stg){
				TskBuf[id].fp_int = null;
				TskBuf[id].tskid |= TSKID_MUTEKI;
				TskBuf[id].alpha = 0.5f;
			}
			break;
		case	3:
			TskBuf[id].wait--;
			if(!TskBuf[id].wait){
				TskBuf[id].tskid |= TSKID_MUTEKI;
				TskBuf[id].px   = START_X;
				TskBuf[id].py   = START_Y;
				TskBuf[id].wait = 120;
				TskBuf[id].cnt = TskBuf[id].wait;
				TskBuf[id].step = 1;
			}
			break;

		case	100:
			TskBuf[id].alpha = 0.0f;
			TskBuf[id].fp_int = null;
			TskBuf[id].px   = START_X;
			TskBuf[id].py   = START_Y;
			TskBuf[id].vx = +0.0f;
			TskBuf[id].vy = +0.0f;
			TskBuf[id].ax = +0.0f;
			TskBuf[id].ay = +0.0f;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].step++;
		case	101:
			BombOFF();
			cmd.vanish();
			TskBuf[id].step++;
		case	102:
			/* 座標更新 */
			acc = ACC_RATE;
			TskBuf[id].vx -= TskBuf[id].vx / (acc * 2.0f);
			TskBuf[id].vy -= TskBuf[id].vy / (acc * 2.0f);
			TskBuf[id].px += TskBuf[id].vx;
			TskBuf[id].py += TskBuf[id].vy;
			if(TskBuf[id].px < -SHIP_AREAMAX){
				TskBuf[id].px = -SHIP_AREAMAX;
				TskBuf[id].vx = -TskBuf[id].vx / 2;
				TskBuf[id].ax = +0.0f;
			}
			if(TskBuf[id].px > +SHIP_AREAMAX){
				TskBuf[id].px = +SHIP_AREAMAX;
				TskBuf[id].vx = -TskBuf[id].vx / 2;
				TskBuf[id].ax = +0.0f;
			}
			if(TskBuf[id].py < -SHIP_AREAMAX){
				TskBuf[id].py = -SHIP_AREAMAX;
				TskBuf[id].vy = -TskBuf[id].vy / 2;
				TskBuf[id].ay = +0.0f;
			}
			if(TskBuf[id].py > +SHIP_AREAMAX){
				TskBuf[id].py = +SHIP_AREAMAX;
				TskBuf[id].vy = -TskBuf[id].vy / 2;
				TskBuf[id].ay = +0.0f;
			}
			ship_px = TskBuf[id].px;
			ship_py = TskBuf[id].py;
			TskBuf[id].tx = TskBuf[id].px + sin(TskBuf[id].rot) * 1.0f;
			TskBuf[id].ty = TskBuf[id].py + cos(TskBuf[id].rot) * 1.0f;
			break;

		case	110:
			acc = ACC_RATE;
			BombOFF();
			TskBuf[id].alpha = 1.00f;
			/* 座標更新 */
			TskBuf[id].vx -= TskBuf[id].vx / (acc * 2.0f);
			TskBuf[id].vy -= TskBuf[id].vy / (acc * 2.0f);
			TskBuf[id].px += TskBuf[id].vx;
			TskBuf[id].py += TskBuf[id].vy;
			if(TskBuf[id].px < -SHIP_AREAMAX){
				TskBuf[id].px = -SHIP_AREAMAX;
				TskBuf[id].vx = -TskBuf[id].vx / 2;
				TskBuf[id].ax = +0.0f;
			}
			if(TskBuf[id].px > +SHIP_AREAMAX){
				TskBuf[id].px = +SHIP_AREAMAX;
				TskBuf[id].vx = -TskBuf[id].vx / 2;
				TskBuf[id].ax = +0.0f;
			}
			if(TskBuf[id].py < -SHIP_AREAMAX){
				TskBuf[id].py = -SHIP_AREAMAX;
				TskBuf[id].vy = -TskBuf[id].vy / 2;
				TskBuf[id].ay = +0.0f;
			}
			if(TskBuf[id].py > +SHIP_AREAMAX){
				TskBuf[id].py = +SHIP_AREAMAX;
				TskBuf[id].vy = -TskBuf[id].vy / 2;
				TskBuf[id].ay = +0.0f;
			}
			TskBuf[id].tx = TskBuf[id].px + sin(TskBuf[id].rot) * 1.0f;
			TskBuf[id].ty = TskBuf[id].py + cos(TskBuf[id].rot) * 1.0f;
			break;

		case	255:
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

	BmbGaugeExec();

	return;
}

void	TSKshipInt(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	if(g_step == GSTEP_DEMO) return;

	playSNDse(SND_SE_SDEST);
	effSetBrokenLine(id, ship_line,  0, 10, 0.0f, 0.0f);
	effSetBrokenLine(id, ship_line,  0, 10, 0.0f, 0.0f);
	effSetBrokenLine(id, ship_line,  0, 10, 0.0f, 0.0f);
	effSetBrokenLine(id, ship_line,  0, 10, 0.0f, 0.0f);
	if(cmd.isEnd()) cmd.vanish();
	TskBuf[id].fp_int = null;
	TskBuf[id].alpha = 0.0f;
	ship_lock = 0;
	TskBuf[ship_id].trg_id = -1;
	BombOFF();

	if(!left){
		stg_ctrl = STG_GAMEOVER;
		TskBuf[id].step = 255;
	}else{
		TskBuf[id].step = 3;
		TskBuf[id].wait = 60;
		TskBuf[id].rot = 0.0f;
		TskBuf[id].vx = +0.0f;
		TskBuf[id].vy = +0.0f;
		TskBuf[id].ax = +0.0f;
		TskBuf[id].ay = +0.0f;
		left--;
		BombON();
		switch(game_level){
			case	GLEVEL_EASY:
				setRank(0.0f);
				break;
			case	GLEVEL_NORMAL:
				addRank(-0.5f);
				bomb = BOMB_ONE;
				break;
			case	GLEVEL_HARD:
				addRank(-0.25f);
				bomb = BOMB_ONE;
				break;
			default:
				break;
		}
	}

	return;
}

void	TSKshipDraw(int id)
{
	float[XYZ]	pos;

	if(TskBuf[id].fp_int && !(TskBuf[id].tskid & TSKID_MUTEKI)){
		glColor4f(0.4f,0.4f,0.8f,TskBuf[id].alpha);
		glBegin(GL_POLYGON);
		for(int i = 0; i < TskBuf[id].body_ang.length; i++){
			pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
			pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
			pos[Z] = TskBuf[id].body_ang[i][Z];
			glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
					   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
					   pos[Z]);
		}
		glEnd();
		glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
		glBegin(GL_LINE_LOOP);
		for(int i = 0; i < TskBuf[id].line_ang.length; i++){
			pos[X] = sin(TskBuf[id].line_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].line_ang[i][W] * 3.0f, TskBuf[id].pz);
			pos[Y] = cos(TskBuf[id].line_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].line_ang[i][W] * 3.0f, TskBuf[id].pz);
			pos[Z] = TskBuf[id].line_ang[i][Z];
			glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
					   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
					   pos[Z]);
		}
		glEnd();
	}else{
		glColor4f(0.4f,0.4f,0.8f,TskBuf[id].alpha);
		glBegin(GL_POLYGON);
		for(int i = 0; i < TskBuf[id].body_ang.length; i++){
			pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
			pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
			pos[Z] = TskBuf[id].body_ang[i][Z];
			glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
					   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
					   pos[Z]);
		}
		glEnd();
		glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
		glBegin(GL_LINE_LOOP);
		for(int i = 0; i < TskBuf[id].line_ang.length; i++){
			pos[X] = sin(TskBuf[id].line_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].line_ang[i][W] * 3.0f, TskBuf[id].pz);
			pos[Y] = cos(TskBuf[id].line_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].line_ang[i][W] * 3.0f, TskBuf[id].pz);
			pos[Z] = TskBuf[id].line_ang[i][Z];
			glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
					   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
					   pos[Z]);
		}
		glEnd();
	}
}

void	TSKshipExit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
	if(cmd){
		delete cmd;
		TskBuf[id].bullet_command = null;
	}
}

float	getShipShotDirection(int id)
{
	float	px,py;
	float	dir;
	int		tid;

	tid = TskBuf[id].tid;
	px = TskBuf[id].tx - TskBuf[tid].px;
	py = TskBuf[id].ty - TskBuf[tid].py;
	dir = atan2(px, py);

	return	dir;
}

void	TSKsshotSimple(int id)
{
	double	tpos[XY];

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].px = TskBuf[TskBuf[id].parent].px;
			TskBuf[id].py = TskBuf[TskBuf[id].parent].py;
			TskBuf[id].cx = 4.0f;
			TskBuf[id].cy = 4.0f;
			TskBuf[id].fp_int = &TSKsshotInt;
			TskBuf[id].fp_draw = &TSKsshotDraw;
			TskBuf[id].fp_exit = &TSKsshotExit;
			TskBuf[id].body_list.length = sshot_body.length / 2;
			TskBuf[id].body_ang.length  = sshot_body.length / 2;
			for(int i = 0; i < TskBuf[id].body_list.length; i++){
				tpos[X] = sshot_body[i*2+0];
				tpos[Y] = sshot_body[i*2+1];
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			TskBuf[id].alpha = 1.0f;
			TskBuf[id].energy = 1;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].px += TskBuf[id].bullet_velx;
			TskBuf[id].py += TskBuf[id].bullet_vely;
			TskBuf[id].px += TskBuf[id].bullet_accx;
			TskBuf[id].py += TskBuf[id].bullet_accy;
			if(TskBuf[id].px < -SSHOT_AREAMAX || TskBuf[id].px > +SSHOT_AREAMAX || TskBuf[id].py > +SSHOT_AREAMAX || TskBuf[id].py < -SSHOT_AREAMAX){
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
	return;
}

void	TSKsshotActive(int id)
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
			TskBuf[id].fp_int = &TSKsshotInt;
			TskBuf[id].fp_draw = &TSKsshotDraw;
			TskBuf[id].fp_exit = &TSKsshotExit;
			TskBuf[id].simple = &TSKsshotSimple;
			TskBuf[id].active = &TSKsshotActive;
			TskBuf[id].target = &getShipDirection;
			TskBuf[id].body_list.length = sshot_body.length / 2;
			TskBuf[id].body_ang.length  = sshot_body.length / 2;
			for(int i = 0; i < TskBuf[id].body_list.length; i++){
				tpos[X] = sshot_body[i*2+0];
				tpos[Y] = sshot_body[i*2+1];
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
			TskBuf[id].alpha = 1.0f;
			TskBuf[id].energy = 1;
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].bullet_velx = (sin(TskBuf[id].bullet_direction) * (+TskBuf[id].bullet_speed));
			TskBuf[id].bullet_vely = (cos(TskBuf[id].bullet_direction) * (-TskBuf[id].bullet_speed));
			TskBuf[id].px += TskBuf[id].bullet_velx;
			TskBuf[id].py += TskBuf[id].bullet_vely;
			TskBuf[id].px += TskBuf[id].bullet_accx;
			TskBuf[id].py += TskBuf[id].bullet_accy;
			TskBuf[id].tx  = TskBuf[TskBuf[id].tid].px;
			TskBuf[id].ty  = TskBuf[TskBuf[id].tid].py;
			if(TskBuf[id].px < -SSHOT_AREAMAX || TskBuf[id].px > +SSHOT_AREAMAX || TskBuf[id].py > +SSHOT_AREAMAX || TskBuf[id].py < -SSHOT_AREAMAX){
				TskBuf[id].step = -1;
			}
			if(!cmd.isEnd()) cmd.run();
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

void	TSKsshotInt(int id)
{
	TskBuf[id].step = -1;

	return;
}

void	TSKsshotDraw(int id)
{
	float[XYZ]	pos;

	glColor4f(0.6f,0.6f,0.6f,TskBuf[id].alpha);
	glBegin(GL_POLYGON);
	for(int i = 0; i < TskBuf[id].body_ang.length; i++){
		pos[X] = sin(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][X]) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][Y]) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,TskBuf[id].alpha);
	glBegin(GL_LINE_LOOP);
	for(int i = 0; i < TskBuf[id].body_ang.length; i++){
		pos[X] = sin(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][X]) * getPointX(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].bullet_direction - TskBuf[id].body_ang[i][Y]) * getPointY(TskBuf[id].body_ang[i][W], TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
}

void	TSKsshotExit(int id)
{
	BulletCommand	cmd = TskBuf[id].bullet_command;

	TskBuf[id].body_list.length = 0;
	TskBuf[id].body_ang.length  = 0;
	if(cmd){
		delete cmd;
		TskBuf[id].bullet_command = null;
	}
}

void	TSKbomb(int id)
{
	int	eid;

	switch(TskBuf[id].step){
		case	0:
			eid = setTSK(GROUP_08,&TSKbgZoom);
			TskBuf[eid].wait = 30;
			TskBuf[eid].tx = BASE_Z - 1.25f;
			TskBuf[eid].tx = BASE_Z - 1.50f;
			TskBuf[id].wait = 30;
			TskBuf[ship_id].tskid |= TSKID_MUTEKI;
			TskBuf[ship_id].fp_int = null;
			TskBuf[id].step++;
			break;
		case	1:
			if(!enemy_stg || TskBuf[ship_id].step != 2){
				eid = setTSK(GROUP_08,&TSKbgZoom);
				TskBuf[eid].wait = 30;
				TskBuf[eid].tx = BASE_Z + cam_scr;
				TskBuf[id].wait = 30;
				TskBuf[id].step++;
				break;
			}
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				if(!TskBuf[ship_id].fp_int){
					TskBuf[ship_id].tskid &= ~TSKID_MUTEKI;
					TskBuf[ship_id].fp_int = &TSKshipInt;
				}
				if(!(pad_dat & PAD_BOMB) || !bomb || boss_flag == 2){
					eid = setTSK(GROUP_08,&TSKbgZoom);
					TskBuf[eid].wait = 30;
					TskBuf[eid].tx = BASE_Z + cam_scr;
					TskBuf[id].wait = 30;
					TskBuf[id].step++;
				}
			}
			BombADDscore(BOMB_SCORE_ADD);
			addRank(RANK_ADD);
			break;
		case	2:
			if(TskBuf[id].wait){
				TskBuf[id].wait--;
			}else{
				TskBuf[id].step = -1;
			}
			break;
		default:
			BombWAIT();
			clrTSK(id);
			break;
	}

	return;
}

void	TSKbarrier(int id)
{
	double[XY]	tpos;

	switch(TskBuf[id].step){
		case	0:
			TskBuf[id].fp_draw = null;
			TskBuf[id].alpha = 0.0f;
			TskBuf[id].rot = 0.0f;
			TskBuf[id].body_list.length = barrier_poly.length / 2;
			TskBuf[id].body_ang.length  = barrier_poly.length / 2;
			for(int i = 0; i < TskBuf[id]. body_list.length; i++){
				tpos[X] = barrier_poly[i*2+0];
				tpos[Y] = barrier_poly[i*2+1];
				TskBuf[id].body_ang[i][X] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Y] = atan2(tpos[X], tpos[Y]);
				TskBuf[id].body_ang[i][Z] = 0.0f;
				tpos[X] = fabs(tpos[X]);
				tpos[Y] = fabs(tpos[Y]);
				TskBuf[id].body_ang[i][W] = sqrt(pow(tpos[X],2.0) + pow(tpos[Y],2.0));
			}
			TskBuf[id].step++;
			break;
		case	1:
			TskBuf[id].px = TskBuf[ship_id].px;
			TskBuf[id].py = TskBuf[ship_id].py;
			if(TskBuf[ship_id].step != 3 && !TskBuf[ship_id].fp_int || (TskBuf[ship_id].tskid & TSKID_MUTEKI) || boss_flag == 2){
				TskBuf[id].fp_draw = &TSKbarrierDraw;
				TskBuf[id].step++;
				TskBuf[id].wait = 15;
			}
			TskBuf[id].rot -= PI / 60.0f;
			break;
		case	2:
			TskBuf[id].px = TskBuf[ship_id].px;
			TskBuf[id].py = TskBuf[ship_id].py;
			if(!TskBuf[id].wait){
				TskBuf[id].alpha = 1.0f;
				TskBuf[id].step++;
			}else{
				TskBuf[id].alpha += (1.0f / 15.0f);
				TskBuf[id].wait--;
			}
			TskBuf[id].rot -= PI / 60.0f;
			break;
		case	3:
			TskBuf[id].px = TskBuf[ship_id].px;
			TskBuf[id].py = TskBuf[ship_id].py;
			if(TskBuf[ship_id].fp_int && !(TskBuf[ship_id].tskid & TSKID_MUTEKI) && boss_flag != 2){
				TskBuf[id].step++;
				TskBuf[id].wait = 15;
			}
			TskBuf[id].rot -= PI / 60.0f;
			break;
		case	4:
			TskBuf[id].px = TskBuf[ship_id].px;
			TskBuf[id].py = TskBuf[ship_id].py;
			if(!TskBuf[id].wait){
				TskBuf[id].alpha = 0.0f;
				TskBuf[id].step = 1;
				TskBuf[id].fp_draw = null;
			}else{
				TskBuf[id].alpha -= (1.0f / 15.0f);
				TskBuf[id].wait--;
			}
			TskBuf[id].rot -= PI / 60.0f;
			break;
		default:
			clrTSK(id);
			break;
	}

	return;
}

void	TSKbarrierDraw(int id)
{
	float[XYZ]	pos;

	glColor4f(0.25f,0.25f,0.50f,(0.25f * TskBuf[id].alpha));
	glBegin(GL_POLYGON);
	for(int i = 0; i < TskBuf[id].body_list.length; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
	glColor4f(1.0f,1.0f,1.0f,(1.0f * TskBuf[id].alpha));
	glBegin(GL_LINE_LOOP);
	for(int i = 0; i < TskBuf[id].body_list.length; i++){
		pos[X] = sin(TskBuf[id].body_ang[i][X] + TskBuf[id].rot) * getPointX(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Y] = cos(TskBuf[id].body_ang[i][Y] + TskBuf[id].rot) * getPointY(TskBuf[id].body_ang[i][W] * 3.0f, TskBuf[id].pz);
		pos[Z] = TskBuf[id].body_ang[i][Z];
		glVertex3f(pos[X] - getPointX(TskBuf[id].px - scr_pos[X], TskBuf[id].pz),
				   pos[Y] - getPointY(TskBuf[id].py - scr_pos[Y], TskBuf[id].pz),
				   pos[Z]);
	}
	glEnd();
}

void	BombOFF()
{
	ship_bomb = 0;
}

void	BombON()
{
	ship_bomb_wait = 0;
	ship_bomb = 1;
}

void	BombEXEC()
{
	ship_bomb = 2;
}

void	BombWAIT()
{
	ship_bomb_wait = 60;
	ship_bomb = 3;
}

void	BombSTOP()
{
	ship_bomb = 4;
}

int	BombTST()
{
	return	(ship_bomb == 1);
}

int	BombTSTexec()
{
	return	(ship_bomb == 2);
}

int	BombTSTwait()
{
	return	(ship_bomb == 3);
}

void	BmbGaugeAdd(int add)
{
	if(bomb_lv != BOMB_MAX){
		bomb += add;
		if(bomb >= (BOMB_ONE * BOMB_MAX)) bomb = BOMB_ONE * BOMB_MAX;
	}
}

void	BombADDscore(int add_score)
{
	bomb_bonus += add_score;
	bomb_remain += BOMB_REMAIN_ADD;
	if(bomb_bonus > BOMB_SCORE_MAX) bomb_bonus = BOMB_SCORE_MAX;
	if(bomb_remain > BOMB_REMAIN_MAX) bomb_remain = BOMB_REMAIN_MAX;
}

void	BombREMAINscore()
{
	if(bomb_remain){
		bomb_remain--;
	}else{
		if(!(turn % 30)){
			if(bomb_bonus){
				bomb_bonus -= 10;
			}
		}
	}
}

void	BmbGaugeExec()
{
	bomb_lv = bomb / BOMB_ONE;
}

float	getShipLength(float px,float py)
{
	float	len = 0;
	float	lpx,lpy;

	lpx = fabs(TskBuf[ship_id].px - px);
	lpy = fabs(TskBuf[ship_id].py - py);
	lpx = pow(lpx, 2.0f);
	lpy = pow(lpy, 2.0f);
	len = sqrt(lpx + lpy);

	return	len;
}

float	getTargetDirection(int id)
{
	float	px,py;
	float	dir;
	int		tid;

	tid = TskBuf[id].trg_id;
	px = TskBuf[id].tx - TskBuf[tid].px;
	py = TskBuf[id].ty - TskBuf[tid].py;
	dir = atan2(px, py);

	return	dir;
}

int getNearEnemy(int id,float length)
{
	int	eid = -1;
	int	prev;
	float max = length;
	float tmp;

	for(int i = TskIndex[GROUP_02]; i != -1; i = prev){
		prev = TskBuf[i].prev;
		if(TskBuf[i].tskid != 0 && (TskBuf[i].tskid & (TSKID_ZAKO+TSKID_BOSS)) && TskBuf[i].fp_int != null){
			tmp = getShipLength(TskBuf[i].px,TskBuf[i].py);
			if(tmp < length && max > tmp){
				eid = i;
				max = tmp;
			}
		}
	}

	return	eid;
}

void	shipLockOff(int id)
{
	if(TskBuf[ship_id].trg_id == id){
		ship_lock = 0;
		TskBuf[ship_id].trg_id = -1;
	}
}

int	getAttractPadData(int id)
{
	if(g_step != GSTEP_DEMO) return	pads;

	int	eid = getNearEnemy(id, 4096.0f);
	int	pad = 0;

	/* 移動 */
	if(eid != -1){
		if(TskBuf[id].px > TskBuf[eid].px){
			pad |= PAD_RIGHT;
		}else if(TskBuf[id].px < TskBuf[eid].px){
			pad |= PAD_LEFT;
		}
		if(TskBuf[id].py > TskBuf[eid].py){
			pad |= PAD_UP;
		}else if(TskBuf[id].py < TskBuf[eid].py){
			pad |= PAD_DOWN;
		}
	}

/*
			demo_move = 0;
			demo_fire = 0;
*/

	eid = getNearEnemy(id, 512.0f);

	if(demo_eid != eid){
		demo_fire = 0;
		demo_eid = eid;
	}

	/* ショット */
	if(!demo_fire && eid != -1){
		demo_fire = Rand() % 120 + 120;
	}else{
		if(demo_fire){
			demo_fire--;
			pad |= PAD_SHOT;
		}
		//pad = PAD_BOMB;
	}

	return	pad;
}

int	getAttractTrgData(int id, int pad, int old_pad)
{
	if(g_step != GSTEP_DEMO) return	trgs;
	return	pad & ~old_pad;
}
