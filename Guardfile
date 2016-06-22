guard :rspec, cmd: 'bundle exec rspec' do

  watch(%r{^lib/(.+).rb$})                   { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/(.+).rb$})                  { |m| "spec/#{m[1]}.rb" }
  watch(%r{spec/sample_data/.+.tfstate$})    { |m| "spec/generate_spec.rb" }
  watch(%r{^reports/.*.erb$})                { |m| "spec/generate_spec.rb" }
  watch('main.rb')                           { |m| "spec/main_spec.rb" }

end
