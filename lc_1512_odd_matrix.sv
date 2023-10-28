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