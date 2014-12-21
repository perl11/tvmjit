#!/usr/bin/tvmjit
;
;   TvmJIT : <http://github.com/fperrad/tvmjit/>
;   Copyright (C) 2013-2014 Francois Perrad.
;
;   Major portions taken verbatim or adapted from the lua-TestMore library.
;   Copyright (c) 2009-2011 Francois Perrad
;

(!call (!index tvm "dofile") "TAP.tp")

(!let concat (!index tvm "concat"))
(!let escape (!index tvm "escape"))
(!let insert (!index table "insert"))
(!let quote (!index tvm "quote"))
(!let wchar (!index tvm "wchar"))
(!let unpack (!index tvm "unpack"))
(!let dofile (!index tvm "dofile"))
(!let load (!index tvm "load"))
(!let loadfile (!index tvm "loadfile"))
(!let op (!index (!index tvm "op") "new"))
(!let open (!index io "open"))
(!let parse (!index tvm "parse"))
(!let parsefile (!index tvm "parsefile"))
(!let unlink (!index os "remove"))
(!let tostring tostring)

(!let plan plan)
(!let is is)
(!let error_contains error_contains)
(!let type_ok type_ok)

(!call plan 74)

(!call contains (!index tvm "_VERSION") "TvmJIT 0.1.3" "variable _VERSION")

(!call is (!call escape "a(b:c)d e") "a\\(b\\:c\\)d\\ e")

(!call is (!call quote "a string with \"quotes\" and \n new line") "\"a string with \\\"quotes\\\" and \n new line\"" "function quote")

(!call is (!call quote "a string with \b and \b2") "\"a string with \\x08 and \\x082\"")

(!call is (!call quote "a string with \x0c") "\"a string with \\x0C\"")

(!call is (!call wchar 65 66 67) "ABC" "function char")
(!call is (!call wchar) "")

(!call is (!call wchar 0xe7) "ç")
(!call is (!call wchar 0x20ac) "€")

(!call error_contains (!lambda () (!call wchar 0 "bad"))
                      ": bad argument #2 to 'wchar' (number expected, got string)"
                      "function wchar with bad arg")

(!call error_contains (!lambda () (!call wchar 0 0x110000))
                      ": bad argument #2 to 'wchar' (invalid value)"
                      "function wchar (invalid)")


(!call eq_array ((!call unpack ())) () "function unpack")
(!call eq_array ((!call unpack ("a"))) ("a"))
(!call eq_array ((!call unpack ("a" "b" "c"))) ("a" "b" "c"))
(!call eq_array ((!call1 unpack ("a" "b" "c"))) ("a"))
(!call eq_array ((!call unpack ("a" "b" "c" "d" "e") 2 4)) ("b" "c" "d"))
(!call eq_array ((!call unpack ("a" "b" "c") 2 4)) ("b" "c"))
(!call eq_array ((!call unpack)) ())


