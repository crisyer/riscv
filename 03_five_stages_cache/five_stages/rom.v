module rom (
    input  clk, 
    input[31:0] pc,
    // output reg [31:0] instr,
    output reg [31:0] instr,
    output reg ready
  );


// parameter num = 128; // 128条指令的容量
reg [31:0] memoryData[0:127];

  // assign instr = memoryData[pc>>2]; // 现在对取指令行为加上delay
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
     $readmemh("../five_stages_tb/commands.txt",memoryData);
  end

  reg [3:0] delay_counter = 0;

  always @(posedge clk)
  begin
    if (delay_counter < 6) begin
      delay_counter <= delay_counter + 1 ;
      instr <= 32'd13;
      ready <= 0;
    end
    else begin
      delay_counter<=0;
      ready <= 1;
      instr <= memoryData[pc>>2];
    end
  end

  initial begin
    ready = 1;
  end

endmodule
