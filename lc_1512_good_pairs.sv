module lc_1512_good_pairs
#(
    parameter DATA_SIZE=32
)
(
    input                        clk,
    input                        rst,

    input        [DATA_SIZE-1:0] in_tdata,
    input                        in_tvalid,
    //input                        in_tlast,
    output                       in_tready,

    output logic [DATA_SIZE-1:0] pairs
);
    logic [2**DATA_SIZE -1: 0] set;

    assign in_tready = !rst;

    always @(posedge clk) begin
        if (rst) begin
            pairs <= 0;
            set <= 0;
        end else begin
            if(in_tvalid) begin
                if(set[in_tdata]) begin
                    set[in_tdata] <= 1'b0;
                    pairs <= pairs + 1;
                end else begin
                    set[in_tdata] <= 1'b1;
                end
            end
        end
    end

endmodule

///
// TEST BENCH
///

module tb_lc_1512_good_pairs();
    localparam DATA_SIZE = 8;

    logic clk;
    logic rst;

    logic [DATA_SIZE-1: 0] in_tdata;
    logic                  in_tvalid;
    wire                   in_tready;

    wire  [DATA_SIZE-1: 0] pairs;

    lc_1512_good_pairs #(
        .DATA_SIZE(DATA_SIZE)
    ) UUT (
        .clk(clk),
        .rst(rst),
        .in_tdata(in_tdata),
        .in_tvalid(in_tvalid),
        .in_tready(in_tready),
        .pairs(pairs)
    );

    always #5 clk = !clk;

    always @(posedge clk) begin
        if(!rst)
            $display("clk=%01d in_tdata=%8d in_tvalid=%1d in_tready=%1d pairs=%8d", clk, in_tdata, in_tvalid, in_tready, pairs);
    end

    initial begin
        rst = 1;
        clk = 0;
        in_tdata = 0;
        in_tvalid = 0;

        repeat (5) @(posedge clk);
        rst = 0;
        wait (in_tready);

        // sends in [5, 123, 5, 3, 5, 4, 2, 1, 0, 26, 255, 255]
        in_tdata = 5;
        in_tvalid = 1;
        wait (!clk); wait(clk);
        in_tdata = 123;
        in_tvalid = 1;
        wait (!clk); wait(clk);
        in_tdata = 5;
        in_tvalid = 1;
        wait (!clk); wait(clk);
        in_tdata = 3;
        in_tvalid = 1;
        wait (!clk); wait(clk);
        in_tdata = 5;
        in_tvalid = 1;
        wait (!clk); wait(clk);
        in_tdata = 4;
        in_tvalid =1;
        wait (!clk); wait(clk);
        in_tdata = 2;
        in_tvalid = 1;
        wait (!clk); wait(clk);
        in_tdata = 1;
        in_tvalid = 1;
        wait (!clk); wait(clk);
        in_tdata = 0;
        in_tvalid = 1;
        wait (!clk); wait(clk);
        in_tdata = 26;
        in_tvalid = 1;
        wait (!clk); wait(clk);
        in_tdata = 255;
        in_tvalid = 1;
        wait (!clk); wait(clk);
        in_tdata = 255;
        in_tvalid = 1;
        // make sure tvalid works
        wait (!clk); wait(clk);
        in_tdata = 8'hDEADBEEF;
        in_tvalid = 0;
        wait (!clk); wait(clk);
        in_tdata = 8'hDEADBEEF;
        in_tvalid = 0;
        wait (!clk); wait(clk);

        in_tdata = 0;
        in_tvalid = 0;
        wait (!clk); wait(clk);


        if (pairs != 2) begin
            wait(!clk);
            $error("Assertion Error: 2 != %d", pairs);
        end

        wait(!clk);
        $display("tb_lc_1512_good_pair succeeded.");
        $finish;
    end

endmodule