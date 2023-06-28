`include "../../rtl/defines.vh"

module agent(
   input                       clk,
   input                       resetn,

   input  [`BUS_WIDTH -1:0]    m_ram_raddr,
   output [`DATA_WIDTH-1:0]    m_ram_rdata,
   input                       m_ram_ren  ,
   input  [`BUS_WIDTH -1:0]    m_ram_waddr,
   input  [`DATA_WIDTH-1:0]    m_ram_wdata,
   input  [`DATA_WIDTH/8-1:0]  m_ram_wen,


   
   output [`BUS_WIDTH -1:0]    s_ram_raddr,
   input  [`DATA_WIDTH-1:0]    s_ram_rdata,
   output                      s_ram_ren  ,
   output [`BUS_WIDTH -1:0]    s_ram_waddr,
   output [`DATA_WIDTH-1:0]    s_ram_wdata,
   output [`DATA_WIDTH/8-1:0]  s_ram_wen,

   output                      secure_debug_disable
   );



   

   //
   // otprom, default bit value is 0, burned bit is 1
   //


   // timing signal , sticky
   // reset to 0
   //
   // resetn   : ____----
   // timing_0 : _____---
   // timing_1 : ______--
   //
   // suppose ram need 1 cycle to read
   // read ram at timing_0, store rdata to reg at timing_1
   //
   wire timing_0;
   wire timing_0_nxt;

   assign timing_0_nxt = resetn | timing_0;

   dffrl_s #(1) timing_0_reg (
      .din   (timing_0_nxt),
      .clk   (clk),
      .rst_l (resetn),
      .q     (timing_0), 
      .se(), .si(), .so());


   wire timing_1;
   wire timing_1_nxt;

   assign timing_1_nxt = timing_0 | timing_1;

   dffrl_s #(1) timing_1_reg (
      .din   (timing_1_nxt),
      .clk   (clk),
      .rst_l (resetn),
      .q     (timing_1), 
      .se(), .si(), .so());


   wire timing_2;
   wire timing_2_nxt;

   assign timing_2_nxt = timing_1 | timing_2;

   dffrl_s #(1) timing_2_reg (
      .din   (timing_2_nxt),
      .clk   (clk),
      .rst_l (resetn),
      .q     (timing_2), 
      .se(), .si(), .so());


   // 
   //
   //
   //wire [`BUS_WIDTH -1:0]    once_ram_raddr;
   //wire                      once_ram_ren  ;
   

   dp_mux2es #(`BUS_WIDTH) mux_s_ram_raddr (
	   .dout  (s_ram_raddr),
	   .in0   (`BUS_WIDTH'h10),
	   .in1   (m_ram_raddr),
	   .sel   (timing_1));

   dp_mux2es #(1) mux_s_ram_ren (
	   .dout  (s_ram_ren),
	   .in0   (1'b1),
	   .in1   (m_ram_ren),
	   .sel   (timing_1));



   // suppose otprom_secure_debug_disable bit is at addr xxx, bit 0
   wire otprom_secure_debug_disable;
   assign otprom_secure_debug_disable = s_ram_rdata[0];

   wire sec_en;
   assign sec_en = ~timing_2;

   dffrle_s #(1) secure_debug_disable_reg (
      .din   (otprom_secure_debug_disable),
      .clk   (clk),
      .rst_l (resetn),
      .en    (sec_en),
      .q     (secure_debug_disable), 
      .se(), .si(), .so());





   //assign s_ram_raddr = m_ram_raddr;
   assign m_ram_rdata = s_ram_rdata;
   //assign s_ram_ren   = m_ram_ren;
   assign s_ram_waddr = m_ram_waddr;
   assign s_ram_wdata = m_ram_wdata;
   assign s_ram_wen   = m_ram_wen;

endmodule

