# List of output programs
TARGETS = divAssembly.out

# All target
all: $(TARGETS)

#sudo apt-get -y install gcc-multilib g++-multilib

# Rules for 64bitAdd
divAssembly.out: divAssembly.o
	ld -melf_x86_64 -o divAssembly.out divAssembly.o

divAssembly.o: divAssembly.s
	as --gstabs -o divAssembly.o divAssembly.s
	
clean:
	rm -f $(TARGETS) *.o

