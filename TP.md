
# Table Processing

## Tokens

#### ; comment

#### number

    0
    42

    3.14
    +.314e+1
    .314e1
    -31.4e-1

    0x7E
    -0X7e

    0x0.1E
    0xA23p-4

#### string

    "text"
    "tab\t"
    "quote\""
    "\x3A"      ; hexadecimal 8-bits character
    "\u20AC"    ; unicode char UTF-8 encoded (4 hexadecimals)
    "\U000020AC"; unicode char UTF-8 encoded (8 hexadecimals)
    "
    multiline
    string
    "

#### table

    (1 4 9 16)
    (-100: "min" 100: "max")
    (0: "zero" "one")
    ("zero": 0 "one": 1)

#### identifier

    Foo
    Foo-Bar
    Foo\:Bar
    Foo\(Bar\)
    Foo\ Bar
    !Foo$Bar?



## Specials

#### `!false`

#### `!nil`

#### `!true`

#### `!vararg`

#### `(!assign var expr)`

assignment
(could be used as expression, not like in Lua)

#### `(!add expr1 expr2)`

addition

#### `(!and expr1 expr2)`

logical and

#### `(!break)`

break statement

#### `(!call fct prm1 ... prmn)`

function call

#### `(!call1 fct prm1 ... prmn)`

function call with results adjusted to 1

in expression with operator (for example `(!neg (!call f))`),
`!call` is automatically replaced by `!call1`

tail call optimization is disabled with `(!return (!call1 ...))`

#### `(!callmeth obj meth prm1 ... prmn)`

method call

#### `(!callmeth1 obj meth prm1 ... prmn)`

method call with results adjusted to 1

#### `(!concat expr1 expr2)`

concatenation

#### `(!cond (expr1 (stmt1 ... stmtm)) ... (exprn (stmt1 ... stmtm)))`

cond statement

#### `(!define var [expr])` or `(!define (var1 ... varn) (expr1 ... exprm))`

define local variables

#### `(!div expr1 expr2)`

division

#### `(!do stmt1 ... stmtn)`

block
(could be used as expression, not like in Lua)

#### `(!eq expr1 expr2)`

relational equal

#### `(!for (var1 ... varn) (expr1 ... exprm) stmt1 ... stmtn)`

for statement

#### `(!ge expr1 expr2)`

relational great or equal

#### `(!goto lbl)`

goto statement

#### `(!gt expr1 exrp2)`

relational great than

#### `(!if expr stmt-then [stmt-else])`

if statement

#### `(!index var expr)`

#### `(!label lbl)`

#### `(!lambda (prm1 ... prmn) stmt1 ... stmtn)`

#### `(!le expr1 expr2)`

relational less or equal

#### `(!len expr)`

length

#### `(!let var expr)` or `(!let (var1 ... varn) (expr1 ... exprm))`

define local variables which could not be re-assigned

#### `(!letrec var lambda)`

define a local variable which could used in recursive call

#### `(!line "filename" lineno)` or `(!line lineno)`

annotation

#### `(!loop init limit step stmt1 ... stmtn)`

loop statement

#### `(!lt expr1 expr2)`

relational less then

#### `(!massign (var1 ... varn) (expr1 ... exprm))`

multiple assignment

#### `(!mconcat expr1 ... exprn)`

concatenation

#### `(!mod expr1 expr2)`

modulo

#### `(!mul expr1 expr2)`

multiplication

#### `(!ne expr1 expr2)`

relational not equal

#### `(!neg expr)`

negation

#### `(!not expr)`

logical not

#### `(!or expr1 expr2)`

logical or

#### `(!pow expr1 expr2)`

exponentiation

#### `(!repeat stmt1 ... stmtn expr)`

repeat statement

#### `(!return expr1 ... exprn)`

return statement

#### `(!sub expr1 expr2)`

subtraction

#### `(!while expr stmt1 ... stmtn)`

while statement



## TVM Library

