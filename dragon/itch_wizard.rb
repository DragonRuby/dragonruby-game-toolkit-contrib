# Copyright 2019 DragonRuby LLC
# MIT License
# itch_wizard.rb has been released under MIT (*only this file*).

class ItchWizard
  include Metadata

  def steps
    [
      :check_metadata,
      :deploy
    ]
  end

  def check_metadata
    metadata_text = $gtk.read_file metadata_file_path
    if !metadata_text
      write_blank_metadata
    end

    if metadata_text.each_line.to_a.length != 6
      write_blank_metadata
    end

    log "* INFO: Contents of #{metadata_file_path}:"
    log "#+begin_src txt"
    metadata_text.each_line { |l| log "  #{l}" }
    log "#+end_src"
    metadata = get_metadata

    if metadata[:dev_id].start_with?("#") || !@dev_id
      log "* PROMPT: Please provide your username for Itch."
      $console.set_command "$wizards.itch.set_dev_id \"your-itch-username\""
      return :need_dev_id
    end

    if metadata[:dev_title].start_with?("#") || !@dev_title
      log "* PROMPT: Please provide developer's/company's name that you want displayed."
      $console.set_command "$wizards.itch.set_dev_title \"Your Name\""
      return :need_dev_title
    end

    if metadata[:game_id].start_with?("#") || !@game_id
      log "* PROMPT: Please provide the id for you game. This is the id you specified when you set up a new game page on Itch."
      $console.set_command "$wizards.itch.set_game_id \"your-game-id\""
      return :need_game_id
    end

    if metadata[:game_title].start_with?("#") || !@game_title
      log "* PROMPT: Please provide the display name for your game. (This can include spaces)"
      $console.set_command "$wizards.itch.set_game_title \"Your Game\""
      return :need_game_title
    end

    if metadata[:version].start_with?("#") || !@version
      log "* PROMPT: Please provide the version for your game."
      $console.set_command "$wizards.itch.set_version \"1.0\""
      return :need_version
    end

    if metadata[:icon].start_with?("#") || !@icon
      log "* PROMPT: Please provide icon path for your game."
      $console.set_command "$wizards.itch.set_icon \"icon.png\""
      return :need_icon
    end

    return :success
  end

  def set_dev_id value
    @dev_id = value
    write_metadata
    start
  end

  def set_dev_title value
    @dev_title = value
    write_metadata
    start
  end

  def set_game_id value
    @game_id = value
    write_metadata
    start
  end

  def set_game_title value
    @game_title = value
    write_metadata
    start
  end

  def set_version value
    @version = value
    write_metadata
    start
  end

  def set_icon value
    @icon = value
    write_metadata
    start
  end

  def write_metadata
    text = ""
    if @dev_id
      text += "devid=#{@dev_id}\n"
    else
      text += "#devid=myname\n"
    end

    if @dev_title
      text += "devtitle=#{@dev_title}\n"
    else
      text += "#devtitle=My Name\n"
    end

    if @game_id
      text += "gameid=#{@game_id}\n"
    else
      text += "#gameid=gameid\n"
    end

    if @game_title
      text += "gametitle=#{@game_title}\n"
    else
      text += "#gametitle=Game Name\n"
    end

    if @version
      text += "version=#{@version}\n"
    else
      text += "#version=0.1\n"
    end

    if @icon
      text += "icon=metadata/#{@icon}\n"
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
    results = $gtk.exec package_command
    log "#+begin_src"
    log results
    log "#+end_src"
    :success
  end

  def start
    log "================"
    log "* INFO: Starting Itch Wizard."
    @start_at = Kernel.global_tick_count
    steps.each do |m|
      begin
        log_info "Running Itch Wizard Step: ~$wizards.itch.#{m}~"
        result = (send m) || :success if @wizard_status[m][:result] != :success
        @wizard_status[m][:result] = result
        if result != :success
          log_info "Exiting wizard. :#{result}"
          break
        end
      rescue Exception => e
        if e.is_a? WizardException
          $console.log.clear
          $console.archived_log.clear
          log "=" * $console.console_text_width
          e.console_primitives.each do |p|
            $console.add_primitive p
          end
          log "=" * $console.console_text_width
          $console.set_command (e.console_command || "$wizards.itch.start")
        else
          log_error "Step #{m} failed."
          log_error e.to_s
          $console.set_command "$wizards.itch.start"
        end

        break
      end
    end
  end

  def reset
    @dev_id = nil
    @dev_title = nil
    @game_id = nil
    @game_title = nil
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

    steps.each do |m|
      @wizard_status[m] = { result: :not_started }
    end

    previous_step = nil
    next_step = nil

    steps.each_cons(2) do |current_step, next_step|
      @wizard_status[current_step][:next_step] = next_step
    end

    steps.reverse.each_cons(2) do |current_step, previous_step|
      @wizard_status[current_step][:previous_step] = previous_step
    end
  end
end
