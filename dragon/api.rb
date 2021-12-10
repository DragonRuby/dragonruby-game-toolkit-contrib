# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# api.rb has been released under MIT (*only this file*).

module GTK
  class Api
    def initialize
    end

    def get_api_autocomplete args, req
      html = <<-S
<html>
  <head>
    <meta charset="UTF-8"/>
    <title>DragonRuby Game Toolkit Documentation</title>
    <style>
    pre {
      border: solid 1px silver;
      padding: 10px;
      font-size: 14px;
      white-space: pre-wrap;
      white-space: -moz-pre-wrap;
      white-space: -pre-wrap;
      white-space: -o-pre-wrap;
      word-wrap: break-word;
    }
    </style>
  </head>
  <body>
      <script>
        async function submitForm() {
          const result = await fetch("/dragon/autocomplete/", {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ index: document.getElementById("index").value,
                                   text: document.getElementById("text").value }),
          });
          document.getElementById("autocomplete-results").innerHTML = await result.text();
        }
      </script>
      <form>
        <div>index</div>
        <input name="index" id="index" type="text" value="27" />
        <div>code</div>
        <textarea name="text" id="text" rows="30" cols="80">def tick args
  args.state.
end</textarea>
        <br/>
        <input type="button" value="Get Suggestions" onclick="submitForm();" />
        <span id="success-notification"></span>
      </form>
      <pre id="autocomplete-results">
      </pre>

    #{links}
  </body>
</html>
S

      req.respond 200,
                  html,
                  { 'Content-Type' => 'text/html' }
    end

    def post_api_autocomplete args, req
      json  = ($gtk.parse_json req.body)
      index = json["index"].to_i
      text  = json["text"]
      suggestions = args.gtk.suggest_autocompletion index: index, text: text
      list_as_string = suggestions.join("\n")
      req.respond 200, list_as_string, { 'Content-Type' => 'text/plain' }
    end

    define_method :links do
      <<-S
    <ul>
      <li><a href="/">Home</a></li>
      <li><a href="/docs.html">Docs</a></li>
      <li><a href="/dragon/control_panel/">Control Panel</a></li>
      <li><a href="/dragon/eval/">Console</a></li>
      <li><a href="/dragon/log/">Logs</a></li>
      <li><a href="/dragon/puts/">Puts</a></li>
      <li><a href="/dragon/code/">Code</a></li>
    </ul>
S
    end

    def get_index args, req
      req.respond 200, <<-S, { 'Content-Type' => 'text/html' }
<html>
  <head>
    <meta charset="UTF-8"/>
    <title>DragonRuby Game Toolkit Documentation</title>
  </head>
  <body>
    #{links}
  </body>
</html>
S
    end

    def source_code_links args
      links = args.gtk.reload_list_history.keys.map do |f|
        "<li><a href=\"/dragon/code/edit/?file=#{f}\">#{f}</a></li>"
      end
      <<-S
<ul>
  #{links.join("\n")}
</ul>
S
    end

    def get_api_code args, req
      view = <<-S
<html>
  <head>
    <meta charset="UTF-8"/>
    <title>DragonRuby Game Toolkit Documentation</title>
  </head>
  <body>
    #{source_code_links args}

    #{links}
  </body>
</html>
S
      req.respond 200,
                  view,
                  { 'Content-Type' => 'text/html' }
    end

    def code_edit_view args, file
      view = <<-S
<html>
  <head>
    <meta charset="UTF-8"/>
    <title>DragonRuby Game Toolkit Documentation</title>
  </head>
  <body>
      <script>
        async function submitForm() {
          const result = await fetch("/dragon/code/update/?file=#{file}", {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ code: document.getElementById("code").value }),
          });
          document.getElementById("success-notification").innerHTML = "update successful";
          setTimeout(function() { document.getElementById("success-notification").innerHTML = ""; }, 3000);
        }
      </script>
      <form>
        <div><code>#{file}:</code></div>
        <textarea name="code" id="code" rows="30" cols="80">#{args.gtk.read_file file}</textarea>
        <br/>
        <input type="button" value="Update" onclick="submitForm();" />
        <span id="success-notification"></span>
      </form>
    #{source_code_links args}

    #{links}
  </body>
