# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# runtime_docs.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# Ketan Patel: https://github.com/cookieoverflow

module RuntimeDocs
  def docs_method_sort_order
    [
      :docs_class,
      :docs_class_macros,

      :docs_indie_pro_functions,
      # indie/pro
      :docs_get_pixels,
      :docs_dlopen,

      # environment
      :docs_environment_functions,
      :docs_calcstringbox,

      :docs_request_quit,
      :docs_quit_requested?,
      :docs_set_window_fullscreen,
      :docs_window_fullscreen?,
      :docs_set_window_scale,
      :docs_set_window_title,

      :docs_platform?,
      :docs_production?,
      :docs_platform_mappings,
      :docs_open_url,
      :docs_system,
      :docs_exec,

      :docs_show_cursor,
      :docs_hide_cursor,
      :docs_cursor_shown?,

      :docs_set_mouse_grab,
      :docs_set_system_cursor,
      :docs_set_cursor,

      # file
      :docs_file_access_functions,
      :docs_list_files,
      :docs_stat_file,
      :docs_read_file,
      :docs_write_file,
      :docs_append_file,
      :docs_delete_file,

      # encodings
      :docs_encoding_functions,
      :docs_parse_json,
      :docs_parse_json_file,
      :docs_parse_xml,
      :docs_parse_xml_file,

      #network
      :docs_network_functions,
      :docs_http_get,
      :docs_http_post,
      :docs_http_post_body,
      :docs_start_server!,

      #dev support
      :docs_dev_support_functions,
      :docs_version,
      :docs_version_pro?,
      :docs_game_version,

      :docs_reset,
      :docs_reset_next_tick,
      :docs_reset_sprite,
      :docs_reset_sprites,
      :docs_calcspritebox,

      :docs_current_framerate,
      :docs_framerate_diagnostics_primitives,
      :docs_warn_array_primitives!,
      :docs_benchmark,

      :docs_notify!,
      :docs_notify_extended!,
      :docs_slowmo!,

      :docs_show_console,
      :docs_hide_console,
      :docs_enable_console,
      :docs_disable_console,
      :docs_disable_reset_via_ctrl_r,
      :docs_disable_controller_config,
      :docs_enable_controller_config,

      :docs_start_recording,
      :docs_stop_recording,
      :docs_cancel_recording,
      :docs_start_replay,
      :docs_stop_replay,

      :docs_get_base_dir,
      :docs_get_game_dir,
      :docs_get_game_dir_url,
      :docs_open_game_dir,

      :docs_write_file_root,
      :docs_append_file_root,

      :docs_argv,
      :docs_cli_arguments,

      :docs_download_stb_rb,

      :docs_reload_history,
      :docs_reload_history_pending,
      :docs_reload_if_needed,

      :docs_api_summary_state,
    ]
  end

  def docs_class
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 1,
                                      heading_include: "Runtime",
                                      max_depth: 0
  end

  def docs_class_macros
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 2,
                                      heading_include: "Class Macros"
  end

  def docs_indie_pro_functions
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 2,
                                      heading_include: "Indie and Pro Functions",
                                      max_depth: 0
  end

  def docs_get_pixels
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_dlopen
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_environment_functions
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 2,
                                      heading_include: "Environment and Utility Functions",
                                      max_depth: 0
  end

  def docs_calcstringbox
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_request_quit
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_quit_requested?
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_set_window_scale
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_set_window_title
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_set_window_fullscreen
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_window_fullscreen?
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_open_url
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_system
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_exec
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_show_cursor
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_hide_cursor
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_cursor_shown?
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_set_mouse_grab
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_set_system_cursor
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_set_cursor
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_read_file
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_encoding_functions
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_parse_json
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_parse_json_file
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_parse_xml
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_parse_xml_file
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_network_functions
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 2,
                                      heading_include: "Network IO Functions"
  end

  def docs_http_get
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_http_post
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_http_post_body
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_start_server!
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_dev_support_functions
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 2,
                                      heading_include: "Developer Support Functions",
                                      max_depth: 0
  end

  def docs_version
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_game_version
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_version_pro?
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_reset
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_reset_next_tick
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_reset_sprite
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_reset_sprites
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_calcspritebox
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_current_framerate
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_framerate_diagnostics_primitives
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_warn_array_primitives!
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")

  end

  def docs_notify!
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_notify_extended!
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_slowmo!
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_show_console
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_hide_console
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_enable_console
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_disable_controller_config
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_enable_controller_config
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_disable_console
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_disable_reset_via_ctrl_r
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_start_recording
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_stop_recording
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_cancel_recording
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_start_replay
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_stop_replay
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_get_base_dir
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_get_game_dir
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_get_game_dir_url
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_open_game_dir
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_write_file_root
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_append_file_root
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_argv
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_cli_arguments
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end


  def docs_download_stb_rb
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_reload_history
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_reload_history_pending
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_reload_if_needed
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_api_summary_state
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 1,
                                      heading_include: "State"
  end

  def docs_production?
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_platform?
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_platform_mappings
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end


  def docs_stat_file
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_file_access_functions
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 2,
                                      heading_include: "File IO Functions",
                                      max_depth: 0
  end

  def docs_list_files
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_write_file
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_append_file
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_delete_file
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_benchmark
    DocsOrganizer.get_docsify_content path: "docs/api/runtime.md",
                                      heading_level: 3,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end
end

class GTK::Runtime
  extend Docs
  extend RuntimeDocs
end
