module CsvOrm
  class Ingestor
    attr_accessor :file, :path, :headers, :headers_defined, :data_set

    def initialize(file_path)
      @path            = File.expand_path(file_path)
      @file            = File.open(path)
      @headers         = [] # will define in first iteration of loop
      @headers_defined = false
      @data_set        = []
    end

    def parse
      CSV.parse(file) do |row|
        unless @headers_defined
          @headers = row.map {|header| header.gsub(' ', '_').downcase.to_sym }
        end
        @data_set << OpenStruct.new(Hash[headers.zip(row.map(&:to_s))]) if @headers_defined
        @headers_defined = true
      end
      @data_set
    end
  end
end
