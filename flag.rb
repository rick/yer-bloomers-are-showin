#!/usr/bin/env ruby

require 'bloom-filter'
require 'posix/spawn'

# usage:
#
# $0 <path-to-bloom-filter> <path-to-repository> [ <path-to-repository> ... ]
def usage
  "#{$0} <minimum-number-of-matching-commits> <path-to-bloom-filter> <path-to-repository> [ <path-to-repository> ... ]\n"
end

threshold = ARGV.shift.to_i
raise(usage) unless threshold > 0
filter_path = ARGV.shift || raise(usage)
repos = ARGV.dup
raise(usage) if repos.empty?

raise "Must create bloom filter [#{filter_path}] via add-known-repo.rb first!" unless File.exists?(filter_path)
filter = BloomFilter.load(filter_path)

bad = 0
repos.each do |repo|
  child = POSIX::Spawn::Child.new('git', 'rev-list', '--all', :chdir => repo)
  count = match = 0
  child.out.split("\n").each do |commit|
    count += 1	
    match += 1 if filter.include? commit
  end
  
  if match >= threshold
    bad += 1 
    pct = "%0.2f" % (match.to_f/count.to_f*100)
    puts "#{repo}\t#{match}\t#{pct}\tmatching commits in [#{repo}] (of #{count} total repo commits - #{pct}%) - threshold #{threshold}"
  end
end

