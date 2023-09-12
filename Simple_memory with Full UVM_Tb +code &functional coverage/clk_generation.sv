//clk generation
  parameter clk_period=10;
  logic clk;
  initial begin
    clk=0;
    forever
      #(clk_period/2) clk=~clk;
  end