// This module is a verilog solution to the leetcode problem https://leetcode.com/problems/number-of-good-pairs/
// ------------------------------------------------------------------
// Given an array of integers nums, return the number of good pairs.
// A pair (i, j) is called good if nums[i] == nums[j] and i < j.
//
//
//
// Example 1:
//
// Input: nums = [1,2,3,1,1,3]
// Output: 4
// Explanation: There are 4 good pairs (0,3), (0,4), (3,4), (2,5) 0-indexed.
// Example 2:
//
// Input: nums = [1,1,1,1]
// Output: 6
// Explanation: Each pair in the array are good.
// Example 3:
//
// Input: nums = [1,2,3]
// Output: 0
//
//
// Constraints:
//  1 <= nums.length <= 100
//  1 <= nums[i] <= 100
//  A pair (i, j) is called good if nums[i] == nums[j] and i < j.

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

    assign in_tready = !rst;
    logic [2**DATA_SIZE -1: 0] set;

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
            $display("in_tdata=%8d in_tvalid=%1d in_tready=%1d pairs=%8d", in_tdata, in_tvalid, in_tready, pairs);
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
        good_write(5);
        good_write(123);
        good_write(5);
        good_write(3);
        good_write(5);
        good_write(4);
        good_write(2);
        good_write(1);
        good_write(0);
        good_write(26);
        good_write(255);
        good_write(255);
        bad_write('hDEADBEEF);
        bad_write('hDEADBEEF);

        in_tdata = 0;
        in_tvalid = 0;
        wait (!clk); wait(clk);

        if (pairs != 2) begin
            wait(!clk);
            $error("Assertion Error: 2 != %d", pairs);
            $fatal(1);
        end

        wait(!clk);
        $display("tb_lc_1512_good_pair succeeded.");
        $finish;
    end

    task good_write(input integer num);
        in_tdata = num;
        in_tvalid = 1;
        wait(!clk); wait(clk);
    endtask

    task bad_write(input integer num);
        in_tdata = num;
        in_tvalid = 0;
        wait(!clk); wait(clk);
    endtask

endmodule