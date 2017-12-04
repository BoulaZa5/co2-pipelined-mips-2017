import re


class command(object):
    def __init__(self, cmd_string):
        return


class assembly_parser(object):
    # Word size
    word_size = 4

    # Default memory location
    default_mem_loc = 0

    # List of labels and their respective locations
    symbol_table = {}

    # Current location in memory
    current_location = 0

    # dictionary of memory locations with their values
    system_memory = {}

    # current instruction table
    instruction_table = {}

    # current resister table
    register_table = {}

    # Output
    output_array = []

    def __init__(self, default_memory_location, instruction_table, register_table, word_size):
        ''' Initialize tables and memory'''

        self.default_mem_loc = default_memory_location
        self.instruction_table = instruction_table
        self.register_table = register_table
        self.word_size = word_size

    def first_pass(self, lines):
        '''For first pass, calculate size in mem of each instruction for calculating addressing'''

        self.current_location = self.default_mem_loc
        for line in lines:

            # Sanitize string (comments, whitespace, etc.)
            if '#' in line:
                line = line[0:line.find('#')]
            line = line.strip()  # remove leading spaces
            if not len(line):
                continue

            # Make sure memory locations line up before allocating memory for bytes
            #self.fix_current_location()

            # Label recognition
            if ':' in line:
                label = line[0:line.find(':')]
                self.symbol_table[label] = str(self.current_location)  # mapping labels to its location address
                line = line[line.find(':') + 1:].strip()  # get the instruction w/o the label

            # Make sure memory location lines up with divisions of 4
            #self.fix_current_location()

            # Parse instructions to establish mem size
            instruction = line[0:line.find(' ')]
            args = line[line.find(' ') + 1:].replace(' ', '').split(',')
            if not instruction:
                continue
            self.current_location += 4


    def second_pass(self, lines):
        ''' For second pass, we convert assembly to machine code'''


        self.current_location = self.default_mem_loc
        for line in lines:

            # Sanitize string (comments, whitespace, etc.)
            if '#' in line:
                line = line[0:line.find('#')]
            line = line.strip()
            if not len(line):
                continue

            # Make sure memory location lines up with divisions of word_size before storing bytes
            #self.fix_current_location()

            # Label ignorator
            if ':' in line:
                label = line[0:line.find(':')]
                line = line[line.find(':') + 1:].strip()
                #self.output_array.append('\n' + hex(int(self.symbol_table[label])) + ' <' + label + '>:')

            # Make sure memory locations line up after storing bytes
            #self.fix_current_location()

            # Parse the line!
            instruction = line[0:line.find(' ')].strip()
            args = line[line.find(' ') + 1:].replace(' ', '').split(',')

            if not instruction:
                continue

            # Create function code from instruction table
            if instruction in self.instruction_table.keys():
                self.parse_instruction(instruction, args)
            else:
                 #print("INSTRUCTION: " + instruction + " IS INVALID! ABORT")
                 exit()

        self.print_memory_map()

    def parse_instruction(self, instruction, raw_args):
        ''' Parses instruction, places proper hex into memory
            Different cases for R, I, J instructions
        '''


        machine_code = self.instruction_table[instruction]

        # parse arguments
        arg_count = 0
        offset = 'not_valid'
        args = raw_args[:]
        for arg in args:
            if '(' in arg:

                # Parse offset from known syntax
                offset = hex(int(arg[0:arg.find('(')]))
                register = re.search('\((.*)\)', arg)

                # Location in memory is offset from memory location
                location = self.register_table[register.group(1)]
                register = location

                # Finish processing args
                args[arg_count] = register

            elif arg in self.register_table.keys():
                # Replace symbol with value in table
                args[arg_count] = int(self.register_table[arg])
            elif arg in self.symbol_table:
                # Replace label with its value
                args[arg_count] = self.symbol_table[arg]
                # Increment argument counter for modifying list
            arg_count += 1

        # Branch instructions are all relative to location
        if (instruction == 'beq' or instruction == 'bne'):
            args[2] = (int(args[2]) - self.current_location-4 ) / 4
        # Jump instructions are all absolute divisions of 4 of the location (word loc)
        if (instruction == 'j' or instruction == 'jal' ):
            args[0] = str(int(int(args[0])/4))
        # Finally convert each value to hex
        for i in range(0, len(args)):
            arg=int(args[i])
            args[i] = str(hex(arg))

        # R instruction
        if len(machine_code) == 6:

            # initial r values
            rs = '0'
            rt = '0'
            rd = '0'
            # If jr syntax....
            if len(args) == 1:
                rs = args[0]
            else:
                # Set rs, rt, rd, and offset in the machine_code
                rd = args[0]
                rs = args[1]
                rt = args[2]

            machine_code[1] = rs
            machine_code[2] = rt
            machine_code[3] = rd
            machine_code[4] = '0'
            if instruction == 'sll' or instruction == 'srl':
                machine_code[4] = rt
                machine_code[2] = machine_code[1]
                machine_code[1] = '0'

            # Get binary of machine code
            op_binary = self.hex2bin(machine_code[0], 6)
            rs_binary = self.hex2bin(machine_code[1], 5)
            rt_binary = self.hex2bin(machine_code[2], 5)
            rd_binary = self.hex2bin(machine_code[3], 5)
            shamt_bin = self.hex2bin(machine_code[4], 5)
            funct_bin = self.hex2bin(machine_code[5], 6)

            # Create 32-bit string to divide up into bytes
            bit_string = op_binary + rs_binary + rt_binary + rd_binary + shamt_bin + funct_bin

            self.store_bit_string(bit_string, instruction, raw_args)

            return
        # I instruction
        if len(machine_code) == 4:

            # Set rs, rt, imm in the machine_code
            rs = args[1]
            rt = args[0]
            imm = offset

            # Is this one of the andi/addi no offset immediate syntaxes?
            if len(args) == 3:
                imm = hex(int(args[2], 16))

            # Is this one of the lui/li type no offset, no rs syntaxes?
            elif imm is 'not_valid':
                imm = args[1]
                rs = '0'

            machine_code[1] = rs
            machine_code[2] = rt
            machine_code[3] = imm

            # Get binary of machine code
            op_binary = self.hex2bin(machine_code[0], 6)
            rs_binary = self.hex2bin(machine_code[1], 5)
            rt_binary = self.hex2bin(machine_code[2], 5)
            im_binary = self.hex2bin(machine_code[3], 16)

            # Create 32-bit string to divide up into bytes
            bit_string = op_binary + rs_binary + rt_binary + im_binary

            self.store_bit_string(bit_string, instruction, raw_args)
            return
        # J instruction
        if len(machine_code) == 2:
            # Create hex machine code
            address = args[0]
            machine_code[1] = hex(int(address, 16))

            # Create binary bit string
            op_binary = self.hex2bin(machine_code[0], 6)
            address_binary = self.hex2bin(machine_code[1], 26)
            bit_string = op_binary + address_binary

            # Store bit string in memory
            self.store_bit_string(bit_string, instruction, raw_args)
            return

        return













    def hex2bin(self, hex_val, num_bits):
        ''' Returns binary string of num_bits length of hex value (pos or neg)
        '''


        # Adjust for negative by performing Two's Complement (tc)
        tc = False
        if '-' in hex_val:
            tc = True
            hex_val = hex_val.replace('-', '')

        bit_string = '0' * num_bits
        bin_val = str(bin(int(hex_val, 16)))[2:]
        bit_string = bit_string[0: num_bits - len(bin_val)] + bin_val + bit_string[num_bits:]

        # Two's complement if negative hex value
        if tc:
            tsubstring = bit_string[0:bit_string.rfind('1')]
            rsubstring = bit_string[bit_string.rfind('1'):]
            tsubstring = tsubstring.replace('1', 'X')
            tsubstring = tsubstring.replace('0', '1')
            tsubstring = tsubstring.replace('X', '0')
            bit_string = tsubstring + rsubstring

        return bit_string


    def bin2hex(self, bit_string):
        bit_string = '0b' + bit_string
        hex_string = str(hex(int(bit_string, 2)))[2:]
        hex_string = hex_string.zfill(2)
        return hex_string


    def store_bit_string(self, bit_string, instruction, arguments):
        ''' Store bit string into current memory block, divided into bytes
        '''


        # new word!
        '''if self.current_location % 4 == 0:
            # Format it nicely
            self.output_array.append(hex(self.current_location) + ':    0x')'''
        if self.current_location == 0:
            self.output_array = []
        if self.current_location % 4 == 0:
            # Format it nicely
            self.output_array.append('\n')

        for i in range(0, len(bit_string) - 1, 8):
            self.system_memory[self.current_location] = bit_string[i:i + 8]

            self.output_array[-1] += self.bin2hex(bit_string[i:i + 8])

            self.current_location += 1


        '''if self.current_location % 4 == 0:
            # Finish formatting nicely
            #self.output_array[-1] += '    ' + instruction.ljust(5) + ', '.join(arguments)'''#instruction assembly


    def print_memory_map(self):
        ''' Print memory map as it exists after allocation
        '''
        #print( "The memory map is:\n")
        keylist = self.system_memory.keys()
        '''for key in keylist:
            print ("%s: %s" % (key, self.system_memory[key]))'''

        '''#print("\nThe label list is: " + str(self.symbol_table))
        # print "\nThe current location is: " + str(self.current_location)
        #print( '\n\n')
        #print('The memory map in HEX:')'''
        file=open("test.hex","w")

        file.writelines(self.output_array)
        file.close()
        file = open("test.hex", "r")
        info=file.readlines()
        file.close()
        file2 = open("out.hex", "w")
        i=0
        for output in info:
            if i!=0:
                file2.write(output)
            i=i+1


        file2.close()



