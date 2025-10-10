# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# ios_wizard.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright: Michał Dudziński

class IOSWizard < Wizard
  def help
    puts <<~S
         * INFO: Help for #{self.class.name}
           Here are the available options for this wizard (these options can be invoked through the DragonRuby Console):
         ** Device
         *** Deploy app to device connected via USB:
             #+begin_src
               $wizards.ios.start env: :dev
             #+end_src
         *** Deploy app to device connected via USB with remote hotload:
             #+begin_src
               $wizards.ios.start env: :hotload
             #+end_src
         *** Do not uninstall game before deploy the new version
             Supported in both ~:dev~ and ~:hotload~
             #+begin_src
               $wizards.ios.start env: :dev, uninstall: false
             #+end_src
         ** Simulator
         *** Deploy app to simulator
             The default simulator is iPhone 13 Pro Max and will be automatically installed if it doesn't exist.
             #+begin_src
               $wizards.ios.start env: :sim
             #+end_src
         *** Deploy app to simulator and specify a device (partial device name allowed):
             #+begin_src
               $wizards.ios.start env: :sim, sim_name: "iPad Pro"
             #+end_src
         *** Reset simulators
             Delete all content from simulators and reset them
             #+begin_src
               $wizards.ios.reset_simulators
             #+end_src
         ** Distribution
         *** Package app for production release:
             #+begin_src
               $wizards.ios.start env: :prod
             #+end_src
         S
  end

  def initialize
    @doctor_executed_at = 0
  end

  def root_dir
    $gtk.get_base_dir
  end

  def prerequisite_steps
    [
      :check_for_xcode,
      :check_for_brew,
      :check_for_certs,
    ]
  end

  def app_metadata_retrieval_steps
    [
      :determine_team_identifier,
      :determine_app_name,
      :determine_app_id,
    ]
  end

  def steps_dev_build
    [
      *prerequisite_steps,

      :check_for_device,
      :check_for_dev_profile,

      *app_metadata_retrieval_steps,
      :determine_devcert,

      :clear_tmp_directory,
      :stage_ios_app,

      :development_write_info_plist,

      :write_entitlements_plist,
      :compile_icons,
      :clear_payload_directory,

      :create_dev_payload_directory,

      :create_payload,
      :code_sign_binary,
      :create_ipa,
      :deploy_to_device
    ]
  end

  def steps_test_build
    [
      *prerequisite_steps,

      :check_for_device,
      :check_for_dev_profile,

      *app_metadata_retrieval_steps,
      :determine_devcert,

      :clear_tmp_directory,
      :stage_ios_app,

      :development_write_info_plist,

      :write_entitlements_plist,
      :compile_icons,
      :clear_payload_directory,

      :create_test_payload_directory,

      :create_payload,
      :code_sign_binary,
      :create_ipa,
      :deploy_to_device
    ]
  end

  def steps_sim_build
    [
      *prerequisite_steps,
      :install_simulator_if_needed,

      *app_metadata_retrieval_steps,
      :determine_devcert,

      :clear_tmp_directory,
      :stage_sim_app,

      :development_write_info_plist,

      :write_entitlements_plist,
      :compile_icons,
      :clear_payload_directory,

      :create_sim_payload_directory,

      :create_payload,
      :code_sign_binary,
      :create_ipa,
      :deploy_to_sim
    ]
  end

  def steps_prod_build
    [
      *prerequisite_steps,

      :check_for_distribution_profile,
      :determine_app_version,

      *app_metadata_retrieval_steps,
      :determine_prodcert,

      :clear_tmp_directory,
      :stage_ios_app,

      :production_write_info_plist,

      :write_entitlements_plist,
      :compile_icons,
      :clear_payload_directory,

      :create_prod_payload_directory,

      :create_payload,
      :code_sign_binary,
      :create_ipa,
      :print_publish_help
    ]
  end

  def get_reserved_sprite png
    sprite_path = ".dragonruby/sprites/wizards/ios/#{png}"

    if !$gtk.ivar :rcb_release_mode
      sprite_path = "deploy_template/#{sprite_path}"
      $gtk.reset_sprite sprite_path
    end

    if !$gtk.read_file sprite_path
      log_error "png #{png} not found."
    end

    sprite_path
  end

  def production_build?
    @build_type == :prod
  end

  def dev_build?
    @build_type == :dev || hotload_build? || @build_type == :test
  end

  def sim_build?
    @build_type == :sim
  end

  def hotload_build?
    @build_type == :hotload || sim_build?
  end

  def start opts = nil
    @opts = opts || {}

    if !(@opts.is_a? Hash) || !($gtk.args.fn.eq_any? @opts[:env], :dev, :prod, :hotload, :sim, :test)
      process_wizard_exception WizardException.new(
                                 "* $wizards.ios.start needs to be provided an ~env:~ option.",
                                 "** To deploy your app to an iOS device connected to your computer:\n   $wizards.ios.start env: :dev",
                                 "** To deploy your app with hotloading to an iOS device connected to your computer:\n   $wizards.ios.start env: :hotload",
                                 "** To deploy your app to the iOS Simulator:\n   $wizards.ios.start env: :sim",
                                 "** To deploy your app for sale on the AppStore:\n   $wizards.ios.start env: :prod",
                                 "** For more help type:\n   $wizards.ios.help",
                               )
    end

    @should_uninstall = @opts[:uninstall]
    @build_type = @opts[:env]
    @certificate_name = nil
    @app_version = opts[:version]
    @app_version = "1.0" if @opts[:env] == :dev && !@app_version
    init_wizard_status
    $console.set_command_silent "Starting iOS Wizard with #{@opts}, please wait..."
    GTK.on_tick_count Kernel.tick_count + 30 do
      execute_steps get_steps_to_execute
      $console.set_command_silent ""
    end
    nil
  end

  def always_fail
    return false if $gtk.ivar :rcb_release_mode
    return true
  end

  def check_for_xcode
    result = sh "xcrun simctl list devices"

    simctl_missing = result.include? "unable to find utility"

    if !cli_app_exist?(xcodebuild_cli_app) || simctl_missing
      raise WizardException.new(
        "* You need Xcode to use $wizards.ios.start.",
        { w: 75, h: 75, path: get_reserved_sprite("xcode.png") },
        "** 1. Go to http://developer.apple.com and register.",
        "** 2. Download Xcode 11.3+ from http://developer.apple.com/downloads.",
        "   NOTE: DO NOT install Xcode from the App Store. Use the link above.",
        { w: 700, h: 359, path: get_reserved_sprite("xcode-downloads.png") },
        "** 3. After installing. Open up Xcode to accept the EULA."
      )
    end

    :success
  end

  def check_for_brew
    if !cli_app_exist?('brew')
      raise WizardException.new(
        "* You need to install Brew.",
        { w: 700, h: 388, path: get_reserved_sprite("brew.png") },
        "** 1. Go to http://brew.sh.",
        "** 2. Copy the command that starts with `/bin/bash -c` on the site.",
        "** 3. Open Terminal and run the command you copied from the website.",
        { w: 700, h: 99, path: get_reserved_sprite("terminal.png") },
      )
    end

    :success
  end

  def init_wizard_status
    @wizard_status = {}
    get_steps_to_execute.each do |m|
      @wizard_status[m] = { result: :not_started }
    end

    previous_step = nil
    next_step = nil
    get_steps_to_execute.each_cons(2) do |current_step, next_step|
      @wizard_status[current_step][:next_step] = next_step
    end

    get_steps_to_execute.reverse.each_cons(2) do |current_step, previous_step|
      @wizard_status[current_step][:previous_step] = previous_step
    end
  end

  def restart
    init_wizard_status
    start
  end

  def reset
    init_wizard_status
  end

  def check_for_distribution_profile
    @provisioning_profile_path = "profiles/distribution.mobileprovision"
    if !($gtk.read_file @provisioning_profile_path)
      $gtk.system "mkdir -p #{root_dir}/profiles"
      $gtk.system "open #{root_dir}/profiles"
      $gtk.system "echo Download the mobile provisioning profile and place it here with the name distribution.mobileprovision > #{root_dir}/profiles/README.txt"
      raise WizardException.new(
        "* I didn't find a mobile provision.",
        "** 1. Go to http://developer.apple.com and click \"Certificates, IDs & Profiles\".",
        "** 2. Add an App Identifier.",
        "** 3. Select the App IDs option from the list.",
        { w: 700, h: 75, path: get_reserved_sprite("identifiers.png") },
        "** 4. Add your Device next. You can use idevice_id -l to get the UUID of your device.",
        { w: 365, h: 69, path: get_reserved_sprite("device-link.png") },
        "** 5. Create a Profile. Associate your certs, id, and device.",
        { w: 300, h: 122, path: get_reserved_sprite("profiles.png") },
        "** 6. Download the mobile provision and save it to 'profiles/development.mobileprovision'.",
        { w: 200, h: 124, path: get_reserved_sprite("profiles-folder.png") },
      )
    end

    :success
  end

  def check_for_dev_profile
    @provisioning_profile_path = "profiles/development.mobileprovision"
    if !($gtk.read_file @provisioning_profile_path)
      $gtk.system "mkdir -p #{root_dir}/profiles"
      $gtk.system "open #{root_dir}/profiles"
      $gtk.system "echo Download the mobile provisioning profile and place it here with the name development.mobileprovision > #{root_dir}/profiles/README.txt"
      raise WizardException.new(
        "* I didn't find a mobile provision.",
        "** 1. Go to http://developer.apple.com and click \"Certificates, IDs & Profiles\".",
        "** 2. Add an App Identifier.",
        "** 3. Select the App IDs option from the list.",
        { w: 700, h: 75, path: get_reserved_sprite("identifiers.png") },
        "** 4. Add your Device next. You can use idevice_id -l to get the UUID of your device.",
        { w: 365, h: 69, path: get_reserved_sprite("device-link.png") },
        "** 5. Create a Profile. Associate your certs, id, and device.",
        { w: 300, h: 122, path: get_reserved_sprite("profiles.png") },
        "** 6. Download the mobile provision and save it to 'profiles/development.mobileprovision'.",
        { w: 200, h: 124, path: get_reserved_sprite("profiles-folder.png") },
        "* NOTE: If you don't want to create a mobile provision right now, you can deploy to the simulator without one. Run the following command:",
        <<~S
        #+begin_src ruby
          # run this in the console to deploy to the simulator (no provisioning profile needed)
          $wizards.ios.start env: :sim
        #+end_src
        S
      )
    end

    :success
  end

  def provisioning_profile_path environment
    return File.expand_path("profiles/distribution.mobileprovision") if environment == :prod
    return File.expand_path("profiles/development.mobileprovision")
  end

  def ios_metadata_template
    <<-S
