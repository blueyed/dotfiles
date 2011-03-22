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
    last_line = sm_update.split("\n")[-1]
    if last_line =~ /Unable to checkout '(\w+)' in submodule path '(.*?)'/
      github_user = %x[git config --get github.user].chomp
      if github_user == ""
        puts "No GitHub user found in `git config --get github.user`. Aborting."
      end
      # check for github_user's remote, and maybe add it and then retry
      sm_path = $2
      remotes = %x[git --git-dir '#{sm_path}/.git' remote]
      if remotes =~ /^#{github_user}$/
        puts "Remote '#{github_user}' exists already. Aborting."
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
  status = %x[ git submodule status --recursive ] or raise "Getting submodule status failed"
  r = {}
  status.split("\n").each do |line|
    if not line =~ /^([ +-])(\w{40}) (.*) \(.*\)$/
      raise "Found invalid submodule line: #{line}"
    end
    path = $3
    r[path] = {"state" => $1}
  end
  return r
end

desc "Upgrade submodules to current master"
task :upgrade do
  # system %Q{ git diff --cached --exit-code > /dev/null } or raise "The Git index is not clean."

  submodules = {}
  # get_submodule_status.each do |sm|
  get_submodule_status().each do |path, sm|
    if sm["state"] == "+"
      puts "Skipping modified submodule #{path}."
      next
    end
    if sm["state"] == "-"
      puts "Skipping uninitialized submodule #{path}."
      next
    end
  end
  submodules.each do |path,match|
    puts path if verbose
    output = %x[ cd '#{path}' && git co master && git pull origin master ]
    puts output
  end

  # Commit any modules
  submodules.each do |path|
    output = %x[ git commit -m 'Update submodule #{path} to origin/master.' ]
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
