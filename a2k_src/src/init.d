/*
	D-System 'INITIALIZE'

		'init.d'

	2003/12/01 jumpei isshiki
*/

private	import	std.stdio;
private	import	std.stream;
private	import	util_sdl;
private	import	util_snd;
private	import	util_pad;
private	import	bulletcommand;
private	import	define;
private	import	gctrl;

void	grpINIT()
{
	readSDLtexture("title.bmp", GRP_TITLE);
}

void	sndINIT()
{
	/* 曲 */
	loadSNDmusic("stg01.ogg",SND_BGM01);
	loadSNDmusic("stg02.ogg",SND_BGM02);
	loadSNDmusic("stg03.ogg",SND_BGM03);
	loadSNDmusic("stg04.ogg",SND_BGM04);
	loadSNDmusic("stg05.ogg",SND_BGM05);
	loadSNDmusic("boss01.ogg",SND_BOSS01);
	loadSNDmusic("boss02.ogg",SND_BOSS02);
	/* SE */
	loadSNDse("se_sdest.wav",SND_SE_SDEST,1);
	loadSNDse("se_dmg01.wav",SND_SE_EDMG,2);
	loadSNDse("se_explode01.wav",SND_SE_EDEST,3);
	loadSNDse("se_explode02.wav",SND_SE_EEXP01,3);
	loadSNDse("se_explode03.wav",SND_SE_EEXP02,3);
	loadSNDse("se_cursole.wav",SND_SE_CURSOLE,1);
	loadSNDse("se_correct.wav",SND_SE_CORRECT,1);
	loadSNDse("se_cancel.wav",SND_SE_CANCEL,1);
	loadSNDse("se_lock_on.wav",SND_SE_LOCK_ON,1);
	loadSNDse("se_lock_off.wav",SND_SE_LOCK_OFF,1);
	/* VOICE */
	loadSNDse("voice04.wav",SND_VOICE_GETREADY,7);
	loadSNDse("voice06.wav",SND_VOICE_EXTEND,6);
	loadSNDse("voice07.wav",SND_VOICE_CHARGE,5);
	loadSNDse("voice08.wav",SND_VOICE_SCENE,7);
	loadSNDse("voice09.wav",SND_VOICE_COMPLETE,7);
	loadSNDse("voice10.wav",SND_VOICE_EMERGENCY,7);
	loadSNDse("voice11.wav",SND_VOICE_AREA,7);

	volumeSNDse(vol_se);
	volumeSNDmusic(vol_music);
}

void	bulletINIT()
{
	/* BULLET */
	initBulletcommandParser(256);
	readBulletcommandParser( BULLET_SHIP01, "bullet01.xml");
	readBulletcommandParser( BULLET_SHIP02, "bullet02.xml");
	readBulletcommandParser( BULLET_ZAKO03, "bulletzako03.xml");
	readBulletcommandParser( BULLET_ZAKO04, "bulletzako04.xml");
	readBulletcommandParser( BULLET_ZAKO05, "bulletzako05.xml");
	readBulletcommandParser( BULLET_ZAKO06, "bulletzako06.xml");
	readBulletcommandParser( BULLET_ZAKO07, "bulletzako07.xml");
	readBulletcommandParser( BULLET_ZAKO08, "bulletzako08.xml");
	readBulletcommandParser( BULLET_MIDDLE01, "bulletmid01.xml");
	readBulletcommandParser( BULLET_MIDDLE02, "bulletmid02.xml");
	readBulletcommandParser( BULLET_MIDDLE03, "bulletmid03.xml");
	readBulletcommandParser( BULLET_MIDDLE04, "bulletmid04.xml");
	readBulletcommandParser( BULLET_MIDDLE05, "bulletmid05.xml");
	readBulletcommandParser( BULLET_BOSS0101, "bulletboss0101.xml");
	readBulletcommandParser( BULLET_BOSS0102, "bulletboss0102.xml");
	readBulletcommandParser( BULLET_BOSS0201, "bulletboss0201.xml");
	readBulletcommandParser( BULLET_BOSS0202, "bulletboss0202.xml");
	readBulletcommandParser( BULLET_BOSS0301, "bulletboss0301.xml");
	readBulletcommandParser( BULLET_BOSS0302, "bulletboss0302.xml");
	readBulletcommandParser( BULLET_BOSS0401, "bulletboss0401.xml");
	readBulletcommandParser( BULLET_BOSS0402, "bulletboss0402.xml");
	readBulletcommandParser( BULLET_BOSS0403, "bulletboss0403.xml");
	readBulletcommandParser( BULLET_BOSS0404, "bulletboss0404.xml");
	readBulletcommandParser( BULLET_BOSS0501, "bulletboss0501.xml");
	readBulletcommandParser( BULLET_BOSS0502, "bulletboss0502.xml");
	readBulletcommandParser( BULLET_BOSS0503, "bulletboss0503.xml");
	readBulletcommandParser( BULLET_BOSS0504, "bulletboss0504.xml");
	readBulletcommandParser( BULLET_BOSS0505, "bulletboss0505.xml");
	readBulletcommandParser( BULLET_BOSS0506, "bulletboss0506.xml");
}

void	configINIT()
{
	high_easy = 0;
	high_normal = 0;
	high_hard = 0;

	scope std.stream.File fd = new std.stream.File;

	try {
		fd.open("score.dat");
		if(fd.size() != 12){
			fd.close();
			writefln("score.dat initialized");
		    fd.create("score.dat");
			fd.write(high_easy);
			fd.write(high_normal);
			fd.write(high_hard);
		}else{
			fd.read(high_easy);
			fd.read(high_normal);
			fd.read(high_hard);
		}
	} catch (Error e) {
		writefln("score.dat initialized");
	    fd.create("score.dat");
		fd.write(high_easy);
		fd.write(high_normal);
		fd.write(high_hard);
		fd.close();
	} finally {
		fd.close();
    }

	fd.open("config.dat");
	try {
		if(fd.size() != 12){
			fd.close();
			writefln("config.dat initialized");
		    fd.create("config.dat");
			fd.write(pad_type);
			fd.write(vol_se);
			fd.write(vol_music);
		}else{
			fd.read(pad_type);
			fd.read(vol_se);
			fd.read(vol_music);
			volumeSNDse(vol_se);
			volumeSNDmusic(vol_music);
		}
	} catch (Error e) {
		writefln("config.dat initialized");
	    fd.create("config.dat");
		fd.write(pad_type);
		fd.write(vol_se);
		fd.write(vol_music);
		fd.close();
	} finally {
		fd.close();
    }
}

void	configSAVE()
{
	scope std.stream.File fd = new std.stream.File;
    fd.create("score.dat");
	fd.write(high_easy);
	fd.write(high_normal);
	fd.write(high_hard);
	fd.close();

    fd.create("config.dat");
	fd.write(pad_type);
	fd.write(vol_se);
	fd.write(vol_music);
	fd.close();
}
