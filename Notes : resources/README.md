# resources
This file contains the main sources I used while developing this operating system. That being said, this is around 40% of the total resources I used. If you intend on making an operating system, you will have much more sources than the ones listed below. This resource page is supposed to be a starting point.

# prerequisite knowledge
Below is a list of prerequisite knowledge needed before building a 32-bit x86 operating system

- [https://www.youtube.com/watch?v=LnzuMJLZRdU&list=PLowKtXNTBypFbtuVMUVXNR0z1mu7dp7eH] - this link leads to a playlist created by ben eater. In this series, Ben Eater creates a 6502 computer system. The reason I recommend this is because it gives a great base understanndding of how the cpu interacts with the rest of the components (ram, rom, io, etc..).
- [https://8bitworkshop.com/v3.8.0/?platform=vcs&file=examples%2Fhello.a] - This link leads to an online IDE that allows you to code in 6502 assembly for an atari, and many other old computer systems. This is a great source for learning how to code in assembly.
- [https://skilldrick.github.io/easy6502/] - this link helped me understand 6502 assembly. it goes through all the basics of 6502 assembly. highly recommend for learning 6502 assembly.
- [https://www.youtube.com/watch?v=ojHSzW3zVNU&list=PLZlHzKk21aImqCiV71iE2I1dUE5LNejQk] - This link isn't necessary, but it gives a great understanding of how cpu's work internally. 
- [https://www.cs.virginia.edu/~evans/cs216/guides/x86.html] - great source for learning x86 assembly
- Lastly, learning C is necessary to program an operating system. I suggest watching some youtube tutorials on C.
# Legacy Bootloader
#### high level concepts:
- [https://manybutfinite.com/post/how-computers-boot-up/] - great source for understanding what happens when a computer boots up.
- [https://wiki.osdev.org/Rolling_Your_Own_Bootloader] - This explains what a boot loader actually does.
#### The technical details:
- [http://www.brokenthorn.com/Resources/OSDev3.html] - great source for creating a bootloader that parses a FAT 12 file system. there might be some strange opcodes in this tutorial, so I recommend just looking up any opcode that's confusing. 
#### other sources I used:
- [https://wiki.osdev.org/A20_Line] - great source for understanding how to enable the A20 line.
- [https://wiki.osdev.org/ATA_in_x86_RealMode_(BIOS)] - helped me understand the conversion from CHS to LBA.
- [https://www.eit.lth.se/fileadmin/eit/courses/eitn50/Literature/fat12_description.pdf] - great for  understanding the FAT-12 file system.
- The links below helped me understand how addressing works in Pmode
    - https://www.felixcloutier.com/x86/lgdt:lidt
    - http://ece-research.unm.edu/jimp/310/slides/micro_arch2.html
    - http://ringzero.free.fr/os/protected%20mode/Pm/PM1.ASM 
    - https://en.wikibooks.org/wiki/X86_Assembly/Global_Descriptor_Table
    - http://www.c-jump.com/CIS77/ASM/Protection/lecture.html

# Kernel
#### getting the enviroment set up:
- [https://www.ryanstan.com/assmToC.html] - helped me understand how to switch from assembly to c
- [https://docs.oracle.com/cd/E19683-01/817-3677/chapter6-46512/index.html] good source for understanding the ELF standard
#### technical guides:
- [http://www.jamesmolloy.co.uk/tutorial_html/] - great source for getting the kernel set up (lib, interrupts, and IRQs). There are a few problems with this tutorial (especially when it comes to paging, the heap, multitasking, and switching to usermode), so I suggest looking at how other people set up the kernel.
- [https://wiki.osdev.org/James_Molloy%27s_Tutorial_Known_Bugs] - this explains what the jamesmolloy tutorial does wrong. I highly suggest you read it if you use jamesmolloys tutorial.
- [https://littleosbook.github.io/] - this is a really good source for the technical details behind a 32 bit x86 kernel. This also has a bunch of other links to reference.
- [http://www.osdever.net/bkerndev/index.php] - great source for the technical details behind a 32 bit x86 kernel.
#### operating systems to reverse engineer:
- https://github.com/cfenollosa/os-tutorial
- https://github.com/michael2012z/Sparrow
- https://github.com/RyanStan/ConiferOS/tree/master/src
- https://github.com/scopeInfinity/FuzzyOS
- http://www.sebastianmihai.com/snowdrop/src/

# Other useful websites
- [https://defuse.ca/online-x86-assembler.htm#disassembly] - useful when debugging bins
- [https://godbolt.org/] - helpful when understanding how C compiles to asm.
- [https://www.rapidtables.com/convert/number/ascii-to-hex.html] - helped me debug things in the root region of the FAT-12 formatted disk.
- [https://www.calculator.net/hex-calculator.html?number1=3000&c2op=%2B&number2=512&calctype=op&x=95&y=22] - helped me calculate adress offsets
- [https://titanwolf.org/Network/Articles/Article?AID=7bdc4d62-bc1e-49cc-8ca6-4657238b013c#gsc.tab=0] - useful when debugging the OS at runtime.
- [https://wiki.osdev.org/Main_Page] - good gateway to many other useful sources
- [https://nithinbekal.com/notes/os/] - another good gateway to useful sources
- [https://wiki.osdev.org/Creating_an_Operating_System] - greate source as a guide on the steps required to build an operating system
