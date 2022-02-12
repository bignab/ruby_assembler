# frozen_string_literal: true

# Symbol table for nand2tetris assembler.
class SymbolTable
  def initialize
    @table = create_table
    @var_index = 16
  end

  def create_table
    { 'SP' => 0, 'LCL' => 1, 'ARG' => 2, 'THIS' => 3, 'THAT' => 4, 'R0' => 0,
      'R1' => 1, 'R2' => 2, 'R3' => 3, 'R4' => 4, 'R5' => 5, 'R6' => 6,
      'R7' => 7, 'R8' => 8, 'R9' => 9, 'R10' => 10, 'R11' => 11, 'R12' => 12,
      'R13' => 13, 'R14' => 14, 'R15' => 15, 'SCREEN' => 16_384, 'KBD' => 24_576 }
  end

  def add_entry(symbol, rom, address = @var_index)
    unless contains(symbol)
      @table[symbol] = address
      @var_index += 1 if rom == false
    end
  end

  def contains(symbol)
    @table.include?(symbol)
  end

  def address(symbol)
    @table[symbol].to_s(2)
  end
end
