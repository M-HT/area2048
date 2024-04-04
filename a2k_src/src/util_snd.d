/*
	D-System 'SOUND UTILITY'

		'util_snd.d'

	2003/12/02 jumpei isshiki
*/

private	import	std.string;
private	import	bindbc.sdl;

enum{
	SND_RATE = 44100,
	SND_CHANNEL = 2,
	SND_BUFFER = 2048,
}

int	vol_se = 100;
int	vol_music = 75;

private	bool			sound_use = false;
private	Mix_Music*[]	music;
private	Mix_Chunk*[]	chunk;
private	int[]			chunkChannel;

int		initSND(int mch, int sch)
{
	if(mch < 1 || sch < 1)
	{
		return	0;
	}
	if(SDL_InitSubSystem(SDL_INIT_AUDIO) < 0){
		return	0;
    }

    int		audio_rate;
    ushort	audio_format;
    int		audio_channels;
    int		audio_buffers;

	audio_rate = SND_RATE;
	audio_format = AUDIO_S16;
	audio_channels = SND_CHANNEL;
	audio_buffers = SND_BUFFER;
	bool sound_opened = false;
	static if(SDL_MIXER_VERSION_ATLEAST(2, 0, 2)){
		const SDL_version *link_version = Mix_Linked_Version();
		if (SDL_version(link_version.major, link_version.minor, link_version.patch) >= SDL_version(2, 0, 2)){
			sound_opened = true;
			if(Mix_OpenAudioDevice(audio_rate, audio_format, audio_channels, audio_buffers, null, 0xff) < 0){
				sound_use = false;
			}else{
				sound_use = true;
			}
		}
	}
	if (!sound_opened){
		if(Mix_OpenAudio(audio_rate, audio_format, audio_channels, audio_buffers) < 0){
			sound_use = false;
		}else{
			sound_use = true;
		}
	}
	Mix_QuerySpec(&audio_rate, &audio_format, &audio_channels);

	music.length = mch;
	for(int i = 0; i < music.length; i++){
		music[i] = null;
	}
	chunk.length = sch;
	chunkChannel.length = sch;
	for(int i = 0; i < chunk.length; i++){
		chunk[i] = null;
		chunkChannel[i] = -1;
	}

	return	1;
}


void	closeSND()
{
	if(!sound_use){
		return;
	}
	freeSND();
	Mix_CloseAudio();

	return;
}


void	loadSNDmusic(const char[] name, int ch)
{
	if(!sound_use){
		return;
	}

	music[ch] = Mix_LoadMUS(std.string.toStringz(name));
	if(!music[ch]){
		sound_use = false;
	}

	return;
}


void	loadSNDse(const char[] name, int bank, int ch)
{
	if(ch < 0){
		return;
	}
	if(!sound_use){
		return;
	}

	chunk[bank] = Mix_LoadWAV(std.string.toStringz(name));
	if(!chunk[bank]){
		sound_use = false;
	}
	chunkChannel[bank] = ch;

	return;
}


void	freeSND()
{
	for(int i = 0; i < music.length; i++){
	    if(music[i]){
			stopSNDmusic();
			Mix_FreeMusic(music[i]);
		}
		music[i] = null;
	}
	for(int i = 0; i < chunk.length; i++){
		if(chunk[i]){
			stopSNDse(chunkChannel[i]);
			Mix_FreeChunk(chunk[i]);
		}
	}

	return;
}


void	playSNDmusic(int ch)
{
	if(ch < 0 || !music[ch]){
		return;
	}
	if(!sound_use){
		return;
	}
    Mix_PlayMusic(music[ch], -1);

	return;
}


void	stopSNDmusic()
{
	if(!sound_use){
		return;
	}
    if(Mix_PlayingMusic()){
		Mix_HaltMusic();
	}

	return;
}


void	playSNDse(int bank)
{
	if(bank < 0 || chunkChannel[bank] == -1 || !chunk[bank]){
		return;
	}
	if(!sound_use){
		return;
	}
    Mix_PlayChannel(chunkChannel[bank], chunk[bank], 0);

	return;
}


void	stopSNDse(int bank)
{
	if(bank < 0 || chunkChannel[bank] == -1){
		return;
	}
	if(!sound_use){
		return;
	}
    Mix_HaltChannel(chunkChannel[bank]);

	return;
}


int		checkSNDse(int ch)
{
	if(ch < 0){
		return	0;
	}
	if(!sound_use){
		return	0;
	}

	return	Mix_Playing(ch);
}


void	stopSNDall()
{
	for(int i = 0; i < music.length; i++){
	    if(music[i]){
			stopSNDmusic();
		}
	}
	for(int i = 0; i < chunkChannel.length; i++){
		stopSNDse(i);
	}

	return;
}

void	volumeSNDse(int vol)
{
	int master = vol * 128 / 100;
	for(int i = 0; i < chunk.length; i++){
		if(chunk[i]){
			Mix_VolumeChunk(chunk[i], master);
		}
	}
}

void	volumeSNDmusic(int vol)
{
	int master = vol * 128 / 100;
	Mix_VolumeMusic(master);
}
