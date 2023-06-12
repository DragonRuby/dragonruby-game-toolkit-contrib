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
