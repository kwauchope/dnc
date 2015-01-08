require "spec_helper"

describe DN do
  let!(:raw_dn) { '/C=US/O=RB/OU=DEV/OU=JS/OU=People/CN=Last First M (initial)' }
  let!(:dn_to_s) { 'CN=LAST FIRST M (INITIAL),OU=PEOPLE,OU=JS,OU=DEV,O=RB,C=US' }
  let(:valid_subject) { DN.new(dn_string: raw_dn) }
  let(:dn_elements) { ["C=US", "O=RB", "OU=DEV", "OU=JS", "OU=PEOPLE", "CN=LAST FIRST M (INITIAL)"] }

  #
  # Unit specs
  #

  describe "#new" do

    it "should create a new DN object when valid" do
      expect(valid_subject.class.to_s).to eq(DN.to_s)
    end

    it "should identify the most likely delimiter" do
      expect(valid_subject.delimiter).to eq('/')
      %w(, ; - _ : \\ % ^ ! & * @ # $).each do |delim|
        custom_delim_subject = DN.new(dn_string: raw_dn.gsub('/',delim))
        expect(custom_delim_subject.delimiter).to eq(delim)
      end
    end

    it "should split on identified delimiter" do
      expect(valid_subject.split_by_delimiter).to eq(dn_elements)
    end

    it "should parse each key value pair and assign an attribute" do
      expect(valid_subject.c).to eq('US')
      expect(valid_subject.o).to eq('RB')
    end

    it "should return appropriate attrs as arrays" do
      [:ou, :dc].each do |array_wrapped_el|
        dn = DN.new(dn_string: '/C=US/O=RB/OU=DEV/OU=JS/OU=People/DC=example/DC=org/CN=Last First M (initial)')
        expect(dn.dc).to eq(['ORG', 'EXAMPLE'])
        expect(dn.ou).to eq(['PEOPLE', 'JS', 'DEV'])
      end
    end

    it "should handle multiple RDN key value pairs in the CN and return an array of elements" do
      dn = DN.new(dn_string: '/C=US/O=RB/OU=DEV/OU=JS/OU=People/DC=example/DC=org/CN=Last First M (initial)+email=initial@example.org')
      expect(dn.cn).to eq(['INITIAL@EXAMPLE.ORG', 'LAST FIRST M (INITIAL)'])
    end
  end

  describe "validations" do

    it "should require a parsable DN string" do
      pending 'pending'
    end

  end

end
