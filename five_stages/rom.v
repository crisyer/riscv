module rom (
    input[31:0] pc,
    output[31:0] instr
  );

  reg [31:0] memory[64:0];

  assign instr = memory[pc>>2];
  // 可以这么理解, 假设我们的pc现在是 8 ,代表我们要去第8个地址(下图8)
  // >>2 之后,地址为2,代表第二条word
  // |  0  |  1 |  2 |  3 |
  // |  4  |  5 |  6 |  7 |
  // |  8  |  9 |  10 |  11 |
  //  上述是内存模型, | * | 代表8位,一行4位,所以一行32位,我们要去第8个地址
  // 但一行就可以跨过去4个,所以,pc>>2,让我们的指令到了第三行的开头(或者说,第二行的末尾)
  // 还有一个好处,当pc的值不是8的整数,不会不合法,例如9(9>>2 == 2)依旧索引到8.

  initial
  begin
    // Example program:

    // NOP (ADD x0, x0, 0)
    memory[0] = 32'h00000013;

    //LUI x4, 0x12345 (加载上层立即数)
    memory[1] = 32'h00123237;

    //AUIPC x2, PC==8, 0 (加载 PC +立即数 0) pc ==12
    memory[2] = 32'h00000117;
    // nop

    // jal x1, -0x16 (从当前位置12跳转 offset= +8 == 20)
    // 跳过 memory[5] 的nop,
    // 并将memory[5]的20 pc 赋值给x2

    // 因为jal imm的特殊性,
    // 从右开始 16F代表 01 0 1101111.  01 0代表x2,后面1101111代表jal
    // 前面的0 0800   00代表imm高位, 08代表低位,也就是+8个跳转
    //
    memory[3] = 32'h0080016F;

    // NOP (ADD x0, x0, 0)
    memory[4] = 32'h00000013;

    // addi (ADDi x2, x2, 8)
    memory[5] = 32'h00810113;

    // addi (ADDi x2, x2, 8)
    memory[6] = 32'h00810113;

    // jalr x2 8 x2
    memory[7] = 32'h00810167;

    // NOP (ADD x0, x0, 0)
    memory[8] = 32'h00000013;

    // NOP (ADD x0, x0, 0)
    memory[9] = 32'h00000013;

    // beq x4 x4 跳转 8个单位
    memory[10] = 32'h00420463;
    // memory[10] = 32'h00411463; //BNE x2 x4
    // memory[10] = 32'h00414463; //BLT x2 x4
    // memory[10] = 32'h00225463; //BGE x4 x2

    // // addi (ADDi x2, x2, 8)
    // memory[10] = 32'h8FF10113;
    // // memory[11] = 32'h00226463; //BLTU x4 x2
    // memory[11] = 32'h00417463; //BGEU x4 x2

    // // NOP (ADD x0, x0, 0)
    // memory[12] = 32'h00000013;

    // // lb
    // memory[13] = 32'h00000013;

    // NOP (ADD x0, x0, 0)
    memory[11] = 32'h00000013;

    // // addi (ADDi x2, x0, 8)
    memory[12] = 32'h00200113;

    // lb x4 rom[2+x2]
    // memory[13] = 32'h00210203;
    // lh x4 rom[2+x2]
    // memory[13] = 32'h00211203;
    // lw x4 rom[2+x2]
    // memory[13] = 32'h00212203;
    // lbu x4 rom[2+x2]
    // memory[13] = 32'h00214203;
    // lhu x4 rom[2+x2]
    memory[13] = 32'h00215203;


    // // sb x4 rom[2+x2]
    // memory[14] = 32'h00410123;

    // sh x2 rom[2+x2]
    // memory[14] = 32'h00211123;

    // sw x2 rom[2+x2]
    memory[14] = 32'h00212123;

    //addi x2 8
    memory[15] = 32'h00800113;

    //slti x4 x2(8) 9
    memory[16] = 32'h80912213;

    //sltiu x4 x2(8) -1
    memory[17] = 32'h80013213;

    //xori x4 x2(8) 8ffffff
    memory[18] = 32'h8FF14213;

    //ori x4 x2(8) 8fffffff
    memory[19] = 32'h8FF16213;

    //andi x4 x2(8) 8fffffff
    memory[20] = 32'h8FF17213;

    //slli x4 x2(4) << 4
    memory[21] = 32'h00411213;

    //srli x4 x2(8) >> 3
    memory[22] = 32'h00315213;

    //srai x4 x2(8) >> 3
    memory[23] = 32'h40115213;

    //add x2 x4 x6
    memory[24] = 32'h00220333;

    //sub x4 x2 x6
    memory[25] = 32'h40410333;

    //sll x4 x2 x6
    memory[26] = 32'h00411333;

    //slt x2 x4 x6
    memory[27] = 32'h00222333;

    //addi x2 -1
    memory[28] = 32'h80000113;

    //sltu x2 x4 x6
    memory[29] = 32'h00223333;

    //addi x2 F
    memory[30] = 32'h00F00113;

    //xor x2 x4 x6
    memory[31] = 32'h00224333;

    //addi x2 1
    memory[32] = 32'h00100113;

    //srl x2 x4 x6
    memory[33] = 32'h00225333;

    //addi x2 -1
    memory[34] = 32'h80100113;

    //sra x2 x4 x6
    memory[35] = 32'h40225333;

    //or x2 x4 x6
    memory[36] = 32'h40225333;

    // //addi x2 1
    // memory[36] = 32'h00225333;

    //and x2 x4 x6
    memory[37] = 32'h00227333;








    // finish:
    // memory[12] = 32'h00000013; // nop (add x0 x0 0)


    // $readmemh("command.txt",memory);
  end

endmodule
