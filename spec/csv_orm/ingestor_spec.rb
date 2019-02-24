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
end