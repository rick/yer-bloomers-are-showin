#!/usr/bin/env ruby

require 'bloom-filter'
require 'posix/spawn'

# usage:
#
# $0 <path-to-bloom-filter> <path-to-repository> [ <path-to-repository> ... ]
def usage
  "#{$0} <path-to-bloom-filter> <path-to-repository> [ <path-to-repository> ... ]\n"
end

filter_path = ARGV.shift || raise(usage)
repos = ARGV.dup
raise(usage) if repos.empty?

filter = if File.exists?(filter_path)
  BloomFilter.load(filter_path)
else
  BloomFilter.new(size: 1_000_000, error_rate: 0.01)
end

total = 0
repos.each do |repo|
  child = POSIX::Spawn::Child.new('git', 'rev-list', '--all', :chdir => repo)
  count = 0
  child.out.split("\n").each do |commit|
    count += 1	
    filter.insert commit
  end
  puts "Encountered #{count} commits in repo #{repo}"
  total += count
end

puts "Writing bloom filter with #{total} commits to [#{filter_path}]..."
filter.dump(filter_path)
