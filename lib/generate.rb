# Generate a report from transformed data.
require 'json'
require 'pp'
require 'erb'
require_relative 'transform'

################
# ERB Report

# Ref http://www.stuartellis.eu/articles/erb/
class TemplateSource
  def initialize(hsh)
    @hsh = hsh
  end
  def get_binding
    binding()
  end
end

# Generate a report using a supplied ERB template string.
def generate_report(filename, template)
  file = File.read(filename)
  data_hash = JSON.parse(file)
  rpt_data = transform(data_hash)

  # Re http://stackoverflow.com/questions/1887845/add-method-to-an-instanced-object
  d = TemplateSource.new(rpt_data)

  template = File.read(template) if File.exist?(template)
  renderer = ERB.new(template, nil, '<>')
  renderer.result(d.get_binding)
end

################
# Tabular report

# Generate report using all of the headings from the report data.
def generate_tabular_report(filename, ostream)
  file = File.read(filename)
  data_hash = JSON.parse(file)
  rpt_data = transform(data_hash)
  rpt_data.keys.each do |name|
    ostream.puts
    ostream.puts name
    tbl = create_resources_table(rpt_data[name]['resources'])
    tbl.each do |r|
      ostream.puts r.join("\t")
    end
  end
end

# Returns array of transformed resource data.  First row contains
# table headings which are sourced from the resource attributes.
def create_resources_table(flattened_resources)
  table = []
  if (flattened_resources.nil? || flattened_resources.size == 0)
    return table
  end

  # Headings.
  base_headings = [ 'resource', 'type', 'depends_on', 'instance', 'id' ]
  attr_headings = []
  flattened_resources.each do |r|
    r['attributes'].keys.each do |k|
      attr_headings << k unless attr_headings.include?(k)
    end
  end
  table << base_headings + attr_headings

  # Resource data corresponding to headings.
  flattened_resources.each do |r|
    table << get_resource_row(r, attr_headings)
  end

  table
end

def get_resource_row(hsh, attr_headings)
  data = [
    hsh['name'],
    hsh['type'],
    hsh['depends_on'].nil? ? nil : hsh['depends_on'],
    hsh['instance'],
    hsh['id']
  ]
  attr_headings.each do |attr|
    s = hsh['attributes'][attr]
    data << s
  end
  data
end
