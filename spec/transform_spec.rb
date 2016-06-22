require 'json'
require_relative '../lib/transform'

RSpec.describe "transform" do

  ################################
  # Helpers: build test data sets.
  
  BASE_DATA = "{
    'version': 1,
    'serial': 136,
    'modules': [
        { 'path': [ 'root' ], 'outputs': {}, 'resources': {} },
        {
            'path': [ 'root', 'backend' ],
            'outputs': {},
            'resources': { DATA_HERE }
	}
	]
}"

  RESOURCE1 = "'resource1': {
         'type': 'A',
         'primary': {
             'id': 'id1',
             'attributes': { 'a': 'a1', 'b': 'b1', 'c': 'c1' }
         }
     }"

  RESOURCE2 = "'resource2': {
         'type': 'A',
         'primary': {
             'id': 'id2',
             'attributes': { 'a': 'a2', 'b': 'b2', 'd': 'd2' }
         }
     }"

  TAINTED = "'resource3': {
         'type': 'A',
         'primary': null,
         'tainted': [
           { 'id': 't1', 'attributes': { 'a': 'at1', 't': 'tt1' } },
           { 'id': 't2', 'attributes': { 'b': 'bt2', 'd': 'dt2' } }
         ]
      }"

  def build_test_json(*resource_array)
    test_data = resource_array.join(", ")
    data = BASE_DATA.gsub("DATA_HERE", test_data)
    JSON.parse(data.gsub("'", "\""))
  end

  
  ######################
  # Tests

  describe "#flatten_resources" do

    context "when modules contains a single primary resource" do

      let (:test_data) { build_test_json(RESOURCE1) }
      let (:first_resource) { flatten_resources(test_data['modules'][1]['resources'])[0] }
      
      it "converts the resources list to an array, each entry of which is a hash" do
        a = flatten_resources(test_data['modules'][1]['resources'])
        expect(a).to be_a(Array)
        expect(a.size).to eq(1)
        a.each do |i|
          expect(i).to be_a(Hash)
        end
      end

      it 'sets the resource name as a Hash entry' do
        expect(first_resource['name']).to eq('resource1')
      end
      
      it 'sets instance = primary' do
        expect(first_resource['instance']).to eq('primary')
      end

      it 'moves the attributes to an "attributes" key' do
        expect(first_resource['attributes']).to be_a(Hash)
      end
    end

    context "when modules contains a single tainted resource" do

      let (:test_data) { build_test_json(TAINTED) }
      let (:first_resource) { flatten_resources(test_data['modules'][1]['resources'])[0] }
      
      it "converts the resources list to an array, each entry of which is a hash" do
        a = flatten_resources(test_data['modules'][1]['resources'])
        expect(a).to be_a(Array)
        a.each do |i|
          expect(i).to be_a(Hash)
        end
      end

      it 'puts each tainted entry into its own resource array element' do
        a = flatten_resources(test_data['modules'][1]['resources'])
        expect(a.size).to eq(2)
      end
      
      it 'sets instance = tainted' do
        expect(first_resource['instance']).to eq('tainted')
      end

      it 'moves the attributes to an "attributes" key' do
        expect(first_resource['attributes']).to be_a(Hash)
      end

    end

    context "when module contains nothing" do

      let (:test_data) do
        d = "{
    'version': 1,
    'serial': 136,
    'modules': [ { 'path': [ 'root' ], 'outputs': {}, 'resources': {} } ] }"
        JSON.parse(d.gsub("'", "\""))
      end

      it "runs without failure" do
        expect { transform(test_data) }.not_to raise_error
      end

    end
    
  end

  
  context "with basic test data" do

    let(:transformed_data) do
      transform(build_test_json(RESOURCE1, RESOURCE2))
    end

    let(:resources) do
      transformed_data['root.backend']['resources']
    end

    it "runs without error" do
      expect { transformed_data }.not_to raise_error
    end

    it "returns a hash, with each module's root as the key" do
      h = transformed_data
      expect(h).to be_a(Hash)
      expect(h).to have_key("root")
      expect(h).to have_key("root.backend")
    end

    it "puts data in the resource rows matching the headings" do
      expected1 = {"type"=>"A", "name"=>"resource1", "depends_on"=>nil, "instance"=>"primary", "id"=>"id1", "attributes"=>{"a"=>"a1", "b"=>"b1", "c"=>"c1"}}
      expect(resources[0]).to eq(expected1)
    end
  end

  context "with test data with single tainted resource" do

    let(:transformed_data) do
      transform(build_test_json(TAINTED))
    end

    let(:resources) do
      transformed_data['root.backend']['resources']
    end

    it "runs without error" do
      expect { transformed_data }.not_to raise_error
    end

    it "puts each tainted resource in its own record" do
      expect(resources.size).to eq(2)
    end
    
    it "flattens the tainted resources" do
      t = resources[0]
      expected = { 'name' => 'resource3', 'instance' => 'tainted' }
      expected.each do |attr_name, val|
        expect(t[attr_name]).to eq(val)
      end
      expect(t['attributes']['a']).to eq('at1')
    end

  end


  context "with dependencies" do

    let(:transformed_data) do
      type = "'type': 'A',"
      tmp = "'depends_on': [ 'x', 'y' ],"
      r = RESOURCE1.gsub(type, "#{type} #{tmp}")
      transform(build_test_json(r))
    end

    let(:resources) do
      transformed_data['root.backend']['resources']
    end

    it "includes dependencies" do
      expect(resources[0]['depends_on']).to eq('x, y')
    end
  end
  

  context "with a real file" do
    let(:sample) { File.join(File.dirname(__FILE__), "sample_data/terraform.tfstate") }
    
    it "runs without error" do
      data = JSON.parse(File.read(sample))
      ret = transform(data)
    end
  end


end