In addition to the [Lua standard libraries](http://www.lua.org/manual/5.1/manual.html#5).

#### `tvm.concat (table [, sep [, i [, j]]])`

like [`table.concat`](http://www.lua.org/manual/5.1/manual.html#pdf-table.concat)
but using `tostring` to convert each element.

#### `tvm.dofile ([filename])`

like [`dofile`](http://www.lua.org/manual/5.1/manual.html#pdf-dofile) but for TP chunk.

#### `tvm.escape (s)`

returns a escaped string (`(`, `)`, `:`, and space) suitable to be safely read back by the TP interpreter.

#### `tvm.load (ld [, source [, mode]])`

like [`load`](http://www.lua.org/manual/5.2/manual.html#pdf-load) (5.2) but for TP chunk
(includes 5.1 [`loadstring`](http://www.lua.org/manual/5.1/manual.html#pdf-loadstring)).

#### `tvm.loadfile (filename [, mode])`

like [`loadfile`](http://www.lua.org/manual/5.2/manual.html#pdf-loadfile) (5.2) but for TP chunk.

#### `tvm.op.new (table)`

constructor of `op` representation.

#### `tvm.op:addkv (k, v)`

#### `tvm.op:push (v)`

#### `tvm.parse (s [, chunkname])`

parses a TP chunk from a string and returns a `op` tree.

#### `tvm.parsefile ([filename])`

parses a TP chunk from a file and returns a `op` tree.

#### `tvm.quote (s)`

returns a quoted string (not printable character are escaped) suitable to be safely read back by the TP interpreter.

#### `tvm.unpack (list [, i [, j ]])`

like [`unpack`](http://www.lua.org/manual/5.1/manual.html#pdf-unpack) but accept `nil` as parameter,
so `tvm.unpack(t)` is equivalent to `unpack(t or {})`.

#### `tvm.wchar (...)`

like [`string.char`](http://www.lua.org/manual/5.1/manual.html#pdf-string.char)
but returns a string which is the concatenation of the UTF-8 representation of each integer.

## UTF-8 Library

backported from Lua 5.3.0.

## The C API

In addition to the [C/Lua API](http://www.lua.org/manual/5.2/manual.html#4)
and the [Auxiliary Library](http://www.lua.org/manual/5.2/manual.html#5).

#### `int tvm_loadx (lua_State *L, lua_Reader reader, void *dt, const char *chunkname, const char *mode);`

like [`lua_load`](http://www.lua.org/manual/5.2/manual.html#lua_load) but for TP chunk.

#### `int (tvm_loadbuffer) (lua_State *L, const char *buff, size_t sz, const char *name);`

like [`luaL_loadbuffer`](http://www.lua.org/manual/5.1/manual.html#luaL_loadbuffer) but for TP chunk.

#### `int (tvm_loadbufferx) (lua_State *L, const char *buff, size_t sz, const char *name, const char *mode);`

like [`luaL_loadbufferx`](http://www.lua.org/manual/5.2/manual.html#luaL_loadbufferx) (5.2) but for TP chunk

#### `int (tvm_loadfile) (lua_State *L, const char *filename);`

like [`luaL_loadfile`](http://www.lua.org/manual/5.1/manual.html#luaL_loadfile) but for TP chunk.

#### `int (tvm_loadfilex) (lua_State *L, const char *filename, const char *mode);`

like [`luaL_loadfilex`](http://www.lua.org/manual/5.2/manual.html#luaL_loadfilex) (5.2) but for TP chunk

#### `int (tvm_loadstring) (lua_State *L, const char *s);`

like [`luaL_loadstring`](http://www.lua.org/manual/5.1/manual.html#luaL_loadstring) but for TP chunk.

## Code Generation

Here, an example with the code generation library :

`$ cat ost.t`

    (!let concat (!index tvm "concat"))
    (!let op (!index (!index tvm "op") "new"))
    (!let quote (!index tvm "quote"))
    (!let insert (!index table "insert"))

    (!let o (
        (!call1 op ("!line" 1))
        (!call1 op ("!call" "print" (!call1 quote "hello")))
        (!call1 op ("!line" 2))
        (!call1 op ("!let" "h" (!call1 op ((!call1 quote "no"): 0 (!call1 quote "yes"): 1))))
        (!call1 op ("!line" 3))
        (!call1 op ("!let" "a" (!call1 op (0: (!call1 quote "zero") (!call1 quote "one") (!call1 quote "two")))))
        (!callmeth1 (!call1 op ("!line"))
                    push 4)
        (!call1 op ("!let" "h" (!callmeth1 (!call1 op ())
                                           addkv (!call1 quote "key") (!call1 quote "value"))))
    ))
    (!call insert o (!call1 op ("!line" 5)))
    (!call insert o (!call1 op ("!call" "print" (!call1 op ("!index" "h" (!call1 quote "key"))))))
    (!call print (!call1 concat o))


`$ ./tvmjit ost.t`

    (!line 1)(!call print "hello")
    (!line 2)(!let h ("no": 0 "yes": 1))
    (!line 3)(!let a (0: "zero" "one" "two"))
    (!line 4)(!let h ("key": "value"))
    (!line 5)(!call print (!index h "key"))

`$ ./tvmjit ost.t | ./tvmjit`

    hello
    value

## References

- [Learn Lua in 15 Minutes](http://tylerneylon.com/a/learn-lua)
- [S-expression](http://en.wikipedia.org/wiki/S-expression)
- [LuaJIT](http://luajit.org/)
- [Lua](http://www.lua.org)
