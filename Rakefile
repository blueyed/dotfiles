require 'rake'
require 'erb'

$my_verbose = 1
$my_verbose = false if $my_verbose == 0

desc "Update the dotfiles in the user's home directory"
task :update => [:pull, :sync_submodules, :update_submodules] do
end

desc "Pull new changes, via `git pull`"
task :pull do
  puts "Pulling.." if $my_verbose
  system %Q{git pull} or raise "Git pull failed."
end

desc "Sync submodules, via `git submodule sync`"
task :sync_submodules do
  puts "Syncing submodules.." if $my_verbose
  system %Q{git submodule --quiet sync 2>&1} or raise "Git submodule sync failed."
end

desc "Update all submodules"
task :update_submodules do
  submodules = get_submodule_status
  puts "Updating submodules.." if $my_verbose
  git_sm_has_recursive = true # until proven otherwise

  # Get submodule summary and remove any submodules with _new_ commits from
  # the list to be updated.
  sm_summary = %x[git submodule summary]
  if not $?.success?
    raise sm_summary
  end
  sm_path = nil
  sm_summary.split("\n").each do |line|
    if line =~ /^\* (.*?) \w+\.\.\.\w+/
      sm_path = $1
    elsif sm_path and line =~ /^  >/
      puts "Skipping submodule #{sm_path}, which is ahead locally."
      submodules.delete(sm_path)
      sm_path = nil
    end
  end

  i = 0
  n = submodules.length
  begin
  while true
    break if i == n
    path = submodules.keys[i]
    sm = submodules[path]
    i+=1

    puts "[#{i}/#{n}] Updating #{path}.." if $my_verbose

    if git_sm_has_recursive
      sm_update = %x[git submodule update --init --recursive #{path} 2>&1]
      if not $?.success?
        if sm_update.start_with?("Usage: ")
          git_sm_has_recursive = false
        end
      end
    end
    if not git_sm_has_recursive
      sm_update = %x[git submodule update --init #{path} 2>&1]
    end

    puts sm_update if $my_verbose and sm_update != ""
    output = sm_update.split("\n")
    if sm_update =~ /^Unable to checkout '(\w+)' in submodule path '(.*?)'$/
      if output.index('Please, commit your changes or stash them before you can switch branches.')
        puts "Stashing changes in #{path}"
        if submodules[path]['stashed']
          raise "Already stashed #{path}!"
        end
        stash_output = %x[ cd '#{path}' && git stash save 'Stashed for `rake update` at #{Time.new.strftime("%Y-%m-%d %H:%M:%S")}.' ]
        if not $?.success?
          raise "ERROR when stashing:\n" + stash_output
        end
        submodules[path]['stashed'] = true
        i -= 1
        next
      end
      github_user = get_github_repo_user
      if github_user == ""
        puts "No GitHub repo user found to add a remote for/from. Skipping."
        next
      end
      # check for github_user's remote, and maybe add it and then retry
      remotes = %x[git --git-dir '#{path}/.git' remote]
      if remotes =~ /^#{github_user}$/
        puts "Remote '#{github_user}' exists already." if $my_verbose
      else
        puts "Adding remote '#{github_user}'." if $my_verbose
        output = %x[cd #{path} && hub remote add #{github_user} 2>&1]
        if not $?.success?
          puts "Failed to add submodule:\n" + output
          next
        end
      end
      puts "Fetching remote '#{github_user}'." if $my_verbose
      output = %x[cd #{path} && git fetch #{github_user} -v 2>&1]
      if not $?.success?
        puts "Failed to fetch submodule:\n" + output
        next
      end
      output = output.split("\n")
      if output.index(' = [up to date]      master     -> blueyed/master')
        puts "ERROR: blueyed/master already up to date. Something wrong. Skipping.\n\t" + output.join("\n\t")
        next
      end
      puts "Retrying.." if verbose
      i -= 1
    end
  end
  rescue Exception => exc
    puts "Exception: " + exc.message
    puts exc.backtrace.join("\n")
  ensure
    submodules.each do |sm_path,sm|
      if sm['stashed'] == true
        puts "Unstashing #{sm_path}" if verbose
        stash_output = %x[{cd '#{sm_path}' && git stash pop} 2>&1]
        if not $?.success?
          puts "ERROR when popping stash for #{sm_path}:\n" + stash_output
        end
        sm['stashed'] = false
      end
    end
  end

  # TODO: update/add new symlinks
end

desc "Generate diff files for repo and any modified submodules"
task :diff do
  puts "Writing dotfiles.diff"
  %x[git diff --ignore-submodules=all > dotfiles.diff]
  get_submodule_status.each do |path,sm|
    puts "Diffing #{path}.." if verbose
    diff = %x[ cd #{path} && git diff ]
    if diff.length > 0
      diffname = "#{File.basename(path)}.diff"
      puts "Writing #{diffname}"
      File.open(diffname, "w").write(diff)
    end
  end
end

desc "Upgrade submodules to current master"
task :upgrade do
  ignore_modified = true
  system %Q{ git diff --cached --exit-code > /dev/null } or raise "The git index is not clean."

  submodules = {}
  get_submodule_status.each do |path, sm|
    if ignore_modified && sm["state"] == "+"
      puts "Skipping modified submodule #{path}."
      next
    end
    if sm["state"] == "-"
      puts "Skipping uninitialized submodule #{path}."
      next
    end
    submodules[path] = sm
  end

  submodules.each do |path,sm|
    puts "Upgrading #{path}.." if $my_verbose

    # puts "Fetching all remotes" if $my_verbose
    output = %x[cd #{path} && git fetch --all]

    sm_url = %x[git config --get submodule.#{path}.url].chomp
    puts "Fetching #{path} from #{sm_url}" if $my_verbose
    output = %x[cd #{path} && git fetch #{sm_url} 2>&1]
    puts output if $my_verbose and $my_verbose > 1
    if not $?.success?
      raise "Fetching failed: " + output
    end

    # Check that current commit is ancestor of FETCH_HEAD
    # sm_commit = %x[cd #{path} && git rev-parse #{sm["commit"]}].chomp
    sm_commit = sm['commit']
    merge_base = %x[cd #{path} && git merge-base #{sm_commit} FETCH_HEAD].chomp
    if sm_commit != merge_base
      # puts "Skipping #{path}: Current commit does not appear to be ancestor of FETCH_HEAD."
      # puts "Info: sm_commit: #{sm_commit}, merge_base: #{merge_base}"
      # next
      output = %x[cd #{path} && git merge FETCH_HEAD]
      puts "Merged FETCH_HEAD:\n" + output
    end

    output = %x[cd #{path} && git merge --ff-only FETCH_HEAD 2>&1]
    if ! output.split("\n")[-1] =~ /^Already up-to-date.( Yeeah!)?/
      puts output
    else
      puts output if $my_verbose and $my_verbose > 1
      # TODO: pull result
    end
    if not $?.success?
      raise "Merging FETCH_HEAD failed: " + output
    end
    next

    # 1. get available remotes
    # 2. find newest one, via
    #    git --describe always
    #    git branch (-a) --contains $DESC
    #    get available master branches via gb -r
    # remotes = %x[git --git-dir '#{path}/.git' remote]
    # if not $?.success?
    #   raise "Pulling failed: " + output
    # end
    #
    output = output.split("\n")
    # Output important lines
    puts output.select{|x| x=~/^Your branch is/}
  end
  Rake::Task[:commitsubmodules].invoke(submodules)
end

desc "Commit modified submodules"
task :commitsubmodules, :submodules do |t, args|
  # Commit any updated modules
  if not args.submodules
    # only call the method on demand; there might be a ruby way to do this anyway..
    args.with_defaults(:submodules => get_modified_submodules)
  end
  get_submodule_status( args.submodules.keys.join(" ") ).each do |path, sm|
    next if sm["state"] != "+"
    status = %x[ cd '#{path}' && git status -b -s ]
    if status =~ /^## master...origin\/master \[ahead/
      puts "WARNING: #{path} appears to be ahead of origin. You might need to push it."
      puts "Skipping commit.."
      next
    end
    output = %x[ zsh -i -c 'gsmc #{path}' ]
    puts output
  end
  # %x[ git submodule foreach "git pull origin master && git co master" ]
  # Commit any new modules
end


desc "install the dot files into user's home directory"
task :install do
  base = ENV['HOME']
  if not base
    puts "Fatal error: no base path given.\nPlease make sure that HOME is set in your environment.\nAborting."
    exit 1
  end

  $replace_all = false
  Dir['*'].each do |file|
    next if %w[Rakefile README.rdoc LICENSE].include? file

    # Install files in "config" separately
    if 'config' == file
      Dir[File.join(file, '*')].each do |file|
        clean_name = file.sub(/\.erb$/, '')
        install_file(file, File.join(base, "."+clean_name))
      end
    else
      clean_name = file.sub(/\.erb$/, '')
      install_file(file, File.join(base, "."+clean_name))
    end
  end

end


def install_file(file, target)
  nice_target = target.sub(/#{ENV['HOME']}/, '~') # for display: collapse "~"
  if File.exist?(target)
    if File.identical? file, target
      puts "identical #{nice_target}"
    elsif $replace_all
      replace_file(file, target)
    else
      print "overwrite #{nice_target}? [ynaq] "
      case $stdin.gets.chomp
      when 'a'
        $replace_all = true
        replace_file(file, target)
      when 'y'
        replace_file(file, target)
      when 'q'
        exit
      else
        puts "skipping #{nice_target}"
      end
    end
  else
    link_file(file, target)
  end
end

def replace_file(file, target)
  system %Q{rm -rf "#{target}"}
  link_file(file, target)
end

def link_file(file, target)
  nice_target = target.sub(/#{ENV['HOME']}/, '~') # for display: collapse "~"
  if file =~ /.erb$/
    puts "generating #{nice_target}"
    File.open(target, 'w') do |new_file|
      new_file.write ERB.new(File.read(file)).result(binding)
    end
  else
    puts "linking #{nice_target}"
    system %Q{ln -sfn "$PWD/#{file}" "#{target}"}
  end
end

def get_github_repo_user
  return "blueyed"
  # XXX: parse from "git remote" output, e.g. origin  git://github.com/blueyed/dotfiles.git
  # irrelevant: return %x[git config --get github.user].chomp
end

def get_submodule_status(sm_args='')
  # return { 'vim/bundle/solarized' => {'state'=>' '} }
  puts "Getting submodules status.." if $my_verbose
  status = %x[ git submodule status #{sm_args} ] or raise "Getting submodule status failed"
  r = {}
  status.split("\n").each do |line|
    if not line =~ /^([ +-])(\w{40}) (.*?)(?: \(.*\))?$/
      raise "Found unexpected submodule line: #{line}"
    end
    path = $3
    next if ! path
    r[path] = {"state" => $1, "commit" => $2}
  end
  return r
end

def get_modified_submodules()
  get_submodule_status.delete_if {|path, sm| sm["state"] != "+"}
end
