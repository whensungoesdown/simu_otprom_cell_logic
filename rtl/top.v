`include "../../rtl/defines.vh"

module top(
   input  clk,
   input  resetn
   );

   
   
   //ram
   wire [`BUS_WIDTH -1:0]    m_ram_raddr;
   wire [`DATA_WIDTH-1:0]    m_ram_rdata;
   wire                      m_ram_ren  ;
   wire [`BUS_WIDTH -1:0]    m_ram_waddr;
   wire [`DATA_WIDTH-1:0]    m_ram_wdata;
   wire [`DATA_WIDTH/8-1:0]  m_ram_wen;


   
   wire [`BUS_WIDTH -1:0]    s_ram_raddr;
   wire [`DATA_WIDTH-1:0]    s_ram_rdata;
   wire                      s_ram_ren  ;
   wire [`BUS_WIDTH -1:0]    s_ram_waddr;
   wire [`DATA_WIDTH-1:0]    s_ram_wdata;
   wire [`DATA_WIDTH/8-1:0]  s_ram_wen;

   wire                      secure_debug_enable;

   

   agent u_agent(
      .clk                  (clk                ),
      .resetn               (resetn             ),

      .m_ram_raddr          (m_ram_raddr        ),
      .m_ram_rdata          (m_ram_rdata        ),
      .m_ram_ren            (m_ram_ren          ),
      .m_ram_waddr          (m_ram_waddr        ),
      .m_ram_wdata          (m_ram_wdata        ),
      .m_ram_wen            (m_ram_wen          ),

      .s_ram_raddr          (s_ram_raddr        ),
      .s_ram_rdata          (s_ram_rdata        ),
      .s_ram_ren            (s_ram_ren          ),
      .s_ram_waddr          (s_ram_waddr        ),
      .s_ram_wdata          (s_ram_wdata        ),
      .s_ram_wen            (s_ram_wen          ),

      .secure_debug_enable  (secure_debug_enable)
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

   
endmodule // top
