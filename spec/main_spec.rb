require_relative '../main'
require 'stringio'

RSpec.describe "main" do

  let (:sample_file) do
    path = [File.dirname(__FILE__), '..', 'spec', 'sample_data', 'terraform.tfstate']
    File.expand_path(File.join(path))
  end

  let (:io) { StringIO.new }

  context "when called" do

    it "runs without failure" do
      expect { main(sample_file, :ostream => io) }.not_to raise_error
    end

    it "fails if missing tfstate file" do
      f = 'x.tfstate'
      expect { main(f, :ostream => io) }.to raise_error(RuntimeError, 'Missing file x.tfstate')
    end

  end

  context "when called with specific template file" do
    it "runs without failure" do
      erb_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'reports', 'short.erb'))
      expect { main(sample_file, :erb_template => erb_path, :ostream => io) }.not_to raise_error
    end
  end

  context "when called with missing template file" do
    it "fails" do
      erb_path = 'x.erb'
      expect { main(sample_file, :erb_template => erb_path, :ostream => io) }.to raise_error(RuntimeError, 'Missing template x.erb')
    end
  end

end


