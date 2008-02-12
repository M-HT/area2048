/*
	area2048 'STAGE-03'

		'stg03.d'

	2004/05/30 jumpei isshiki
*/

private	import	util_sdl;
private	import	util_snd;
private	import	define;
private	import	task;
private	import	gctrl;
private	import	system;
private	import	effect;
private	import	bg;
private	import	stg;
private	import	ship;

private	int[]	seq_stg01 = [
								SEQ_STGINIT,
								SEQ_REQBGM,SND_BGM03,
								SEQ_SETENESTG,12,
								SEQ_SETENEMAX,8,
								SEQ_SETBONUS,24*60,

								SEQ_BG_SET,
								SEQ_WAIT,1,
								SEQ_FADE,256,256,256,256,  0,30,
								SEQ_SHIPINIT,
								SEQ_BGZOOM,1,-16000,
								SEQ_WAIT,1,
								SEQ_BG_ON,
								SEQ_BGZOOM,60, -7500,

								SEQ_SHIPSTART,
								SEQ_MSGSTART,
								SEQ_PLAYVOICE,SND_VOICE_GETREADY,
								SEQ_CHKVOICE,
								SEQ_WAIT,15,
								SEQ_TIMESTART,

								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_01,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_03,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_05,
								SEQ_WAIT,15,
								SEQ_LOOP,

								SEQ_EWAIT,0,

								SEQ_TIMESTOP,
								SEQ_MSGCLEAR,
								SEQ_PLAYVOICE,SND_VOICE_SCENE,
								SEQ_CHKVOICE,
								SEQ_SHIPLOCK,
								SEQ_FADE,256,256,256,  0,256,60,
								SEQ_BGZOOM,60,-16000,
								SEQ_WAIT,60,
								SEQ_BG_OFF,
								SEQ_END,
							];

private	int[]	seq_stg02 = [
								SEQ_STGINIT,
								SEQ_REQBGM,SND_BGM03,
								SEQ_SETENESTG,16,
								SEQ_SETENEMAX,8,
								SEQ_SETBONUS,32*60,

								SEQ_BG_SET,
								SEQ_WAIT,1,
								SEQ_FADE,256,256,256,256,  0,30,
								SEQ_SHIPINIT,
								SEQ_BGZOOM,1,-16000,
								SEQ_WAIT,1,
								SEQ_BG_ON,
								SEQ_BGZOOM,60, -7500,

								SEQ_SHIPSTART,
								SEQ_MSGSTART,
								SEQ_PLAYVOICE,SND_VOICE_GETREADY,
								SEQ_CHKVOICE,
								SEQ_WAIT,15,
								SEQ_TIMESTART,

								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_02,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_03,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_04,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_05,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_EWAIT,0,

								SEQ_TIMESTOP,
								SEQ_MSGCLEAR,
								SEQ_PLAYVOICE,SND_VOICE_SCENE,
								SEQ_CHKVOICE,
								SEQ_SHIPLOCK,
								SEQ_FADE,256,256,256,  0,256,60,
								SEQ_BGZOOM,60,-16000,
								SEQ_WAIT,60,
								SEQ_BG_OFF,
								SEQ_END,
							];

private	int[]	seq_stg03 = [
								SEQ_STGINIT,
								SEQ_REQBGM,SND_BGM03,
								SEQ_SETENESTG,16,
								SEQ_SETENEMAX,8,
								SEQ_SETBONUS,32*60,

								SEQ_BG_SET,
								SEQ_WAIT,1,
								SEQ_FADE,256,256,256,256,  0,30,
								SEQ_SHIPINIT,
								SEQ_BGZOOM,1,-16000,
								SEQ_WAIT,1,
								SEQ_BG_ON,
								SEQ_BGZOOM,60, -7500,

								SEQ_SHIPSTART,
								SEQ_MSGSTART,
								SEQ_PLAYVOICE,SND_VOICE_GETREADY,
								SEQ_CHKVOICE,
								SEQ_WAIT,15,
								SEQ_TIMESTART,

								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_03,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,12,
								SEQ_SETENEMY,ENMEY_05,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_EWAIT,0,

								SEQ_TIMESTOP,
								SEQ_MSGCLEAR,
								SEQ_PLAYVOICE,SND_VOICE_SCENE,
								SEQ_CHKVOICE,
								SEQ_SHIPLOCK,
								SEQ_FADE,256,256,256,  0,256,60,
								SEQ_BGZOOM,60,-16000,
								SEQ_WAIT,60,
								SEQ_BG_OFF,
								SEQ_END,
							];

