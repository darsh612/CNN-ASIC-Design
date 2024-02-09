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
  input wire [15:0] weights_sram_read_data );  

//Parameters
  localparam s0 = 6'b0;
  localparam s1 = 6'b01;
  localparam s2 = 6'b010;
  localparam s3 = 6'b011;
  localparam s4 = 6'b0100;
  localparam s5 = 6'b0101;
  localparam s6 = 6'b0110;
  localparam s7 = 6'b0111;
  localparam s8 = 6'b01000;
  localparam s9 = 6'b01001;
  localparam s10 = 6'b01010;
  localparam s11 = 6'b01011;
  localparam s12 = 6'b01100;
  localparam s13 = 6'b01101;
  localparam s14 = 6'b01110;
  localparam s15 = 6'b01111;
  localparam s16 = 6'b010000;
  localparam s17 = 6'b010001;
  localparam s18 = 6'b010010;
  localparam s19 = 6'b010011;
  localparam s20 = 6'b010100;
  localparam s21 = 6'b010101;
  localparam s22 = 6'b010110;
  localparam s23 = 6'b010111;
  localparam s24 = 6'b011000;
  localparam s25 = 6'b011001;
  localparam s26 = 6'b011010;
  localparam s27 = 6'b011011;
  localparam s28 = 6'b011100;
  localparam s29 = 6'b011101;
  localparam s30 = 6'b011110;
  localparam s31 = 6'b011111;
  localparam s32 = 6'b100000;
  localparam s33 = 6'b100001;
  localparam s34 = 6'b100010;
  localparam s35 = 6'b100011;
  localparam s36 = 6'b100100;
  localparam s37 = 6'b100101;
  localparam s38 = 6'b100110;
  localparam s39 = 6'b100111;
  localparam s40 = 6'b101000;
  localparam s41 = 6'b101001;
  localparam s42 = 6'b101010;
  localparam s43 = 6'b101011;
  localparam s44 = 6'b101100;
  localparam s45 = 6'b101101;
  localparam s46 = 6'b101110;

// Registers

 reg [7:0] Read_Size;
 reg signed[7:0] Read_data;
 reg signed[7:0] Read_data_ker;
 reg [5:0] current_state;
 reg [5:0] next_state;
 reg signed[19:0] Accumulator;
 reg [7:0] N;
 reg signed[15:0] Storage_1;
 reg signed[15:0] Storage_2;
 reg [7:0] counter_x;
 reg [7:0] counter_y;
 reg counter ;


//line select
 //reg [1:0]read_addr_size_sel;
 reg [1:0]read_size_sel;
 reg [1:0]write_ip;
 reg [1:0]write_ip_ker;
 reg [2:0]read_addr_sel;
 reg [1:0]read_addr_ker_sel;
 reg [1:0]acc_sel;
 reg [1:0]storage_sel1;
 reg [1:0]storage_sel2;
 reg [1:0]counter_x_sel;
 reg [1:0]counter_y_sel;
 reg [1:0]op_write_addr;
 reg [1:0]op_write_data;
 reg op_write_enable;
 reg N_sel;
 reg [1:0]counter_sel;

//wire select

wire signed [15:0] IPMulker;
//-------------Code Start----------------//

//Control path

//FSM

always@(posedge clk or negedge reset_b) begin
    if(!reset_b)
       current_state <= 6'b0;
    else
       current_state <= next_state;
end

