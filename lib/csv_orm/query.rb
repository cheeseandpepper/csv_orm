module CsvOrm
  class Query
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def size
      @data.size
    end

    def aggregate(*fields)
      agg = {}
      @data.each do |row|
        fields.each do |field|
          agg[field] ||= {}
          agg[field][row.send(field)] ||= 0
          agg[field][row.send(field)] += 1
        end
      end
      agg
    end

    def explain(method, args)
      case
      when method == :where 
        build_expression('&&', args)
      when method == :where_any
        build_expression('||', args)
      else
        'not supported at this time'
      end
    end
    
    def where_any(attrs)
      expression = build_expression('||', attrs)
      self.class.new(@data.select {|row| eval(expression)});
    end

    def where(attrs)
      expression = build_expression('&&', attrs)
      self.class.new(@data.select {|row| eval(expression)});
    end

    def not(attrs)
      expression = build_expression('&&', attrs)
      self.class.new(@data.reject {|row| eval(expression)});
    end

    def parse_range_values(range)
      exclude = range.exclude_end?
      first, last = DateTime.parse(range.begin), DateTime.parse(range.end) rescue nil
  
      if first && last
        Range.new(first.to_time.to_i, last.to_time.to_i, exclude)
      else
        range
      end
    end

    def build_expression_part(key, value)
      case
      when value.class == String
        "row.send(:#{key}) == '#{value}'"
      when value.class == Regexp
        "row.send(:#{key}).match(/#{value.source}/)"
      when value.class == Array
        "#{value}.include?(row.send(:#{key}))"
      when value.class == Range
        parsed_range_value = parse_range_values(value)
        "(#{parsed_range_value}).cover?(row.send(:#{key}))"
      when [TrueClass, FalseClass].include?(value.class)
        "row.send(:#{key}) == '#{value.to_s}'"
      end
    end

    def build_expression(conditional, attrs)
      string   = ''
      is_first = true

      attrs.each do |k, v|
        string << " #{conditional} " unless is_first
        string << build_expression_part(k, v)
        
        is_first = false
      end
      string
    end
  end
end
