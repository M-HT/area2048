/*
	area2048 'STAGE CTRL'

		'stg.d'

	2003/12/01 jumpei isshiki
*/

private	import	std.random;
private	import	core.stdc.stdio;
private	import	util_sdl;
private	import	util_snd;
private	import	util_pad;
private	import	define;
private	import	task;
private	import	main;
private	import	gctrl;
private	import	system;
private	import	effect;
private	import	bg;
private	import	stg01;
private	import	stg02;
private	import	stg03;
private	import	stg04;
private	import	stg05;
private	import	ship;
private	import	enemy01;
private	import	enemy02;
private	import	enemy03;
private	import	enemy04;
private	import	enemy05;
private	import	enemy06;
private	import	enemy07;
private	import	enemy08;
private	import	middle01;
private	import	middle02;
private	import	middle03;
private	import	middle04;
private	import	middle05;
private	import	boss01;
private	import	boss02;
private	import	boss03;
private	import	boss04;
private	import	boss05;

int	enemy_cnt;
int	enemy_max;
int	enemy_stg;
int	boss_flag;

int	area_num;
int	scene_num;

int	seq_wait;
int	seq_stg;
int	seq_top;
int	seq_loop;

int	stg_ctrl;
int	stg_bgm;

int[]	seq_stgexec;

private	int[]	seq_demo = [
								SEQ_SETENEMAX,16,
								SEQ_SETENEMY,ENMEY_01,
								SEQ_WAIT,15,
								SEQ_JUMP,2
							];

private	void	function(int)[]	enemy_func = [
												&TSKenemy01,
												&TSKenemy02,
												&TSKenemy03,
												&TSKenemy04,
												&TSKenemy05,
												&TSKenemy06,
												&TSKenemy07,
												&TSKenemy08,
												&TSKmiddle01,
												&TSKmiddle02,
												&TSKmiddle03,
												&TSKmiddle04,
												&TSKmiddle05,
												&TSKboss01,
												&TSKboss02,
												&TSKboss03,
												&TSKboss04,
												&TSKboss05,
											];

void	TSKstgCtrl(int id)
{
	switch(TskBuf[id].step){
		case	0:
			area_num = AREA_01;
			scene_num = SCENE_01;
			debug{
				//area_num = AREA_02;
				//area_num = AREA_03;
				//area_num = AREA_04;
				//area_num = AREA_05;
				//scene_num = SCENE_02;
				//scene_num = SCENE_03;
				//scene_num = SCENE_04;
				//scene_num = SCENE_05;
				//scene_num = SCENE_06;
				//scene_num = SCENE_07;
				//scene_num = SCENE_08;
				//scene_num = SCENE_09;
				//scene_num = SCENE_10;
			}
			stg_bgm = -1;
			stg_ctrl = STG_INIT;
			TskBuf[id].step++;
			break;
		case	1:
			switch(area_num){
				case	AREA_01:
					stg_ctrl = STG_MAIN;
					setTSK(GROUP_01,&TSKstg01);
					break;
				case	AREA_02:
					stg_ctrl = STG_MAIN;
					setTSK(GROUP_01,&TSKstg02);
					break;
				case	AREA_03:
					stg_ctrl = STG_MAIN;
					setTSK(GROUP_01,&TSKstg03);
					break;
				case	AREA_04:
					stg_ctrl = STG_MAIN;
					setTSK(GROUP_01,&TSKstg04);
					break;
				case	AREA_05:
					stg_ctrl = STG_MAIN;
					setTSK(GROUP_01,&TSKstg05);
					break;
				default:
					g_step = GSTEP_CLEAR;
					break;
			}
			TskBuf[id].step++;
			break;
		case	2:
			if(stg_ctrl == STG_GAMEOVER){
				setTSK(GROUP_08,&TSKgameover);
				time_flag = 0;
				TskBuf[id].step = 3;
				break;
			}
			if(stg_ctrl == STG_CLEAR){
				stg_ctrl = STG_INIT;
				scene_num++;
				if(scene_num && !(scene_num % 10)){
					time_total = 0;
					scene_num = SCENE_01;
					area_num++;
				}
				TskBuf[id].step = 1;
			}
			break;
		case	3:
			if(stg_ctrl != STG_GAMEOVER){
				g_step = GSTEP_CLEAR;
				TskBuf[id].step = -1;
			}
			break;
		default:
			break;
	}

	return;
}


void	TSKdemoCtrl(int id)
{
	switch(TskBuf[id].step){
		case	0:
			stg_ctrl = STG_INIT;
			TskBuf[id].step++;
			break;
		case	1:
			setTSK(GROUP_01,&TSKdemo);
			TskBuf[id].step++;
			break;
		case	2:
			break;
		default:
			break;
	}

	return;
}


