module Mengine
  module Base
    def exec_command command
      Kernel::system command
    end    
  end
end
