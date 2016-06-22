# Generate report from supplied tfstate file and an ERB template.
# Some canned ERB reports are provided in the "reports" subfolder.
#
# Usage:
# ruby main.rb <path_to_tfstate> <path_to_erb>
#
# Example:
# ruby main.rb spec/sample_data/terraform.tfstate reports/short.erb
#
# path_to_erb defaults to 'reports/standard.erb' if not specified.
#

require_relative 'lib/generate'

# Generate a report for terraform state file on output stream
# ostream
def main(tfstate_path, options = {})
  ostream = options[:ostream] || $stdout
  erb_template = options[:erb_template] || File.join(File.dirname(__FILE__), 'reports', 'standard.erb')
  raise "Filename required" if tfstate_path.nil?
  raise "Missing file #{tfstate_path}" unless File.exist?(tfstate_path)
  raise "Missing template #{erb_template}" unless File.exist?(erb_template)
  s = generate_report(tfstate_path, erb_template)
  ostream.puts s
end

if __FILE__==$0
  options = { :ostream => $stdout, :erb_template => ARGV[1] }
  main(ARGV[0], options)
end
