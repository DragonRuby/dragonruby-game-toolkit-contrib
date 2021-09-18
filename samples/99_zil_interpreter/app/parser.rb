# Parser class uses the scanner to load from file or string buffer. Results are loaded into expressions.
#
# Usage:
#   source = "<ZIL ()>"
#   parser.parse_string(args, source)
#   expr0 = parser.expressions[0]
#
#   OR
#
#   parser.parse_file(args, '/data/zil/zork1/', 'zork1.zil')
#   expr0 = parser.expressions[0]
#
class Parser
  attr_reader :expressions
  attr_accessor :log_flag

  def self.parse_string(string)
    parser = new
    parser.parse_string(string)
    parser.expressions
  rescue RuntimeError => e
    raise ParserError, e.to_s
  end

  def initialize
    @expressions = []
    @debug_name = "BUFFER"
    @log_flag = true
  end

  def parse_file(work_dir, file_name)
    @work_dir = work_dir # not sure if we need work_dir, the idea was to follow INSERT-FILEs inside the parser/scanner
    @debug_name = file_name

    log "Opening '" + file_name + "' ..." if @log_flag
    buffer = $gtk.read_file(@work_dir + file_name)
    raise "Empty/Missing file! (#{@work_dir}#{file_name})" if buffer.nil? || buffer.length == 0
    parse_string(buffer)
  end

  def parse_string(buffer)
    log "Parsing ..." if @log_flag
    scanner = Scanner.new(buffer)

    i = 0
    while scanner.scan_to('<;"%') # find next form, string, or comment
      expr = scanner.read_expression
      @expressions << expr
      log "[#{@debug_name}:#{i}] " + expr.to_s if @log_flag
      i += 1
    end

    log "Parse completed." if @log_flag
  end
end

class ParserError < StandardError; end

