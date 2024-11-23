
OPTIONS := -g -m32 -Wall -Werror -fno-pie -no-pie

all: combs.out combs_c.out 

combs.out: combs.o main.o
	gcc $(OPTIONS) -o combs.out combs.o main.o

combs_c.out: combs_c.o main.o 
	gcc $(OPTIONS) -o combs_c.out combs_c.o main.o
	
combs_c.o: combs.c combs.h 
	gcc $(OPTIONS) -g -Wall -m32 -c -o combs_c.o combs.c

main.o: main.c combs.h
	gcc $(OPTIONS) -g -Wall -m32 -c -o main.o main.c
	
combs.o: combs.s
	gcc $(OPTIONS) -g -Wall -m32 -c -o combs.o combs.s
	
clean:
	rm *.o *.out
