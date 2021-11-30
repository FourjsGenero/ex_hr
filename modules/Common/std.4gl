#
# std.4gl   Standard definitions
#

--% package Common

public type
  tValidationStatus
    record
      ok boolean,
      error string,
      row integer,
      field string
    end record


#
# METHODS
#

public function (this tValidationStatus) New()

  let this.ok = TRUE
  let this.error = ""
  let this.row = 0
  let this.field = ""

end function
