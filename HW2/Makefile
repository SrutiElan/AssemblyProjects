# List of output programs
TARGETS = 64bitAdd.out

# All target
all: $(TARGETS)

#sudo apt-get -y install gcc-multilib g++-multilib

# Rules for 64bitAdd
64bitAdd.out: 64bitAdd.o
	ld -melf_x86_64 -o 64bitAdd.out 64bitAdd.o

64bitAdd.o: 64bitAdd.s
	as --gstabs -o 64bitAdd.o 64bitAdd.s
	
clean:
	rm -f $(TARGETS) *.o