</html>
S
    end

    def get_api_code_edit args, req
      file = req.uri.split('?').last.gsub("file=", "")
      view = code_edit_view args, file
      req.respond 200,
                  view,
                  { 'Content-Type' => 'text/html' }
    end

    def post_api_code_update args, req
      file = req.uri.split('?').last.gsub("file=", "")
      code = ($gtk.parse_json req.body)["code"]
      args.gtk.write_file file, code
      view = code_edit_view args, file
      req.respond 200,
                  view,
                  { 'Content-Type' => 'text/html' }
    end

    def get_api_boot args, req
      req.respond 200,
                  args.gtk.read_file("tmp/src_backup/boot.txt"),
                  { 'Content-Type' => 'text/plain' }
    end

    def get_api_trace args, req
      req.respond 200,
                  args.gtk.read_file("logs/trace.txt"),
                  { 'Content-Type' => 'text/plain' }
    end

    def get_api_log args, req
      req.respond 200,
                  args.gtk.read_file("logs/log.txt"),
                  { 'Content-Type' => 'text/plain' }
    end

    def post_api_log args, req
      Log.log req.body

      req.respond 200,
                  "ok",
                  { 'Content-Type' => 'text/plain' }
    end

    def get_api_puts args, req
      req.respond 200,
                  args.gtk.read_file("logs/puts.txt"),
                  { 'Content-Type' => 'text/plain' }
    end

    def get_api_changes args, req
      req.respond 200,
                  args.gtk.read_file("tmp/src_backup/src_backup_changes.txt"),
                  { 'Content-Type' => 'text/plain' }
    end

    def get_favicon_ico args, req
      @favicon ||= args.gtk.read_file('docs/favicon.ico')
      req.respond 200, @favicon, { "Content-Type" => 'image/x-icon' }
    end

    def get_src_backup args, req
      file_name = req.uri.gsub("/dragon/", "")
      req.respond 200,
                  args.gtk.read_file("tmp/src_backup/#{file_name}"),
                  { 'Content-Type' => 'text/plain' }
    end

    def get_not_found args, req
      puts("METHOD: #{req.method}");
      puts("URI: #{req.uri}");
      puts("HEADERS:");
      req.headers.each { |k,v| puts("  #{k}: #{v}") }
      req.respond 404, "not found: #{req.uri}", { }
    end

    def get_docs_html args, req
      req.respond 200,
                  args.gtk.read_file("docs/docs.html"),
                  { 'Content-Type' => 'text/html' }
    end

    def get_docs_css args, req
      req.respond 200,
                  args.gtk.read_file("docs/docs.css"),
                  { 'Content-Type' => 'text/css' }
    end

    def get_docs_search_gif args, req
      req.respond 200,
                  args.gtk.read_file("docs/docs_search.gif"),
                  { 'Content-Type' => 'image/gif' }
    end

    def get_src_backup_index_html args, req
      req.respond 200,
                  args.gtk.read_file("/tmp/src_backup/src_backup_index.html"),
                  { 'Content-Type' => 'text/html' }
    end

    def get_src_backup_index_txt args, req
      req.respond 200,
                  args.gtk.read_file("/tmp/src_backup/src_backup_index.txt"),
                  { 'Content-Type' => 'text/txt' }
    end

    def get_src_backup_css args, req
      req.respond 200,
                  args.gtk.read_file("/tmp/src_backup/src_backup.css"),
                  { 'Content-Type' => 'text/css' }
    end

    def get_src_backup_changes_html args, req
      req.respond 200,
                  args.gtk.read_file("/tmp/src_backup/src_backup_changes.html"),
                  { 'Content-Type' => 'text/html' }
    end

    def get_src_backup_changes_txt args, req
      req.respond 200,
                  args.gtk.read_file("/tmp/src_backup/src_backup_changes.txt"),
                  { 'Content-Type' => 'text/txt' }
    end

    def get_api_eval args, req
      eval_view = <<-S
<html lang="en">
  <head><title>Eval</title></head>
  <style>
  pre {
    border: solid 1px silver;
    padding: 10px;
    font-size: 14px;
    white-space: pre-wrap;
    white-space: -moz-pre-wrap;
    white-space: -pre-wrap;
    white-space: -o-pre-wrap;
    word-wrap: break-word;
  }
  </style>
  <body>
    <script>
      async function submitForm() {
          const result = await fetch("/dragon/eval/", {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ code: document.getElementById("code").value }),
          });
          document.getElementById("eval-result").innerHTML = await result.text();
      }
    </script>
    <form>
      <textarea name="code" id="code" rows="10" cols="80"># write your code here and set $result.\n$result = $gtk.args.state</textarea>
      <br/>
      <input type="button" onclick="submitForm();" value="submit" />
    </form>
    <pre>curl -H "Content-Type: application/json" --data '{ "code": "$result = $args.state" }' -X POST http://localhost:9001/dragon/eval/</pre>
    <div>Eval Result:</div>
    <pre id="eval-result"></pre>
    #{links}
  </body>
