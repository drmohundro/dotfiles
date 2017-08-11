# This Rakefile is based heavily upon Ryan Bates' Rakefile
# - see https://github.com/ryanb/dotfiles/blob/master/Rakefile

require 'rake'
require 'erb'

desc "install the dot files into user's home directory"
task :install do
  replace_all = false
  Dir['*'].each do |file|
    next if %w(Rakefile README.markdown LICENSE).include? file

    if File.exist?(File.join(ENV['HOME'], ".#{file.sub('.erb', '')}"))
      if File.identical? file, File.join(ENV['HOME'], ".#{file.sub('.erb', '')}")
        puts "identical ~/.#{file.sub('.erb', '')}"
      elsif replace_all
        replace_file(file)
      else
        print "overwrite ~/.#{file.sub('.erb', '')}? [ynaq] "
        case $stdin.gets.chomp
        when 'a'
          replace_all = true
          replace_file(file)
        when 'y'
          replace_file(file)
        when 'q'
          exit
        else
          puts "skipping ~/.#{file.sub('.erb', '')}"
        end
      end
    else
      link_file(file)
    end
  end

  link_nvim
end

def link_nvim
  if windows?
    link_file('vim', "#{ENV['LOCALAPPDATA']}/nvim")
    link_file('vimrc', "#{ENV['LOCALAPPDATA']}/nvim/init.vim")
  else
    link_file('vim', "#{ENV['HOME']}/.config/nvim")
    link_file('vimrc', "#{ENV['HOME']}/.config/nvim/init.vim")
  end
end

def replace_file(file)
  FileUtils.rm_rf "#{ENV['HOME']}/.#{file.sub('.erb', '')}"
  link_file(file)
end

def link_file(file, link = nil)
  if file =~ /.erb$/
    puts "generating ~/.#{file.sub('.erb', '')}"
    File.open(File.join(ENV['HOME'], ".#{file.sub('.erb', '')}"), 'w') do |new_file|
      new_file.write ERB.new(File.read(file)).result(binding)
    end
  else
    puts "linking ~/.#{file}"

    link ||= "#{ENV['HOME']}/.#{file}"
    target = "#{Dir.pwd}/#{file}"

    if windows?
      mklink_opts = File.directory?(target) ? '/J' : ''

      link.gsub! '/', '\\'
      target.gsub! '/', '\\'

      system %(cmd /c mklink #{mklink_opts} "#{link}" "#{target}")
    else
      system %(ln -s "#{target}" "#{link}")
    end
  end
end

def windows?
  RUBY_PLATFORM =~ /(win32|mingw32)/
end
