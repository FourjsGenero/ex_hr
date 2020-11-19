main
  define
    l_db string,
    l_table string,
    l_file string

  let l_db = "hr"
  #let l_table = arg_val(2)
  #let l_file = l_table || ".unl"

  try
    database l_db
    load from "country.unl" insert into country
    load from "title.unl" insert into title
  catch
    display "ERROR: ", SQLCA.SQLERRM
  end try

end main
