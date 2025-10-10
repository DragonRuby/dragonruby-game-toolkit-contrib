# coding: utf-8
# Copyright 2023 DragonRuby LLC
# MIT License
# download_stb_rb.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module DownloadStbRb
      def download_stb_rb_print_usage
        puts <<~S
        * INFO: download_stb_rb usage.
        From the DragonRuby console enter:

        #+begin_src ruby
          $gtk.download_stb_rb GITHUB_URL_TO_FILE_ENDING_IN_RB
        #+end_src

        OR

        #+begin_src ruby
          $gtk.download_stb_rb USER_NAME, REPO_NAME, FILE_NAME_ENDING_IN_RB
        #+end_src

        If the code you are trying to download isn't a github repository, then
        consider using

        #+begin_src ruby
          $gtk.download_stb_rb_raw DOWNLOAD_URL_TO_TEXT_CONTENT, SAVE_PATH
        #+end_src
        S
      end

      def download_stb_rb_raw download_url, save_path, metadata = {}
        entry = metadata.merge download_url: download_url, save_path: save_path
        entry_to_return = entry.copy
        @download_stb_rb_requests[download_url] = entry
        @download_stb_rb_requests[download_url].request = $gtk.http_get(download_url)
        entry_to_return
      end

      alias_method :download_lib_raw, :download_stb_rb_raw

      def download_stb_rb url_or_user_name = nil, repo_name = nil, file_name = nil
        @download_stb_rb_requests ||= {}
        if url_or_user_name && repo_name && file_name
          resolved_user_name = url_or_user_name
          resolved_repo_name = repo_name
          resolved_file_name = file_name
          raw_content_url = "https://raw.githubusercontent.com/#{resolved_user_name}/#{resolved_repo_name}/main/#{resolved_file_name}"
        elsif url_or_user_name && !repo_name && !file_name
          if !url_or_user_name.include? "github.com"
            download_stb_rb_print_usage
            raise "* ERROR: Only github.com url's are currently supported."
          end

          if !url_or_user_name.end_with? ".rb"
            download_stb_rb_print_usage
            raise "* ERROR: The url must point to a single file (url must end in .rb)."
          end

          raw_content_url = url_or_user_name.gsub("github.com", "raw.githubusercontent.com")
                                           .gsub("/blob/", "/")

          resolved_user_name = url_or_user_name.split("github.com/").last.split("/").first.strip
          resolved_file_name = url_or_user_name.split("/").last.strip
          resolved_repo_name = url_or_user_name.split(resolved_user_name).last.split("/").reject(&:empty?).first.strip
        else
          download_stb_rb_print_usage

          return
        end

        return if @download_stb_rb_requests.has_key? raw_content_url

        save_path = File.join(resolved_user_name, resolved_repo_name, resolved_file_name)

        puts "* INFO: invoking download_stb_rb"
        puts "** user_name:       #{resolved_user_name}"
        puts "** repo_name:       #{resolved_repo_name}"
        puts "** file_name:       #{resolved_file_name}"
        puts "** raw_content_url: #{raw_content_url}"

        metadata = {
          user_name:       resolved_user_name,
          repo_name:       resolved_repo_name,
          file_name:       resolved_file_name
        }

        download_stb_rb_raw raw_content_url, save_path, metadata
      end

      alias_method :download_lib, :download_stb_rb

      def tick_download_stb_rb
        return if !Kernel.tick_count.zmod? 60

        @download_stb_rb_requests ||= {}

        @download_stb_rb_requests.each do |url, entry|
          if entry.request.http_response_code == 200 && entry.request.complete
            $gtk.write_file entry.save_path, entry.request.response_data
            puts <<~S

                 * INFO: File written to #{entry.save_path}
                 Verify the contents of the file and then add the following to the top of main.rb:
                 #+begin_src ruby
                   require "#{entry.save_path}"
                 #+end_src
                 S
            $gtk.show_console
          elsif entry.request.http_response_code != 200 && entry.request.complete
            puts <<~S

                 * ERROR: Failed to download #{url}.
                 Response code: #{entry.request.http_response_code}
                 S
            $gtk.show_console
          end
        end

        @download_stb_rb_requests.reject! { |url, entry| entry.request.complete }
      rescue Exception => e
        @download_stb_rb_requests.clear
        raise e
      end
    end # end DownloadStbRb module
  end # end Runtime class
end # end GTK module

module GTK
  class Runtime
    include DownloadStbRb
  end
end
