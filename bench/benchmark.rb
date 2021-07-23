require 'bundler/setup'

require 'sober_swag'

require 'yaml'
require 'benchmark/ips'

##
# Quick and dirty way to benchmark things.
class Bench
  class << self
    def report(name, &block)
      puts name

      data[name] ||= Benchmark.ips(&block).data
    end

    def data
      @data ||= {}
    end

    def write!(filename)
      File.open(filename, 'w') do |f|
        f << YAML.dump(data)
      end
    end
  end
end

Dir['bench/benchmarks/**/*.rb'].sort.each do |file|
  require_relative file.gsub(%r{^bench/}, '')
end

Bench.write!('benchmark_results.yaml')
