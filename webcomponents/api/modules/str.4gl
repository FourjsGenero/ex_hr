#
# str   Common string functions (subset)
#

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

public function ArraySet(pa_str dynamic array of string, p_json string)

  define
    o_jArr util.JSONArray

  try
    let o_jArr = util.JSONArray.parse(p_json)
    call o_jArr.toFGL(pa_str)
  catch
  end try

end function