# ios_metadata.txt is used by the Pro version of DragonRuby Game Toolkit to create iOS apps.
# Information about the Pro version can be found at: http://dragonruby.org/toolkit/game#purchase

# teamid needs to be set to your assigned Team Id which can be found at https://developer.apple.com/account/#/membership/
teamid=
# appid needs to be set to your application identifier which can be found at https://developer.apple.com/account/resources/identifiers/list
appid=
# appname is the name you want to show up underneath the app icon on the device. Keep it under 10 characters.
appname=
# devcert is the certificate to use for development/deploying to your local device. This is the NAME of the certificate as it's displayed in Keychain Access.
devcert=
# prodcert is the certificate to use for distribution to the app store. This is the NAME of the certificate as it's displayed in Keychain Access.
prodcert=
S
  end

  def ios_metadata
    contents = $gtk.read_file 'metadata/ios_metadata.txt'

    if !contents
      $gtk.write_file 'metadata/ios_metadata.txt', ios_metadata_template
      contents = $gtk.read_file 'metadata/ios_metadata.txt'
    end

    kvps = contents.each_line
                   .reject { |l| l.strip.length == 0 || (l.strip.start_with? "#") }
                   .map do |l|
                     key, value = l.split("=")
                     [key.strip.to_sym, value.strip]
                   end.flatten
    Hash[*kvps]
  end

  def game_metadata
    contents = $gtk.read_file 'metadata/game_metadata.txt'

    kvps = contents.each_line
                   .reject { |l| l.strip.length == 0 || (l.strip.start_with? "#") }
                   .map do |l|
                     key, value = l.split("=")
                     [key.strip.to_sym, value.strip]
                   end.flatten
    Hash[*kvps]
  end

  def raise_ios_metadata_required
    raise WizardException.new(
            "* mygame/metadata/ios_metadata.txt needs to be filled out.",
            "You need to update metadata/ios_metadata.txt with a valid teamid, appname, appid, devcert, and prodcert.",
            "Instructions for where the values should come from are within metadata/ios_metadata.txt."
          )
  end

  def determine_team_identifier
    @team_id = (ios_metadata.teamid || "").strip
    if @build_type == :sim && @team_id.length == 0
      log_warn <<-S
