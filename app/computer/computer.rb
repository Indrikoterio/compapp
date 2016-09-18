#-------------------------------------------------------
# Computer
#
# A simple simulated computer. This program writes instructions
# to a simulated memory (instruction_memory), and executes them.
# The instruction set is: MULT, CALL, RET, STOP, PRINT, PUSH
#
# Instruction memory - an array
# data_stack - a LIFO stack
# Assumptions: operands are integers only
#
# Cleve Lendon 2016


#-------------------------------------------------------
# Operation
# This class represents one machine instruction.
# Eg:  PUSH 7
#
# Note: This class is called Operation to avoid
# conflict with a db model class called Instruction.
# Don't confuse.
class Operation
  attr_accessor  :opcode, :operand
  def initialize(opcode, operand = 0)
    @opcode   = opcode
    @operand  = operand
  end
end


#-------------------------------------------------------
# Computer  - main class
#
class Computer

  # SQLITE3 has 64 bit integers.
  #MAX_INTEGER =  9223372036854775807   # 2^63 - 1
  #MIN_INTEGER = -9223372036854775808   # - 2^63

  # ActiveRecord defines integers as 4 bytes by default.
  MAX_INTEGER =  2147483647
  MIN_INTEGER = -2147483648

  INSTRUCTION_SET = %w(MULT CALL RET STOP PRINT PUSH)
  REQUIRE_OPERAND = %w(CALL PUSH)

  attr_accessor :output

  @program_counter = 0
  @insert_address = 0

  def initialize(memory_size = 100)
    @memory_size = memory_size
    @instruction_memory = Array.new(memory_size)
    @data_stack = Array.new
    @output = ""
  end


  # Set the address for the insert function.
  def set_address(addr)
    @insert_address = addr  if valid_address?(addr)
    return self
  end

  # Insert one operation and argument (if required) into the instruction memory.
  def insert(*args)

    raise ArgumentError, "#{@insert_address}: Too many arguments." if args.length > 2
    raise ArgumentError, "#{@insert_address}: Missing argument." if args.length == 0
    opcode = args[0]
    raise ArgumentError,
            "#{@insert_address}: Invalid instruction: #{opcode}" unless INSTRUCTION_SET.include?(opcode)

    if REQUIRE_OPERAND.include?(opcode)
      raise ArgumentError,
            "#{@insert_address}: The instruction '#{opcode}' requires an operand." if args.length != 2
      operand = args[1]
      # Check validity of operands.
      if (opcode == 'CALL')
        if (valid_address?(operand))
          instruction = Operation.new(opcode, operand)
        end
      elsif (opcode == 'PUSH')
        if (valid_operand?(operand))
          instruction = Operation.new(opcode, operand)
        end
      end
    else
      raise ArgumentError,
            "#{@insert_address}: The instruction '#{opcode}' does not take an operand." if args.length == 2
      instruction = Operation.new(opcode)
    end

    # Write to instruction to memory if there is room.
    if (@insert_address + 1 <= @memory_size)
      @instruction_memory[@insert_address] = instruction
      @insert_address += 1
    else
      raise "#{@insert_address}: Program memory overflow. Max size: #{@memory_size}."
    end

    return self
  end


  # Load a program into instruction_memory.
  # Params:  instructions - an array of hashes
  # Typical input:
  #     [{:address => 10, :opcode => 'CALL', :operand => 7}, ...]
  def load(instructions)
    @output = ""
    instructions.each do |i|
      set_address(i[:address])
      opcode = i[:opcode]
      if REQUIRE_OPERAND.include? opcode
        operand = i[:operand]
        insert(opcode, operand)
      else
        insert(opcode)
      end
    end
  end


  # Execute the program.
  def execute

    #puts "Instruction memory:\n#{@instruction_memory}"
    @program_counter = get_start_address
    operand = 0
    @output = ""

    @running = true
    while @running do

      instruction = @instruction_memory[@program_counter]
      break if (instruction.nil?)

      @program_counter += 1

      case instruction.opcode
        when 'MULT'
          exec_mult
        when 'CALL'
          exec_call(instruction.operand)
        when 'RET'
          exec_ret
        when 'STOP'
          exec_stop
        when 'PRINT'
          exec_print
        when 'PUSH'
          exec_push(instruction.operand)
      end
    end
    print @output
    return self
  end   # execute

