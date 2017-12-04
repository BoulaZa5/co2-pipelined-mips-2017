# Create the instruction_table as a dictionary. This table stores instruction fields of each instruction in our MIPS Assembler


# instruction format fields
# 6 : R
# 4 : I
# 2 : J

# All values in HEX
instruction_table = {
    # R-format
    'add': ['0x00', 'rs', 'rt', 'rd', 'shamt', '0x20'],
    'sub': ['0x00', 'rs', 'rt', 'rd', 'shamt', '0x22'],
    'and': ['0x00', 'rs', 'rt', 'rd', 'shamt', '0x24'],
    'or': ['0x00', 'rs', 'rt', 'rd', 'shamt', '0x25'],
    'sll': ['0x00', 'rs', 'rt', 'rd', 'shamt', '0x00'],
    'srl': ['0x00', 'rs', 'rt', 'rd', 'shamt', '0x02'],
    'nor': ['0x00', 'rs', 'rt', 'rd', 'shamt', '0x27'],
    'slt': ['0x00', 'rs', 'rt', 'rd', 'shamt', '0x2A'],
    'jr': ['0x00', 'rs', 'rt', 'rd', 'shamt', '0x08'],
    # I-format
    'lw': ['0x23', 'rs', 'rt', 'imm'],
    'sw': ['0x2B', 'rs', 'rt', 'imm'],
    'lui': ['0x0F', 'rs', 'rt', 'imm'],
    'addi': ['0x08', 'rs', 'rt', 'imm'],
    'andi': ['0x0C', 'rs', 'rt', 'imm'],
    'ori': ['0x0D', 'rs', 'rt', 'imm'],
    'beq': ['0x04', 'rs', 'rt', 'imm'],
    'bne': ['0x05', 'rs', 'rt', 'imm'],
    'slti': ['0x0A', 'rs', 'rt', 'imm'],
    # J-format
    'j': ['0x02', 'add'],
    'jal': ['0x03', 'add'],

}