# frozen_string_literal: true

require './parser'
require './code'
require './symbol_table'

# Assembler for nand2tetris course
class HackAssembler
  def initialize(parser = load_asm, code = Code.new)
    @parser = parser
    @code = code
    @symbol_table = build_symbol_table
  end

  def load_asm
    puts 'Please enter the relative file path of the .asm file to be assembled.'
    asm_file = '../pong/Pong.asm'.chomp
    Parser.new(asm_file)
  end

  def assemble
    Dir.mkdir('output') unless Dir.exist?('output')
    out_file = File.new("output/#{@parser.file_name}.hack", 'w')
    build_symbol_table
    @parser.second_parse
    cycle_through(out_file)
  end

  def cycle_through(out_file)
    @parser.commands.each do |line|
      type = @parser.command_type(line)
      out_file.puts "#{steer_type(line, type)}\n"
    end
  end

  def build_symbol_table
    symbol_table = SymbolTable.new
    symbol_table = build_symbol_table_first_pass(symbol_table)
    build_symbol_table_second_pass(symbol_table)
  end

  def build_symbol_table_first_pass(symbol_table)
    index = 0
    @parser.commands.each do |line|
      type = @parser.command_type(line)
      if type == 'L_COMMAND'
        symbol = @parser.symbol(line, 'l')
        symbol_table.add_entry(symbol, true, index)
      end
      index += 1 if type != 'L_COMMAND'
    end
    symbol_table
  end

  def build_symbol_table_second_pass(symbol_table)
    @parser.commands.each do |line|
      type = @parser.command_type(line)
      if type == 'A_COMMAND'
        symbol = @parser.symbol(line, 'a')
        symbol_table.add_entry(symbol, false) if symbol =~ /[a-zA-Z_.$:](\w|_.$:)*$/
      end
    end
    symbol_table
  end

  def steer_type(line, type)
    case type
    when 'A_COMMAND'
      a_command(line)
    when 'C_COMMAND'
      c_command(line)
    end
  end

  def a_command(line)
    @code.number(@parser.symbol(line, 'a'), @symbol_table)
  end

  def c_command(line)
    dest_binary = @code.dest(@parser.dest(line))
    comp_binary = @code.comp(@parser.comp(line))
    jump_binary = @code.jump(@parser.jump(line))
    "111#{comp_binary}#{dest_binary}#{jump_binary}"
  end
end

assembler = HackAssembler.new
assembler.assemble
