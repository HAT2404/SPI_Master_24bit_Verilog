`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2025 09:32:46 PM
// Design Name: 
// Module Name: simulator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module simulator();
    reg clk; 
    reg resetn;
    reg start; 
    reg [7:0]addr; 
    reg [15:0]data_in; 
    wire [23:0]data_out; 
    wire busy; 
    wire done; 
    wire SCLK;
    wire CS; 
    wire MOSI;    
    reg MISO;
    wire SCLN; 
    
    Master_SPI_INTF #(
    .edge_detection_transfer(1),
    .edge_detection_receive(1))
    test(
    .clk(clk),
    .resetn(resetn),
    .start(start),
    .addr(addr),
    .data_in(data_in),
    .data_out(data_out),
    .done(done),
    .SCLK(SCLK),
    .CS(CS),
    .MOSI(MOSI),
    .MISO(MISO),
    .SCLN(SCLN)
    );
    
    always #1 clk = ~clk; 
    initial  
    begin 
    clk =1; resetn =1;
    #20 resetn =0;
    #20 resetn =1; start =1; addr = 8'hAA; data_in = 16'hAAAA; MISO =1'b1;
    #1 start =0;
    #301 start =1; addr = 8'h01; data_in = 16'h0001; MISO = 1'b0;
    #1 start = 0; MISO = 1'b1;
    
    #1000;
    $finish;
    end
endmodule