void	TSKdemo(int id)
{
	switch(TskBuf[id].step){
		case	0:
			SEQinit();
			seq_stgexec = seq_demo;
			TskBuf[id].step++;
			break;
		case	1:
			if(seq_wait){
				seq_wait--;
				break;
			}
			if((seq_stg = SEQexec(seq_stg)) == -1){
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
	return;
}


void	TSKatrractCtrl(int id)
{
	switch(TskBuf[id].step){
		case	0:
			area_num = Rand() % AREA_05;
			printf("area %d\n",area_num);
			scene_num = SCENE_01;
			stg_bgm = -1;
			stg_ctrl = STG_INIT;
			TskBuf[id].step++;
			break;
		case	1:
			switch(area_num){
				case	AREA_01:
					stg_ctrl = STG_MAIN;
					setTSK(GROUP_01,&TSKstg01);
					break;
				case	AREA_02:
					stg_ctrl = STG_MAIN;
					setTSK(GROUP_01,&TSKstg02);
					break;
				case	AREA_03:
					stg_ctrl = STG_MAIN;
					setTSK(GROUP_01,&TSKstg03);
					break;
				case	AREA_04:
					stg_ctrl = STG_MAIN;
					setTSK(GROUP_01,&TSKstg04);
					break;
				case	AREA_05:
					stg_ctrl = STG_MAIN;
					setTSK(GROUP_01,&TSKstg05);
					break;
				default:
					g_step = GSTEP_CLEAR;
					break;
			}
			TskBuf[id].step++;
			break;
		case	2:
			if(stg_ctrl == STG_CLEAR){
				stg_ctrl = STG_INIT;
				scene_num++;
				if(scene_num && !(scene_num % 10)){
					time_total = 0;
					scene_num = SCENE_01;
					area_num++;
				}
				TskBuf[id].step = 1;
			}
			break;
		case	3:
			if(stg_ctrl != STG_GAMEOVER){
				g_step = GSTEP_CLEAR;
				TskBuf[id].step = -1;
			}
			break;
		default:
			break;
	}

	return;
}


void	SEQinit()
{
	seq_wait = 0;
	seq_stg = 0;
	seq_top = 0;
	seq_loop = 0;
	enemy_cnt = 0;
	enemy_max = 0;
}

int		SEQexec(int seq_pnt)
{
	int	eid;
	int	seq_flag = 0;

	while(!seq_flag){
		switch(seq_stgexec[seq_pnt]){
			case	SEQ_WAIT:
				seq_wait = seq_stgexec[seq_pnt+1];
				seq_flag = 1;
				seq_pnt += 2;
				break;
			case	SEQ_SETENEMY:
				if(enemy_cnt < enemy_max){
					setTSK(GROUP_02, enemy_func[seq_stgexec[seq_pnt+1]]);
					enemy_cnt++;
					seq_pnt += 2;
				}else{
					seq_flag = 1;
				}
				break;
			case	SEQ_SETENEMYID:
				if(enemy_cnt < enemy_max){
					eid = setTSK(GROUP_02, enemy_func[seq_stgexec[seq_pnt+1]]);
					TskBuf[eid].chr_id = seq_stgexec[seq_pnt+2];
					enemy_cnt++;
					seq_pnt += 3;
				}else{
					seq_flag = 1;
				}
				break;
			case	SEQ_EWAIT:
				if(enemy_cnt <= seq_stgexec[seq_pnt+1]){
					seq_pnt += 2;
				}else{
					seq_flag = 1;
				}
				break;
			case	SEQ_JUMP:
				seq_pnt = seq_stgexec[seq_pnt+1];
				break;
			case	SEQ_LOOPSET:
				seq_loop = seq_stgexec[seq_pnt+1];
				seq_pnt += 2;
				seq_top = seq_pnt;
				break;
			case	SEQ_STGINIT:
				clrTSKgroup(GROUP_04);
				clrTSKgroup(GROUP_06);
				seq_pnt += 1;
				break;
			case	SEQ_LOOP:
				seq_loop--;
				if(seq_loop){
					seq_pnt = seq_top;
				}else{
					seq_pnt += 1;
				}
				break;
			case	SEQ_REQBGM:
				if(stg_bgm != seq_stgexec[seq_pnt+1]){
					playSNDmusic(seq_stgexec[seq_pnt+1]);
					stg_bgm = seq_stgexec[seq_pnt+1];
				}
				seq_pnt += 2;
				break;
			case	SEQ_STOPBGM:
				stopSNDmusic();
				stg_bgm = -1;
				seq_pnt += 1;
				break;
			case	SEQ_SETENEMAX:
				enemy_max = seq_stgexec[seq_pnt+1];
				seq_pnt += 2;
				break;
			case	SEQ_SETBONUS:
				time_bonus = seq_stgexec[seq_pnt+1];
				opt_bonus = 0;
				seq_pnt += 2;
				break;
			case	SEQ_SETENESTG:
				enemy_stg = seq_stgexec[seq_pnt+1];
				seq_pnt += 2;
				break;
			case	SEQ_PLAYVOICE:
				playSNDse(seq_stgexec[seq_pnt+1]);
				seq_pnt += 2;
				break;
			case	SEQ_CHKVOICE:
				if(checkSNDse(7) == 1){
					seq_flag = 1;
				}else{
					seq_pnt += 1;
				}
				break;
			case	SEQ_TIMESTART:
				if(g_step != GSTEP_DEMO) pause_flag = 1;
				time_clear = time_left;
				time_flag = 1;
				seq_pnt += 1;
				break;
			case	SEQ_TIMESTOP:
				if(g_step != GSTEP_DEMO) pause_flag = 0;
				time_clear -= time_left;
				time_total += time_clear;
				time_flag = 0;
				seq_pnt += 1;
				break;
			case	SEQ_TIMEPAUSE:
				if(g_step != GSTEP_DEMO) pause_flag = 0;
				time_flag = 0;
				seq_pnt += 1;
				break;
			case	SEQ_TIMERESUME:
				time_flag = 1;
				seq_pnt += 1;
				break;
			case	SEQ_MSGSTART:
				setTSK(GROUP_08,&TSKstgStartMsg);
				seq_pnt += 1;
				break;
			case	SEQ_MSGCLEAR:
				setTSK(GROUP_08,&TSKstgClearMsg);
				seq_pnt += 1;
				break;
			case	SEQ_BGZOOM:
				eid = setTSK(GROUP_08,&TSKbgZoom);
				TskBuf[eid].wait = seq_stgexec[seq_pnt+1];
				TskBuf[eid].tx = BASE_Z + seq_stgexec[seq_pnt+2] / 10000.0f;
				seq_pnt += 3;
				break;
			case	SEQ_BGPOS:
				ship_px = seq_stgexec[seq_pnt+1];
				ship_py = seq_stgexec[seq_pnt+2];
				seq_pnt += 3;
				break;
			case	SEQ_SHIPINIT:
				TskBuf[ship_id].step = 100;
				seq_pnt += 1;
				break;
			case	SEQ_SHIPLOCK:
				TskBuf[ship_id].step = 101;
				seq_pnt += 1;
				break;
			case	SEQ_SHIPOFF:
				TskBuf[ship_id].step = 110;
				seq_pnt += 1;
				break;
			case	SEQ_SHIPSTART:
				TskBuf[ship_id].alpha = 0.0f;
				TskBuf[ship_id].step = 1;
				TskBuf[ship_id].wait = 120;
				TskBuf[ship_id].cnt = TskBuf[ship_id].wait;
				seq_pnt += 1;
				break;
			case	SEQ_SHIPMUTEKI:
				TskBuf[ship_id].tskid |= TSKID_MUTEKI;
				TskBuf[ship_id].alpha = 0.50f;
				TskBuf[ship_id].fp_int = null;
				seq_pnt += 1;
				break;
			case	SEQ_BOSSINIT:
				boss_flag = 0;
				seq_pnt += 1;
				break;
			case	SEQ_BOSSSTART:
				boss_flag = 1;
				seq_pnt += 1;
				break;
			case	SEQ_BOSSWAIT:
				if(boss_flag != 2) seq_flag = 1;
				else			   seq_pnt += 1;
				break;
			case	SEQ_BG_SET:
				if(bg_id == -1){
					eid = setTSK(GROUP_01,&TSKbg01);
					bg_id = eid;
				}
				seq_pnt += 1;
				break;
			case	SEQ_BG_CLR:
				if(bg_id != -1){
					clrTSK(bg_id);
					bg_id = -1;
				}
				seq_pnt += 1;
				break;
			case	SEQ_BG_ON:
				bg_disp = 1;
				seq_pnt += 1;
				break;
			case	SEQ_BG_OFF:
				bg_disp = 0;
				seq_pnt += 1;
				break;
			case	SEQ_FADE:
				fade_r = seq_stgexec[seq_pnt+1] / 256.0f;
				fade_g = seq_stgexec[seq_pnt+2] / 256.0f;
				fade_b = seq_stgexec[seq_pnt+3] / 256.0f;
				fade_a = seq_stgexec[seq_pnt+4] / 256.0f;
				TskBuf[fade_id].tx = seq_stgexec[seq_pnt+5] / 256.0f;
				TskBuf[fade_id].wait = seq_stgexec[seq_pnt+6];
				TskBuf[fade_id].step = 2;
				seq_pnt += 7;
				break;
			case	SEQ_END:
				seq_flag = 1;
				seq_pnt = -1;
				break;
			default:
				break;
		}
	}

	return	seq_pnt;
}
