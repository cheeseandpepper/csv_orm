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

    def where_any(attrs)
      expression = build_expression('||', attrs)
      self.class.new(@data.select {|row| eval(expression)});
    end

    def where_all(attrs)
      expression = build_expression('&&', attrs)
      self.class.new(@data.select {|row| eval(expression)});
    end

    def build_expression(conditional, attrs)
      attrs.each_with_object([]) { |(k,v), array| array << "row.send(:#{k}) == '#{v}'" }.join(" #{conditional} ")
    end
  end
end
