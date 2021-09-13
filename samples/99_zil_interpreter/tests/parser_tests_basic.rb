# test basic SETG command with STRING and FIX
# -----------------------------------------
def test_parser_01(args, assert)
  source = <<-ZIL
<SETG ZORK-NUMBER 1>
  ZIL

  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :SETG,
    :"ZORK-NUMBER",
    1)

  assert.equal! parsed, expected
end

# test character
# -----------------------------------------
def test_parser_02(args, assert)
  # need to escape backslash in HEREDOC to get correct result
  source = <<-ZIL
<STRING !\\" !,WBREAKS>
  ZIL

  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :STRING,
    '"',
    Syntax::Segment.new(Syntax::Form.new(:GVAL, :WBREAKS))
  )

  assert.equal! parsed, expected
end

# test nested forms and character
# -----------------------------------------
def test_parser_03(args, assert)
  # need to escape backslash to get correct result
  source = <<-ZIL
<OR <GASSIGNED? ZILCH>
    <SETG WBREAKS <STRING !\\" !,WBREAKS>>>
  ZIL

  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :OR,
    Syntax::Form.new(
      :"GASSIGNED?",
      :"ZILCH"),
    Syntax::Form.new(
      :SETG,
      :"WBREAKS",
      Syntax::Form.new(
        :STRING,
        '"',
        Syntax::Segment.new(Syntax::Form.new(:GVAL, :WBREAKS)))))

  assert.equal! parsed, expected
end

# test string element
# -----------------------------------------
def test_parser_04(args, assert)
  source = <<-ZIL
<INSERT-FILE "GMACROS" T>
  ZIL

  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :"INSERT-FILE",
    "GMACROS",
    :T)

  assert.equal! parsed, expected
end

# test list element
# -----------------------------------------
def test_parser_05(args, assert)
  source = <<-ZIL
<OBJECT ROOMS
	(IN TO ROOMS)>
  ZIL

  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :"OBJECT",
    :"ROOMS",
    Syntax::List.new(
      :IN, :TO, :ROOMS
    )
  )

  assert.equal! parsed, expected
end

# test commented string
# -----------------------------------------
def test_parser_06(args, assert)
  source = <<-ZIL
;"Yes, this synonym for LOCAL-GLOBALS needs to exist... sigh"
  ZIL

  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Comment.new(
    "Yes, this synonym for LOCAL-GLOBALS needs to exist... sigh"
  )

  assert.equal! parsed, expected
end

# test commented object
# -----------------------------------------
def test_parser_07(args, assert)
  source = <<-ZIL
;<SETG ZORK-NUMBER 1>
  ZIL

  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Comment.new(
    Syntax::Form.new(
      :SETG,
      :"ZORK-NUMBER",
      1))

  assert.equal! parsed, expected
end

# test Hello World routine
# -----------------------------------------
def test_parser_08(args, assert)
  source = <<-ZIL
  <ROUTINE GO ()
    <PRINTI "Hello, world!">
    <CRLF>>
  ZIL

  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :ROUTINE,
    :GO,
    Syntax::List.new,
    Syntax::Form.new(:PRINTI, "Hello, world!"),
    Syntax::Form.new(:CRLF))

  assert.equal! parsed, expected
end

# test list with atom, string, fix
# -----------------------------------------
def test_parser_09(args, assert)
  source = <<-ZIL
<ROUTINE WITH-LIST (P "TEST" 0)>
  ZIL
  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :ROUTINE,
    :"WITH-LIST",
    Syntax::List.new(:P, "TEST", 0)
  )

  assert.equal! parsed, expected
end

# test FIX parsing (all varieties: binary octal and decimal)
# -----------------------------------------
def test_parser_10(args, assert)
  source = <<-ZIL
<ROUTINE WITH-LIST (#2 0011 *17* 123)>
  ZIL
  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :ROUTINE,
    :"WITH-LIST",
    Syntax::List.new(
      3, # '#2 0011'
      15, # '*17*'
      123) # 123
  )

  assert.equal! parsed, expected
end

# test FORM parse with empty FORM element
# -----------------------------------------
def test_parser_11(args, assert)
  source = <<-ZIL
  <RETURN <>>
  ZIL
  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :RETURN,
    Syntax::Form.new)

  assert.equal! parsed, expected
end

# test FORM parse with empty LIST element
# -----------------------------------------
def test_parser_12(args, assert)
  source = <<-ZIL
  <RETURN (() ()) ()>
  ZIL
  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :RETURN,
    Syntax::List.new(
      Syntax::List.new,
      Syntax::List.new),
    Syntax::List.new)

  assert.equal! parsed, expected
end

# test multiline string
# -----------------------------------------
def test_parser_13(args, assert)
  source = <<-ZIL
  <TELL
