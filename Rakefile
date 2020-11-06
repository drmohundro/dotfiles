# frozen_string_literal: true

require 'rake'
require 'json'

desc 'check the dotfiles to see if anything is missing'
task :check do
  begin
    loop_files do |link, _file|
      raise DotfileError.new('Link not created', link) unless File.exist?(link)
      raise DotfileError.new('Not symlink', link) unless File.symlink?(link)
    end
    puts "#{'✓'.green} All good"
  rescue DotfileError => e
    puts "#{'✘'.red} #{e.link} #{e.message}"
  end
end

desc 'whatif - see what would happen without running it'
task :whatif do
  loop_files(whatif: true) do |link, file|
    next if File.identical?(link, file)

    link_file(file, link, whatif: true)
  end
end

desc "install the dotfiles into user's home directory"
task :install do
  loop_files do |link, file|
    next if File.identical?(link, file)

    link_file(file, link)
  end
end

def loop_files(whatif = false)
  config = JSON.parse(File.read('overrides.json'))

  Dir['*'].each do |file|
    next if config['skip_processing'].include?(file)
    next if file.start_with?('.')

    path = determine_path(file, config, whatif)
    yield path if path
    log path if path && whatif
  end
end

def config_check(os, file, config)
  if config[os][file]
    if config[os][file].kind_of?(Array)
      config[os][file].each do |item|
        [File.expand_path(item), full_path(file)]
      end
    else
      [File.expand_path(config[os][file]), full_path(file)]
    end
  else
    default_path(file)
  end
end

def determine_path(file, config, whatif = false)
  log "Checking #{file}..." if whatif

  if config['windows'][file]
    if windows?
      config_check('windows', file, config)
    end
  elsif config['macos'][file]
    if mac?
      config_check('macos', file, config)
    end
  else
    default_path(file)
  end
end

def link_file_command(file, link)
  if windows?
    mklink_opts = File.directory?(file) ? '/J' : ''

    link = link.tr('/', '\\')
    file = file.tr('/', '\\')

    %(cmd /c mklink #{mklink_opts} "#{link}" "#{file}")
  else
    %(ln -s "#{file}" "#{link}")
  end
end

def link_file(file, link, whatif = false)
  command = link_file_command(file, link)

  if whatif
    log command
  else
    system command
  end

  puts "#{'✓'.green} #{file} linked to #{link}"
end

def windows?
  RUBY_PLATFORM =~ /(win32|mingw32)/
end

def mac?
  RUBY_PLATFORM =~ /darwin/
end

def nvim_home
  windows? ? File.join(ENV['LOCALAPPDATA'], 'nvim') : File.join(ENV['HOME'], '.config', 'nvim')
end

def full_path(file)
  File.join(Dir.pwd, file)
end

def default_path(file)
  [File.join(ENV['HOME'], ".#{file}"), full_path(file)]
end

def log(msg)
  log = "💡 #{msg}"
  puts log.yellow
end

# string helper to get ANSI colors
class String
  def red
    "\e[31m#{self}\e[0m"
  end

  def green
    "\e[32m#{self}\e[0m"
  end

  def yellow
    "\e[33m#{self}\e[0m"
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
