# 02-几行汇编几行C：实现一个最简单的内核

December 2, 2021 2021-12-02

![HelloOS引导图](02-%E5%87%A0%E8%A1%8C%E6%B1%87%E7%BC%96%E5%87%A0%E8%A1%8CC%EF%BC%9A%E5%AE%9E%E7%8E%B0%E4%B8%80%E4%B8%AA%E6%9C%80%E7%AE%80%E5%8D%95%E7%9A%84%E5%86%85%E6%A0%B8%20c987a1dc764845da9b287017a84bf56d/Untitled.png)

HelloOS引导图

上图为 HelloOS 引导图。

简单解释一下，PC 机 BIOS 固件是固化在 PC 机主板上的 ROM 芯片中的，掉电也能保存，PC 机上电后的第一条指令就是 BIOS 固件中的，它负责**检测和初始化 CPU、内存及主板平台**，然后加载引导设备（大概率是硬盘）中的第一个扇区数据，到 0x7c00 地址开始的内存空间，再接着跳转到 0x7c00 处执行指令，在我们这里的情况下就是 GRUB 引导程序。

### Hello OS 引导汇编代码

Q: 为什么写引导程序不能用C语言，而要使用汇编

A: **C 作为通用的高级语言，不能直接操作特定的硬件，而且 C 语言的函数调用、函数传参，都需要用栈。**

栈简单来说就是一块内存空间，其中数据满足**后进先出**的特性，它由 CPU 特定的栈寄存器指向，所以我们要先用汇编代码处理好这些 C 语言的工作环境。

### Hello OS 的编译过程

![HelloOS 编译过程图](02-%E5%87%A0%E8%A1%8C%E6%B1%87%E7%BC%96%E5%87%A0%E8%A1%8CC%EF%BC%9A%E5%AE%9E%E7%8E%B0%E4%B8%80%E4%B8%AA%E6%9C%80%E7%AE%80%E5%8D%95%E7%9A%84%E5%86%85%E6%A0%B8%20c987a1dc764845da9b287017a84bf56d/Untitled%201.png)

HelloOS 编译过程图