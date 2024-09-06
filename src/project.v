/*
 * Copyright (c) 2024 Wei Zhang
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none


module tt_um_Electom_cla_4bits(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    wire [3 : 0]  a;
    wire [3 : 0]  b;
    wire          ci;
    reg  [3 : 0]  s;
    reg           co;

    wire [3 : 0] g;
    wire [3 : 0] p;
    wire [2 : 0] c;
    wire [3 : 0] s_w;
    wire         co_w;
    
    //design input mapping
    assign a = ui_in[3:0];
    assign b = ui_in[7:4];
    assign ci = uio_in[0];


    assign g = a & b;
    assign p = a | b;
  
    assign c[0] = g[0] | (p[0] & ci);
    assign c[1] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & ci);
    assign c[2] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & ci);
    assign co_w = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & ci);
  
    assign s_w = (p & ~g) ^ {c[2 : 0], ci};

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            s <= 0;
            co <= 0;
        end
        else begin
            s <= s_w;
            co <= co_w;
        end
    end

    //design output mapping
    assign uo_out[3:0] = s;
    assign uo_out[4] = co;

    // All output pins must be assigned. If not used, assign to 0.
    assign uo_out[7:5]  = 0;  // Example: ou_out is the sum of ui_in and uio_in
    assign uio_out = 0;
    assign uio_oe  = 0;

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, uio_in[7:1], 1'b0};

endmodule