(!define f (!call open "lib1.tp" "w"))
(!callmeth f write "
(!assign norm (!lambda (x y)
                (!return (!pow (!add (!pow x 2) (!pow y 2)) 0.5))))

(!assign twice (!lambda (x)
                (!return (!mul 2 x))))
")
(!callmeth f close)
(!call dofile "lib1.tp")
(!define n (!call norm 3.4 1.0))
(!call contains (!call twice n) "7.088" "function dofile")

(!call unlink "lib1.tp")        ; clean up

(!call error_contains (!lambda () (!call dofile "no_file.tp"))
                      "cannot open no_file.tp: No such file or directory"
                      "function dofile (no file)")

(!define f (!call open "foo.tp" "w"))
(!callmeth f write "?syntax error?")
(!callmeth f close)
(!call error_contains (!lambda () (!call dofile "foo.tp"))
                      "foo.tp:"
                      "function dofile (syntax error)")
(!call unlink "foo.tp") ; clean up

(!define t ( "
(!assign bar (!lambda (x)
                (!return x)))
"))
(!assign i 0)
(!let reader (!lambda ()
                (!assign i (!add i 1))
                (!return (!index t i))))
(!define (f msg) ((!call load reader)))
(!if msg
     (!call diag msg))
(!call type_ok f "function" "function load(reader)")
(!call is bar !nil)
(!call f)
(!call is (!call bar "ok") "ok")
(!assign bar !nil)

(!define t ("
(!assign baz (!lambda (x)
                (!return x)))
"))
(!assign i -1)
(!let reader (!lambda ()
                (!assign i (!add i 1))
                (!return (!index t i))))
(!define (f msg) ((!call load reader)))
(!if msg (!call diag msg))
(!call type_ok f "function" "function load(pathological reader)")
(!call f)
(!call is baz !nil)

(!assign t ("?syntax error?"))
(!assign i 0)
(!define (f msg) ((!call load reader "errorchunk")))
(!call is f !nil "function load(syntax error)")
(!call contains msg "[string \"errorchunk\"]:")

(!define f (!call load (!lambda () (!return !nil))))
(!call type_ok f "function" "when reader returns nothing")

(!define (f msg) ((!call load (!lambda () (!return ())))))
(!call is f !nil "reader function must return a string")
(!call contains msg "reader function must return a string")

(!define f (!call load "(!assign bar (!lambda (x) (!return x)))"))
(!call is bar !nil "function load(str)")
(!call f)
(!call is (!call bar "ok") "ok")
(!assign bar !nil)

(!define env ())
(!define f (!call load "(!assign bar (!lambda (x) (!return x)))" "from string" "t" env))
(!call is (!index env "bar") !nil "function load(str)")
(!call f)
(!call is (!call (!index env "bar") "ok") "ok")

(!define (f msg) ((!call load "?syntax error?" "errorchunk")))
(!call is f !nil "function load(syntax error)")
(!call contains msg "[string \"errorchunk\"]:")

(!define (f msg) ((!call load "(!call print \"ok\")" "chunk txt" "b")))
(!call contains  msg "attempt to load chunk with wrong mode")
(!call is f !nil "mode")

(!define (f msg) ((!call load "\x1bLua" "chunk bin" "t")))
(!call contains  msg "attempt to load chunk with wrong mode")
(!call is f !nil "mode")

(!define f (!call open "foo.tp" "w"))
(!callmeth f write "(!assign foo (!lambda (x) (!return x)))")
(!callmeth f close)
(!define f (!call loadfile "foo.tp"))
(!call is foo !nil "function loadfile")
(!call f)
(!call is (!call foo "ok") "ok")

(!define (f msg) ((!call loadfile "foo.tp" "b")))
(!call contains msg "attempt to load chunk with wrong mode")
(!call is f !nil "mode")

(!define env ())
(!define f (!call loadfile "foo.tp" "t" env))
(!call is (!index env "foo") !nil "function loadfile")
(!call f)
(!call is (!call (!index env "foo") "ok") "ok")

(!call unlink "foo.tp") ; clean up

(!define (f msg) ((!call loadfile "no_file.tp")))
(!call is f !nil "function loadfile (no file)")
(!call is msg "cannot open no_file.tp: No such file or directory")

(!define f (!call open "foo.tp" "w"))
(!callmeth f write "?syntax error?")
(!callmeth f close)
(!define (f msg) ((!call loadfile "foo.tp")))
(!call is f !nil "function loadfile (syntax error)")
(!call contains msg "foo.tp:")
(!call unlink "foo.tp") ; clean up

(!define t ("a" "b" "c" "d" "e"))
(!call is (!call concat t) "abcde" "function concat")
(!call is (!call concat t ",") "a,b,c,d,e")
(!call is (!call concat t "," 2) "b,c,d,e")
(!call is (!call concat t "," 2 4) "b,c,d")
(!call is (!call concat t "," 4 2) "")

(!define t ("a" "b" 3 "d" "e"))
(!call is (!call concat t ",") "a,b,3,d,e" "function concat (number)")

(!define t ("a" "b" !true "d" "e"))
(!call is (!call concat t ",") "a,b,true,d,e")

(!let o1 (!call1 op ("!call" "print" (!call1 quote "hello"))))
(!call is (!call1 tostring o1) "(!call print \"hello\")" "op")
(!let o2 (!call1 op ((!call1 quote "no"): 0 (!call1 quote "yes"): 1)))
(!call is (!call1 tostring o2) "(\"no\": 0 \"yes\": 1)")
(!let o3 (!call1 op (0: (!call1 quote "zero") (!call1 quote "one") (!call1 quote "two"))))
(!call is (!call1 tostring o3) "(0: \"zero\" \"one\" \"two\")")
(!let o4 (!call1 op ("!line")))
(!callmeth o4 push 4)
(!call is (!call1 tostring o4) "\n(!line 4)")
(!let o5 (!call1 op ()))
(!callmeth o5 addkv (!call1 quote "key") (!call1 quote "value"))
(!call is (!call1 tostring o5) "(\"key\": \"value\")")

(!let o ((!call1 op ("!line" 1)) o1))
(!call is (!call1 concat o) "\n(!line 1)(!call print \"hello\")" "ops")
(!call insert o (!call1 op ("!line" 2)))
(!call insert o o1)
(!call is (!call1 concat o) "\n(!line 1)(!call print \"hello\")\n(!line 2)(!call print \"hello\")")

(!call is (!call1 tostring (!call1 parse "()")) "()" "parse")
(!call is (!call1 tostring (!call1 parse ";\n() ; comment")) "()")
(!call is (!call1 tostring (!call1 parse "()()")) "\n(!do () ())")
(!call is (!call1 tostring (!call1 parse "\n(!do () ())")) "\n(!do () ())")

(!call is (!call1 tostring (!call1 parse "(1 !true \"foo\")")) "(1 !true \"foo\")")
(!call is (!call1 tostring (!call1 parse "(\"no\": 0 \"yes\": 1)")) "(\"no\": 0 \"yes\": 1)")
(!call is (!call1 tostring (!call1 parse "(1 (-2e1 (+3)))")) "(1 (-20 (3)))")
(!call is (!index (!call1 parse "(3.14)") 1) 3.14)

(!define f (!call open "foo.tp" "w"))
(!let code "(!assign foo (!lambda (x) (!return x)))")
(!callmeth f write code)
(!callmeth f close)
(!call is (!call1 tostring (!call1 parsefile "foo.tp")) code "parsefile")

(!call unlink "foo.tp") ; clean up
