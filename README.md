# SPI_Master_24bit_Verilog
SPI master verilog
Xin chào cộng đồng Việt Nam, những người đam mê trong lĩnh vực thiết kế chip, hôm nay tôi giới thiệu với mọi người phần giao thức SPI 24 bit Master mà tôi vừa hoàn thành, tôi muốn chia sẻ với mọi người tham khảo:
1. Clock
   - Sử dụng clk :10mhz
3. Timing Diagram
   - ADDR: 8'hAA; DATA: 16'hAAAA 
   <img width="1271" height="333" alt="image" src="https://github.com/user-attachments/assets/1799a536-dd99-4dc4-a099-d2ab5a0f2537" />
  - ADDR: 8'h01; DATA: 16'h0001
    <img width="1714" height="346" alt="image" src="https://github.com/user-attachments/assets/d9bb0fc8-16c8-40ce-9bf8-01eb0effc5c1" />
4. Mode:=
    - CPOL=1 CPHA = 1
