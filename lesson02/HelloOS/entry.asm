;彭东 @ 2021.01.09
;thehackercat with note @ 2021.12.02
; 1. 代码 1~40 行，用汇编定义的 GRUB 的多引导协议头，其实就是一定格式的数据，我们的 Hello OS 是用 GRUB 引导的，当然要遵循 GRUB 的多引导协议标准，让 GRUB 能识别我们的 Hello OS。之所以有两个引导头，是为了兼容 GRUB1 和 GRUB2。
; 2. 代码 44~52 行，关掉中断，设定 CPU 的工作模式。你现在可能不懂，没事儿，后面 CPU 相关的课程我们会专门再研究它。
; 3. 代码 54~73 行，初始化 CPU 的寄存器和 C 语言的运行环境。
; 4. 代码 78~87 行，GDT_START 开始的，是 CPU 工作模式所需要的数据，同样，后面讲 CPU 时会专门介绍。

MBT_HDR_FLAGS	EQU 0x00010003
MBT_HDR_MAGIC	EQU 0x1BADB002 ;多引导协议头魔数
MBT_HDR2_MAGIC	EQU 0xe85250d6 ;第二版多引导协议头魔数
global _start ;导出_start符号
extern main ;导入外部的main函数符号

[section .start.text] ;定义.start.text代码节
[bits 32] ;汇编成32位代码
_start:
	jmp _entry
ALIGN 8
mbt_hdr:
	dd MBT_HDR_MAGIC
	dd MBT_HDR_FLAGS
	dd -(MBT_HDR_MAGIC+MBT_HDR_FLAGS)
	dd mbt_hdr
	dd _start
	dd 0
	dd 0
	dd _entry

;以上是GRUB所需要的头
ALIGN 8
mbt2_hdr:
	DD	MBT_HDR2_MAGIC
	DD	0
	DD	mbt2_hdr_end - mbt2_hdr
	DD	-(MBT_HDR2_MAGIC + 0 + (mbt2_hdr_end - mbt2_hdr))
	DW	2, 0
	DD	24
	DD	mbt2_hdr
	DD	_start
	DD	0
	DD	0
	DW	3, 0
	DD	12
	DD	_entry
	DD      0
	DW	0, 0
	DD	8
mbt2_hdr_end:
;以上是GRUB2所需要的头
;包含两个头是为了同时兼容GRUB、GRUB2

ALIGN 8

_entry:
	;关中断
	cli
	;关不可屏蔽中断
	in al, 0x70
	or al, 0x80
	out 0x70,al
	;重新加载GDT
	lgdt [GDT_PTR]
	jmp dword 0x8 :_32bits_mode

_32bits_mode:
	;下面初始化C语言可能会用到的寄存器
	mov ax, 0x10
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor edi,edi
	xor esi,esi
	xor ebp,ebp
	xor esp,esp
	;初始化栈，C语言需要栈才能工作
	mov esp,0x9000
	;调用C语言函数main
	call main
	;让CPU停止执行指令
halt_step:
	halt
	jmp halt_step


GDT_START:
knull_dsc: dq 0
kcode_dsc: dq 0x00cf9e000000ffff
kdata_dsc: dq 0x00cf92000000ffff
k16cd_dsc: dq 0x00009e000000ffff
k16da_dsc: dq 0x000092000000ffff
GDT_END:

GDT_PTR:
GDTLEN	dw GDT_END-GDT_START-1
GDTBASE	dd GDT_START
