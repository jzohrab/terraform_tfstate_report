# Transform .tfstate file into consumable data.
def transform(json)
  ret = {}
  json['modules'].each do |m|
    resources_hsh = m['resources']
    ret[ m['path'].join('.') ] = { 'resources' => flatten_resources(resources_hsh) }
  end
  ret
end

# Resources can be primary instances, or tainted intances.  There can
# be multiple tainted instances of a resource.  Flattening here means
# create a separate resource (with identical values) for each tainted
# array entry.
def flatten_resources(resources_hash)
  if (resources_hash.nil?)
    return [ {} ]
  end
  
  rsrc_array = []
  resources_hash.each do |name, hsh|
    hsh['name'] = name
    hsh['depends_on'] = (hsh['depends_on'].nil? ? nil : hsh['depends_on'].join(', '))
    rsrc_array << hsh
  end

  ret = []
  rsrc_array.each do |attrs|
    r = attrs.clone
    if (attrs['primary']) then
      r['instance'] = 'primary'
      r['id'] = attrs['primary']['id']
      r['attributes'] = attrs['primary']['attributes']
      r.delete('primary')
      ret << r
    end

    if (attrs['tainted']) then
      r['instance'] = 'tainted'
      r['tainted'].each do |tainted_row|
        a = r.clone
        a['id'] = tainted_row['id']
        a['attributes'] = tainted_row['attributes']
        a.delete('tainted')
        ret << a
      end
    end
  end
  ret
end