private	int[]	seq_stg04 = [
								SEQ_STGINIT,
								SEQ_REQBGM,SND_BGM03,
								SEQ_SETENESTG,12,
								SEQ_SETENEMAX,8,
								SEQ_SETBONUS,64*60,

								SEQ_BG_SET,
								SEQ_WAIT,1,
								SEQ_FADE,256,256,256,256,  0,30,
								SEQ_SHIPINIT,
								SEQ_BGZOOM,1,-16000,
								SEQ_WAIT,1,
								SEQ_BG_ON,
								SEQ_BGZOOM,60, -7500,

								SEQ_SHIPSTART,
								SEQ_MSGSTART,
								SEQ_PLAYVOICE,SND_VOICE_GETREADY,
								SEQ_CHKVOICE,
								SEQ_WAIT,15,
								SEQ_TIMESTART,

								SEQ_LOOPSET,8,
								SEQ_SETENEMY,ENMEY_05,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_EWAIT,0,

								SEQ_SETENEMAX,2,
								SEQ_SETENEMYID,MIDDLE_02,0,
								SEQ_SETENEMYID,MIDDLE_02,1,
								SEQ_SETENEMYID,MIDDLE_02,2,
								SEQ_SETENEMYID,MIDDLE_02,3,
								SEQ_EWAIT,0,

								SEQ_TIMESTOP,
								SEQ_MSGCLEAR,
								SEQ_PLAYVOICE,SND_VOICE_SCENE,
								SEQ_CHKVOICE,
								SEQ_SHIPLOCK,
								SEQ_FADE,256,256,256,  0,256,60,
								SEQ_BGZOOM,60,-16000,
								SEQ_WAIT,60,
								SEQ_BG_OFF,
								SEQ_END,
							];

private	int[]	seq_stg05 = [
								SEQ_STGINIT,
								SEQ_REQBGM,SND_BGM03,
								SEQ_SETENESTG,24,
								SEQ_SETENEMAX,8,
								SEQ_SETBONUS,48*60,

								SEQ_BG_SET,
								SEQ_WAIT,1,
								SEQ_FADE,256,256,256,256,  0,30,
								SEQ_SHIPINIT,
								SEQ_BGZOOM,1,-16000,
								SEQ_WAIT,1,
								SEQ_BG_ON,
								SEQ_BGZOOM,60, -7500,

								SEQ_SHIPSTART,
								SEQ_MSGSTART,
								SEQ_PLAYVOICE,SND_VOICE_GETREADY,
								SEQ_CHKVOICE,
								SEQ_WAIT,15,
								SEQ_TIMESTART,

								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_01,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_02,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_03,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_04,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_05,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_06,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_EWAIT,0,

								SEQ_TIMESTOP,
								SEQ_MSGCLEAR,
								SEQ_PLAYVOICE,SND_VOICE_SCENE,
								SEQ_CHKVOICE,
								SEQ_SHIPLOCK,
								SEQ_FADE,256,256,256,  0,256,60,
								SEQ_BGZOOM,60,-16000,
								SEQ_WAIT,60,
								SEQ_BG_OFF,
								SEQ_END,
							];

private	int[]	seq_stg06 = [
								SEQ_STGINIT,
								SEQ_REQBGM,SND_BGM03,
								SEQ_SETENESTG,24,
								SEQ_SETENEMAX,8,
								SEQ_SETBONUS,48*60,

								SEQ_BG_SET,
								SEQ_WAIT,1,
								SEQ_FADE,256,256,256,256,  0,30,
								SEQ_SHIPINIT,
								SEQ_BGZOOM,1,-16000,
								SEQ_WAIT,1,
								SEQ_BG_ON,
								SEQ_BGZOOM,60, -7500,

								SEQ_SHIPSTART,
								SEQ_MSGSTART,
								SEQ_PLAYVOICE,SND_VOICE_GETREADY,
								SEQ_CHKVOICE,
								SEQ_WAIT,15,
								SEQ_TIMESTART,

								SEQ_LOOPSET,6,
								SEQ_SETENEMY,ENMEY_03,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,6,
								SEQ_SETENEMY,ENMEY_04,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,6,
								SEQ_SETENEMY,ENMEY_05,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,6,
								SEQ_SETENEMY,ENMEY_06,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_EWAIT,0,

								SEQ_TIMESTOP,
								SEQ_MSGCLEAR,
								SEQ_PLAYVOICE,SND_VOICE_SCENE,
								SEQ_CHKVOICE,
								SEQ_SHIPLOCK,
								SEQ_FADE,256,256,256,  0,256,60,
								SEQ_BGZOOM,60,-16000,
								SEQ_WAIT,60,
								SEQ_BG_OFF,
								SEQ_END,
							];