# This class can probably be reworked into Parser
#
# Usage:
#   scanner = Scanner.new(buffer)
#   while scanner.scan_to('<;"%') # find next form, string, or comment
#     expr = scanner.read_expression
#   end
#
class Scanner
  ATOM_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-+*/?=.,!$&_"
  FIX_CHARS = '0123456789*#' # * = octal, #2 = binary
  WHITESPACE_CHARS = " \r\n\t"

  def initialize(buffer)
    @buffer = buffer
    @expr_depth = -1
    reset
  end

  def reset
    @buf_index = -1
    @line_num = 0
    @line_pos = 0
  end

  def scan_to(scan_chars)
    found = false

    while @buf_index < @buffer.length - 1
      buffer_advance
      buf_char = peek

      if scan_chars.include?(buf_char)
        found = true
        break
      end

    end

    found
  end

  def buffer_advance
    char = peek
    if char == "\n"
      @line_num += 1
      @line_pos = 0
    end

    @buf_index += 1
    @line_pos += 1
  end

  def buffer_previous
    @buf_index -= 1
    @line_pos -= 1

    char = peek
    if char == "\n"
      @line_num -= 1
      @line_pos = 0
    end
  end

  def indent(width)
    str = ""
    width.times do str += "  " end
    str
  end

  def peek
    @buffer[@buf_index]
  end

  def peek_next
    @buffer[@buf_index + 1]
  end

  def peek_string(num)
    str = ""

    i = 0
    while i < num
      str += @buffer[@buf_index + i]
      i += 1
    end

    str
  end

  def is_fix?(char, next_char)
    return false if char.nil?

    if char == '*' && FIX_CHARS.include?(next_char) == false # make sure this isn't the multiply operator ('*' followed by whitespace)
      false
    elsif next_char == '?' # special case for 0? and 1? atoms
      false
    elsif FIX_CHARS.include?(char)
      true
    else
      false
    end
  end

  # ,ATOM
  def read_alias_gval
    skip_char(',')
    expr = read_expression

    Syntax::Form.new(:GVAL, expr)
  end

  # .ATOM
  def read_alias_lval
    skip_char('.')
    expr = read_expression

    Syntax::Form.new(:LVAL, expr)
  end

  def read_atom
    atom = ""

    while @buf_index < @buffer.length - 1
      buf_char = peek
      buffer_advance

      if buf_char == '\\'
        atom += read_char
      elsif ATOM_CHARS.include?(buf_char)
        atom += buf_char
      else
        buffer_previous
        break
      end
    end

    raise "Invalid syntax at #{@line_num}:#{@line_pos}!" if atom.length == 0

    atom.to_sym
  end

  # [start]...[end]
  def read_bracket_expression(start_bracket, end_bracket, output_class)
    skip_whitespace
    skip_char(start_bracket)
    skip_whitespace

    # read contents
    expr = []
    next_char = peek
    while next_char != end_bracket
      expr << read_expression
      skip_whitespace
      next_char = peek
    end

    skip_char(end_bracket)

    output_class.new(*expr)
  end

  def read_char
    char = peek
    buffer_advance
    char
  end

  # !\.
  def read_character
    skip_char('!')
    skip_char('\\')
    read_char
  end

  # ;...
  def read_comment
    # read comment char, then read the expresson that follows
    skip_char(';') # read in ;
    skip_whitespace
    comment = read_expression # read commented out stuff and ignore

    Syntax::Comment.new(comment)
  end

  # #DECL(...)
  def read_decl
    skip_char('#') # read #
    skip_atom(:DECL) # read DECL

    list = read_list
    raise "DECL inner list is empty!" if list.elements.length < 1

    Syntax::Decl.new(list)
  end

  # #BYTE
  def read_byte
    skip_char('#') # read #
    skip_atom(:BYTE) # read BYTE
    skip_whitespace

    expression = read_expression

    Syntax::Byte.new(expression)
  end

  def read_expression
    debug_flag = false
    @expr_depth += 1
    raise "Expression recursion overflow" if @expr_depth > 50

    expr_char = peek
    if expr_char == '<' #  Starts with '<' then read_form
      log indent(@expr_depth) + "+ FORM " if debug_flag
      expr = read_form
    elsif expr_char == '(' #  Starts with '(' then read_list
      log indent(@expr_depth) + "+ LIST " if debug_flag
      expr = read_list
    elsif expr_char == '"' #  Starts with '"' then read_string
      log indent(@expr_depth) + "+ STRING " if debug_flag
      expr = read_string
    elsif expr_char == '!'
      if peek_next == '\\' #  Starts with '!\' then read_character
        log indent(@expr_depth) + "+ CHARACTER " if debug_flag
        expr = read_character
      else #  Starts with '!' then read_segment
        log indent(@expr_depth) + "+ SEGMENT " if debug_flag
        expr = read_segment
      end
    elsif expr_char == '[' #  Starts with '[' then read_vector
      log indent(@expr_depth) + "+ VECTOR " if debug_flag
      expr = read_vector
    elsif expr_char == ';' #  Starts with ';' then read_comment
      log indent(@expr_depth) + "+ COMMENT " if debug_flag
      expr = read_comment
    elsif expr_char == '#' && peek_string(5) == '#DECL' # MDL also has FUNCTION (not implemented in ZIL)
      log indent(@expr_depth) + "+ DECL " if debug_flag
      expr = read_decl
    elsif expr_char == '#' && peek_string(5) == '#BYTE'
      log indent(@expr_depth) + "+ BYTE " if debug_flag
      expr = read_byte
    elsif expr_char == '%' && peek_string(6) == '%<COND' # % is MACRO in MDL. ZIL only uses <COND after (being cautious)
      log indent(@expr_depth) + "+ MACRO " if debug_flag
      expr = read_macro
    elsif expr_char == "'"
      log indent(@expr_depth) + "+ QUOTE " if debug_flag
      expr = read_quote
    elsif expr_char == ","
      log indent(@expr_depth) + "+ GVAL " if debug_flag
      expr = read_alias_gval
    elsif expr_char == "."
      log indent(@expr_depth) + "+ LVAL " if debug_flag
      expr = read_alias_lval
    elsif is_fix?(expr_char, peek_next) # Starts with 0123456789 then read_fix
      log indent(@expr_depth) + "+ FIX " if debug_flag
      expr = read_fix
    else
      #  else read atom
      log indent(@expr_depth) + "+ ATOM " if debug_flag
      expr = read_atom
    end

    @expr_depth -= 1
    expr
  end

  # 123456
  # *3777*
  # #2 0111
  def read_fix
    fix = ""

    # step 1: just load the string based on the three types
    while @buf_index < @buffer.length - 1 # iterate characters in line
      buf_char = peek
      buffer_advance

      if FIX_CHARS.include?(buf_char)
        #log "[TMP] " + buf_char
        fix += buf_char
      elsif buf_char == " " && fix == '#2'
        fix += buf_char
      else
        buffer_previous
        break
      end
    end

    # step 2: convert to number
    if fix.start_with?('*')
      fix = fix.gsub('*', '').to_i(base=8)
    elsif fix.start_with?('#2')
      fix = fix.gsub('#2 ', '').to_i(base=2)
    else
      fix = fix.to_i
    end

    fix
  end

  # <...>
  def read_form
    read_bracket_expression('<', '>', Syntax::Form)
  end

  # (...)
  def read_list
    read_bracket_expression('(', ')', Syntax::List)
  end

  # %...
  def read_macro
    skip_char('%') # read '%'
    expr = read_expression # read '<...>'

    Syntax::Macro.new(expr)
  end

  # '...
  def read_quote
    skip_char("'")
    expr = read_expression # read '<...>'

    Syntax::Quote.new(expr)
  end

  # !...
  def read_segment
    skip_char('!')
    expr = read_expression

    Syntax::Segment.new(expr)
  end

  # "..."
  def read_string
    skip_char('"') # read '"'

    s = ""
    # read contents
    while @buf_index < @buffer.length - 1 # iterate characters in line
      buf_char = peek
      buffer_advance

      # levi use case \' (don't see in ZIL files currently)
      if buf_char == '\\'
        next_char = peek
        if next_char == '"'
          s += read_char
        end
      elsif buf_char != '"'
        s += buf_char
      else
        buffer_previous
        break
      end
    end

    skip_char('"') # read '"'

    s
  end

  # [...]
  def read_vector
    read_bracket_expression('[', ']', Syntax::Vector)
  end

  def skip_atom(expected)
    atom = read_atom
    raise "Expected: '#{expected}' (#{expected.class.name}), Found: '#{atom}' (#{atom.class.name}) at #{@line_num}:#{@line_pos}" if atom != expected
  end

  def skip_char(expected)
    char = read_char
    raise "Expected: '#{expected}', Found: '#{char}' at #{@line_num}:#{@line_pos}" if char != expected
  end

  def skip_whitespace
    raise "Unexpected end of file!" unless @buf_index < @buffer.length

    loop do
      break if @buf_index >= @buffer.length || WHITESPACE_CHARS.include?(peek) == false
      buffer_advance
    end
  end

end
