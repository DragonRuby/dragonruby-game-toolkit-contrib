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

    dev_id, dev_title, game_id, game_title, version, icon = *metadata.each_line.to_a

    {
      dev_id:     dev_id.strip.gsub("#", "").gsub("devid=", ""),
      dev_title:  dev_title.strip.gsub("#", "").gsub("devtitle=", ""),
      game_id:    game_id.strip.gsub("#", "").gsub("gameid=", ""),
      game_title: game_title.strip.gsub("#", "").gsub("gametitle=", ""),
      version:    version.strip.gsub("#", "").gsub("version=", ""),
      icon:       icon.strip.gsub("#", "").gsub("icon=", "")
    }
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
