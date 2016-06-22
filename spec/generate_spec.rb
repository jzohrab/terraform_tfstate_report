require_relative '../lib/generate'
require 'stringio'

RSpec.describe "generate" do

  let(:sample_filename) { File.join(File.dirname(__FILE__), "sample_data", "terraform.tfstate") }

  context "#generate_tabular_report" do

    it "runs without failure" do
      output = StringIO.new
      expect { generate_tabular_report(sample_filename, output) }.not_to raise_error
    end

  end


  context "#generate_report" do

    def report_filename(f)
      return File.expand_path(File.join(File.dirname(__FILE__), '..', 'reports', f))
    end

    %w(standard.erb short.erb short.md.erb).each do |canned_report|
      context canned_report do
        it "runs without failure" do
          expect { generate_report(sample_filename, report_filename(canned_report)) }.not_to raise_error
        end

        it "generates a decent report" do
          content = generate_report(sample_filename, report_filename(canned_report))
          # Not bothering to check whole content due to length ...
          expect(content).to match("root.nodes_backend")
        end
      end
    end

    context "using erb string" do

      let(:template) do
        data = <<HERE
id	name

<% @hsh.keys.each do |m| %>
Module: <%= m %>
<% @hsh[m]['resources'].each do |r| %>
<%= [ r['id'], r['name'] ].join('\t') %>

<% end %>
<% end %>
HERE
      end

      it "runs without failure" do
        expect { generate_report(sample_filename, template) }.not_to raise_error
      end

      it "generates content correctly" do
        content = generate_report(sample_filename, template)
        expected = <<HERE
id	name

Module: root
Module: root.nodes_backend
id1	VM1
id2	VM2
Module: root.nodes_opstools
id3	VM3
id4	VM4
HERE
        expect(content).to eq(expected)
      end

    end

  end

end


