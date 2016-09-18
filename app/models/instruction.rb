# This file contains the Instruction model and validator.
# An Instruction consists of an address, opcode and operand.
# Cleve Lendon 2016


#-------------------------------------------------
# The validation for the Instruction model class is not simple.
# The opcode must be valid.
# Some opcodes require an operand, which must be valid.
# When creating a new record, ensure that the address is valid and not occupied.

class InstructionValidator < ActiveModel::Validator

  def validate(record)

    address    = record[:address]
    address_b4 = record.address_before_type_cast

    opcode     = record[:opcode]

    operand    = record[:operand]
    operand_b4 = record.operand_before_type_cast

    # Validate opcode.
    if (opcode.nil? || opcode.empty?)
      record.errors[:base] << "Please enter an opcode. Valid opcodes are:"
      record.errors[:base] << Computer::INSTRUCTION_SET.join(' ')
    elsif (!Computer::INSTRUCTION_SET.include? opcode)
      record.errors[:base] << "Invalid opcode: #{opcode}. Valid opcodes are:"
      record.errors[:base] << Computer::INSTRUCTION_SET.join(' ')
    end

    # Validate operand.
    if (Computer::REQUIRE_OPERAND.include? opcode)
      if (operand.nil?)
        record.errors[:base] << "This operation requires an integer operand."
      elsif !(operand_b4 =~ /\A[-+]?\d+\Z/)
        record.errors[:base] << "This operation requires an integer operand."
      elsif (operand > Computer::MAX_INTEGER)
        record.errors[:base] << "Operand must be less than #{Computer::MAX_INTEGER + 1}."
      elsif (operand < Computer::MIN_INTEGER)
        record.errors[:base] << "Operand must be greater than #{Computer::MIN_INTEGER - 1}."
      end
    else
      record[:operand] = ""
    end

   # Validate address if this is a new record.
   if (record[:created_at].nil?)  # Is this new?
     if (address_b4.empty?)
        record.errors[:base] << "Please enter a valid address."
     elsif !(address_b4 =~ /\A[+]?\d+\Z/)
       record.errors[:base] << "The address must be a positive integer."
     elsif (address >= InstructionsController::COMPUTER_MEMORY_SIZE)
       record.errors[:base] <<
               "The address must be less than #{InstructionsController::COMPUTER_MEMORY_SIZE}"
     else
        Instruction.all.each do |instr|
          if (address == instr.address)
            record.errors[:base] << "An instruction already exists at #{address}. Please use Edit."
            break;
          end
        end
     end
   end

  end  # validate()

end  # InstructionValidator


#-------------------------------------------------
# Instruction model class.

class Instruction < ApplicationRecord

  validates_with InstructionValidator

  before_validation :up_case

  def up_case
    opcode.upcase!
  end

end


