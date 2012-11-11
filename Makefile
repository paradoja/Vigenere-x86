EXECUTABLE=cp

all: vigenere clean

%.o: %.nasm
	nasm -f elf -o $@ $<

vigenere: vigenere.o
	ld -s -o $(EXECUTABLE) -melf_i386 $<

clean:
	rm -f *~ *.o

clean-all: clean
	rm $(EXECUTABLE)
