VFLAGS = -O3 --x-assign fast --x-initial fast --noassert -DSIM -DVERILATOR_SIM
SDL_CFLAGS = `sdl2-config --cflags`
SDL_LDFLAGS = `sdl2-config --libs`

project.mk: ../src/project.v
	verilator ${VFLAGS} -I../src \
		-cc $< --exe main_$(basename $@).cpp -o $(basename $@) \
		-CFLAGS "${SDL_CFLAGS}" -LDFLAGS "${SDL_LDFLAGS}"

project: project.mk
	make -C ./obj_dir -f V$<

all: project

clean:
	rm -rf ./obj_dir

.PHONY: all clean