# coding: utf-8
# Copyright 2021 DragonRuby LLC
# MIT License
# metadata.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright: Michał Dudziński

module Metadata
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
      dev_id: dev_id.strip,
      dev_title: dev_title.strip,
      game_id: game_id.strip,
      game_title: game_title.strip,
      version: version.strip,
      icon: icon.strip
    }
  end

  def write_blank_metadata
      $gtk.write_file metadata_file_path, <<-S.strip
#devid=myname
#devtitle=My Name
#gameid=mygame
#gametitle=My Game
#version=0.1
#icon=metadata/icon.png
S
  end
end
