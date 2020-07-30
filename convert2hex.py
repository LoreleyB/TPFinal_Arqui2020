
import sys
import struct
import binascii

op_r_shift = ["SLL", "SRL", "SRA"]
op_r = ["SRLV", "SRAV", "ADD", "SLLV", "SUBU", "AND", "OR", "XOR", "NOR", "SLT", "ADDU", "SLTU"]
op_i_base = ["LB", "LH", "LW", "LWU", "LBU" , "LHU", "SB", "SH", "SW"]

op_i_inm = ["ADDI", "ANDI", "ORI", "XORI", "SLTI", "ADDIU", "SLTIU"] 

op_i_comp = ["BEQ", "BNE"] 
op_j_jump = ["J", "JAL"]

code_r_shift = ['000000', '000010', '000011']
code_r = ['000110', '000111', '100000', '000100', '100100', '100100', '100101', '100110', '100111', '101010', '100001', '101011']
code_i_base = ['100000', '100001', '100011', '100111', '100100', '100101', '101000', '101001', '101011']

code_i_inm = ['001000', '001100', '001101', '001110', '001010', '001001', '001011']
code_i_comp = ['000100', '000101']

code_j_jump = ['000010', '000011']

def format_reg (hexa_regs):
    #value1 = hex (int(hexa_regs))
    if (hexa_regs == '0'):
        value1 = hexa_regs.zfill(5)
        return value1
    else:
        value1 = bin(int(hexa_regs, 16))[2:]
        print ('binario: ',value1)
        value = hex2bin (value1)
        
        return value

def define_op (asm_instruc):
    values = asm_instruc[1].split(sep=',')
    print (values)

    if asm_instruc[0] in op_r_shift:
        fun = code_r_shift [op_r_shift.index(asm_instruc[0])]
        op= '0'
        xeros = op.zfill(5)
        op=op.zfill(6)
        rd  = format_reg(values[0])
        rt = format_reg(values[1])
        sa = format_reg(values[2])
        bin_line = op + xeros + rt + rd + sa + fun
        print (bin_line)
        return (bin_line)
    
    elif asm_instruc[0] in op_r:
        op='0'
        sh=op.zfill(5)
        op=op.zfill(6)
        print (sh)
        fun = code_r[op_r.index(asm_instruc[0])]
        print (fun)
        rd  = format_reg(values[0])
        rs = format_reg(values[1])
        rt = format_reg(values[2])
        bin_line= op + rs + rt + rd + sh + fun
        print (bin_line)
        return (bin_line)
    
    elif asm_instruc[0] in op_i_base:                 # RT,BASE(OFFSET)
        op = code_i_base [op_i_base.index(asm_instruc[0])]
        rt = format_reg(values[0])
        addr = values[1].replace('(', ',')
        addr = addr[:(len(addr))-1]
        addr = addr.split(',')
        offset = (format_reg(addr[1])).zfill(16)
        base = format_reg(addr[0])
        bin_line = op + base + rt + offset
        print (bin_line)
        return (bin_line)
    
    elif asm_instruc[0] in op_i_inm:            # RT,RS,IMMEDIATE
        op = code_i_inm[op_i_inm.index(asm_instruc[0])]
        rt  = format_reg(values[0])
        rs = format_reg(values[1])
        imm = (format_reg(values[2])).zfill(16)
        bin_line = op + rs + rt + imm
        print (bin_line)
        return (bin_line)
    
    elif asm_instruc[0] in op_i_comp:           # RS,RT,OFFSET
        op = code_i_comp[op_i_comp.index(asm_instruc[0])]
        print (op)
        rs  = format_reg(values[0])
        rt = format_reg(values[1])
        offset = (format_reg(values[2])).zfill(16)
        bin_line = op + rs + rt + offset
        print (bin_line)
        return (bin_line)
        
    elif asm_instruc[0] == "LUI":                   # RT,IMMEDIATE
        op = '001111'
        xeros ='00000'
        rt= format_reg(values[0])
        imm = (format_reg(values[1])).zfill(16)
        bin_line = op + xeros + rt + imm
        print (bin_line)
        return (bin_line)
        
    
    elif asm_instruc[0] in op_j_jump:
        op = code_j_jump[op_j_jump.index(asm_instruc[0])]
        index = format_reg( asm_instruc[1] )
        bin_line = op + index.zfill(26)
        return (bin_line)
        
    elif asm_instruc[0] == "JR":
        op='0'
        op= op.zfill(6)
        xeros=op.zfill(15)
        fun = '001000'
        rs = format_reg( asm_instruc[1] )
        bin_line = op +rs + xeros + fun
        print (bin_line)
        return (bin_line)
        
    elif asm_instruc[0] == "JALR":
        op='0'
        xeros = op.zfill (5)
        op = op.zfill(6)
        fun = '001001'
        if (len(values) > 1 ):
            rd = format_reg(values[0])
            rs = format_reg(values[1])
        else:
            rd = '11111'
            rs = format_reg(asm_instruc[1])
        bin_line = op + rs + xeros + rd +xeros + fun 
        return (bin_line)

def hex2bin (value):
    print (len(value))
    print (value)
    if len(value) <= 5:
        print ('menor que 5')
        binary = value.zfill(5)
        return binary
    elif ((len(value) >=6) &  (len(value) < 16)):
        print('hasta16')
        binary = value.zfill(16)
        return binary
    elif len(value) > 16:
        print ('mayor 16')
        binary = value.zfill(26)
        return binary

file_path = 'program.txt'

stall = '11111111111111111111111111111111'
asm_file =  open (sys.argv[1],'r+') 
with open(file_path, 'w') as f:
    for line in asm_file:
        line= line.split()
        print ('linea: ',line)
        if len(line) & (line[0] == 'HALT'):
            opcode = stall
            f.write(opcode)
            print (opcode)
        else:
            opcode = define_op(line)
            f.write(opcode)
            f.write('\n')
f.close()
    

