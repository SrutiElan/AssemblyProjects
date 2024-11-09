# List of output programs
TARGETS = editDist.out

# All target
all: $(TARGETS)

#sudo apt-get -y install gcc-multilib g++-multilib

# Rules for 64bitAdd
editDist.out: editDist.o
	ld -melf_x86_64 -o editDist.out editDist.o

editDist.o: editDist.s
	as --gstabs -o editDist.o editDist.s
	
clean:
	rm -f $(TARGETS) *.o