"You are standing in an open field west of a white house, with a boarded
front door.">
  ZIL
  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :TELL,
    "You are standing in an open field west of a white house, with a boarded\nfront door.")

  assert.equal! parsed, expected
end

# test multiline string with escape chars
# -----------------------------------------
def test_parser_14(args, assert)
  # need to escape backslash to get correct result
  source = <<-ZIL
  <TELL
"You are standing in an \\"open\\" field west of a white house, with a boarded
front door.">
  ZIL
  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :TELL,
    "You are standing in an \"open\" field west of a white house, with a boarded\nfront door.")

  assert.equal! parsed, expected
end

# test DECL for routine
# -----------------------------------------
def test_parser_15(args, assert)
  source = <<-ZIL
<ROUTINE ROUTINE1 (P1 P2 P3)
	 #DECL ((P1 P2 P3) FIX)>
  ZIL
  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :ROUTINE,
    :ROUTINE1,
    Syntax::List.new(:P1, :P2, :P3),
    Syntax::Decl.new(
      Syntax::List.new(
        Syntax::List.new(:P1, :P2, :P3),
        :FIX)))

  assert.equal! parsed, expected
end

# test Macro/Quote for routine
# -----------------------------------------
def test_parser_16(args, assert)
  source = <<-ZIL
<ROUTINE V-WISH ()
	 %<COND (<==? ,ZORK-NUMBER 2>
		 '<PERFORM ,V?MAKE ,WISH>)
		(T
		 '<TELL "With luck, your wish will come true." CR>)>>
  ZIL
  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :ROUTINE,
    :"V-WISH",
    Syntax::List.new,
    Syntax::Macro.new(
      Syntax::Form.new(
        :COND,
        Syntax::List.new(
          Syntax::Form.new(
            :"==?",
            Syntax::Form.new(:GVAL, :"ZORK-NUMBER"),
            2),
          Syntax::Quote.new(
            Syntax::Form.new(
              :PERFORM,
              Syntax::Form.new(:GVAL, :"V?MAKE"),
              Syntax::Form.new(:GVAL, :"WISH")))
        ),
        Syntax::List.new(
          :T,
          Syntax::Quote.new(
            Syntax::Form::new(:TELL, "With luck, your wish will come true.", :CR)
          )
        )
      )
    )
  )

  assert.equal! parsed, expected
end

# test inline commented object (space immediately after semicolon)
# -----------------------------------------
def test_parser_17(args, assert)
  source = <<-ZIL
	<TABLE DEF2A
	       DEF2B
	       0; <REST ,DEF2B 2>
	       0; <REST ,DEF2B 4>>
  ZIL
  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :TABLE,
    :"DEF2A",
    :"DEF2B",
    0, Syntax::Comment.new(Syntax::Form.new(:REST, Syntax::Form.new(:GVAL, :"DEF2B"), 2)),
    0, Syntax::Comment.new(Syntax::Form.new(:REST, Syntax::Form.new(:GVAL, :"DEF2B"), 4))
  )

  assert.equal! parsed, expected
end

# test inline commented object (form immediately after semicolon)
# -----------------------------------------
def test_parser_18(args, assert)
  source = <<-ZIL
	<TABLE DEF2A
	       DEF2B
	       0 ;<REST ,DEF2B 2>
	       0 ;<REST ,DEF2B 4>>
  ZIL
  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :TABLE,
    :"DEF2A",
    :"DEF2B",
    0, Syntax::Comment.new(Syntax::Form.new(:REST, Syntax::Form.new(:GVAL, :"DEF2B"), 2)),
    0, Syntax::Comment.new(Syntax::Form.new(:REST, Syntax::Form.new(:GVAL, :"DEF2B"), 4))
  )

  assert.equal! parsed, expected
end

# test '&' character in atom (discovered in zork2 files)
# -----------------------------------------
def test_parser_19(args, assert)
  source = <<-ZIL
<ROUTINE GO&LOOK>
  ZIL
  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :ROUTINE, :"GO&LOOK"
  )

  assert.equal! parsed, expected
end

# test whitespace after '(' in list element
# -----------------------------------------
def test_parser_20(args, assert)
  source = <<-ZIL
<ROUTINE MATCH-FCN ( "AUX" CNT)>
  ZIL
  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :ROUTINE,
    :"MATCH-FCN",
    Syntax::List.new(
      "AUX",
      :CNT
    )
  )

  assert.equal! parsed, expected
end

# test vector observed in zork3:3actions.zil in #DECL of CPWALL-OBJECT
# --------------------------------------------------------------------
def test_parser_21(args, assert)
  source = <<-ZIL
<UVECTOR [REST FIX]>
  ZIL
  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Form.new(
    :UVECTOR,
    Syntax::Vector.new(
      :REST,
      :FIX
    )
  )

  assert.equal! parsed, expected
end
