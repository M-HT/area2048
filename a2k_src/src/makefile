DC = dmd
CP = cp
CD = cd
DEL = rm -f
INCLUDES += -I../import
#LIBS += SDL.lib SDL_mixer.lib opengl32.lib bulletml.lib
LIBS += SDL.lib SDL_mixer.lib bulletml.lib glu32.lib opengl32.lib
SOURCES = $(wildcard *.d)
OBJS = $(SOURCES:.d=.obj)
#EXE = main.exe
EXE = a2k.exe
#DFLAGS = -c -op -debug -g
DFLAGS = -c -inline -release -O
SDLSOURCES = $(wildcard ../import/*.d)
SDLOBJS = $(SDLSOURCES:.d=.obj)

all: $(EXE)

$(EXE): $(OBJS) a2k.def $(SDLOBJS)
	$(DC) -L/ma $(OBJS) $(SDLOBJS) $(EXE) $(LIBS)
#	$(DC) -L/ma $(OBJS) $(SDLOBJS) $(EXE) $(LIBS) a2k.def
	$(CP) $(EXE) ..\exec\

$(OBJS): %.obj:%.d
	$(DC) $(DFLAGS) $(INCLUDES) $<

$(SDLOBJS): %.obj:%.d
	$(DC) $(DFLAGS) $(INCLUDES) $<

clean: 
	$(DEL) *.map $(OBJS) $(EXE) 

clean_all: 
	$(DEL) *.map $(OBJS) $(SDLOBJS) $(EXE) 
