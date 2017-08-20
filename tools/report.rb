#!/usr/bin/env ruby
require 'json'
require 'pathname'

class Report
  attr_accessor :stats, :dirs
  def initialize(dirs)
    @stats = { layer: [] }
    @dirs = dirs || []
    report!
  end

  def self.run(paths)
    dirs = {}
    paths.each do |path|
      Dir.glob("#{path}/**/*") do |fn|
        p = Pathname(fn)
        dirs[p.dirname] = true if p.file?
      end
    end

    report = Report.new(dirs.keys.to_a.sort.uniq)
    JSON.pretty_generate(report.stats)
  end

  private

  def report!
    dirs.each { |dir| collect_stats(dir) if count_files(dir).positive? }
    stats[:layer_count] = stats[:layer].size
  end

  def collect_stats(dir)
    stats[:layer] << dir
    Dir.glob("#{dir}/*").each do |path|
      next if Pathname(path).directory?
      k = Pathname(path).basename.to_s
      stats[k] ||= 0
      stats[k] += 1
    end
  end

  def count_files(dir)
    Dir.glob("#{dir}/*").each.reject { |path| Pathname(path).directory? }.size
  end
end

puts Report.run(ARGV)
