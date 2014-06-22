/*
** utf8 library.
** Copyright (C) 2013-2014 Francois Perrad.
**
** Major portions taken verbatim or adapted from the Lua interpreter.
** Copyright (C) 1994-2014 Lua.org, PUC-Rio. See Copyright Notice in lua.h
*/


#define lib_utf8_c
#define LUA_LIB

#include "tvmjit.h"
#include "lauxlib.h"
#include "lualib.h"

#include "lj_lib.h"

/* ------------------------------------------------------------------------ */

#define LJLIB_MODULE_utf8

#define MAXUNICODE	0x10FFFF

#define iscont(p)	((*(p) & 0xC0) == 0x80)


/* from strlib */
/* translate a relative string position: negative means back from end */
static lua_Integer u_posrelat (lua_Integer pos, size_t len) {
  if (pos >= 0) return pos;
  else if (0u - (size_t)pos > len) return 0;
  else return (lua_Integer)len + pos + 1;
}


/*
** Decode one UTF-8 sequence, returning NULL if byte sequence is invalid.
*/
static const char *utf8_decode (const char *o, int *val) {
  static unsigned int limits[] = {0xFF, 0x7F, 0x7FF, 0xFFFF};
  const unsigned char *s = (const unsigned char *)o;
  unsigned int c = s[0];
  unsigned int res = 0;  /* final result */
  if (c < 0x80)  /* ascii? */
    res = c;
  else {
    int count = 0;  /* to count number of continuation bytes */
    while (c & 0x40) {  /* still have continuation bytes? */
      int cc = s[++count];  /* read next byte */
      if ((cc & 0xC0) != 0x80)  /* not a continuation byte? */
        return NULL;  /* invalid byte sequence */
      res = (res << 6) | (cc & 0x3F);  /* add lower 6 bits from cont. byte */
      c <<= 1;  /* to test next bit */
    }
    res |= ((c & 0x7F) << (count * 5));  /* add first byte */
    if (count > 3 || res > MAXUNICODE || res <= limits[count])
      return NULL;  /* invalid byte sequence */
    s += count;  /* skip continuation bytes read */
  }
  if (val) *val = res;
  return (const char *)s + 1;  /* +1 to include first byte */
}


/*
** utf8len(s [, i [, j]]) --> number of characters that start in the
** range [i,j], or nil + current position if 's' is not well formed in
** that interval
*/
LJLIB_CF(utf8_len)
{
  int n = 0;
  size_t len;
  const char *s = luaL_checklstring(L, 1, &len);
  lua_Integer posi = u_posrelat(luaL_optinteger(L, 2, 1), len);
  lua_Integer posj = u_posrelat(luaL_optinteger(L, 3, -1), len);
  luaL_argcheck(L, 1 <= posi && --posi <= (lua_Integer)len, 2,
                   "initial position out of string");
  luaL_argcheck(L, --posj < (lua_Integer)len, 3,
                   "final position out of string");
  while (posi <= posj) {
    const char *s1 = utf8_decode(s + posi, NULL);
    if (s1 == NULL) {  /* conversion error? */
      lua_pushnil(L);  /* return nil ... */
      lua_pushinteger(L, posi + 1);  /* ... and current position */
      return 2;
    }
    posi = s1 - s;
    n++;
  }
  lua_pushinteger(L, n);
  return 1;
}


/*
** codepoint(s, [i, [j]])  -> returns codepoints for all characters
** that start in the range [i,j]
*/
LJLIB_CF(utf8_codepoint)
{
  size_t len;
  const char *s = luaL_checklstring(L, 1, &len);
  lua_Integer posi = u_posrelat(luaL_optinteger(L, 2, 1), len);
  lua_Integer pose = u_posrelat(luaL_optinteger(L, 3, posi), len);
  int n;
  const char *se;
  luaL_argcheck(L, posi >= 1, 2, "out of range");
  luaL_argcheck(L, pose <= (lua_Integer)len, 3, "out of range");
  if (posi > pose) return 0;  /* empty interval; return no values */
  n = (int)(pose -  posi + 1);
  if (posi + n <= pose)  /* (lua_Integer -> int) overflow? */
    return luaL_error(L, "string slice too long");
  luaL_checkstack(L, n, "string slice too long");
  n = 0;
  se = s + pose;
  for (s += posi - 1; s < se;) {
    int code;
    s = utf8_decode(s, &code);
    if (s == NULL)
      return luaL_error(L, "invalid UTF-8 code");
    lua_pushinteger(L, code);
    n++;
  }
  return n;
}


/*
** offset(s, n, [i])  -> index where n-th character *after*
**   position 'i' starts; 0 means character at 'i'.
*/
LJLIB_CF(utf8_offset)
{
  size_t len;
  const char *s = luaL_checklstring(L, 1, &len);
  int n  = luaL_checkint(L, 2);
  lua_Integer posi = u_posrelat(luaL_optinteger(L, 3, 1), len) - 1;
  luaL_argcheck(L, 0 <= posi && posi <= (lua_Integer)len, 3,
                   "position out of range");
  if (n == 0) {
    /* find beginning of current byte sequence */
    while (posi > 0 && iscont(s + posi)) posi--;
  }
  else if (n < 0) {
    while (n < 0 && posi > 0) {  /* move back */
      do {  /* find beginning of previous character */
        posi--;
      } while (posi > 0 && iscont(s + posi));
      n++;
    }
  }
  else {
    n--;  /* do not move for 1st character */
    while (n > 0 && posi < (lua_Integer)len) {
      do {  /* find beginning of next character */
        posi++;
      } while (iscont(s + posi));  /* ('\0' is not continuation) */
      n--;
    }
  }
  if (n == 0)
    lua_pushinteger(L, posi + 1);
  else
    lua_pushnil(L);  /* no such position */
  return 1;
}


static int iter_aux (lua_State *L) {
  size_t len;
  const char *s = luaL_checklstring(L, 1, &len);
  int n = lua_tointeger(L, 2) - 1;
  if (n < 0)  /* first iteration? */
    n = 0;  /* start from here */
  else if (n < (lua_Integer)len) {
    n++;  /* skip current byte */
    while (iscont(s + n)) n++;  /* and its continuations */
  }
  if (n >= (lua_Integer)len)
    return 0;  /* no more codepoints */
  else {
    int code;
    const char *next = utf8_decode(s + n, &code);
    if (next == NULL || iscont(next))
      return luaL_error(L, "invalid UTF-8 code");
    lua_pushinteger(L, n + 1);
    lua_pushinteger(L, code);
    return 2;
  }
}


LJLIB_CF(utf8_codes)
{
  luaL_checkstring(L, 1);
  lua_pushcfunction(L, iter_aux);
  lua_pushvalue(L, 1);
  lua_pushinteger(L, 0);
  return 3;
}

/* ------------------------------------------------------------------------ */

/* pattern to match a single UTF-8 character */
#define UTF8PATT	"[\0-\x7F\xC2-\xF4][\x80-\xBF]*"

#include "lj_libdef.h"

int luaopen_utf8 (lua_State *L) {
  LJ_LIB_REG(L, LUA_UTF8LIBNAME, utf8);
  lua_pushliteral(L, UTF8PATT);
  lua_setfield(L, -2, "charpatt"); /* utf8.charpatt = UTF8PATT */
  lua_getglobal(L, "tvm");
  lua_getfield(L, -1, "wchar");
  lua_remove(L, -2); /* tvm */
  lua_setfield(L, -2, "char"); /* utf8.char = tvm.wchar */
  return 1;
}

