#!/usr/bin/env ruby
require 'open3'
require 'pathname'

class Coffee < Thor

  SOURCE = "src"
  TARGET = "public/compiled"

  desc "watch", "Start watcher for compiling CoffeeScript-files when they change"
  def watch
    puts "CoffeeScript watcher started..."
    compile
    Dir.chdir(root) do
      system "bundle exec watchr #{here.join('watchr.rb')}"
    end
  end

  method_options :growl => :boolean
  desc "compile", "Compiles Coffeescript, optionally provide filenames"
  def compile(*files)
    files = Dir.glob(source.join('**/*.coffee')) if files.empty?
    loose = []
    concatinations  = []
    files.each do |file|
      name = concatination_name(file)
      if name
        concatinations << name
      else
        loose << file
      end
    end
    concatinations.uniq.compact.each { |dir| process_directory(dir) }
    loose.uniq.each { |file| process_loose_file(Pathname.new(file)) }
    send_notifications if options.growl?
  end

  private

  def concatination_name(file)
    file.to_s.sub(source.to_s, '').split('/').find { |part| part != "" && part != File.basename(file).to_s }
  end

  def here
    @here ||= Pathname.new(File.expand_path('../', __FILE__))
  end

  def root
    @root ||= Pathname.getwd
  end

  def source
    root.join(SOURCE)
  end

  def target
    root.join(SOURCE)
  end

  def process_loose_file(file)
    target_file = file.basename.to_s.gsub(".coffee", ".js")
    _compile(
      command: "coffee -o tmp -c #{file}",
      source: "tmp/#{target_file}",
      target: target.join(target_file),
      message: "\e[032mcompiled\e[0;90m '\e[0m#{target_file}\e[0;90m'\e[0m"
    )
  end

  def process_directory(dir)
    _compile(
      command: "coffee -o tmp --join --compile src/#{dir}/**/*.coffee",
      source:  "tmp/concatenation.js",
      target:  dir.to_s + '.js',
      message: "\e[032mcompiled\e[0;90m '\e[0m%{target}\e[0;90m'\e[0m"
    )
  end

  def _compile(args = {})
    FileUtils.mkdir_p File.dirname(args[:target])
    FileUtils.mkdir_p File.dirname(args[:source])
    stdin, stdout, stderr = nil, nil, nil
    Dir.chdir(root.to_s) do
      stdin, stdout, stderr = Open3.popen3(args[:command])
    end
    stderr = stderr.read
    if stderr == ""
      system "mv #{args[:source]} #{args[:target]}"
      msg = args[:message] % args
      puts "\e[0;90m#{Time.now} #{msg}"
      notify false, "Success: #{File.basename(args[:target])}", msg.gsub(/\e\[[^m]+m/,'')
    else
      header, *stacktrace = stderr.split("\n")
      puts "\n\e[31m#{header}\e[0m"
      stacktrace.each { |line| puts "\e[0;90m#{line}\e[0m" }
      puts ""
      title, message = header.split(": ", 2)
      notify true, "#{title}: #{File.basename(args[:target])}", "#{message}"
    end
  end

  def notify(*args)
    notifications << Struct.new(:error, :title, :message).new(*args)
  end

  def notifications
    @notifications ||= []
  end

  def send_notifications
    errors  = notifications.select(&:error)
    error   = errors.any?
    image   = error ? here.join("error.png") : here.join("ok.png")
    prio    = error ? 1 : -1
    source  = error ? errors : notifications
    title   = source.map(&:title).join(" - ")
    message = source.map(&:message).join(' - ')
    cmd = [ here.join('growlnotify').to_s, "-t", "#{title}", "-m", "#{message}", "--image", image, "-p", prio.to_s ]
    system *cmd.map(&:to_s)
  end

end
