# markOS
## Current Version beta 0.3.2
- [学习笔记更新](https://github.com/Liu-Jing-Jing/markOS/wiki)

## ReleaseNote
- Version: beta 0.0.8 将磁盘的启动扇区和C0-H0-S2读入内存中
- Version: beta 0.0.9 将磁盘的启动扇区和C0-H0-S2到S17.算上boot sector共18个扇区读入内存中
- Version: beta 0.1.0 将磁盘的启动扇区和C0-H0-S2到第10个柱面的C9-H1-S17读入内存中,共10个柱面.内存占用180KB

#当前进度:
#day 05 last GDT and IDT initialize

BootStrap
vim 的转义使用反斜杠 将"/"替换为"\"  :1,$/\//\\/g
http://blog.csdn.net/thimin/article/details/2313390
加载到了 0c7c00
vim :%s/;.*//g
vim :%s/^/\t/g
MOV	AX,0
MOV	ES,AX
MOV	AX,msg
MOV	BP,AX	; ES:BP = 串地址
MOV	CX,14	; 串长度
MOV	AX,0x1301	;AH = 0x13，AL = 0x01
MOV	BX,0x000c	; 页号BH = 0 黑底红字 BL = 0x0c
MOV	DL,0
INT	0x10

Asmhead.nas 隐藏的细节 VGA 显示模式 实模式保护模式

官方的内存地址分布
0x00000000  -   0x000fffff 启动的时候多次使用, 之后变为空(1MB)
0x00100000  -   0x00267fff 保存软盘内容(1440KB)
0x7c00 512 bit IPL
0x00270000  ~   000x27ffff GDT(64KB)
0x0026f800  ~   0x0026ffff IDT(2KB)    
0x00280000  ~   0x002fffff bootpack.hrb(512KB)
0x00300000  -   0x003FFFFF 栈及其他
0x003c0000  ~   32KB       memman
0x00400000      EMPTY
```
[代码块](https://github.com/Liu-Jing-Jing/markOS/blob/master/helloOS.asm)
entry:

MOV		AX,0			; 初始化寄存器

MOV		SS,AX

MOV		SP,0x7c00

MOV		DS,AX

MOV		ES,AX


```
