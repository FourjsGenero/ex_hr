#
# db.4gl   Common Database methods
#
# PUBLIC
#! Transact     Database transaction
#! Begin        Begin a transaction
#! Commit       Commit a transaction
#! Rollback     Roll back a transaction
#! Open         Open a database
#! Connect      Open a conection to a database
#


#
#! Transact
#+ Database transactions: BEGIN, COMMIT or ROLLBACK work
#+ This is a wrapper to the FGL database functions in fgldbutl.4gl
#+
#+ @param p_transact    Transaction "BEGIN", "COMMIT", "ROLLBACK"
#+
#+ @returnType        Integer
#+ @return            status
#+
#+ @code
#+ if db.Transact("BEGIN") then
#+   ...
#+   let l_status = db.Transact("COMMIT")
#+   try
#+     -- ... some db transaction
#+     let l_status = db.Transact("COMMIT")
#+   catch
#+     let l_status = db.Transact("ROLLBACK")
#+   end try
#
public function Transact(p_transact string)
  returns (integer)

  define
    l_status integer

  let p_transact = p_transact.toUpperCase()
  
  case p_transact.getCharAt(1)
  when "B"  #Begin
    let l_status = db_start_transaction()
  when "C"  #Commit
    let l_status = db_finish_transaction(TRUE)
  when "R"  #Rollback
    let l_status = db_finish_transaction(FALSE)
  otherwise
    let l_status = 100  #notfound
  end case

  return l_status
  
end function


#
# for convenience
#

#
#! Begin
#+ Begin a transaction
#+
#+ @returnType          Boolean
#+ @return              TRUE if OK, else FALSE
#+
#+ @code
#+ if db.Begin() then
#+   # db statements ...
#

public function Begin()
  returns (boolean)
  return IIF(db_start_transaction() = 0, TRUE, FALSE)
end function

#
#! Commit
#+ Commit a transaction
#+
#+ @returnType          Boolean
#+ @return              TRUE if OK, else FALSE
#+
#+ @code
#+ if db.Commit() then
#

public function Commit()
  returns (integer)
  return IIF(db_finish_transaction(TRUE) = 0, TRUE, FALSE)
end function

#
#! Rollback
#+ Rollback a transaction
#+
#+ @returnType          Boolean
#+ @return              TRUE if OK, else FALSE
#+
#+ @code
#+ if db.Rollback() then
#

public function Rollback()
  returns (integer)
  return IIF(db_finish_transaction(FALSE) = 0, TRUE, FALSE)
end function


#
#! Open
#+ Open a database
#+
#+ @param p_database    Database name
#+
#+ @returnType          Integer
#+ @return              status
#+
#+ @code
#+ if db.Open("monitoring") != 0 then
#+   error "unable to open database"
#

public function Open(p_database string)
  returns (integer)

  -- if no database specified look at env DB
  if p_database.getLength() = 0
  then
    let p_database = fgl_getenv("DB")
  end if

  -- still no database, then not found
  if p_database.getLength() = 0
  then
    return NOTFOUND
  end if

  -- close previous db and open this one - IMPLICIT
  #try
  #  close database
  #catch
  #end try
  database p_database

  return status
  
end function



#
#! Connect
#+ Open a conection to a database
#+
#+ @param p_connect     Database name or connection string
#+ @param p_user        User ID
#+ @param p_password    Password
#+
#+ @returnType          Integer
#+ @return              status
#+
#+ @code
#+ if db.Connect("monitoring","ssykes","secret") != 0 then
#+   error "unable to connect to database"
#

public function Connect(p_connect string, p_user string, p_password string)
  returns (integer)

  connect to p_connect user p_user using p_password

  return status
  
end function

