module memory(Data_in,Address,write_En,read_En,Clk,rst,Data_out);
  
  input [31:0] Data_in;
  input [3:0] Address;
  input write_En,read_En,Clk,rst;
  output reg [31:0] Data_out;
  reg [31:0] mem [15:0];
  
  always @(posedge Clk or negedge rst) begin
    if(!rst)
      Data_out<=0;
    else begin
      if(write_En)
        mem[Address]<=Data_in;
      if(read_En)
        Data_out<=mem[Address];
    end
  end
endmodule