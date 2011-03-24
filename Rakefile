require 'rake'
require 'erb'

verbose = 1

desc "Update the dot files in the user's home directory"
task :update do
  puts "Pulling.." if verbose
  system %Q{git pull} or raise "Git pull failed."
  puts "Syncing submodules.." if verbose
  system %Q{git submodule --quiet sync 2>&1} or raise "Git submodule sync failed."
  while true
    puts "Updating submodules.." if verbose
    sm_update = %x[git submodule update --init --recursive 2>&1]
    puts sm_update if verbose and sm_update != ""
    if $?.success?
      break
    end
    output = sm_update.split("\n")
    if output[-1] =~ /Unable to checkout '(\w+)' in submodule path '(.*?)'/
      if output.index('Please, commit your changes or stash them before you can switch branches.')
        puts "Abort: manual interaction required." # XXX: we might stash here automatically, but not yet..
        break
      end
      github_user = %x[git config --get github.user].chomp
      if github_user == ""
        puts "No GitHub user found in `git config --get github.user`. Aborting."
      end
      # check for github_user's remote, and maybe add it and then retry
      sm_path = $2
      remotes = %x[git --git-dir '#{sm_path}/.git' remote]
      if remotes =~ /^#{github_user}$/
        puts "Remote '#{github_user}' exists already." if verbose
      else
        puts "Adding remote '#{github_user}'." if verbose
        output = %x[cd #{sm_path} && hub remote add -p #{github_user} 2>&1]
        if not $?.success?
          puts "Failed to add submodule:\n" + output
          break
        end
      end
      puts "Fetching remote '#{github_user}'." if verbose
      output = %x[cd #{sm_path} && git fetch #{github_user} 2>&1]
      if not $?.success?
        puts "Failed to fetch submodule:\n" + output
        break
      end
    end
    puts "Retrying update.."
  end
end

def get_submodule_status
  puts "Getting submodules status.." if verbose
  status = %x[ git submodule status --recursive ] or raise "Getting submodule status failed"
  r = {}
  status.split("\n").each do |line|
    if not line =~ /^([ +-])(\w{40}) (.*?)(?: \(.*\))?$/
      raise "Found unexpected submodule line: #{line}"
    end
    path = $3
    next if ! path
    r[path] = {"state" => $1}
  end
  return r
end

desc "Upgrade submodules to current master"
task :upgrade do
  system %Q{ git diff --cached --exit-code > /dev/null } or raise "The git index is not clean."

  submodules = {}
  # get_submodule_status.each do |sm|
  get_submodule_status.each do |path, sm|
    if sm["state"] == "+"
      puts "Skipping modified submodule #{path}."
      next
    end
    if sm["state"] == "-"
      puts "Skipping uninitialized submodule #{path}."
      next
    end
    submodules[path] = [sm]
  end
  submodules.each do |path,sm|
    puts "Pulling #{path}.." if verbose
    # TODO: pull from github_user branch if present
    # should fix:
    # vim/bundle/visualctrlg
    # Already on 'master'
    # From git://github.com/tyru/visualctrlg.vim
    #  * branch            master     -> FETCH_HEAD
    #  Your branch and 'origin/master' have diverged,
    #  and have 2 and 1 different commit(s) each, respectively.
    #  Auto-merging plugin/visualctrlg.vim
    #  CONFLICT (content): Merge conflict in plugin/visualctrlg.vim
    #  Automatic merge failed; fix conflicts and then commit the result.
    #
    output = %x[ { cd '#{path}' && git fetch --all && git co master && git merge origin/master master ; } 2>&1 ]
    if not $?.success?
      raise "Pulling failed: " + output
    end
    output = output.split("\n")
    # Output important lines
    puts output.select{|x| x=~/^Your branch is/}

    if ! output[-1] =~ /^Already up-to-date.( Yeeah!)?/
      puts output
    else
      puts output if verbose > 1
    end
  end

  # Commit any updated modules
  get_submodule_status.each do |path, sm|
    next if sm["state"] != "+"
    output = %x[ git commit -m 'Update submodule #{path} to origin/master.' #{path} ]
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
