module CsvOrm
  class Ingestor
    attr_accessor :file, :path, :headers, :headers_defined, :data_set

    def initialize(file_path, options={})
      @path            = File.expand_path(file_path)
      @file            = File.open(path)
      @headers         = [] # will define in first iteration of loop
      @headers_defined = false
      @data_set        = []
      @smart           = options[:smart] == false ? false : true
    end

    def parse
      CSV.parse(file) do |row|
        unless @headers_defined
          @headers = row.map {|header| header.gsub(' ', '_').downcase.to_sym }
        end
        parsed_row = row.map {|field| infer_data_type(field) }
        @data_set << OpenStruct.new(Hash[headers.zip(parsed_row)]) if @headers_defined
        @headers_defined = true
      end
      true # suppress potentially massive @data_set
    end

    def infer_data_type(field)
      # currently supporting time to integer conversion
      return field.to_s unless @smart
      date = DateTime.parse(field) rescue nil
      if date
        return date.to_time.to_i
      end
      field.to_s
    end
  end
end
