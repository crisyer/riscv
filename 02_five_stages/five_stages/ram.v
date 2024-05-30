module ram(
    input [31:0] ram_addr,
    input [31:0] write_ram_data,
    input [1:0] write_ram_flag,
    input [2: 0] load_ram_flag,
    input clk, rst,
    output reg [31:0] ram_out,

    output [31:0] ram_0, 
    output [31:0] ram_1, 
    output [31:0] ram_2, 
    output [31:0] ram_3, 
    output [31:0] ram_4, 
    output [31:0] ram_5, 
    output [31:0] ram_6, 
    output [31:0] ram_7, 
    output [31:0] ram_8
);
    reg [31:0] data [127:0];

    // initial begin
    //      data[0] = 32'h12345678;
    //      data[1] = 32'h22222222;
    //      data[2] = 32'h33333333;
    //      data[3] = 32'h12345678;
    //      data[4] = 32'hF2345678;
    //      data[5] = 32'h12345678;
    //      data[6] = 32'h12345678;
    //      data[7] = 32'h12345678;
    //      data[8] = 32'h12345678;
    // end

    assign ram_0 = data[0];
    assign ram_1 = data[1];
    assign ram_2 = data[2];
    assign ram_3 = data[3];
    assign ram_4 = data[4];
    assign ram_5 = data[5];
    assign ram_6 = data[6];
    assign ram_7 = data[7];
    assign ram_8 = data[8];

always @(*) begin
    case (load_ram_flag[1:0])
        2'b00:begin // 不读取
            ram_out = 32'b0;
        end
        2'b01:begin  // 读全字
            ram_out = data[ram_addr];
        end
        2'b10:begin //读半字
            if(load_ram_flag[2]) ram_out = {{16{data[ram_addr][31]}}, data[ram_addr][15:0]};
            else ram_out = {16'b0, data[ram_addr][15:0]};
        end
        2'b11:begin // 读单字节
            if(load_ram_flag[2]) ram_out = {{24{data[ram_addr][31]}}, data[ram_addr][6:0]};
            else ram_out = {24'b0, data[ram_addr][7:0]};
        end 
        default:begin
            ram_out = 32'b0;
        end
    endcase
end
always @(posedge clk) begin
    case (write_ram_flag)
        2'b01:begin // 写全字
            data[ram_addr] <= write_ram_data;
        end
        2'b10:begin //写半字
            data[ram_addr][15:0] = write_ram_data[15: 0];
        end
        2'b11:begin //写单字节
            data[ram_addr][7:0] = write_ram_data[7: 0];
        end     //nop
        default: begin
        end
    endcase
end
endmodule