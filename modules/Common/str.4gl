#
# str.4gl   Common string methods
#
# PUBLIC
#! ArraySet Set a dynamic array of strings from JSONarray string
#! Hash     Generate a hash from a string using a hash algorithm
#! HasOnly  String only has characters that matches pattern
#! Split    Split string into two parts separated by a token character

#
# shorthand convenience
#! sp       Generate a string containing a set number of spaces
#! ts4      Generate a string containing a set number of 4 char wide tabs
#! ts8      Generate a string containing a set number of 8 char wide tabs
#
# PRIVATE
#! tab_stop Generate a string containing a set number of 8 char wide tabs
#
# TBD
#! _        Localisation of Strings

import security
import util



#
#! ArraySet
#+ Set a dynamic array of strings from JSONarray string
#+
#+ @param pa_str        Dynamic array of strings
#+ @param p_json        String with JSONarray
#+
#+ @code
#+ define a_items dynamic array of string
#+ call str.ArraySet(a_items, '["Alpha","0","50","100","150","200","250"]')
#

function ArraySet(pa_str dynamic array of string, p_json string)

  define
    o_jArr util.JSONArray

  try
    let o_jArr = util.JSONArray.parse(p_json)
    call o_jArr.toFGL(pa_str)
  catch
  end try

end function



#
#! Hash
#+ Generate a hash from a string using a hash algorithm
#+
#+ @param p_algorithm   SHA1, SHA512, SHA384, SHA256, SHA224, MD5
#+ @param p_string      String to generate a hash for
#+
#+ @returnType          String
#+ @return              Hash of p_string
#+
#+ @code
#+ define p_hash string
#+ let p_hash = str.Hash("SHA1", "user@domain.com")
#


public function Hash(p_algorithm, p_string)
  returns (string)

  define
    p_string, p_algorithm, l_hash string,
    o_digest security.Digest

  try
    let o_digest = security.Digest.CreateDigest(p_algorithm)
    call o_digest.AddStringData(p_string)
    let l_hash = o_digest.DoBase64Digest()
  catch
    let l_hash = NULL
  end try

  return l_hash
  
end function


#
#! HasOnly
#+ String only has characters that matches pattern
#+
#+ @param p_pattern   Pattern to match
#+ @param p_string    String to analyse
#+
#+ @returnType        Boolean
#+ @return            TRUE if string HasOnly pattern
#+
#+ @code
#+ define p_phoneNumber string
#+ ...
#+ if str_HasOnly("[0-9]", p_phoneNumber) then ...
#

public function HasOnly(p_pattern, p_string)
  returns (boolean)

  define
    p_string, p_pattern string,
    l_buffer base.StringBuffer,
    idx int

  -- empty cant match
  if p_string.getLength() < 1
  then
    return FALSE
  end if
  
  let l_buffer = base.StringBuffer.create()
  call l_buffer.append(p_string)

  -- check if any chars don't match
  for idx = 1 to l_buffer.getLength()
    if l_buffer.getCharAt(idx) not matches p_pattern
    then
      return FALSE
    end if
  end for

  return TRUE
  
end function


#
#! Split
#+ Split string into two parts separated by a token character
#+
#+ @param p_str     String to split
#+ @param p_sep     Seprator strong or token
#+
#+ @returnType      String, String
#+ @return          String part on left side of separator
#+ @return          Srting part on right side of separator
#+
#+ @code
#+ define p_user, p_domain string
#+ call str.Split("user@domain.com", "@")
#+    returning p_user, p_domain
#

public function Split(p_str, p_sep)
  returns (string, string)

  define
    p_str   string,
    p_sep   char,

    p_len   int,
    p_idx   int,
    p_s1    string,
    p_s2    string


  let p_len = p_str.getLength()
  let p_idx = p_str.getIndexOf(p_sep, 1)

  if p_idx > 0
  then
    let p_s1 = p_str.subString(1, p_idx-1)
    let p_s2 = p_str.subString(p_idx+1, p_len)
  else
    let p_s1 = p_str
    let p_s2 = ""
  end if

  return p_s1, p_s2

end function





#
# Short hand/Convenience functions
# Used in sentential string construction
#



#
#! sp
#+ Generate a string containing a set number of spaces
#+
#+ @param p_spaces    Number of space characters to generate
#+
#+ @returnType        String
#+ @return            String containing p_spaces number of spaces
#+
#+ @code
#+ define p_label string
#+ let p_label = "AAA", sp(20), "BBB"
#

public function sp(p_spaces)
  returns (string)

  define
    p_spaces int

  return p_spaces spaces

end function


#
#! ts4
#+ Generate a string containing a set number of 4 char wide tabs
#+
#+ @param p_tabs  Number of tabs to generate
#+
#+ @returnType    String
#+ @return        String containing p_tabs number of tabs
#+
#+ @code
#+ define p_label string
#+ let p_label = "AAA", ts4(3), "BBB"
#

function ts4(p_tabs)
  returns (string)

  define
    p_tabs int

  return tab_stop(p_tabs, 4)

  end function


#
#! ts8
#+ Generate a string containing a set number of 8 char wide tabs
#+
#+ @param p_tabs  Number of tabs to generate
#+
#+ @returnType    String
#+ @return        String containing p_tabs number of tabs
#+
#+ @code
#+ define p_label string
#+ let p_label = "AAA", ts8(3), "BBB"
#

function ts8(p_tabs)
  returns (string)

  define
    p_tabs int

  return tab_stop(p_tabs, 8)

end function


#
# tab_stop: generate tab spaces (based on sw=4)
#

#
#! tab_stop
#+ Generate a string containing a set number of 8 char wide tabs
#+
#+ @param p_tabs  Number of tabs to generate
#+ @param p_size  Width of each tab
#+
#+ @returnType    String
#+ @return        String containing p_tabs number of tabs
#+
#

private function tab_stop(p_tabs, p_size)
  returns (string)

  define
    p_tabs, p_size int

  return p_tabs * p_size spaces

end function


############################################################################
#
# _: stub for Localisation of Strings
#
############################################################################

public function _(p_string)
  returns (string)

  define
    p_string string

  return p_string
end function
