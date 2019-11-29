default: img

ipl.bin : ipl.asm
	nasm ipl.asm -o ipl.bin -l ipl.lst

asm : ipl.bin

haribote.sys : haribote.asm
	nasm haribote.asm -o haribote.sys -l haribote.lst

haribote.img : ipl.bin haribote.sys
	mformat -f 1440 -C -B ipl.bin -i haribote.img ::
	mcopy haribote.sys -i haribote.img ::

img : haribote.img

run : haribote.img
	qemu-system-i386 -fda haribote.img  # "-fda" for floppy disk
