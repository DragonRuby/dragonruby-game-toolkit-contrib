require 'tests/test_helpers.rb'

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

  parsed = Parser.parse_string(source)[0]

  expected = form(
    :ROUTINE,
    :"OTHER-SIDE",
    list(
      :DOBJ,
      "AUX",
      list(:P, 0),
      :TX),
    form(
      :REPEAT,
      list,
      form(
        :COND,
        list(
          form(
            :L?,
            form(
              :SET,
              :P,
              form(
                :NEXTP,
                form(:GVAL, :"HERE"),
                form(:LVAL, :"P")
              )
            ),
            form(:GVAL, :"LOW-DIRECTION")
          ),
          form(:RETURN, form)
        ),
        list(
          :ELSE,
          form(
            :SET,
            :TX,
            form(
              :GETPT,
              form(:GVAL, :"HERE"),
              form(:LVAL, :"P")
            )
          ),
          form(
            :COND,
            list(
              form(
                :AND,
                form(
                  :EQUAL?,
                  form(
                    :PTSIZE,
                    form(:LVAL, :"TX")
                  ),
                  form(:GVAL, :"DEXIT")
                ),
                form(
                  :EQUAL?,
                  form(
                    :GETB,
                    form(:LVAL, :"TX"),
                    form(:GVAL, :"DEXITOBJ")
                  ),
                  form(:LVAL, :"DOBJ"))
              ),
              form(
                :RETURN,
                form(:LVAL, :"P")),
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

  parsed = Parser.parse_string(source)[0]

  expected = Syntax::Macro.new(
    form(
      :COND,
      list(
        form(:EQUAL?, form(:GVAL, :"GLOBAL-VAR"), 22),
        Syntax::Quote.new(
          form(:ROUTINE, :ABC, list, 3)
        ),
      ),
      list(
        :ELSE,
        Syntax::Quote.new(
          form(:ROUTINE, :ABC, list, 4)
        )
      )
    )
  )

  assert.equal! parsed, expected
end
