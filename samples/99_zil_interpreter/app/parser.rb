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

  def initialize
    @expressions = []
  end

  def parse_file(args, work_dir, file_name)
    @work_dir = work_dir # not sure if we need work_dir, the idea was to follow INSERT-FILEs inside the parser/scanner

    file = args.gtk.read_file(@work_dir + file_name)
    log "Opening '" + file_name + "' ..."

    buffer = ""
    file.each_line.each { |line|
      line.each_char { |c| buffer << c }
    }

    log "Scanning '" + file_name + "' ..."
    scanner = Scanner.new(buffer)

    i = 0
    while scanner.scan_to('<;"%') # find next form, string, or comment
      expr = scanner.read_expression
      @expressions << expr
      log "[#{file_name}:#{i}] " + expr.to_s
      i += 1
    end

    log "Scan completed."
  end

  def parse_string(args, buffer)
    log "Scanning buffer ..."
    scanner = Scanner.new(buffer)

    i = 0
    while scanner.scan_to('<;"%') # find next form, string, or comment
      expr = scanner.read_expression
      @expressions << expr
      log "[BUFFER:#{i}] " + expr.to_s
      i += 1
    end

    log "Scan completed."
  end
end

# This class can probably be reworked into Parser:
#
# Usage:
#   scanner = Scanner.new(buffer)
#   while scanner.scan_to('<;"%') # find next form, string, or comment
#     expr = scanner.read_expression
#   end
#
class Scanner
  ATOM_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-+*/?=.,!$"
  FIX_CHARS = '0123456789*#' # * = octal, #2 = binary
  WHITESPACE_CHARS = " \r\n\t"

  def initialize(buffer)
    @buffer = buffer
    @expr_depth = 0
    @list_depth = 0
    reset
  end

  def reset
    @buf_index = -1
  end

  def scan_to(scan_chars)
    found = false

    while @buf_index < @buffer.length - 1
      @buf_index += 1
      buf_char = @buffer[@buf_index]

      if scan_chars.include?(buf_char)
        found = true
        break
      end

    end

    found
  end

  def skip_whitespace
    done = false

    until done
      break if @buf_index >= @buffer.length

      c = @buffer[@buf_index]
      if WHITESPACE_CHARS.include?(c) == false
        done = true
        break
      end
      @buf_index += 1
    end
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

  def is_fix?(char)
    return false if char.nil?

    if FIX_CHARS.include?(char)
      true
    else
      false
    end
  end

  def read_atom
    atom = ""

    while @buf_index < @buffer.length - 1 # iterate characters in line
      buf_char = @buffer[@buf_index]
      @buf_index += 1

      if buf_char == '\\' # observed in this--> <STRING !\" !,WBREAKS>
        next_char = peek
        if next_char == '"'
          atom += read_char
        end
      elsif ATOM_CHARS.include?(buf_char)
        atom += buf_char
      else
        @buf_index -= 1
        break
      end
    end

    atom.to_sym
  end

  def read_char
    char = @buffer[@buf_index]
    @buf_index += 1
    char
  end

  def read_comment
    # read comment char, then read the expresson that follows
    semi = read_char # read in ;
    comment = read_expression # read commented out stuff and ignore

    Syntax::Comment.new(comment)
  end

  # %<...>
  def read_cond_macro
    pct_char = read_char # read '%'
    expr = read_expression # read '<...>'

    Syntax::Macro.new(expr)
  end

  def read_decl
    hashtag = read_char # read #
    decl = read_atom # read DECL
    skip_whitespace
    list = read_list

    Syntax::Decl.new(*list)
  end

  def read_expression
    debug_flag = false
    @expr_depth += 1
    raise "Expression recursion overflow" if @expr_depth > 50

    expr_char = peek
    if expr_char == '<' #  Starts with '<' then read_form
      log "+ FORM " if debug_flag
      expr = read_form
    elsif expr_char == '(' #  Starts with '(' then read_list
      log "+ LIST " if debug_flag
      expr = read_list
    elsif expr_char == '"' #  Starts with '"' then read_string
      log "+ STRING " if debug_flag
      expr = read_string
    elsif expr_char == ';' #  Starts with ';' then read_comment
      log "+ COMMENT " if debug_flag
      expr = read_comment
    elsif expr_char == '#' && peek_string(5) == '#DECL'
      log "+ DECL " if debug_flag
      expr = read_decl
    elsif expr_char == '%' && peek_string(6) == '%<COND'
      log "+ COND MACRO " if debug_flag
      expr = read_cond_macro
    elsif expr_char == "'"
      log "+ MACRO " if debug_flag
      expr = read_macro
    elsif is_fix?(expr_char) # Starts with 0123456789 then read_fix
      log "+ FIX " if debug_flag
      expr = read_fix
    else
      #  else read atom
      log "+ ATOM " if debug_flag
      expr = read_atom
    end

    @expr_depth -= 1
    expr
  end

  def read_fix
    # UC1: 123456
    # UC2: *3777*
    # UC3: #2 0111

    fix = ""

    # step 1: just load the string based on the three types
    while @buf_index < @buffer.length - 1 # iterate characters in line
      buf_char = @buffer[@buf_index]
      @buf_index += 1

      if FIX_CHARS.include?(buf_char)
        #log "[TMP] " + buf_char
        fix += buf_char
      elsif buf_char == " " && fix == '#2'
        fix += buf_char
      else
        @buf_index -= 1
        break
      end
    end

    # step 2: convert to number
    if fix.start_with?('*')
      fix = fix.gsub('*', '')
      fix = fix.to_i(base=8)
    elsif fix.start_with?('#2')
      fix = fix.gsub('#2 ', '')
      fix = fix.to_i(base=2)
    else
      fix = fix.to_i
    end

    fix
  end

  # <...>
  def read_form
    lt = read_char # 1) Read '<'
    atom = read_atom # 2) Read atom
    skip_whitespace # 3) Skip whitespace

    # 4) Read params (form, list, string, fix)
    expr = []
    last_buf_index = -1 # make sure we don't get into an endless loop
    done = false
    until done
      if @buf_index == last_buf_index # endless loop detected
        log "ENDLESS at '" + peek + "'"
        raise "ENDLESS"
      end

      last_buf_index = @buf_index

      ft = peek
      if ft == '>' # handle special case of empty form
        done = true
      else
        expr << read_expression
        #log expr[expr.length - 1]
      end

      skip_whitespace
    end

    gt = read_char # 5) Read '>'

    if atom.length == 0 && expr.length == 0
      Syntax::Form.new # empty Form
    elsif atom.length != 0 && expr.length == 0
      Syntax::Form.new(atom) # atom with no params
    else
      Syntax::Form.new(*[atom, *expr]) # atom and params
    end
  end

  # (...)
  def read_list
    @list_depth += 1
    raise "List overflow" if @list_depth > 50

    lparen = read_char # read '('

    # read contents
    list = []
    next_char = peek
    while next_char != ")"
      list << read_expression
      skip_whitespace
      next_char = peek
    end

    rparen = read_char # read ')'

    @list_depth -= 1
    Syntax::List.new(*list)
  end

  # '<...>
  def read_macro
    squot = read_char # read '
    expr = read_expression # read '<...>'

    Syntax::Quote.new(expr)
  end

  def read_string
    quot = read_char # read '"'

    s = ""
    # read contents
    while @buf_index < @buffer.length - 1 # iterate characters in line
      buf_char = @buffer[@buf_index]
      @buf_index += 1

      # levi use case \' (don't see in ZIL files currently)
      if buf_char == '\\'
        next_char = peek
        if next_char == '"'
          s += read_char
        end
      elsif buf_char != '"'
        s += buf_char
      else
        @buf_index -= 1
        break
      end
    end

    quot = read_char # read '"'
    s
  end

end