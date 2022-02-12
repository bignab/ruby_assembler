# frozen_string_literal: true

# Parser for the nand2tetris Hack Assembler
class Parser
  attr_reader :commands, :file_name

  def initialize(asm_file)
    @commands = initial_parse(asm_file)
    @file_name = File.basename(asm_file, '.*')
  end

  def initial_parse(asm_file)
    file = File.open(asm_file)
    file_data = file.readlines.map(&:chomp)
    file.close
    clean_data = []
    file_data.each do |line|
      clean_data.push(line) unless line.empty? || line[0..1] == '//'
    end
    scrub_comments(clean_data)
  end

  def scrub_comments(commands)
    scrubbed_data = []
    commands.each do |line|
      stripped_line = line.lstrip
      line_end = stripped_line.length
      line_end = stripped_line.index(' ') unless stripped_line.index(' ').nil?
      scrubbed_data.push(stripped_line[0, line_end])
    end
    scrubbed_data
  end

  def second_parse
    new_commands = []
    @commands.each do |line|
      new_commands.push(line) unless line[0] == '('
    end
    @commands = new_commands
  end

  def command_type(command)
    return 'A_COMMAND' if command =~ /@[a-zA-Z\d_.$:]+$/
    return 'C_COMMAND' if command =~ /([MDA]{1,3}={1}[01DAM!+&|-]{1,3}$)|([0D]{1};[JGTLEQTNMP]{3}$)/
    return 'L_COMMAND' if command =~ /[(][a-zA-Z\d_.$:]+[)]$/

    'INVALID'
  end

  def symbol(command, type)
    case type
    when 'a'
      value = command[1, command.length]
      return value if value =~ /^(\d+$)|(^[a-zA-Z_.$:]([a-zA-Z\d_.$:])+$)/
    when 'l'
      value = command[1, command.length - 2]
      return value if value =~ /[a-zA-Z_.$:](\w|_.$:)*$/
    end

    'INVALID'
  end

  def dest(c_command)
    mnemonics = %w[M D MD A AM AD AMD]
    index = c_command.rindex('=')
    target = c_command[0...index]
    mnemonics.each do |mnemonic|
      return target if target == mnemonic
    end
    'null'
  end

  def comp(c_command) # rubocop:disable Metrics/MethodLength
    mnemonics = ['0', '1', '-1', 'D', 'A', '!D', '!A', '-D', '-A', 'D+1', 'A+1', 'D-1', 'A-1', 'D+A', 'D-A',
                 'A-D', 'D&A', 'D|A', 'M', '!M', '-M', 'M+1', 'M-1', 'D+M', 'D-M', 'M-D', 'D&M', 'D|M']
    equals_index = c_command.index('=')
    semicolon_index = c_command.index(';')
    target = if equals_index.nil?
               c_command[0...semicolon_index]
             else
               c_command[equals_index + 1, c_command.length]
             end
    mnemonics.each do |mnemonic|
      return target if target == mnemonic
    end
    'null'
  end

  def jump(c_command)
    mnemonics = %w[JGT JEQ JGE JLT JNE JLE JMP]
    index = c_command.index(';')
    target = c_command[index + 1, c_command.length] unless index.nil?
    mnemonics.each do |mnemonic|
      return target if target == mnemonic && !index.nil?
    end
    'null'
  end
end
