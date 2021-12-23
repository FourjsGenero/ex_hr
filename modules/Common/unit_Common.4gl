#
# unit_Common.4gl  Unit tests for Common module
#

-- import fgl db
-- import fgl Common.str
-- import fgl Common.*
import FGL std
import FGL db
import FGL str



#
# Main: Unit Test
#

main

  call Setup()
  call Run("STR")
  call Teardown()
  
end main



#
#! Run
#
public function Run(p_request string)

  case p_request
    when "STR"
      call test_Hash()
  end case
  
end function


#
#! Setup
#
private function Setup()

    -- var unused = 1
    
end function


#
#! Teardown
#
private function Teardown()
  
end function


#
#! test_Hash
#
private function test_Hash()
  
  var p_hash = str.Hash("SHA1", "foo")
  if p_hash = "C+7Hteo/D9vJXQ3UfzxbwnXaijM="
  then
    display "Hash(SHA1,foo): OK"
  else
    display "Hash(SHA1,foo): FAILED with ", p_hash
  end if
  
end function
