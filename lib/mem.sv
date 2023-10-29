// Simple memory model with two ports for access based on bram
module mem #(
    parameter DATA_WIDTH=8,
    parameter ADDR_WIDTH=8
)
(
    input                         clk,
    input                         rst,

    input        [DATA_WIDTH-1:0] in_data_a,
    input        [ADDR_WIDTH-1:0] in_addr_a,
    input                         en_a,
    input                         we_a,
    output logic [DATA_WIDTH-1:0] out_data_a,

    input        [DATA_WIDTH-1:0] in_data_b,
    input        [ADDR_WIDTH-1:0] in_addr_b,
    input                         en_b,
    input                         we_b,
    output logic [DATA_WIDTH-1:0] out_data_b
);

logic [2**ADDR_WIDTH-1:0][DATA_WIDTH-1:0] memory;
always @(posedge clk) begin
    if(rst) begin
        out_data_a <= 0;
        out_data_b <= 0;
        memory <= 0;
    end else begin
        // port a
        if(en_a && !we_a) begin
            out_data_a <= memory[in_addr_a];
        end
        else if(en_a && we_a) begin
            memory[in_addr_a] <= in_data_a;
        end

        // port b
        if(en_b && !we_b) begin
            out_data_b <= memory[in_addr_b];
        end
        else if (en_b && we_b) begin
            memory[in_addr_b] <= in_data_b;
        end
    end
end

endmodule

module tb_mem();
    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 8;

    logic                  clk;
    logic                  rst;

    logic [DATA_WIDTH-1:0] in_data_a;
    logic [ADDR_WIDTH-1:0] in_addr_a;
    logic                  en_a;
    logic                  we_a;
    wire  [DATA_WIDTH-1:0] out_data_a;

    logic [DATA_WIDTH-1:0] in_data_b;
    logic [ADDR_WIDTH-1:0] in_addr_b;
    logic                  en_b;
    logic                  we_b;
    wire  [DATA_WIDTH-1:0] out_data_b;

    mem #(
        .DATA_WIDTH( DATA_WIDTH ),
        .ADDR_WIDTH( ADDR_WIDTH )
    ) UUT (
        .clk       ( clk       ),
        .rst       ( rst       ),
        .in_data_a ( in_data_a ),
        .in_addr_a ( in_addr_a ),
        .en_a      ( en_a      ),
        .we_a      ( we_a      ),
        .out_data_a( out_data_a),
        .in_data_b ( in_data_b ),
        .in_addr_b ( in_addr_b ),
        .en_b      ( en_b      ),
        .we_b      ( we_b      ),
        .out_data_b( out_data_b)
    );

    always #5 clk = !clk;

    initial begin
        $dumpfile("tb_results/lib/mem.vcd");
        $dumpvars(0, tb_mem);

        rst = 1;
        clk = 0;
        in_data_a = 0;
        in_addr_a = 0;
        en_a = 0;
        we_a = 0;
        in_data_b = 0;
        in_addr_b = 0;
        en_b = 0;
        we_b = 0;
        repeat (5) @(negedge clk);
        rst = 0;
        repeat (1) @(negedge clk);

        // write/read a block
        for(int i=0; i < 255; i++) begin
            in_addr_a = i;
            in_data_a = i;
            en_a = 1;
            we_a = 1;
            repeat (1) @(negedge clk);
            in_data_a = 0;
            we_a = 0; // read back
            repeat (1) @(negedge clk);
            en_a = 0;
            $display("Read 0x%h from 0x%h", out_data_a, in_addr_a);
            if(out_data_a != in_addr_a) begin
                $error("0x%h != 0x%h", out_data_a, in_addr_a);
                //$fatal(1);
            end
        end

        $finish;

    end


endmodule