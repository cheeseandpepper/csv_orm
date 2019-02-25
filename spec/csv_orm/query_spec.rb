require 'spec_helper'

describe CsvOrm::Query do
  let(:path)          { File.expand_path("spec/fixtures/mock_data.csv") }
  let(:ingested_data) { CsvOrm::Ingestor.new(path).parse }
  let(:subject)       { described_class.new(ingested_data) }

  describe '#size' do
    it 'it returns the size of the dataset' do
      #mock_data has 1000 rows, it is known.
      expect(subject.size).to eq(1000)
    end
  end

  describe '#build_expression' do
    it 'builds an expression for a single key value pair' do
      expression = subject.build_expression('&&', {foo: 'bar'})
      expect(expression).to eq("row.send(:foo) == 'bar'")
    end

    it 'builds an && expression for multiple key value pairs' do
      expression = subject.build_expression('&&', {foo: 'bar', baz: 'biz'})
      expect(expression).to eq("row.send(:foo) == 'bar' && row.send(:baz) == 'biz'")
    end

    it 'builds an || expression for multiple key value pairs' do
      expression = subject.build_expression('||', {foo: 'bar', baz: 'biz'})
      expect(expression).to eq("row.send(:foo) == 'bar' || row.send(:baz) == 'biz'")
    end

    context 'mixed data types' do
      it 'can build a complex query' do
        # 2 Bari, 2 Brit
        expression = subject.build_expression('&&', {first_name: ['Bari', 'Brit'], admin: true})
        expect(expression).to eq "[\"Bari\", \"Brit\"].include?(row.send(:first_name)) && row.send(:admin) == 'true'"
      end
    end
  end


  context 'ranges' do
    context 'date range' do
      let(:begin_date) { DateTime.parse('2018-01-01').to_time.to_i }
      let(:end_date)   { DateTime.parse('2018-05-05').to_time.to_i }
      let(:in_range)   { DateTime.parse('2018-03-03').to_time.to_i }
      let(:out_range)  { DateTime.parse('2018-10-01').to_time.to_i }

      it 'can query for date within range' do
        mock_range_date = [
          OpenStruct.new(created_at: in_range),
          OpenStruct.new(created_at: out_range)
        ]
        
        mock_query = CsvOrm::Query.new(mock_range_date)
        expect(mock_query.where({created_at: (begin_date..end_date)}).size).to eq(1)
      end
    end
  end

  describe '#not' do
    it 'returns dataset not meeting the condition' do
      expect(subject.not({admin: true}).size).to eq(510)
    end
  end

  describe '#where_any' do
    it 'returns a dataset meeting the || condition' do
      #490 admin, 1, Emilie Bartaloni who is not an admin
      expect(subject.where_any({admin: true, last_name: 'Bartaloni'}).size).to eq(491)
    end
  end

  describe '#where' do
    it 'returns a dataset meeting the && condition' do
      #510 non admins
      expect(subject.where({admin: false}).size).to eq(510)
      expect(subject.where({admin: false, last_name: 'Bartaloni'}).size).to eq(1)
    end
  end

  describe '#aggregate' do
    #490 admin, 510 non admin
    it 'returns the counts for all values given a key' do
      admin_aggregate = subject.aggregate(:admin)
      expect(admin_aggregate[:admin]['true']).to eq(490)
      expect(admin_aggregate[:admin]['false']).to eq(510)
    end
  end
end