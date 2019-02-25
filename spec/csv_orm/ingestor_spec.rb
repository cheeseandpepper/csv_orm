require 'spec_helper'

describe CsvOrm::Ingestor do
  let(:path) { File.expand_path("spec/fixtures/mock_data.csv") }
  let(:subject) { described_class.new(path) }

  describe '.new' do
    it 'instantiates with a file object' do
      expect(subject.file.class).to eq(File)
    end
  end

  describe '#parse' do
    it 'creates an array of open structs' do
      data = subject.parse
      expect(data.all? { |row| row.class == OpenStruct }).to eq(true)
    end

    it 'converts headers into underscore accessors' do
      # actual headers ['id', 'First Name', 'Last Name', 'email', 'gender', 'IP Address', 'admin', 'subscribed_at', 'canceled_at']
      expected_accessors = [:id, :first_name, :last_name, :email, :gender, :ip_address, :admin, :subscribed_at, :canceled_at] 

      first_row = subject.parse.first
      expected_accessors.each do |accessor|
        expect(first_row.respond_to?(accessor)).to eq(true)
      end
    end
  end

  describe '#confidence_in_numeric?' do
    let(:numerics)     { ['1', '1.2', '0.09', '999999999'] }
    let(:non_numerics) { ['1a', 'a1', '1.0.9', '1.a3', '1-2'] }

    it 'returns true for numerics' do
      numerics.each do |num|
        expect(subject.confidence_in_numeric?(num)).to eq(true)
      end
    end

    it 'returns false for non_numerics' do
      non_numerics.each do |num|
        expect(subject.confidence_in_numeric?(num)).to eq(false)
      end
    end
  end
end