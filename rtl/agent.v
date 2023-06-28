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

   output                      secure_debug_enable
   );


   assign s_ram_raddr = m_ram_raddr;
   assign m_ram_rdata = s_ram_rdata;
   assign s_ram_ren   = m_ram_ren;
   assign s_ram_waddr = m_ram_waddr;
   assign s_ram_wdata = m_ram_wdata;
   assign s_ram_wen   = m_ram_wen;

   
endmodule

