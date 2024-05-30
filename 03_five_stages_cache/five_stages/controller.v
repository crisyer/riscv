module controller(
    input [6: 0] opcode,
    input [2: 0] func3,
    input [6: 0] func7,

    output reg [4: 0] alu_opt,
    
    output reg alu_a_in_rs1_or_pc, // JAL JALR AUIPC
    output reg [1: 0] alu_b_in_rs2Data_or_imm32_or_4,

    output reg write_reg_enable, // rd

    output reg [1: 0] write_ram_flag,  // s
    output reg wb_aluOut_or_memOut, // LW LH LB
    output reg [2: 0] load_ram_flag,
    output reg [1: 0] pc_condition
);

always @(*) begin
    case (opcode)
        // lui
        7'b0110111:begin
            write_reg_enable = 1;
            wb_aluOut_or_memOut = 0;
            alu_a_in_rs1_or_pc = 0; // 
            alu_b_in_rs2Data_or_imm32_or_4 = 2'b01; //imm
            write_ram_flag = 2'b00;
            load_ram_flag = 3'b000;
            alu_opt = 5'b10001;
            pc_condition = 2'b00;
        end
        // auipc
        7'b0010111:begin
            write_reg_enable = 1;
            wb_aluOut_or_memOut = 0;
            alu_a_in_rs1_or_pc = 1; // pc
            alu_b_in_rs2Data_or_imm32_or_4 = 2'b01; //imm
            write_ram_flag = 2'b00;
            load_ram_flag = 3'b000;
            alu_opt = 5'b00000;
            pc_condition = 2'b00;
        end
        // jal
        7'b1101111:begin
            write_reg_enable = 1;
            wb_aluOut_or_memOut = 0;
            alu_a_in_rs1_or_pc = 1; // pc
            alu_b_in_rs2Data_or_imm32_or_4 = 2'b11; //  pc+4 ==>rd
            write_ram_flag = 2'b00;
            load_ram_flag = 3'b000;
            alu_opt = 5'b00000;
            pc_condition = 2'b10;
        end
        // jalr
        7'b1100111:begin
            write_reg_enable = 1;
            wb_aluOut_or_memOut = 0;
            alu_a_in_rs1_or_pc = 0; // rs1_addr
            alu_b_in_rs2Data_or_imm32_or_4 = 2'b01; //  rs + imm ==>rd
            write_ram_flag = 2'b00;
            load_ram_flag = 3'b000;
            alu_opt = 5'b01010;
            pc_condition = 2'b11;
        end
        // B型指令
        7'b1100011:begin
            write_reg_enable = 0;
            wb_aluOut_or_memOut = 0;
            alu_a_in_rs1_or_pc = 0; // rs1_addr
            alu_b_in_rs2Data_or_imm32_or_4 = 2'b00;; //rs2_addr
            write_ram_flag = 2'b00;
            load_ram_flag = 3'b000;
            pc_condition = 2'b01;
            case (func3)
                // beq
                3'b000:begin
                    alu_opt = 5'b01011;
                end
                // bne
                3'b001:begin
                    alu_opt = 5'b01100;
                end
                // blt
                3'b100: begin
                    alu_opt = 5'b01101;
                end
                // bge
                3'b101:begin
                    alu_opt = 5'b01110;
                end
                // bltu
                3'b110:begin
                    alu_opt = 5'b01111;
                end
                // bgeu
                3'b111:begin
                    alu_opt = 5'b10000;
                end
                default:begin
                    
                end
            endcase
        end
        // L型指令
        7'b0000011:begin
            write_reg_enable = 1;
            wb_aluOut_or_memOut = 1;
            alu_a_in_rs1_or_pc = 0; // rs1_addr
            alu_b_in_rs2Data_or_imm32_or_4 = 2'b01; //imm
            write_ram_flag = 2'b00;
            alu_opt = 5'b00000;
            pc_condition = 2'b00;
            case (func3)
                // lw
                3'b010:begin
                    load_ram_flag = 3'b001;
                end
                // lh
                3'b001:begin
                    load_ram_flag = 3'b110;
                end
                // lb
                3'b000:begin
                    load_ram_flag = 3'b111;
                end
                // lbu
                3'b100:begin
                    load_ram_flag = 3'b011;
                end
                // lhu
                3'b101:begin
                    load_ram_flag = 3'b010;
                end
                default: begin
                    
                end
            endcase
        end
        // S型指令
        7'b0100011:begin
            write_reg_enable = 0;
            wb_aluOut_or_memOut = 0;
            alu_a_in_rs1_or_pc = 0; // rs1_addr
            alu_b_in_rs2Data_or_imm32_or_4 = 2'b01; //imm
            write_ram_flag = 2'b00;
            load_ram_flag = 3'b000;
            alu_opt = 5'b00000;
            pc_condition = 2'b00;
            case (func3)
                // sw
                3'b010:begin
                    write_ram_flag = 2'b01;
                end
                // sh
                3'b001:begin
                    write_ram_flag = 2'b10;
                end
                // sb
                3'b000:begin
                    write_ram_flag = 2'b11;
                end
                default: begin
                    
                end
            endcase
        end
        // I型指令
        7'b0010011:begin
            write_reg_enable = 1;
            wb_aluOut_or_memOut = 0;
            alu_a_in_rs1_or_pc = 0; // rs1_addr
            alu_b_in_rs2Data_or_imm32_or_4 = 2'b01; //imm
            write_ram_flag = 2'b00;
            load_ram_flag = 3'b000;
            pc_condition = 2'b00;

            case (func3)
                // addi
                3'b000:begin
                    alu_opt = 5'b00000;
                end
                // slti
                3'b010:begin
                    alu_opt = 5'b00110;
                end
                // sltiu
                3'b011:begin
                    alu_opt = 5'b00111;
                end
                // xori
                3'b100:begin
                    alu_opt = 5'b00100;
                end
                // ori
                3'b110:begin
                    alu_opt = 5'b00011;
                end
                // andi
                3'b111:begin
                    alu_opt = 5'b00010;
                end
                // slli
                3'b001:begin
                    alu_opt = 5'b00101;
                end
                // srli, srai
                3'b101:begin
                    if(func7[5])begin
                        alu_opt = 5'b01001;
                    end
                    else alu_opt = 5'b01000;
                end
                default:begin
                    
                end
            endcase
        end
        // R型指令
        7'b0110011:begin
            write_reg_enable = 1;
            wb_aluOut_or_memOut = 0;
            alu_a_in_rs1_or_pc = 0; // rs1_addr
            alu_b_in_rs2Data_or_imm32_or_4 = 2'b00;; //rs2_addr
            write_ram_flag = 2'b00;
            load_ram_flag = 3'b000;
            pc_condition = 2'b00;
            case (func3)
                // sub, add
                3'b000:begin
                    if(func7[5])begin
                        alu_opt = 5'b00001;
                    end else begin
                        alu_opt = 5'b00000;
                    end
                end
                // or
                3'b110:begin
                    alu_opt = 5'b00011;
                end
                // and
                3'b111:begin
                    alu_opt = 5'b00010;
                end
                // xor
                3'b100:begin
                    alu_opt = 5'b00100;
                end
                // sll
                3'b001:begin
                    alu_opt = 5'b00101;
                end
                // slt
                3'b010:begin
                    alu_opt = 5'b00110;
                end
                // sltu
                3'b011:begin
                    alu_opt = 5'b00111;
                end
                // srl, sra
                3'b101:begin
                    if(func7[5]) alu_opt = 5'b01001;
                    else alu_opt = 5'b01000;
                end 
                default: begin
                    
                end
            endcase
        end
        default: begin
            
        end
    endcase
end

endmodule