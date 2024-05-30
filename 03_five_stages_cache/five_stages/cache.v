// 缓存大小和块大小设置
// 缓存块的概念主要源自于内存访问的特点:

// 内存访问是以字节为单位的随机访问。CPU 可以任意读写内存中的任何一个字节。
// 但实际上,内存的物理特性决定了内存访问的最小单位并不是字节,而是一个较大的数据块,比如 32 字节或 64 字节。
// 这是因为内存通常由多个存储单元组成,每次读写都需要访问多个存储单元。而将这些物理上相邻的存储单元组成一个数据块,就可以提高内存访问的效率。
// 所以在缓存设计中,我们将内存划分成多个固定大小的缓存块(cache block),每个缓存块包含多个字节的数据。

// 这样做的好处有:

// 可以利用局部性原理,当 CPU 访问一个内存地址时,附近的地址很可能也会被访问。缓存可以预取整个缓存块,提高访问效率。
// 缓存的标记(tag)和索引(index)设计也会变得更加简单高效。
// 缓存的替换策略也可以针对整个缓存块进行优化,而不是针对单个字节。
`define FIFO 1 // 注释掉就是LRU
module cpu_cache #(
    parameter DATA_WIDTH = 32,   //DATA_WIDTH定义了数据宽度, 定义的就是32位的可以寻址的最大内存里面的数据
    parameter ADDR_WIDTH = 32, // ADDR_WIDTH定义了地址宽度
    // ADDR_WIDTH 表示整个地址空间的位宽,也就是说这个系统所能访问的最大内存地址的位数。
    //在缓存设计中,我们需要考虑整个计算机系统的地址空间,因为缓存作为一个中间层,需要能够覆盖所有可能访问到的内存地址。
    // 所以32位就是32位,64就是64
    parameter CACHE_SIZE = 4096  // 4KB cache
) (
    input clk,
    input reset,
    input [ADDR_WIDTH-1:0] addr,
    input read,
    input write,
    input [DATA_WIDTH-1:0] write_data,
    output reg [DATA_WIDTH-1:0] read_data,
    output reg hit  //上述是输入与输出
);

// 定义常量
localparam BLOCK_SIZE = 64;  // BLOCK_SIZE定义了每个缓存块的大小,为64字节。
localparam NUM_BLOCKS = CACHE_SIZE / BLOCK_SIZE; //NUM_BLOCKS计算出缓存中总共有多少个块。
localparam BLOCK_ADDR_WIDTH = $clog2(NUM_BLOCKS);  
// 比如4kb cache, 一个 cache block是64,那么一共就要用 64个 block,
//也就是一共要被划分成64个block,现在要对这64个block编号,一共需要log2(64)也就是6位就可以存储

//NUM_BLOCKS 是缓存中总共的块数
//$clog2(NUM_BLOCKS) 是一个 Verilog 内置函数，它会返回一个整数值，代表 NUM_BLOCKS 所需要的最小二进制位宽。
//将这个值赋给 BLOCK_ADDR_WIDTH 局部参数，表示用于寻址缓存块的地址宽度
//这样做的目的是动态计算出所需的地址宽度,而不是提前固定一个值。这样可以使得缓存大小更加灵活和可扩展。

// 缓存结构
reg [DATA_WIDTH-1:0] cache_data [0:NUM_BLOCKS-1];  
// cache需要满足地址位数,所以是data_width-1位;因为需要num_block个数的cache,所以,个数为NUM_BLOCKS-1
reg [ADDR_WIDTH-BLOCK_ADDR_WIDTH-1:0] cache_tag [0:NUM_BLOCKS-1];
// cache_tag不是对16个cache-data的打tag,而是对全体可寻址的4GB空间进行打tag.
// 因为num_block的个数一共为64, 所以tag的个数要和实际block个数一致
// 而它的位宽, 因为缓存,缓存的是整个可以被寻址的ram中的数据.也就是,32位电脑,一共可以有4GB大小的空间可以被寻址
// 那么理论上, 位宽的大小要符合,可以寻址4GB大小的要求.

reg cache_valid [0:NUM_BLOCKS-1];
// 这里是标记cache是否合法,是否还是最新值或者已经过期
// 这是一个一维数组,用于标记每个缓存块是否有效。
// 每个元素是一个 1 位的 reg，表示该缓存块是否包含有效数据。


// 替换策略
`ifdef FIFO
reg [BLOCK_ADDR_WIDTH-1:0] fifo_ptr;
`else
reg [BLOCK_ADDR_WIDTH-1:0] lru_ptr [0:NUM_BLOCKS-1];
reg [BLOCK_ADDR_WIDTH-1:0] lru_head;
`endif

