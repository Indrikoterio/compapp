# Instructions Controller.
# Instructions are addresses, opcodes and operands for a simulated computer.
# Cleve Lendon, 2016

require './app/computer/computer'

class InstructionsController < ApplicationController

  COMPUTER_MEMORY_SIZE = 100

  def index

    @instruction = Instruction.new    # For adding new entries.

    # Sort address by reverse order. 0 at the bottom.
    @instructions = Instruction.all.sort_by { |one_hash| - one_hash[:address]}

    # Get the last program address, and increment it for the next instruction.
    last = LastAddress.first
    if last.nil?
      LastAddress.create(address: 0)
      @next_address = 0
    else
      @next_address = last.address + 1
    end

  end

  def new
    @instruction = Instruction.new
  end

  def edit
    @instruction = Instruction.find(params[:id])
  end

  def create
    @instruction = Instruction.new(instruction_params)
    if @instruction.save
      # Save the address of this instruction.
      last = LastAddress.first
      last.address = instruction_params[:address].to_i
      last.save
      redirect_to instructions_path      
    end
    # Else show errors.
  end

  def update
    @instruction = Instruction.find(params[:id])
    if @instruction.update(instruction_params)
      redirect_to instructions_path
    end
    # Else show errors.
  end



  # Get the program from the database, execute it with the Computer class,
  # and return the result to the main page.
  def execute

    computer = Computer.new(COMPUTER_MEMORY_SIZE)
    all_instr = Instruction.all

    # Need an array of hashes.
    # .as_json would be convenient but it converts the address field to string.
    program = Array.new
    all_instr.each do |h|
      instr = {:address => h[:address], :opcode => h[:opcode], :operand => h[:operand]}
      # For testing, introduce an error.
      #if (instr[:opcode] == 'PUSH')
      #  instr[:opcode] = "PSH"
      #  instr[:operand] = Computer::MIN_INTEGER + 1
      #end
      program << instr
    end

    # Loading or execution may raise errors.
    begin
      computer.load(program)
      computer.execute
      # Must replace \n with <br> for html.
      @results = computer.output.gsub("\n", "<br>")
    rescue => e
      @results = e.message
    end

  end

  def delete
    @instruction = Instruction.find(params[:instruction_id])
  end

  def destroy
    @instruction = Instruction.find(params[:id])
    @instruction.destroy
    redirect_to instructions_path
  end

private

  def instruction_params
    params.require(:instruction).permit(:address, :opcode, :operand)
  end

end
