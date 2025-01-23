`timescale 1ns / 1ps


module tree #(
    parameter type TreeVal,
    parameter type TreeIdx,
    parameter integer TreePolarity = 0,
    parameter integer TreeWidth
) (
    input var TreeVal values[TreeWidth],

    output var TreeIdx out
);

  typedef struct {
    TreeVal value;
    TreeIdx id;
  } tree_item_t;

  function automatic tree_item_t find_min_max(TreeVal arr[TreeWidth], TreeIdx range_start,
                                              TreeIdx range_end);
    if ((range_end - range_start) >= 2) begin
      byte unsigned middle = range_start + ((range_end - range_start) >> 1);
      tree_item_t left = find_min_max(arr, range_start, middle);
      tree_item_t right = find_min_max(arr, middle + 1, range_end);
      if ((left.value > right.value) == TreePolarity) begin
        return right;
      end else begin
        return left;
      end
    end else if ((range_end - range_start) == 1) begin
      if ((arr[range_start] > arr[range_end]) == TreePolarity) begin
        return '{arr[range_end], range_end};
      end else begin
        return '{arr[range_start], range_start};
      end
    end  // range_start == range_end
    else begin
      return '{arr[range_start], range_start};
    end

  endfunction
  tree_item_t find_out;
  assign find_out = find_min_max(values, 0, TreeWidth - 1);
  assign out = find_out.id;

endmodule
