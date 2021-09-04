def test_parser(args, assert)
  source = <<-ZIL
<ROUTINE OTHER-SIDE (DOBJ "AUX" (P 0) TX)
 <REPEAT ()
   <COND (<L? <SET P <NEXTP ,HERE .P>> ,LOW-DIRECTION>
    <RETURN <>>)
         (ELSE
    <SET TX <GETPT ,HERE .P>>
    <COND (<AND <EQUAL? <PTSIZE .TX> ,DEXIT>
          <EQUAL? <GETB .TX ,DEXITOBJ> .DOBJ>>
           <RETURN .P>)>)>>>
ZIL

  parser = Parser.new
  parser.parse_string(args, source)
  parsed = parser.expressions[0]

  expected = Syntax::Form.new(
    :ROUTINE,
    :"OTHER-SIDE",
    Syntax::List.new(
      :DOBJ,
      "AUX",
      Syntax::List.new(:P, 0),
      :TX),
    Syntax::Form.new(
      :REPEAT,
      Syntax::List.new,
      Syntax::Form.new(
        :COND,
        Syntax::List.new(
          Syntax::Form.new(
            :L?,
            Syntax::Form.new(
              :SET,
              :P,
              Syntax::Form.new(
                :NEXTP,
                Syntax::Form.new(:GVAL, :"HERE"),
                Syntax::Form.new(:LVAL, :"P")
              )
            ),
            Syntax::Form.new(:GVAL, :"LOW-DIRECTION")
          ),
          Syntax::Form.new(:RETURN, Syntax::Form.new)
        ),
        Syntax::List.new(
          :ELSE,
          Syntax::Form.new(
            :SET,
            :TX,
            Syntax::Form.new(
              :GETPT,
              Syntax::Form.new(:GVAL, :"HERE"),
              Syntax::Form.new(:LVAL, :"P")
            )
          ),
          Syntax::Form.new(
            :COND,
            Syntax::List.new(
              Syntax::Form.new(
                :AND,
                Syntax::Form.new(
                  :EQUAL?,
                  Syntax::Form.new(
                    :PTSIZE,
                    Syntax::Form.new(:LVAL, :"TX")
                  ),
                  Syntax::Form.new(:GVAL, :"DEXIT")
                ),
                Syntax::Form.new(
                  :EQUAL?,
                  Syntax::Form.new(
                    :GETB,
                    Syntax::Form.new(:LVAL, :"TX"),
                    Syntax::Form.new(:GVAL, :"DEXITOBJ")
                  ),
                  Syntax::Form.new(:LVAL, :"DOBJ"))
              ),
              Syntax::Form.new(
                :RETURN,
                Syntax::Form.new(:LVAL, :"P")),
            )
          )
        )
      )
    )
  )

  assert.equal! parsed, expected
end

def test_parser_macro_and_quoted(args, assert)
  source = <<-ZIL
%<COND (<EQUAL? ,GLOBAL-VAR 22>
  '<ROUTINE ABC () 3>)
       (ELSE
  '<ROUTINE ABC () 4>)>
ZIL

  parser = Parser.new
  parser.parse_string(args, source)
  parsed = parser.expressions[0]

  expected = Syntax::Macro.new(
    Syntax::Form.new(
      :COND,
      Syntax::List.new(
        Syntax::Form.new(:EQUAL?, Syntax::Form.new(:GVAL, :"GLOBAL-VAR"), 22),
        Syntax::Quote.new(
          Syntax::Form.new(:ROUTINE, :ABC, Syntax::List.new, 3)
        ),
      ),
      Syntax::List.new(
        :ELSE,
        Syntax::Quote.new(
          Syntax::Form.new(:ROUTINE, :ABC, Syntax::List.new, 4)
        )
      )
    )
  )

  assert.equal! parsed, expected
end