</html>
S
      req.respond 200,
                  eval_view,
                  { 'Content-Type' => 'text/html' }
    end

    def post_api_eval args, req
      if json? req
        code = ($gtk.parse_json req.body)["code"]
        code = code.gsub("$result", "$eval_result")
        Object.new.instance_eval do
          begin
            Kernel.eval code
          rescue Exception => e
            $eval_result = e
          end
        end
      end

      req.respond 200,
                  "#{$eval_result || $eval_results || "nil"}",
                  { 'Content-Type' => 'text/plain' }

      $eval_result  = nil
      $eval_results = nil
    end

    def api_css_string

    end

    def get_api_console args, req
      html = console_view "# write your code here and set $result.\n$result = $gtk.args.state"
      req.respond 200,
                  html,
                  { 'Content-Type' => 'text/html' }
    end

    def control_panel_view
      <<-S
<html lang="en">
  <head><title>console</title></head>
  <body>
    <script>
      async function submitForm(url) {
        const result = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({}),
        });
        document.getElementById("success-notification").innerHTML = "successful";
        setTimeout(function() { document.getElementById("success-notification").innerHTML = ""; }, 3000);
      }
    </script>
    <form>
      <input type="button" value="Show Console" onclick="submitForm('/dragon/show_console/')" />
    </form>
    <form>
      <input type="button" value="Reset Game" onclick="submitForm('/dragon/reset/');" />
    </form>
    <form>
      <input type="button" value="Record Gameplay" onclick="submitForm('/dragon/record/');" />
    </form>
    <form>
      <input type="button" value="Stop Recording" onclick="submitForm('/dragon/record_stop/');" />
    </form>
    <form>
      <input type="button" value="Replay Recording" onclick="submitForm('/dragon/replay/');" />
    </form>
    <div id="success-notification"></div>
    #{links}
  </body>
