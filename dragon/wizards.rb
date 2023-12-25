# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# wizards.rb has been released under MIT (*only this file*).

class Wizard
  def metadata_file_path
    "metadata/game_metadata.txt"
  end

  def get_metadata
    metadata = $gtk.read_file metadata_file_path

    if !metadata
      write_blank_metadata
      metadata = $gtk.read_file metadata_file_path
    end

    kvps = metadata.each_line
                   .reject { |l| l.strip.length == 0 || (l.strip.start_with? "#") }
                   .map do |l|
                     key, value = l.split("=")
                     [key.strip.to_sym, value.strip]
                   end.flatten

    default_metadata = {
      devid: "myname",
      devtitle: "My Name",
      gameid: "mygame",
      gametitle: "My Game",
      version: "0.1",
      icon: "metadata/icon.png"
    }

    parsed_metadata = Hash[*kvps]

    default_metadata.merge parsed_metadata
  end

  def help
    puts "* INFO: No help available for Wizard of type ~#{self.class.name}~"
  end

  def process_wizard_exception e
    # queue the exception to be added after current standard out has been processed.
    queue_at = Kernel.global_tick_count + 3
    $console.clear_logs global_at: queue_at - 1
    $console.add_primitive ("=" * $console.console_text_width), global_at: queue_at
    e.console_primitives.each do |p|
      $console.add_primitive p, global_at: queue_at
    end
    $console.add_primitive ("=" * $console.console_text_width), global_at: queue_at
  end

  def last_executed_steps
    @last_executed_steps
  end

  def execute_steps steps
    log "================"
    log "* INFO: Starting #{display_name}."
    @start_at = Kernel.global_tick_count

    @last_executed_steps = steps

    steps.each do |m|
      before_step = "before_#{m}".to_sym
      after_step = "after_#{m}".to_sym
      send before_step if respond_to? before_step
      log_info "Running step ~:#{m}~."
      if @wizard_status[m][:result] != :success
        result = (send m)
        if !result || result.is_a?(Symbol) == false
          raise "Step ~:#{m}~ returned nil. Expected a symbol (:success if everything went well)."
        end

        return result if result != :success
      end
      send after_step if respond_to? after_step
      @wizard_status[m][:result] = result
      log_info "Running step ~:#{m}~ complete."
    end

    return :success
  rescue Exception => e
    if e.is_a? WizardException
      process_wizard_exception e
    else
      log_error e.to_s
      log e.__backtrace_to_org__
    end
    return :exception
  end

  def display_name
    self.class.name
  end
end

class WizardException < Exception
  attr_accessor :console_primitives

  def initialize *console_primitives
    @console_primitives = console_primitives
  end
end

module GTK
  class Wizards
    attr_accessor :ios, :itch

    def initialize
      @ios = IOSWizard.new
      @itch = ItchWizard.new
    end
  end
end
