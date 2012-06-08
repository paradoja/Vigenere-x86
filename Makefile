all:

%.asm:
	nasm -f elf $<

%.o: %.asm
	ld -s -o cp -melf_i386 $<