* WARNING: =mygame/metadata/ios_metadata.txt= does not specify =teamid=
  Since this is a simulator build, the default =teamid= of =UNKNOWN= will be used.
S
      @team_id = "UNKNOWN"
    elsif @team_id.length == 0
      raise_ios_metadata_required if @team_id.strip.length == 0
    end
    log_info "Team Identifer is: #{@team_id}"
    :success
  end

  def determine_app_name
    @app_name = (ios_metadata.appname || "").strip
    if @build_type == :sim && @app_name.length == 0
      log_warn <<-S
* WARNING: =mygame/metadata/ios_metadata.txt= does not specify =appname=
  Since this is a simulator build, the default =appname= of =Game= will be used.
S
      @app_name = "Game"
    elsif @app_name.length == 0
      raise_ios_metadata_required if @app_name.length == 0
    end

    log_info "App name is: #{@app_name}."
    :success
  end

  def provisioning_profile_xml environment
    xml = $gtk.read_file (provisioning_profile_path environment)
    scrubbed = xml.each_line.map do |l|
      if l.strip.start_with? "<"
        if l.start_with? '</plist>'
          '</plist>'
        elsif l.include? "Apple Inc."
          nil
        elsif l.include? '<data>'
          nil
        else
          l
        end
      else
        nil
      end
    end.reject { |l| !l }.join
    $gtk.parse_xml scrubbed
  end

  def determine_app_id
    @app_id = (ios_metadata.appid || "").strip
    if @build_type == :sim && @app_id.length == 0
      log_warn <<-S
* WARNING: =mygame/metadata/ios_metadata.txt= does not specify =appid=
  Since this is a simulator build, the default =appid= of =com.unknown.game= will be used.
S
      @app_id = "com.unknown.game"
    elsif @app_id.length == 0
      raise_ios_metadata_required if @app_id.strip.length == 0
    end
    log_info "App Identifier is set to: #{@app_id}"
    :success
  end

  def determine_devcert
    @certificate_name = (ios_metadata.devcert || "").strip
    if @build_type == :sim && @certificate_name.length == 0
      log_warn <<-S
* WARNING: =mygame/metadata/ios_metadata.txt= does not specify =devcert=
  Since this is a simulator build, the default =devcert= of =Unknown= will be used.
