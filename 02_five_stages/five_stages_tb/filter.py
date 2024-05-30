import re

# 输入文件路径
input_file = 'main.txt'
# 输出文件路径
output_file = 'commands.txt'

# 使用正则表达式匹配 32 位 16 进制数字,并且排除<func> 
pattern = r'(?<!<)\b[0-9A-Fa-f]{8}\b(?!>)'

# 读取输入文件并提取数字
hex_numbers = []
with open(input_file, 'r') as f:
    for line in f:
        match = re.search(pattern, line)
        if match:
            hex_numbers.append(match.group())

# 将数字写入输出文件,除了最后一行
with open(output_file, 'w') as f:
    for i, number in enumerate(hex_numbers):
        if i < len(hex_numbers) - 1:
            f.write(number + '\n')
        else:
            f.write(number)

with open('commands.txt', 'r') as f:
    num_lines = len(f.readlines())
    num_lines = num_lines -1


with open('../five_stages/rom.v', 'r') as file:
    lines = file.readlines()

# 从第 7 行开始处理
for i in range(len(lines)):
    if i == 6 :
                lines[i] = "parameter num = "+str(num_lines)+";\n"

# 将修改后的内容写回文件
with open('../five_stages/rom.v', 'w') as file:
    file.writelines(lines)
