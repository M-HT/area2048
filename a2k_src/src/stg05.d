/*
	area2048 'STAGE-05'

		'stg05.d'

	2004/06/09 jumpei isshiki
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
								SEQ_REQBGM,SND_BGM05,
								SEQ_SETENESTG,1,
								SEQ_SETENEMAX,1,
								SEQ_SETBONUS,32*60,

								SEQ_SHIPINIT,
								SEQ_BOSSINIT,
								SEQ_WAIT,1,
								SEQ_SHIPOFF,

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

								SEQ_SETENEMY,BOSS_01,
								SEQ_BOSSSTART,

								SEQ_BOSSWAIT,
								SEQ_SHIPMUTEKI,
								SEQ_TIMESTOP,
								SEQ_EWAIT,0,

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
								SEQ_REQBGM,SND_BGM05,
								SEQ_SETENESTG,2,
								SEQ_SETENEMAX,2,
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

								SEQ_SETENEMYID,MIDDLE_01,0,
								SEQ_SETENEMYID,MIDDLE_01,1,
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
								SEQ_REQBGM,SND_BGM05,
								SEQ_SETENESTG,4,
								SEQ_SETENEMAX,4,
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

private	int[]	seq_stg04 = [
								SEQ_STGINIT,
								SEQ_REQBGM,SND_BGM05,
								SEQ_SETENESTG,1,
								SEQ_SETENEMAX,1,
								SEQ_SETBONUS,60*60,

								SEQ_SHIPINIT,
								SEQ_BOSSINIT,
								SEQ_WAIT,1,
								SEQ_SHIPOFF,

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

								SEQ_SETENEMY,BOSS_02,
								SEQ_BOSSSTART,

								SEQ_BOSSWAIT,
								SEQ_SHIPMUTEKI,
								SEQ_TIMESTOP,
								SEQ_EWAIT,0,

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
								SEQ_REQBGM,SND_BGM05,
								SEQ_SETENESTG,4,
								SEQ_SETENEMAX,4,
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

private	int[]	seq_stg06 = [
								SEQ_STGINIT,
								SEQ_REQBGM,SND_BGM05,
								SEQ_SETENESTG,2,
								SEQ_SETENEMAX,2,
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

private	int[]	seq_stg07 = [
								SEQ_STGINIT,
								SEQ_REQBGM,SND_BGM05,
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

								SEQ_SETENEMY,BOSS_03,
								SEQ_BOSSSTART,

								SEQ_BOSSWAIT,
								SEQ_SHIPMUTEKI,
								SEQ_TIMESTOP,
								SEQ_EWAIT,0,

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
								SEQ_REQBGM,SND_BGM05,
								SEQ_SETENESTG,4,
								SEQ_SETENEMAX,2,
								SEQ_SETBONUS,35*60,

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

								SEQ_SETENEMYID,MIDDLE_04,0,
								SEQ_SETENEMYID,MIDDLE_04,1,
								SEQ_SETENEMYID,MIDDLE_04,2,
								SEQ_SETENEMYID,MIDDLE_04,3,
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
								SEQ_REQBGM,SND_BGM05,
								SEQ_SETENESTG,4,
								SEQ_SETENEMAX,2,
								SEQ_SETBONUS,75*60,

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

								SEQ_SETENEMYID,MIDDLE_05,0,
								SEQ_SETENEMYID,MIDDLE_05,3,
								SEQ_SETENEMYID,MIDDLE_05,1,
								SEQ_SETENEMYID,MIDDLE_05,2,
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
								SEQ_REQBGM,SND_BGM05,
								SEQ_SETENESTG,2,
								SEQ_SETENEMAX,1,
								SEQ_SETBONUS,270*60,

								SEQ_SHIPINIT,
								SEQ_BOSSINIT,
								SEQ_WAIT,1,
								SEQ_SHIPOFF,

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

								SEQ_SETENEMY,BOSS_04,
								SEQ_BOSSSTART,

								SEQ_BOSSWAIT,
								SEQ_SHIPLOCK,
								SEQ_SHIPMUTEKI,
								SEQ_EWAIT,0,

								SEQ_STOPBGM,
								SEQ_TIMEPAUSE,

								SEQ_SHIPOFF,
								SEQ_BOSSINIT,
								SEQ_WAIT,1,

								SEQ_PLAYVOICE,SND_VOICE_EMERGENCY,
								SEQ_WAIT,90,

								SEQ_SETENEMY,BOSS_05,

								SEQ_BGZOOM,15, -12500,
								SEQ_BGPOS,+0,+0,
								SEQ_REQBGM,SND_BOSS02,
								SEQ_CHKVOICE,
								SEQ_WAIT,30,

								SEQ_BOSSSTART,
								SEQ_SHIPSTART,
								SEQ_TIMERESUME,
								SEQ_BGZOOM,60, -7500,
								SEQ_WAIT,60,


								SEQ_PLAYVOICE,SND_VOICE_GETREADY,
								SEQ_CHKVOICE,
								SEQ_WAIT,15,

								SEQ_BOSSWAIT,
								SEQ_SHIPMUTEKI,
								SEQ_SHIPLOCK,
								SEQ_STOPBGM,
								SEQ_TIMESTOP,
								SEQ_EWAIT,0,

								SEQ_MSGCLEAR,
								SEQ_PLAYVOICE,SND_VOICE_COMPLETE,
								SEQ_CHKVOICE,
								SEQ_WAIT,60,
								SEQ_FADE,256,256,256,  0,256,60,
								SEQ_BGZOOM,60,-16000,
								SEQ_WAIT,60,
								SEQ_BG_OFF,
								SEQ_WAIT,1,
								SEQ_BG_CLR,
								SEQ_END,
							];

void	TSKstg05(int id)
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
					seq_stgexec = seq_stg10;
					break;
				default:
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