S
      @certificate_name = "Unknown"
    elsif @certificate_name.length == 0
      raise_ios_metadata_required
    end
    log_info "Dev Certificate is set to: #{@certificate_name}"
    :success
  end

  def determine_prodcert
    @certificate_name = ios_metadata.prodcert
    raise_ios_metadata_required if @certificate_name.strip.length == 0
    log_info "Production (Distribution) Certificate is set to: #{@certificate_name}"
    :success
  end

  def set_app_name name
    @app_name = name
    start
  end

  def set_dev_profile path
    if !$gtk.read_file path
      log_error "I couldn't find a development profile at #{path}."
      ask_for_dev_profile
    else
      @provisioning_profile_path = path
      start
    end
  end

  def clear_tmp_directory
    sh "rm -rf #{tmp_directory}"
    :success
  end

  def set_app_id id
    log_info = "App Id set to: #{id}"
    @app_id = id
    start
  end

  def check_for_device
    log_info "Looking for device."

    if !cli_app_exist?(idevice_id_path)
      raise WizardException.new(
         "* It doesn't look like you have the libimobiledevice iOS protocol library installed.",
         "** 1. Open Terminal.",
         { w: 700, h: 99, path: get_reserved_sprite("terminal.png") },
         "** 2. Run: `brew install libimobiledevice`.",
         { w: 500, h: 93, path: get_reserved_sprite("brew-install-libimobiledevice.png") },
      )
    end

    if !cli_app_exist?(ideviceinstaller_cli_app)
      raise WizardException.new(
         "* It doesn't look like you have the libimobiledevice iOS protocol library installed.",
         "** 1. Open Terminal.",
         { w: 700, h: 99, path: get_reserved_sprite("terminal.png") },
         "** 2. Run: `brew install ideviceinstaller`.",
         { w: 500, h: 91, path: get_reserved_sprite("brew-install-ideviceinstaller.png") },
      )
    end

    if connected_devices.length == 0
      raise WizardException.new("* I couldn't find any connected devices. Connect your iOS device to your Mac and try again.")
    end

    @device_id = connected_devices.first
    log_info "I will be using device with UUID #{@device_id}"
    :success
  end

  def check_for_certs
    log_info "Attempting to find certificates on your computer."

    if production_build?
      @certificate_name = ios_metadata[:prodcert]
    elsif dev_build?
      @certificate_name = ios_metadata[:devcert]
    else
      raise "I don't know how to ~check_for_certs~ for a build_type/env of #{@build_type}."
    end

    log_info "I will be using certificate: '#{@certificate_name}'."

    :success
  end

  def codesign_allocate_path
    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate"
  end

  def codesign_path
    "/usr/bin/codesign"
  end

  def idevice_id_path
    "idevice_id"
  end

  def ideviceinstaller_cli_app
    "ideviceinstaller"
  end

  def security_cli_app
    "/usr/bin/security"
  end

  def xcodebuild_cli_app
    "xcodebuild"
  end

  def connected_devices
    sh("idevice_id -l").strip.each_line.map do |l|
      l.strip
    end.reject { |l| l.length == 0 }
  end

  def cli_app_exist? app
    `which #{app}`.strip.length != 0
  end

  def write_entitlements_plist
    if production_build?
      entitlement_plist_string = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
        <dict>
                <key>application-identifier</key>
                <string>:app_id</string>
                <key>beta-reports-active</key>
                <true/>
        </dict>
</plist>
XML
    else
      entitlement_plist_string = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
        <dict>
                <key>application-identifier</key>
                <string>:app_id</string>
                <key>get-task-allow</key>
                <true/>
        </dict>
</plist>
XML
    end

    log_info "Creating Entitlements.plist"

    $gtk.write_file_root "tmp/ios/Entitlements.plist", entitlement_plist_string.gsub(":app_id", "#{@team_id}.#{@app_id}").strip
    $gtk.write_file_root "tmp/ios/Entitlements.txt", entitlement_plist_string.gsub(":app_id", "#{@team_id}.#{@app_id}").strip

    sh "/usr/bin/plutil -convert binary1 \"#{tmp_directory}/Entitlements.plist\""
    sh "/usr/bin/plutil -convert xml1 \"#{tmp_directory}/Entitlements.plist\""

    @entitlement_plist_written = true
    :success
  end

  def code_sign_binary
    log_info "Signing app with #{@certificate_name}."

    sh "xattr -cr \"#{tmp_directory}/ipa_root/Payload/#{@app_name}.app\""
    sh "CODESIGN_ALLOCATE=\"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate\" /usr/bin/codesign -f -s \"#{@certificate_name}\" --entitlements #{tmp_directory}/Entitlements.plist \"#{tmp_directory}/ipa_root/Payload/#{@app_name}.app\""

    sh "xattr -cr \"#{tmp_directory}/ipa_root/Payload/#{@app_name}.app/#{@app_name}\""
    sh "CODESIGN_ALLOCATE=\"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate\" /usr/bin/codesign -f -s \"#{@certificate_name}\" --entitlements #{tmp_directory}/Entitlements.plist \"#{tmp_directory}/ipa_root/Payload/#{@app_name}.app/#{@app_name}\""

    @code_sign_completed = true
    :success
  end

  def __get_plist_orientation_values_xml__
    values_xml = __get_plist_orientation_values__.map do |v|
      <<-S.rstrip
                <string>#{v}</string>
S
    end.join "\n"

    array_xml = <<-S.rstrip
        <array>
#{values_xml}
        </array>
