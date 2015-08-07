$(src): $(src).asm
ifeq ($(mode), ld)
	nasm -f elf $(src).asm
	ld -m elf_i386 -o $(src) $(src).o
else
	nasm -f elf -l $(src).lst $(src).asm
	gcc -m32 -o $(src) $(src).o
endif

clean:
	rm -f *.lst
	rm -f *.o
