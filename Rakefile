# frozen_string_literal: true

require 'rake'
require 'yaml'

def nvim_home
  windows? ? "#{ENV['LOCALAPPDATA']}/nvim" : "#{ENV['HOME']}/.config/nvim"
end

def full_path(file)
  "#{Dir.pwd}/#{file}"
end

def default_path(file)
  [File.join(ENV['HOME'], ".#{file}"), full_path(file)]
end

def config_check(file, config)
  if config['windows'][file]
    [File.expand_path(config['windows'][file]), full_path(file)] if windows?
  elsif config['macos'][file]
    [File.expand_path(config['macos'][file]), full_path(file)] if mac?
  else
    default_path(file)
  end
end

def determine_path(file, config)
  case file
  when 'vim'
    default_path(file)
    [nvim_home, full_path(file)]
  when 'vimrc'
    default_path(file)
    [File.join(nvim_home, 'init.vim'), full_path(file)]
  else
    config_check(file, config)
  end
end

def loop_files
  config = YAML.load_file('overrides.yaml')

  Dir['*'].each do |file|
    next if %w[Rakefile README.md LICENSE overrides.yaml].include?(file)

    path = determine_path(file, config)
    yield path if path
  end
end

def check_dotfiles
  loop_files do |link, _file|
    raise DotfileError.new('Link not created', link) unless File.exist?(link)
    raise DotfileError.new('Not symlink', link) unless File.symlink?(link)
  end

  true
end

desc 'check the dotfiles to see if anything is missing'
task :check do
  begin
    check_dotfiles
    puts '✓'.green
  rescue DotfileError => e
    puts "#{'✘'.red} #{e.link} #{e.message}"
  end
end

desc "install the dotfiles into user's home directory"
task :install do
  loop_files do |link, file|
    next if File.identical?(link, file)

    link_file(file, link)
  end
end

def link_file(file, link)
  if windows?
    mklink_opts = File.directory?(file) ? '/J' : ''

    link = link.tr('/', '\\')
    file = file.tr('/', '\\')

    system %(cmd /c mklink #{mklink_opts} "#{link}" "#{file}")
  else
    system %(ln -s "#{file}" "#{link}")
  end

  puts "#{'✓'.green} #{file} linked to #{link}"
end

def windows?
  RUBY_PLATFORM =~ /win32/
end

def mac?
  RUBY_PLATFORM =~ /darwin/
end

# string helper to get ANSI colors
class String
  def red
    "\e[31m#{self}\e[0m"
  end

  def green
    "\e[32m#{self}\e[0m"
  end
end

# error for dotfile issues
class DotfileError < StandardError
  attr_reader :message, :link

  def initialize(message, link)
    @message = message
    @link = link
  end
end
