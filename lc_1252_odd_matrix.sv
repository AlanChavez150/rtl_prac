// https://leetcode.com/problems/cells-with-odd-values-in-a-matrix/description/
// 1252. Cells with Odd Values in a Matrix
// There is an m x n matrix that is initialized to all 0's. There is also a 2D array indices where each indices[i] = [ri, ci] represents a 0-indexed location to perform some increment operations on the matrix.
//
// For each location indices[i], do both of the following:
//
// Increment all the cells on row ri.
// Increment all the cells on column ci.
// Given m, n, and indices, return the number of odd-valued cells in the matrix after applying the increment to all locations in indices.
//
//
//
// Example 1:
//
//
// Input: m = 2, n = 3, indices = [[0,1],[1,1]]
// Output: 6
// Explanation: Initial matrix = [[0,0,0],[0,0,0]].
// After applying first increment it becomes [[1,2,1],[0,1,0]].
// The final matrix is [[1,3,1],[1,3,1]], which contains 6 odd numbers.
// Example 2:
//
//
// Input: m = 2, n = 2, indices = [[1,1],[0,0]]
// Output: 0
// Explanation: Final matrix = [[2,2],[2,2]]. There are no odd numbers in the final matrix.
//
//
// Constraints:
//
// 1 <= m, n <= 50
// 1 <= indices.length <= 100
// 0 <= ri < m
// 0 <= ci < n

// RUST solution
// pub fn odd_cells(m: i32, n: i32, indices: Vec<Vec<i32>>) -> i32 {
//     // make m x n matrix. row major matrix
//     let mut matrix = vec![vec![0; n as usize ]; m as usize ];
//
//     for coor in indices{
//         let row = coor[0] as usize;
//         let col = coor[1] as usize;
//
//         // go through all points and incrment if on same row or col
//         for rt in 0..m as usize{
//             for ct in 0..n as usize{
//                 if rt == row{
//                     matrix[rt][ct] += 1;
//                 }
//                 if ct == col{
//                     matrix[rt][ct] += 1;
//                 }
//             }
//         }
//     }
//
//     // iterate and find odd numbered cells
//     let mut sum = 0;
//     for row in matrix{
//         for cell in row{
//             if cell % 2 == 1{
//                 sum += 1;
//             }
//         }
//     }
//
//     return sum;
// }

module lc_1252_odd_matrix #(
    parameter MAX_IND_LEN = 100
)(
    input             clk,
    input             rst,

    input       [7:0] m,          // saved on tlast+tvalid signal
    input       [7:0] n,

    input  [1:0][7:0] ind_tdata,
    input             ind_tvalid,
    input             ind_tlast,
    output            ind_tready,

    output      [7:0] odd_cells,
    output            out_tvalid
);

    logic       ind_loaded; // low unitl all ind have been loaded
    logic [7:0] m_reg;
    logic [7:0] n_reg;
    logic [MAX_IND_LEN-1:0][1:0][7:0] indices;
    logic [$clog2(MAX_IND_LEN):0]     ind_ptr;

    // state machine to load indicies into an array
    assign ind_tready = !rst && !ind_loaded;

    integer i;
    always @(posedge clk) begin
        if(rst) begin
            ind_loaded <= 0;
            m_reg <= 0;
            n_reg <= 0;
            ind_ptr <= 0;
            indices <= 0;
        end else begin
            if(ind_tvalid) begin
                indices[ind_ptr] <= ind_tdata;
                ind_ptr <= ind_ptr + 1;
                if(ind_tlast) begin
                    ind_loaded <= 1;
                    m_reg <= m;
                    n_reg <= n;
                end
            end
        end
    end

endmodule


module tb_lc_1252_odd_matrix();

    logic            clk;
    logic            rst;

    logic      [7:0] m;          // saved on tlast+tvalid signal
    logic      [7:0] n;

    logic [1:0][7:0] ind_tdata;
    logic            ind_tvalid;
    logic            ind_tlast;
    wire             ind_tready;

    wire       [7:0] odd_cells;
    wire             out_tvalid;

    lc_1252_odd_matrix UUT(
        .clk       ( clk        ),
        .rst       ( rst        ),

        .m         ( m          ), // saved on tlast+tvalid signal
        .n         ( n          ),

        .ind_tdata ( ind_tdata  ),
        .ind_tvalid( ind_tvalid ),
        .ind_tlast ( ind_tlast  ),
        .ind_tready( ind_tready ),

        .odd_cells ( odd_cells  ),
        .out_tvalid( out_tvalid )
    );

    always #5 clk = !clk;
    initial begin
        $dumpfile("tb_results/lc_1252_odd_matrix.vcd");
        $dumpvars(0, tb_lc_1252_odd_matrix);

        rst = 1;
        clk = 0;
        m = 0;
        n = 0;
        ind_tdata = 0;
        ind_tvalid = 0;
        ind_tlast = 0;
        repeat (5) @(posedge clk);
        rst = 0;
        wait (ind_tready);
        $display("Sending in data. 2x3 [[0,1],[1,1]]");
        m = 2;
        n = 3;
        send_coor(0, 1, 0);
        send_coor(1, 1, 1);
        ind_tvalid = 0;
        repeat(1) @(posedge clk);

        if(!UUT.ind_loaded || UUT.m_reg != m || UUT.n_reg != n) begin
            $error("Assertion error");
            $fatal(1);
        end
        print_ind(0);

        repeat (1) @(posedge clk);
        $finish;
    end

    // TASKS
    task print_ind(input dummy);
        $display("(%1d, %1d)",UUT.indices[0][0], UUT.indices[0][1]);
        $display("(%1d, %1d)",UUT.indices[1][0], UUT.indices[1][1]);
    endtask


    task send_coor(
        input [7:0] row,
        input [7:0] col,
        input       last
    );
        ind_tdata[0] = row;
        ind_tdata[1] = col;
        ind_tvalid   = 1;
        ind_tlast    = last;
        repeat (1) @(posedge clk);
    endtask

endmodule