S

    array_xml
  end

  def __get_plist_orientation_values__
    orientation_string_landscape_left = "UIInterfaceOrientationLandscapeLeft"
    orientation_string_landscape_right = "UIInterfaceOrientationLandscapeRight"
    orientation_string_portrait = "UIInterfaceOrientationPortrait"

    # check ios orientation override and return plist values accordingly
    ios_orientation = Cvars["game_metadata.orientation_ios"].value
    ios_orientation = Cvars["game_metadata.orientation"].value if ios_orientation.length == 0

    if ios_orientation == "portrait,landscape"
      [orientation_string_portrait, orientation_string_landscape_right, orientation_string_landscape_left]
    elsif ios_orientation == "landscape,portrait"
      [orientation_string_landscape_right, orientation_string_landscape_left, orientation_string_portrait]
    elsif ios_orientation == "portrait"
      [orientation_string_portrait]
    elsif ios_orientation == "landscape"
      [orientation_string_landscape_right, orientation_string_landscape_left]
    end
  end

  def development_write_info_plist
    log_info "Adding Info.plist."


    info_plist_string = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>BuildMachineOSBuild</key>
        <string>20D91</string>
        <key>CFBundleDevelopmentRegion</key>
        <string>en</string>
        <key>CFBundleDisplayName</key>
        <string>:app_name</string>
        <key>CFBundleExecutable</key>
        <string>:app_name</string>
        <key>NSAppTransportSecurity</key>
        <dict>
          <key>NSAllowsArbitraryLoads</key>
          <true/>
        </dict>        <key>CFBundleIconFiles</key>
        <array>
                <string>AppIcon60x60</string>
        </array>
        <key>CFBundleIcons</key>
        <dict>
                <key>CFBundlePrimaryIcon</key>
                <dict>
                        <key>CFBundleIconFiles</key>
                        <array>
                                <string>AppIcon60x60</string>
                        </array>
                        <key>CFBundleIconName</key>
                        <string>AppIcon</string>
                </dict>
        </dict>
        <key>CFBundleIcons~ipad</key>
        <dict>
                <key>CFBundlePrimaryIcon</key>
                <dict>
                        <key>CFBundleIconFiles</key>
                        <array>
                                <string>AppIcon60x60</string>
                                <string>AppIcon76x76</string>
                                <string>AppIcon83.5x83.5</string>
                        </array>
                        <key>CFBundleIconName</key>
                        <string>AppIcon</string>
                </dict>
        </dict>
        <key>CFBundleIdentifier</key>
        <string>:app_id</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>:app_version</string>
        <key>CFBundleName</key>
        <string>:app_name</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>:app_version</string>
        <key>CFBundleSignature</key>
        <string>????</string>
        <key>CFBundleSupportedPlatforms</key>
        <array>
                <string>iPhoneOS</string>
        </array>
        <key>CFBundleVersion</key>
        <string>:app_version</string>
        <key>DTCompiler</key>
        <string>com.apple.compilers.llvm.clang.1_0</string>
        <key>DTPlatformBuild</key>
        <string>18D46</string>
        <key>DTPlatformName</key>
        <string>iphoneos</string>
        <key>DTPlatformVersion</key>
        <string>11.0</string>
        <key>DTSDKBuild</key>
        <string>18D46</string>
        <key>DTSDKName</key>
        <string>iphoneos14.4</string>
        <key>DTXcode</key>
        <string>0124</string>
        <key>DTXcodeBuild</key>
        <string>12D4e</string>
        <key>MinimumOSVersion</key>
        <string>11.0</string>
        <key>UIAppFonts</key>
        <array/>
        <key>UIBackgroundModes</key>
        <array/>
        <key>UIDeviceFamily</key>
        <array>
                <integer>1</integer>
                <integer>2</integer>
        </array>
        <key>UILaunchStoryboardName</key>
        <string>SimpleSplash</string>
        <key>UIRequiredDeviceCapabilities</key>
        <array>
                <string>arm64</string>
        </array>
        <key>UIRequiresFullScreen</key>
        <true/>
        <key>UIStatusBarStyle</key>
        <string>UIStatusBarStyleDefault</string>
        <key>UISupportedInterfaceOrientations</key>
#{__get_plist_orientation_values_xml__}
        <key>CFBundleURLTypes</key>
        <array>
            <dict>
                <key>CFBundleURLName</key>
                <string>:app_id</string>
                <key>CFBundleURLSchemes</key>
                <array>
                    <string>:app_id</string>
                </array>
            </dict>
        </array>
    </dict>
