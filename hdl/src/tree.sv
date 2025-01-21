`timescale 1ns / 1ps
package tree_pkg;
  localparam TreeValWidth = 32;
  //localparam type TreeVal = logic [TreeValWidth-1:0];

  localparam TreeWidth = 8; // this is best as some 2^n
  localparam TreeIdxWidth = $clog2(TreeWidth);
  //localparam type TreeIdx = logic [TreeIdxWidth-1:0];
  localparam TreeDepth = $clog2(TreeWidth + 1);
  localparam TreePolarity = 0; // 1 = get smallest, 0 = get largest
endpackage

module tree
  import tree_pkg::*;
  #(
  parameter type TreeVal,
  parameter type TreeIdx)
(
  input var TreeVal values[TreeWidth],

  output var TreeIdx out
);

typedef struct {
    TreeVal value;
    TreeIdx id;
} TreeItem;

function automatic TreeItem find_min_max(TreeVal arr[TreeWidth], TreeIdx range_start, TreeIdx range_end);
    if ((range_end - range_start) >= 2) begin
        byte unsigned middle = range_start + ((range_end - range_start)>>1);
        TreeItem left = find_min_max(arr, range_start, middle);
        TreeItem right = find_min_max(arr, middle + 1 , range_end);
        if ((left.value > right.value) == TreePolarity) begin
            return right;
        end
        else begin
            return left;
        end
    end
    else if ((range_end - range_start) == 1) begin
        if ((arr[range_start] > arr[range_end]) == TreePolarity) begin
            return '{arr[range_end], range_end};
        end
        else begin
            return '{arr[range_start], range_start};
        end
    end
    // range_start == range_end
    else begin
        return '{arr[range_start], range_start};
    end

endfunction
TreeItem find_out;
assign find_out = find_min_max(values, 0, TreeWidth - 1);
assign out = find_out.id;

endmodule
