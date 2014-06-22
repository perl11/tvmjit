#!/usr/bin/tvmjit
;
;   TvmJIT : <http://github.com/fperrad/tvmjit/>
;   Copyright (C) 2013-2014 Francois Perrad.
;
;   Major portions taken verbatim or adapted from the lua-TestMore library.
;   Copyright (c) 2009-2014 Francois Perrad
;

(!call (!index tvm "dofile") "TAP.tp")

(!let char (!index utf8 "char"))
(!let charpatt (!index utf8 "charpatt"))
(!let codes (!index utf8 "codes"))
(!let codepoint (!index utf8 "codepoint"))
(!let len (!index utf8 "len"))
(!let offset (!index utf8 "offset"))

(!let plan plan)
(!let is is)
(!let eq_array eq_array)
(!let error_contains error_contains)

(!call plan 58)

(!call is (!call char 65 66 67) "ABC" "function char")
(!call is (!call char 0x20AC) "\u20AC")
(!call is (!call char) "")

(!call error_contains (!lambda () (!call char 0 -1))
                      ": bad argument #2 to 'char' (invalid value)"
                      "function char (invalid)")

(!call error_contains (!lambda () (!call char 0 "bad"))
                      ": bad argument #2 to 'char' (number expected, got string)"
                      "function char (bad)")

(!call is charpatt "[\x00-\x7F\xC2-\xF4][\x80-\xBF]*" "charpatt")

(!let ap ())
(!let ac ())
(!for (p c) ((!call codes "A\u20AC3"))
        (!assign (!index ap (!add (!len ap) 1)) p)
        (!assign (!index ac (!add (!len ac) 1)) c))
(!call eq_array ap (1 2 5) "function codes")
(!call eq_array ac (0x41 0x20AC 0x33))

(!define empty !true)
(!for (p c) ((!call codes ""))
        (!assign empty !false))
(!call ok empty "codes (empty)")

(!call error_contains (!lambda () (!call codes))
                      ": bad argument #1 to 'codes' (string expected, got no value)"
                      "function codes ()")

(!call error_contains (!lambda () (!call codes !true))
                      ": bad argument #1 to 'codes' (string expected, got boolean)"
                      "function codes (true)")

(!call is (!call codepoint "A\u20AC3") 0x41 "function codepoint")
(!call is (!call codepoint "A\u20AC3" 2) 0x20AC)
(!call is (!call codepoint "A\u20AC3" (!neg 1)) 0x33)
(!call is (!call codepoint "A\u20AC3" 5) 0x33)
(!call eq_array ((!call codepoint "A\u20AC3" 1 5)) (0x41 0x20AC 0x33))
(!call eq_array ((!call codepoint "A\u20AC3" 1 4)) (0x41 0x20AC))

(!call error_contains (!lambda () (!call codepoint "A\u20AC3" 6))
                      ": bad argument #3 to 'codepoint' (out of range)"
                      "function codepoint (out of range)")

(!call error_contains (!lambda () (!call codepoint "A\u20AC3" 8))
                      ": bad argument #3 to 'codepoint' (out of range)"
                      "function codepoint (out of range)")

(!call is (!call len "A") 1 "function len")
(!call is (!call len "") 0)
(!call is (!call len "\u0041\u0042\u0043") 3)
(!call is (!call len "A\u20AC3") 3)
(!call is (!call len "A" 1) 1)
(!call is (!call len "A" 2) 0)
(!call is (!call len "ABC" -1) 1)
(!call is (!call len "ABC" -2) 2)

(!call error_contains (!lambda () (!call len "A" 3))
                      ": bad argument #2 to 'len' (initial position out of string)"
                      "function len (out of range))")

(!call is (!call offset "A\u20AC3" 1) 1 "function offset")
(!call is (!call offset "A\u20AC3" 2) 2)
(!call is (!call offset "A\u20AC3" 3) 5)
(!call is (!call offset "A\u20AC3" 4) 6)
(!call is (!call offset "A\u20AC3" 5) !nil)
(!call is (!call offset "A\u20AC3" 6) !nil)
(!call is (!call offset "A\u20AC3" -1) !nil)
(!call is (!call offset "A\u20AC3" 1 2) 2)
(!call is (!call offset "A\u20AC3" 2 2) 5)
(!call is (!call offset "A\u20AC3" 3 2) 6)
(!call is (!call offset "A\u20AC3" 4 2) !nil)
(!call is (!call offset "A\u20AC3" -1 2) 1)
(!call is (!call offset "A\u20AC3" -2 2) !nil)
(!call is (!call offset "A\u20AC3" 1 5) 5)
(!call is (!call offset "A\u20AC3" 2 5) 6)
(!call is (!call offset "A\u20AC3" 3 5) !nil)
(!call is (!call offset "A\u20AC3" -1 5) 2)
(!call is (!call offset "A\u20AC3" -2 5) 1)
(!call is (!call offset "A\u20AC3" -3 5) !nil)
(!call is (!call offset "A\u20AC3" 1 6) 6)
(!call is (!call offset "A\u20AC3" 2 6) !nil)
(!call is (!call offset "A\u20AC3" 1 -1) 5)
(!call is (!call offset "A\u20AC3" -1 -1) 2)
(!call is (!call offset "A\u20AC3" -2 -1) 1)
(!call is (!call offset "A\u20AC3" -3 -1) !nil)
(!call is (!call offset "A\u20AC3" 1 -4) 2)
(!call is (!call offset "A\u20AC3" 2 -4) 5)
(!call is (!call offset "A\u20AC3" -1 -4) 1)
(!call is (!call offset "A\u20AC3" -2 -4) !nil)

(!call error_contains (!lambda () (!call offset "A\u20AC3" 1 7))
                      ": bad argument #3 to 'offset' (position out of range)"
                      "function offset (out of range)")