</plist>
XML

    # <string>UIInterfaceOrientationPortrait</string>
    # <string>UIInterfaceOrientationLandscapeRight</string>

    info_plist_string.gsub!(":app_name", @app_name)
    info_plist_string.gsub!(":app_id", @app_id)

    $gtk.write_file_root "tmp/ios/#{@app_name}.app/Info.plist", info_plist_string.strip
    $gtk.write_file_root "tmp/ios/Info.txt", info_plist_string.strip

    @info_plist_written = true
    :success
  end

  def production_write_info_plist
    log_info "Adding Info.plist."

    info_plist_string = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>BuildMachineOSBuild</key>
        <string>20D91</string>
        <key>CFBundleDevelopmentRegion</key>
        <string>en</string>
        <key>CFBundleDisplayName</key>
        <string>:app_name</string>
        <key>CFBundleExecutable</key>
        <string>:app_name</string>
        <key>CFBundleIconFiles</key>
        <array>
                <string>AppIcon60x60</string>
        </array>
        <key>CFBundleIcons</key>
        <dict>
                <key>CFBundlePrimaryIcon</key>
                <dict>
                        <key>CFBundleIconFiles</key>
                        <array>
                                <string>AppIcon60x60</string>
                        </array>
                        <key>CFBundleIconName</key>
                        <string>AppIcon</string>
                </dict>
        </dict>
        <key>CFBundleIcons~ipad</key>
        <dict>
                <key>CFBundlePrimaryIcon</key>
                <dict>
                        <key>CFBundleIconFiles</key>
                        <array>
                                <string>AppIcon60x60</string>
                                <string>AppIcon76x76</string>
                                <string>AppIcon83.5x83.5</string>
                        </array>
                        <key>CFBundleIconName</key>
                        <string>AppIcon</string>
                </dict>
        </dict>
        <key>CFBundleIdentifier</key>
        <string>:app_id</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>:app_version</string>
        <key>CFBundleName</key>
        <string>:app_name</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>:app_version</string>
        <key>CFBundleSignature</key>
        <string>????</string>
        <key>CFBundleSupportedPlatforms</key>
        <array>
                <string>iPhoneOS</string>
        </array>
        <key>CFBundleVersion</key>
        <string>:app_version</string>
        <key>DTCompiler</key>
        <string>com.apple.compilers.llvm.clang.1_0</string>
        <key>DTPlatformBuild</key>
        <string>18D46</string>
        <key>DTPlatformName</key>
        <string>iphoneos</string>
        <key>DTPlatformVersion</key>
        <string>14.4</string>
        <key>DTSDKBuild</key>
        <string>18D46</string>
        <key>DTSDKName</key>
        <string>iphoneos14.4</string>
        <key>DTXcode</key>
        <string>0124</string>
        <key>DTXcodeBuild</key>
        <string>12D4e</string>
        <key>MinimumOSVersion</key>
        <string>11.0</string>
        <key>UIAppFonts</key>
        <array/>
        <key>UIBackgroundModes</key>
        <array/>
        <key>UIDeviceFamily</key>
        <array>
                <integer>1</integer>
                <integer>2</integer>
        </array>
        <key>UILaunchStoryboardName</key>
        <string>SimpleSplash</string>
        <key>UIRequiredDeviceCapabilities</key>
        <array>
                <string>arm64</string>
        </array>
        <key>UIRequiresFullScreen</key>
        <true/>
        <key>UIStatusBarStyle</key>
        <string>UIStatusBarStyleDefault</string>
        <key>UISupportedInterfaceOrientations</key>
#{__get_plist_orientation_values_xml__}
        <key>CFBundleURLTypes</key>
        <array>
            <dict>
                <key>CFBundleURLName</key>
                <string>:app_id</string>
                <key>CFBundleURLSchemes</key>
                <array>
                    <string>:app_id</string>
                </array>
            </dict>
        </array>