private

  # get_start_address - (the lowest address)
  # Raise an error if there are no instructions.
  # Return the lowest address.
  def get_start_address
    lowest = 0
    found = false   # At least one instruction found.
    @instruction_memory.each_with_index do |instr, index|
       next if instr.nil?
       lowest = index
       found = true
       break
    end
    raise "There are no instructions to execute." if found == false
    lowest
  end

  # MULT: Pop the 2 arguments from the stack, multiply them
  # and push the result back to the stack
  def exec_mult
    #Need two parameters.
    param1 = pop_data
    param2 = pop_data
    result = param1 * param2
    if number_range_ok?(result)
      push_data(result)
    end
  end

  # CALL addr: Set the program counter (PC) to addr.
  def exec_call(addr)
    if call_ret_ok?(addr)
      @program_counter = addr
    end
  end

  # RET: Pop address from stack and set PC to address.
  def exec_ret
    addr = pop_data
    if call_ret_ok?(addr)
      @program_counter = addr
    end
  end

  # STOP: Exit the program.
  def exec_stop
    @running = false
  end

  # PRINT: Pop value from stack and print it (to @output).
  def exec_print
    data = pop_data
    @output << "#{data}\n"
  end

  # PUSH arg: Push argument to the stack.
  def exec_push(arg)
    push_data(arg)
  end


  # Push data onto the data stack
  # Param: An integer.
  def push_data(num)
    @data_stack.push num
  end

  # Pop data from the data stack.
  # Returns: value from top of stack
  # Raise Error if stack is empty.
  def pop_data
    data = @data_stack.pop
    if data.nil? then raise "#{@program_counter - 1}: Data stack is empty." end
    data
  end

  # Check to ensure that the address is within the program space.
  def valid_address?(addr)
    raise ArgumentError, "#{@insert_address}: Address must be an integer: #{addr}" unless addr.is_a? Integer
    raise ArgumentError, "#{@insert_address}: Address must not be negative: #{addr}" if addr < 0
    raise ArgumentError, "#{@insert_address}: Address must be less than #{@memory_size}: #{addr}" if addr >= @memory_size
    return true
  end

  # Check to ensure that the operand is a valid integer.
  def valid_operand?(num)
    raise ArgumentError, "#{@insert_address}: Operand must be an integer: #{num}" unless num.is_a? Integer
    raise ArgumentError, "#{@insert_address}: Operand is too large (> #{MAX_INTEGER}): #{num}" if num > MAX_INTEGER
    raise ArgumentError, "#{@insert_address}: Operand is too small (< #{MIN_INTEGER}): #{num}" if num < MIN_INTEGER
    return true
  end


  # CALL or RET address OK?
  # This is a runtime check.
  # Must not set the program counter to an address which is not defined.
  # Return true if OK. Else raise error.
  def call_ret_ok?(addr)
    if @instruction_memory[addr].nil?
      raise "#{@program_counter - 1}: Attempting to go to an invalid address: #{addr}"
    end
    return true
  end

  # Number range ok?
  # Used to check the result of multiplication.
  # This is a runtime check.
  def number_range_ok?(num)
    raise "#{@program_counter - 1}: Result is too large (> #{MAX_INTEGER}): #{num}" if num > MAX_INTEGER
    raise "#{@program_counter - 1}: Result is too small (< #{MIN_INTEGER}): #{num}" if num < MIN_INTEGER
    return true
  end

end # Computer



if __FILE__ == $0 then


  PRINT_TENTEN_BEGIN = 50
  MAIN_BEGIN = 0

  def main

    # Create new computer with a stack of 100 addresses
    computer = Computer.new(100)

    # Instructions for the print_tenten function
    computer.set_address(PRINT_TENTEN_BEGIN).insert("MULT").insert("PRINT").insert("RET")

    # The start of the main function
    computer.set_address(MAIN_BEGIN).insert("PUSH", 1009).insert("PRINT")

    # Return address for when print_tenten function finishes.
    computer.insert("PUSH", 6)

    # Setup arguments and call print_tenten
    computer.insert("PUSH", 101).insert("PUSH", 10).insert("CALL", PRINT_TENTEN_BEGIN)

    # Stop the program
    computer.insert("STOP")
    computer.set_address(MAIN_BEGIN).execute()

  end

  main()


end