always@(*) begin
    casex(current_state)
        s0 : begin
            read_size_sel = 2'b0;
            write_ip = 2'b0;
            write_ip_ker = 2'b0;
            N_sel = 1'b0;    
            read_addr_sel= 3'b0;
            read_addr_ker_sel = 2'b0;
            acc_sel = 2'b0;
            storage_sel1 = 2'b0;
            storage_sel2 = 2'b0;
            dut_busy = 1'b0;
            counter_x_sel = 2'b0;
            counter_y_sel = 2'b0;
            op_write_addr = 2'b0;
            op_write_data = 2'b0;
            op_write_enable = 1'b0;
            counter_sel = 2'b01;
            next_state = s1; 
        end
        s1 : begin
            /*read_size_sel = 2'b10;
            write_ip = 2'b0;
            write_ip_ker = 2'b0;
            N_sel = 1'b0;    
            read_addr_sel= 3'b0;
            read_addr_ker_sel = 2'b0;
            acc_sel = 2'b0;
            storage_sel1 = 2'b0;
            storage_sel2 = 2'b0;
            dut_busy = 1'b0;
            counter_x_sel = 2'b0;
            counter_y_sel = 2'b0;
            op_write_addr = 2'b0;
            op_write_data = 2'b0;
            op_write_enable = 1'b0;
            if (dut_run == 1'b1)
                next_state = s2;
            else
                next_state = s1;  */
            read_size_sel = 2'b10;
            write_ip = 2'b0;
            write_ip_ker = 2'b0;
            N_sel = 1'b0;    
            read_addr_sel= 3'b01;
            read_addr_ker_sel = 2'b0;
            acc_sel = 2'b10;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b0;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            if (dut_run == 1'b1)
                next_state = s2;
            else
                next_state = s1; 
        end
        s2 : begin
            read_size_sel = 2'b10;
            write_ip = 2'b0;
            write_ip_ker = 2'b0;
            N_sel = 1'b0;    
            read_addr_sel= 3'b01;
            read_addr_ker_sel = 2'b0;
            acc_sel = 2'b10;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s3;           
        end
        s3 : begin
            read_size_sel = 2'b01;
            N_sel = 1'b0;    
            write_ip = 2'b0;
            write_ip_ker = 2'b0;
            read_addr_sel= 3'b01;
            read_addr_ker_sel = 2'b0;
            acc_sel = 2'b10;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s4;
        end 
        s4 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b1;    
            write_ip = 2'b0;
            write_ip_ker = 2'b0;
            read_addr_sel= 3'b010;
            read_addr_ker_sel = 2'b01;   
            acc_sel = 2'b0;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            if(Read_Size == 8'hff)
               next_state = s0;
            else
               next_state = s5;
        end  
        s5 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b0;
            write_ip_ker = 2'b0;
            read_addr_sel= 3'b01; 
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b10;  
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s6;
        end 
        s6 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b010;  
            read_addr_ker_sel = 2'b10;  
            acc_sel = 2'b10;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s7;
        end 
        s7 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b011; 
            read_addr_ker_sel = 2'b01;   
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s8;
        end 
        s8 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b01;  
            read_addr_ker_sel = 2'b10;  
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s9;
        end 
        s9 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b010; 
            read_addr_ker_sel = 2'b01;   
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s10;
        end 
        s10 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b011; 
            read_addr_ker_sel = 2'b10;
            acc_sel = 2'b01;  
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10; 
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s11;
        end 
        s11 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b01;  
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10; 
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s12;
        end 
        s12 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b010;   
            read_addr_ker_sel = 2'b10; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s13;
        end 
        s13 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b100; 
            read_addr_ker_sel = 2'b0;
            acc_sel = 2'b01; 
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;  
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s14;
        end  
        s14 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b10; 
            read_addr_ker_sel = 2'b01;  
            acc_sel = 2'b01; 
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s15;
        end  
        s15 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b10; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s16;
        end  
        s16 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b11;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b11;
            storage_sel1 = 2'b01;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s17;
        end
        s17 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b10;   
            read_addr_ker_sel = 2'b10; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s18;
        end
        s18 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s19;
        end
        s19 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b11;   
            read_addr_ker_sel = 2'b10; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s20;
        end
        s20 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b10;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s21;
        end
        s21 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b10; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s22;
        end
        s22 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b101;   
            read_addr_ker_sel = 2'b0; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s23;
        end
        s23 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s24;
        end
        s24 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b010;   
            read_addr_ker_sel = 2'b10; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s25;
        end
        s25 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b011;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b11;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b01;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s26;
        end
        s26 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b10; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b11;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s27;
        end
        s27 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b010;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s28;
        end
        s28 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b011;   
            read_addr_ker_sel = 2'b10; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s29;
        end
        s29 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s30;
        end
        s30 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b010;   
            read_addr_ker_sel = 2'b10; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s31;
        end
        s31 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b100;   
            read_addr_ker_sel = 2'b0; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s32;
        end
        s32 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b10;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s33;
        end
        s33 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b10; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s34;
        end
        s34 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b011;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b11;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b01;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s35;
        end
        s35 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b10;   
            read_addr_ker_sel = 2'b10; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b11;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s36;
        end
        s36 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s37;
        end
        s37 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b11;   
            read_addr_ker_sel = 2'b10; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s38;
        end
        s38 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b10;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s39;
        end
        s39 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b10; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s40;
        end
        s40 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b01;
            write_ip_ker = 2'b10;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b0; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s41;
        end
        s41 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b10;
            write_ip_ker = 2'b01;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s42;
        end
        s42 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b0;
            write_ip_ker = 2'b0;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b01;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s43;
        end
        s43 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b0;
            write_ip_ker = 2'b0;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b0;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b01;
            dut_busy = 1'b1;           
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            op_write_data = 2'b11;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s44;
        end
        s44 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b0;
            write_ip_ker = 2'b0;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b0; 
            acc_sel = 2'b0;
            storage_sel1 = 2'b11;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_addr = 2'b10;
            if(counter == 1'b1) begin
               op_write_data = 2'b0;
            end
            else if(counter == 1'b0) begin
               op_write_data = 2'b11;
            end
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s45;
        end
        s45 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b0;
            write_ip_ker = 2'b0;
            read_addr_sel= 3'b01;   
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b0;
            storage_sel1 = 2'b0;
            storage_sel2 = 2'b0;
            dut_busy = 1'b1;
            counter_x_sel = 2'b10;
            counter_y_sel = 2'b10;
            op_write_enable= 1'b1;
            //op_write_addr =2'b10;
            if(counter == 1'b1) begin
               if(counter_x == 0 && output_sram_write_addresss ==12'b0 /*||(counter_x == ((N>>1)-2) && counter_y == ((N>>1)-2))*/) begin
                  op_write_addr = 2'b10; 
                  op_write_data = 2'b01;
                  counter_sel = 2'b0;
               end
               else  if((counter_x == 0 && output_sram_write_addresss !=12'b0) ||(counter_x != 0 && output_sram_write_addresss ==12'b0)||(counter_x != 0 && output_sram_write_addresss !=12'b0))begin
                  op_write_addr = 2'b01;
                  op_write_data = 2'b01;
                  counter_sel = 2'b0;
               end
               else if ((counter_x == ((N>>1)-2) && counter_y == ((N>>1)-2))) begin
                  op_write_addr = 2'b10; 
                  op_write_data = 2'b11;
                  counter_sel = 2'b0;
               end
               else begin
                  op_write_addr = 2'b0; 
                  op_write_data = 2'b0;
                  counter_sel = 2'b0;
               end
            end
            else if(counter == 1'b0) begin
               op_write_addr = 2'b10;
               op_write_data = 2'b10;
               counter_sel = 2'b01;
            end
            next_state = s46;
        end
        s46 : begin
            read_size_sel = 2'b10;
            N_sel = 1'b0;    
            write_ip = 2'b0;
            write_ip_ker = 2'b0;
            read_addr_ker_sel = 2'b01; 
            acc_sel = 2'b0;
            storage_sel1 = 2'b10;
            storage_sel2 = 2'b10;
            dut_busy = 1'b1;
            op_write_enable = 2'b0;
            if(counter_y < ((N>>1)-2)) begin
               if(counter_x != ((N>>1)-2)) begin
                  read_addr_sel= 3'b110; 
                  counter_x_sel= 2'b01;
                  counter_y_sel= 2'b10;
                  op_write_addr = 2'b10;
                  op_write_data = 2'b11;
                  counter_sel = 2'b10;
                  next_state = s4;                  
               end
               else begin
                  read_addr_sel= 3'b111;
                  counter_x_sel= 2'b0;
                  counter_y_sel= 2'b01;
                  op_write_addr = 2'b10;
                  op_write_data = 2'b11;
                  counter_sel = 2'b10;
                  next_state = s4;
               end
            end
            else if(counter_y == ((N>>1)-2))begin
               if(counter_x < ((N>>1)-2)) begin
                  read_addr_sel= 3'b110; 
                  counter_x_sel= 2'b01;
                  counter_y_sel= 2'b10;
                  op_write_addr = 2'b10;
                  op_write_data = 2'b11;
                  counter_sel = 2'b10;
                  next_state = s4;  
               end
               else if(counter_x == ((N>>1)-2)) begin
                  read_addr_sel = 3'b010;
                  counter_x_sel = 2'b0;
                  counter_y_sel = 2'b0;
                  op_write_data = 2'b10;
                  counter_sel = 2'b01;
                  op_write_addr = 2'b10;
                  next_state = s2;
               end
               else begin
                  read_addr_sel = 3'b0;
                  counter_x_sel = 2'b0;
                  counter_y_sel = 2'b0;
                  op_write_data = 2'b0;
                  counter_sel = 2'b0;
                  op_write_addr = 2'b0;
                  next_state = s0;  
               end
            end
            else begin
                  read_addr_sel = 3'b0;
                  counter_x_sel = 2'b0;
                  counter_y_sel = 2'b0;
                  op_write_data = 2'b0;
                  counter_sel = 2'b0;
                  op_write_addr = 2'b0;
                  next_state = s0; 
            end
        end
        default : begin
            read_size_sel = 2'b0;
            N_sel = 1'b0;    
            write_ip = 1'b0;
            write_ip_ker = 2'b0;
            read_addr_sel= 3'b01; 
            read_addr_ker_sel = 2'b0; 
            acc_sel = 2'b0;
            storage_sel1 = 2'b0;
            storage_sel2 = 2'b0;
            dut_busy = 1'b0;
            counter_x_sel = 2'b0;
            counter_y_sel = 2'b0;
            op_write_addr = 2'b0;
            op_write_data = 2'b0;
            op_write_enable = 1'b0;
            counter_sel = 2'b10;
            next_state = s0;        
        end
    endcase
end

//Data Path
//Size Count register

always@(posedge clk)begin
       if(read_size_sel == 2'b0)
       begin
          Read_Size <= 0;
       end
       else if(read_size_sel == 2'b01)
       begin
          Read_Size <= input_sram_read_data;  
       end 
          //assign N = SizeCount;
       else if(read_size_sel == 2'b10)
       begin  
          Read_Size <= Read_Size;
       end
end

// Read_address
always@(posedge clk)begin
       if(read_addr_sel == 3'b0)
         input_sram_read_address <= 12'b0;
       else if(read_addr_sel == 3'b01)    
         input_sram_read_address <= input_sram_read_address ;
       else if(read_addr_sel == 3'b010)
         input_sram_read_address <= input_sram_read_address+ 12'b1;  
       else if(read_addr_sel == 3'b011)
         input_sram_read_address <= input_sram_read_address+ ((N>>1)-1);  
       else if(read_addr_sel == 3'b100)
         input_sram_read_address <= input_sram_read_address- (N+1);   
       else if(read_addr_sel == 3'b101)
         input_sram_read_address <= input_sram_read_address -((N>>1)+1);   
       else if(read_addr_sel == 3'b110)
         input_sram_read_address <= input_sram_read_address -(3*(N>>1)+1);   
       else if(read_addr_sel == 3'b111)
         input_sram_read_address <= input_sram_read_address - (N);
end

//N transfer
always@(posedge clk)begin
       if(N_sel == 1'b0)
         N <= N;
       else if(N_sel)
         N <= Read_Size;          
end
// Read Data
always@(posedge clk)begin
       if(write_ip == 2'b0)
           Read_data <= Read_data;
       else if(write_ip == 2'b01)
           Read_data <= input_sram_read_data[15:8];
       else if(write_ip == 2'b10) 
           Read_data <= input_sram_read_data[7:0];
end

//Read_Weight_address

always@(posedge clk)begin
       if(read_addr_ker_sel == 2'b0)
         weights_sram_read_address <= 12'b0;
       else if(read_addr_ker_sel == 2'b01)    
         weights_sram_read_address <= weights_sram_read_address ;
       else if(read_addr_ker_sel == 2'b10)
         weights_sram_read_address <= weights_sram_read_address+ 12'b1;        
end

// Read Weight Data
always@(posedge clk)begin
       if(write_ip_ker == 2'b0)
           Read_data_ker <= Read_data_ker;
       else if(write_ip_ker == 2'b01)
           Read_data_ker <= weights_sram_read_data[15:8];
       else if(write_ip_ker == 2'b10) 
           Read_data_ker <= weights_sram_read_data[7:0];
end

// Accumulator
assign IPMulker = Read_data * Read_data_ker;
always @(posedge clk) begin
        if (acc_sel == 2'b0)
	    Accumulator <= 19'b0;
	else if (acc_sel == 2'b01)
	    Accumulator <= Accumulator + {4'b0,IPMulker};
	else if (acc_sel == 2'b10)
	    Accumulator <= Accumulator;
        else if (acc_sel == 2'b11)
            Accumulator <= IPMulker;
end

//Storage_1
always@(posedge clk) begin
       if(storage_sel1 == 2'b0) begin
          Storage_1 <= 0;
       end
       else if(storage_sel1 == 2'b01) begin
          Storage_1 <= (Accumulator[15] == 1)? 16'h0:Accumulator;
       end
       else if(storage_sel1 == 2'b10) begin
          Storage_1 <= Storage_1;  
       end
       else if(storage_sel1 == 2'b11) begin
          Storage_1 <= (Storage_1 > Storage_2)?Storage_1 : Storage_2;
       end
end
//Storage_2
always@(posedge clk) begin
       if(storage_sel2 == 2'b0) begin
          Storage_2 <= 0;
       end 
       else if(storage_sel2 == 2'b01) begin
          Storage_2 <= (Accumulator[15] == 1)? 16'h0:Accumulator;
       end
       else if(storage_sel2 == 2'b10) begin
          Storage_2 <= Storage_2;  
       end
end

//Counter_x
always@(posedge clk) begin
       if(counter_x_sel == 2'b0)
          counter_x <= 7'b0;
       else if(counter_x_sel == 2'b01)
          counter_x <= counter_x + 7'b01;
       else if(counter_x_sel == 2'b10)
          counter_x <= counter_x; 
end

//Counter_y
always@(posedge clk) begin
       if(counter_y_sel == 2'b0)
          counter_y <= 7'b0;
       else if(counter_y_sel == 2'b01)
          counter_y <= counter_y + 7'b01;
       else if(counter_y_sel == 2'b10)
          counter_y <= counter_y; 
end
 
//O/p write_address
always@(posedge clk)begin
       if(op_write_addr == 2'b0)
         output_sram_write_addresss <=0;
       else if(op_write_addr == 2'b01)
         output_sram_write_addresss <= output_sram_write_addresss + 12'b01;
       else if(op_write_addr == 2'b10)
         output_sram_write_addresss <= output_sram_write_addresss;
end

// O/p write_enable
always@(posedge clk)begin
       if(op_write_enable == 1'b0)
         output_sram_write_enable <= 1'b0;
       else if(op_write_enable == 1'b1)
         output_sram_write_enable <= 1'b1;
end

// O/p write_data
always@(posedge clk)begin
       if(op_write_data == 2'b0) begin
         output_sram_write_data <= 0;
       end
       else if(op_write_data == 2'b01) begin
         output_sram_write_data[15:8] <= (Storage_1[7:0] >= 8'h7f)? 8'h7f : Storage_1[7:0];
         //counter = 1'b0;
       end
       else if(op_write_data == 2'b10) begin
         output_sram_write_data[7:0] <= (Storage_1[7:0]>= 8'h7f)? 8'h7f : Storage_1[7:0];
         //counter = 1'b1;
       end
       else if(op_write_data == 2'b11) begin
         output_sram_write_data <= output_sram_write_data;
       end
end

always@(posedge clk)begin
      if(counter_sel == 2'b0) begin
        counter = 1'b0;
      end
      else if(counter_sel == 2'b01) begin
        counter = 1'b1;  
      end
      else if(counter_sel == 2'b10)begin
        counter = counter;
      end
end
 

endmodule
