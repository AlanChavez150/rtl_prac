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

`include "lib/mem.sv"

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
            if(ind_tvalid && ind_tready) begin
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

    // Memory space used for a matrix\
    wire  [7:0] mat_in_data_a,  mat_in_data_b;
    logic [7:0] mat_addr_a,     mat_addr_b;
    logic       mat_en_a,       mat_en_b;
    logic       mat_we_a,       mat_we_b;

    wire  [7:0] mat_out_data_a, mat_out_data_b;

    mem #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(8)
    ) matrix_mem (
        .clk       ( clk            ),
        .rst       ( rst            ),
        .in_data_a ( mat_in_data_a  ),
        .in_addr_a ( mat_addr_a     ),
        .en_a      ( mat_en_a       ),
        .we_a      ( mat_we_a       ),
        .out_data_a( mat_out_data_a ),
        // ignore b port
        .in_data_b ( mat_in_data_b  ),
        .in_addr_b ( mat_addr_b     ),
        .en_b      ( mat_en_b       ),
        .we_b      ( mat_we_b       ),
        .out_data_b( mat_out_data_b )
    );

    // state machines for actual calculation
    // There are 2 state machines
    //  1. iterates through indicies and incremnets row and col values
    //  2. goes matrix and counts odd cells

    //
    // First state machine. increments cells as needed.
    //

    enum logic [3:0]{
        INC_IDLE    = 0, // does nothing until ind_loaded signal goes high
        INC_ROW_INC = 1, // read memory and increment if the curr row is selected
        INC_COL_INC = 2, // read memory and increment if the curr col is selected
        INC_DONE    = 3
    } inc_state;

    wire [ 7:0] curr_index = ind_ptr-1;
    wire [15:0] curr_ind   = indices[curr_index];

    logic [7:0] row_cnt;
    logic [7:0] col_cnt;
    logic [7:0] state_cnt;

    wire   last_row      = row_cnt == m_reg-1;
    wire   last_col      = col_cnt == n_reg-1;
    wire   last_cell     = last_row && last_col;
    wire   read_rdy      = state_cnt >= 2;
    assign mat_we_a      = (inc_state != INC_DONE) ? read_rdy: 0;
    assign mat_in_data_a = (inc_state == INC_ROW_INC || inc_state == INC_COL_INC) ?
                         (read_rdy) ? mat_out_data_a+1: 0
                           :0;

    always @(posedge clk) begin
        if(rst) begin
            inc_state <= INC_IDLE;
            row_cnt <= 0;
            col_cnt <= 0;
            mat_addr_a <= 0; // used in this block so its reset in this block
            mat_en_a <= 0;
            state_cnt <= 0;
        end else begin
            case (inc_state)
            INC_IDLE: begin
                if(ind_loaded) inc_state <= INC_ROW_INC;
            end
            INC_ROW_INC: begin
                if(curr_ind[7:0] == row_cnt) begin
                    // read mem, increment, and write back
                    // state machine should spend three cycles in the if statement
                    // 1. read request
                    // 2. read data, write back incremented, move on
                    mat_addr_a <= addr_calc(row_cnt, col_cnt);
                    mat_en_a <= 1;
                    if(read_rdy) begin
                        state_cnt <= 0;
                        inc_state <= INC_COL_INC;
                    end else begin
                        state_cnt <= state_cnt + 1;
                    end
                end else begin
                    // move to next state
                    state_cnt <= 0;
                    inc_state <= INC_COL_INC;
                end
            end
            INC_COL_INC:
                if(curr_ind[15:8] == col_cnt) begin
                    // read mem, increment, and write back
                    // state machine should spend three cycles in the if statement
                    // 1. read request
                    // 2. read data, write back incremented, move on
                    mat_addr_a <= addr_calc(row_cnt, col_cnt);
                    mat_en_a <= 1;
                    if(read_rdy) begin
                        inc_col_next_state(last_row, last_col, last_cell);
                    end else begin
                        state_cnt <= state_cnt + 1;
                    end
                end else begin
                    // move to next state
                    inc_col_next_state(last_row, last_col, last_cell);
                end
            INC_DONE: begin
            end
            endcase
        end
    end

    task inc_col_next_state(input last_row, input input_col, input last_cell);
        state_cnt <= 0;
        if(last_cell && ind_ptr == 0) begin
            row_cnt <= 0;
            col_cnt <= 0;
            inc_state <= INC_DONE;
        end
        else if (last_cell) begin
            row_cnt <= 0;
            col_cnt <= 0;
            ind_ptr <= ind_ptr - 1;
            inc_state <= INC_ROW_INC;
        end
        else if(last_row) begin
            row_cnt <= 0;
            col_cnt <= col_cnt + 1;
            inc_state <= INC_ROW_INC;
        end else begin
            row_cnt <= row_cnt + 1;
            inc_state <= INC_ROW_INC;
        end
    endtask

    function [7:0] addr_calc([7:0] row, [7:0] col);
        // column size * row + col
       return n_reg*row + col;
    endfunction

    //
    // second state machine. Counts how many odd cells there are
    //

    // state machine that counts how many odd cells there are.
    enum logic [3:0]{
        ODD_IDLE = 0,
        ODD_CNT  = 1,
        ODD_DONE = 2
    } odd_state;

    logic [7:0] odd_cnt;
    logic [7:0] odd_addr;
    logic [7:0] read_delay;
    wire        read_done;
    wire  [7:0] max_addr;

    assign mat_we_b  = 0; // read only
    assign max_addr  = (n_reg * m_reg) - 1;
    assign read_done = odd_addr > max_addr;
    assign mat_en_b  = (odd_state == ODD_CNT && !read_done);

    // module outputs
    assign odd_cells = odd_cnt;
    assign out_tvalid = odd_state == ODD_DONE;

    always @(posedge clk) begin
        if(rst) begin
            mat_addr_b <= 0;
            odd_state <= ODD_IDLE;
            odd_addr <= 0;
            odd_cnt <= 0;
            read_delay <= 0;
        end else begin
            case(odd_state)
            ODD_IDLE: begin
                odd_state <= (inc_state == INC_DONE) ? ODD_CNT: ODD_IDLE;
            end
            ODD_CNT: begin
                read_delay <= read_delay + 1;
                if(!read_done) begin
                    mat_addr_b <= odd_addr;
                    odd_addr <= odd_addr + 1;
                end

                if(read_delay > 1) begin
                    if(mat_out_data_b[0]) begin
                        odd_cnt <= odd_cnt + 1;
                    end
                end

                // exit case
                if(read_done && read_delay > max_addr+1) begin
                    odd_state <= ODD_DONE;
                end
            end
            ODD_DONE: begin

            end
            endcase
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

        //$monitor("state = 0x%h row 0x%h col 0x%x ind ptr 0x%h", UUT.inc_state, UUT.row_cnt, UUT.col_cnt, UUT.ind_cnt);
        wait(UUT.inc_state == 3);
        $display("Done Incrementing Matrix cells");
        wait(out_tvalid);
        $display("Done counting odd cells");
        if(odd_cells != 6) begin
            $error("Assertion error. %d != 6", odd_cells);
            $fatal(1);
        end
        $display("%d odd cells", odd_cells);
        mem_dump(0);

        // reset and insert other test case
        rst = 1;
        clk = 0;
        m = 0;
        n = 0;
        ind_tdata = 0;
        ind_tvalid = 0;
        ind_tlast = 0;
        repeat(5) @(posedge clk);
        rst = 0;
        wait(ind_tready);
        $display("Sending in data. 2x2 [[1,1],[0,0]]");
        m = 2;
        n = 2;
        send_coor(1, 1, 0);
        send_coor(0, 0, 1);
        ind_tvalid = 0;
        repeat(1) @(posedge clk);
        if(!UUT.ind_loaded || UUT.m_reg != m || UUT.n_reg != n) begin
            $error("Assertion error");
            $fatal(1);
        end
        print_ind(0);

        //$monitor("state = 0x%h row 0x%h col 0x%x ind ptr 0x%h", UUT.inc_state, UUT.row_cnt, UUT.col_cnt, UUT.ind_cnt);
        wait(UUT.inc_state == 3);
        $display("Done Incrementing Matrix cells");
        wait(out_tvalid);
        $display("Done counting odd cells");
        if(odd_cells != 0) begin
            $error("Assertion error. %d != 0", odd_cells);
            $fatal(1);
        end
        $display("%d odd cells", odd_cells);
        mem_dump(0);

        $finish;
    end

    // watch mem writes
    //always @(posedge clk) begin
    //    if(UUT.matrix_mem.we_a && UUT.matrix_mem.en_a) begin
    //        $display("Read 0x%h from 0x%h", UUT.matrix_mem.out_data_a, UUT.matrix_mem.in_addr_a);
    //        $display("Writing 0x%h to 0x%h", UUT.matrix_mem.in_data_a, UUT.matrix_mem.in_addr_a);
    //        if(UUT.inc_state == UUT.INC_ROW_INC) begin
    //            $display("ROW write");
    //        end else if(UUT.inc_state == UUT.INC_COL_INC) begin
    //            $display("COL write");
    //        end
    //        $display("Curr index 0x%h ind ptr 0x%h", UUT.curr_index, UUT.ind_ptr);
    //        $display("curr ind (0x%h, 0x%h). cnts (0x%h, 0x%h)", UUT.curr_ind[7:0], UUT.curr_ind[15:8], UUT.row_cnt, UUT.col_cnt);
    //        $display("");
    //    end
    //end

    // TASKS
    task print_ind(input dummy);
        $display("(%1d, %1d)",UUT.indices[0][0], UUT.indices[0][1]);
        $display("(%1d, %1d)",UUT.indices[1][0], UUT.indices[1][1]);
    endtask


    task mem_dump(input inst);
        for(int i=0; i < 64; i += 16) begin
            $display(
                "0x%04h: 0x%h 0x%h 0x%h 0x%h 0x%h 0x%h 0x%h 0x%h 0x%h 0x%h 0x%h 0x%h 0x%h 0x%h 0x%h 0x%h",
                i,
                UUT.matrix_mem.memory[i +  0],
                UUT.matrix_mem.memory[i +  1],
                UUT.matrix_mem.memory[i +  2],
                UUT.matrix_mem.memory[i +  3],
                UUT.matrix_mem.memory[i +  4],
                UUT.matrix_mem.memory[i +  5],
                UUT.matrix_mem.memory[i +  6],
                UUT.matrix_mem.memory[i +  7],
                UUT.matrix_mem.memory[i +  8],
                UUT.matrix_mem.memory[i +  9],
                UUT.matrix_mem.memory[i + 10],
                UUT.matrix_mem.memory[i + 11],
                UUT.matrix_mem.memory[i + 12],
                UUT.matrix_mem.memory[i + 13],
                UUT.matrix_mem.memory[i + 14],
                UUT.matrix_mem.memory[i + 15],
            );
        end
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