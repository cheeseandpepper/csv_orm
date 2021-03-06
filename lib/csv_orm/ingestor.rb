module CsvOrm
  class Ingestor
    attr_accessor :file, :path, :headers, :headers_defined, :data_set, :options

    def initialize(file_path, options={})
      @path            = File.expand_path(file_path)
      @file            = File.open(path)
      @headers         = [] # will define in first iteration of loop
      @headers_defined = false
      @data_set        = []
      @smart           = options[:smart] == false ? false : true
      @logging         = options[:logging]
    end

    def self.build(path, options)
      self_instance = new(path, options)
      Query.new(self_instance.parse)
    end

    def parse
      begin_time = Time.now
      CSV.parse(file) do |row|
        unless @headers_defined
          @headers = row.map {|header| header.gsub(/[ -]/, '_').downcase.to_sym }
        end
        parsed_row = row.map {|field| infer_data_type(field) }
        @data_set << OpenStruct.new(Hash[headers.zip(parsed_row)]) if @headers_defined
        @headers_defined = true
        puts "Parsed row #{$.}" if @logging
      end
      end_time = Time.now
      puts "Parsed #{@file.path} in #{end_time - begin_time} seconds" if @logging
      @data_set
    end

    def infer_data_type(field)
      # currently supporting time to integer conversion
      return field.to_s unless @smart

      # integers are almost certainly not meant to be time. probably will have to address this at some point.
      return field if confidence_in_numeric?(field)

      date = DateTime.parse(field) rescue nil
      if date
        return date.to_time.to_i
      end
      field.to_s
    end

    def confidence_in_numeric?(string)
      return true if string =~ /\A\d+\Z/
      true if Float(string) rescue false
    end
  end
end
