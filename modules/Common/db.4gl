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

--% package Common

import FGL fgldbutl

type
  tRDS record
    driver string,
    region string,
    server string,
    port string,
    name string,
    user string,
    password string,
    certs string,
    args string,
    isRDS boolean
  end record



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
    let l_status = fgldbutl.db_start_transaction()
  when "C"  #Commit
    let l_status = fgldbutl.db_finish_transaction(TRUE)
  when "R"  #Rollback
    let l_status = fgldbutl.db_finish_transaction(FALSE)
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
  return IIF(fgldbutl.db_start_transaction() = 0, TRUE, FALSE)
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
  return IIF(fgldbutl.db_finish_transaction(TRUE) = 0, TRUE, FALSE)
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
  return IIF(fgldbutl.db_finish_transaction(FALSE) = 0, TRUE, FALSE)
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

  -- implicitly close previous db and open this one
  try
    if IsRDS()
    then
      let status = RDS_Connect()
    else
      database p_database
    end if
  catch
  end try

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

  display sfmt("db.Connect(%1, %2, %3)", p_connect, p_user, p_password)
  connect to p_connect user p_user using p_password

  return status
  
end function


#
#! AWS_RDStoken
#+ Generate an RDS authentication token. Return the token and a return value 0 on success.
#+ In case of failure, return error output and shell's error code.
#+
#+ @param p_server      FQDN or IP of the server on which the RDS database is hosted
#+ @param p_port        Database's port
#+ @param p_region      AWS region in which the database is hosted
#+ @param p_user        Database user to connect as
#+
#+ @returnType          String
#+ @return              AWS RDS connection Token
#

public function AWS_RDStoken(p_server string, p_port string, p_region string, p_user string)
  returns string

  define
    ch_pipe base.Channel,
    p_cmd string,
    p_token string

	# build command to generate the token
	let p_cmd = sfmt("sudo -E /usr/local/bin/aws rds generate-db-auth-token --hostname %1 --port %2 --region %3 --username %4 2>/dev/null", p_server, p_port, p_region, p_user)

	# read token from pipe
    let ch_pipe = base.Channel.create()
    call ch_pipe.openPipe(p_cmd, "r")
    let p_token = ch_pipe.readLine()
    call ch_pipe.close()

    # trim spaces from the token
	return p_token.trimWhiteSpace()

end function


#
#! LCAP_RDStoken
#+ For lack of a product name, using our LCAP GAS image, gets the connection parameters fron the GAS pod environment
#+ and calls AWS_RDStoken to retrieve the database connection token
#+
#+ @returnType          String
#+ @return              AWS RDS connection Token
#

public function LCAP_RDStoken(p_platform string)
  returns string

  case p_platform.toUpperCase()
    when "AZURE"
    otherwise
      # default to AWS
      return AWS_RDStoken(
        fgl_getenv("HC_DBSERVER"),
        nvl(fgl_getenv("HC_DBPORT"), "5432"),
        nvl(fgl_getenv("AWS_REGION"), fgl_getenv("AWS_DEFAULT_REGION")),
        fgl_getenv("HC_DBUSER"))
  end case

  return ""

end function


#
#! RDS_Connect
#+ Connect to database via RDS
#

public function RDS_Connect()
  returns integer

  define
    a_dbPorts dictionary of string =
      (
      "dbmifx": "28177",
      "dbmpgs": "5432",
      "dbmmys": "3306"
      ),
    p_dbSpec string

  var
    r_db tRDS =
      (
      driver: fgl_getenv("HC_DBDRIVER"),
      region: nvl(fgl_getenv("AWS_REGION"), fgl_getenv("AWS_DEFAULT_REGION")),
      server: fgl_getenv("HC_DBSERVER"),
      port: fgl_getenv("HC_DBPORT"),
      name: fgl_getenv("HC_DBNAME"),
      user: fgl_getenv("HC_DBUSER"),
      certs: fgl_getenv("HC_DBCERTS"),
      isRDS: IsRDS()
      )

  # check if requried connection params are there
  if r_db.port is null
  then
    let r_db.port = a_dbPorts[r_db.driver]
  end if

  # %%% we should check all the other params here ...

  # Get token if RDS
  case r_db.driver
    when "dbmpgs"
      if r_db.isRDS
      then
        let r_db.password = LCAP_RDStoken("AWS")
        let r_db.args = sfmt("?sslmode=verify-full&sslrootcert=%1", r_db.certs)
      end if
  end case

  # Build db spec:  name@server:port+driver='dbmxxx'
  let p_dbSpec = sfmt("%1%2%3%4%5",
    r_db.name,
    iif(r_db.server.getLength(), sfmt("@%1", r_db.server), ""),
    iif(r_db.port.getLength(), sfmt(":%1", r_db.port), ""),
    r_db.args,
    iif(r_db.driver.getLength(), sfmt("+driver='%1'", r_db.driver), ""))

  # Connect
  var p_stat integer = Connect(p_dbSpec, r_db.user, r_db.password)

  return p_stat

end function


#
#! IsRDS
#+ Returns if database connection is RDS
#+
#+ @returnType          Boolean
#+ @return              TRUE if RDS, else FALSE
#
public function IsRDS()
  returns boolean

  return (nvl(fgl_getenv("HC_DBISRDS"), "NO") == "YES")

end function