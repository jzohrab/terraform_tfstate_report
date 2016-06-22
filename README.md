# Terraform tfstate Reporter

This tool generates node summary reports from a
[Terraform](https://www.terraform.io/) .tfstate file, such as the
following:

```
name    ip       id    cluster  module
web     1.1.1.1  id1   A        backend
db      2.2.2.2  id2   A        backend
nagios  3.3.3.3  id3   B        tools
```

Reports are defined using ERB.


## Usage

```
$ ruby main.rb <path_to_tfstate> <path_to_report_erb>
```

Some report samples are in the `reports` subdirectory.  It defaults to
`reports/standard.erb` if not specified.

Example (tab-delimited output for import into spreadsheet):

```
$ ruby main.rb spec/sample_data/terraform.tfstate reports/short.erb
name	ip	id	cluster	module
Luke	1.2.3.4	id1	P1	root.nodes_backend
Leia	2.3.4.5	id2	P1	root.nodes_backend
Solo	6.7.8.9	id3	P3	root.nodes_opstools
Chewie	1.1.1.1	id4	P3	root.nodes_opstools
```

The Markdown sample report `reports/short.md.erb` generates the following:

|name|ip |id |cluster|module|
|--- |---|---|---    |---   |
|Luke|1.2.3.4|id1|P1|root.nodes_backend|
|Leia|2.3.4.5|id2|P1|root.nodes_backend|
|Solo|6.7.8.9|id3|P3|root.nodes_opstools|
|Chewie|1.1.1.1|id4|P3|root.nodes_opstools|


### Prerequisities

* Ruby
* [Bundler](http://bundler.io/): `gem install bundler`


### Installing

`$ bundle install` installs the following:

* [RSpec](http://rspec.info/)
* [Guard](https://github.com/guard/guard) and guard-rspec

If you don't want to install Guard, use `$ bundle install --without development`.


## Running the tests

If you've installed Guard, you can open a dedicated console window and
type `guard`.  Guard will observe selected files on disk (see the
`Guardfile`) and automatically run the spec tests on file change.

Run tests manually from console with `$ rspec`.