private	int[]	seq_stg07 = [
								SEQ_STGINIT,
								SEQ_REQBGM,SND_BGM03,
								SEQ_SETENESTG,24,
								SEQ_SETENEMAX,8,
								SEQ_SETBONUS,48*60,

								SEQ_BG_SET,
								SEQ_WAIT,1,
								SEQ_FADE,256,256,256,256,  0,30,
								SEQ_SHIPINIT,
								SEQ_BGZOOM,1,-16000,
								SEQ_WAIT,1,
								SEQ_BG_ON,
								SEQ_BGZOOM,60, -7500,

								SEQ_SHIPSTART,
								SEQ_MSGSTART,
								SEQ_PLAYVOICE,SND_VOICE_GETREADY,
								SEQ_CHKVOICE,
								SEQ_WAIT,15,
								SEQ_TIMESTART,

								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_03,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_05,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_04,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_06,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_04,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_06,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_EWAIT,0,

								SEQ_TIMESTOP,
								SEQ_MSGCLEAR,
								SEQ_PLAYVOICE,SND_VOICE_SCENE,
								SEQ_CHKVOICE,
								SEQ_SHIPLOCK,
								SEQ_FADE,256,256,256,  0,256,60,
								SEQ_BGZOOM,60,-16000,
								SEQ_WAIT,60,
								SEQ_BG_OFF,
								SEQ_END,
							];

private	int[]	seq_stg08 = [
								SEQ_STGINIT,
								SEQ_REQBGM,SND_BGM03,
								SEQ_SETENESTG,10,
								SEQ_SETENEMAX,8,
								SEQ_SETBONUS,40*60,

								SEQ_BG_SET,
								SEQ_WAIT,1,
								SEQ_FADE,256,256,256,256,  0,30,
								SEQ_SHIPINIT,
								SEQ_BGZOOM,1,-16000,
								SEQ_WAIT,1,
								SEQ_BG_ON,
								SEQ_BGZOOM,60, -7500,

								SEQ_SHIPSTART,
								SEQ_MSGSTART,
								SEQ_PLAYVOICE,SND_VOICE_GETREADY,
								SEQ_CHKVOICE,
								SEQ_WAIT,15,
								SEQ_TIMESTART,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_05,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_06,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_EWAIT,0,

								SEQ_SETENEMYID,MIDDLE_03,0,
								SEQ_SETENEMYID,MIDDLE_03,1,
								SEQ_EWAIT,0,

								SEQ_TIMESTOP,
								SEQ_MSGCLEAR,
								SEQ_PLAYVOICE,SND_VOICE_SCENE,
								SEQ_CHKVOICE,
								SEQ_SHIPLOCK,
								SEQ_FADE,256,256,256,  0,256,60,
								SEQ_BGZOOM,60,-16000,
								SEQ_WAIT,60,
								SEQ_BG_OFF,
								SEQ_END,
							];

private	int[]	seq_stg09 = [
								SEQ_STGINIT,
								SEQ_REQBGM,SND_BGM03,
								SEQ_SETENESTG,32,
								SEQ_SETENEMAX,8,
								SEQ_SETBONUS,48*60,

								SEQ_BG_SET,
								SEQ_WAIT,1,
								SEQ_FADE,256,256,256,256,  0,30,
								SEQ_SHIPINIT,
								SEQ_BGZOOM,1,-16000,
								SEQ_WAIT,1,
								SEQ_BG_ON,
								SEQ_BGZOOM,60, -7500,

								SEQ_SHIPSTART,
								SEQ_MSGSTART,
								SEQ_PLAYVOICE,SND_VOICE_GETREADY,
								SEQ_CHKVOICE,
								SEQ_WAIT,15,
								SEQ_TIMESTART,

								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_01,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_02,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_03,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,4,
								SEQ_SETENEMY,ENMEY_04,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,8,
								SEQ_SETENEMY,ENMEY_05,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_LOOPSET,8,
								SEQ_SETENEMY,ENMEY_06,
								SEQ_WAIT,15,
								SEQ_LOOP,
								SEQ_EWAIT,0,

								SEQ_TIMESTOP,
								SEQ_MSGCLEAR,
								SEQ_PLAYVOICE,SND_VOICE_SCENE,
								SEQ_CHKVOICE,
								SEQ_SHIPLOCK,
								SEQ_FADE,256,256,256,  0,256,60,
								SEQ_BGZOOM,60,-16000,
								SEQ_WAIT,60,
								SEQ_BG_OFF,
								SEQ_END,
							];

