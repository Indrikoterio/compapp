# File:  tc_computer.rb

require "../app/computer/computer"
require "test/unit"
 
class TestComputer < Test::Unit::TestCase

  MEMORY_SIZE = 10

  def setup
    @computer = Computer.new(MEMORY_SIZE)
  end

  def teardown
  end

  def test_set_address
    assert_raises(ArgumentError) { @computer.set_address(1.1) }
    assert_raises(ArgumentError) { @computer.set_address("Hello") }
    assert_raises(ArgumentError) { @computer.set_address(-1) }
    assert_raises(ArgumentError) { @computer.set_address(MEMORY_SIZE) }
    assert_nothing_raised { @computer.set_address(0) }
    assert_nothing_raised { @computer.set_address(MEMORY_SIZE - 1) }
  end

  def test_insert
    assert_raises(ArgumentError) { @computer.insert }
    assert_raises(ArgumentError) { @computer.insert(1, 2, 3) }
    assert_raises(ArgumentError) { @computer.insert("HELLO") }
    assert_raises(ArgumentError) { @computer.insert("MULT", 4) }
    assert_raises(ArgumentError) { @computer.insert("CALL") }
    assert_nothing_raised do
      @computer.set_address(0)
      @computer.insert("MULT")
      @computer.insert("CALL", 3)
      @computer.insert("RET")
      @computer.insert("STOP")
      @computer.insert("PRINT")
      @computer.insert("PUSH", 10)
    end
    assert_nothing_raised do
      @computer.insert("PUSH", Computer::MAX_INTEGER)
      @computer.insert("PUSH", Computer::MIN_INTEGER)
    end
    assert_raises(ArgumentError) do
      @computer.insert("PUSH", Computer::MAX_INTEGER + 1)
      @computer.insert("PUSH", Computer::MIN_INTEGER - 1)
    end
  end

  def test_memory_overflow
    assert_nothing_raised do
      @computer.set_address(MEMORY_SIZE - 1)
      @computer.insert("CALL", 0)
    end
    assert_raises(ArgumentError) do
      @computer.insert("CALL", -1)
      @computer.insert("CALL", MEMORY_SIZE + 1)
    end
  end

  # Test bad calls and returns. Must not jump to an invalid address.
  def test_call_ret
    assert_raises(RuntimeError) do
      @computer.set_address(0).insert("PUSH", MEMORY_SIZE - 1).insert("RET").execute
    end
    assert_raises(RuntimeError) do
      @computer.set_address(0).insert("CALL", MEMORY_SIZE - 1).execute
    end
  end

  # Test if the result of multiplication is too large.
  def test_mult_overflow
    assert_raises(RuntimeError) do
      @computer.set_address(0).insert("PUSH",
           Computer::MAX_INTEGER).insert("PUSH", Computer::MIN_INTEGER)
           .insert("MULT").insert("STOP").execute
    end
  end

  # Ensure that program execution returns expected results.
  PRINT_TENTEN_BEGIN = 50
  MAIN_BEGIN = 0
  def test_execution
    # We need a bigger program space for this test.
    computer = Computer.new(100)
    expected_result = "1009\n1010\n"
    # Instructions for the print_tenten function
    computer.set_address(PRINT_TENTEN_BEGIN).insert("MULT").insert("PRINT").insert("RET")
    # The start of the main function
    computer.set_address(MAIN_BEGIN).insert("PUSH", 1009).insert("PRINT")
    # Return address for when print_tenten function finishes
    computer.insert("PUSH", 6)
    # Setup arguments and call print_tenten
    computer.insert("PUSH", 101).insert("PUSH", 10).insert("CALL", PRINT_TENTEN_BEGIN)
    # Stop the program
    computer.insert("STOP")
    computer.set_address(MAIN_BEGIN).execute()
    assert_equal(expected_result, computer.output)
  end

end