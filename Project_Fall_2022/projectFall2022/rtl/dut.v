module MyDesign (
//---------------------------------------------------------------------------
//Control signals
  input   wire dut_run                    , 
  output  reg dut_busy                   ,
  input   wire reset_b                    ,  
  input   wire clk                        ,
 
//---------------------------------------------------------------------------
//Input SRAM interface
  output reg        input_sram_write_enable    ,
  output reg [11:0] input_sram_write_addresss  ,
  output reg [15:0] input_sram_write_data      ,
  output reg [11:0] input_sram_read_address    ,
  input wire [15:0] input_sram_read_data       ,

//---------------------------------------------------------------------------
//Output SRAM interface
  output reg        output_sram_write_enable    ,
  output reg [11:0] output_sram_write_addresss  ,
  output reg [15:0] output_sram_write_data      ,
  output reg [11:0] output_sram_read_address    ,
  input wire [15:0] output_sram_read_data       ,

//---------------------------------------------------------------------------
//Scratchpad SRAM interface
  output reg        scratchpad_sram_write_enable    ,
  output reg [11:0] scratchpad_sram_write_addresss  ,
  output reg [15:0] scratchpad_sram_write_data      ,
  output reg [11:0] scratchpad_sram_read_address    ,
  input wire [15:0] scratchpad_sram_read_data       ,

//---------------------------------------------------------------------------
//Weights SRAM interface                                                       
  output reg        weights_sram_write_enable    ,
  output reg [11:0] weights_sram_write_addresss  ,
  output reg [15:0] weights_sram_write_data      ,
  output reg [11:0] weights_sram_read_address    ,
  input wire [15:0] weights_sram_read_data       

);

  //dimension values and weight matrix
  //wire [4:0] xdim, ydim;
  //wire [15:0]weight;
  //loading dimensions from the controller
  //wire [1:0]input_dim_load_ctrl;
  //addr and write enable from controller for sram interfaces
  wire [11:0]fsm_weight_addr, fsm_input_addr, fsm_output_addr;
  wire fsm_w_enable;
  //Data from interface outputs to device
  wire [15:0]weight_input_data, input_input_data;
  //Whole row output calculation to be sent to sram interface
  wire [15:0]calculation_output;
//---------------------------------------------------------------------------
//FSM Controller. This is where addres and data is set
  fms_controller controller(.clock(clk), .reset(reset_b), .go(dut_run),
    .input_data(input_input_data),
    .busy(dut_busy),
    .input_addr(fsm_input_addr),
    .weight_addr(fsm_weight_addr),
    .output_addr(fsm_output_addr),
    .output_w_enable(fsm_w_enable));

//---------------------------------------------------------------------------
//Convolution Module
convo calculate(.clock(clk), .reset(reset_b),
    .input_3x3(),
    .kernel(),
    .output_value());
//---------------------------------------------------------------------------
// Maxpoole Module
maxpoole max_out4(.clock(clk),.reset(reset_b)
    .intput_scratch_2x2());
//---------------------------------------------------------------------------
//Read Interface
sram_input_read input_data(.clock(clk),
   .reset(reset_b),
   .interface_sram_read_data(input_sram_read_data),
   .interface_sram_read_address(input_sram_read_address),
   .interface_sram_write_enable(input_sram_write_enable),
   .interface_sram_write_data(input_sram_write_data),
   .interface_sram_write_address(input_sram_write_addresss)
   .fsm_sram_addr(fsm_input_addr),
   .fsm_input_data(input_input_data)
   .fsm_w_enable(fsm_w_enable));

//---------------------------------------------------------------------------
//Weight interface
sram_weight_read weight_data(.clock(clk),
   .reset(reset_b),
   .interface_sram_read_data(weights_sram_read_data),
   .interface_sram_read_address(weights_sram_read_address),
   .interface_sram_write_enable(weights_sram_write_enable),
   .interface_sram_write_data(weights_sram_write_data),
   .interface_sram_write_address(weights_sram_write_addresss)
   .fsm_weight_addr(.fsm_weight_addr)
   .fsm_weight_data(.weight_input_data)
   .fsm_w_enable(fsm_w_enable));
//---------------------------------------------------------------------------
//Scratchpad Interface
sram_read scratchpad_data(.clock(clk),
   .reset(reset_b),
   .interface_sram_read_data(scratchpad_sram_read_data),
   .interface_sram_read_address(scratchpad_sram_read_address),
   .interface_sram_write_enable(scratchpad_sram_write_enable),
   .interface_sram_write_data(scratchpad_sram_write_data),
   .interface_sram_write_address(scratchpad_sram_write_addresss));
//---------------------------------------------------------------------------
//Write Interface
sram_output_data(.clock(clk),
   .reset(reset_b),
   .interface_sram_read_data(output_sram_read_data),
   .interface_sram_read_address(output_sram_read_address),
   .interface_sram_write_enable(output_sram_write_enable),
   .interface_sram_write_data(output_sram_write_data),
   .interface_sram_write_address(output_sram_write_addresss));
//---------------------------------------------------------------------------

endmodule
  //YOUR CODE HERE

module sram_input_read(
  input clock,
  input reset,
  output [15:0] interface_sram_read_data,
  input [11:0] interface_sram_read_address,
  output reg [11:0]interface_sram_write_addr, //to mem
  output reg [15:0]interface_sram_write_data, //to mem
  output reg interface_sram_r_enable);

  always @ ( posedge clock ) begin
    if(~reset)begin
      interface_sram_read_address <= 0;
      interface_sram_read_data <=0;
      interface_sram_write_addr <= 0;
      interface_sram_write_data <=0;
      interface_sram_r_enable <=0;
    end
    else begin
      interface_sram_r_enable <= fsm_w_enable;
      if(interface_sram_r_enable == 1)
      begin
        interface_sram_read_addr <=interface_sram_write_addr;
        interface_sram_read_data <=interface_sram_write_data; 
        interface_sram_write_addr <= fsm_input_addr;
        interface_sram_write_data <=input_input_data;
      end
      else if(interface_sram_r_enable == 0)
      begin
        interface_sram_read_addr <= fsm_input_addr;
        interface_sram_read_data <= input_input_data;
      end
       
    end

  end

endmodule

module sram_weight_data(
  input clock,
  input reset,
  output [15:0] interface_sram_read_data,
  input [11:0] interface_sram_read_address,
  output reg [11:0]interface_sram_write_addr, //to mem
  output reg [15:0]interface_sram_write_data, //to mem
  output reg interface_sram_r_enable);

always @ ( posedge clock ) begin
    if(~reset)begin
      interface_sram_read_address <= 0;
      interface_sram_read_data <=0;
      interface_sram_write_addr <= 0;
      interface_sram_write_data <=0;
      interface_sram_r_enable <=0;
    end
    else begin
      interface_sram_r_enable <= fsm_w_enable;
      if(interface_sram_r_enable == 1)
      begin
        interface_sram_read_addr <=interface_sram_write_addr;
        interface_sram_read_data <=interface_sram_write_data; 
        interface_sram_write_addr <= fsm_weight_addr;
        interface_sram_write_data <=weight_input_data;
      end
      else if(interface_sram_r_enable == 0)
      begin
        interface_sram_read_addr <= fsm_weight_addr;
        interface_sram_read_data <= weight_input_data;
        interface_sram_write_addr <= 0;
        interface_sram_write_data <=0;
      end
       
    end

  end

endmodule



