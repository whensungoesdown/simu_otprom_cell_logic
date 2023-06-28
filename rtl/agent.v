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


   wire timing2n;
   wire timing2n_nxt;

   assign timing2n_nxt = timing1n | timing2n;

   dffrl_s #(1) timing2n_reg (
      .din   (timing2n_nxt),
      .clk   (clk),
      .rst_l (resetn),
      .q     (timing2n), 
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
	   .sel   (timing0n));

   dp_mux2es #(1) mux_s_ram_ren (
	   .dout  (s_ram_ren),
	   .in0   (1'b1),
	   .in1   (m_ram_ren),
	   .sel   (timing0n));



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





   //assign s_ram_raddr = m_ram_raddr;
   assign m_ram_rdata = s_ram_rdata;
   //assign s_ram_ren   = m_ram_ren;
   assign s_ram_waddr = m_ram_waddr;
   assign s_ram_wdata = m_ram_wdata;
   assign s_ram_wen   = m_ram_wen;

endmodule

