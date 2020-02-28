# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# log.rb has been released under MIT (*only this file*).

XTERM_COLOR = {
  black:          "\u001b[30m",
  red:            "\u001b[31m",
  green:          "\u001b[32m",
  yellow:         "\u001b[33m",
  blue:           "\u001b[34m",
  magenta:        "\u001b[35m",
  cyan:           "\u001b[36m",
  white:          "\u001b[37m",
  bright_black:   "\u001b[30;1m",
  bright_red:     "\u001b[31;1m",
  bright_green:   "\u001b[32;1m",
  bright_yellow:  "\u001b[33;1m",
  bright_blue:    "\u001b[34;1m",
  bright_magenta: "\u001b[35;1m",
  bright_cyan:    "\u001b[36;1m",
  bright_white:   "\u001b[37;1m",
  reset:          "\u001b[0m",
}

module GTK
  class Log
    def self.write_to_log_and_puts *args
      return if $gtk.production
      $gtk.append_file 'logs/log.txt', args.join("\n") + "\n"
      args.each { |obj| $gtk.log obj, self }
    end

    def self.write_to_log_and_print *args
      return if $gtk.production
      $gtk.append_file 'logs/log.txt', args.join("\n")
      Object.print(*args)
    end

    def self.puts_important *args
      return if $gtk.production
      $gtk.append_file 'logs/log.txt', args.join("\n")
      $gtk.notify! "Important notification occurred."
      args.each { |obj| $gtk.log obj }
    end

    def self.puts *args
      message_id, message = args
      message ||= message_id
      write_to_log_and_puts message
    end

    def self.multiline? *args
      return true if args.length > 1
      return !args[0].to_s.multiline?
    end

    def self.join_lines args
      return "" if args.length == 0
      return args if args.is_a? String
      return args[0] if args.length == 1
      return args.to_s.join("\n")
    end

    def self.headline name
      @asterisk_count ||= 1
      @asterisk_count = @asterisk_count.greater(1)
      result_from_yield = join_lines yield
      result_from_yield = result_from_yield.each_line.map { |l| "  #{l}" }.join
      r ="#{"*" * @asterisk_count} #{name}\n#{result_from_yield}"
      @asterisk_count -= 1
      @asterisk_count = @asterisk_count.greater(1)
      r
    end

    def self.dynamic_block
      "#+BEGIN:
#{join_lines yield}
#+END:

"
    end

    def self.puts_info *args
      args ||= []
      title = args[0]
      additional = args[1..-1] || []
      additional = "" if additional.length == 0
      if !title.multiline? && join_lines(additional).multiline?
        message = headline "INFO: #{title}" do
          dynamic_block do
            additional
          end
        end
      elsif title.multiline?
        message = headline "INFO: " do
          dynamic_block do
            args
          end
        end
      else
        message = "* INFO: #{title} #{additional}".strip
      end

      self.puts message
    end

    def self.puts_once *ids, message
      id = "#{ids}"
      @once ||= {}
      return if @once[id]
      @once[id] = id
      write_to_log_and_puts ""
      write_to_log_and_puts "#{message.strip}"
      write_to_log_and_puts ""
      write_to_log_and_puts "[Message ID: #{id}]"
      write_to_log_and_puts ""
      return if $gtk.cli_arguments[:replay]
      return if $gtk.cli_arguments[:record]
      $gtk.notify!("One time notification occurred. [Message ID: #{id}] (Open console for more info.)")
    end

    def self.puts_once_info *ids, message
      id = "#{ids}"
      @once ||= {}
      return if @once[id]
      @once[id] = id
      log_info message
    end

    def self.print *args
      write_to_log_and_print(*args)
    end
  end
end

class Object
  def log_print *args
    GTK::Log.print(*args)
  end

  def log_important *args
    GTK::Log.puts_important(*args)
  end

  def log *args
    GTK::Log.puts(*args)
  end

  def log_with_color xterm_escape_code, *args
    log_print xterm_escape_code
    log(*args)
  ensure
    log_reset_color
  end

  def log_reset_color
    log_print XTERM_COLOR[:reset]
  end

  def log_black *args
    log_with_color XTERM_COLOR[:black], *args
  end

  def log_red *args
    log_with_color XTERM_COLOR[:red], *args
  end

  def log_green *args
    log_with_color XTERM_COLOR[:green], *args
  end

  def log_yellow *args
    log_with_color XTERM_COLOR[:yellow], *args
  end

  def log_blue *args
    log_with_color XTERM_COLOR[:blue], *args
  end

  def log_magenta *args
    log_with_color XTERM_COLOR[:magenta], *args
  end

  def log_cyan *args
    log_with_color XTERM_COLOR[:cyan], *args
  end

  def log_white *args
    log_with_color XTERM_COLOR[:white], *args
  end

  def log_bright_black *args
    log_with_color XTERM_COLOR[:bright_black], *args
  end

  def log_bright_red *args
    log_with_color XTERM_COLOR[:bright_red], *args
  end

  def log_bright_green *args
    log_with_color XTERM_COLOR[:bright_green], *args
  end

  def log_bright_yellow *args
    log_with_color XTERM_COLOR[:bright_yellow], *args
  end

  def log_bright_blue *args
    log_with_color XTERM_COLOR[:bright_blue], *args
  end

  def log_bright_magenta *args
    log_with_color XTERM_COLOR[:bright_magenta], *args
  end

  def log_bright_cyan *args
    log_with_color XTERM_COLOR[:bright_cyan], *args
  end

  def log_bright_white *args
    log_with_color XTERM_COLOR[:bright_white], *args
  end

  def log_info *args
    GTK::Log.puts_info(*args)
  end

  def log_once *ids, message
    GTK::Log.puts_once(*ids, message)
  end

  def log_once_info *ids, message
    GTK::Log.puts_once_info(*ids, message)
  end
end
