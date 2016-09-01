### flag git repositories which have significant overlap with a set of other git repositories

Let's say you have a bunch of git repositories ("yours"), and another set of git repositories
("theirs") and you're curious if any of their repositories are likely to be duplicates, clones, 
forks, or highly similar to yours.  

This simple tool takes the approach that we want to just quickly rule out any of their 
repositories which absolutely aren't related to any of your repositories.  If there *might* 
be some of theirs that could be related to some of yours, just print out the names of those
repositories and we can visually inspect them.

### usage:


Let's get set up:

```
bundle install
```

Let's index our repositories:

```
# hint: do this in a loop, realistically, over a ton of repos
% bundle exec add-known-repo.rb ~/ours/{always-be-scheduling,hadoop,kerminator,mesos-plugin,run-me-maybe-plugin}
Encountered 154 commits in repo /Users/rick/ours/always-be-scheduling/
Encountered 162 commits in repo /Users/rick/ours/hadoop/
Encountered 741 commits in repo /Users/rick/ours/kerminator/
Encountered 312 commits in repo /Users/rick/ours/mesos-plugin/
Encountered 61 commits in repo /Users/rick/ours/run-me-maybe-plugin/
Writing bloom filter with 1430 commits to [/tmp/bloom.txt]...
```

```
# find repositories which overlap with ours by 5 or more commits
% bundle exec flag.rb 5 /tmp/bloom.txt ~/theirs/*
/home/me/theirs/hadoop	162	matching commits in [/home/me/theirs/hadoop] (of 162 total repo commits - 100.0%) - threshold 5
```

### Limitations and stuff

 - This is pretty naive
 - I used like the 2nd bloom filter library I found (which was the more recently updated of the two listed at the top of google); there have got to be 1000 ways to do this better
 - This is doing a full index of all those repos to build its index.  Probably one would want to just update the index with new commits as things come in.
 - This doesn't really tell you what repositories of yours theirs is overlapping with. Wouldn't be super-hard to do this, you'd maybe want to keep some separate indexes for each of your repositories and scan down them when you find a hit. There are other ways to do this. Suffix trees/arrays come to mind.
 - I mean, I hacked this up in about 45 minutes, so, you get what you pay for.
