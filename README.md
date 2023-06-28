# simu_otprom_cell_logic
Right after reset, agent reads out otprom word and stored in register, then use it as signals. The otprom is simulated with a sram

现在的问题是，想让otprom里的一个bit直接控制某些逻辑，比如控制某个模块的clock gate。otprom不能从里面直接引出这个bit，而是需要通过接口先读出来，这样就需要跑固件代码。

目标是用硬件逻辑读出这个bit，不需要通过固件。

在这个例子里，要用otprom地址0x10里的bit0，起个名字叫secure_debug_disable来控制coresight的clock gate，和jtag的pad。（具体怎么disable还没试过）

没有otprom，据说是个硬ip，所以就用sram模拟。

现实中，sram的ip很复杂，也并不是所有的内容都在一个sram的实例里。所以对sram这样做也有意义。


## 思路
做个agent模块，处理sram接口。

用resetn信号建立几个信号，每个延后1个cycle，例如timing0n,timing1n

sram的read latency是1 cycle (根据实际的read latency确定)。

在timing0n之前，mux sram的raddr和ren到指定的位置，比如0x10，在timing0n（reset后的第一个上升沿）读sram数据。
读出的数据在timing1n（reset后的第二个cycle上升沿）写入寄存器，此后用作控制信号。


![screenshot0](https://github.com/whensungoesdown/whensungoesdown.github.io/raw/main/_posts/2023-06-28-0.png)