</dict>
</plist>
XML

    # <string>UIInterfaceOrientationPortrait</string>
    # <string>UIInterfaceOrientationLandscapeRight</string>

    info_plist_string.gsub!(":app_name", @app_name)
    info_plist_string.gsub!(":app_id", @app_id)
    info_plist_string.gsub!(":app_version", @app_version)

    $gtk.write_file_root "tmp/ios/#{@app_name}.app/Info.plist", info_plist_string.strip
    $gtk.write_file_root "tmp/ios/Info.txt", info_plist_string.strip

    @info_plist_written = true
    :success
  end

  def tmp_directory
    "#{root_dir}/tmp/ios"
  end

  def app_path
    "#{tmp_directory}/#{@app_name}.app"
  end

  def game_dir
    GTK.get_game_dir
  end

  def embed_mobileprovision
    sh %Q[cp #{@provisioning_profile_path} "#{app_path}/embedded.mobileprovision"]
    sh %Q[/usr/bin/plutil -convert binary1 "#{app_path}/Info.plist"]
    :success
  end

  def clear_payload_directory
    sh %Q[rm "#{@app_name}".ipa]
    sh %Q[rm -rf "#{app_path}/app"]
    sh %Q[rm -rf "#{app_path}/sounds"]
    sh %Q[rm -rf "#{app_path}/sprites"]
    sh %Q[rm -rf "#{app_path}/data"]
    sh %Q[rm -rf "#{app_path}/fonts"]
    sh %Q[rm -rf "#{app_path}/metadata"]
    :success
  end

  def root_folder_directories
    directories = $gtk.list_files ""
    ignored_directories = Cvars["game_metadata.ignore_directories"].value
                                                                   .split(",")
                                                                   .reject { |d| d.strip.length == 0 }
    directories.reject { |d| ignored_directories.include? d }
  end

  def stage_ios_app
    log_info "Staging."
    sh "mkdir -p #{tmp_directory}"
    sh "cp -R #{root_dir}/dragonruby-ios.app/ \"#{tmp_directory}/#{@app_name}.app/\""
    sh "mv \"#{tmp_directory}/#{@app_name}.app/Runtime\" \"#{tmp_directory}/#{@app_name}.app/#{@app_name}\""
    root_folder_directories.each do |d|
      sh %Q[cp -r "#{game_dir}/#{d}/" "#{app_path}/#{d}/"]
    end
    :success
  end

  def stage_sim_app
    log_info "Staging."
    sh "codesign --remove-signature #{root_dir}/dragonruby-ios-simulator.app/Runtime"
    sh "mkdir -p #{tmp_directory}"
    sh "cp -R #{root_dir}/dragonruby-ios-simulator.app/ \"#{tmp_directory}/#{@app_name}.app/\""
    sh "mv \"#{tmp_directory}/#{@app_name}.app/Runtime\" \"#{tmp_directory}/#{@app_name}.app/#{@app_name}\""
    root_folder_directories.each do |d|
      sh %Q[cp -r "#{game_dir}/#{d}/" "#{app_path}/#{d}/"]
    end
    :success
  end

  def create_payload
    sh %Q[mkdir -p #{tmp_directory}/ipa_root/Payload]
    sh %Q[cp -r "#{app_path}" "#{tmp_directory}/ipa_root/Payload"]
    sh %Q[chmod -R 755 "#{tmp_directory}/ipa_root/Payload"]
    :success
  end

  def write_server_ip_address
    if sim_build?
      sh %Q[mkdir -p "#{app_path}/metadata/"]
      sh %Q[echo localhost]
      sh %Q[echo localhost > "#{app_path}/metadata/dragonruby_remote_hotload"]
    else
      sh %Q[mkdir -p "#{app_path}/metadata/"]
      sh %Q[echo #{$gtk.ffi_misc.get_local_ip_address.strip}]
      sh %Q[echo #{$gtk.ffi_misc.get_local_ip_address.strip} > "#{app_path}/metadata/dragonruby_remote_hotload"]
    end
    :success
  end

  def create_dev_payload_directory
    embed_mobileprovision
    clear_payload_directory
    stage_ios_app
    # write dev machine's ip address for hotloading
    write_server_ip_address if hotload_build?

    # production build marker
    sh %Q[mkdir -p "#{app_path}/metadata/"]
    :success
  end

  def create_test_payload_directory
    embed_mobileprovision
    clear_payload_directory
    stage_ios_app
    # write dev machine's ip address for hotloading
    write_server_ip_address if hotload_build?

    # production build marker
    sh %Q[mkdir -p "#{app_path}/metadata/"]
    sh %Q[touch "#{app_path}/metadata/dragonruby_production_build"]
    :success
  end

  def create_prod_payload_directory
    # production builds does not hotload ip address
    sh %Q[rm "#{game_dir}/app/server_ip_address.txt"]

    embed_mobileprovision
    stage_ios_app

    # production build marker
    sh %Q[mkdir -p "#{app_path}/metadata/"]
    sh %Q[touch "#{app_path}/metadata/dragonruby_production_build"]
    :success
  end

  def create_sim_payload_directory
    embed_mobileprovision
    clear_payload_directory
    stage_sim_app
    write_server_ip_address

    # production build marker
    sh %Q[mkdir -p "#{app_path}/metadata/"]
    :success
  end

  def create_ipa
    do_zip
    sh "cp \"#{tmp_directory}/ipa_root/archive.zip\" \"#{tmp_directory}/#{@app_name}.ipa\""
    :success
  end

  def do_zip
    $gtk.write_file_root "tmp/ios/do_zip.sh", <<-SCRIPT
pushd #{tmp_directory}/ipa_root/
zip -q -r archive.zip Payload
popd
SCRIPT

    :success
    sh "sh #{tmp_directory}/do_zip.sh"
  end

  def sh cmd
    log_info cmd.strip
    result = `#{cmd} 2>&1`.strip.each_line.map(&:strip).join("\n")
    if result.strip.length > 0
      log_info result
      __puts__ result
    end
    result
  end

  def deploy_to_device
    sh "ideviceinstaller --uninstall #{@app_id}" if @should_uninstall
    sh "ideviceinstaller -i \"#{tmp_directory}/#{@app_name}.ipa\""
    log_info "Check your device!!"
    :success
  end

  def simctl_list_devices
    output = sh "xcrun simctl list devices"

    # get only installed devices
    output = output.split("-- Unavailable").first

    devices = {}
    current_version_number_string = nil
    output.each_line do |l|
      if l.start_with? "-- iOS"
        current_version_number_string = l.strip.gsub("-- iOS ", "").gsub(" --", "")
      else
        tokens = l.gsub("(Booted)", "")
                  .gsub("(Shutdown)", "")
                  .strip.split(" (")

        device_name = tokens.first.strip
        device_id = tokens.last.gsub(")", "").strip
        device_name_2 = if tokens.length <= 2
                          ""
                        else
                          tokens[1].gsub(")", "").strip
                        end

        if !device_id.include? "Devices"
          devices[device_id] = {
            name: device_name,
            name_2: device_name_2,
            version_string: current_version_number_string,
            version_number: current_version_number_string.split(".").map(&:to_i),
            id: device_id
          }
        end
      end
    end

    devices
  end

  def install_simulator_if_needed
    results = sh "xcrun simctl list devices"
    results = results.split("== Devices ==").last
    iphone_13_pro_max_line = results.split("\n").find { |line| line.include? "iPhone 13 Pro Max" }
    if iphone_13_pro_max_line && iphone_13_pro_max_line.include?("unavailable")
      iphone_13_pro_max_line = nil
    end

    if !iphone_13_pro_max_line
      puts "* INFO: Installing iPhone 13 Pro Max simulator..."
      install_command =  "xcrun simctl create \"iPhone 13 Pro Max\" com.apple.CoreSimulator.SimDeviceType.iPhone-13-Pro-Max"
      results = sh install_command
      if results.include? "Could not find an"
        raise WizardException.new(
          "* ERROR: Unable to install simulator a default simulator.",
          "** Please run the following command in your terminal:",
          "",
          "     xcodebuild -downloadPlatform iOS",
          ""
        )
      end
    end

    :success
  end

  def simctl_list_devices_max_version
    devices = simctl_list_devices
    max_version_number = devices.map { |k, v| v.version_number }.max
    max_version_number_string = max_version_number.join(".")
    devices.reject! { |k, v| v.version_string != max_version_number_string }
    devices
  end

  def simctl_iphone_device_id_max_version
    devices = simctl_list_devices_max_version
    k, v = devices.find { |k, v| v.name.include?("iPhone") && !v.name.include?("SE") }
    k
  end

  def simctl_iphone_device_id_by_name
    devices = simctl_list_devices
    k, v = devices.find { |k, v| v.name.downcase.include?(@opts[:sim_name].downcase) }
    k
  end

  def deploy_to_sim
    device_id = nil
    if @opts[:sim_name]
      device_id = simctl_iphone_device_id_by_name
      if !device_id
        $console.set_command "$wizards.ios.start env: :#{@opts[:env]}, sim_name: \"#{@opts[:sim_name]}\""
        raise WizardException.new(
          "* Unable to find simulator named '#{@opts[:sim_name]}'.",
          "** The name must (at least partially) match the name of an existing simulator.",
          "** Open your iOS simulator and check File > Open Simulator to see the options."
        )
      end
    else
      device_id = simctl_iphone_device_id_max_version
    end

    sh "xcrun simctl boot #{device_id}"
    sh "open -a Simulator"
    sh "xcrun simctl uninstall #{device_id} #{@app_id}"
    sh "xcrun simctl install #{device_id} \"#{tmp_directory}/#{@app_name}.app\""
    sh "xcrun simctl launch #{device_id} #{@app_id}"
    puts "Check your simulator!!\nYou can use cmd+left/right arrow to rotate the device."
    :success
  end

  def print_publish_help
    has_transporter = (sh "ls /Applications/Transporter.app").include? "Contents"
    if !has_transporter
      $gtk.openurl "https://apps.apple.com/us/app/transporter/id1450874784?mt=12"
      $console.set_command "$wizards.ios.start env: :#{@opts[:env]}, version: \"#{@opts[:version]}\""
      raise WizardException.new(
        "* To upload your app, Download Transporter from the App Store https://apps.apple.com/us/app/transporter/id1450874784?mt=12."
      )
    else
      sh "mkdir ./tmp/ios/intermediary_artifacts"
      sh "mv \"#{tmp_directory}/#{@app_name}.app\" #{tmp_directory}/intermediary_artifacts/"
      sh "mv \"#{tmp_directory}/do_zip.sh\" #{tmp_directory}/intermediary_artifacts"
      sh "mv \"#{tmp_directory}/Entitlements.plist\" #{tmp_directory}/intermediary_artifacts"
      sh "mv \"#{tmp_directory}/ipa_root\" #{tmp_directory}/intermediary_artifacts/"
      sh "open /Applications/Transporter.app"
      sh "open \"#{tmp_directory}\""
    end

    :success
  end

  def compile_icons
    cmd = <<-S
"/Applications/Xcode.app/Contents/Developer/usr/bin/actool" --output-format human-readable-text \\
                                                            --notices --warnings --platform iphoneos \\
                                                            --minimum-deployment-target 10.3 \\
                                                            --target-device iphone \\
                                                            --target-device ipad  --app-icon 'AppIcon' \\
                                                            --output-partial-info-plist '#{app_path}/AssetCatalog-Info.plist' \\
                                                            --compress-pngs --compile "#{app_path}" \\
                                                            "#{app_path}/Assets.xcassets"
S
    sh cmd
    :success
  end

  def stage_native_libs
    sh "cp -r \"#{game_dir}/native/\" \"#{app_path}/native/\""
    sh "CODESIGN_ALLOCATE=\"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate\" /usr/bin/codesign -f -s \"#{@certificate_name}\" --entitlements #{tmp_directory}/Entitlements.plist \"#{tmp_directory}/#{@app_name}.app/native/ios-device/ext.dylib\""
  end

  def set_version version
    @app_version = version
    start env: @opts[:env], version: version
  end

  def app_name
    @app_name
  end

  def app_version
    log_info "Attempting to retrieve App Version from metadata/ios_metadata.txt."
    ios_version_number = (ios_metadata.version || "").strip
    if ios_version_number.length == 0
      log_info "Not found. Attempting to retrieve App Version from metadata/game_metadata.txt."
      ios_version_number = (game_metadata.version || "").strip
    end
    ios_version_number
  end

  def determine_app_version
    @app_version = app_version
    return :success if @app_version
  end

  def certificate_name
    @certificate_name
  end

  def display_name
    "iOS Wizard"
  end

  def reset_simulators
    sh "killall \"Simulator\" 2> /dev/null"
    sh "xcrun simctl delete unavailable"
    sh "xcrun simctl shutdown all"
    sh "xcrun simctl erase all"
  end

  def get_steps_to_execute
    if @build_type == :sim
      steps_sim_build
    elsif @build_type == :dev || @build_type == :hotload
      steps_dev_build
    elsif @build_type == :test
      steps_test_build
    elsif @build_type == :prod
      steps_prod_build
    else
      []
    end
  end
end