private	int[]	seq_stg10 = [
								SEQ_STGINIT,
								SEQ_STOPBGM,
								SEQ_SETENESTG,1,
								SEQ_SETENEMAX,1,
								SEQ_SETBONUS,90*60,

								SEQ_SHIPINIT,
								SEQ_BOSSINIT,
								SEQ_WAIT,1,
								SEQ_SHIPOFF,

								SEQ_BG_SET,
								SEQ_WAIT,1,
								SEQ_FADE,256,256,256,256,  0,30,
								SEQ_BGZOOM,1,-16000,
								SEQ_WAIT,1,
								SEQ_BG_ON,
								SEQ_BGZOOM,60, -7500,

								SEQ_MSGSTART,
								SEQ_PLAYVOICE,SND_VOICE_EMERGENCY,
								SEQ_WAIT,90,

								SEQ_SETENEMY,BOSS_03,

								SEQ_BGZOOM,15, -12500,
								SEQ_BGPOS,+0,+0,
								SEQ_REQBGM,SND_BOSS01,
								SEQ_CHKVOICE,
								SEQ_WAIT,30,

								SEQ_BOSSSTART,

								SEQ_SHIPSTART,
								SEQ_BGZOOM,60, -7500,
								SEQ_WAIT,60,

								SEQ_PLAYVOICE,SND_VOICE_GETREADY,
								SEQ_CHKVOICE,
								SEQ_WAIT,15,
								SEQ_TIMESTART,

								SEQ_BOSSWAIT,
								SEQ_SHIPMUTEKI,
								SEQ_STOPBGM,
								SEQ_TIMESTOP,
								SEQ_EWAIT,0,

								SEQ_MSGCLEAR,
								SEQ_PLAYVOICE,SND_VOICE_AREA,
								SEQ_CHKVOICE,
								SEQ_SHIPLOCK,
								SEQ_FADE,256,256,256,  0,256,60,
								SEQ_BGZOOM,60,-16000,
								SEQ_WAIT,60,
								SEQ_BG_OFF,
								SEQ_WAIT,1,
								SEQ_BG_CLR,
								SEQ_END,
							];

void	TSKstg03(int id)
{
	switch(TskBuf[id].step){
		case	0:
			SEQinit();
			switch(scene_num){
				case	SCENE_01:
					seq_stgexec = seq_stg01;
					break;
				case	SCENE_02:
					seq_stgexec = seq_stg02;
					break;
				case	SCENE_03:
					seq_stgexec = seq_stg03;
					break;
				case	SCENE_04:
					seq_stgexec = seq_stg04;
					break;
				case	SCENE_05:
					seq_stgexec = seq_stg05;
					break;
				case	SCENE_06:
					seq_stgexec = seq_stg06;
					break;
				case	SCENE_07:
					seq_stgexec = seq_stg07;
					break;
				case	SCENE_08:
					seq_stgexec = seq_stg08;
					break;
				case	SCENE_09:
					seq_stgexec = seq_stg09;
					break;
				case	SCENE_10:
				default:
					seq_stgexec = seq_stg10;
					break;
			}
			seq_top = 0;
			TskBuf[id].step++;
			break;
		case	1:
			if(stg_ctrl != STG_MAIN) break;
			if(seq_wait){
				seq_wait--;
				break;
			}
			if((seq_stg = SEQexec(seq_stg)) == -1){
				stg_ctrl = STG_CLEAR;
				TskBuf[id].step = -1;
			}
			break;
		default:
			clrTSK(id);
			break;
	}
	return;
}
