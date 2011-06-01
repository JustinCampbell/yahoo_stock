module YahooStock
  
  class Conversion < Base
    
    def self.convert(parameter, data)
      @@convert ? "Conversion placeholder for #{data}" : data
    end
    
  end
  
end
