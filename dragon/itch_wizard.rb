# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# itch_wizard.rb has been released under MIT (*only this file*).

class ItchWizard < Wizard
  def help
    puts <<~S
         * INFO: Help for #{self.class.name}
         To run this wizard, type the following into the DragonRuby Console:

           $wizards.itch.start

         S
  end

  def itch_steps
    [
      :check_metadata
    ]
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

  def check_metadata
    metadata_text = $gtk.read_file metadata_file_path
    if !metadata_text
      write_blank_metadata
    end

    if metadata_text.strip.each_line.to_a.length < 6
      write_blank_metadata
    end

    log "* INFO: Contents of #{metadata_file_path}:"
    log "#+begin_src txt"
    metadata_text.each_line { |l| log "  #{l}" }
    log "#+end_src"
    metadata = get_metadata

    if metadata[:devid].start_with?("#") || !@devid
      log "* PROMPT: Please provide your username for Itch."
      $console.set_command "$wizards.itch.set_devid \"#{metadata[:devid]}\""
      return :need_devid
    end

    if metadata[:devtitle].start_with?("#") || !@devtitle
      log "* PROMPT: Please provide developer's/company's name that you want displayed."
      $console.set_command "$wizards.itch.set_devtitle \"#{metadata[:devtitle]}\""
      return :need_devtitle
    end

    if metadata[:gameid].start_with?("#") || !@gameid
      log "* PROMPT: Please provide the id for you game. This is the id you specified when you set up a new game page on Itch."
      $console.set_command "$wizards.itch.set_gameid \"#{metadata[:gameid]}\""
      return :need_gameid
    end

    if metadata[:gametitle].start_with?("#") || !@gametitle
      log "* PROMPT: Please provide the display name for your game. (This can include spaces)"
      $console.set_command "$wizards.itch.set_gametitle \"#{metadata[:gametitle]}\""
      return :need_gametitle
    end

    if metadata[:version].start_with?("#") || !@version
      log "* PROMPT: Please provide the version for your game."
      $console.set_command "$wizards.itch.set_version \"#{metadata[:version]}\""
      return :need_version
    end

    if metadata[:icon].start_with?("#") || !@icon
      log "* PROMPT: Please provide icon path for your game."
      $console.set_command "$wizards.itch.set_icon \"#{metadata[:icon]}\""
      return :need_icon
    end

    return :success
  end

  def set_devid value
    @devid = value
    start
  end

  def set_devtitle value
    @devtitle = value
    start
  end

  def set_gameid value
    @gameid = value
    start
  end

  def set_gametitle value
    @gametitle = value
    start
  end

  def set_version value
    @version = value
    start
  end

  def set_icon value
    @icon = value
    write_metadata
    deploy
    reset
    $console.set_command "$wizards.itch.start"
  end

  def write_metadata
    text = ""
    if @devid
      text += "devid=#{@devid}\n"
    else
      text += "#devid=myname\n"
    end

    if @devtitle
      text += "devtitle=#{@devtitle}\n"
    else
      text += "#devtitle=My Name\n"
    end

    if @gameid
      text += "gameid=#{@gameid}\n"
    else
      text += "#gameid=gameid\n"
    end

    if @gametitle
      text += "gametitle=#{@gametitle}\n"
    else
      text += "#gametitle=Game Name\n"
    end

    if @version
      text += "version=#{@version}\n"
    else
      text += "#version=0.1\n"
    end

    if @icon
      text += "icon=#{@icon}\n"
    else
      text += "#icon=metadata/icon.png\n"
    end

    $gtk.write_file metadata_file_path, text
  end

  def relative_path
    (File.dirname $gtk.binary_path)
  end

  def package_command
    "#{File.join $gtk.get_base_dir, 'dragonruby-publish'}"
  end

  def deploy
    log_info "* Running dragonruby-publish: #{package_command}"
    $gtk.openurl "http://itch.io/dashboard" if $gtk.platform == "Mac OS X"
    if $gtk.platform? :mac
      $gtk.exec "rm -rf ./builds"
    end
    results = $gtk.exec "#{package_command} --only-package"
    puts File.expand_path("./builds")

    log "#+begin_src"
    log results
    log "#+end_src"

    if $gtk.platform? :mac
      $gtk.exec "open ./builds/"
    elsif $gtk.platform? :windows
      $gtk.exec "powershell \"ii .\""
    end

    $gtk.openurl "https://itch.io/dashboard"

    puts "* INFO: Builds for your game are located within the =./builds= directory."

    :success
  end

  def start
    execute_steps itch_steps
    nil
  end

  def reset
    @devid = nil
    @devtitle = nil
    @gameid = nil
    @gametitle = nil
    @version = nil
    @icon = nil
    init_wizard_status
  end

  def restart
    reset
    start
  end

  def initialize
    reset
  end

  def init_wizard_status
    @wizard_status = {}

    itch_steps.each do |m|
      @wizard_status[m] = { result: :not_started }
    end

    previous_step = nil
    next_step = nil

    itch_steps.each_cons(2) do |current_step, next_step|
      @wizard_status[current_step][:next_step] = next_step
    end

    itch_steps.reverse.each_cons(2) do |current_step, previous_step|
      @wizard_status[current_step][:previous_step] = previous_step
    end
  end

  def display_name
    "Itch Wizard"
  end
end
