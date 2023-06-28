# simu_otprom_cell_logic

Right after reset, agent reads out otprom word and stored in register, then use it as signals. The otprom is simulated with a sram

## The Problem and the Goal


现在的问题是，想让otprom里的一个bit直接控制某些逻辑，比如控制某个模块的clock gate。otprom不能从里面直接引出这个bit，而是需要通过接口先读出来，这样就需要跑固件代码。

目标是用硬件逻辑读出这个bit，不需要通过固件。

在这个例子里，要用otprom地址0x10里的bit0，起个名字叫secure_debug_disable来控制coresight的clock gate，和jtag的pad。（具体怎么disable还没试过）

没有otprom，据说是个硬ip，所以就用sram模拟。

现实中，sram的ip很复杂，也并不是所有的内容都在一个sram的实例里。所以对sram这样做也有意义。


## Solution

做个agent模块，处理sram接口。

`````verilog
   agent u_agent(
      .clk                  (clk                 ),
      .resetn               (resetn              ),

      .m_ram_raddr          (m_ram_raddr         ),
      .m_ram_rdata          (m_ram_rdata         ),
      .m_ram_ren            (m_ram_ren           ),
      .m_ram_waddr          (m_ram_waddr         ),
      .m_ram_wdata          (m_ram_wdata         ),
      .m_ram_wen            (m_ram_wen           ),

      .s_ram_raddr          (s_ram_raddr         ),
      .s_ram_rdata          (s_ram_rdata         ),
      .s_ram_ren            (s_ram_ren           ),
      .s_ram_waddr          (s_ram_waddr         ),
      .s_ram_wdata          (s_ram_wdata         ),
      .s_ram_wen            (s_ram_wen           ),

      .secure_debug_disable (secure_debug_disable)
   );

   
   sram ram(
      .clock        (clk               ),
      .rdaddress    (s_ram_raddr[14:2] ),
      .q            (s_ram_rdata       ),
      .rden         (s_ram_ren         ),
      .wraddress    (s_ram_waddr[14:2] ),
      .data         (s_ram_wdata       ),
      .wren         (|s_ram_wen        )
      );
`````


In the agent module, 用resetn信号建立几个信号，每个延后1个cycle，例如timing0n,timing1n


`````verilog
agent.v

   // timing signal , sticky
   // reset to 0
   //
   // resetn   : ____----
   // timing0n : _____---
   // timing1n : ______--
   //
   // suppose ram need 1 cycle to read
   // read ram at timing0n, store rdata to reg at timing1n
   //
   wire timing0n;
   wire timing0n_nxt;

   assign timing0n_nxt = resetn | timing0n;

   dffrl_s #(1) timing0n_reg (
      .din   (timing0n_nxt),
      .clk   (clk),
      .rst_l (resetn),
      .q     (timing0n), 
      .se(), .si(), .so());


   wire timing1n;
   wire timing1n_nxt;

   assign timing1n_nxt = timing0n | timing1n;

   dffrl_s #(1) timing1n_reg (
      .din   (timing1n_nxt),
      .clk   (clk),
      .rst_l (resetn),
      .q     (timing1n), 
      .se(), .si(), .so());
`````


sram的read latency是1 cycle (根据实际的read latency确定)。

在timing0n之前，mux sram的raddr和ren到指定的位置，比如0x10，在timing0n（reset后的第一个上升沿）读sram数据。

`````verilog
   dp_mux2es #(`BUS_WIDTH) mux_s_ram_raddr (
	   .dout  (s_ram_raddr),
	   .in0   (`BUS_WIDTH'h10),
	   .in1   (m_ram_raddr),
	   .sel   (timing0n));

   dp_mux2es #(1) mux_s_ram_ren (
	   .dout  (s_ram_ren),
	   .in0   (1'b1),
	   .in1   (m_ram_ren),
	   .sel   (timing0n));
`````

读出的数据在timing1n（reset后的第二个cycle上升沿）写入寄存器，此后用作控制信号。

`````verilog
   // suppose otprom_secure_debug_disable bit is at addr xxx, bit 0
   wire otprom_secure_debug_disable;
   assign otprom_secure_debug_disable = s_ram_rdata[0];

   wire sec_en;
   assign sec_en = ~timing1n;

   dffrle_s #(1) secure_debug_disable_reg (
      .din   (otprom_secure_debug_disable),
      .clk   (clk),
      .rst_l (resetn),
      .en    (sec_en),
      .q     (secure_debug_disable), 
      .se(), .si(), .so());
`````

![screenshot0](https://github.com/whensungoesdown/whensungoesdown.github.io/raw/main/_posts/2023-06-28-0.png)


## Issues

During the first cycle after reset, the ram_raddr will be muxed to a specific adddress, in this demo, 0x10. So, if a legit ram request is sent at the very first cycle, the reading result, ram_rdata, will be wrong.

It is because sram interface do not have a hand shake mechanism. The reading result always be available at the next cycle.

If the logic is made with a axi-interface sram, then it could delay arready or rvalid for one or two cycles, so that the legit read request will be served correctly.

But that's only a demo. I remembered some where I saw that the very first transaction of some protocol will take longer than usual. I do not if it has something going on similar to this.
