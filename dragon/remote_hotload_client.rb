# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# remote_hotload_client.rb has been released under MIT (*only this file*).

module GTK
  class RemoteHotloadClient
    attr :args

    def gtk
      args.gtk
    end

    def state
      local_state
    end

    def initialize server_ip_address, port
      local_state.server_ip_address = server_ip_address || ""
      local_state.server_port = port
      puts "* INFO: Remote Hotload Client server_available? #{server_available?}"
    end

    def tick
      return unless server_available?

      if should_tick? && !local_state.notified
        if server_available?
          log_spam "* REMOTE HOTLOAD INFO: Hotload server found at #{get_server_ip_address}:#{get_server_port}."
        end
        local_state.notified = true
      end

      tick_write_file
      tick_process_file_retrieval
      tick_process_queue
      tick_changes
      tick_http_boot
    end

    def should_tick?
      (Kernel.global_tick_count.mod_zero? 60) && Kernel.global_tick_count > 5.seconds
    end

    def game_state
      args.state
    end

    def local_state
      @local_state ||= {}

      @local_state.hotload_client ||= {
        type: :hotload_client,
        notes: "This entity is used by DragonRuby Game Toolkit to provide you hotloading on remote machines.",
        changes: {},
        changes_queue: [],
        write_file_queue: [],
        reloaded_files_times: []
      }

      @local_state.hotload_client
    end

    def get_server_ip_address
      local_state.server_ip_address
    end

    def get_server_port
      local_state.server_port
    end

    def get_server_url path
      return "http://#{get_server_ip_address}:#{get_server_port}/#{path}"
    end

    def server_available?
      return false if $gtk.platform == 'Emscripten'
      get_server_ip_address.length != 0
    end

    def tick_changes
      return unless should_tick?

      local_state.greatest_tick ||= 0
      local_state.last_greatest_tick ||= 0

      tick_http_changes
    end

    def tick_http_boot
      return if local_state.booted_at
      local_state.http_boot_debounce ||= 0
      local_state.http_boot_debounce  -= 1
      local_state.http_boot_debounce   = local_state.http_boot_debounce.clamp(0, 120)
      return if local_state.http_boot_debounce > 0

      if !local_state.http_boot
        # first retrieve changes.txt which has the following format
        # file with latest change,
        # latest file                              update_time  key
        # tmp/src_backup/src_backup_app_main.rb, 1597926596,  app/main.rb
        log_spam "* REMOTE HOTLOAD INFO: Attempting http_get of #{get_server_url('dragon/boot/')}"
        local_state.http_boot    = args.gtk.http_get(get_server_url('dragon/boot/'))
      elsif local_state.http_boot && local_state.http_boot[:http_response_code] == 200
        local_state.last_greatest_tick = local_state.http_boot[:response_data].strip.to_i
        local_state.greatest_tick = local_state.http_boot[:response_data].strip.to_i
        local_state.booted_at = local_state.greatest_tick
        log_spam '* REMOTE HOTLOAD INFO: HTTP GET for local_state. boot.txt succeeded.'
        log_spam "* REMOTE HOTLOAD INFO: Looking for changes after: #{local_state.greatest_tick}."
      elsif local_state.http_boot && local_state.http_boot[:http_response_code] == -1 && local_state.http_boot[:complete]
        log_spam '* REMOTE HOTLOAD INFO: HTTP GET for boot.txt failed. Retrying.'
        local_state.http_boot = nil
        local_state.http_boot_debounce = 120
      end
    end

    def tick_http_changes
      return unless local_state.booted_at

      if !local_state.http_changes
        log_spam "* REMOTE HOTLOAD INFO: Attempting http_get of #{get_server_url('dragon/changes/')}"
        local_state.http_changes = args.gtk.http_get(get_server_url('dragon/changes/'))
      end

      if local_state.http_changes && local_state.http_changes[:http_response_code] == 200 && local_state.booted_at
        local_state.last_greatest_tick = local_state.greatest_tick
        # if the retrieval of changes.txt was successful
        local_state.http_changes[:response_data].each_line do |l|
          if l.strip.length != 0
            # within reload state for that specific changes hash
            # set the last time the file was updated
            file_name, updated_at, key = l.strip.split(',')
            file_name.strip!
            updated_at.strip!
            key.strip!
            updated_at = updated_at.to_i
            file_name = file_name.gsub("tmp/src_backup/", "")

            # keep an internal clock that denotes that current time on the
            # dev machine
            if updated_at > local_state.greatest_tick
              local_state.greatest_tick = updated_at

              # create a new entry in change tracking for the file
              # for every file where the file was last updated, find all the ones where the time is not the same
              # and queue those to be retrieved and required
              # if the last time the dev machine time was retrieved is less than the file time changed
              # then queue the file for reload
              current_updated_at = (local_state.changes[key] || { updated_at: 0 })[:updated_at]
              if updated_at > current_updated_at
                log_spam "* REMOTE HOTLOAD INFO: Queueing file #{file_name} for update."
                local_state.changes[key] = { key: key,
                                             latest_file: file_name,
                                             updated_at: updated_at }
                local_state.changes_queue << local_state.changes[key]
              end
            end
          end
        end

        # set the greatest tick/current time of the machine
        local_state.http_changes = nil
      elsif local_state.http_changes && local_state.http_changes[:http_response_code] == -1 && local_state.http_changes[:complete] && local_state.booted_at
        local_state.http_changes = nil
      end
    end

    def tick_process_queue
      return if local_state.http_file_changes # don't pop a file off the queue if there is an http request in flight
      return if local_state.processing_file_changes # don't pop a file if there is a file currently being processed
      return unless local_state.changes_queue.length > 0 # return if the queue is empty

      # if it isn't empty, pop the first file off the queue (FIFO)
      local_state.processing_file_changes = local_state.changes_queue.pop_front

      # create an http request for the file
      url = get_server_url("/dragon/#{local_state.processing_file_changes[:latest_file]}")
      log_spam "* REMOTE HOTLOAD INFO: Getting new version of #{local_state.processing_file_changes[:latest_file]} (#{url})."
      local_state.http_file_changes = args.gtk.http_get url
    end

    def tick_process_file_retrieval
      return if !local_state.http_file_changes

      # if the http request has finished successfully
      if local_state.http_file_changes && local_state.http_file_changes[:http_response_code] == 200 && local_state.http_file_changes[:complete]
        file_key = local_state.processing_file_changes[:key]
        # notify that a file will be reloaded
        log "* REMOTE HOTLOAD INFO: Loading #{file_key}: #{local_state.processing_file_changes[:latest_file]}"
        log "#{local_state.http_file_changes[:response_data]}"

        # write the latest file with what came back from the response data
        local_state.write_file_queue << { path: file_key, text: local_state.http_file_changes[:response_data] }

        # nil out the currently processing file so a new item can be processed from the queue
        # local_state.reloaded_files_times << local_state.processing_file_changes[:key]
        local_state.http_file_changes = nil
        local_state.processing_file_changes = nil
      end
    end

    def tick_write_file
      local_state.write_file_queue.each do |h|
        log "* REMOTE HOTLOAD INFO: writing file #{h[:path]}"
        $gtk.write_file h[:path], h[:text]
      end

      local_state.write_file_queue.clear
    end
  end
end