</html>
S
    end

    def get_api_control_panel args, req
      req.respond 200,
                  control_panel_view,
                  { 'Content-Type' => 'text/html' }
    end

    def json? req
      req.headers.find { |k, v| k == "Content-Type" && (v.include? "application/json") }
    end

    def post_api_reset args, req
      $gtk.reset if json? req
      req.respond 200,
                  control_panel_view,
                  { 'Content-Type' => 'text/html' }
    end

    def post_api_record args, req
      $recording.start 100 if json? req
      req.respond 200,
                  control_panel_view,
                  { 'Content-Type' => 'text/html' }
    end

    def post_api_record_stop args, req
      $recording.stop 'replay.txt' if json? req
      req.respond 200,
                  control_panel_view,
                  { 'Content-Type' => 'text/html' }
    end

    def post_api_replay args, req
      $replay.start 'replay.txt' if json? req
      req.respond 200,
                  control_panel_view,
                  { 'Content-Type' => 'text/html' }
    end

    def post_api_show_console args, req
      $gtk.console.show if json? req
      req.respond 200,
                  control_panel_view,
                  { 'Content-Type' => 'text/html' }
    end

    def tick args
      args.inputs.http_requests.each do |req|
        match_candidate = { method:                   req.method.downcase.to_sym,
                            uri:                      req.uri,
                            uri_without_query_string: (req.uri.split '?').first,
                            query_string:             (req.uri.split '?').last,
                            has_query_string:         !!(req.uri.split '?').last,
                            has_api_prefix:           (req.uri.start_with? "/dragon"),
                            end_with_rb:              (req.uri.end_with? ".rb"),
                            has_file_extension:       file_extensions.find { |f| req.uri.include? f },
                            has_trailing_slash:       (req.uri.split('?').first.end_with? "/") }

        if !match_candidate[:has_file_extension]
          if !match_candidate[:has_trailing_slash]
            match_candidate[:uri] = match_candidate[:uri_without_query_string] + "/"
            if match_candidate[:query_string]
              match_candidate[:uri] += "?#{match_candidate[:query_string]}"
            end
          end
        end

        context = { args: args, req: req, match_candidate: match_candidate }

        process! context: context, routes: routes
      end
    end

    def url_decode args, string
      args.fn.gsub string,
                   '+', " ",
                   '%27',    "'",
                   '%22',    '"',
                   '%0D%0A', "\n",
                   '%3D',    "=",
                   '%3B',    ";",
                   '%7C',    "|",
                   '%28',    "(",
                   '%29',    ")",
                   '%7B',    "{",
                   '%7D',    "}",
                   '%2C',    ",",
                   '%3A',    ":",
                   '%5B',    "[",
                   '%5D',    "]",
                   '%23',    "#",
                   '%21',    "!",
                   '%3C',    "<",
                   '%3E',    ">",
                   '%2B',    "+",
                   '%2F',    "/",
                   '%40',    "@",
                   '%3F',    "?",
                   '%26',    "&",
                   '%24',    "$",
                   '%5C',    "\\",
                   '%60',    "`",
                   '%7E',    "~",
                   '%C2%B2', "²",
                   '%5E',    "^",
                   '%C2%BA', "º",
                   '%C2%A7', "§",
                   '%20',    " ",
                   '%0A',    "\n",
                   '%25',    "%",
                   '%2A',    "*"
    end

    def file_extensions
      [".html", ".css", ".gif", ".txt", ".ico", ".rb"]
    end

    def routes
      [{ match_criteria: { method: :get, uri: "/" },
         handler:        :get_index },
       { match_criteria: { method: :get, uri: "/dragon/" },
         handler:        :get_index },

       { match_criteria: { method: :get, uri: "/dragon/boot/" },
         handler:        :get_api_boot },
       { match_criteria: { method: :get, uri: "/dragon/trace/" },
         handler:        :get_api_trace },
       { match_criteria: { method: :get, uri: "/dragon/puts/" },
         handler:        :get_api_puts },
       { match_criteria: { method: :get, uri: "/dragon/log/" },
         handler:        :get_api_log },
       { match_criteria: { method: :post, uri: "/dragon/log/" },
         handler:        :post_api_log },
       { match_criteria: { method: :get, uri: "/dragon/changes/" },
         handler:        :get_api_changes },
       { match_criteria: { method: :get, uri: "/dragon/eval/" },
         handler:        :get_api_eval },
       { match_criteria: { method: :post, uri: "/dragon/eval/" },
         handler:        :post_api_eval },
       { match_criteria: { method: :get, uri: "/dragon/console/" },
         handler:        :get_api_console },
       { match_criteria: { method: :post, uri: "/dragon/console/" },
         handler:        :post_api_console },
       { match_criteria: { method: :get, uri: "/dragon/control_panel/" },
         handler:        :get_api_control_panel },
       { match_criteria: { method: :post, uri: "/dragon/reset/" },
         handler:        :post_api_reset },
       { match_criteria: { method: :post, uri: "/dragon/record/" },
         handler:        :post_api_record },
       { match_criteria: { method: :post, uri: "/dragon/record_stop/" },
         handler:        :post_api_record_stop },
       { match_criteria: { method: :post, uri: "/dragon/replay/" },
         handler:        :post_api_replay },
       { match_criteria: { method: :post, uri: "/dragon/show_console/" },
         handler:        :post_api_show_console },
       { match_criteria: { method: :get, uri: "/dragon/code/" },
         handler:        :get_api_code },
       { match_criteria: { method: :get, uri: "/dragon/autocomplete/" },
         handler:        :get_api_autocomplete },
       { match_criteria: { method: :post, uri: "/dragon/autocomplete/" },
         handler:        :post_api_autocomplete },
       { match_criteria: { method: :get, uri_without_query_string: "/dragon/code/edit/", has_query_string: true },
         handler:        :get_api_code_edit },
       { match_criteria: { method: :post, uri_without_query_string: "/dragon/code/update/", has_query_string: true },
         handler:        :post_api_code_update },


       { match_criteria: { method: :get, uri: "/docs.html" },
         handler:        :get_docs_html },
       { match_criteria: { method: :get, uri_without_query_string: "/docs.css" },
         handler:        :get_docs_css },
       { match_criteria: { method: :get, uri: "/docs_search.gif" },
         handler:        :get_docs_search_gif },

       { match_criteria: { method: :get, uri: "/src_backup_index.html" },
         handler:        :get_src_backup_index_html },

       { match_criteria: { method: :get, uri: "/src_backup_index.txt" },
         handler:        :get_src_backup_index_txt },

       { match_criteria: { method: :get, uri: "/src_backup_changes.html" },
         handler:        :get_src_backup_changes_html },

       { match_criteria: { method: :get, uri: "/src_backup_changes.txt" },
         handler:        :get_src_backup_changes_txt },

       { match_criteria: { method: :get, uri: "/src_backup.css" },
         handler:        :get_src_backup_css },

       { match_criteria: { method: :get, uri: "/favicon.ico" },
         handler:        :get_favicon_ico },

       { match_criteria: { method: :get, end_with_rb: true },
         handler:        :get_src_backup },

       { match_criteria: { method: :get, end_with_rb: true },
         handler:        :get_src_backup }

      ]
    end

    def process! opts
      routes  = opts[:routes]
      context = opts[:context]
      routes.each do |route|
        match_found = (process_single! route: route, context: context)
        return if match_found
      end
    end

    def process_single! opts
      match_criteria  = opts[:route][:match_criteria]
      m               = opts[:route][:handler]
      args            = opts[:context][:args]
      req             = opts[:context][:req]
      match_candidate = opts[:context][:match_candidate]
      match_criteria.each do |k, v|
        return false if match_candidate[k] != v
      end

      begin
        send m, args, req
      rescue Exception => e
        req.respond 200,
                    "#{e}\n#{e.__backtrace_to_org__}",
                    { 'Content-Type' => 'text/plain' }
      end
      return true
    end
  end
end
