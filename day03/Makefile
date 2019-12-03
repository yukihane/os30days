default: img

ipl10.bin : ipl10.asm
	nasm ipl10.asm -o ipl10.bin -l ipl10.lst

asm : ipl10.bin

haribote.sys : asmhead.asm
	nasm asmhead.asm -o haribote.sys -l haribote.lst

haribote.img : ipl10.bin haribote.sys
	mformat -f 1440 -C -B ipl10.bin -i haribote.img ::
	mcopy haribote.sys -i haribote.img ::

img : haribote.img

run : haribote.img
	qemu-system-i386 -fda haribote.img  # "-fda" for floppy disk