/* 
这段代码定义了两种不同的缓存替换策略:FIFO(先进先出)和 LRU(最近最少使用)。
FIFO 策略:
定义了一个 fifo_ptr 寄存器,用于记录下一个要被替换的缓存块的地址。
每次替换缓存块时,将 fifo_ptr 指向的块替换掉,然后 fifo_ptr 自增。
LRU 策略:
定义了两个寄存器:
lru_ptr: 一个二维数组,用于记录每个缓存块在 LRU 队列中的位置。
lru_head: 用于记录 LRU 队列的头部位置,也就是最近最少使用的缓存块。
每次访问缓存时,都需要更新对应缓存块在 LRU 队列中的位置,并更新 lru_head。
这两种策略是常见的缓存替换算法,各有优缺点:

FIFO 策略简单易实现,但不考虑数据使用频率,可能会导致热点数据被频繁替换出去。
LRU 策略能够较好地保留热点数据,但实现复杂度较高,需要维护一个队列。
通过 ifdef 预处理指令,可以根据项目需求选择使用哪种替换策略。在编译时,编译器会根据宏定义选择相应的代码分支。 
*/


integer i, j;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        // 重置缓存
        for (i = 0; i < NUM_BLOCKS; i++) begin
            cache_valid[i] <= 1'b0;
        end
        `ifdef FIFO
        fifo_ptr <= 0;
        `else
        for (i = 0; i < NUM_BLOCKS; i++) begin
            lru_ptr[i] <= i;
        end
        lru_head <= 0;
        `endif
    end else begin
        // 缓存访问
        if (read) begin
            // 从缓存中读取
            hit <= 1'b0;
            for (i = 0; i < NUM_BLOCKS; i++) begin
                if (cache_valid[i] && cache_tag[i] == addr[ADDR_WIDTH-1:BLOCK_ADDR_WIDTH]) begin
                    read_data <= cache_data[i];
                    hit <= 1'b1;
                    `ifdef FIFO
                    fifo_ptr <= (fifo_ptr + 1) % NUM_BLOCKS;
                    `else
                    // 更新LRU
                    for (j = 0; j < NUM_BLOCKS; j++) begin
                        if (lru_ptr[j] == i) begin
                            lru_ptr[j] <= lru_head;
                            lru_head <= i;
                            // 这里无需"break",循环会自动退出
                        end
                    end
                    `endif
                    // 这里无需"break",循环会自动退出
                end
            end
        end else if (write) begin
            // 写入缓存
            `ifdef FIFO
            cache_data[fifo_ptr] <= write_data; //这行代码将要写入的数据存储到缓存的当前位置,也就是 fifo_ptr 指向的缓存块。
            cache_tag[fifo_ptr] <= addr[ADDR_WIDTH-1:BLOCK_ADDR_WIDTH]; //这行代码将地址标记(tag)存储到缓存的当前位置。
            cache_valid[fifo_ptr] <= 1'b1;  //这行代码将缓存的当前位置标记为有效(valid)。
            fifo_ptr <= (fifo_ptr + 1) % NUM_BLOCKS;    //这行代码更新了 fifo_ptr 的值,将其指向下一个可替换的缓存块。
            `else
            // 找到LRU块
            integer lru_index = lru_ptr[lru_head];
            cache_data[lru_index] <= write_data;
            cache_tag[lru_index] <= addr[ADDR_WIDTH-1:BLOCK_ADDR_WIDTH];
            cache_valid[lru_index] <= 1'b1;
            // 更新LRU
            for (i = 0; i < NUM_BLOCKS; i++) begin
                if (lru_ptr[i] == lru_head) begin
                    lru_ptr[i] <= lru_index;
                    lru_head <= (lru_head + 1) % NUM_BLOCKS;
                    // 这里无需"break",循环会自动退出
                end
            end
            `endif
        end
    end
end

/* 这段代码实现了一个简单的缓存系统,包括以下功能:

缓存初始化:
当 reset 信号为高电平时,将所有缓存块的 cache_valid 标记为无效。
对于 FIFO 替换策略,将 fifo_ptr 重置为 0。
对于 LRU 替换策略, lru_ptr 数组被初始化为 0 到 NUM_BLOCKS-1 的索引序列,表示每个缓存块在 LRU 队列中的初始位置。lru_head 被初始化为 0,表示最近最少使用的缓存块索引。
缓存读取:
当 read 信号为高电平时,遍历所有缓存块,检查地址标签是否与访问地址的高位部分匹配,并且缓存块有效。
如果命中,则将缓存数据输出到 read_data，并将 hit 标志置为 1。
对于 FIFO 策略,不需要进一步操作。
对于 LRU 策略,需要更新命中缓存块在 LRU 队列中的位置,将其移动到队列头部。
缓存写入:
当 write 信号为高电平时,根据替换策略选择一个要替换的缓存块。
对于 FIFO 策略,将数据写入 fifo_ptr 指向的缓存块,并将 fifo_ptr 循环自增。
对于 LRU 策略,将数据写入 lru_ptr[lru_head] 指向的缓存块,并更新 lru_ptr 和 lru_head 以反映新的 LRU 队列情况。
通过这段代码,可以实现一个基本的缓存系统,支持两种常见的替换策略:FIFO 和 LRU。在编译时通过宏定义选择使用哪种策略。 */

endmodule